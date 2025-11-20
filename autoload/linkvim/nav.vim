function! linkvim#nav#next_link() abort
  call search(g:linkvim#rx#link, 's')
endfunction

function! linkvim#nav#prev_link() abort
  if linkvim#u#in_syntax('wikiLink.*')
        \ && linkvim#u#in_syntax('wikiLink.*', line('.'), col('.')-1)
    call search(g:linkvim#rx#link, 'sb')
  endif
  call search(g:linkvim#rx#link, 'sb')
endfunction
