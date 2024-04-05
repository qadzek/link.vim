" MAIN FUNCTIONS =================================================== {{{1

" Convert one inline link to a reference link on the current line
function! mdlink#ConvertSingleLink(mode = 'normal') abort
  let [l:orig_line_nr, l:orig_col_nr, l:orig_fold_option] = mdlink#Initialize()
  let l:cur_line_content = getline('.')

  let l:all_links_on_line = mdlink#ParseLineInBodyFor('inline', l:orig_line_nr)

  if len(l:all_links_on_line) == 0
    echom g:mdlink#err_msg['no_inline_link']
    return
  endif

  " Add heading if needed
  let l:heading_text = mdlink#GetHeadingText()
  let l:is_heading_present = mdlink#IsHeadingPresent(l:heading_text)
  if !l:is_heading_present
    call mdlink#AddHeading(l:heading_text)
  endif

  let l:new_label_nr = mdlink#GetNewLabelNumber(l:is_heading_present)

  " Determine which link to convert, if there are multiple on the current line
  let l:link = mdlink#PickClosestLink(l:all_links_on_line, l:orig_col_nr)

  call mdlink#ReplaceLink(l:cur_line_content, l:link['full_link'],
        \ l:link['link_text'], l:new_label_nr, l:orig_line_nr)
  call mdlink#AddReference(l:new_label_nr, l:link['destination'])

  call mdlink#Finalize(l:orig_line_nr, l:orig_col_nr, l:orig_fold_option)

  if a:mode ==# 'insert'
    " Move to end of reference link: first to start, then to 2nd ]
    call cursor(l:orig_line_nr, l:link['col_start'])
    normal! 2f]

    " Determine if link is at the very end of the line
    let l:orig_line_len = strlen(l:cur_line_content)
    let l:sum = l:link['col_start'] + l:link['length'] - 1

    " Return to insert mode
    " Link is at the very end of the line
    if l:sum == l:orig_line_len
      startinsert!
    " Link is in the middle of the line
    else
      normal! l
      startinsert
    endif
  endif
endfunction

" Convert inline links  to reference links within a range
function! mdlink#ConvertRange(type = 'range') abort range
  let [l:orig_line_nr, l:orig_col_nr, l:orig_fold_option] = mdlink#Initialize()

  let l:heading_text = mdlink#GetHeadingText()
  let l:is_heading_present = mdlink#IsHeadingPresent(l:heading_text)
  let l:heading_line_nr = mdlink#GetHeadingLineNr(l:heading_text)

  let l:new_label_nr = mdlink#GetNewLabelNumber(l:is_heading_present)
  let l:start_label_nr = l:new_label_nr

  " Determine lines to scan for links: entire document body, or within a range
  if a:type ==# 'all'
    let l:cur_line_nr = 1
    if l:is_heading_present
      let l:max_line_nr = l:heading_line_nr
    else
      let l:max_line_nr = line('$')
    endif

  elseif a:type ==# 'range'
    let l:cur_line_nr = a:firstline
    let l:max_line_nr = a:lastline

    if l:is_heading_present && a:lastline > l:heading_line_nr
      echom g:mdlink#err_msg['not_include_ref']
      call mdlink#Finalize(l:orig_line_nr, l:orig_col_nr, l:orig_fold_option)
      return
    endif
  endif

  " Loop over all lines within the range/from first line until heading
  while l:cur_line_nr <= l:max_line_nr
    let l:all_links_on_line = mdlink#ParseLineInBodyFor('inline', l:cur_line_nr)

    " Loop over all inline links on current line
    for l:link in l:all_links_on_line

      if !l:is_heading_present
        call mdlink#AddHeading(l:heading_text)
        let l:is_heading_present = 1
      endif

      let l:cur_line_content = getline(l:cur_line_nr)
      call mdlink#ReplaceLink(l:cur_line_content, l:link['full_link'],
            \ l:link['link_text'], l:new_label_nr, l:cur_line_nr)
      call mdlink#AddReference(l:new_label_nr, l:link['destination'])
      let l:new_label_nr += 1
    endfor

    let l:cur_line_nr += 1
  endwhile

  call mdlink#Finalize(l:orig_line_nr, l:orig_col_nr, l:orig_fold_option)
  echom l:new_label_nr - l:start_label_nr . ' inline links were converted'
endfunction

" Convert all inline links to reference links in the document body
function! mdlink#ConvertAllLinks() abort
  call mdlink#ConvertRange('all')
endfunction

" Jump between a reference link and the corresponding link reference definition
function! mdlink#Jump(type = 'jump') abort
  let [l:orig_line_nr, l:orig_col_nr, l:orig_fold_option] = mdlink#Initialize()

  let l:heading_text = mdlink#GetHeadingText()
  let l:is_heading_present = mdlink#IsHeadingPresent(l:heading_text)
  if !l:is_heading_present
    echom g:mdlink#err_msg['no_heading']
    call mdlink#Finalize(l:orig_line_nr, l:orig_col_nr, l:orig_fold_option)
    return
  endif
  let l:heading_line_nr = mdlink#GetHeadingLineNr(l:heading_text)

  " No opening/peeking from reference section
  if (a:type ==# 'open' || a:type ==# 'peek') && l:orig_line_nr >= l:heading_line_nr
    echom g:mdlink#err_msg['not_from_ref']
    call mdlink#Finalize(l:orig_line_nr, l:orig_col_nr, l:orig_fold_option)
    return
  endif

  " Determine if we should jump to the reference section or to the document body
  if l:orig_line_nr < l:heading_line_nr
    let l:line_nr = mdlink#JumpToReferenceSection(l:orig_line_nr, l:orig_col_nr, l:heading_line_nr)
  else
    let l:line_nr = mdlink#JumpToBody(l:orig_line_nr, l:heading_line_nr)
  endif

  " 0 will get returned if the jump failed
  if l:line_nr == 0
    call mdlink#Finalize(l:orig_line_nr, l:orig_col_nr, l:orig_fold_option)
    return
  endif

  " Open URL from corresponding link reference definition in browser
  if a:type ==# 'open'
    let l:ref_link = mdlink#ParseReferenceSection(l:line_nr, 'one')[0]
    let l:url = l:ref_link['destination']

    " Add protocol if required
    if l:url =~# '^www'
      let l:url = 'https://' . l:url
    endif

    " Not a valid URL
    if l:url !~# '^http'
      echom g:mdlink#err_msg['no_valid_url'] . ': ' . l:url
      call mdlink#Finalize(l:orig_line_nr, l:orig_col_nr, l:orig_fold_option)
      return
    endif

    " Decide which command to use, based on the OS
    let l:os = mdlink#GetOperatingSystem()
    if l:os ==? 'Darwin'
      let l:cmd = 'open'
    elseif l:os ==? 'Linux'
      let l:cmd = 'xdg-open'
    elseif l:os ==? 'Windows'
      let l:cmd = 'start'
    endif

    """ Open URL in browser
    " Capture the command's output and remove trailing newline
    let l:output = substitute( system(l:cmd . ' ' . l:url), '\n\+$', '', '' )
    if v:shell_error != 0
      echom g:mdlink#err_msg['open_in_browser_failed'] . l:output
    endif

    call mdlink#Finalize(l:orig_line_nr, l:orig_col_nr, l:orig_fold_option)
  endif

  " Display corresponding link reference definition
  if a:type ==# 'peek'
    let l:line_content = getline('.')
    call mdlink#Finalize(l:orig_line_nr, l:orig_col_nr, l:orig_fold_option)
    echom l:line_content
  endif
endfunction

" Open the URL from the corresponding reference link definition in the browser
function! mdlink#Open() abort
  call mdlink#Jump('open')
endfunction

" Get a preview of the corresponding reference link definition
function! mdlink#Peek() abort
  call mdlink#Jump('peek')
endfunction

" Delete link reference definitions that are no longer needed
function! mdlink#DeleteUnneededRefs(env = 'production') abort
  if a:env ==# 'production'
    let l:reply = confirm('Delete links in reference section that are no longer needed?', "&Yes\n&No", 3)
    if l:reply != 1
      return
    endif
  endif

  let [l:orig_line_nr, l:orig_col_nr, l:orig_fold_option] = mdlink#Initialize()

  let l:heading_text = mdlink#GetHeadingText()
  let l:is_heading_present = mdlink#IsHeadingPresent(l:heading_text)
  if !l:is_heading_present
    echom g:mdlink#err_msg['no_heading']
    call mdlink#Finalize(l:orig_line_nr, l:orig_col_nr, l:orig_fold_option)
    return
  endif
  let l:heading_line_nr = mdlink#GetHeadingLineNr(l:heading_text)

  """ Store all reference links from the document body
  let l:all_labels = []

  " Loop over all lines from first line until heading
  let l:cur_line_nr = 1
  while l:cur_line_nr < l:heading_line_nr
    let l:all_links_on_line = mdlink#ParseLineInBodyFor('reference', l:cur_line_nr)

    " Loop over all links on current line
    for l:link in l:all_links_on_line
      call add(l:all_labels, l:link['destination'])
    endfor

    let l:cur_line_nr += 1
  endwhile

  """ Loop over all link reference definitions in the reference section
  let l:cur_line_nr = l:heading_line_nr + 1
  let l:last_line_nr = line('$')

  " Protect against an infinite loop
  let l:loop_count = 0
  let l:loop_max = l:last_line_nr - l:heading_line_nr - 1

  let l:delete_count = 0

  while l:cur_line_nr <= l:last_line_nr && l:loop_count <= l:loop_max
    let l:loop_count += 1
    let l:cur_line_nr += 1

    let l:ref_link = mdlink#ParseReferenceSection(l:cur_line_nr, 'one')
    if len(l:ref_link) == 0
      continue
    endif
    let l:label = l:ref_link[0]['label']

    " Corresponding label in the document body
    if index(l:all_labels, l:label) >= 0
      continue
    endif

    " No corresponding label in the document body
    "  Delete line to black hole register
    execute l:cur_line_nr . ' delete _'
    let l:delete_count += 1
    " Line number shouldn't be increased, as a line was just removed
    let l:cur_line_nr -= 1
  endwhile

  echom l:delete_count . ' links have been deleted from the reference section'
  call mdlink#Finalize(l:orig_line_nr, l:orig_col_nr, l:orig_fold_option)
endfunction

" HEADING ========================================================== {{{1

" Return heading specified in vimrc, or the default heading
function! mdlink#GetHeadingText() abort
  return get(g:, 'md_link_heading', s:defaults['heading'])
endfunction

" Return <line_nr> if buffer contains heading, else 0
function! mdlink#GetHeadingLineNr(heading) abort
  " Needed to get line number if there are two headings
  normal! G$

  " Search *b*ackward, accept a match at *c*ursor position, do *n*ot move
  " cursor, start search at cursor instead of *z*ero
  return search('^' . a:heading . '\s*$', 'bcnz')
endfunction

" Return 1 if heading is present in buffer, else 0
function! mdlink#IsHeadingPresent(heading) abort
  let l:line_nr = mdlink#GetHeadingLineNr(a:heading)
  return l:line_nr > 0
endfunction

" Add the specified heading to the buffer
function! mdlink#AddHeading(heading_text) abort
  " Add a blank line above and below the heading
  call append('$', [ '', a:heading_text, ''  ])
endfunction

" DOCUMENT BODY ==================================================== {{{1

" Determine which link to use, if there are multiple links on one line
" The link that is positioned behind or on the cursor will be picked
function! mdlink#PickClosestLink(links, col_nr) abort
  if len(a:links) == 1
    return a:links[0]
  endif

  for l:link in a:links
    if a:col_nr < l:link['col_start'] + l:link['length']
      break
    endif
  endfor

  return l:link
endfunction

" Scan one line in the document body for an inline link [foo](bar.com) or a
" reference link [foo][5]
" Return list of dictionaries, containing full link [foo](www.bar.com), link
" text, destination (URL or reference), length of total match and start position
" of total match
function! mdlink#ParseLineInBodyFor(type, line_nr) abort
  if a:type ==# 'inline'
    let l:regex = '\v' . '\[(' . '[^]]+' . ')\]' . '\((' . '[^)]+' . ')\)'
  elseif a:type ==# 'reference'
    let l:regex = '\v' . '\[(' . '[^]]+' . ')\]' . '\[(' . '[^]]+' . ')\]'
  else
    throw 'Invalid type'
  endif

  let l:line_content = getline(a:line_nr)
  let l:line_len = strlen(l:line_content)

  let l:all_links = []
  let l:col = 0

  " Get all links on the specified line
  while l:col < l:line_len
    let l:match_list = matchlist(l:line_content, l:regex, l:col)

    if len(l:match_list) == 0
      break
    endif

    " First character is considered as 0
    let l:match_start = match(l:line_content, '\V' . l:match_list[0]) + 1

    let l:total_len = strlen(l:match_list[0])

    let l:link = {
          \ 'full_link': l:match_list[0],
          \ 'link_text': l:match_list[1],
          \ 'destination': l:match_list[2],
          \ 'length': l:total_len,
          \ 'col_start': l:match_start,
          \ }

    call add(l:all_links, l:link)
    let l:col = l:match_start + l:total_len
  endwhile

  return l:all_links
endfunction

" Convert inline link to reference link by replacing line content
function! mdlink#ReplaceLink(line_content, full_link, link_text, label, line_nr) abort
  " NOTE URLs containing the * character are not supported
  let l:esc_full_link = escape(a:full_link, '[]')
  let l:ref_link = '[' . a:link_text . '][' . a:label . ']'
  let l:new_line_content = substitute(a:line_content, l:esc_full_link,
        \ l:ref_link, '')
  call setline(a:line_nr, l:new_line_content)
endfunction

" REFERENCE SECTION ================================================ {{{1

" Add a link reference definition to the reference section
function! mdlink#AddReference(label, url) abort
  let l:new_line_content = '[' . a:label . ']: ' . a:url
  call append('$', l:new_line_content)
endfunction

" Parse the reference section, in its entirety or just one line
" Return a list of dictionaries
function! mdlink#ParseReferenceSection(start_line_nr, type) abort
  if a:type ==# 'all' " This type isn't used at the moment
    let l:cur_line_nr = a:start_line_nr + 1
    let l:last_line_nr = line('$')
  elseif a:type ==# 'one'
    let l:cur_line_nr = a:start_line_nr
    let l:last_line_nr = a:start_line_nr
  endif

  " https://github.github.com/gfm/#link-reference-definition
  let l:all_link_reference_definitions = []
  let l:regex = '\v^\s*\[(\d+)\]:\s+(\S+)'

  " Loop over one line, or over all lines from heading until last line
  while l:cur_line_nr <= l:last_line_nr
    let l:cur_line_content = getline(l:cur_line_nr)
    let l:cur_line_nr += 1

    let l:match_list = matchlist(l:cur_line_content, l:regex)

    if len(l:match_list) == 0
      continue
    endif

    let l:link_ref_def = {
          \ 'line_nr': l:cur_line_nr - 1,
          \ 'full_match': l:match_list[0],
          \ 'label': l:match_list[1],
          \ 'destination': l:match_list[2],
          \ }

    call add(l:all_link_reference_definitions, l:link_ref_def)
  endwhile

  return l:all_link_reference_definitions
endfunction

" LABEL ============================================================ {{{1

" Determine new label number
function! mdlink#GetNewLabelNumber(is_heading_present) abort
  if a:is_heading_present
    return mdlink#GetLastLabel() + 1
  endif

  return mdlink#GetLabelStartIndex()
endfunction

" Return the start index for the first label, specified in vimrc, or the default
function! mdlink#GetLabelStartIndex() abort
  return get(g:, 'md_link_start_index', s:defaults['start_index'])
endfunction

" Return last label number in reference section, e.g. 3 for [3]: http://foo.com
" Return -1 if not found
function! mdlink#GetLastLabel() abort
  let l:regex = '\v^\s*\[\zs\d+\ze\]:\s+'

  " Go to start of last non-blank line
  silent execute "normal! G$?.\<CR>0"

  " Get number between square brackets
  let l:last_line_content = getline('.')
  let l:match = matchstr(l:last_line_content, l:regex)

  " This could happen if there is only a header present, without any labels, or
  " if there is regular text below the header
  if l:match !~# '^\d\+$'
    return -1
  endif

  return str2nr(l:match)
endfunction

" JUMP ============================================================= {{{1

" Jump from a reference link in the document body [foo][3] to the corresponding
" link reference definition in the reference section [3]: http://bar.com
" Return line number of match, or 0
function! mdlink#JumpToReferenceSection(orig_line_nr, orig_col_nr, heading_line_nr) abort
  let l:all_links = mdlink#ParseLineInBodyFor('reference', a:orig_line_nr)
  if len(l:all_links) == 0
    echom g:mdlink#err_msg['no_reference_link']
    return 0
  endif

  let l:link = mdlink#PickClosestLink(l:all_links, a:orig_col_nr)
  let l:label = l:link['destination']

  let l:regex = '\v^\s*\[' . l:label . '\]:\s+\S+'

  " Start search at heading
  call cursor(a:heading_line_nr, 1)

  " Move cursor
  " Line number of match, or 0 in case of no match
  let l:ref_line_nr = search(l:regex, 'cW')

  " Put cursor on start of URL
  normal! W

  if l:ref_line_nr == 0
    echom g:mdlink#err_msg['no_label_ref_section'] . l:label
  endif

  " 0 in case of no match
  return l:ref_line_nr
endfunction

" Jump from a link reference definition in the reference section
" [3]: http://bar.com to the corresponding reference link in the document body
" [foo][3]
" Return line number of match, or 0
function! mdlink#JumpToBody(orig_line_nr, heading_line_nr) abort
  let l:reference_section = mdlink#ParseReferenceSection(a:orig_line_nr, 'one')
  if len(l:reference_section) == 0
    echom g:mdlink#err_msg['no_link_ref_definition']
    return 0
  endif
  let l:link_reference_definition = l:reference_section[0]
  let l:label = l:link_reference_definition['label']

  " Start search at first line
  call cursor(1, 1)
  " Stop search at heading
  let l:body_line_nr = search('\v\]\[' . l:label . '\]', 'cWe', a:heading_line_nr)

  if l:body_line_nr == 0
    echom 'Could not find the label ' . l:label . ' in the document body'
  endif

  " 0 in case of no match
  return l:body_line_nr
endfunction

" HELPERS ========================================================== {{{1

" Return list of original line number, column number and folding option
" Temporarily disable folding
function! mdlink#Initialize() abort
  let [@_, l:line_nr, l:col_nr, @_, @_] = getcurpos()
  let l:orig_fold_option = &foldenable
  setlocal nofoldenable
  return [l:line_nr, l:col_nr, l:orig_fold_option]
endfunction

" Restore cursor position and folding option
function! mdlink#Finalize(orig_line_nr, orig_col_nr, orig_fold_option) abort
  call cursor(a:orig_line_nr, a:orig_col_nr)
  let &l:foldenable = a:orig_fold_option
  call mdlink#VimwikiRefLinksRefresh()
endfunction

" Fix Vimwiki bug where newly created reference links don't work instantly
function! mdlink#VimwikiRefLinksRefresh() abort
  " See https://github.com/vimwiki/vimwiki/issues/1005 and
  " https://github.com/vimwiki/vimwiki/issues/1351

  if &filetype !~# 'vimwiki'
    return
  endif

  call vimwiki#markdown_base#scan_reflinks()
endfunction

" Return the operating system: 'Darwin', 'Linux' or 'Windows'
function! mdlink#GetOperatingSystem() abort
  " https://vi.stackexchange.com/a/2577/50213
  if has('win64') || has('win32') || has('win16')
    return 'Windows'
  else
    return substitute(system('uname'), '\n', '', '')
  endif
endfunction

" Default values, can be overridden by vimrc
let s:defaults = {
  \ 'heading': '## Links',
  \ 'start_index': 0,
  \ }

" Error messages
let g:mdlink#err_msg = {
  \ 'no_corresponding_ref':
    \ 'No corresponding label found in the references section',
  \ 'no_heading':
    \ 'No heading found',
  \ 'no_inline_link':
    \ 'No inline link in the format of "[foo](http://bar.com)" found on this line',
  \ 'no_link_ref_definition':
    \ 'No link reference definition in the format of "[3]: ..." found on this line',
  \ 'no_label_ref_section':
    \ 'The following label was not found in the reference section: ',
  \ 'not_from_ref':
    \ 'This action is only possible from the document body, not from the reference section',
  \ 'not_include_ref':
    \ 'The range cannot include (parts of) the reference section',
  \ 'no_reference_link':
    \ 'No reference link in the format of "[foo][3]" found on this line',
  \ 'no_valid_url':
    \ 'Not a valid URL',
  \ 'open_in_browser_failed':
    \ 'Failed to open the URL, because of this error: ',
  \ }
