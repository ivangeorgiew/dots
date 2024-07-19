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
      vim.opt.formatoptions = "tcrqnlj" -- formatting options
    end
  }
)

create_au(
  "go to last cursor position",
  "BufReadPost",
  {
    callback = function(e)
      local bn = e.buf -- buffer number
      local is_excluded_ft = vim.tbl_contains(
        { "gitcommit", "gitrebase", "svn", "hgcommit" },
        vim.bo[bn].filetype
      )
      local is_excluded_bt = vim.tbl_contains(
        { "quickfix", "nofile", "help" },
        vim.bo[bn].buftype
      )

      if vim.b[bn].last_loc or is_excluded_ft or is_excluded_bt then
        return
      end

      local mark = vim.api.nvim_buf_get_mark(bn, '"')
      local lcount = vim.api.nvim_buf_line_count(bn)

      if mark[1] > 0 and mark[1] <= lcount then
        -- also open fold and recenter
        vim.b[bn].last_loc = pcall(vim.cmd, [[normal! g`"zvzz]])
      end
    end
  }
)
