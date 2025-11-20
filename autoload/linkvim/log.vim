" vint: -ProhibitImplicitScopeVariable

function! linkvim#log#info(...) abort
  call s:logger.add(a:000, 'info')
endfunction

function! linkvim#log#warn(...) abort
  call s:logger.add(a:000, 'warning')
endfunction

function! linkvim#log#error(...) abort
  call s:logger.add(a:000, 'error')
endfunction

function! linkvim#log#get() abort
  return s:logger.entries
endfunction

function! linkvim#log#open() abort
  call linkvim#scratch#new(s:logger)
endfunction

function! linkvim#log#toggle_verbose() abort
  let s:logger.verbose = !s:logger.verbose
endfunction

function! linkvim#log#set_silent() abort
  let s:logger.verbose_old = get(s:logger, 'verbose_old', s:logger.verbose)
  let s:logger.verbose = 0
endfunction

function! linkvim#log#set_silent_restore() abort
  let s:logger.verbose = get(s:logger, 'verbose_old', s:logger.verbose)
endfunction

let s:logger = {
      \ 'name': 'LinkVimMessageLog',
      \ 'entries' : [],
      \ 'type_to_highlight' : {
      \   'info' : 'Identifier',
      \   'warning' : 'WarningMsg',
      \   'error' : 'ErrorMsg',
      \ },
      \ 'type_to_level': {
      \   'info': 1,
      \   'warning': 2,
      \   'error': 3,
      \ },
      \ 'verbose': get(get(s:, 'logger', {}), 'verbose',
      \                get(g:, 'linkvim_log_verbose', 1)),
      \}
function! s:logger.add(msg_arg, type) abort dict
  let l:msg_list = []
  for l:msg in a:msg_arg
    if type(l:msg) == v:t_string
      call add(l:msg_list, l:msg)
    elseif type(l:msg) == v:t_list
      call extend(l:msg_list, filter(l:msg, 'type(v:val) == v:t_string'))
    endif
  endfor

  let l:entry = {}
  let l:entry.type = a:type
  let l:entry.time = strftime('%T')
  let l:entry.msg = l:msg_list
  let l:entry.callstack = linkvim#debug#stacktrace()[1:]
  for l:level in l:entry.callstack
    let l:level.nr -= 2
  endfor
  call add(self.entries, l:entry)

  if self.verbose
    if self.type_to_level[a:type] > 1
      unsilent call self.notify(l:msg_list, a:type)
    else
      call self.notify(l:msg_list, a:type)
    endif
  endif
endfunction

function! s:logger.notify(msg_list, type) abort dict
  call linkvim#ui#echo([
        \ [self.type_to_highlight[a:type], 'link.vim:'],
        \ ' ' . a:msg_list[0]
        \])
  for l:msg in a:msg_list[1:]
    call linkvim#ui#echo(l:msg, {'indent': 2})
  endfor
endfunction

function! s:logger.print_content() abort dict
  for l:entry in self.entries
    call append('$', printf('%s: %s', l:entry.time, l:entry.type))
    for l:stack in l:entry.callstack
      if l:stack.lnum > 0
        call append('$', printf('  #%d %s:%d', l:stack.nr, l:stack.filename, l:stack.lnum))
      else
        call append('$', printf('  #%d %s', l:stack.nr, l:stack.filename))
      endif
      call append('$', printf('  In %s', l:stack.function))
      if !empty(l:stack.text)
        call append('$', printf('    %s', l:stack.text))
      endif
    endfor
    for l:msg in l:entry.msg
      call append('$', printf('  %s', l:msg))
    endfor
    call append('$', '')
  endfor
endfunction

function! s:logger.syntax() abort dict
  syntax match WikiLogOther /.*/

  syntax include @VIM syntax/vim.vim
  syntax match WikiLogVimCode /^    .*/ transparent contains=@VIM

  syntax match WikiLogKey /^\S*:/ nextgroup=WikiLogValue
  syntax match WikiLogKey /^  #\d\+/ nextgroup=WikiLogValue
  syntax match WikiLogKey /^  In/ nextgroup=WikiLogValue
  syntax match WikiLogValue /.*/ contained
endfunction

" vint: +ProhibitImplicitScopeVariable
