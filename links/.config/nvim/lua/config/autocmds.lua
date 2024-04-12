local create_au = require("utils").create_au

create_au(
  "reload file on change",
  { "FocusGained", "TermClose", "TermLeave" },
  { command = "checktime" }
)

create_au(
  "highlight on yank",
  "TextYankPost",
  { callback = function(e) vim.highlight.on_yank() end, }
)

create_au(
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

create_au(
  "wrap and spell in text files",
  "FileType",
  {
    pattern = { "gitcommit", "markdown" },
    callback = function(e)
      local l = vim.opt_local

      l.wrap = true
      l.spell = true
    end,
  }
)

create_au(
  "set buffer options",
  "BufEnter",
  {
    callback = function(e)
      vim.opt.formatoptions = "tcrqlj" -- formatting options
    end
  }
)
