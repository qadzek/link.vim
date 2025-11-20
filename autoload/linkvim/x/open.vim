" Open an external link in the default browser. Open an internal link in the
" editor.
function! linkvim#x#open#open() abort
    let l:link = linkvim#link#get()

    if empty(l:link) || l:link.type ==# 'word'
      call linkvim#log#info('No link found under cursor')
      return
    endif

    call linkvim#link#follow()
endfunction
