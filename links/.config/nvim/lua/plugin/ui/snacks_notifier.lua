---@type LazyPluginSpec
local M = { "snacks.nvim", opts = { styles = {} } }

---@type snacks.win.Config
M.opts.styles.notification_history = {
  height = 0.8,
  width = 0.8,
  minimal = true,
  wo = { conceallevel = 2 },
}

---@type snacks.notifier.Config
M.opts.notifier = {
  enabled = true,
  timeout = 3 * 1e3,
  style = "fancy",
  height = { max = 0.3 },
  icons = {
    error = "",
    warn = "",
    info = "",
    debug = "",
    trace = "",
  },
  custom = {
    ---@type KeymapSetArgs[]
    maps = {
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
            Snacks.notifier.show_history()
          end
        end,
        { desc = "Notifications Show" },
      },
    },
  },
}

return M
