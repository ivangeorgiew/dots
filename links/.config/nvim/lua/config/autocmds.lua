local M = {}

M.setup = tie("Setup autocmds", function()
  tied.do_block("Create autocmds", function()
    local group = tied.create_augroup("my.main", true)

    tied.each_i("Queue autocmd to create", M.config, function(_, opts)
      opts.group = group
      tied.create_autocmd(opts)
    end)
  end)

  tied.do_block("Auto-clear hlsearch", function()
    local ctrlv_code = vim.api.nvim_replace_termcodes("<C-V>", true, true, true)

    -- Can't be put in an autocmd, so use vim.on_key instead
    vim.g.ns_clear_hls = vim.on_key(
      tie("Clear hlsearch", function(_, key)
        local mode = vim.api.nvim_get_mode().mode:gsub(ctrlv_code, "v"):lower()

        if
          vim.o.hlsearch
          and mode:match("^[niv]$")
          and not key:match("^[nN]?$")
        then
          vim.cmd("nohls")
        end
      end, function() vim.on_key(nil, vim.g.ns_clear_hls) end),

      vim.api.nvim_create_namespace("clear_hls")
    )
  end)
end, tied.do_nothing)

---@type MyAutocmdOpts[]
M.config = {
  {
    desc = "Auto-save vim session",
    event = "VimLeavePre",
    callback = function() tied.manage_session(false) end,
  },
  {
    desc = "Auto-load vim session",
    event = "UIEnter",
    once = true,
    nested = true,
    callback = function()
      if vim.env.NVIM_RELOADED then
        tied.manage_session(true)
      end
    end,
  },
  {
    desc = "Create user event FilePost",
    event = { "UIEnter", "BufNewFile", "BufReadPost" },
    callback = function(e)
      if not vim.g.ui_entered and e.event == "UIEnter" then
        vim.g.ui_entered = true
      end

      if vim.g.ui_entered and tied.check_if_buf_is_file(e.buf) then
        vim.api.nvim_exec_autocmds("User", {
          pattern = "FilePost",
          modeline = false,
        })

        -- Do not schedule/defer or there can be issues
        vim.api.nvim_exec_autocmds(
          "FileType",
          { buffer = e.buf, modeline = false }
        )

        if vim.g.editorconfig then
          require("editorconfig").config(e.buf)
        end

        return true
      end
    end,
  },
  {
    desc = "Reload file on change",
    event = { "FocusGained", "TermClose", "TermLeave" },
    callback = function(e)
      if vim.bo[e.buf].buftype ~= "nofile" then
        vim.cmd("checktime")
      end
    end,
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
      local should_wrap =
        vim.list_contains({ "gitcommit", "markdown" }, e.match)

      l.formatoptions = "tcrqnlj"

      if should_wrap then
        l.wrap = true
      end
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
    end,
  },
  {
    desc = "On quickfix/location lists",
    event = "Filetype",
    pattern = "qf", -- matches both quickfix and location lists
    callback = function(e)
      -- move to the bottom of all other windows
      vim.cmd("wincmd J")

      tied.each_i(
        "Create quickfix/loc list keymap",
        require("config.keymaps").config.quickfix,
        function(_, map_opts)
          map_opts[4].buffer = e.buf
          tied.create_map(unpack(map_opts))
        end
      )
    end,
  },
  {
    desc = "Remove ending whitespace",
    event = "BufWritePre",
    callback = function()
      vim.cmd("normal! ms")
      vim.cmd([[silent! %s/\s\+$//]])
      vim.cmd("normal! g`s")
    end,
  },
  {
    desc = "Set float window settings",
    event = "WinNew",
    callback = function()
      local winnr = vim.api.nvim_get_current_win()
      local win_config = vim.api.nvim_win_get_config(winnr)
      local is_float = win_config.relative ~= ""

      if not is_float then
        return
      end

      tied.do_block("Create floating window keymaps", function()
        ---@type KeymapSetArgs[]
        local maps = {
          -- stylua: ignore start
          -- NOTE: Close with <C-e>
          { "n", "<C-Space>", function() pcall(vim.api.nvim_set_current_win, winnr) end, { desc = "Enter floating window" } },
          { "n", "<C-f>", function() tied.keys_in_win(winnr, "<C-f>", true) end, { desc = "Scroll down" } },
          { "n", "<C-b>", function() tied.keys_in_win(winnr, "<C-b>", true) end, { desc = "Scroll up" } },
          -- stylua: ignore end
        }

        tied.each_i(
          "Create a floating window keymap",
          maps,
          function(_, map_opts)
            map_opts[4].buffer = true

            tied.create_map(unpack(map_opts))
          end
        )
      end)
    end,
  },
}

return M
