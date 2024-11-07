" Return the start index for the first label, buffer-local or global, or default
function! link#label#GetStartIndex() abort
  if exists('b:link_start_index') | return b:link_start_index | endif
  if exists('g:link_start_index') | return g:link_start_index | endif
  return g:link#globals#defaults['start_index']
endfunction

" Return list of line number and label index, for first or last label in
" reference section
" Position : `first` or `last`
function! link#label#GetInfo(position) abort
  let l:save_cursor = getcurpos()

  let l:search_flags = 'cW'

  if a:position ==# 'first'
    call link#utils#MoveCursorTo('start')

  elseif a:position ==# 'last'
    call link#utils#MoveCursorTo('end')
    let l:search_flags ..= 'b'

  else
    throw 'Invalid position'
  endif

  let l:regex = g:link#globals#re['ref_def']

  " Move cursor to search result
  let l:match_line_nr = search(l:regex, l:search_flags)

  " Return -1 when no link reference definition is found
  if l:match_line_nr == 0
    return [ -1, -1 ]
  endif

  " Get number between square brackets
  let l:line_content = getline(l:match_line_nr)
  let l:match = matchstr(l:line_content, l:regex)
  let l:label_idx = str2nr(l:match)

  call setpos('.', l:save_cursor)

  return [ l:match_line_nr, l:label_idx ]
endfunction
