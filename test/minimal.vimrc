" Create a testing environment isolated from existing plugins and settings on
" your workstation.

" Helper functions ------------------------------------------------- {{{1

" Check if running inside Docker container.
function! s:is_docker()
  return filereadable('/.dockerenv')
endfunction

" Add plugin to runtimepath and warn if not found.
function! s:load_plugin(path)
  let l:exp_path = expand(a:path)

  if !isdirectory(l:exp_path)
    throw 'Could not find the plugin: ' .. a:path
  endif

  let &runtimepath .= ',' .. l:exp_path
endfunction

" Settings --------------------------------------------------------- {{{1

filetype plugin indent on
syntax enable

" Disable the pager prompt `-- More --`; see `:help pager` and `:help more`.
set nomore

" Load plugins ----------------------------------------------------- {{{1

" Load Vader test framework.
if s:is_docker()
  call s:load_plugin('/home/vimmer/vader.vim')
else
  " Edit this path, depening on your plugin manager.
  call s:load_plugin('~/.local/share/nvim/lazy/vader.vim')
endif

" Load link.vim.
if s:is_docker()
  call s:load_plugin('/home/vimmer/link.vim')
else
  " Edit this path, depening on your plugin manager.
  call s:load_plugin('~/.local/share/nvim/lazy/link.vim')
endif

" Key bindings ----------------------------------------------------- {{{1

" Exit tests
nnoremap Q      :quitall!<CR>
inoremap Q <Cmd>:quitall!<CR>
