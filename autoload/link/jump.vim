" Jump from a reference link in the document body [foo][3] to the corresponding
" link reference definition in the reference section [3]: http://bar.com
" Return line number of match, or 0
function! link#jump#ToReferenceSection(orig_line_nr, orig_col_nr, heading_line_nr) abort
  let l:all_links = link#body#ParseLineFor('reference', a:orig_line_nr)
  if len(l:all_links) == 0
    echom g:link#globals#err_msg['no_reference_link']
    return 0
  endif

  let l:link = link#body#PickClosestLink(l:all_links, a:orig_col_nr)
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
    echom g:link#globals#err_msg['no_label_ref_section'] .. l:label
  endif

  " 0 in case of no match
  return l:ref_line_nr
endfunction

" Jump from a link reference definition in the reference section
" [3]: http://bar.com to the corresponding reference link in the document body
" [foo][3]
" Return line number of match, or 0
function! link#jump#ToBody(orig_line_nr, heading_line_nr) abort
  let l:reference_section = link#reference#Parse(a:orig_line_nr, 'one')
  if len(l:reference_section) == 0
    echom g:link#globals#err_msg['no_link_ref_definition']
    return 0
  endif
  let l:link_reference_definition = l:reference_section[0]
  let l:label = l:link_reference_definition['label']

  " Start search at first line
  call cursor(1, 1)
  " Stop search at heading
  let l:body_line_nr = search('\v\[' .. l:label .. '\]', 'cWe', a:heading_line_nr)

  if l:body_line_nr == 0
    echom g:link#globals#err_msg['no_label_body'] .. l:label
  endif

  " 0 in case of no match
  return l:body_line_nr
endfunction

