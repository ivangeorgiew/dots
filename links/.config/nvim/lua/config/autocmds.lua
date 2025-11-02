local M = {}

M.config = {
  {
    -- from NvChad
    { "UIEnter", "BufNewFile", "BufReadPost", },
    {
      group = "create user event FilePost",
      callback = function(e)
        local file = vim.api.nvim_buf_get_name(e.buf)
        local buftype = vim.api.nvim_get_option_value("buftype", { buf = e.buf })

        if not vim.g.ui_entered and e.event == "UIEnter" then
          vim.g.ui_entered = true
        end

        if file ~= "" and buftype ~= "nofile" and vim.g.ui_entered then
          vim.api.nvim_exec_autocmds("User", { pattern = "FilePost", modeline = false })
          vim.api.nvim_del_augroup_by_id(e.group)

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

        tied.each_i(qf_maps, "assign buffer to vim keymap", function(k, _)
          qf_maps[k][4].buffer = e.buf
        end)

        tied.apply_maps(qf_maps)
      end
    }
  },
}

M.setup = tie(
  "setup autocmds",
  function()
    tied.each_i(M.config, "queue autocmd to create", function(_, autocmd)
      tied.create_autocmd(unpack(autocmd))
    end)
  end,
  tied.do_nothing
)

return M
