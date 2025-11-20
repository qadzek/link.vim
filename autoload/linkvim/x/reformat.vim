" Reformat reference links and reference section: renumber, merge, delete, mark
" as broken.
function! linkvim#x#reformat#reformat() abort
  let l:init_state = linkvim#x#lifecycle#initialize()

  let l:label_info = linkvim#x#label#get_info()
  let l:first_label_lnum = l:label_info.first.lnum
  let l:last_label_lnum = l:label_info.last.lnum
  let l:init_ref_len = l:last_label_lnum - l:first_label_lnum + 1
  let l:missing_marker = linkvim#x#u#setting_with_default(
    \ 'link_missing_marker', g:linkvim#defaults.missing_marker)

  " No reference section present
  if l:first_label_lnum == -1
    call linkvim#log#error('No reference section was found')
    call linkvim#x#lifecycle#finalize(l:init_state)
    return
  endif

  let l:ref_target_links = linkvim#x#u#get_links('ref_target')
  let l:includes_internal = len(filter(l:ref_target_links, {_, v -> v.scheme ==# ''})) > 0
  if l:includes_internal
    call linkvim#log#warn('Internal links detected. Pay attention!') " TODO
  endif

  let l:index = linkvim#x#label#get_start_index()
  let l:reference_links = linkvim#x#u#get_links('reference')
  let l:valid_links = []

  let l:state = {
    \ 'prev_lnum': 0,
    \ 'line_shortened_chars': 0,
    \ 'num_broken': 0,
    \ 'num_merged': 0,
    \ 'num_renumbered': 0,
    \ }

  for l:link in l:reference_links
    " Ignore non-numeric labels
    if l:link.url_raw !~# '^\d\+$'
      continue
    endif

    let l:lnum = l:link.pos_start[0]

    let l:line_cont = getline(l:lnum)
    if linkvim#x#body#skip_blockquote(l:line_cont) | continue | endif
    if linkvim#x#body#skip_line(l:line_cont) | continue | endif

    " Handle multiple links on the same line
    if l:lnum != l:state.prev_lnum
      let l:state.line_shortened_chars = 0
    endif
    let l:state.prev_lnum = l:lnum

    let b:resolve_silent = v:true
    let l:resolved = l:link.resolve()

    " Mark link as broken if no corresponding label was found in reference
    " section, or if resolution failed (because file not found).
    if empty(l:resolved) || l:resolved.scheme ==# 'refbad'
      let l:state.line_shortened_chars += linkvim#x#body#replace_body_link(
        \ l:lnum, l:link,l:missing_marker, l:state.line_shortened_chars)
      let l:state.num_broken += 1
      continue
    endif

    let l:resolved_url = linkvim#x#u#rm_wiki_prefix(l:resolved.url)

    " Merge label if exactly the same URL was already encountered before
    let l:url_matches = filter( deepcopy(l:valid_links), {_, v -> v.resolved ==# l:resolved_url} )
    if !empty(l:url_matches)
      " Avoid merging if this has been merged before
      if l:link.url_raw ==# l:url_matches[0].id
        continue
      endif
      let l:state.line_shortened_chars += linkvim#x#body#replace_body_link(
        \ l:lnum, l:link, l:url_matches[0].id, l:state.line_shortened_chars)
      let l:state.num_merged += 1
      continue
    endif

    " Renumber label if it differs from index: e.g. label says 5 while it's the 3rd link
    if l:link.url_raw !=# l:index
      let l:state.line_shortened_chars += linkvim#x#body#replace_body_link(
        \ l:lnum, l:link, l:index, l:state.line_shortened_chars)
      let l:state.num_renumbered += 1
    endif

    call add(l:valid_links, { 'resolved': l:resolved_url, 'id': l:index })
    let l:index += 1
  endfor

  " Delete current reference section to black hole register
  silent execute 'normal! :' .. l:first_label_lnum .. ',' .. l:last_label_lnum
        \ .. "$ delete _ \<CR>"

  " Generate new reference section
  let l:lnum = l:first_label_lnum - 1
  for l:link in l:valid_links
    call linkvim#x#reference#add( l:lnum, l:link.id, l:link.resolved )
    let l:lnum += 1
  endfor

  call linkvim#x#lifecycle#finalize(l:init_state)

  call linkvim#log#info('Links in text body - marked as broken: ' .. l:state.num_broken ..
        \ '; merged: ' .. l:state.num_merged ..
        \ '; renumbered: ' .. l:state.num_renumbered)
  let l:cur_ref_len = len(l:valid_links)
  let l:num_deleted = l:init_ref_len - l:cur_ref_len - l:state.num_merged
  call linkvim#log#info('Links in reference section - deleted: ' .. l:num_deleted)
endfunction
