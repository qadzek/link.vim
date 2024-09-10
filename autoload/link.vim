" MAIN FUNCTIONS =================================================== {{{1

" Convert inline links to reference links within a range
" Types : 'multiple-links', 'single-link'
" Modes : 'normal', 'insert'
function! link#Convert(type = 'multiple-links', mode = 'normal') abort range
  let [l:orig_view, l:orig_line_nr, l:orig_col_nr, l:orig_fold_option] =
        \ link#Initialize()

  " Use cursor position before range function moves cursor to first line of
  " range: https://vi.stackexchange.com/questions/6036/
  if exists('b:init_view')
    let l:orig_view = b:init_view
    unlet b:init_view
  endif

  let [ l:heading_text, l:is_heading_present, l:heading_line_nr ] =
        \ link#GetHeadingInfo()

  let l:new_label_nr = link#GetNewLabelNumber(l:is_heading_present)
  let l:start_label_nr = l:new_label_nr

  let l:max_line_nr = link#LimitRangeToHeading(l:is_heading_present,
        \ l:heading_line_nr, a:lastline)

  " Loop over all lines within the range
  for l:cur_line_nr in range(a:firstline, l:max_line_nr)

    " Necessary if reference section is repositioned
    if l:is_heading_present && l:cur_line_nr >= l:heading_line_nr
      break
    endif

    if link#SkipLine(l:cur_line_nr)
      continue
    endif

    let l:all_links_on_line = link#ParseLineInBodyFor('inline', l:cur_line_nr)

    " Display error when trying to convert a single link but there is none
    if a:type ==# 'single-link' && len(l:all_links_on_line) == 0
      echom g:link#err_msg['no_inline_link']
      call link#Finalize(l:orig_view, l:orig_fold_option)
      return
    endif

    " Limit list of links to one link when converting a single inline link
    if a:type ==# 'single-link'
      let l:all_links_on_line = [ link#PickClosestLink(l:all_links_on_line, l:orig_col_nr) ]
    endif

    " Loop over all inline links on current line
    for l:link in l:all_links_on_line

      " Last label line number is known
      if exists('l:last_label_line_nr')
        let l:last_label_line_nr += 1

      " Last label line number is unknown, so look it up
      elseif l:is_heading_present
        let l:last_label_line_nr = link#GetLastLabel('line_nr')

      " No heading
      else
        call link#AddHeading(l:heading_text)
        let l:is_heading_present = 1
        let l:heading_line_nr = link#GetHeadingLineNr(l:heading_text)
        let l:last_label_line_nr = l:heading_line_nr + 1
      endif

      let l:cur_line_content = getline(l:cur_line_nr)

      call link#ReplaceLink(l:cur_line_content, l:link['full_link'],
            \ l:link['link_text'], l:new_label_nr, l:cur_line_nr)

      call link#AddReference(l:new_label_nr, l:link['destination'],
            \ l:last_label_line_nr)

      let l:new_label_nr += 1
    endfor " End looping over all links on current line
  endfor " End looping over all lines

  call link#Finalize(l:orig_view, l:orig_fold_option)

  " Display how many links were converted
  if a:type !=# 'single-link'
    echom l:new_label_nr - l:start_label_nr .. ' links were converted'
  endif

  " Move cursor when function is called from Insert mode, to allow user to
  " continue typing after the converted link
  if a:type ==# 'single-link' && a:mode ==# 'insert'
    " Move to end of reference link: first to start, then to 2nd ]

    call cursor(l:orig_line_nr, l:link['col_start'])

    if link#IsFiletypeMarkdown()
      normal! 2f]
    else
      normal! f]
    endif

    " Determine if link is at the very end of the line
    let l:orig_line_len = strlen(l:cur_line_content)
    let l:sum = l:link['col_start'] + l:link['length'] - 1

    " Return to insert mode; link is at the very end of the line
    if l:sum == l:orig_line_len
      startinsert!
    " Return to insert mode; link is in the middle of the line
    else
      normal! l
      startinsert
    endif
  endif
endfunction

" Jump between a reference link and the corresponding link reference definition
" Types: 'jump', 'open', 'peek'
function! link#Jump(type) abort
  let [l:orig_view, l:orig_line_nr, l:orig_col_nr, l:orig_fold_option] =
        \ link#Initialize()

  let [l:is_heading_present, l:heading_line_nr] = link#GetHeadingInfo()[1:2]
  if !l:is_heading_present
    echom g:link#err_msg['no_heading']
    call link#Finalize(l:orig_view, l:orig_fold_option)
    return
  endif

  " No opening/peeking from reference section
  if (a:type ==# 'open' || a:type ==# 'peek') && l:orig_line_nr >= l:heading_line_nr
    echom g:link#err_msg['not_from_ref']
    call link#Finalize(l:orig_view, l:orig_fold_option)
    return
  endif

  " Determine if we should jump to the reference section or to the document body
  if l:orig_line_nr < l:heading_line_nr
    let l:line_nr = link#JumpToReferenceSection(l:orig_line_nr, l:orig_col_nr, l:heading_line_nr)
  else
    let l:line_nr = link#JumpToBody(l:orig_line_nr, l:heading_line_nr)
  endif

  " 0 will get returned if the jump failed
  if l:line_nr == 0
    call link#Finalize(l:orig_view, l:orig_fold_option)
    return
  endif

  " Open URL from corresponding link reference definition in browser
  if a:type ==# 'open'
    let l:ref_link = link#ParseReferenceSection(l:line_nr, 'one')[0]
    let l:url = l:ref_link['destination']

    " Add protocol if required
    if l:url =~# '^www'
      let l:url = 'https://' .. l:url
    endif

    " Not a valid URL
    if l:url !~# '^http'
      echom g:link#err_msg['no_valid_url'] .. ': ' .. l:url
      call link#Finalize(l:orig_view, l:orig_fold_option)
      return
    endif

    " Decide which command to use, based on the OS
    let l:os = link#GetOperatingSystem()
    if l:os ==? 'Darwin'
      let l:cmd = 'open'
    elseif l:os ==? 'Linux'
      let l:cmd = 'xdg-open'
    elseif l:os ==? 'Windows'
      let l:cmd = 'start'
    endif

    """ Open URL in browser
    " Escape URL, to support URLs containing e.g. a question mark
    let l:esc_url = shellescape(l:url)
    " Capture the command's output and remove trailing newline
    let l:output = substitute( system(l:cmd .. ' ' .. l:esc_url),
          \ '\n\+$', '', '' )
    if v:shell_error != 0
      echom g:link#err_msg['open_in_browser_failed'] .. l:output
    endif

    call link#Finalize(l:orig_view, l:orig_fold_option)
  endif

  " Display corresponding link reference definition
  if a:type ==# 'peek'
    let l:line_content = getline('.')
    call link#Finalize(l:orig_view, l:orig_fold_option)
    echom l:line_content
  endif
endfunction

" Reformat reference links and reference section: renumber, merge, delete, mark
function! link#Reformat() abort
  let [l:orig_view, @_, @_, l:orig_fold_option] = link#Initialize()

  let [l:is_heading_present, l:heading_line_nr] = link#GetHeadingInfo()[1:2]
  if !l:is_heading_present
    echom g:link#err_msg['no_heading']
    call link#Finalize(l:orig_view, l:orig_fold_option)
    return
  endif

  let l:ref_section_start = l:heading_line_nr + 2
  let l:ref_section_end = link#GetLastLabel('line_nr')
  let l:ref_section = link#ParseReferenceSection(l:ref_section_start, 'all')

  " Nth reference link, counting from start of document body
  let l:index = link#GetLabelStartIndex()

  let l:all_ref_links = []

  " Loop over all lines from first line until heading
  for l:body_line_nr in range(1, l:heading_line_nr - 1)
    if link#SkipLine(l:body_line_nr)
      continue
    endif

    let l:all_links_on_line = link#ParseLineInBodyFor('reference',
          \ l:body_line_nr)

    " Loop over all links on current line
    for l:link in l:all_links_on_line
      let l:body_line_content = getline(l:body_line_nr)
      let l:link['line_nr'] = l:body_line_nr

      " Find the link reference definition with a corresponding label
      let l:ref_section_copy = deepcopy(l:ref_section)
      let l:corresponding_refs = filter(l:ref_section_copy,
            \ {_, val -> val['label'] ==# l:link['destination']})

      " Corresponding label was not found in the reference section, so label
      " will be changed to '???', to mark that it's broken
      if len(l:corresponding_refs) == 0
        call link#ReplaceLink(l:body_line_content, l:link['full_link'],
              \ l:link['link_text'], '???', l:body_line_nr)
        continue
      endif

      let l:link['url'] = l:corresponding_refs[0]['destination']
      let l:link['index'] = l:index

      " Determine if exactly the same URL was already encountered before
      let l:all_ref_links_copy = deepcopy(l:all_ref_links)
      let l:url_matches = filter( l:all_ref_links_copy,
            \ { _, val -> val['url'] ==# l:link['url'] } )
      " 'Merge' labels
      if len(l:url_matches) >= 1
        let l:link['index'] = l:url_matches[0]['index']
        call link#ReplaceLink(l:body_line_content, l:link['full_link'],
              \ l:link['link_text'], l:link['index'], l:body_line_nr)
        continue
      endif

      " Label differs from index: e.g. label says 5 while it's the 3rd link
      if l:link['destination'] !=# l:link['index']
        call link#ReplaceLink(l:body_line_content, l:link['full_link'],
              \ l:link['link_text'], l:link['index'], l:body_line_nr)
      endif

      call add(l:all_ref_links, l:link)

      let l:index += 1
    endfor
  endfor

  " Delete current reference section to black hole register
  silent execute 'normal! :' .. l:ref_section_start .. ',' .. l:ref_section_end
        \ .. "$ delete _ \<CR>"

  " Add new reference section
  for l:idx in range( len(l:all_ref_links) )
    let l:ref_link = l:all_ref_links[l:idx]
    let l:line_nr = l:ref_section_start - 1 + l:idx
    call link#AddReference(l:ref_link['index'], l:ref_link['url'], l:line_nr)

  let l:ref_section_start = l:heading_line_nr + 2
  endfor

  let l:orig_ref_len = l:ref_section_end - l:ref_section_start + 1
  let l:new_ref_len = link#GetLastLabel('line_nr') - l:ref_section_start + 1
  echom 'Finished reformatting reference links and reference section'
  echom 'Number of lines in reference section -- Before: ' .. l:orig_ref_len .. ' -- After: ' .. l:new_ref_len

  call link#Finalize(l:orig_view, l:orig_fold_option)
endfunction

" HEADING ========================================================== {{{1

" Return buffer-local heading, or the global heading, or the default heading
function! link#GetHeadingText() abort
  if exists('b:link_heading')
    return b:link_heading
  endif

  if exists('g:link_heading')
    return g:link_heading
  endif

  if link#IsFiletypeMarkdown()
    return s:defaults['heading_markdown']
  else
    return s:defaults['heading_other']
  endif
endfunction

" Return <line_nr> if buffer contains heading, else 0
function! link#GetHeadingLineNr(heading) abort
  " Needed to get line number if there are two headings
  normal! G$

  " Search *b*ackward, accept a match at *c*ursor position, do *n*ot move
  " cursor, start search at cursor instead of *z*ero
  return search('^' .. a:heading .. '\s*$', 'bcnz')
endfunction

" Return 1 if heading is present in buffer, else 0
function! link#IsHeadingPresent(heading) abort
  let l:line_nr = link#GetHeadingLineNr(a:heading)
  return l:line_nr > 0
endfunction

" Return list of heading text, if heading is present, heading line number
function! link#GetHeadingInfo() abort
  let l:heading_text = link#GetHeadingText()
  let l:is_heading_present = link#IsHeadingPresent(l:heading_text)
  let l:heading_line_nr = link#GetHeadingLineNr(l:heading_text)
  return [ l:heading_text, l:is_heading_present, l:heading_line_nr ]
endfunction

" Add the specified heading to the buffer
function! link#AddHeading(heading_text) abort
  normal! G$

  " Move to a line matching a pattern, before adding the heading
  if exists('b:link_heading_before')

    " Cannot find pattern: show message
    if search(b:link_heading_before, 'bcWz') == 0
      echom g:link#err_msg['no_heading_pattern'] .. b:link_heading_before

    " Can find pattern: move 2 lines up
    else
      normal! 2k
    endif
  endif

  " Add a blank line above and below the heading
  call append('.', [ '', a:heading_text, ''  ])
endfunction

" DOCUMENT BODY ==================================================== {{{1

" Determine which link to use, if there are multiple links on one line
" The link that is positioned behind or on the cursor will be picked
function! link#PickClosestLink(links, col_nr) abort
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
function! link#ParseLineInBodyFor(type, line_nr) abort
  if a:type ==# 'inline'
    " Match http://, ftp://, www. etc.
    let l:protocol = '[a-zA-Z0-9.-]{2,12}:\/\/|www\.'

    " Match [foo](https://bar.com)
    if link#IsFiletypeMarkdown()
      let l:regex = '\v' .. '\[(' .. '[^]]+' .. ')\]' .
          \ '\((' .. '%(' .. l:protocol .. ')' .. '[^)]+' .. ')\)'

    " Match https://bar.com
    else
      " '()' ensures the right match ends up in the right subgroup
      let l:regex = '\v' .. '()' .. '(%(' .. l:protocol .. ')' .. '\S+)'
  endif

  elseif a:type ==# 'reference'
    " Match [foo][3]
    if link#IsFiletypeMarkdown()
      let l:regex = '\v' .. '\[(' .. '[^]]+' .. ')\]' .. '\[(' .. '[^]]+' .. ')\]'

    " Match [3]
    else
      let l:regex = '\v' .. '()' .. '\[(' .. '[^]]+' .. ')\]'
    endif

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
    let l:match_start = match(l:line_content, '\V' .. l:match_list[0]) + 1

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
function! link#ReplaceLink(line_content, full_link, link_text, label, line_nr) abort
  " NOTE URLs containing the * character are not supported
  let l:esc_full_link = escape(a:full_link, '[]')

  if link#IsFiletypeMarkdown()
    let l:ref_link = '[' .. a:link_text .. '][' .. a:label .. ']'
  else
    let l:ref_link = '[' .. a:label .. ']'
  endif

  let l:new_line_content = substitute(a:line_content, l:esc_full_link,
        \ l:ref_link, '')
  call setline(a:line_nr, l:new_line_content)
endfunction

" REFERENCE SECTION ================================================ {{{1

" Add a link reference definition to the reference section
function! link#AddReference(label, url, last_label_line_nr = '$') abort
  let l:new_line_content = '[' .. a:label .. ']: ' .. a:url
  call append(a:last_label_line_nr, l:new_line_content)
endfunction

" Parse the reference section, in its entirety or just one line
" Return a list of dictionaries
function! link#ParseReferenceSection(start_line_nr, type) abort
  if a:type ==# 'all'
    let l:cur_line_nr = a:start_line_nr
    let l:last_line_nr = line('$')
  elseif a:type ==# 'one'
    let l:cur_line_nr = a:start_line_nr
    let l:last_line_nr = a:start_line_nr
  endif

  " https://github.github.com/gfm/#link-reference-definition
  let l:all_link_reference_definitions = []
  let l:regex = '\v^\s*\[(\d+)\]:\s+(\S+)'

  " Loop over one line, or over all lines from heading until last line

  for l:cur_line_nr in range(l:cur_line_nr, l:last_line_nr)
    let l:cur_line_content = getline(l:cur_line_nr)

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
  endfor

  return l:all_link_reference_definitions
endfunction

" LABEL ============================================================ {{{1

" Determine new label number
function! link#GetNewLabelNumber(is_heading_present) abort
  if a:is_heading_present
    return link#GetLastLabel('label_nr') + 1
  endif

  return link#GetLabelStartIndex()
endfunction

" Return the start index for the first label, buffer-local or global, or default
function! link#GetLabelStartIndex() abort
  if exists('b:link_start_index')
    return b:link_start_index
  endif

  if exists('g:link_start_index')
    return g:link_start_index
  endif

  return s:defaults['start_index']
endfunction

" Types : 'line_nr' or 'label_nr'
" 'label_nr':
" Return last label number in reference section, e.g. 3 for [3]: http://foo.com
" Return -1 if not found
" 'line_nr':
" Return line number of last label in reference section
" Return last line number of buffer if not found
function! link#GetLastLabel(type) abort
  let l:regex = '\v^\s*\[\zs\d+\ze\]:\s+'

  " Go to start of last non-blank line
  " silent execute "normal! G$?.\<CR>0"

  normal! G$
  call search(l:regex, 'bcW')

  if a:type ==# 'line_nr'
    return line('.')
  endif

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
function! link#JumpToReferenceSection(orig_line_nr, orig_col_nr, heading_line_nr) abort
  let l:all_links = link#ParseLineInBodyFor('reference', a:orig_line_nr)
  if len(l:all_links) == 0
    echom g:link#err_msg['no_reference_link']
    return 0
  endif

  let l:link = link#PickClosestLink(l:all_links, a:orig_col_nr)
  let l:label = l:link['destination']

  let l:regex = '\v^\s*\[' .. l:label .. '\]:\s+\S+'

  " Start search at heading
  call cursor(a:heading_line_nr, 1)

  " Move cursor
  " Line number of match, or 0 in case of no match
  let l:ref_line_nr = search(l:regex, 'cW')

  " Put cursor on start of URL
  normal! W

  if l:ref_line_nr == 0
    echom g:link#err_msg['no_label_ref_section'] .. l:label
  endif

  " 0 in case of no match
  return l:ref_line_nr
endfunction

" Jump from a link reference definition in the reference section
" [3]: http://bar.com to the corresponding reference link in the document body
" [foo][3]
" Return line number of match, or 0
function! link#JumpToBody(orig_line_nr, heading_line_nr) abort
  let l:reference_section = link#ParseReferenceSection(a:orig_line_nr, 'one')
  if len(l:reference_section) == 0
    echom g:link#err_msg['no_link_ref_definition']
    return 0
  endif
  let l:link_reference_definition = l:reference_section[0]
  let l:label = l:link_reference_definition['label']

  " Start search at first line
  call cursor(1, 1)
  " Stop search at heading
  let l:body_line_nr = search('\v\[' .. l:label .. '\]', 'cWe', a:heading_line_nr)

  if l:body_line_nr == 0
    echom g:link#err_msg['no_label_body'] .. l:label
  endif

  " 0 in case of no match
  return l:body_line_nr
endfunction

" HELPERS ========================================================== {{{1

" Temporarily disable folding
" Return list of original view, line number, column number and folding option
function! link#Initialize() abort
  let l:orig_view = winsaveview()
  let l:line_nr = l:orig_view['lnum']
  let l:col_nr = l:orig_view['col'] + 1

  let l:orig_fold_option = &foldenable
  setlocal nofoldenable

  return [ l:orig_view, l:line_nr, l:col_nr, l:orig_fold_option ]
endfunction

" Restore original view and folding option
function! link#Finalize(orig_view, orig_fold_option) abort
  call winrestview(a:orig_view)
  let &l:foldenable = a:orig_fold_option
  call link#VimwikiRefLinksRefresh()
endfunction

" Limit range to line containing heading, so reference section stays untouched
function! link#LimitRangeToHeading(is_heading_present, heading_line_nr, range_end_line_nr) abort range
  if a:is_heading_present && a:range_end_line_nr > a:heading_line_nr
    return a:heading_line_nr
  endif

  return a:range_end_line_nr
endfunction

" Return 1 if line should be skipped, else 0
function! link#SkipLine(cur_line_nr) abort
  "Custom pattern
  if exists('b:link_skip_line')
    let l:regex = b:link_skip_line
  else
    " Default
    let l:regex = '\V\^' .. substitute( escape(&commentstring, '\'), '%s', '\\.\\*', 'g' ) .. '\$'
  endif

  return match( getline(a:cur_line_nr), l:regex ) >= 0
endfunction

" Fix Vimwiki bug where newly created reference links don't work instantly
function! link#VimwikiRefLinksRefresh() abort
  " See https://github.com/vimwiki/vimwiki/issues/1005 and
  " https://github.com/vimwiki/vimwiki/issues/1351

  if &filetype !~# 'vimwiki'
    return
  endif

  call vimwiki#markdown_base#scan_reflinks()
endfunction

" Return the operating system: 'Darwin', 'Linux' or 'Windows'
function! link#GetOperatingSystem() abort
  " https://vi.stackexchange.com/a/2577/50213
  if has('win64') || has('win32') || has('win16')
    return 'Windows'
  else
    return substitute(system('uname'), '\n', '', '')
  endif
endfunction

function! link#IsFiletypeMarkdown() abort
  " NOTE This assumes that Vimwiki uses Markdown syntax
  return &filetype =~# 'markdown' || &filetype =~# 'vimwiki'
endfunction

" Default values, can be overridden by vimrc
let s:defaults = {
      \ 'heading_markdown': '## Links',
      \ 'heading_other': 'Links:',
      \ 'start_index': 0,
      \ }

" Error messages
let g:link#err_msg = {
      \ 'no_heading':
      \ 'No heading found',
      \ 'no_inline_link':
      \ 'No inline link found on this line in the format of "[foo](http://bar.com)" (Markdown) or "http://bar.com" (other)',
      \ 'no_link_ref_definition':
      \ 'No link reference definition in the format of "[3]: ..." found on this line',
      \ 'no_label_ref_section':
      \ 'The following label was not found in the reference section: ',
      \ 'no_label_body':
      \ 'The following label was not found in the document body: ',
      \ 'not_from_ref':
      \ 'This action is only possible from the document body, not from the reference section',
      \ 'no_reference_link':
      \ 'No reference link found on this line in the format of "[foo][3]" (Markdown) or "[3]" (other)',
      \ 'no_valid_url':
      \ 'Not a valid URL',
      \ 'open_in_browser_failed':
      \ 'Failed to open the URL, because of this error: ',
      \ 'no_heading_pattern':
      \ 'Failed to detect heading pattern: ',
      \ }
