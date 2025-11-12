--- @type table<string,MyLazySpec>
local M = {
  which_key = {
    -- Show keybind hints on key press
    "ivangeorgiew/which-key.nvim",
    -- dev = true,
    event = "VeryLazy",
    dependencies = { "nvim-mini/mini.icons", "nvim-tree/nvim-web-devicons" },
  },
}

M.which_key.config = tie(
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
)

M.which_key.opts = {
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
      { "<localleader>", group = "Local leader", },
      { "<leader>t", group = "Toggle", },
      { "<leader>%", group = "Whole file", },
      { "<leader>j", group = "Prev", proxy = "[", },
      { "<leader>k", group = "Next", proxy = "]", },
      { "[", group = "Prev", },
      { "]", group = "Next", },
      { "q", group = "Quit", },
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
}

return M
