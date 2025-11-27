--- @class MyLazySpec
local M = {
  "folke/tokyonight.nvim",
  cond = vim.g.colorscheme == "tokyonight",
  event = "UIEnter",
  config = tied.colorscheme_config,
  opts = {
    style = "night", -- The theme comes in three styles, `storm`, `moon`, a darker variant `night` and `day`
    light_style = "day", -- The theme is used when the background is set to light
    transparent = true, -- Enable this to disable setting the background color
    terminal_colors = true, -- Configure the colors used when opening a `:terminal` in [Neovim](https://github.com/neovim/neovim)
    styles = {
      -- Style to be applied to different syntax groups
      -- Value is any valid attr-list value for `:help nvim_set_hl`
      comments = { italic = true },
      keywords = { italic = false },
      functions = {},
      variables = {},
      -- Background styles. Can be "dark", "transparent" or "normal"
      sidebars = "transparent", -- style for sidebars, see below
      floats = "transparent", -- style for floating windows
    },
    sidebars = { "qf", "help" }, -- Set a darker background on sidebar-like windows. For example: `["qf", "vista_kind", "terminal", "packer"]`
    day_brightness = 0.3, -- Adjusts the brightness of the colors of the **Day** style. Number between 0 and 1, from dull to vibrant colors
    hide_inactive_statusline = false, -- Enabling this option, will hide inactive statuslines and replace them with a thin border instead. Should work with the standard **StatusLine** and **LuaLine**.
    dim_inactive = false, -- dims inactive windows
    lualine_bold = false, -- When `true`, section headers in the lualine theme will be bold

    -- You can override specific highlights to use other groups or a hex color
    -- function will be called with a Highlights and ColorScheme table
    -- https://github.com/folke/tokyonight.nvim?tab=readme-ov-file#borderless-telescope-example
    on_highlights = tie("Theme tokyonight -> on_highlight", function(hl, _)
      local hypr_border = { fg = "#492A78" }
      local kanagawa_TabLine = { fg = "#938aa9" }
      local global = { link = "@variable.builtin" }

      -- Use :Inspect to find out the hl group under cursor
      hl.WinSeparator = hypr_border
      hl.TabLine = kanagawa_TabLine
      hl["@lsp.typemod.variable.global"] = global
    end, tied.do_nothing),
  },
}

return M
