local M = {}

M.config = {
  {
    { "FocusGained", "TermClose", "TermLeave" },
    {
      group = "reload file on change",
      callback = function()
        if vim.o.buftype ~= "nofile" then vim.cmd("checktime") end
      end
    }
  },
  {
    "BufEnter",
    {
      group = "overwrite settings",
      callback = function()
        local o = vim.opt

        o.formatoptions = "tcrqnlj"
      end
    }
  },
  {
    "VimResized",
    {
      group = "resize splits on window resize",
      callback = function()
        local current_tab = vim.fn.tabpagenr()

        vim.cmd("tabdo wincmd =")
        vim.cmd("tabnext " .. current_tab)
      end,
    }
  },

  {
    "FileType",
    {
      group = "enable local options in special files",
      pattern = { "gitcommit", "markdown" },
      callback = function()
        local l = vim.opt_local

        l.wrap = true
      end,
    }
  },
  {
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
  },
  {
    "Filetype",
    {
      group = "on quickfix/location lists",
      pattern = "qf", -- matches both quickfix and location lists
      callback = function(e)
        -- move to the bottom of all other windows
        vim.cmd("wincmd J")

        local qf_maps = require("config.keymaps").config.quickfix

        for k, _ in ipairs(qf_maps) do
          qf_maps[k][4].buffer = e.buf
        end

        tied.apply_maps(qf_maps)
      end
    }
  },
}

M.setup = tie(
  "setup autocmds",
  function()
    for _, autocmd in ipairs(M.config) do
      tied.create_autocmd(unpack(autocmd))
    end
  end,
  tied.do_nothing
)

return M
