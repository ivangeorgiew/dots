--- @class MyLazySpec
local M = {
  -- Show keybind hints on key press
  "ivangeorgiew/which-key.nvim",
  -- cond = false,
  -- dev = true,
  event = tied.LazyEvent,
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
      -- { "<leader>", mode = { "n", "x" } },
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
        { "<leader>t", group = "Toggle" },
        { "<leader>%", group = "Whole file" },
        { "q", group = "Quit" },
        { "D", group = "Cut", op = true },
        { "gc", group = "Toggle comment", op = true },
        { "g@", desc = "Operator-pending mode" },
      },
      {
        mode = { "n", "x" },
        { "<leader>", group = "Leader" },
        { "<localleader>", group = "Local leader" },
        { "<leader>j", group = "Prev", proxy = "[" },
        { "<leader>k", group = "Next", proxy = "]" },
        { "[", group = "Prev" },
        { "]", group = "Next" },
        { "gx", desc = "Open with system app" },
      },
    },
  },
}

return M
