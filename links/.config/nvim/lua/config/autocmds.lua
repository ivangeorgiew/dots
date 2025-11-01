local M = {}

M.config = {
  {
    -- from nvchad
    { "UIEnter", "BufNewFile", "BufReadPost", },
    {
      group = "FilePost",
      callback = function(e)
        local file = vim.api.nvim_buf_get_name(e.buf)
        local buftype = vim.api.nvim_get_option_value("buftype", { buf = e.buf })

        if not vim.g.ui_entered and e.event == "UIEnter" then
          vim.g.ui_entered = true
        end

        if file ~= "" and buftype ~= "nofile" and vim.g.ui_entered then
          vim.api.nvim_exec_autocmds("User", { pattern = "FilePost", modeline = false })
          vim.api.nvim_del_augroup_by_name("FilePost")

          vim.schedule(function()
            vim.api.nvim_exec_autocmds("FileType", {})

            if vim.g.editorconfig then
              require("editorconfig").config(e.buf)
            end
          end)
        end
      end,
    }
  },
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
    "TextYankPost",
    {
      group = "highlight on yank",
      callback = function() vim.hl.on_yank() end,
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
