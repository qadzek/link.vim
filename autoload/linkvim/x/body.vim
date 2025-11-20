" Determine which link to use. If there are multiple links on one line, pick the
" first link that is positioned behind or on the cursor.
function! linkvim#x#body#pick_closest_link(links, col_nr) abort
  if len(a:links) == 1
    return a:links[0]
  endif

  for l:link in a:links
    if a:col_nr < l:link.pos_end[1]
      break
    endif
  endfor

  return l:link
endfunction

" Replace link in the body with a reference-style link. This can also renumber
" an existing reference-style link. Return number of characters the line was
" shortened (positive number) or lengthened (negative number) by.
function! linkvim#x#body#replace_body_link(lnum, link, new_id, shortened_chars) abort
  let l:col_start = a:link.pos_start[1] - a:shortened_chars
  let l:col_end = a:link.pos_end[1] - a:shortened_chars
  let l:is_start_of_line = l:col_start == 1

  let l:cont = getline(a:lnum)
  let l:prefix = l:is_start_of_line ? '' : l:cont[0 : l:col_start - 2]
  let l:suffix = l:cont[l:col_end - 1 : -1]

  let l:new_cont = l:prefix
  if len(a:link.text) >= 1
    if a:link.type ==# 'md_fig'
      let l:new_cont .= '!' " Add `!` for images
    endif
    let l:new_cont .= '[' .. a:link.text .. ']' " Add `[foo]`
  endif
  let l:new_cont .= '[' .. a:new_id .. ']' " Add `[3]`
  let l:new_cont .= l:suffix

  call setline(a:lnum, l:new_cont)

  let l:len_diff = len(l:cont) - len(l:new_cont)
  return l:len_diff
endfunction

" Return whether line should be skipped because it is a blockquote.
function! linkvim#x#body#skip_blockquote(line_content) abort
  if a:line_content !~# '^>'
    return v:false
  endif

  if exists('b:link_include_blockquotes')
    return !b:link_include_blockquotes
  endif

  if exists('g:link_include_blockquotes')
    return !g:link_include_blockquotes
  endif

  return v:true
endfunction

" Return whether line should be skipped. It can be skipped because of a custom
" pattern or because it matches the `commentstring`.
function! linkvim#x#body#skip_line(line_content) abort
  " Use a custom pattern
  if exists('b:link_skip_line')
    let l:regex = b:link_skip_line

  " Use the `commentstring` as the default
  else
    let l:regex = '\V\^' .. substitute( escape(&commentstring, '\'), '%s', '\\.\\*', 'g' ) .. '\$'
  endif

  return match( a:line_content, l:regex ) >= 0
endfunction
