function! linkvim#jobs#neovim#run(cmd) abort
  call s:neovim_{s:os}_run(a:cmd)
endfunction

let s:os = has('win32') ? 'win' : 'unix'

" vint: next-line -ProhibitUnusedVariable
function! s:neovim_unix_run(cmd) abort
  call system(['sh', '-c', a:cmd])
endfunction

" vint: next-line -ProhibitUnusedVariable
function! s:neovim_win_run(cmd) abort
  let s:saveshell = [&shell, &shellcmdflag, &shellslash]
  set shell& shellcmdflag& shellslash&

  call system('cmd /s /c "' . a:cmd . '"')

  let [&shell, &shellcmdflag, &shellslash] = s:saveshell
endfunction
