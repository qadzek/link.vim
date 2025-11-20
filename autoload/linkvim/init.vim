" Note: This file is loaded as long as wiki.vim is loaded, so try to keep it as
"       short as possible!

function! linkvim#init#option(name, default) abort
  let l:option = 'g:' . a:name
  if !exists(l:option)
    let {l:option} = a:default
  elseif type(a:default) == type({})
    call linkvim#u#extend_recursive({l:option}, a:default, 'keep')
  endif
endfunction
