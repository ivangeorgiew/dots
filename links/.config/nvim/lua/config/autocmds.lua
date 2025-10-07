local M = {}
local maps_config = require("config.keymaps").config
local create_au = tied.create_au

M.setup = tie(
  "setup autocmds",
  function()
    create_au(
      "augroup -> reload file on change",
      { "FocusGained", "TermClose", "TermLeave" },
      {
        callback = function()
          if vim.o.buftype ~= "nofile" then vim.cmd("checktime") end
        end
      }
    )

    create_au(
      "augroup -> highlight on yank",
      "TextYankPost",
      { callback = function(e) vim.hl.on_yank() end, }
    )

    create_au(
      "augroup -> delete ending space",
      { "BufWritePre", "BufReadPost" },
      {
        callback = function(e)
          vim.cmd("normal! ms")
          vim.cmd([[silent! %s/\s\+$//]])
          vim.cmd("normal! `s")
        end,
      }
    )

    create_au(
      "augroup -> overwrite settings",
      "BufEnter",
      {
        callback = function(e)
          local o = vim.opt

          o.formatoptions = "tcrqnlj" -- formatting options
        end
      }
    )

    create_au(
      "augroup -> resize splits on window resize",
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
      "augroup -> enable local options in special files",
      "FileType",
      {
        pattern = { "gitcommit", "markdown" },
        callback = function(e)
          local l = vim.opt_local

          l.wrap = true
        end,
      }
    )

    create_au(
      "augroup -> go to last cursor position",
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
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.b[bn].last_loc = pcall(vim.cmd, [[normal! g`"zvzz]])
          end
        end
      }
    )

    create_au(
      "augroup -> create directories when saving files",
      "BufWritePre",
      {
        callback = function()
          local dir = vim.fn.expand("<afile>:p:h")

          if vim.fn.isdirectory(dir) == 0 then
            vim.fn.mkdir(dir, "p")
          end
        end
      }
    )

    create_au(
      "augroup -> quickfix/location lists",
      "Filetype",
      {
        pattern = "qf", -- matches both quickfix and location lists
        callback = function(e) maps_config.quickfix(e) end
      }
    )
  end,
  do_nothing
)

return M
