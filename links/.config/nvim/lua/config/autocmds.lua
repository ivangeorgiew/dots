local M = {}
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
        callback = function(e)
          local buf_nr = e.buf
          local maps = require("config.keymaps").config.quickfix

          for k, v in ipairs(maps) do
            maps[k][4].buffer = buf_nr
          end

          tied.apply_maps(maps)
        end
      }
    )
  end,
  do_nothing
)

return M
