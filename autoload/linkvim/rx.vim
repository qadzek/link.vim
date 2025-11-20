" vint: -ProhibitImplicitScopeVariable

function! linkvim#rx#surrounded(word, chars) abort
  return '\%(^\|\s\|[[:punct:]]\)\zs'
        \ . escape(a:chars, '*')
        \ . a:word
        \ . escape(join(reverse(split(a:chars, '\zs')), ''), '*')
        \ . '\ze\%([[:punct:]]\|\s\|$\)'
endfunction

let linkvim#rx#word = '[^[:blank:]!"$%&''()*+,:;<=>?\[\]\\^`{}]\+'
let linkvim#rx#pre_beg = '^\s*```'
let linkvim#rx#pre_end = '^\s*```\s*$'
let linkvim#rx#super = '\^[^^`]\+\^'
let linkvim#rx#sub = ',,[^,`]\+,,'
let linkvim#rx#list_define = '::\%(\s\|$\)'
let linkvim#rx#comment = '^\s*%%.*$'
let linkvim#rx#todo = '\C\<\%(TODO\|STARTED\|FIXME\)\>:\?'
let linkvim#rx#done = '\C\<\%(OK\|DONE\|FIXED\)\>:\?'
let linkvim#rx#header_md_atx = '^#\{1,6}\s*[^#].*'
let linkvim#rx#header_md_atx_items = '^\(#\{1,6}\)\s*\([^#].*\)\s*$'
let linkvim#rx#header_org = '^\*\{1,6}\s*[^\*].*'
let linkvim#rx#header_org_items = '^\(\*\{1,6}\)\s*\([^\*].*\)\s*$'
let linkvim#rx#header_adoc = '^=\{1,6}\s*[^=].*'
let linkvim#rx#header_adoc_items = '^\(=\{1,6}\)\s*\([^=].*\)\s*$'
let linkvim#rx#bold = linkvim#rx#surrounded(
      \ '[^*`[:space:]]\%([^*`]*[^*`[:space:]]\)\?', '*')
let linkvim#rx#italic = linkvim#rx#surrounded(
      \ '[^_`[:space:]]\%([^_`]*[^_`[:space:]]\)\?', '_')
let linkvim#rx#date = '\d\d\d\d-\d\d-\d\d'
let linkvim#rx#url =
      \ '\%(\<\l\+:\%(\/\/\)\?[^ \t()\[\]|]\+'
      \ . '\|'
      \ . '<\zs\l\+:\%(\/\/\)\?[^>]\+\ze>\)'
" Match as few characters as possible, each of which is not \, [, or ].
let linkvim#rx#reftext = '[^\\\[\]]\{-}'
let linkvim#rx#reflabel = '\%(\d\+\|\a[-_. [:alnum:]]\+\|\^\w\+\)'
let linkvim#rx#link_adoc_link = '\<link:\%(\[[^]]\+\]\|[^[]\+\)\[[^]]*\]'
let linkvim#rx#link_adoc_xref_bracket = '<<[^>]\+>>'
let linkvim#rx#link_adoc_xref_inline = '\<xref:\%(\[[^]]\+\]\|[^[]\+\)\[[^]]*\]'
let linkvim#rx#link_md = '\[[^[\]]\{-}\]([^\\]\{-})'
let linkvim#rx#link_md_fig = '!' . linkvim#rx#link_md
let linkvim#rx#link_org = '\[\[\/\?[^\\\]]\{-}\]\%(\[[^\\\]]\{-}\]\)\?\]'
let linkvim#rx#link_reference = '[\]\[]\@<!\[' . linkvim#rx#reflabel . '\][\]\[]\@!'
let linkvim#rx#link_ref_collapsed = '[\]\[]\@<!\[' . linkvim#rx#reflabel . '\]\[\][\]\[]\@!'
let linkvim#rx#link_ref_full =
      \ '[\]\[]\@<!'
      \ . '\[' . linkvim#rx#reftext   . '\]'
      \ . '\[' . linkvim#rx#reflabel . '\]'
      \ . '[\]\[]\@!'
let linkvim#rx#url_ref_target = '\S\+' " MODIFIED
let linkvim#rx#link_ref_target =
      \ '^\s*\[' . linkvim#rx#reflabel . '\]:\s\+' . linkvim#rx#url_ref_target " MODIFIED
let linkvim#rx#link_cite = '\%(\s\|^\|\[\)\zs@[-_.+:a-zA-Z0-9]\+[-_a-zA-Z0-9]'
let linkvim#rx#link_cite_url = '\%(\s\|^\|\[\)@\zs[-_.+:a-zA-Z0-9]\+[-_a-zA-Z0-9]'
let linkvim#rx#link_wiki = '\[\[\/\?[^\\\]]\{-}\%(|[^\\\]]\{-}\)\?\]\]'

" Used in `linkvim#link#get_all_from_lines()`.
let linkvim#rx#link = join([
      \ linkvim#rx#link_wiki,
      \ linkvim#rx#link_adoc_link,
      \ linkvim#rx#link_adoc_xref_bracket,
      \ linkvim#rx#link_adoc_xref_inline,
      \ '!\?' . linkvim#rx#link_md,
      \ linkvim#rx#link_org,
      \ linkvim#rx#link_ref_target,
      \ linkvim#rx#link_reference,
      \ linkvim#rx#link_ref_full,
      \ linkvim#rx#url,
      \ linkvim#rx#link_cite,
      \], '\|')

" vint: +ProhibitImplicitScopeVariable
