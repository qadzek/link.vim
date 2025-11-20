function! linkvim#jobs#run(cmd, ...) abort
  " Run an external process.
  "
  " The optional argument is a dictionary of options. Each option is parsed in
  " the code below.
  "
  " Return: Nothing.
  let l:opts = a:0 > 0 ? a:1 : {}

  call linkvim#paths#pushd(get(l:opts, 'cwd', ''))
  call linkvim#jobs#{s:backend}#run(a:cmd)
  call linkvim#paths#popd()
endfunction

let s:backend = has('nvim') ? 'neovim' : 'vim'
