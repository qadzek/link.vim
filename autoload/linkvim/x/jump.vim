" Move the cursor between a reference link and its corresponding link reference
" definition.
function! linkvim#x#jump#jump() abort
  let l:link = linkvim#link#get()
  if empty(l:link) | return | endif

  " Move cursor from body to reference section
  if l:link.type ==# 'reference'
    let l:id = l:link.url_raw
    let l:url = {
          \  'origin'   : l:link.origin,
          \  'scheme'   : l:link.scheme,
          \  'stripped' : l:link.url_raw,
          \  'url'      : l:link.url,
          \  }

    let l:lnum = linkvim#url#resolvers#reference(l:url, v:true)
    if l:lnum == 0
      call linkvim#log#warn('Could not find matching label [' .. l:id .. '] in reference section')
      return
    endif

    let l:col = 5 + len(l:id) " Put cursor on first character of URL

  " Move cursor from reference section to text body
  elseif l:link.type ==# 'ref_target'
    let l:id = l:link.text
    let l:reference_links = linkvim#x#u#get_links('reference')
    let l:matches = filter(l:reference_links, {_, v -> v.url_raw ==# l:id})

    if empty(l:matches)
      call linkvim#log#warn('Could not find matching label [' .. l:id .. '] in text body')
      return
    endif

    let l:lnum = l:matches[0].pos_start[0]
    let l:col = l:matches[0].pos_end[1] - 1 " Put cursor after closing `]`

  else
    call linkvim#log#warn('Can only jump between references')
    return
  endif

  " Like in `linkvim#url#handlers#refbad()`
  normal! m'
  call cursor(l:lnum, l:col)
endfunction
