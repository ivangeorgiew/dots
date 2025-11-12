---@type LazyPluginSpec|LazyPluginSpec[]
return {
  {
    "ivangeorgiew/which-key.nvim",
    -- dev = true,
    event = "VeryLazy",
    dependencies = { "nvim-mini/mini.icons", "nvim-tree/nvim-web-devicons" },
    config = tie(
      "Plugin which-key -> config",
      function(_, opts)
        local wk = require("which-key")

        -- which-key doesn't show some keymaps unless timeoutlen is low enough
        -- but my fork fixes this issue, so can safely comment out
        -- vim.opt.timeoutlen = 150

        wk.setup(opts)

        tied.apply_maps({
          { "n", "<leader>?", function() wk.show({ global = false }) end, { desc = "Buffer Keymaps (which-key)", } },
        })
      end,
      tied.do_nothing
    ),
    -- :h which-key.nvim.txt
    opts = {
      preset = "helix",
      delay = 200,
      icons = { mappings = false }, -- remove icons
      expand = tie(
        "Plugin which-key -> expand",
        -- expand all nodes without a description
        function(node) return not node.desc end,
        function() return false end
      ),
      triggers = {
         -- Can be removed to have only manual triggers
        { "<auto>", mode = "nixsotc" },
        -- Add manual triggers below
        -- { "<leader>", mode = { "n", "v" } },
      },
      defer = tie(
        "Plugin which-key -> defer",
        ---@param _ { mode: string, operator: string }
        function(_)
          -- If it returns true, don't show which-key for
          -- the mode or operator until an additional key is pressed
          return (
            -- All custom operators actually map to `g@`
            -- vim.list_contains({ "d", "y" }, ctx.operator) or
            -- Not only visual, but any map mode (n, o, c, etc)
            -- vim.list_contains({ "<C-V>", "V", "v" }, ctx.mode) or
            false
          )
        end,
        function() return false end
      ),
      spec = {
        {
          mode = "n",
          { "<localleader>", group = "Local leader", },
          { "<leader>q", group = "Quit", },
          { "<leader>t", group = "Toggle", },
          { "<leader>%", group = "Whole file", },
          { "<leader>j", group = "Prev", proxy = "[", },
          { "<leader>k", group = "Next", proxy = "]", },
          { "[", group = "Prev", },
          { "]", group = "Next", },
          { "D", group = "Cut", op = true },
          { "gc", group = "Toggle comment", op = true },
          { "g@", desc = "Operator-pending mode" },
        },
        {
          mode = "v",
          { "<leader>", group = "Leader", }
        },
        {
          mode = { "n", "v" },
          { "gx", desc = "Open with system app" },
        },
      },
    },
  },
}
