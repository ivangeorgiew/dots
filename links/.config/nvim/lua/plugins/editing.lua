return {
  {
    "gbprod/substitute.nvim",
    event = "VeryLazy",
    -- https://github.com/gbprod/substitute.nvim?tab=readme-ov-file
    config = tie(
      "plugin substitute -> config",
      function(_, opts)
        local subs = require("substitute")
        local exch = require("substitute.exchange")

        local r = "r" -- replace key
        local x = "x" -- exchange key

        subs.setup(opts)
        tied.apply_maps({
          { "n", r, subs.operator, { desc = "Replace" } },
          { "x", r, subs.visual, { desc = "Replace" } },
          { "n", r..r, subs.line, { desc = "Replace Line" } },

          { "n", x, exch.operator, { desc = "Exchange" } },
          { "x", x, exch.visual, { desc = "Exchange" } },
          { "n", x..x, exch.line, { desc = "Exchange Line" } },
          { "n", x:upper(), exch.cancel, { desc = "Exchange cancel" } },
        })
        tied.on_plugin_load("which-key.nvim", function()
          require("which-key").add({
            mode = "n",
            { r, group = "replace", op = true },
            { x, group = "exchange", op = true },
          })
        end)
      end,
      do_nothing
    ),
    opts = {
      highlight_substituted_text = { enabled = false, },
      preserve_cursor_position = false,
    },
  },
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    -- :h nvim-autopairs-default-values
    opts = {},
  },
}
