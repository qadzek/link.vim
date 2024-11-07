" Jump from a reference link in the document body to the corresponding link
" reference definition in the reference section
" Return line number of match, or 0 in case of no match
function! link#jump#ToReferenceSection(orig_line_nr, orig_col_nr, divider_line_nr) abort
  let l:all_links = link#body#ParseLineFor('reference', a:orig_line_nr)
  if len(l:all_links) == 0
    call link#utils#DisplayError('no_reference_link')
    return 0
  endif

  let l:link = link#body#PickClosestLink(l:all_links, a:orig_col_nr)
  let l:label = l:link['destination']

  " Start search at heading
  call cursor(a:divider_line_nr, 1)

  " Move cursor to match
  let l:regex = g:link#globals#re['ref_def_pre'] .. l:label .. g:link#globals#re['ref_def_suf']
  let l:match_line_nr = search(l:regex, 'cW')

  " Put cursor on start of URL
  keepjumps normal! W

  " No match
  if l:match_line_nr == 0
    call link#utils#DisplayError('no_label_ref_section', l:label)
  endif

  return l:match_line_nr
endfunction

" Jump from a link reference definition in the reference section to the
" corresponding reference link in the document body
" Return line number of match, or 0 in case of no match
function! link#jump#ToBody(orig_line_nr, divider_line_nr) abort
  let l:reference_section = link#reference#Parse(a:orig_line_nr, 'one')

  if len(l:reference_section) == 0
    call link#utils#DisplayError('no_ref_def')
    return 0
  endif

  let l:link_reference_definition = l:reference_section[0]
  let l:label_idx = l:link_reference_definition['label']

  " Start search at first line
  call cursor(1, 1)

  " Stop search at heading
  let l:body_line_nr = search('\v\[' .. l:label_idx .. '\]', 'cWe', a:divider_line_nr)

  " No match
  if l:body_line_nr == 0
    call link#utils#DisplayError('no_label_body', l:label_idx)
  endif

  return l:body_line_nr
endfunction

