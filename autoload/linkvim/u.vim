function! linkvim#u#cnum_to_byte(cnum) abort
  if a:cnum <= 0 | return a:cnum | endif
  let l:bytes = len(strcharpart(getline('.')[a:cnum-1:], 0, 1))
  return a:cnum + l:bytes - 1
endfunction

function! linkvim#u#command(cmd) abort
  return execute(a:cmd, 'silent!')->split("\n")
endfunction

function! linkvim#u#extend_recursive(dict1, dict2, ...) abort
  let l:option = a:0 > 0 ? a:1 : 'force'
  if index(['force', 'keep', 'error'], l:option) < 0
    throw 'E475: Invalid argument: ' .. l:option
  endif

  for [l:key, l:Value] in items(a:dict2)
    if !has_key(a:dict1, l:key)
      let a:dict1[l:key] = l:Value
    elseif type(l:Value) == type({})
      call linkvim#u#extend_recursive(a:dict1[l:key], l:Value, l:option)
    elseif l:option ==# 'error'
      throw 'E737: Key already exists: ' .. l:key
    elseif l:option ==# 'force'
      let a:dict1[l:key] = l:Value
    endif
    unlet l:Value
  endfor

  return a:dict1
endfunction

function! linkvim#u#in_syntax(name, ...) abort
  let l:pos = [0, 0]
  let l:pos[0] = a:0 > 0 ? a:1 : line('.')
  let l:pos[1] = a:0 > 1 ? a:2 : col('.')
  if mode() ==# 'i'
    let l:pos[1] -= 1
  endif
  if l:pos[1] <= 0
    let l:pos[0] -= 1
    let l:pos[1] = 10000
  endif
  call map(l:pos, 'max([v:val, 1])')

  " vint: -ProhibitInvalidMapCall
  " Check syntax at position
  return synstack(l:pos[0], l:pos[1])
        \ ->map("synIDattr(v:val, 'name')")
        \ ->match('^' .. a:name) >= 0
  " vint: +ProhibitInvalidMapCall
endfunction

function! linkvim#u#is_code(...) abort
  let l:lnum = a:0 > 0 ? a:1 : line('.')
  let l:col = a:0 > 1 ? a:2 : col('.')

  " vint: -ProhibitInvalidMapCall
  return synstack(l:lnum, l:col)
        \ ->map("synIDattr(v:val, 'name')")
        \ ->match('^\%(wikiPre\|mkd\%(Code\|Snippet\)\|markdownCode\)') >= 0
  " vint: +ProhibitInvalidMapCall
endfunction

function! linkvim#u#is_code_by_string(line, in_code) abort
  " Check if we are inside a fenced code block by inspecting a given line. The
  " in_code argument indicates if we were already within a code block.
  "
  " We return two values: [in_code, skip]
  "
  " `in_code` is taken to be true for all lines within a fenced code block
  " except the last fence. `skip` is true for all lines, including the last
  " fence. This means we can use the output to properly skip lines while
  " parsing a set of lines.

  if a:in_code
    let l:code_ended = a:line =~# '^\s*```\s*$'
    return [!l:code_ended, v:true]
  endif

  if a:line =~# '^\s*```\w*\s*$'
    return [v:true, v:true]
  endif

  return [v:false, v:false]
endfunction

function! linkvim#u#shellescape(string) abort
  "
  " Path used in "cmd" only needs to be enclosed by double quotes.
  " shellescape() on Windows with "shellslash" set will produce a path
  " enclosed by single quotes, which "cmd" does not recognize and reports an
  " error.
  "
  if has('win32')
    let l:shellslash = &shellslash
    set noshellslash
    let l:cmd = shellescape(a:string)
    let &shellslash = l:shellslash
    return l:cmd
  endif

  return shellescape(a:string)
endfunction

function! linkvim#u#uniq_unsorted(list) abort
  if len(a:list) <= 1 | return a:list | endif

  let l:visited = {}
  let l:result = []
  for l:x in a:list
    let l:key = string(l:x)
    if !has_key(l:visited, l:key)
      let l:visited[l:key] = 1
      call add(l:result, l:x)
    endif
  endfor

  return l:result
endfunction
