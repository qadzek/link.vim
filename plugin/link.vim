" Boilerplate; see `:help use-cpo-save`
if exists('g:loaded_link') | finish | endif
let g:loaded_link = 1
let s:save_compatible_options = &cpoptions
set cpoptions&vim

" User can specify for which filetypes the plugin should be enabled
let s:fts = get(g:, 'link_enabled_filetypes', g:link#globals#defaults['filetypes'])
let s:fts = join(s:fts, ',')

" Enable plugin on desired filetypes
augroup link_vim_filetypes
  autocmd!
  execute 'autocmd FileType ' .. s:fts .. ' call LinkEnable()'
augroup end

function! LinkEnable() abort
  " Define commands
  " `init_view` stores view of current window (cursor position etc.) before
  " range function moves cursor to first line of range
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
  command! -buffer -bar        LinkJump               :call link#Connect('jump')
  command! -buffer -bar        LinkOpen               :call link#Connect('open')
  command! -buffer -bar        LinkPeek               :call link#Connect('peek')
  command! -buffer -bar        LinkReformat           :call link#Reformat()

  " Initialize mappings
  nnoremap <buffer> <silent> <Plug>(LinkVim-ConvertSingle) :LinkConvertSingle<CR>
  inoremap <buffer> <silent> <Plug>(LinkVim-ConvertSingleInsert) <Esc>:LinkConvertSingleInsert<CR>
  vnoremap <buffer> <silent> <Plug>(LinkVim-ConvertRange)  :LinkConvertRange<CR>
  nnoremap <buffer> <silent> <Plug>(LinkVim-ConvertAll)    :LinkConvertAll<CR>
  nnoremap <buffer> <silent> <Plug>(LinkVim-Jump)          :LinkJump<CR>
  nnoremap <buffer> <silent> <Plug>(LinkVim-Open)          :LinkOpen<CR>
  nnoremap <buffer> <silent> <Plug>(LinkVim-Peek)          :LinkPeek<CR>
  nnoremap <buffer> <silent> <Plug>(LinkVim-Reformat)      :LinkReformat<CR>

  " Apply default mappings, if user has set special variable in vimrc
  if get(g:, 'link_use_default_mappings', 0) 
    nmap <LocalLeader>c   <Plug>(LinkVim-ConvertSingle)
    imap <C-g>c           <Plug>(LinkVim-ConvertSingleInsert)
    vmap <LocalLeader>c   <Plug>(LinkVim-ConvertRange)
    nmap <LocalLeader>a   <Plug>(LinkVim-ConvertAll)
    nmap <LocalLeader>j   <Plug>(LinkVim-Jump)
    nmap <LocalLeader>o   <Plug>(LinkVim-Open)
    nmap <LocalLeader>p   <Plug>(LinkVim-Peek)
    nmap <LocalLeader>r   <Plug>(LinkVim-Reformat)
  endif
endfunction

let &cpoptions = s:save_compatible_options
unlet s:save_compatible_options
