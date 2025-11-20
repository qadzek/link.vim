function! linkvim#ui#echo(input, ...) abort
  if empty(a:input) | return | endif
  let l:opts = extend(#{indent: 0}, a:0 > 0 ? a:1 : {})

  if type(a:input) == v:t_string
    call s:echo_string(a:input, l:opts)
  elseif type(a:input) == v:t_list
    call s:echo_formatted(a:input, l:opts)
  elseif type(a:input) == v:t_dict
    call s:echo_dict(a:input, l:opts)
  else
    call linkvim#log#warn('Argument not supported: ' . type(a:input))
  endif
endfunction


function! linkvim#ui#confirm(prompt) abort
  return linkvim#ui#{g:linkvim_ui_method.confirm}#confirm(a:prompt)
endfunction

function! linkvim#ui#input(options) abort
  let l:options = extend(#{
        \ prompt: '> ',
        \ text: '',
        \ info: '',
        \}, a:options)

  return linkvim#ui#{g:linkvim_ui_method.input}#input(l:options)
endfunction

function! linkvim#ui#select(container, ...) abort
  let l:options = extend(
        \ {
        \   'prompt': 'Please choose item:',
        \   'return': 'value',
        \   'force_choice': v:false,
        \   'auto_select': v:true,
        \ },
        \ a:0 > 0 ? a:1 : {})

  let l:list = type(a:container) == v:t_dict
        \ ? values(a:container)
        \ : a:container
  let [l:index, l:value] = empty(l:list)
        \ ? [-1, '']
        \ : (len(l:list) == 1 && l:options.auto_select
        \   ? [0, l:list[0]]
        \   : linkvim#ui#{g:linkvim_ui_method.select}#select(l:options, l:list))

  if l:options.return ==# 'value'
    return l:value
  endif

  if type(a:container) == v:t_dict
    return l:index >= 0 ? keys(a:container)[l:index] : ''
  endif

  return l:index
endfunction


function! linkvim#ui#get_number(max, digits, force_choice, do_echo) abort
  let l:choice = ''

  if a:do_echo
    echo '> '
  endif

  while len(l:choice) < a:digits
    if len(l:choice) > 0 && (l:choice . '0') > a:max
      return l:choice - 1
    endif

    let l:input = nr2char(getchar())

    if !a:force_choice && index(["\<C-c>", "\<Esc>", 'x'], l:input) >= 0
      if a:do_echo
        echon 'aborted!'
      endif
      return -2
    endif

    if len(l:choice) > 0 && l:input ==# "\<cr>"
      return l:choice - 1
    endif

    if l:input !~# '\d' | continue | endif

    if (l:choice . l:input) > 0
      let l:choice .= l:input
      if a:do_echo
        echon l:input
      endif
    endif
  endwhile

  return l:choice - 1
endfunction

function! s:echo_string(msg, opts) abort
  let l:msg = repeat(' ', a:opts.indent) . a:msg

  echo l:msg
endfunction

function! s:echo_formatted(parts, opts) abort
  echo repeat(' ', a:opts.indent)
  try
    for l:part in a:parts
      if type(l:part) == v:t_string
        echohl None
        echon l:part
      else
        execute 'echohl' l:part[0]
        echon l:part[1]
      endif
      unlet l:part
    endfor
  finally
    echohl None
  endtry
endfunction

function! s:echo_dict(dict, opts) abort
  for [l:key, l:val] in items(a:dict)
    call s:echo_formatted([['Label', l:key . ': '], l:val], a:opts)
  endfor
endfunction
