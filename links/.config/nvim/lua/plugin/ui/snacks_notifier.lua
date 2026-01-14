---@module "snacks"
---@type LazyPluginSpec
local M = { "snacks.nvim", opts = { styles = {} } }

---@class snacks.notifier.Config
M.opts.notifier = {
  enabled = true,
  timeout = 3 * 1e3,
  style = "fancy",
  height = { max = 0.5 },
  icons = {
    error = "",
    warn = "",
    info = "",
    debug = "",
    trace = "",
  },
  custom = { show_lsp_progress = true },
}

---@type snacks.win.Config
M.opts.styles.notification_history = {
  height = 0.8,
  width = 0.8,
  minimal = true,
  wo = { conceallevel = 2 },
}

M.opts.notifier.filter = tie(
  "Plugin snacks.notifier -> Filter out messages",
  ---@param notif snacks.notifier.Notif
  function(notif)
    local msgs = {
      "No signature help available",
      "Diagnosing",
    }

    for _, msg in ipairs(msgs) do
      if notif.msg:match(msg) then
        return false
      end
    end

    return true
  end,
  function() return true end
)

---@type KeymapSetArgs[]
M.opts.notifier.custom.maps = {
  {
    "n",
    "<leader>nh",
    function() Snacks.notifier.hide() end,
    { desc = "Notifications Hide" },
  },
  {
    "n",
    "<leader>ns",
    function()
      ---@diagnostic disable-next-line: undefined-field
      if Snacks.config.picker and Snacks.config.picker.enabled then
        Snacks.picker.notifications()
      else
        Snacks.notifier.show_history({
          filter = M.opts.notifier.filter,
          reverse = true,
        })
      end
    end,
    { desc = "Notifications Show" },
  },
}

M.opts.notifier.custom.config = tie(
  "Plugin snacks.notifier -> config",
  ---@param opts snacks.Config
  function(_, opts)
    vim.validate("opts", opts, "table")

    if not opts.notifier.custom.show_lsp_progress then
      return
    end

    tied.create_autocmd({
      desc = "Show LSP progress",
      event = "LspProgress",
      group = tied.create_augroup("my.snacks.notifier.lsp_spinner", true),
      callback = function(ev)
        vim.notify(vim.lsp.status(), vim.log.levels.INFO, {
          id = "lsp_progress",
          title = "LSP Progress",
          opts = tie("Change LSP progress notification icon", function(notif)
            -- stylua: ignore
            local spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }

            notif.icon = ev.data.params.value.kind == "end" and ""
              or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]
          end, tied.do_nothing),
        })
      end,
    })
  end,
  tied.do_nothing
)

return M
