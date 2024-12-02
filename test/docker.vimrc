" Settings --------------------------------------------------------- {{{1

filetype plugin indent on
syntax enable

" Disable the pager prompt `-- More --`; see `:help pager` and `:help more`
set nomore

" Key bindings ----------------------------------------------------- {{{1

" Exit tests
nnoremap Q      :qa!<CR>
inoremap Q <Esc>:qa!<CR>

" Download Plug ---------------------------------------------------- {{{1

" https://github.com/junegunn/vim-plug/wiki/tips
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Plug start ------------------------------------------------------- {{{1

" Custom plugin directory, same for Vim and Neovim
silent! call plug#begin('~/plugged')

" Activate plugins ------------------------------------------------- {{{1

Plug 'junegunn/vader.vim'

" Latest release
" Plug 'qadzek/link.vim'

" Modified plugin
Plug '~/plugged/link.vim'

" Plug end --------------------------------------------------------- {{{1

call plug#end()
