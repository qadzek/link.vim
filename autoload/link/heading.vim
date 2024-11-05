" Return buffer-local heading, or the global heading, or the default heading
function! link#heading#GetText() abort
  if exists('b:link_heading')
    return b:link_heading
  endif

  if exists('g:link_heading')
    return g:link_heading
  endif

  if link#utils#IsFiletypeMarkdown()
    return g:link#globals#defaults['heading_markdown']
  else
    return g:link#globals#defaults['heading_other']
  endif
endfunction

" Return <line_nr> if buffer contains heading, else 0
function! link#heading#GetLineNr(heading) abort
  " Needed to get line number if there are two headings
  normal! G$

  " Search *b*ackward, accept a match at *c*ursor position, do *n*ot move
  " cursor, start search at cursor instead of *z*ero
  return search('^' .. a:heading .. '\s*$', 'bcnz')
endfunction

" Return 1 if heading is present in buffer, else 0
function! link#heading#IsPresent(heading) abort
  let l:line_nr = link#heading#GetLineNr(a:heading)
  return l:line_nr > 0
endfunction

" Return list of heading text, if heading is present, heading line number
function! link#heading#GetInfo() abort
  let l:heading_text = link#heading#GetText()
  let l:is_heading_present = link#heading#IsPresent(l:heading_text)
  let l:heading_line_nr = link#heading#GetLineNr(l:heading_text)
  return [ l:heading_text, l:is_heading_present, l:heading_line_nr ]
endfunction

" Add the specified heading to the buffer
function! link#heading#Add(heading_text) abort
  normal! G$

  " Move to a line matching a pattern, before adding the heading
  if exists('b:link_heading_before')

    " Cannot find pattern: show message
    if search(b:link_heading_before, 'bcWz') == 0
      call link#utils#DisplayError('no_heading_pattern', b:link_heading_before)

    " Can find pattern: move 2 lines up
    else
      normal! 2k
    endif
  endif

  " Add a blank line above and below the heading
  call append('.', [ '', a:heading_text, ''  ])
endfunction

" Limit range to line containing heading, so reference section stays untouched
function! link#heading#LimitRange(is_heading_present, heading_line_nr, range_end_line_nr) abort range
  if a:is_heading_present && a:range_end_line_nr > a:heading_line_nr
    return a:heading_line_nr
  endif

  return a:range_end_line_nr
endfunction

