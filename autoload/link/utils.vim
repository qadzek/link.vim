" Display message in Vim's command-line
function! link#utils#DisplayMsg(msg) abort
  echohl WarningMsg

  echomsg a:msg

  echohl None
endfunction

" Display error in Vim's command-line
function! link#utils#DisplayError(error_key, suffix = '') abort
  echohl ErrorMsg

  let l:msg = g:link#globals#errors[a:error_key]
  if len(a:suffix) | let l:msg ..= ' ' .. a:suffix | endif

  echomsg l:msg

  echohl None
endfunction

" Move cursor to first character of first line or last char of last line
function! link#utils#MoveCursorTo(destination) abort
  if a:destination ==# 'start'
    let l:row = 1
    let l:col = 1

  elseif a:destination ==# 'end'
    let l:row = line('$')
    let l:col = col( [ l:row, '$' ] ) " Last char of last line

  else
    throw 'Invalid destination'
  endif

  call cursor(l:row, l:col)
endfunction

" Return boolean indicating if filetype includes Markdown or Vimwiki
function! link#utils#IsFiletypeMarkdown() abort
  " NOTE This assumes that Vimwiki uses Markdown syntax
  return &filetype =~# 'markdown' || &filetype =~# 'vimwiki'
endfunction

" Return operating system: 'Darwin', 'Linux' or 'Windows'
function! link#utils#GetOperatingSystem() abort
  " https://vi.stackexchange.com/a/2577/50213
  if has('win64') || has('win32') || has('win16')
    return 'Windows'
  else
    return substitute(system('uname'), '\n', '', '')
  endif
endfunction

" Return command to open URL in default application, based on operating system
function! link#utils#GetOpenCommand(os) abort
  if a:os ==? 'Darwin'
    return 'open'
  elseif a:os ==? 'Linux'
    return 'xdg-open'
  elseif a:os ==? 'Windows'
    return 'start ""'
  else
    throw 'Unknown operating system'
  endif
endfunction

" Return boolean indicating if only URLs should be converted, not links to
" internal wiki pages
function! link#utils#ConvertUrlsOnly() abort
  if exists('b:link_disable_internal_links')
    return b:link_disable_internal_links
  endif

  if exists('g:link_disable_internal_links')
    return g:link_disable_internal_links
  endif

  return 0
endfunction
