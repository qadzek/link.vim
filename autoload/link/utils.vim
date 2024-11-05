" Return boolean
function! link#utils#IsFiletypeMarkdown() abort
  " NOTE This assumes that Vimwiki uses Markdown syntax
  return &filetype =~# 'markdown' || &filetype =~# 'vimwiki'
endfunction

" Return 'Darwin', 'Linux' or 'Windows'
function! link#utils#GetOperatingSystem() abort
  " https://vi.stackexchange.com/a/2577/50213
  if has('win64') || has('win32') || has('win16')
    return 'Windows'
  else
    return substitute(system('uname'), '\n', '', '')
  endif
endfunction

" Fix Vimwiki bug where newly created reference links don't work instantly
function! link#utils#VimwikiRefLinksRefresh() abort
  " See https://github.com/vimwiki/vimwiki/issues/1005 and
  " https://github.com/vimwiki/vimwiki/issues/1351

  if &filetype !~# 'vimwiki'
    return
  endif

  call vimwiki#markdown_base#scan_reflinks()
endfunction

