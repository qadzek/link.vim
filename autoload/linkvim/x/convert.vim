" Convert inline links to reference links within a range.
" Type : `multiple` or `single` (indicates how many links to convert)
" Mode : `normal` or `insert`
function! linkvim#x#convert#convert(type = 'multiple', mode = 'normal') abort range
  let l:init_state = linkvim#x#lifecycle#initialize()

  call s:removal_warning() " TODO: Remove in future version

  " Use cursor position before range function moves cursor to first line of
  " range: https://vi.stackexchange.com/questions/6036/
  if exists('b:init_view')
    let l:init_state.view = b:init_view
    unlet b:init_view
  endif

  let l:ref_target_links = linkvim#x#u#get_links('ref_target')
  let l:label_info = linkvim#x#label#get_info(l:ref_target_links)
  let l:first_label_lnum = l:label_info.first.lnum
  let l:is_ref_section_present = l:first_label_lnum != -1
  let l:last_label_lnum = l:label_info.last.lnum
  let l:last_label_idx = l:label_info.last.id

  let l:heading_text = linkvim#x#heading#get_text()
  let l:heading_is_empty = linkvim#x#heading#is_empty(l:heading_text)
  let l:heading_is_needed = linkvim#x#heading#is_needed(l:heading_is_empty, l:heading_text)

  " Reference section present
  if l:is_ref_section_present
    let l:divider_lnum = l:first_label_lnum - 1
    let l:new_label_idx = l:last_label_idx + 1
  " No reference section present
  else
    call linkvim#x#u#move_cursor_to('end')
    call linkvim#x#reference#position_section()
    let l:divider_lnum = line('.')
    let l:last_label_lnum = line('.')
    let l:new_label_idx = linkvim#x#label#get_start_index()
  endif

  let l:allowed_types = ['url', 'md', 'md_fig']
  let l:links = linkvim#x#u#get_links(l:allowed_types, a:firstline, a:lastline)

  if s:convert_urls_only()
    let l:links = filter(deepcopy(l:links), {_,link -> s:is_in(link.scheme, g:linkvim#protocols) })
  endif

  if empty(l:links)
    call linkvim#log#warn('Detected no links that can be converted')
    call linkvim#x#lifecycle#finalize(l:init_state)
    return
  endif

  " When converting a single link, limit list of links to one link
  if a:type ==# 'single'
    let l:links = [ linkvim#x#body#pick_closest_link(l:links, l:init_state.col) ]
  endif

  let l:loop_state = {
    \ 'prev_lnum': 0,
    \ 'line_shortened_chars': 0,
    \ 'conversion_counter': 0,
    \ }

  for l:link in l:links
    let l:lnum = l:link.pos_start[0]
    let l:line_cont = getline(l:lnum)

    if linkvim#x#body#skip_blockquote(l:line_cont) | continue | endif
    if linkvim#x#body#skip_line(l:line_cont) | continue | endif

    " Handle multiple links on the same line
    if l:lnum != l:loop_state.prev_lnum
      let l:loop_state.line_shortened_chars = 0
    endif

    " In case of an empty heading, add a blank line
    if l:heading_is_empty && !l:is_ref_section_present
      call append( line('.'), '' )
      let l:last_label_lnum += 1
      let l:is_ref_section_present = v:true
    endif

    " Add a (non-empty) heading
    if l:heading_is_needed
      let l:last_label_lnum += linkvim#x#heading#add(l:heading_text, l:divider_lnum)
      let l:heading_is_needed = v:false
    endif

    " Check if the same link is already present in the reference section
    let l:matches_in_ref_section = filter(deepcopy(l:ref_target_links), {_, v -> v.url ==# l:link.url_raw })
    let l:already_in_ref_section = len(l:matches_in_ref_section) > 0

    let l:id = l:already_in_ref_section ? l:matches_in_ref_section[0].text : l:new_label_idx

    let l:loop_state.line_shortened_chars += linkvim#x#body#replace_body_link(
          \ l:lnum,
          \ l:link,
          \ l:id,
          \ l:loop_state.line_shortened_chars)

    let l:loop_state.conversion_counter += 1
    let l:loop_state.prev_lnum = l:lnum

    " Avoid adding duplicate links to reference section
    if l:already_in_ref_section
      continue
    endif
    call add(l:ref_target_links, { 'url': l:link.url_raw, 'text': l:new_label_idx })

    call linkvim#x#reference#add( l:last_label_lnum, l:new_label_idx, l:link.url_raw)

    let l:last_label_lnum += 1
    let l:new_label_idx += 1
  endfor

  call linkvim#x#lifecycle#finalize(l:init_state)
  call s:display_conversion_count(a:type, l:loop_state.conversion_counter)
  call s:move_cursor_to_link_end(a:type, a:mode, l:links[0], l:init_state.lnum, l:init_state.line_len)
endfunction

" Display how many links were converted.
function! s:display_conversion_count(type, counter) abort
  if a:type ==# 'single'
    return
  endif

  let l:msg = a:counter == 1 ? ' link was' : ' links were'
  call linkvim#log#info(a:counter .. l:msg .. ' converted')
endfunction

" Move cursor when called from Insert mode, so user can continue typing after
" the converted link.
function! s:move_cursor_to_link_end(type, mode, link, lnum, init_line_len) abort
  if a:type !=# 'single' || a:mode !=# 'insert'
    return
  endif

  if ! s:is_in(a:link.type, ['md', 'url'])
    return
  endif

  let l:is_last_char = a:link.pos_end[1] == a:init_line_len + 1

  " Move to end of reference link: first to start, then to 1st/2nd `]`
  call cursor(a:lnum, a:link.pos_start[1])

  if a:link.type ==# 'md'
    keepjumps normal! 2f]
  elseif a:link.type ==# 'url'
    keepjumps normal! f]
  endif

  " Return to insert mode; link is at the very end of the line
  if l:is_last_char
    startinsert!
  " Return to insert mode; link is in the middle of the line
  else
    normal! l
    startinsert
  endif
endfunction

" Show warning for removed configuration options.
function! s:removal_warning() abort
  if !exists('g:link_enabled_filetypes')
    return
  endif

  if exists('s:warned') && s:warned
    return
  endif
  let s:warned = v:true

  let l:msg = 'let g:link_enabled_filetypes has been removed. '
  let l:msg .= 'Run ":help g:link_enabled_filetypes" for more information.'

  call linkvim#log#info(l:msg)
endfunction

" Return whether only URLs should be converted, and not links to internal files.
function! s:convert_urls_only() abort
  return linkvim#x#u#setting_with_default('link_disable_internal_links', 0)
endfunction

let s:is_in = function('linkvim#x#u#is_in')
