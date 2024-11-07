" Return applicable heading, in order: buffer-local, global or default heading
function! link#heading#GetText() abort
  if exists('b:link_heading') | return b:link_heading | endif
  if exists('g:link_heading') | return g:link_heading | endif

  if link#utils#IsFiletypeMarkdown()
    return g:link#globals#defaults['heading_markdown']
  else
    return g:link#globals#defaults['heading_other']
  endif
endfunction

" Return boolean, indicating whether heading is set to empty string
function! link#heading#IsEmpty(heading_text) abort
  return empty(a:heading_text)
endfunction

" Return boolean indicating if heading needs to be added
function! link#heading#IsNeeded(is_empty, heading_text) abort
  if a:is_empty | return 0 | endif

  let l:match_line_nr = search('^' .. a:heading_text .. '\s*$', 'nw')
  return l:match_line_nr == 0
endfunction

" Add the specified heading to the buffer
function! link#heading#Add(heading_text, line_nr) abort
  " Add a blank line above and below the heading
  let l:lines = [ '', a:heading_text, ''  ]

  call append( a:line_nr , l:lines )
endfunction
