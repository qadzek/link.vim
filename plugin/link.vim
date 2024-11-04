" Convert ---------------------------------------------------------- {{{1

" Boilerplate; see :help use-cpo-save
if exists('g:loaded_link')
  finish
endif
let g:loaded_link = 1

let s:save_cpo = &cpoptions
set cpoptions&vim

" By default, the plugin will be enabled for the following filetypes, if the
" user hasn't set a special variable in their vimrc
let s:default_enabled_filetypes = [ 'markdown', 'vimwiki', 'mail', 'text' ]

if exists('g:link_enabled_filetypes')
  let s:enabled_filetypes = g:link_enabled_filetypes
else
  let s:enabled_filetypes = s:default_enabled_filetypes
endif

augroup link_vim
  autocmd!
  execute 'autocmd FileType ' .. join(s:enabled_filetypes, ',') ..
        \ ' call LinkEnable()'
augroup end

function! LinkEnable() abort

  " Store view of the current window (e.g. cursor position) before range
  " function moves it
  command! -buffer -bar -range LinkConvertRange
        \ let b:init_view = winsaveview() |
        \ :<line1>,<line2>call link#Convert()
  command! -buffer -bar        LinkConvertAll            :% LinkConvertRange
  command! -buffer -bar        LinkConvertSingle
        \ let b:init_view = winsaveview() |
        \ :call link#Convert('single-link')
  command! -buffer -bar        LinkConvertSingleInsert
        \ let b:init_view = winsaveview() |
        \ :call link#Convert('single-link', 'insert')
  command! -buffer -bar        LinkJump                  :call link#Jump('jump')
  command! -buffer -bar        LinkOpen                  :call link#Jump('open')
  command! -buffer -bar        LinkPeek                  :call link#Jump('peek')
  command! -buffer -bar        LinkReformat              :call link#Reformat()
  
  nnoremap <buffer> <silent> <Plug>(LinkVim-ConvertSingle)            :LinkConvertSingle<CR>
  inoremap <buffer> <silent> <Plug>(LinkVim-ConvertSingleInsert) <Esc>:LinkConvertSingleInsert<CR>
  vnoremap <buffer> <silent> <Plug>(LinkVim-ConvertRange)             :LinkConvertRange<CR>
  nnoremap <buffer> <silent> <Plug>(LinkVim-ConvertAll)               :LinkConvertAll<CR>
  nnoremap <buffer> <silent> <Plug>(LinkVim-Jump)                     :LinkJump<CR>
  nnoremap <buffer> <silent> <Plug>(LinkVim-Open)                     :LinkOpen<CR>
  nnoremap <buffer> <silent> <Plug>(LinkVim-Peek)                     :LinkPeek<CR>
  nnoremap <buffer> <silent> <Plug>(LinkVim-Reformat)                 :LinkReformat<CR>

  " By default, no mappings exist. The user can try the suggested key bindings
  " by setting a special variable in their vimrc
  if exists('g:link_use_default_mappings') && g:link_use_default_mappings
    nmap <LocalLeader>c       <Plug>(LinkVim-ConvertSingle)
    imap <C-g>c               <Plug>(LinkVim-ConvertSingleInsert)
    vmap <LocalLeader>c       <Plug>(LinkVim-ConvertRange)
    nmap <LocalLeader>a       <Plug>(LinkVim-ConvertAll)
    nmap <LocalLeader>j       <Plug>(LinkVim-Jump)
    nmap <LocalLeader>o       <Plug>(LinkVim-Open)
    nmap <LocalLeader>p       <Plug>(LinkVim-Peek)
    nmap <LocalLeader>r       <Plug>(LinkVim-Reformat)
  endif
endfunction

let &cpoptions = s:save_cpo
unlet s:save_cpo
