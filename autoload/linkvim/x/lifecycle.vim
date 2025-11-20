" Disable folding and return initial view and folding setting.
function! linkvim#x#lifecycle#initialize() abort
  let l:fold_setting = &foldenable
  setlocal nofoldenable

  let l:view = winsaveview()
  let l:lnum = l:view['lnum']
  let l:col = l:view['col'] + 1
  let l:line_cont = getline(l:lnum)

  return {
        \ 'view': l:view,
        \ 'lnum': l:lnum,
        \ 'col': l:col,
        \ 'fold_setting': l:fold_setting,
        \ 'line_cont': l:line_cont,
        \ 'line_len': len(l:line_cont),
        \ }
endfunction

" Restore initial view and folding setting.
function! linkvim#x#lifecycle#finalize(init_state) abort
  call winrestview(a:init_state.view)

  let &l:foldenable = a:init_state.fold_setting

  call s:vimwiki_ref_links_refresh()
endfunction

" Fix Vimwiki bug where newly created reference links don't work immediately.
" See https://github.com/vimwiki/vimwiki/issues/1005 and
" https://github.com/vimwiki/vimwiki/issues/1351
function! s:vimwiki_ref_links_refresh() abort
  if &filetype !~# 'vimwiki'
    return
  endif

  if !exists('*vimwiki#markdown_base#scan_reflinks')
    return
  endif

  call vimwiki#markdown_base#scan_reflinks()
endfunction
