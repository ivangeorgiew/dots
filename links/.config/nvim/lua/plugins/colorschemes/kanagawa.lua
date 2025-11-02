---@type LazyPluginSpec|LazyPluginSpec[]
return {
  "rebelot/kanagawa.nvim",
  enabled = vim.g.colorscheme == "kanagawa",
  event = { "UIEnter" },
  config = tied.colorscheme_config,
  -- :h kanagawa.nvim-configuration
  opts = {
    undercurl = true, -- enable undercurls
    keywordStyle = { italic = false },
    transparent = true, -- do not set background color
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
      "colorscheme kanagawa -> overrides",
      function()
        local hypr_border = "#492A78"

        return {
          WinSeparator = { fg = hypr_border },
          TabLine = { bg = "none" },
          TabLineFill = { bg = "none" },
          -- StatusLine = { bg = "none" },
        }
      end,
      tied.do_nothing
    ),
  },
}
