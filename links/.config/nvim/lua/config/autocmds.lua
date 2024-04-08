local au = require("utils").au

au(
  "reload file on change",
  { "FocusGained", "TermClose", "TermLeave" },
  { command = "checktime" }
)

au(
  "highlight on yank",
  "TextYankPost",
  { callback = function(e) vim.highlight.on_yank() end, }
)

au(
  "resize splits on window resize",
  "VimResized",
  {
    callback = function(e)
      local current_tab = vim.fn.tabpagenr()
      vim.cmd("tabdo wincmd =")
      vim.cmd("tabnext " .. current_tab)
    end,
  }
)

au(
  "wrap and spell in text files",
  "FileType",
  {
    pattern = { "gitcommit", "markdown" },
    callback = function(e)
      vim.opt_local.wrap = true
      vim.opt_local.spell = true
    end,
  }
)

au(
  "set buffer options",
  "BufEnter",
  {
    callback = function(e)
      vim.opt.formatoptions = "tcrqlj" -- formatting options
    end
  }
)
