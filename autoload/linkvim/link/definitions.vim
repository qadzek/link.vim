let g:linkvim#link#definitions#wiki = {
      \ 'type': 'wiki',
      \ 'rx': g:linkvim#rx#link_wiki,
      \ 'rx_url': '\[\[\zs\/\?[^\\\]]\{-}\ze\%(|[^\\\]]\{-}\)\?\]\]',
      \ 'rx_text': '\[\[\/\?[^\\\]]\{-}|\zs[^\\\]]\{-}\ze\]\]',
      \}

let g:linkvim#link#definitions#adoc_xref_bracket = {
      \ 'type': 'adoc_xref_bracket',
      \ 'rx': g:linkvim#rx#link_adoc_xref_bracket,
      \ 'rx_url': '<<\zs\%([^,>]\{-}\ze,[^>]\{-}\|[^>]\{-}\ze\)>>',
      \ 'rx_text': '<<[^,>]\{-},\zs[^>]\{-}\ze>>',
      \}

let g:linkvim#link#definitions#adoc_xref_inline = {
      \ 'type': 'adoc_xref_inline',
      \ 'rx': g:linkvim#rx#link_adoc_xref_inline,
      \ 'rx_url': '\<xref:\%(\[\zs[^]]\+\ze\]\|\zs[^[]\+\ze\)\[[^]]*\]',
      \ 'rx_text': '\<xref:\%(\[[^]]\+\]\|[^[]\+\)\[\zs[^]]*\ze\]',
      \}

let g:linkvim#link#definitions#adoc_link = {
      \ 'type': 'adoc_link',
      \ 'rx': g:linkvim#rx#link_adoc_link,
      \ 'rx_url': '\<link:\%(\[\zs[^]]\+\ze\]\|\zs[^[]\+\ze\)\[[^]]\+\]',
      \ 'rx_text': '\<link:\%(\[[^]]\+\]\|[^[]\+\)\[\zs[^]]\+\ze\]',
      \}

let g:linkvim#link#definitions#md_fig = {
      \ 'type': 'md_fig',
      \ 'rx': g:linkvim#rx#link_md_fig,
      \ 'rx_url': '!\[[^\\\[\]]\{-}\](\zs[^\\]\{-}\ze)',
      \ 'rx_text': '!\[\zs[^\\\[\]]\{-}\ze\]([^\\]\{-})',
      \ '__transformer': { u, t, _ -> printf('![%s](%s)', empty(t) ? u : t, u) },
      \}

let g:linkvim#link#definitions#md = {
      \ 'type': 'md',
      \ 'rx': g:linkvim#rx#link_md,
      \ 'rx_url': '\[[^[\]]\{-}\](\zs[^\\]\{-}\ze)',
      \ 'rx_text': '\[\zs[^[\]]\{-}\ze\]([^\\]\{-})',
      \}

let g:linkvim#link#definitions#org = {
      \ 'type' : 'org',
      \ 'rx' : g:linkvim#rx#link_org,
      \ 'rx_url' : '\[\[\zs\/\?[^\\\]]\{-}\ze\]\%(\[[^\\\]]\{-}\]\)\?\]',
      \ 'rx_text' : '\[\[\/\?[^\\\]]\{-}\]\[\zs[^\\\]]\{-}\ze\]\]',
      \}

let g:linkvim#link#definitions#ref_target = {
      \ 'type': 'ref_target',
      \ 'rx': g:linkvim#rx#link_ref_target,
      \ 'rx_url': '\[' . g:linkvim#rx#reflabel . '\]:\s\+\zs.*',
      \ 'rx_text': '^\s*\[\zs' . g:linkvim#rx#reflabel . '\ze\]',
      \ '__transformer': function('linkvim#link#templates#ref_target'),
      \}

let g:linkvim#link#definitions#reference = {
      \ 'type': 'reference',
      \ 'rx': g:linkvim#rx#link_reference,
      \ 'rx_url': '\[\zs' . g:linkvim#rx#reflabel . '\ze\]',
      \ '__scheme': 'reference',
      \ '__transformer': { _u, _t, l -> linkvim#link#template#md(l.url, l.id) },
      \}

let g:linkvim#link#definitions#ref_collapsed = extend(
      \ deepcopy(g:linkvim#link#definitions#reference), {
      \ 'rx': g:linkvim#rx#link_ref_collapsed,
      \ 'rx_url': '\[\zs' . g:linkvim#rx#reflabel . '\ze\]\[\]',
      \ 'rx_text': '\[\zs' . g:linkvim#rx#reflabel . '\ze\]\[\]',
      \})

let g:linkvim#link#definitions#ref_full = extend(
      \ deepcopy(g:linkvim#link#definitions#reference), {
      \ 'rx': g:linkvim#rx#link_ref_full,
      \ 'rx_url':
      \   '\['    . g:linkvim#rx#reftext   . '\]'
      \ . '\[\zs' . g:linkvim#rx#reflabel . '\ze\]',
      \ 'rx_text':
      \   '\[\zs' . g:linkvim#rx#reftext   . '\ze\]'
      \ . '\['    . g:linkvim#rx#reflabel . '\]',
      \})

let g:linkvim#link#definitions#url = {
      \ 'type': 'url',
      \ 'rx': g:linkvim#rx#url,
      \}

let g:linkvim#link#definitions#cite = {
      \ 'type': 'cite',
      \ 'rx': g:linkvim#rx#link_cite,
      \ 'rx_url': g:linkvim#rx#link_cite_url,
      \ '__scheme': { -> linkvim#link#get_scheme('cite') },
      \}

let g:linkvim#link#definitions#date = {
      \ 'type': 'date',
      \ 'rx': g:linkvim#rx#date,
      \}

let g:linkvim#link#definitions#word = {
      \ 'type' : 'word',
      \ 'rx' : g:linkvim#rx#word,
      \ '__transformer': function('linkvim#link#templates#word'),
      \}


" linkvim#link#definitions#all is an ordered list of definitions used by
" linkvim#link#get() to detect a link at the cursor.
"
" Notice that the order is important! The order between the wiki, md, and org
" definitions is especially tricky! This is because wiki and org links are
" equivalent when they lack a description: [[url]]. Thus, the order specified
" here means wiki.vim will always match [[url]] as a wiki link and never as an
" org link. This is not a problem for links with a description, though, since
" they differ: [[url|description]] vs [[url][description]], respectively.
let g:linkvim#link#definitions#all = [
      \ g:linkvim#link#definitions#wiki,
      \ g:linkvim#link#definitions#adoc_xref_bracket,
      \ g:linkvim#link#definitions#adoc_xref_inline,
      \ g:linkvim#link#definitions#adoc_link,
      \ g:linkvim#link#definitions#md_fig,
      \ g:linkvim#link#definitions#md,
      \ g:linkvim#link#definitions#org,
      \ g:linkvim#link#definitions#ref_target,
      \ g:linkvim#link#definitions#reference,
      \ g:linkvim#link#definitions#ref_collapsed,
      \ g:linkvim#link#definitions#ref_full,
      \ g:linkvim#link#definitions#cite,
      \ g:linkvim#link#definitions#url,
      \ g:linkvim#link#definitions#date,
      \ g:linkvim#link#definitions#word,
      \]

" linkvim#link#definitions#all_real is an ordered list of definitions used by
" linkvim#link#get_all_from_lines() to get all links from a list of lines.
let g:linkvim#link#definitions#all_real = [
      \ g:linkvim#link#definitions#wiki,
      \ g:linkvim#link#definitions#adoc_xref_bracket,
      \ g:linkvim#link#definitions#adoc_xref_inline,
      \ g:linkvim#link#definitions#adoc_link,
      \ g:linkvim#link#definitions#md_fig,
      \ g:linkvim#link#definitions#md,
      \ g:linkvim#link#definitions#org,
      \ g:linkvim#link#definitions#ref_target,
      \ g:linkvim#link#definitions#cite,
      \ g:linkvim#link#definitions#url,
      \] + [
      \ g:linkvim#link#definitions#reference,
      \ g:linkvim#link#definitions#ref_collapsed,
      \ g:linkvim#link#definitions#ref_full,
      \ ] " MODIFIED
