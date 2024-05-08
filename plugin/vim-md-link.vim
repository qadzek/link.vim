" Convert ---------------------------------------------------------- {{{1

" By default, the plugin will be enabled for the following filetypes, if the
" user hasn't set a special variable in their vimrc
let s:default_enabled_filetypes = [ 'markdown', 'vimwiki', 'mail', 'text' ]

if exists('g:md_link_enabled_filetypes')
  let s:enabled_filetypes = g:md_link_enabled_filetypes
else
  let s:enabled_filetypes = s:default_enabled_filetypes
endif

augroup vim_md_link
  autocmd!
  execute 'autocmd FileType ' .. join(s:enabled_filetypes, ',') ..
        \ ' call MdLinkEnable()'
augroup end

function! MdLinkEnable() abort

  " Store cursor position before range function moves it
  command! -buffer -bar -range MdLinkConvertRange
        \ let b:init_cur_pos = getcurpos()[1:2] |
        \ :<line1>,<line2>call mdlink#Convert()

  command! -buffer -bar        MdLinkConvertAll        :% MdLinkConvertRange

  command! -buffer -bar        MdLinkConvertSingle
        \ let b:init_cur_pos = getcurpos()[1:2] |
        \ :call mdlink#Convert('single-link')

  command! -buffer -bar        MdLinkConvertSingleInsert
        \ let b:init_cur_pos = getcurpos()[1:2] |
        \ :call mdlink#Convert('single-link', 'insert')

  command! -buffer -bar        MdLinkJump              :call mdlink#Jump('jump')
  command! -buffer -bar        MdLinkOpen              :call mdlink#Jump('open')
  command! -buffer -bar        MdLinkPeek              :call mdlink#Jump('peek')

  command! -buffer -bar        MdLinkReformat          :call mdlink#Reformat()

  " By default, no mappings exist. The user can try the suggested key bindings
  " by setting a special variable in their vimrc
  if exists('g:md_link_use_default_mappings') && g:md_link_use_default_mappings
    nnoremap <buffer> <silent> <LocalLeader>c      :MdLinkConvertSingle<CR>
    inoremap <buffer> <silent> <C-g>c         <Esc>:MdLinkConvertSingleInsert<CR>
    vnoremap <buffer> <silent> <LocalLeader>c      :MdLinkConvertRange<CR>
    nnoremap <buffer> <silent> <LocalLeader>a      :MdLinkConvertAll<CR>
    nnoremap <buffer> <silent> <LocalLeader>j      :MdLinkJump<CR>
    nnoremap <buffer> <silent> <LocalLeader>o      :MdLinkOpen<CR>
    nnoremap <buffer> <silent> <LocalLeader>p      :MdLinkPeek<CR>
    nnoremap <buffer> <silent> <LocalLeader>r      :MdLinkReformat<CR>
  endif
endfunction
