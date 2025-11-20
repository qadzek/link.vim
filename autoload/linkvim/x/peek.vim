" For a reference link within the document body, show a preview of the
" corresponding link reference definition.
function! linkvim#x#peek#peek() abort
  let l:link = linkvim#link#get()
  if empty(l:link) | return | endif

  if l:link.type !=# 'reference'
    call linkvim#log#warn('Can only peek reference links')
    return
  endif

  let l:url = {
        \  'origin'   : l:link.origin,
        \  'scheme'   : l:link.scheme,
        \  'stripped' : l:link.url_raw,
        \  'url'      : l:link.url,
        \  }

  let b:resolve_silent = v:true
  let l:resolved = linkvim#url#resolvers#reference(l:url)
  if empty(l:resolved)
    call linkvim#log#warn('Could not locate reference')
    return
  endif

  if l:resolved.scheme ==# 'refbad'
    call linkvim#log#warn('Could not resolve link')
    return
  endif

  let l:fmt_url = linkvim#x#u#rm_wiki_prefix(l:resolved.url)

  call linkvim#log#info(l:fmt_url)
endfunction
