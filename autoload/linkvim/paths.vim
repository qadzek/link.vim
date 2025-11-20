function! linkvim#paths#pushd(path) abort
  if empty(a:path) || getcwd() ==# fnamemodify(a:path, ':p')
    let s:qpath += ['']
  else
    let s:qpath += [getcwd()]
    execute s:cd fnameescape(a:path)
  endif
endfunction

function! linkvim#paths#popd() abort
  let l:path = remove(s:qpath, -1)
  if !empty(l:path)
    execute s:cd fnameescape(l:path)
  endif
endfunction

function! linkvim#paths#join(root, tail) abort
  return linkvim#paths#s(a:root . '/' . a:tail)
endfunction

function! linkvim#paths#s(path) abort
  " Handle shellescape issues and simplify path
  let l:path = exists('+shellslash') && !&shellslash
        \ ? tr(a:path, '/', '\')
        \ : a:path

  return simplify(l:path)
endfunction

function! linkvim#paths#is_abs(path) abort
  return a:path =~# s:re_abs
endfunction

function! linkvim#paths#shorten_relative(path) abort
  " Input: An absolute path
  " Output: Relative path with respect to the wiki root, unless absolute path
  "         is shorter

  let l:relative = linkvim#paths#relative(a:path, linkvim#get_root())
  return strlen(l:relative) < strlen(a:path)
        \ ? l:relative : a:path
endfunction

function! linkvim#paths#relative(path, current) abort
  " Note: This algorithm is based on the one presented by @Offirmo at SO,
  "       http://stackoverflow.com/a/12498485/51634

  let l:target = simplify(substitute(a:path, '\\', '/', 'g'))
  let l:common = simplify(substitute(a:current, '\\', '/', 'g'))

  " This only works on absolute paths
  if !linkvim#paths#is_abs(l:target)
    return substitute(a:path, '^\.\/', '', '')
  endif

  if has('win32')
    let l:target = substitute(l:target, '^\a:', '', '')
    let l:common = substitute(l:common, '^\a:', '', '')
  endif

  if l:common[-1:] ==# '/'
    let l:common = l:common[:-2]
  endif

  let l:tries = 50
  let l:result = ''
  while stridx(l:target, l:common) != 0 && l:tries > 0
    let l:common = fnamemodify(l:common, ':h')
    let l:result = empty(l:result) ? '..' : '../' . l:result
    let l:tries -= 1
  endwhile

  if l:tries == 0 | return a:path | endif

  if l:common ==# '/'
    let l:result .= '/'
  endif

  let l:forward = strpart(l:target, strlen(l:common))
  if !empty(l:forward)
    let l:result = empty(l:result)
          \ ? l:forward[1:]
          \ : l:result . l:forward
  endif

  return l:result
endfunction

function! linkvim#paths#to_node(path) abort
  " Input: An absolute path
  " Output: Relative path without extension with respect to the wiki root,
  "         unless absolute path is shorter (a "node")

  return fnamemodify(linkvim#paths#shorten_relative(a:path), ':r')
endfunction

function! linkvim#paths#to_wiki_url(path, ...) abort
  " Input:  absolute path
  " Output: wiki url (relative to root)
  let l:root = a:0 > 0 ? a:1 : linkvim#get_root()
  let l:path = linkvim#paths#relative(a:path, l:root)

  let l:ext = '.' .. fnamemodify(l:path, ':e')
  return linkvim#link#get_creator('url_extension') ==# l:ext
        \ ? l:path
        \ : fnamemodify(l:path, ':r')
endfunction

let s:cd = haslocaldir()
      \ ? 'lcd'
      \ : exists(':tcd') && haslocaldir(-1) ? 'tcd' : 'cd'
let s:qpath = get(s:, 'qpath', [])

let s:re_abs = has('win32') ? '^\a:[\\/]' : '^/'
