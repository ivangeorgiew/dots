local M = {}

M.setup = tie("Setup autocmds", function()
  local group = tied.create_augroup("my.main", true)

  tied.each_i("Queue autocmd to create", M.config, function(_, opts)
    opts.group = group
    tied.create_autocmd(opts)
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
        -- with wrong bufnr being provided
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

      ---@type KeymapSetArgs[]
      local maps = {
        -- stylua: ignore start
        { "n", "<C-r>", "<cmd>Replace<cr>", { desc = "Replace text in files" } },
        { "n", "<C-t>", "<C-w><CR><C-w>T", { desc = "Open list item in new tab" } },
        { "n", "<C-s>", "<C-w><CR>", { desc = "Open list item in hor. split" } },
        { "n", "<C-v>", "<C-w><CR>:windo lclose<cr><C-w>L:lopen<cr><cr>", { desc = "Open list item in vert. split" } },
        -- stylua: ignore end
      }

      tied.each_i("Create quickfix/loc list keymap", maps, function(_, map_opts)
        map_opts[4].buffer = e.buf
        tied.create_map(unpack(map_opts))
      end)
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
          { "n", "<C-f>", function() tied.do_keys_in_win(winnr, "<C-f>", true) end, { desc = "Scroll down" } },
          { "n", "<C-b>", function() tied.do_keys_in_win(winnr, "<C-b>", true) end, { desc = "Scroll up" } },
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
