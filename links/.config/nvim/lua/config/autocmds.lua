local M = {}
local create_autocmd = tied.create_autocmd

M.setup = tie(
  "setup autocmds",
  function()
    create_autocmd(
      "augroup -> reload file on change",
      { "FocusGained", "TermClose", "TermLeave" },
      {
        callback = function()
          if vim.o.buftype ~= "nofile" then vim.cmd("checktime") end
        end
      }
    )

    create_autocmd(
      "augroup -> delete ending space",
      { "BufWritePre", "BufReadPost" },
      {
        callback = function()
          vim.cmd("normal! ms")
          vim.cmd([[silent! %s/\s\+$//]])
          vim.cmd("normal! `s")
        end,
      }
    )

    create_autocmd(
      "augroup -> overwrite settings",
      "BufEnter",
      {
        callback = function()
          local o = vim.opt

          o.formatoptions = "tcrqnlj" -- formatting options
        end
      }
    )

    create_autocmd(
      "augroup -> resize splits on window resize",
      "VimResized",
      {
        callback = function()
          local current_tab = vim.fn.tabpagenr()

          vim.cmd("tabdo wincmd =")
          vim.cmd("tabnext " .. current_tab)
        end,
      }
    )

    create_autocmd(
      "augroup -> enable local options in special files",
      "FileType",
      {
        pattern = { "gitcommit", "markdown" },
        callback = function()
          local l = vim.opt_local

          l.wrap = true
        end,
      }
    )

    create_autocmd(
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

    create_autocmd(
      "augroup -> quickfix/location lists",
      "Filetype",
      {
        pattern = "qf", -- matches both quickfix and location lists
        callback = function(e)
          local buf_nr = e.buf
          local maps = require("config.keymaps").config.quickfix

          for k, _ in ipairs(maps) do
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
