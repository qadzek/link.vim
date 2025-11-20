" Add a link reference definition to the reference section.
function! linkvim#x#reference#add(lnum, id, url) abort
  let l:new_line_content = '[' .. a:id .. ']: ' .. a:url
  call append(a:lnum, l:new_line_content)
endfunction

" Position reference section, so it isn't at the bottom of the buffer.
function! linkvim#x#reference#position_section() abort
  if !exists('b:link_heading_before')
    return
  endif

  " Move cursor to line matching pattern
  let l:match_line_nr = search(b:link_heading_before, 'bcWz')

  " Cannot find pattern
  if l:match_line_nr == 0
    call linkvim#log#warn('Failed to detect pattern to position reference section: '
      \ .. b:link_heading_before)
    return
  endif

" Can find pattern: move 2 lines up
  keepjumps normal! 2k
endfunction
