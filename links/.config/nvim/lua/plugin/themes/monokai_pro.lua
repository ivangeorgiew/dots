--- @type MyLazySpec
local M = {
  "loctvl842/monokai-pro.nvim",
  cond = vim.g.colorscheme == "monokai-pro",
  event = "UIEnter", -- issues if "VeryLazy"
  config = tied.colorscheme_config,
  opts = {
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
  },
}

return M
