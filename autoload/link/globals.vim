" Default values, can be overridden by vimrc
let g:link#globals#defaults = {
  \ 'filetypes': [ 'markdown', 'vimwiki', 'mail', 'text' ],
  \ 'heading_markdown': '## Links',
  \ 'heading_other': 'Links:',
  \ 'start_index': 0,
\ }

" Error messages
let g:link#globals#err_msg = {
  \ 'no_heading':
  \ 'No heading found',
  \ 'no_inline_link':
  \ 'No inline link found on this line in the format of "[foo](http://bar.com)" (Markdown) or "http://bar.com" (other)',
  \ 'no_link_ref_definition':
  \ 'No link reference definition in the format of "[3]: ..." found on this line',
  \ 'no_label_ref_section':
  \ 'The following label was not found in the reference section: ',
  \ 'no_label_body':
  \ 'The following label was not found in the document body: ',
  \ 'not_from_ref':
  \ 'This action is only possible from the document body, not from the reference section',
  \ 'no_reference_link':
  \ 'No reference link found on this line in the format of "[foo][3]" (Markdown) or "[3]" (other)',
  \ 'no_valid_url':
  \ 'Not a valid URL',
  \ 'open_in_browser_failed':
  \ 'Failed to open the URL, because of this error: ',
  \ 'no_heading_pattern':
  \ 'Failed to detect heading pattern: ',
\ }
