# vim-md-link

`vim-md-link` is a plugin for Vim/Neovim that keeps long URLs out of your way
in Markdown documents.

In essence, this plugin converts

```md
# Notes

[Vim](https://www.vim.org) and [Neovim](https://neovim.io) are text editors.
```

into

```md
# Notes

[Vim][0] and [Neovim][1] are text editors.

## Links

[0]: https://www.vim.org
[1]: https://neovim.io
```

`vim-md-link` works well with [Vimwiki][0], but is useful for all Markdown
documents containing long URLs. Even this `README.md` file uses it!

## Installation

Use your favorite plugin manager to install this plugin.

For instance, if you use [vim-plug][1]:

```vim
Plug 'qadzek/vim-md-link'
```

## Usage

`vim-md-link` can be used by executing one of the following commands:

```vim
:MdLinkConvertSingle         " Convert the link under the cursor
:MdLinkConvertAll            " Convert all links in the document
:MdLinkJump                  " Jump to and from the references
:MdLinkPeek                  " Get a preview of the URL
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
    nnoremap <buffer> <silent> <LocalLeader>a   :MdLinkConvertAll<CR>
    nnoremap <buffer> <silent> <LocalLeader>j   :MdLinkJump<CR>
    nnoremap <buffer> <silent> <LocalLeader>p   :MdLinkPeek<CR>
    nnoremap <buffer> <silent> <LocalLeader>d   :MdLinkDeleteUnneededRefs<CR>
    inoremap <buffer> <silent> <C-g>       <Esc>:MdLinkConvertSingleInsert<CR>
  endfunction
```

For more details, such as configuration options, run `:help md-link`.

## Misc

Questions, suggestions, comments, feature requests... everything is welcome in
the "Issues" tab.

If you would like to contribute, see `:help md-link`.

[0]: https://github.com/vimwiki/vimwiki
[1]: https://github.com/junegunn/vim-plug
