-- TODO: fix indentation after replace and paste

--- @type MyLazySpec
local M = {
  -- Adds replace and exchange commands
  "gbprod/substitute.nvim",
  event = tied.LazyEvent,
  -- https://github.com/gbprod/substitute.nvim?tab=readme-ov-file
  opts = {
    highlight_substituted_text = { enabled = false },
    preserve_cursor_position = false,
  },
}

M.config = tie("Plugin substitute -> config", function(_, opts)
  local subs = require("substitute")

  subs.setup(opts)

  tied.do_block("Plugin substitute -> Setup keymaps", function()
    local exch = require("substitute.exchange")
    local r = "r" -- replace key
    local x = "x" -- exchange key

    ---@type KeymapSetArgs[]
    local maps = {
      { "n", r, subs.operator, { desc = "Replace" } },
      { "x", r, subs.visual, { desc = "Replace" } },
      { "n", r .. r, subs.line, { desc = "Replace line" } },

      { "n", x, exch.operator, { desc = "Exchange" } },
      { "x", x, exch.visual, { desc = "Exchange" } },
      { "n", x .. x, exch.line, { desc = "Exchange line" } },
      { "n", x:upper(), exch.cancel, { desc = "Exchange cancel" } },
    }

    tied.each_i(
      "Plugin substitute -> Create keymap",
      maps,
      function(_, map_opts) tied.create_map(unpack(map_opts)) end
    )

    tied.on_plugin_load(
      "which-key.nvim",
      "Plugin substitute -> Modify which-key mappings",
      function()
        require("which-key").add({
          mode = { "n" },
          { r, group = "Replace", op = true },
          { x, group = "Exchange", op = true },
        })
      end
    )
  end)
end, tied.do_nothing)

return M
