" Convert inline links to reference links within a range
" Types : 'multiple-links', 'single-link'
" Modes : 'normal', 'insert'
function! link#Convert(type = 'multiple-links', mode = 'normal') abort range
  let [l:orig_view, l:orig_line_nr, l:orig_col_nr, l:orig_fold_option] =
        \ link#lifecycle#Initialize()

  " Use cursor position before range function moves cursor to first line of
  " range: https://vi.stackexchange.com/questions/6036/
  if exists('b:init_view')
    let l:orig_view = b:init_view
    unlet b:init_view
  endif

  let [ l:heading_text, l:is_heading_present, l:heading_line_nr ] =
        \ link#heading#GetInfo()

  let l:new_label_nr = link#label#GetNewNumber(l:is_heading_present)
  let l:start_label_nr = l:new_label_nr

  let l:max_line_nr = link#heading#LimitRange(l:is_heading_present,
        \ l:heading_line_nr, a:lastline)

  " Loop over all lines within the range
  for l:cur_line_nr in range(a:firstline, l:max_line_nr)

    " Necessary if reference section is repositioned
    if l:is_heading_present && l:cur_line_nr >= l:heading_line_nr
      break
    endif

    if link#body#SkipLine(l:cur_line_nr)
      continue
    endif

    let l:all_links_on_line = link#body#ParseLineFor('inline', l:cur_line_nr)

    " Display error when trying to convert a single link but there is none
    if a:type ==# 'single-link' && len(l:all_links_on_line) == 0
      echom g:link#globals#err_msg['no_inline_link']
      call link#lifecycle#Finalize(l:orig_view, l:orig_fold_option)
      return
    endif

    " Limit list of links to one link when converting a single inline link
    if a:type ==# 'single-link'
      let l:all_links_on_line = [ link#body#PickClosestLink(l:all_links_on_line, l:orig_col_nr) ]
    endif

    " Loop over all inline links on current line
    for l:link in l:all_links_on_line

      " Last label line number is known
      if exists('l:last_label_line_nr')
        let l:last_label_line_nr += 1

      " Last label line number is unknown, so look it up
      elseif l:is_heading_present
        let l:last_label_line_nr = link#label#GetLast('line_nr')

      " No heading
      else
        call link#heading#Add(l:heading_text)
        let l:is_heading_present = 1
        let l:heading_line_nr = link#heading#GetLineNr(l:heading_text)
        let l:last_label_line_nr = l:heading_line_nr + 1
      endif

      let l:cur_line_content = getline(l:cur_line_nr)

      call link#body#ReplaceLink(l:cur_line_content, l:link['full_link'],
            \ l:link['link_text'], l:new_label_nr, l:cur_line_nr)

      call link#reference#Add(l:new_label_nr, l:link['destination'],
            \ l:last_label_line_nr)

      let l:new_label_nr += 1
    endfor " End looping over all links on current line
  endfor " End looping over all lines

  call link#lifecycle#Finalize(l:orig_view, l:orig_fold_option)

  " Display how many links were converted
  if a:type !=# 'single-link'
    echom l:new_label_nr - l:start_label_nr .. ' links were converted'
  endif

  " Move cursor when function is called from Insert mode, to allow user to
  " continue typing after the converted link
  if a:type ==# 'single-link' && a:mode ==# 'insert'
    " Move to end of reference link: first to start, then to 2nd ]

    call cursor(l:orig_line_nr, l:link['col_start'])

    if link#utils#IsFiletypeMarkdown()
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
        \ link#lifecycle#Initialize()

  let [l:is_heading_present, l:heading_line_nr] = link#heading#GetInfo()[1:2]
  if !l:is_heading_present
    echom g:link#globals#err_msg['no_heading']
    call link#lifecycle#Finalize(l:orig_view, l:orig_fold_option)
    return
  endif

  " No opening/peeking from reference section
  if (a:type ==# 'open' || a:type ==# 'peek') && l:orig_line_nr >= l:heading_line_nr
    echom g:link#globals#err_msg['not_from_ref']
    call link#lifecycle#Finalize(l:orig_view, l:orig_fold_option)
    return
  endif

  " Determine if we should jump to the reference section or to the document body
  if l:orig_line_nr < l:heading_line_nr
    let l:line_nr = link#jump#ToReferenceSection(l:orig_line_nr, l:orig_col_nr, l:heading_line_nr)
  else
    let l:line_nr = link#jump#ToBody(l:orig_line_nr, l:heading_line_nr)
  endif

  " 0 will get returned if the jump failed
  if l:line_nr == 0
    call link#lifecycle#Finalize(l:orig_view, l:orig_fold_option)
    return
  endif

  " Open URL from corresponding link reference definition in browser
  if a:type ==# 'open'
    let l:ref_link = link#reference#Parse(l:line_nr, 'one')[0]
    let l:url = l:ref_link['destination']

    " Add protocol if required
    if l:url =~# '^www'
      let l:url = 'https://' .. l:url
    endif

    " Not a valid URL
    if l:url !~# '^http'
      echom g:link#globals#err_msg['no_valid_url'] .. ': ' .. l:url
      call link#lifecycle#Finalize(l:orig_view, l:orig_fold_option)
      return
    endif

    " Don't open links in browser when running tests if `-b` flag is set
    if $VADER_OPEN_IN_BROWSER ==# 'false'
      call link#lifecycle#Finalize(l:orig_view, l:orig_fold_option)
      return
    endif

    " Decide which command to use, based on the OS
    let l:os = link#utils#GetOperatingSystem()
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
      echom g:link#globals#err_msg['open_in_browser_failed'] .. l:output
    endif

    call link#lifecycle#Finalize(l:orig_view, l:orig_fold_option)
  endif

  " Display corresponding link reference definition
  if a:type ==# 'peek'
    let l:line_content = getline('.')
    call link#lifecycle#Finalize(l:orig_view, l:orig_fold_option)
    echom l:line_content
  endif
endfunction

" Reformat reference links and reference section: renumber, merge, delete, mark
function! link#Reformat() abort
  let [l:orig_view, @_, @_, l:orig_fold_option] = link#lifecycle#Initialize()

  let [l:is_heading_present, l:heading_line_nr] = link#heading#GetInfo()[1:2]
  if !l:is_heading_present
    echom g:link#globals#err_msg['no_heading']
    call link#lifecycle#Finalize(l:orig_view, l:orig_fold_option)
    return
  endif

  let l:ref_section_start = l:heading_line_nr + 2
  let l:ref_section_end = link#label#GetLast('line_nr')
  let l:ref_section = link#reference#Parse(l:ref_section_start, 'all')

  " Nth reference link, counting from start of document body
  let l:index = link#label#GetStartIndex()

  let l:all_ref_links = []

  " Loop over all lines from first line until heading
  for l:body_line_nr in range(1, l:heading_line_nr - 1)
    if link#body#SkipLine(l:body_line_nr)
      continue
    endif

    let l:all_links_on_line = link#body#ParseLineFor('reference',
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
        call link#body#ReplaceLink(l:body_line_content, l:link['full_link'],
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
        call link#body#ReplaceLink(l:body_line_content, l:link['full_link'],
              \ l:link['link_text'], l:link['index'], l:body_line_nr)
        continue
      endif

      " Label differs from index: e.g. label says 5 while it's the 3rd link
      if l:link['destination'] !=# l:link['index']
        call link#body#ReplaceLink(l:body_line_content, l:link['full_link'],
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
    call link#reference#Add(l:ref_link['index'], l:ref_link['url'], l:line_nr)

  let l:ref_section_start = l:heading_line_nr + 2
  endfor

  let l:orig_ref_len = l:ref_section_end - l:ref_section_start + 1
  let l:new_ref_len = link#label#GetLast('line_nr') - l:ref_section_start + 1
  echom 'Finished reformatting reference links and reference section'
  echom 'Number of lines in reference section -- Before: ' .. l:orig_ref_len .. ' -- After: ' .. l:new_ref_len

  call link#lifecycle#Finalize(l:orig_view, l:orig_fold_option)
endfunction
