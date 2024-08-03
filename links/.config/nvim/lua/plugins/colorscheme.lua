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
    "polirritmico/monokai-nightasty.nvim",
    enabled = vim.g.colorscheme == "monokai-nightasty",
    lazy = false,
    priority = 1000,
    config = tie(
      "configure theme",
      {},
      function()
        require("monokai-nightasty").setup({
          dark_style_background = "transparent", -- default, dark, transparent, #color
          light_style_background = "transparent", -- default, dark, transparent, #color
          hl_styles = {
            -- Style to be applied to selected syntax groups: (See `:help nvim_set_hl` for supported keys)
            comments = { italic = true },
            keywords = { italic = false },
            functions = {},
            variables = {},
            -- Background styles for sidebars (panels) and floating windows:
            floats = "transparent", -- default, dark, transparent
            sidebars = "transparent", -- default, dark, transparent
          },

          color_headers = false, -- Enable header colors for each header level (h1, h2, etc.)
          dim_inactive = false, -- dims inactive windows
          lualine_bold = true, -- Lualine headers will be bold or regular
          lualine_style = "default", -- "dark", "light" or "default" (default follows dark/light style)
          markdown_header_marks = false, -- Add headers marks highlights (the `#` character) to Treesitter highlight query

          -- Set the colors for terminal-mode (`:h terminal-config`). `false` to disable it.
          -- Pass a table with `terminal_color_x` values: `{ terminal_color_8 = "#e6e6e6" }`.
          -- Also accepts a function:
          -- ```lua
          -- function(colors) return { fg = colors.fg_dark, terminal_color_4 = "#ff00ff" } end
          -- ```
          -- > Use the `fg` key to apply colors to the normal text.
          terminal_colors = true,

          --- You can override specific color groups to use other groups or a hex color
          --- function will be called with the Monokai ColorScheme table.
          ---@param colors ColorScheme
          on_colors = tie("override colors", { "table" }, function(c) end),

          --- You can override specific highlights to use other groups or a hex color
          --- function will be called with the Monokai Highlights and ColorScheme table.
          ---@param highlights monokai.Highlights
          ---@param colors ColorScheme
          on_highlights = tie("override highlights", { "table", "table" }, function(hl, c) end),

          -- When `true` the theme will be cached for better performance.
          cache = true,

          --- Automatically enable highlights for supported plugins in the lazy.nvim config.
          auto_enable_plugins = true,

          --- List of manually enabled/disabled plugins.
          --- Check the supported plugins here:
          ---   https://github.com/polirritmico/monokai-nightasty.nvim/tree/main/lua/monokai-nightasty/highlights
          ---@type table<string, boolean>
          -- plugins = {
          --   -- Use the ["<repository name>"]. For example:
          --   -- ["telescope.nvim"] = true,

          --   -- `all`: enable or disable all plugins. By default if lazy.nvim is not loaded enable all the plugins
          --   all = package.loaded.lazy == nil,
          -- },
        })

        vim.cmd("colorscheme monokai-nightasty")
      end
    ),
  },
}
