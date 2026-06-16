--- @module "catppuccin"
--- @type plugin_spec
local M = {
  src = "catppuccin/nvim",
  name = "catppuccin",
  enabled = vim.g.colorscheme == "catppuccin",
  lazy = false,
  config = tied.colorscheme_config,
  --- @type CatppuccinOptions
  opts = {
    flavour = "mocha", -- latte, frappe, macchiato, mocha
    transparent_background = true,
    float = { transparent = true, solid = false },
    term_colors = true, -- sets terminal colors (e.g. `g:terminal_color_0`)
    dim_inactive = { enabled = false },
    no_bold = false, -- Force no bold
    no_italic = false, -- Force no italic
    no_underline = false, -- Force no underline
    styles = { -- Handles the styles of general hi groups (see `:h highlight-args`):
      comments = { "italic" }, -- Change the style of comments
      conditionals = {},
      loops = {},
      functions = {},
      keywords = {},
      strings = {},
      variables = {},
      numbers = {},
      booleans = {},
      properties = {},
      types = {},
      operators = {},
      miscs = {},
    },
    lsp_styles = { -- Handles the style of specific lsp hl groups (see `:h lsp-highlight`).
      virtual_text = {
        errors = { "italic" },
        hints = { "italic" },
        warnings = { "italic" },
        information = { "italic" },
        ok = { "italic" },
      },
      underlines = {
        errors = { "undercurl" },
        hints = { "undercurl" },
        warnings = { "undercurl" },
        information = { "undercurl" },
        ok = { "undercurl" },
      },
      inlay_hints = { background = false },
    },
    auto_integrations = false, -- requires lazy.nvim
    default_integrations = true,
    -- https://github.com/catppuccin/nvim#integrations
    integrations = {
      blink_cmp = { enabled = true, style = "bordered" },
      diffview = false,
      mini = { enabled = true },
      nvimtree = true,
      which_key = true,
    },
    custom_highlights = tie("Theme catppuccin -> custom_highlights", function()
      local colors = require("catppuccin.palettes").get_palette("mocha")
      local hypr_border = { fg = "#492A78" }
      -- local global = { link = "@variable.builtin" }

      -- Use :Inspect to find out the hl group under cursor
      -- Highlight groups: https://github.com/catppuccin/nvim/blob/main/lua/catppuccin/groups
      return {
        WinSeparator = hypr_border,
        TabLine = { bg = "none" },
        TabLineSel = { bg = colors.surface1 },
        BlinkCmpSource = { link = "BlinkCmpLabel" },
        -- ["@namespace.builtin.lua"] = global,
      }
    end, function() return {} end),
  },
}

return M
