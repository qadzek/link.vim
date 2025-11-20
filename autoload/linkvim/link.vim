function! linkvim#link#get() abort
  if linkvim#u#is_code() | return {} | endif

  for l:link_definition in g:linkvim#link#definitions#all
    let l:match = s:match_at_cursor(l:link_definition.rx)
    if empty(l:match) | continue | endif

    return linkvim#link#class#new(l:link_definition, l:match)
  endfor

  return {}
endfunction

function! s:match_at_cursor(regex) abort
  let l:lnum = line('.')

  " Seach backwards for current regex
  let l:c1 = searchpos(a:regex, 'ncb', l:lnum)[1]
  if l:c1 == 0 | return {} | endif

  " Ensure that the cursor is positioned on top of the match
  let l:c1e = searchpos(a:regex, 'ncbe', l:lnum)[1]
  if l:c1e >= l:c1 && l:c1e < col('.') | return {} | endif

  " Find the end of the match
  let l:c2 = searchpos(a:regex, 'nce', l:lnum)[1]
  if l:c2 == 0 | return {} | endif

  let l:c2 = linkvim#u#cnum_to_byte(l:c2)

  return {
        \ 'content': strpart(getline('.'), l:c1-1, l:c2-l:c1+1),
        \ 'origin': expand('%:p'),
        \ 'pos_end': [l:lnum, l:c2],
        \ 'pos_start': [l:lnum, l:c1],
        \}
endfunction

function! linkvim#link#show(...) abort
  let l:link = linkvim#link#get()

  if empty(l:link) || l:link.type ==# 'word'
    call linkvim#log#info('No link detected')
  else
    let l:viewer = {
          \ 'name': 'LinkInfo',
          \ 'items': l:link.describe()
          \}
    function! l:viewer.print_content() abort dict
      for [l:key, l:value] in l:self.items
        call append('$', printf(' %-14s %s', l:key, l:value))
      endfor
    endfunction

    call linkvim#scratch#new(l:viewer)
  endif
endfunction

function! linkvim#link#follow(...) abort
  let l:edit_cmd = a:0 > 0 ? a:1 : 'edit'
  let l:link = linkvim#link#get()
  if empty(l:link) | return | endif

  try
    call linkvim#url#follow(l:link.url, l:edit_cmd)
  catch /E37:/
    call linkvim#log#error(
          \ "Can't follow link before you've saved the current buffer.")
  endtry
endfunction

function! linkvim#link#get_scheme(link_type) abort
  let l:scheme = get(g:linkvim_link_default_schemes, a:link_type, '')

  if type(l:scheme) == v:t_dict
    let l:scheme = get(l:scheme, expand('%:e'), '')
  endif

  return l:scheme
endfunction

function! linkvim#link#get_all_from_file(...) abort
  let l:file = a:0 > 0 ? a:1 : expand('%:p')
  if !filereadable(l:file) | return [] | endif

  return linkvim#link#get_all_from_lines(readfile(l:file), l:file)
endfunction

function! linkvim#link#get_all_from_range(line1, line2) abort
  let l:lines = getline(a:line1, a:line2)
  return linkvim#link#get_all_from_lines(l:lines, expand('%:p'), a:line1)
endfunction

function! linkvim#link#get_all_from_lines(lines, file, ...) abort
  let l:links = []

  let l:in_code = v:false
  let l:skip = v:false

  let l:lnum = a:0 > 0 ? (a:1 - 1) : 0
  for l:line in a:lines
    let l:lnum += 1

    let [l:in_code, l:skip] = linkvim#u#is_code_by_string(l:line, l:in_code)
    if l:skip | continue | endif

    let l:c2 = 0
    while v:true
      let l:c1 = match(l:line, g:linkvim#rx#link, l:c2) + 1
      if l:c1 == 0 | break | endif

      let l:content = matchstr(l:line, g:linkvim#rx#link, l:c2)
      let l:c2 = l:c1 + strlen(l:content)

      for l:link_definition in g:linkvim#link#definitions#all_real
        if l:content =~# l:link_definition.rx
          call add(l:links, linkvim#link#class#new(l:link_definition, {
                \ 'content': l:content,
                \ 'origin': a:file,
                \ 'pos_start': [l:lnum, l:c1],
                \ 'pos_end': [l:lnum, l:c2],
                \}))
          break
        endif
      endfor
    endwhile
  endfor

  return l:links
endfunction
