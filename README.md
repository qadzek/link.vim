# link.vim

`link.vim` is a plugin for Vim and Neovim that keeps long URLs out of your way.
It supports links in Markdown syntax and plaintext links (e.g. in emails, in
text files etc.)

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

Watch the screencast for a quick overview of the plugin:

https://github.com/qadzek/link.vim/assets/84473512/7be44a63-677c-4477-8e30-fa6090e3c6d9

## Installation

Use your favorite plugin manager to install this plugin. For instance, if you use [vim-plug][0]:

```vim
Plug 'qadzek/vim.link'
```

## Usage

By default, this plugin is activated for Markdown, [Vimwiki][1], email and text
files. You can customize the filetypes on which the plugin operates in your
`vimrc`:

```vim
let g:link_enabled_filetypes = [ 'markdown', 'gitcommit' ]
```

`link.vim` can be used by executing one of the following commands:

| Command              | Key binding       | Description                              |
|----------------------|-------------------|------------------------------------------|
| `:LinkConvertSingle` | `LocalLeader` + c | Convert link under cursor                |
|                      | `<C-g>` + c       | Same, but from insert mode               |
| `:LinkConvertRange`  | `LocalLeader` + c | Convert links on visually selected lines |
| `:LinkConvertAll`    | `LocalLeader` + a | Convert all links in document            |
| `:LinkJump`          | `LocalLeader` + j | Jump to and from reference section       |
| `:LinkOpen`          | `LocalLeader` + o | Open link in browser                     |
| `:LinkPeek`          | `LocalLeader` + p | Show link preview                        |
| `:LinkReformat`      | `LocalLeader` + r | Renumber/merge/delete unneeded links     |

No mappings are built-in to avoid conflicts with your existing key bindings.
You can enable the key bindings suggested above by adding this line to your
`vimrc`:

```vim
let g:link_use_default_mappings = 1
```

Note that by default, `<LocalLeader>` is the backslash key. Run `:help
link-mappings` to view how to change these key bindings.

Read `:help link-configuration` to learn how to customize the heading, the
position of the reference section, which lines to skip and more.

The [Wiki][2] contains some snippets submitted by users, showing configuration
for e.g. `gitcommit` buffers.

## Misc

Questions, suggestions, comments, feature requests... everything is welcome in
the _Issues_ tab.

If you would like to contribute, see `:help link-contributing`.

[0]: https://github.com/junegunn/vim-plug
[1]: https://github.com/vimwiki/vimwiki
[2]: https://github.com/qadzek/link.vim/wiki
