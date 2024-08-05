return {
  {
    "folke/tokyonight.nvim",
    enabled = vim.g.colorscheme == "tokyonight",
    lazy = false,
    priority = 1000, -- load before all other plugins start

    -- pass setup options manually instead of using `opts`
    -- because we have to use `config` to change the colorscheme
    config = tie(
      "configure theme",
      {},
      function()
        require("tokyonight").setup({
          style = "moon", -- The theme comes in three styles, `storm`, `moon`, a darker variant `night` and `day`
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

          -- You can override specific color groups to use other groups or a hex color
          -- function will be called with a ColorScheme table
          -- https://github.com/folke/tokyonight.nvim?tab=readme-ov-file#-overriding-colors--highlight-groups
          on_colors = tie("override colors", { "table" }, function(c) end),

          -- You can override specific highlights to use other groups or a hex color
          -- function will be called with a Highlights and ColorScheme table
          -- https://github.com/folke/tokyonight.nvim?tab=readme-ov-file#borderless-telescope-example
          on_highlights = tie(
            "override highlights",
            { "table", "table" },
            function(hl, c)
              local n_col = "#8b83a8"

              hl.LineNr = { fg = n_col }
              hl.CursorLineNr = { fg = n_col }
              hl.EndOfBuffer = { fg = n_col }
            end
          ),
        })

        -- actualy set the colorscheme
        vim.cmd("colorscheme tokyonight")
      end
    ),
  },

  {
    "rebelot/kanagawa.nvim",
    enabled = vim.g.colorscheme == "kanagawa",
    lazy = false,
    priority = 1000,
    config = tie(
      "configure theme",
      {},
      function()
        require("kanagawa").setup({
          compile = false, -- enable compiling the colorscheme
          undercurl = false, -- enable undercurls
          commentStyle = { italic = true },
          functionStyle = {},
          keywordStyle = { italic = false },
          statementStyle = { bold = true },
          typeStyle = {},
          transparent = true, -- do not set background color
          dimInactive = false, -- dim inactive window `:h hl-NormalNC`
          terminalColors = true,-- define vim.g.terminal_color_{0,17}
          colors = { -- add/modify theme and palette colors
            palette = {},
            theme = {
              wave = {}, lotus = {}, dragon = {},
              all = {
                ui = { bg_gutter = "none", nontext = "#8b83a8" }
              }
            },
          },
          overrides = tie(
            "modify highlights",
            { "table" },
            function(colors)
              local none = "NONE"

              return {
                NormalFloat = { bg = none },
                FloatBorder = { bg = none },
                FloatTitle = { bg = none },
              }
            end
          ),
          theme = "dragon", -- when 'background' option is not set
          background = {
            dark = "wave", -- try "dragon" or "lotus"
            light = "lotus"
          },
        })

        vim.cmd("colorscheme kanagawa")
      end
    ),
  },

  {
    "loctvl842/monokai-pro.nvim",
    enabled = vim.g.colorscheme == "monokai-pro",
    lazy = false,
    priority = 1000,
    config = tie(
      "configure theme",
      {},
      function()
        require("monokai-pro").setup({
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
          -- https://github.com/loctvl842/monokai-pro.nvim/tree/master
          override = tie("override colors", { "table" }, function(c) end),
        })

        -- TODO: if you use lualine, you can set it's options theme to monokai-pro

        vim.cmd("colorscheme monokai-pro")
      end
    ),
  },
}
