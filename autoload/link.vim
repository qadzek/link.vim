" Convert inline links to reference links within a range
" Type : `multiple-links` or `single-link`
" Mode : `normal` or `insert`
function! link#Convert(type = 'multiple-links', mode = 'normal') abort range
  let [l:orig_view, l:orig_line_nr, l:orig_col_nr, l:orig_fold_option] =
    \ link#lifecycle#Initialize()

  " Use cursor position before range function moves cursor to first line of
  " range: https://vi.stackexchange.com/questions/6036/
  if exists('b:init_view')
    let l:orig_view = b:init_view
    unlet b:init_view
  endif

  let [ l:first_label_line_nr, @_] = link#label#GetInfo('first')
  let [ l:last_label_line_nr, l:last_label_idx ] = link#label#GetInfo('last')

  let l:heading_text = link#heading#GetText()
  let l:heading_is_empty = link#heading#IsEmpty(l:heading_text)
  let l:heading_is_needed = link#heading#IsNeeded(l:heading_is_empty, l:heading_text)

  " No reference section present
  if l:first_label_line_nr == -1
    call link#reference#PositionSection()
    let l:divider_line_nr = line('.')
    let l:last_label_line_nr = line('.')
    let l:range_end_line_nr = a:lastline
    let l:new_label_idx = link#label#GetStartIndex()
    let l:first_ref_added = 0

  " Reference section present
  else
    let l:divider_line_nr = l:first_label_line_nr - 1
    let l:range_end_line_nr = link#body#LimitRange(l:divider_line_nr, a:lastline)
    let l:new_label_idx = l:last_label_idx + 1
    let l:first_ref_added = 1
  endif

  let l:conversion_counter = 0

  " Loop over all lines within the range
  for l:cur_line_nr in range(a:firstline, l:range_end_line_nr)

    " Necessary if reference section is positioned
    if l:cur_line_nr > l:divider_line_nr
      break
    endif

    if link#body#SkipLine(l:cur_line_nr)
      continue
    endif

    let l:all_links_on_line = link#body#ParseLineFor('inline', l:cur_line_nr)

    " Display error when trying to convert a single link but there is none
    if a:type ==# 'single-link' && len(l:all_links_on_line) == 0
      call link#utils#DisplayError('no_inline_link')
      call link#lifecycle#Finalize(l:orig_view, l:orig_fold_option)
      return
    endif

    " Limit list of links to one link when converting a single inline link
    if a:type ==# 'single-link'
      let l:all_links_on_line = [ link#body#PickClosestLink(l:all_links_on_line, l:orig_col_nr) ]
    endif

    " Loop over all inline links on current line
    for l:link in l:all_links_on_line

      " In case of an empty heading, add a blank line
      if l:first_ref_added == 0 && l:heading_is_empty
        call append( line('.'), '')
        let l:last_label_line_nr += 1
        let l:first_ref_added = 1
      endif

      " Add a (non-empty) heading
      if l:heading_is_needed
        call link#heading#Add(l:heading_text, l:divider_line_nr)
        let l:last_label_line_nr += 3 " Three lines were added
        let l:heading_is_needed = 0
      endif

      let l:cur_line_content = getline(l:cur_line_nr)

      call link#body#ReplaceLink(l:cur_line_content, l:link['full_link'],
            \ l:link['link_text'], l:new_label_idx, l:cur_line_nr)

      call link#reference#Add(l:new_label_idx, l:link['destination'],
            \ l:last_label_line_nr)

      let l:conversion_counter += 1
      let l:last_label_line_nr += 1
      let l:new_label_idx += 1
    endfor " End looping over all links on current line
  endfor " End looping over all lines

  call link#lifecycle#Finalize(l:orig_view, l:orig_fold_option)

  " Display how many links were converted
  if a:type !=# 'single-link'
    call link#utils#DisplayMsg(l:conversion_counter .. ' link(s) were converted')
  endif

  " Move cursor when function is called from Insert mode, so user can continue
  " typing after the converted link
  if a:type ==# 'single-link' && a:mode ==# 'insert'
    " Move to end of reference link: first to start, then to 1st/2nd `]`
    call cursor(l:orig_line_nr, l:link['col_start'])
    if link#utils#IsFiletypeMarkdown()
      keepjumps normal! 2f]
    else
      keepjumps normal! f]
    endif

    " Determine if link is at the very end of the line
    let l:orig_line_len = len(l:cur_line_content)
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

" Connect a reference link and the corresponding link reference definition and
" perform some action
" Action : `jump`, `open` or `peek`
function! link#Connect(action) abort
  let [l:orig_view, l:orig_line_nr, l:orig_col_nr, l:orig_fold_option] =
        \ link#lifecycle#Initialize()

  let [ l:first_label_line_nr, @_] = link#label#GetInfo('first')
  " No reference section present
  if l:first_label_line_nr == -1
    call link#utils#DisplayError('no_ref_section')
    call link#lifecycle#Finalize(l:orig_view, l:orig_fold_option)
    return
  endif

  let l:divider_line_nr = l:first_label_line_nr - 1

  " No opening/peeking from reference section
  if (a:action ==# 'open' || a:action ==# 'peek') && l:orig_line_nr >= l:divider_line_nr
    call link#utils#DisplayError('not_from_ref')
    call link#lifecycle#Finalize(l:orig_view, l:orig_fold_option)
    return
  endif

  " Determine if we should jump to the reference section or to the document body
  if l:orig_line_nr < l:divider_line_nr
    let l:line_nr = link#jump#ToReferenceSection(l:orig_line_nr, l:orig_col_nr, l:divider_line_nr)
  else
    let l:line_nr = link#jump#ToBody(l:orig_line_nr, l:divider_line_nr)
  endif

  " 0 gets returned if the jump failed
  if l:line_nr == 0
    call link#lifecycle#Finalize(l:orig_view, l:orig_fold_option)
    return
  endif

  " Open URL from corresponding link reference definition in browser
  if a:action ==# 'open'
    let l:ref_link = link#reference#Parse(l:line_nr, 'one')[0]
    let l:url = l:ref_link['destination']

    " Add protocol if required
    if l:url =~# '^www' | let l:url = 'https://' .. l:url | endif

    " Not a valid URL
    if l:url !~# '^http'
      call link#utils#DisplayError('no_valid_url', l:url)
      call link#lifecycle#Finalize(l:orig_view, l:orig_fold_option)
      return
    endif

    " When running tests, don't open links in browser, if `-b` flag is set
    if $VADER_OPEN_IN_BROWSER ==# 'false'
      call link#lifecycle#Finalize(l:orig_view, l:orig_fold_option)
      return
    endif

    " Decide which command to use, based on the OS
    let l:operating_system = link#utils#GetOperatingSystem()
    let l:open_cmd = link#utils#GetOpenCommand(l:operating_system)

    " Escape URL, to support URLs containing e.g. a question mark
    let l:esc_url = shellescape(l:url)

    " Open URL in browser; capture command's output and remove trailing newline
    let l:output = substitute( system(l:open_cmd .. ' ' .. l:esc_url), '\n\+$', '', '' )
    if v:shell_error != 0
      call link#utils#DisplayError('open_in_browser_failed', l:output)
    endif

    call link#lifecycle#Finalize(l:orig_view, l:orig_fold_option)
  endif

  " Display corresponding link reference definition
  if a:action ==# 'peek'
    let l:line_content = getline('.')
    call link#utils#DisplayMsg(l:line_content)
    call link#lifecycle#Finalize(l:orig_view, l:orig_fold_option)
  endif
endfunction

" Reformat reference links and reference section: renumber, merge, delete, mark
function! link#Reformat() abort
  let [l:orig_view, @_, @_, l:orig_fold_option] = link#lifecycle#Initialize()

  let [ l:first_label_line_nr, @_] = link#label#GetInfo('first')
  let [ l:last_label_line_nr, @_ ] = link#label#GetInfo('last')
  let l:orig_ref_len = l:last_label_line_nr - l:first_label_line_nr + 1

  " No reference section present
  if l:first_label_line_nr == -1
    call link#utils#DisplayError('no_ref_section')
    call link#lifecycle#Finalize(l:orig_view, l:orig_fold_option)
    return
  endif

  let l:divider_line_nr = l:first_label_line_nr - 1

  let l:ref_section_start = l:first_label_line_nr
  let l:ref_section_end = l:last_label_line_nr
  let l:ref_section = link#reference#Parse(l:ref_section_start, 'all')

  " Nth reference link, counting from start of document body
  let l:index = link#label#GetStartIndex()

  let l:all_ref_links = []

  " Loop over all lines from first line until heading
  for l:body_line_nr in range(1, l:divider_line_nr)
    if link#body#SkipLine(l:body_line_nr)
      continue
    endif

    let l:all_links_on_line = link#body#ParseLineFor('reference', l:body_line_nr)

    " Loop over all links on current line
    for l:link in l:all_links_on_line
      let l:body_line_content = getline(l:body_line_nr)
      let l:link['line_nr'] = l:body_line_nr

      " Find the link reference definition with a corresponding label
      let l:ref_section_copy = deepcopy(l:ref_section)
      let l:corresponding_refs = filter(l:ref_section_copy,
            \ {_, val -> val['label'] ==# l:link['destination']})

      " Corresponding label was not found in reference section, so label will be
      " changed to '???', to mark that it's broken
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

  " Generate new reference section
  for l:idx in range( len(l:all_ref_links) )
    let l:ref_link = l:all_ref_links[l:idx]
    let l:line_nr = l:divider_line_nr + l:idx
    call link#reference#Add(l:ref_link['index'], l:ref_link['url'], l:line_nr)
  endfor

  let [ l:first_label_line_nr, @_] = link#label#GetInfo('first')
  let [ l:last_label_line_nr, @_ ] = link#label#GetInfo('last')
  let l:new_ref_len = l:last_label_line_nr - l:ref_section_start + 1

  call link#utils#DisplayMsg('Finished reformatting reference links and reference section')
  call link#utils#DisplayMsg('Number of lines in reference section -- Before: '
    \ .. l:orig_ref_len .. ' -- After: ' .. l:new_ref_len)

  call link#lifecycle#Finalize(l:orig_view, l:orig_fold_option)
endfunction
