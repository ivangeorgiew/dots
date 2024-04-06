local au = require("utils").au

au(
  "reload_file_on_change",
  { "FocusGained", "TermClose", "TermLeave" },
  { command = "checktime" }
)

au(
  "highlight_on_yank",
  "TextYankPost",
  { callback = function() vim.highlight.on_yank() end, }
)

au(
  "resize_splits_on_window_resize",
  "VimResized",
  {
    callback = function()
      local current_tab = vim.fn.tabpagenr()
      vim.cmd("tabdo wincmd =")
      vim.cmd("tabnext " .. current_tab)
    end,
  }
)

au(
  "wrap_and_spell_in_text_files",
  "FileType",
  {
    pattern = { "gitcommit", "markdown" },
    callback = function()
      vim.opt_local.wrap = true
      vim.opt_local.spell = true
    end,
  }
)

au(
  "set_buffer_options",
  "BufEnter",
  {
    callback = function()
      local o = vim.opt

      o.formatoptions = "tcrqlj" -- formatting options
    end
  }
)
