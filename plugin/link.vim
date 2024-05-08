" Convert ---------------------------------------------------------- {{{1

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

  " Store cursor position before range function moves it
  command! -buffer -bar -range LinkConvertRange
        \ let b:init_cur_pos = getcurpos()[1:2] |
        \ :<line1>,<line2>call link#Convert()

  command! -buffer -bar        LinkConvertAll            :% LinkConvertRange

  command! -buffer -bar        LinkConvertSingle
        \ let b:init_cur_pos = getcurpos()[1:2] |
        \ :call link#Convert('single-link')

  command! -buffer -bar        LinkConvertSingleInsert
        \ let b:init_cur_pos = getcurpos()[1:2] |
        \ :call link#Convert('single-link', 'insert')

  command! -buffer -bar        LinkJump                  :call link#Jump('jump')
  command! -buffer -bar        LinkOpen                  :call link#Jump('open')
  command! -buffer -bar        LinkPeek                  :call link#Jump('peek')

  command! -buffer -bar        LinkReformat              :call link#Reformat()

  " By default, no mappings exist. The user can try the suggested key bindings
  " by setting a special variable in their vimrc
  if exists('g:link_use_default_mappings') && g:link_use_default_mappings
    nnoremap <buffer> <silent> <LocalLeader>c       :LinkConvertSingle<CR>
    inoremap <buffer> <silent> <C-g>c          <Esc>:LinkConvertSingleInsert<CR>
    vnoremap <buffer> <silent> <LocalLeader>c       :LinkConvertRange<CR>
    nnoremap <buffer> <silent> <LocalLeader>a       :LinkConvertAll<CR>
    nnoremap <buffer> <silent> <LocalLeader>j       :LinkJump<CR>
    nnoremap <buffer> <silent> <LocalLeader>o       :LinkOpen<CR>
    nnoremap <buffer> <silent> <LocalLeader>p       :LinkPeek<CR>
    nnoremap <buffer> <silent> <LocalLeader>r       :LinkReformat<CR>
  endif
endfunction
