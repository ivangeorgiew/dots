-- TODO: enable dashboard

---@module "snacks"
---@type PluginSpec
local M = {
  "ivangeorgiew/snacks.nvim",
  lazy = false,
  opts = {},
}

M.opts.styles = {
  ---@type snacks.win.Config
  notification_history = {
    height = 0.8,
    width = 0.8,
    minimal = true,
    wo = { conceallevel = 2 },
  },
}

---@class snacks.bigfile.Config
M.opts.bigfile = {
  enabled = true,
  notify = true,
  size = 1024 * 1024 * 1.5,
  line_length = 1000,
}

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
  filter = tie(
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
  ),
  custom = { show_lsp_progress = false },
}

M.opts.notifier.custom.which_key = {
  { "<leader>n", mode = "n", group = "Notifications" },
}

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
      Snacks.notifier.show_history({
        filter = M.opts.notifier.filter,
        reverse = true,
      })
    end,
    { desc = "Notifications Show" },
  },
}

M.opts.notifier.custom.config = tie(
  "Plugin snacks.notifier -> config",
  ---@param opts snacks.Config
  function(_, opts)
    vim.validate("opts", opts, "table")

    if opts.notifier.custom.show_lsp_progress then
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
    end
  end,
  tied.do_nothing
)

M.config = tie("Plugin snacks -> config", function(_, opts)
  require("snacks").setup(opts)

  tied.for_table(
    "Plugin snacks -> Traverse modules",
    opts,
    function(module_name, module)
      if not module.enabled then
        return
      end

      local desc_start = ("Plugin snacks.%s -> "):format(module_name)

      tied.do_block(desc_start .. "Custom config", function()
        if vim.tbl_get(module, "custom", "config") then
          module.custom.config(_, opts)
        end
      end)

      tied.do_block(desc_start .. "Create keymaps", function()
        if vim.tbl_get(module, "custom", "maps") then
          tied.for_list(
            "Plugin snacks -> Create a keymap",
            module.custom.maps,
            function(_, map_args) tied.create_map(unpack(map_args)) end
          )
        end
      end)

      if vim.tbl_get(module, "custom", "which_key") then
        tied.on_plugin_load(
          "which-key.nvim",
          desc_start .. "Modify which-key mappings",
          function() require("which-key").add(module.custom.which_key) end
        )
      end
    end
  )
end, tied.do_nothing)

return M
