" Return heading text: buffer-local, global or default.
function! linkvim#x#heading#get_text() abort
  let l:default = s:is_ft_markdown()
        \ ? g:linkvim#defaults['heading_markdown']
        \ : g:linkvim#defaults['heading_other']

  return linkvim#x#u#setting_with_default('link_heading', l:default)
endfunction

" Return whether heading is set to an empty string.
function! linkvim#x#heading#is_empty(heading_text) abort
  return type(a:heading_text) == v:t_string && a:heading_text ==# ''
endfunction

" Return whether heading needs to be added.
function! linkvim#x#heading#is_needed(is_empty, heading_text) abort
  if a:is_empty
    return v:false
  endif

  if type(a:heading_text) == v:t_list
    let l:pattern = '^' .. join(a:heading_text, '\_s*') .. '$' " Add newlines
  else
    let l:pattern = '^' .. a:heading_text .. '\s*$'
  endif

  let l:match_line_nr = search(l:pattern, 'nw')

  return l:match_line_nr == 0
endfunction

" Add the specified heading text to the buffer. Return number of lines added.
function! linkvim#x#heading#add(heading_text, lnum) abort
  if type(a:heading_text) == v:t_list
    let l:lines = a:heading_text
  else
    let l:lines = [ '', a:heading_text, ''  ] " Blank line above and below heading
  endif

  call append( a:lnum , l:lines )
  return len(l:lines)
endfunction

" Return whether filetype includes Markdown. This accounts for composite
" filetypes such as `vimwiki.markdown.pandoc`.
function! s:is_ft_markdown() abort
  return &filetype =~# 'markdown'
endfunction
