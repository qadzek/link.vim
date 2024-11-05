" Determine new label number
function! link#label#GetNewNumber(is_heading_present) abort
  if a:is_heading_present
    return link#label#GetLast('label_nr') + 1
  endif

  return link#label#GetStartIndex()
endfunction

" Return the start index for the first label, buffer-local or global, or default
function! link#label#GetStartIndex() abort
  if exists('b:link_start_index')
    return b:link_start_index
  endif

  if exists('g:link_start_index')
    return g:link_start_index
  endif

  return g:link#globals#defaults['start_index']
endfunction

" Types : 'line_nr' or 'label_nr'
" 'label_nr':
" Return last label number in reference section, e.g. 3 for [3]: http://foo.com
" Return -1 if not found
" 'line_nr':
" Return line number of last label in reference section
" Return last line number of buffer if not found
function! link#label#GetLast(type) abort
  let l:regex = '\v^\s*\[\zs\d+\ze\]:\s+'

  " Go to start of last non-blank line
  " silent execute "normal! G$?.\<CR>0"

  normal! G$
  call search(l:regex, 'bcW')

  if a:type ==# 'line_nr'
    return line('.')
  endif

  " Get number between square brackets
  let l:last_line_content = getline('.')
  let l:match = matchstr(l:last_line_content, l:regex)

  " This could happen if there is only a header present, without any labels, or
  " if there is regular text below the header
  if l:match !~# '^\d\+$'
    return -1
  endif

  return str2nr(l:match)
endfunction

