--- @type MyLazySpec
local M = {
  -- Show keybind hints on key press
  "ivangeorgiew/which-key.nvim",
  -- dev = true,
  event = "VeryLazy",
  dependencies = { "nvim-mini/mini.icons", "nvim-tree/nvim-web-devicons" },
  opts = {
    preset = "helix",
    delay = 200,
    keys = {
      scroll_down = "<Down>",
      scroll_up = "<Up>",
    },
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
        return false
      end,
      function() return false end
    ),
    spec = {
      {
        mode = "n",
        { "<localleader>", group = "Local leader" },
        { "<leader>t", group = "Toggle" },
        { "<leader>%", group = "Whole file" },
        { "<leader>j", group = "Prev", proxy = "[" },
        { "<leader>k", group = "Next", proxy = "]" },
        { "[", group = "Prev" },
        { "]", group = "Next" },
        { "q", group = "Quit" },
        { "D", group = "Cut", op = true },
        { "gc", group = "Toggle comment", op = true },
        { "g@", desc = "Operator-pending mode" },
      },
      {
        mode = "v",
        { "<leader>", group = "Leader" },
      },
      {
        mode = { "n", "v" },
        { "gx", desc = "Open with system app" },
      },
    },
  },
}

return M
