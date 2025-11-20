function! linkvim#url#follow(url_string, ...) abort
  let l:url = linkvim#url#resolve(a:url_string)
  if empty(l:url) | return | endif

  let l:edit_cmd = a:0 > 0 ? a:1 : 'edit'

  try
    call linkvim#url#handlers#{l:url.scheme}(l:url, l:edit_cmd)
  catch /E117/
    call linkvim#url#handlers#generic(l:url)
  endtry
endfunction

function! linkvim#url#resolve(url_string, ...) abort
  let l:parts = matchlist(a:url_string, '\v%((\w+):)?(.*)')

  let l:url = {
        \ 'url': a:url_string,
        \ 'scheme': tolower(l:parts[1]),
        \ 'stripped': l:parts[2],
        \ 'origin': a:0 > 0 ? a:1 : expand('%:p'),
        \}

  " The wiki scheme is default if no other scheme is applied
  if empty(l:url.scheme)
    let l:url.scheme = 'wiki'
    let l:url.url = l:url.scheme . ':' . l:url.url
  endif

  try
    let l:url = linkvim#url#resolvers#{l:url.scheme}(l:url)
  catch /E117/
  endtry

  return l:url
endfunction
