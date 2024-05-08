# vim-md-link

`vim-md-link` is a plugin for Vim and Neovim that keeps long URLs out of your
way. It supports links in Markdown syntax and plaintext links (e.g. in emails,
in text files etc.)

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

For instance, if you use [vim-plug][0]:

```vim
Plug 'qadzek/vim-md-link'
```

## Usage

By default, this plugin is activated for Markdown, [Vimwiki][1], email and text
files. You can customize the filetypes on which the plugin operates in your
`vimrc`:

```vim
let g:md_link_enabled_filetypes = [ 'markdown', 'gitcommit' ]
```

`vim-md-link` can be used by executing one of the following commands:

| Command                | Key binding       | Description                              |
|------------------------|-------------------|------------------------------------------|
| `:MdLinkConvertSingle` | `LocalLeader` + c | Convert link under cursor                |
|                        | `<C-g>` + c       | Same, but from insert mode               |
| `:MdLinkConvertRange`  | `LocalLeader` + c | Convert links on visually selected lines |
| `:MdLinkConvertAll`    | `LocalLeader` + a | Convert all links in document            |
| `:MdLinkJump`          | `LocalLeader` + j | Jump to and from reference section       |
| `:MdLinkOpen`          | `LocalLeader` + o | Open link in browser                     |
| `:MdLinkPeek`          | `LocalLeader` + p | Show link preview                        |
| `:MdLinkReformat`      | `LocalLeader` + r | Renumber/merge/delete unneeded links     |

No mappings are built-in to avoid conflicts with your existing key bindings.
You can enable the key bindings suggested above by adding this line to your
`vimrc`:

```vim
let g:md_link_use_default_mappings = 1
```

Note that by default, `<LocalLeader>` is the backslash key. Run `:help
md-link-mappings` to view how to change these key bindings.

Read `:help md-link-configuration` to learn how to customize the heading, the
position of the reference section, which lines to skip and more.

The [Wiki][2] contains some snippets submitted by users, showing configuration
for e.g. `gitcommit` buffers.

## Misc

Questions, suggestions, comments, feature requests... everything is welcome in
the _Issues_ tab.

If you would like to contribute, see `:help md-link-contributing`.

[0]: https://github.com/junegunn/vim-plug
[1]: https://github.com/vimwiki/vimwiki
[2]: https://github.com/qadzek/vim-md-link/wiki
