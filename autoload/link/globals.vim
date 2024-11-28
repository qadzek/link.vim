" Default values, can be overridden by vimrc
let g:link#globals#defaults = {
  \ 'filetypes': [ 'markdown', 'vimwiki', 'mail', 'text' ],
  \ 'heading_markdown': '## Links',
  \ 'heading_other': 'Links:',
  \ 'start_index': 0,
\ }

" Error messages
let g:link#globals#errors = {
  \ 'no_inline_link':
    \ 'No inline link found on this line in the format of "[foo](http://bar.com)" (Markdown) or "http://bar.com" (other)',
  \ 'no_reference_link':
    \ 'No reference link found on this line in the format of "[foo][3]" (Markdown) or "[3]" (other)',
  \ 'no_ref_def':
    \ 'No link reference definition in the format of "[3]: ..." found on this line',
  \ 'no_label_ref_section':
    \ 'The following label was not found in the reference section:',
  \ 'no_label_body':
    \ 'The following label was not found in the document body:',
  \ 'not_from_ref':
    \ 'This action is only possible from the document body, not from the reference section',
  \ 'no_valid_url':
    \ 'Not a valid URL:',
  \ 'open_in_browser_failed':
    \ 'Failed to open the URL, because of this error:',
  \ 'no_position_pattern':
    \ 'Failed to detect pattern to position reference section:',
  \ 'no_ref_section':
    \ 'No reference section was found',
\ }

let s:re_ref_def_pre = '\v^\s*\[\zs'
let s:re_ref_def_suf = '\ze\]:\s+'

let g:link#globals#re = {
  \ 'ref_def_pre': s:re_ref_def_pre,
  \ 'ref_def_suf': s:re_ref_def_suf,
  \ 'ref_def': s:re_ref_def_pre .. '\d+' .. s:re_ref_def_suf,
  \ 'protocol': '[a-zA-Z][a-zA-Z0-9.-]{1,9}:\/\/'
\ }
