if exists('g:loaded_linkvim') | finish | endif
let g:loaded_linkvim = 1

let g:linkvim#defaults = {
  \ 'heading_markdown': '## Links',
  \ 'heading_other': 'Links:',
  \ 'start_index': 0,
  \ 'missing_marker': '???',
\ }
let g:linkvim#protocols = ['wiki', 'http', 'https', 'ftp', 'ftps',
  \ 'mailto', 'file', 'news', 'telnet', 'ssh', 'sftp' ]

let g:linkvim_cache_root = ''
let g:linkvim_link_default_schemes = {}
let g:linkvim_filetypes = ['md', 'wiki']

if has('win32') || has('win32unix')
  let s:default_viewer = 'start'
elseif has('mac') || has('ios') || substitute(system('uname'), '\n', '', '') =~# 'Darwin'
  let s:default_viewer = 'open'
else
  let s:default_viewer = 'xdg-open'
endif
call linkvim#init#option('linkvim_viewer', {
      \ '_' : s:default_viewer,
      \ 'md' : ':edit',
      \ 'wiki' : ':edit',
      \})

call linkvim#init#option('linkvim_link_default_schemes', {
      \ 'wiki': { 'wiki': 'wiki', 'adoc': 'adoc' },
      \ 'md': 'md',
      \ 'md_fig': 'file',
      \ 'org': 'wiki',
      \ 'adoc_xref_inline': 'adoc',
      \ 'adoc_xref_bracket': 'adoc',
      \ 'adoc_link': 'file',
      \ 'ref_target': '',
      \ 'date': 'journal',
      \ 'cite': 'zot',
      \})

" Initialize global commands
command! -bar        LinkShow                call linkvim#link#show()
command! -bar        LinkPrev                call linkvim#nav#prev_link()
command! -bar        LinkNext                call linkvim#nav#next_link()
command! -bar        LinkJump                call linkvim#x#jump#jump()
command! -bar        LinkPeek                call linkvim#x#peek#peek()
command! -bar        LinkOpen                call linkvim#x#open#open()
command! -bar        LinkReformat            call linkvim#x#reformat#reformat()
command! -bar        LinkConvertSingle       let b:init_view = winsaveview() | :call linkvim#x#convert#convert('single')
command! -bar        LinkConvertSingleInsert let b:init_view = winsaveview() | :call linkvim#x#convert#convert('single', 'insert')
command! -bar -range LinkConvertRange        let b:init_view = winsaveview() | :<line1>,<line2>call linkvim#x#convert#convert()
command! -bar        LinkConvertAll          :% LinkConvertRange

" Initialize mappings
nnoremap <silent> <plug>(LinkVim-Show)                     :LinkShow<cr>
nnoremap <silent> <plug>(LinkVim-Prev)                     :LinkPrev<cr>
nnoremap <silent> <plug>(LinkVim-Next)                     :LinkNext<cr>
nnoremap <silent> <plug>(LinkVim-Jump)                     :LinkJump<cr>
nnoremap <silent> <plug>(LinkVim-Peek)                     :LinkPeek<cr>
nnoremap <silent> <plug>(LinkVim-Open)                     :LinkOpen<cr>
nnoremap <silent> <plug>(LinkVim-Reformat)                 :LinkReformat<cr>
nnoremap <silent> <plug>(LinkVim-ConvertSingle)            :LinkConvertSingle<cr>
inoremap <silent> <plug>(LinkVim-ConvertSingleInsert) <cmd>:LinkConvertSingleInsert<cr>
vnoremap <silent> <plug>(LinkVim-ConvertRange)             :LinkConvertRange<cr>
nnoremap <silent> <plug>(LinkVim-ConvertAll)               :LinkConvertAll<cr>

" Apply default mappings, if user has set variable (before loading plugin)
if get(g:, 'link_use_default_mappings', 0)
  nnoremap <LocalLeader>s <plug>(LinkVim-Show)
  nnoremap <C-p>          <plug>(LinkVim-Prev)
  nnoremap <C-n>          <plug>(LinkVim-Next)
  nnoremap <LocalLeader>j <plug>(LinkVim-Jump)
  nnoremap <LocalLeader>p <plug>(LinkVim-Peek)
  nnoremap <LocalLeader>o <plug>(LinkVim-Open)
  nnoremap <LocalLeader>r <plug>(LinkVim-Reformat)
  nnoremap <LocalLeader>c <Plug>(LinkVim-ConvertSingle)
  inoremap <C-g>c         <Plug>(LinkVim-ConvertSingleInsert)
  vnoremap <LocalLeader>c <plug>(LinkVim-ConvertRange)
  nnoremap <LocalLeader>a <plug>(LinkVim-ConvertAll)
endif
