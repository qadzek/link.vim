-- Specify the file types where the plugin should be active.
local ft = { "markdown", "text", "mail", "gitcommit" }

return {
  {
    "qadzek/link.vim",

    desc = "Keep long URLs out of your way",

    enabled = true,

    ft = ft,

    config = function()
      -- Run `:help link-configuration` for more information on the following settings.
      vim.g.link_use_default_mappings = 0
      vim.g.link_heading = "Links:"
      vim.g.link_start_index = 0
      vim.g.link_include_blockquotes = 0
      vim.g.link_disable_internal_links = 0
      vim.g.link_missing_marker = "???"

      -- This `autocmd` ensures the following key bindings are only applied to the specified file types.
      vim.api.nvim_create_autocmd("Filetype", {
        pattern = ft,

        group = vim.api.nvim_create_augroup("LinkVim", { clear = true }),

        callback = function(ev)
          vim.keymap.set(
            "n",
            "<LocalLeader>c",
            "<Plug>(LinkVim-ConvertSingle)",
            { buffer = ev.buf, desc = "Convert single link" }
          )

          vim.keymap.set(
            "i",
            "<C-g>c",
            "<Plug>(LinkVim-ConvertSingleInsert)",
            { buffer = ev.buf, desc = "Convert single link from Insert mode" }
          )

          vim.keymap.set(
            "v",
            "<LocalLeader>c",
            "<plug>(LinkVim-ConvertRange)",
            { buffer = ev.buf, desc = "Convert range of links" }
          )

          vim.keymap.set(
            "n",
            "<LocalLeader>a",
            "<plug>(LinkVim-ConvertAll)",
            { buffer = ev.buf, desc = "Convert all links" }
          )

          vim.keymap.set(
            "n",
            "<LocalLeader>j",
            "<plug>(LinkVim-Jump)",
            { buffer = ev.buf, desc = "Jump between links" }
          )

          vim.keymap.set("n", "<LocalLeader>o", "<plug>(LinkVim-Open)", { buffer = ev.buf, desc = "Open link" })

          vim.keymap.set("n", "<LocalLeader>p", "<plug>(LinkVim-Peek)", { buffer = ev.buf, desc = "Peek link" })

          vim.keymap.set(
            "n",
            "<LocalLeader>r",
            "<plug>(LinkVim-Reformat)",
            { buffer = ev.buf, desc = "Reformat links" }
          )

          vim.keymap.set(
            "n",
            "<LocalLeader>s",
            "<plug>(LinkVim-Show)",
            { buffer = ev.buf, desc = "Show debug info about link" }
          )

          vim.keymap.set(
            "n",
            "<C-p>",
            "<plug>(LinkVim-Prev)",
            { buffer = ev.buf, desc = "Move cursor to previous link" }
          )

          vim.keymap.set("n", "<C-n>", "<plug>(LinkVim-Next)", { buffer = ev.buf, desc = "Move cursor to next link" })
        end,
      })
    end,
  },
}
