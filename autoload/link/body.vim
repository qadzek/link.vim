" Scan single line in document body for inline link [foo](http://bar.com) or
" reference link [foo][5]
" Return list of dictionaries, containing full link [foo](http://bar.com), link
" text, destination (URL or reference), length of total match and start position
" of total match
function! link#body#ParseLineFor(type, line_nr) abort
  if a:type ==# 'inline'
    " Match `http://`, `ftp://`, `www.` etc.
    let l:protocol = g:link#globals#re['protocol'] .. '|www\.'

    if link#utils#IsFiletypeMarkdown()
      let l:regex_start = '\v' .. '\[(' .. '[^]]+' .. ')\]' .. '\(('
      let l:regex_end = '[^)]+' .. ')\)'

      " Match link to URL, e.g. [foo](http://bar.com)
      if link#utils#ConvertUrlsOnly()
        let l:regex = l:regex_start .. '%(' .. l:protocol .. ')' .. l:regex_end

      " Match link to URL, or to internal wiki page, e.g. [foo](bar.md)
      else
        let l:regex = l:regex_start .. l:regex_end
      endif

    " Match http://bar.com
    else
      " Avoid trailing punctuation character from being considered part of URL
      let l:last_url_char = '[a-zA-Z0-9/#-]'
      " '()' ensures the right match ends up in the right subgroup
      let l:regex = '\v' .. '()' .. '(%(' .. l:protocol .. ')' .. '\S+' ..
            \ l:last_url_char .. ')'
  endif

  elseif a:type ==# 'reference'
    " Match [foo][3]
    if link#utils#IsFiletypeMarkdown()
      let l:regex = '\v' .. '\[(' .. '[^]]+' .. ')\]' .. '\[(' .. '[^]]+' .. ')\]'

    " Match [3]
    else
      let l:regex = '\v' .. '()' .. '\[(' .. '[^]]+' .. ')\]'
    endif

  else
    throw 'Invalid type'
  endif

  let l:line_content = getline(a:line_nr)
  let l:line_len = len(l:line_content)

  let l:all_links = []
  let l:col = 0

  " Get all links on the specified line
  while l:col < l:line_len
    let l:match_list = matchlist(l:line_content, l:regex, l:col)

    if len(l:match_list) == 0
      break
    endif

    " First character is considered as 0
    let l:match_start = match(l:line_content, '\V' .. l:match_list[0], l:col) + 1

    let l:total_len = strlen(l:match_list[0])

    let l:link = {
      \ 'full_link': l:match_list[0],
      \ 'link_text': l:match_list[1],
      \ 'destination': l:match_list[2],
      \ 'length': l:total_len,
      \ 'col_start': l:match_start,
    \ }

    call add(l:all_links, l:link)

    let l:new_col = l:match_start + l:total_len
    if l:new_col == l:col
      let l:new_col += 1 " Avoid infinite loop
    endif
    let l:col = l:new_col
  endwhile

  return l:all_links
endfunction

" Determine which link to use, if there are multiple links on one line
" The link that is positioned behind or on the cursor will be picked
function! link#body#PickClosestLink(links, col_nr) abort
  if len(a:links) == 1
    return a:links[0]
  endif

  for l:link in a:links
    if a:col_nr < l:link['col_start'] + l:link['length']
      break
    endif
  endfor

  return l:link
endfunction

" Convert inline link to reference link by replacing line content
function! link#body#ReplaceLink(line_content, full_link, link_text, label, line_nr) abort
  " URLs containing the * character are not supported
  let l:esc_full_link = escape(a:full_link, '[]')

  if link#utils#IsFiletypeMarkdown()
    let l:ref_link = '[' .. a:link_text .. '][' .. a:label .. ']'
  else
    let l:ref_link = '[' .. a:label .. ']'
  endif

  let l:new_line_content = substitute(a:line_content, l:esc_full_link, l:ref_link, '')
  call setline(a:line_nr, l:new_line_content)
endfunction

" Return boolean indicating if line should be skipped
function! link#body#SkipLine(cur_line_nr) abort
  if exists('b:link_skip_line')
    " Use custom pattern
    let l:regex = b:link_skip_line

  else
    " Use a default
    let l:regex = '\V\^' .. substitute( escape(&commentstring, '\'), '%s', '\\.\\*', 'g' ) .. '\$'
  endif

  return match( getline(a:cur_line_nr), l:regex ) >= 0
endfunction

" Limit range to line containing heading/divider, so reference section stays
" untouched
function! link#body#LimitRange(divider_line_nr, range_end_line_nr) abort range
  if a:range_end_line_nr >= a:divider_line_nr
    return a:divider_line_nr - 1
  endif

  return a:range_end_line_nr
endfunction
