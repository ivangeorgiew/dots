-- Lazy Settings: https://github.com/folke/lazy.nvim#%EF%B8%8F-configuration
-- Plugin Settings: https://github.com/folke/lazy.nvim?tab=readme-ov-file#examples

-- setup plugin manager
local uv = require("utils").uv
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not uv.fs_stat(lazypath) then
  print("Installing lazy.nvim...")

  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath,
  })

  print("Done.")
end

vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- auto add all my plugins from `lua/plugins/*.lua`
  spec = "plugins",

  defaults = {
    lazy = true, -- lazy load all plugins by default
    version = false, -- always use the latest git commit
    cond = nil, -- default condition to load plugins
  },

  dev = {
    -- path to local plugins
    path = vim.fn.stdpath("config") .. "local_plugins",

    -- if plugin matches one of the string patterns, use local
    patterns = {},

    -- fallback to git if local plugin is missing
    fallback = false,
  },

  ui = {
    border = "rounded", -- border of LazyVim window
  },

  custom_keys = {}, -- keybinds when LazyVim is open

  install = {
    -- auto install missing plugins on vim startup
    missing = true,

    -- colorscheme during installation
    colorscheme = { "tokyonight" },
  },

  checker = {
    -- auto check for plugin updates
    enabled = false,
  },

  change_detection = {
    -- whether to detect plugin config changes
    enabled = true,

    -- get a notification when plugin configs are updated
    notify = false,
  },

  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        --"matchit",
        "matchparen",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
