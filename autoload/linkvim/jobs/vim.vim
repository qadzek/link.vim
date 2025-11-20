function! linkvim#jobs#vim#run(cmd) abort
  call s:vim_{s:os}_run(a:cmd)
endfunction

let s:os = has('win32') ? 'win' : 'unix'

" vint: next-line -ProhibitUnusedVariable
function! s:vim_unix_run(cmd) abort
  silent! call system(a:cmd)
endfunction

" vint: next-line -ProhibitUnusedVariable
function! s:vim_win_run(cmd) abort
  let s:saveshell = [
        \ &shell,
        \ &shellcmdflag,
        \ &shellquote,
        \ &shellxquote,
        \ &shellredir,
        \ &shellslash
        \]
  set shell& shellcmdflag& shellquote& shellxquote& shellredir& shellslash&

  silent! call system('cmd /s /c "' . a:cmd . '"')

  let [   &shell,
        \ &shellcmdflag,
        \ &shellquote,
        \ &shellxquote,
        \ &shellredir,
        \ &shellslash] = s:saveshell
endfunction
