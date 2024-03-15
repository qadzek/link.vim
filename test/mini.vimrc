" Minimal vimrc, to create a testing environment isolated from plugins and
" settings

filetype off

""" Load Vader test framework
" Location can vary
" E.g. Vundle: ~/.vim/bundle/vader.vim
set runtimepath+=~/.vim/plugged/vader.vim

""" Load plugin
" Location can vary, depending on Vim/Neovim/plugin manager
" E.g. Vim:    ~/.vim/plugged/vim-md-link
" E.g. Neovim: ~/.local/share/nvim/vim-md-link
set runtimepath+=~/.vim/plugged/vim-md-link

filetype plugin indent on
syntax enable

" Exit tests
nnoremap Q :qa!<CR>
