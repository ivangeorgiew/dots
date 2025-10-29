return {
  {
    "ivangeorgiew/which-key.nvim",
    -- dev = true,
    event = "VeryLazy",
    dependencies = { "nvim-mini/mini.icons", "nvim-tree/nvim-web-devicons" },
    config = tie(
      "plugin which-key -> config",
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
        "plugin which-key -> expand",
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
        "plugin which-key -> defer",
        ---@param ctx { mode: string, operator: string }
        function(ctx)
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
          { "<localleader>", group = "local leader", },
          { "<leader>q", group = "quit", },
          { "<leader>t", group = "toggle", },
          { "<leader>%", group = "whole file", },
          { "<leader>j", group = "prev", proxy = "[", },
          { "<leader>k", group = "next", proxy = "]", },
          { "[", group = "prev", },
          { "]", group = "next", },
          { "D", group = "cut", op = true },
          { "gc", group = "toggle comment", op = true },
          { "g@", desc = "Operator-pending mode" },
        },
        {
          mode = "v",
          { "<leader>", group = "leader", }
        },
        {
          mode = { "n", "v" },
          { "gx", desc = "Open with system app" },
        },
      },
    },
  },
}
