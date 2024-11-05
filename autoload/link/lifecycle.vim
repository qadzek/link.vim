" Disable folding
" Return list of original view, line number, column number and folding option
function! link#lifecycle#Initialize() abort
  let l:orig_view = winsaveview()
  let l:line_nr = l:orig_view['lnum']
  let l:col_nr = l:orig_view['col'] + 1

  let l:orig_fold_option = &foldenable
  setlocal nofoldenable

  return [ l:orig_view, l:line_nr, l:col_nr, l:orig_fold_option ]
endfunction

" Restore original view and folding option
function! link#lifecycle#Finalize(orig_view, orig_fold_option) abort
  call winrestview(a:orig_view)

  let &l:foldenable = a:orig_fold_option

" TODO
  call link#utils#VimwikiRefLinksRefresh()
endfunction

