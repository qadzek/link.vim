function! linkvim#url#handlers#adoc(resolved, edit_cmd) abort
  let l:do_edit = resolve(a:resolved.path) !=# resolve(expand('%:p'))

  call linkvim#url#utils#go_to_file(
        \ a:resolved.path, a:edit_cmd, a:resolved.stripped, l:do_edit)
  call linkvim#url#utils#go_to_anchor_adoc(a:resolved.anchor, l:do_edit)
  call linkvim#url#utils#focus(l:do_edit)

  if exists('#User#WikiLinkFollowed')
    doautocmd <nomodeline> User WikiLinkFollowed
  endif
endfunction

function! linkvim#url#handlers#doi(resolved, ...) abort
  let a:resolved.url = 'http://dx.doi.org/' .. a:resolved.stripped
  let a:resolved.scheme = 'http'
  let a:resolved.stripped = strpart(a:resolved.url, 5)

  return linkvim#url#handlers#generic(a:resolved)
endfunction

function! linkvim#url#handlers#file(resolved, ...) abort
  let l:cmd = get(g:linkvim_viewer, a:resolved.ext, g:linkvim_viewer._)
  if l:cmd ==# ':edit'
    silent execute 'edit' fnameescape(a:resolved.path)
  else
    call linkvim#jobs#run(
          \ l:cmd .. ' ' .. linkvim#u#shellescape(a:resolved.path) .. '&')
  endif
endfunction

function! linkvim#url#handlers#generic(resolved, ...) abort
  " Print URL, to make testing possible.
  if exists('g:vader_file') && !exists('$TEST_OPEN_IN_BROWSER') " MODIFIED
    echom a:resolved.url
    return
  endif

  try
    if get(g:, 'loaded_netrwPlugin', '') >=? 'v182'
      call netrw#BrowseX(a:resolved.url)
    else
      call netrw#BrowseX(a:resolved.url, 0)
    endif
  catch
    call linkvim#jobs#run(
          \ g:linkvim_viewer._ .. ' ' .. linkvim#u#shellescape(a:resolved.url) .. '&')
  endtry
endfunction

function! linkvim#url#handlers#man(resolved, ...) abort
  execute 'edit' fnameescape(a:resolved.path)
endfunction

function! linkvim#url#handlers#refbad(resolved, ...) abort
  normal! m'
  call cursor(a:resolved.lnum, 1)
endfunction

function! linkvim#url#handlers#vimdoc(resolved, edit_cmd) abort
  try
    if a:edit_cmd ==# 'edit'
      execute 'help' a:resolved.stripped
      execute winnr('#') 'hide'
    elseif a:edit_cmd ==# 'tabedit'
      execute 'tab help' a:resolved.stripped
    elseif a:edit_cmd =~# '^vert'
      execute 'vert help' a:resolved.stripped
    else
      execute 'help' a:resolved.stripped
    endif
  catch
    call linkvim#log#warn("can't find vimdoc page: " .. a:resolved.stripped)
  endtry
endfunction

function! linkvim#url#handlers#wiki(resolved, edit_cmd) abort
  let l:do_edit = resolve(a:resolved.path) !=# resolve(expand('%:p'))

  call linkvim#url#utils#go_to_file(
        \ a:resolved.path, a:edit_cmd, a:resolved.stripped, l:do_edit)
  call linkvim#url#utils#go_to_anchor_wiki(a:resolved.anchor, l:do_edit)
  call linkvim#url#utils#focus(l:do_edit)

  if exists('#User#WikiLinkFollowed')
    doautocmd <nomodeline> User WikiLinkFollowed
  endif
endfunction

function! linkvim#url#handlers#md(resolved, edit_cmd) abort
  return linkvim#url#handlers#wiki(a:resolved, a:edit_cmd)
endfunction

function! linkvim#url#handlers#zot(resolved, ...) abort
  let l:files = linkvim#zotero#search(a:resolved.stripped)

  if len(l:files) > 0
    let l:choice = linkvim#ui#select(
          \ ['Follow in Zotero: ' .. a:resolved.stripped]
          \   + map(copy(l:files), 's:menu_open_pdf(v:val)'),
          \ {
          \   'prompt': 'Please select desired action:',
          \   'return': 'index',
          \ })
    if l:choice < 0
      return linkvim#log#warn('Aborted')
    endif

    if l:choice > 0
      let l:file = l:files[l:choice-1]
      let l:viewer = get(g:linkvim_viewer, 'pdf', g:linkvim_viewer._)
      call linkvim#jobs#start(l:viewer .. ' ' .. linkvim#u#shellescape(l:file))
      return
    endif
  endif

  " Fall back to zotero://select/items/bbt:citekey
  call linkvim#jobs#run(printf('%s zotero://select/items/bbt:%s &',
        \ g:linkvim_viewer['_'], a:resolved.stripped))
endfunction

function! linkvim#url#handlers#bdsk(resolved, ...) abort
  let l:encoded_url = stridx(a:resolved.stripped, '%') < 0
        \ ? linkvim#url#utils#url_encode(a:resolved.stripped)
        \ : a:resolved.stripped

  let a:resolved.url = 'x-bdsk://' .. l:encoded_url
  let a:resolved.scheme = 'x-bdsk'

  return linkvim#url#handlers#generic(a:resolved)
endfunction


function! s:menu_open_pdf(val) abort
  let l:filename = fnamemodify(a:val, ':t')

  let l:strlen = strchars(l:filename)
  let l:width = winwidth(0) - 14
  if l:strlen > l:width
    let l:pre = strcharpart(l:filename, 0, l:width/2 - 3)
    let l:post = strcharpart(l:filename, l:strlen - l:width/2 + 3)
    let l:filename = l:pre .. ' ... ' .. l:post
  endif

  return 'Open PDF: ' .. l:filename
endfunction
