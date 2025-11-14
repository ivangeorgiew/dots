local M = {}

M.setup = tie(
  "Setup autocmds",
  function()
    local group = tied.create_augroup("my.main", true)

    tied.each_i(M.config, "Queue autocmd to create", function(_, opts)
      opts.group = group
      tied.create_autocmd(opts)
    end)

    local ctrlv_code = vim.api.nvim_replace_termcodes("<C-V>", true, true, true)

    -- Can't be put in an autocmd, so use vim.on_key instead
    vim.g.ns_clear_hls = vim.on_key(
      tie(
        "Clear hlsearch",
        function(_, key)
          local mode = vim.api.nvim_get_mode().mode:gsub(ctrlv_code, "v"):lower()

          if (
            vim.o.hlsearch and
            mode:match("^[niv]$") and
            not key:match("^[nN]?$")
          ) then
            vim.cmd("nohls")
          end
        end,
        function() vim.on_key(nil, vim.g.ns_clear_hls) end
      ),
      vim.api.nvim_create_namespace("clear_hls")
    )

  end,
  tied.do_nothing
)

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
  {
    desc = "Remove ending whitespace",
    event = "BufWritePre",
    callback = function()
      vim.cmd("normal! ms")
      vim.cmd([[silent! %s/\s\+$//]])
      vim.cmd("normal! `s")
    end
  },
  {
    desc = "Auto-save vim session",
    event = "VimLeavePre",
    callback = function() tied.load_session(false) end,
  },
  {
    desc = "Auto-load vim session",
    event = "UIEnter",
    once = true,
    nested = true,
    callback = function()
      if vim.env.NVIM_RELOADED then
        tied.load_session(true)
      end
    end,
  },
}

return M
