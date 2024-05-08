" Minimal vimrc: create a testing environment isolated from plugins and settings

" Settings
filetype off
filetype plugin indent on
syntax enable

" Location where plugins are installed, depends on Vim/Neovim/plugin manager
" E.g. when using regular Vim and Vundle: ~/.vim/bundle/
let s:vim_plugins_dir = '~/.vim/plugged/'
let s:neovim_plugins_dir = '~/.local/share/nvim/plugged/'

" Add plugin to runtimepath
function! LoadPlugin(name)
  if has('nvim')
    let s:plugin_path = s:neovim_plugins_dir .. a:name
  else
    let s:plugin_path = s:vim_plugins_dir .. a:name
  endif

  if isdirectory( expand(s:plugin_path) )
    let &runtimepath .= ',' .. expand(s:plugin_path)
  else
    throw 'Could not find the ' .. a:name .. ' plugin. Is it installed?'
  endif
endfunction

" Load Vader test framework
call LoadPlugin('vader.vim')

" Load this plugin
call LoadPlugin('link.vim')

" Exit tests
nnoremap Q :qa!<CR>
