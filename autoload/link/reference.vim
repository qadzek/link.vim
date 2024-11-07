" Add a link reference definition to the reference section
function! link#reference#Add(label, url, last_label_line_nr = '$') abort
  let l:new_line_content = '[' .. a:label .. ']: ' .. a:url
  call append(a:last_label_line_nr, l:new_line_content)
endfunction

" Parse the reference section, in its entirety or just one line
" Return a list of dictionaries
" Type : `all` or `one`
function! link#reference#Parse(start_line_nr, type) abort
  let l:cur_line_nr = a:start_line_nr

  if a:type ==# 'all'
    let l:last_line_nr = line('$')
  elseif a:type ==# 'one'
    let l:last_line_nr = a:start_line_nr
  else
    throw 'Invalid type: ' .. a:type
  endif

  " https://github.github.com/gfm/#link-reference-definition
  let l:all_link_reference_definitions = []
  let l:regex = '\v^\s*\[(\d+)\]:\s+(\S+)'

  " Loop over one line, or over all lines from divider/heading until last line
  for l:cur_line_nr in range(l:cur_line_nr, l:last_line_nr)
    let l:cur_line_content = getline(l:cur_line_nr)

    let l:match_list = matchlist(l:cur_line_content, l:regex)

    if len(l:match_list) == 0
      continue
    endif

    let l:link_ref_def = {
      \ 'line_nr': l:cur_line_nr - 1,
      \ 'full_match': l:match_list[0],
      \ 'label': l:match_list[1],
      \ 'destination': l:match_list[2],
    \ }

    call add(l:all_link_reference_definitions, l:link_ref_def)
  endfor

  return l:all_link_reference_definitions
endfunction

" Position reference section, so it isn't at the bottom of the buffer
function! link#reference#PositionSection() abort
  if !exists('b:link_heading_before') | return | endif

  " Move cursor to line matching pattern
  let l:match_line_nr = search(b:link_heading_before, 'bcWz')

  " Cannot find pattern: show error
  if l:match_line_nr == 0
    call link#utils#DisplayError('no_position_pattern', b:link_heading_before)
  " Can find pattern: move 2 lines up
  else
    keepjumps normal! 2k
  endif
endfunction
