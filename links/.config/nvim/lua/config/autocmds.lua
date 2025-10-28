local M = {}

M.setup = tie(
  "setup autocmds",
  function()
    tied.create_autocmd(
      { "FocusGained", "TermClose", "TermLeave" },
      {
        group = "reload file on change",
        callback = function()
          if vim.o.buftype ~= "nofile" then vim.cmd("checktime") end
        end
      }
    )

    tied.create_autocmd(
      "BufEnter",
      {
        group = "overwrite settings",
        callback = function()
          local o = vim.opt

          o.formatoptions = "tcrqnlj"
        end
      }
    )

    tied.create_autocmd(
      "VimResized",
      {
        group = "resize splits on window resize",
        callback = function()
          local current_tab = vim.fn.tabpagenr()

          vim.cmd("tabdo wincmd =")
          vim.cmd("tabnext " .. current_tab)
        end,
      }
    )

    tied.create_autocmd(
      "FileType",
      {
        group = "enable local options in special files",
        pattern = { "gitcommit", "markdown" },
        callback = function()
          local l = vim.opt_local

          l.wrap = true
        end,
      }
    )

    tied.create_autocmd(
      "BufWritePre",
      {
        group = "create directories when saving files",
        callback = function()
          local dir = vim.fn.expand("<afile>:p:h")

          if vim.fn.isdirectory(dir) == 0 then
            vim.fn.mkdir(dir, "p")
          end
        end
      }
    )

    tied.create_autocmd(
      "Filetype",
      {
        group = "on quickfix/location lists",
        pattern = "qf", -- matches both quickfix and location lists
        callback = function(e)
          local buf_nr = e.buf
          local maps = require("config.keymaps").config.quickfix

          for k, _ in ipairs(maps) do
            maps[k][4].buffer = buf_nr
          end

          tied.apply_maps(maps)

          -- move to the bottom of all other windows
          vim.cmd("wincmd J")
        end
      }
    )
  end,
  tied.do_nothing
)

return M
