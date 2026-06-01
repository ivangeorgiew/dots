local M = {}

M.setup = tie("Setup autocmds", function()
  local group = tied.create_augroup("my.main", true)

  tied.for_list("Queue autocmd to create", M.config, function(_, opts)
    opts.group = group
    tied.create_autocmd(opts)
  end)
end, tied.do_nothing)

---@type AutoCmdArgs[]
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
    desc = "Reload file on change",
    event = { "FocusGained", "TermClose", "TermLeave" },
    callback = function(e)
      if tied.check_if_buf_is_file(e.buf) then
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
          { "n", "<C-f>", function() tied.do_keys_in_win(winnr, "<C-f>", true) end, { desc = "Scroll down" } },
          { "n", "<C-b>", function() tied.do_keys_in_win(winnr, "<C-b>", true) end, { desc = "Scroll up" } },
          -- stylua: ignore end
        }

        tied.for_list(
          "Create a floating window keymap",
          maps,
          function(_, map_args)
            map_args[4].buf = 0

            tied.create_map(unpack(map_args))
          end
        )
      end)
    end,
  },
  {
    desc = "Change cursor to last position",
    event = "BufWinEnter",
    callback = function(ev)
      if not tied.check_if_buf_is_file(ev.buf) or vim.fn.line(".") > 1 then
        return
      end

      local prev_line = vim.fn.line([['"]])
      local last_line = vim.fn.line("$")

      if prev_line > 0 and prev_line <= last_line then
        vim.cmd([[silent noautocmd keepjumps normal! g`"zvzz]])
      end
    end,
  },
}

return M
