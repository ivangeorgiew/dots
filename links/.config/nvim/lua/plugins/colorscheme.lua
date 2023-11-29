return {
  'folke/tokyonight.nvim',

  lazy = false, -- required at startup since it's main colorscheme

  priority = 1000, -- load before all other plugins start

  config = function()
    -- pass setup options manually instead of using `opts`
    -- because we have to use `config` to change the colorscheme
    require('tokyonight').setup({
      style = 'moon',
      transparent = true,
      styles = {
        sidebars = 'transparent',
        floats = 'transparent',
      },
    })

    -- actualy set the colorscheme
    vim.cmd('colorscheme tokyonight')
  end,
}
