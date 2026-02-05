# link.vim

`link.vim` is a plugin for Vim and Neovim that keeps long URLs out of your way.
It moves URLs to a reference section, so you can focus on the content of your
document.

Links in Markdown syntax and plaintext links (e.g. in emails, in text files
etc.) are supported.

For instance, the following document:

```md
[Vim](https://www.vim.org) and Neovim https://neovim.io are text editors.
```

will be turned into

```md
[Vim][0] and Neovim [1] are text editors.

Links:

[0]: https://www.vim.org
[1]: https://neovim.io
```

Watch the screencast for a quick overview of the plugin:

https://github.com/qadzek/link.vim/assets/84473512/7be44a63-677c-4477-8e30-fa6090e3c6d9

## Installation

Use your favorite plugin manager to install this plugin.

If you use [vim-plug][0]:

```vim
Plug 'qadzek/link.vim'
```

If you use [lazy.nvim][1], see the example [spec](./lazy_nvim_spec_example.lua)
file, or just add the following to your list of plugins:

```lua
{ "qadzek/link.vim" }
```

If you use a Debian-based Linux distribution, this plugin might be available in
its [repositories][2]:

```sh
apt install vim-link-vim
```

## Usage

`link.vim` can be used by executing one of the following commands:

| Command              | Key binding       | Description                              |
|----------------------|-------------------|------------------------------------------|
| `:LinkConvertSingle` | `LocalLeader` + c | Convert one link on current line         |
|                      | `<C-g>` + c       | Same, but from insert mode               |
| `:LinkConvertRange`  | `LocalLeader` + c | Convert links on visually selected lines |
| `:LinkConvertAll`    | `LocalLeader` + a | Convert all links in document            |
| `:LinkJump`          | `LocalLeader` + j | Jump to and from reference section       |
| `:LinkOpen`          | `LocalLeader` + o | Open link in browser                     |
| `:LinkPeek`          | `LocalLeader` + p | Show link preview                        |
| `:LinkReformat`      | `LocalLeader` + r | Renumber/merge/delete unneeded links     |
| `:LinkPrev`          | `<C-p>`           | Move cursor to previous link             |
| `:LinkNext`          | `<C-n>`           | Move cursor to next link                 |

No mappings are built-in to avoid conflicts with your existing key bindings.
You can quickly try out the key bindings suggested above by adding this line to
your `vimrc`, _before_ your plugin manager initializes:

```vim
let g:link_use_default_mappings = 1
```

Note that by default, `<LocalLeader>` is the backslash key. Run `:help
link-mappings` to view how to change these key bindings.

Read `:help link-configuration` to learn how to customize or disable the
heading, the position of the reference section, which lines to skip and more.

## Misc

Questions, suggestions, comments, feature requests... everything is welcome in
the _Issues_ tab.

While this plugin was originally written from scratch, in `v2` it has been
rewritten based on the excellent [wiki.vim][3] plugin. Make sure to give it a
try, it's a great tool for writing and maintaining a personal wiki.

If you would like to contribute, see `:help link-contributing`. This plugin uses
the [Vint][4] linter and the [Vader][5] test framework.

[0]: https://github.com/junegunn/vim-plug
[1]: https://github.com/folke/lazy.nvim
[2]: https://repology.org/project/vim-link-vim/versions
[3]: https://github.com/lervag/wiki.vim
[4]: https://github.com/Vimjas/vint
[5]: https://github.com/junegunn/vader.vim
