" vint: -ProhibitImplicitScopeVariable

function! linkvim#link#class#new(link_definition, match) abort
  let l:link = extend(deepcopy(s:link), a:match, 'error')
  let l:link.type = a:link_definition.type

  " Parse link description and URL
  let l:link.text = ''
  let l:link.url = l:link.content
  call s:parse_from_content(l:link, a:link_definition, 'text')
  call s:parse_from_content(l:link, a:link_definition, 'url')
  let l:link.url_raw = l:link.url

  " Remove enclosing angled brackets
  let l:link.url = substitute(l:link.url, '^<\(.*\)>$', '\1', '')

  " Add scheme to URL if it is missing
  if has_key(a:link_definition, '__scheme')
    let l:link.scheme = type(a:link_definition.__scheme) == v:t_func
          \ ? a:link_definition.__scheme()
          \ : a:link_definition.__scheme
    let l:link.url = l:link.scheme . ':' . l:link.url
  else
    let l:link.scheme = matchstr(l:link.url, '^\w\+\ze:')
    if empty(l:link.scheme)
      let l:default_scheme = linkvim#link#get_scheme(l:link.type)
      if !empty(l:default_scheme)
        let l:link.url = l:default_scheme . ':' . l:link.url
        let l:link.scheme = l:default_scheme
      endif
    endif
  endif

  return l:link
endfunction

function! s:parse_from_content(link, link_definition, name) abort
  let l:regex = get(a:link_definition, 'rx_' . a:name, '')
  if empty(l:regex) | return | endif

  let [l:match, l:c1, l:c2] = s:matchstrpos(a:link.content, l:regex)
  if empty(l:match) | return | endif

  let a:link[a:name] = l:match
  let a:link[a:name . '_pos_start'] = [
        \ a:link.pos_start[0],
        \ a:link.pos_start[1] + l:c1
        \]
  let a:link[a:name . '_pos_end'] = [
        \ a:link.pos_start[0],
        \ a:link.pos_start[1] + l:c2 - 1
        \]
endfunction

function! s:matchstrpos(...) abort
  if exists('*matchstrpos')
    return call('matchstrpos', a:000)
  else
    let [l:expr, l:pat] = a:000[:1]

    let l:pos = match(l:expr, l:pat)
    if l:pos < 0
      return ['', -1, -1]
    else
      let l:match = matchstr(l:expr, l:pat)
      return [l:match, l:pos, l:pos+strlen(l:match)]
    endif
  endif
endfunction

let s:link = {}
function! s:link.replace(text) dict abort
  let l:line = getline(self.pos_start[0])
  call setline(self.pos_start[0],
        \   strpart(l:line, 0, self.pos_start[1]-1)
        \ . a:text
        \ . strpart(l:line, self.pos_end[1]))
endfunction

function! s:link.describe() dict abort
  let l:content = [
        \  ['Type:', self.type],
        \  ['Match:', self.content],
        \  ['URL:', self.url],
        \]

  if self.url !=# self.url_raw
    let l:content += [['URL (raw):', self.url_raw]]
  endif

  let l:content += [['Description:', empty(self.text) ? 'N/A' : self.text]]

  let l:content += [['', '']]
  let l:content += [['Resolved URL object:', '']]
  for [l:key, l:value] in items(self.resolve())
    let l:content += [['  ' . l:key . ':', l:value]]
  endfor

  return l:content
endfunction

function! s:link.transform() dict abort
  let l:new = self.__transformer(self.url_raw, self.text, self)
  if empty(l:new) | return | endif

  call self.replace(l:new)
endfunction

function! s:link.resolve() dict abort
  if self.type ==# 'word' | return '' | endif

  return linkvim#url#resolve(self.url, self.origin)
endfunction

" vint: +ProhibitImplicitScopeVariable
