local M = {}

---@type MyAutocmdOpts[]
M.config = {
  {
    desc = "Create user event FilePost",
    event = { "UIEnter", "BufNewFile", "BufReadPost", },
    callback = function(e)
      local file = vim.api.nvim_buf_get_name(e.buf)
      local buftype = vim.bo[e.buf].buftype

      if not vim.g.ui_entered and e.event == "UIEnter" then
        vim.g.ui_entered = true
      end

      if file ~= "" and buftype ~= "nofile" and vim.g.ui_entered then
        vim.api.nvim_exec_autocmds("User", { pattern = "FilePost", modeline = false })

        vim.schedule(tie(
          "After FilePost event",
          function()
            vim.api.nvim_exec_autocmds("FileType", {})

            if vim.g.editorconfig then
              require("editorconfig").config(e.buf)
            end
          end,
          tied.do_nothing
        ))

        return true
      end
    end,
  },
  {
    desc = "Reload file on change",
    event = { "FocusGained", "TermClose", "TermLeave" },
    callback = function(e)
      if vim.bo[e.buf].buftype ~= "nofile" then vim.cmd("checktime") end
    end
  },
  {
    desc = "Highlight on yank",
    event = "TextYankPost",
    callback = function() vim.hl.on_yank() end,
  },
  {
    desc = "Resize splits on window resize",
    event = "VimResized",
    callback = function()
      local current_tab = vim.fn.tabpagenr()

      vim.cmd("tabdo wincmd =")
      vim.cmd("tabnext " .. current_tab)
    end,
  },
  {
    desc = "Set local vim options",
    event = "FileType",
    callback = function(e)
      local l = vim.opt_local
      local should_wrap = vim.list_contains(
        { "gitcommit", "markdown" },
        e.match
      )

      l.formatoptions = "tcrqnlj"

      if should_wrap then l.wrap = true end
    end,
  },
  {
    desc = "Create directories when saving files",
    event = "BufWritePre",
    callback = function()
      local dir = vim.fn.expand("<afile>:p:h")

      if vim.fn.isdirectory(dir) == 0 then
        vim.fn.mkdir(dir, "p")
      end
    end
  },
  {
    desc = "On quickfix/location lists",
    event = "Filetype",
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
  },
}

M.setup = tie(
  "Setup autocmds",
  function()
    local group = tied.create_augroup("my.main", true)

    tied.each_i(M.config, "Queue autocmd to create", function(_, opts)
      opts.group = group
      tied.create_autocmd(opts)
    end)
  end,
  tied.do_nothing
)

return M
