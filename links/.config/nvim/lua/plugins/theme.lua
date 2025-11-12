--- @type table<string,MyLazySpec>
local M = {
  kanagawa = {
    "rebelot/kanagawa.nvim",
    cond = vim.g.colorscheme == "kanagawa",
    event = "UIEnter", -- issues if "VeryLazy"
    config = tied.colorscheme_config,
  },
  monokai_pro = {
    "loctvl842/monokai-pro.nvim",
    cond = vim.g.colorscheme == "monokai-pro",
    event = "UIEnter", -- issues if "VeryLazy"
    config = tied.colorscheme_config,
  },
  tokyonight = {
    "folke/tokyonight.nvim",
    cond = vim.g.colorscheme == "tokyonight",
    event = "UIEnter", -- issues if "VeryLazy"
    config = tied.colorscheme_config,
  },
}

M.kanagawa.opts = {
  transparent = true,
  undercurl = true,
  commentStyle = { bold = false, italic = true },
  typeStyle = { bold = false, italic = false },
  keywordStyle = { bold = false, italic = false },
  functionStyle = { bold = false, italic = false },
  statementStyle = { bold = false, italic = false },
  colors = { -- add/modify theme and palette colors
    theme = {
      all = {
        ui = {
          float = { bg = "none", bg_border = "none" },
          bg_gutter = "none",
          -- nontext = "#8b83a8",
        }
      }
    },
  },
  overrides = tie(
    "Colorscheme kanagawa -> overrides",
    function()
      local hypr_border = "#492A78"

      return {
        WinSeparator = { fg = hypr_border },
        TabLine = { bg = "none" },
        -- TabLineFill = { bg = "none" },
        -- StatusLine = { bg = "none" },
      }
    end,
    tied.do_nothing
  ),
}

M.monokai_pro.opts = {
  filter = "spectrum", -- classic | octagon | pro | machine | ristretto | spectrum
  transparent_background = true,
  terminal_colors = true,
  devicons = true, -- highlight the icons of `nvim-web-devicons`
  styles = {
    comment = { italic = true },
    keyword = { italic = false }, -- any other keyword
    type = { italic = false }, -- (preferred) int, long, char, etc
    storageclass = { italic = false }, -- static, register, volatile, etc
    structure = { italic = false }, -- struct, union, enum, etc
    parameter = { italic = false }, -- parameter pass in function
    annotation = { italic = false },
    tag_attribute = { italic = false }, -- attribute of tag in reactjs
  },
  inc_search = "background", -- underline | background
  background_clear = {
    "float_win",
    "toggleterm",
    "telescope",
    "which-key",
    "renamer",
    "notify",
    "nvim-tree",
    "neo-tree",
    "bufferline",
  },
  plugins = {
    bufferline = {
      underline_selected = false,
      underline_visible = false,
      underline_fill = false,
      bold = true,
    },
    indent_blankline = {
      context_highlight = "default", -- default | pro
      context_start_underline = false,
    },
  },
}

M.tokyonight.opts = {
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
  on_highlights = tie(
    "Colorscheme tokyonight -> config -> on_highlight",
    function(hl, _)
      local hypr_border = "#492A78"
      local kanagawa_TabLine = { fg= "#938aa9" }

      hl.WinSeparator = { fg = hypr_border }
      hl.TabLine = kanagawa_TabLine
    end,
    tied.do_nothing
  ),
}

return M
