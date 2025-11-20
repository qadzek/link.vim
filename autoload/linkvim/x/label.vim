" Return the start index for the first label. By default, this is `0`, but the
" user can set it to e.g. `1`.
function! linkvim#x#label#get_start_index() abort
  return linkvim#x#u#setting_with_default(
    \ 'link_start_index',
    \ g:linkvim#defaults['start_index']
    \ )
endfunction

" Return line number and label index, for first and last label in reference
" section.
function! linkvim#x#label#get_info(...) abort
  let l:ref_target_links = a:0 == 0 ? linkvim#x#u#get_links('ref_target') : a:1

  if empty(l:ref_target_links)
    return {
      \ 'first': { 'lnum': -1, 'id': -1 },
      \ 'last':  { 'lnum': -1, 'id': -1 },
      \ }
  endif

  let l:first_link =  l:ref_target_links[0]
  let l:last_link = l:ref_target_links[-1]

  return {
    \ 'first': {
      \ 'lnum': l:first_link.pos_start[0],
      \ 'id': str2nr(l:first_link.text),
      \ },
    \ 'last': {
      \ 'lnum': l:last_link.pos_start[0],
      \ 'id': str2nr(l:last_link.text),
      \ },
    \ }
endfunction
