# vim-md-link

`vim-md-link` is a plugin for Vim and Neovim that keeps long URLs out of your
way. It started as a plugin for Markdown documents (hence its name) but can now
handle links in other filetypes as well.

Inline links will be moved to a reference section. For instance, the following
Markdown document:

```md
# Notes

[Vim](https://www.vim.org) and [Neovim](https://neovim.io) are text editors.
```

will be turned into

```md
# Notes

[Vim][0] and [Neovim][1] are text editors.

## Links

[0]: https://www.vim.org
[1]: https://neovim.io
```

## Installation

Use your favorite plugin manager to install this plugin.

For instance, if you use [vim-plug][2]:

```vim
Plug 'qadzek/vim-md-link'
```

## Usage

`vim-md-link` can be used by executing one of the following commands:

```vim
:MdLinkConvertSingle         " Convert the link under the cursor
:MdLinkConvertRange          " Convert all links within a range
:MdLinkConvertAll            " Convert all links in the document
:MdLinkOpen                  " Open a link in the browser
:MdLinkPeek                  " Get a preview of the URL
:MdLinkJump                  " Jump to and from the references
:MdLinkDeleteUnneededRefs    " Delete references that are no longer needed
```

No mappings are built-in to avoid conflicts with your existing key bindings.
The following is an example that you can copy to you `.vimrc`. By default,
`<LocalLeader>` is the backslash key.

```vim
  augroup vim_md_link
    autocmd!
    autocmd Filetype markdown :call MdLinkAddKeyBindings()
  augroup END

  function! MdLinkAddKeyBindings()
    nnoremap <buffer> <silent> <LocalLeader>s   :MdLinkConvertSingle<CR>
    inoremap <buffer> <silent> <C-g>       <Esc>:MdLinkConvertSingleInsert<CR>
    vnoremap <buffer> <silent> <LocalLeader>r   :MdLinkConvertRange<CR>
    nnoremap <buffer> <silent> <LocalLeader>a   :MdLinkConvertAll<CR>
    nnoremap <buffer> <silent> <LocalLeader>o   :MdLinkOpen<CR>
    nnoremap <buffer> <silent> <LocalLeader>p   :MdLinkPeek<CR>
    nnoremap <buffer> <silent> <LocalLeader>j   :MdLinkJump<CR>
    nnoremap <buffer> <silent> <LocalLeader>d   :MdLinkDeleteUnneededRefs<CR>
  endfunction
```

For more details, such as configuration options, run `:help md-link`.

## Extensions

`vim-md-link` was originally designed for Markdown documents (including
[Vimwiki][0]). Even this `README.md` file uses it!

`:help md-link-extensions` shows how this plugin can be extended to other
filetypes, e.g. to `mail` buffers. This means that the following email

```text
Hi John,

I hope this email finds you well. Did you know that Vim was created by Bram
Moolenaar? https://en.wikipedia.org/wiki/Bram_Moolenaar

He released it as charityware, so you are encouraged to make a donation for
children in Uganda. https://vimhelp.org/uganda.txt.html

Best regards,
Jane
```

can be converted to

```text
Hi John,

I hope this email finds you well. Did you know that Vim was created by Bram
Moolenaar? [0]

He released it as charityware, so you are encouraged to make a donation for
children in Uganda. [1]

Best regards,
Jane

Links:

[0]: https://en.wikipedia.org/wiki/Bram_Moolenaar
[1]: https://vimhelp.org/uganda.txt.html
```

The [Wiki][1] contains some snippets provided by users, for instance on how to
extend this plugin to `gitcommit` buffers.

## Misc

Questions, suggestions, comments, feature requests... everything is welcome in
the _Issues_ tab.

If you would like to contribute, see `:help md-link`.

[0]: https://github.com/vimwiki/vimwiki
[1]: https://github.com/qadzek/vim-md-link/wiki
[2]: https://github.com/junegunn/vim-plug
