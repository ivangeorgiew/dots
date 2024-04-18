local tie = require("utils").tie
local opts = {
  padding = true, -- Add a space b/w comment and the line
  sticky = true, -- Whether the cursor should stay at its position
  ignore = "^$", -- Lines to be ignored while (un)comment
  mappings = { basic = true, extra = false, }, -- Toggles keybindings creation
  toggler = { line = "gcc", block = "gbc", }, -- LHS of toggle mappings in NORMAL mode
  opleader = { line = "gc", block = "gb", }, -- LHS of operator-pending mappings in NORMAL and VISUAL mode
  extra = { above = "gcO", below = "gco", eol = "gcA", }, -- LHS of extra mappings
  pre_hook = nil, -- Function to call before (un)comment
  post_hook = nil, -- Function to call after (un)comment
}
local modes = { "n", "v" }

return {
  "numToStr/Comment.nvim",
  keys = {
    { "gcc", mode = modes },
    { "gbc", mode = modes },
    { "gc",  mode = modes },
    { "gb",  mode = modes },
  },
  --event = "VeryLazy",
  config = tie(
    "config for Comment",
    {},
    function()
      require("Comment").setup(opts)

      local ft = require("Comment/ft")

      -- can add/modify commentstrings by filetype
      -- ft.javascript = { "//%s", "/*%s*/" }
    end
  )
}
