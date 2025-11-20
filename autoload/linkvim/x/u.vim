" Return value of variable from buffer or global scope, or default.
function! linkvim#x#u#setting_with_default(var_name, default) abort
  return get(b:, a:var_name, get(g:, a:var_name, a:default))
endfunction

" Move cursor to first character of first line or last char of last line
function! linkvim#x#u#move_cursor_to(destination) abort
  if a:destination ==# 'start'
    let l:row = 1
    let l:col = 1
  elseif a:destination ==# 'end'
    let l:row = line('$')
    let l:col = col( [ l:row, '$' ] ) " Last char of last line
  endif

  call cursor(l:row, l:col)
endfunction

" Return links of given types from given range.
" Parameters:
"   types: string or list of strings indicating link types to return; 'all' for
"          all types (default: 'all');
"   start: starting line number (default: 1);
"   end:   ending line number (default: last line).
function! linkvim#x#u#get_links(types = 'all', start = 1, end = line('$')) abort
  let l:types = type(a:types) == v:t_string ? [a:types] : a:types

  let l:all_links = linkvim#link#get_all_from_range(a:start, a:end)

  " Filter out links of type `url` without an allowed scheme, to avoid e.g.
  " `foo:bar` from being recognized as a link.
  let l:links_allowed_schemes = filter(
        \ deepcopy(l:all_links),
        \ {_,link -> link.type !=# 'url' || s:is_in(link.scheme, g:linkvim#protocols) } )

  " Filter out links inside inline code (single backticks in Markdown).
  let l:links_not_in_code = filter(deepcopy(l:links_allowed_schemes),
    \ {_,link -> !linkvim#u#is_code(link.pos_start[0], link.pos_start[1]) })

  if l:types[0] ==# 'all'
    return l:links_not_in_code
  endif

  let l:links_allowed_types = filter(deepcopy(l:links_not_in_code),
    \ {_,link -> s:is_in(link.type, l:types) })
  return l:links_allowed_types
endfunction

" Return whether value is in list of values.
function! linkvim#x#u#is_in(value, list) abort
  return index(a:list, a:value) != -1
endfunction
let s:is_in = function('linkvim#x#u#is_in')

" Remove `wiki:` prefix from internal links.
function! linkvim#x#u#rm_wiki_prefix(url) abort
  return substitute(a:url, '^wiki:', '', '')
endfunction
