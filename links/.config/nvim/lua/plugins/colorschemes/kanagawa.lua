---@type LazyPluginSpec|LazyPluginSpec[]
return {
  "rebelot/kanagawa.nvim",
  cond = vim.g.colorscheme == "kanagawa",
  event = "UIEnter", -- issues if "VeryLazy"
  config = tied.colorscheme_config,
  -- :h kanagawa.nvim-configuration
  opts = {
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
  },
}
