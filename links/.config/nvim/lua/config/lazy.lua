-- Lazy Settings: https://lazy.folke.io/configuration
-- Plugin Settings: https://lazy.folke.io/spec
local M = {}

-- TODO: Go through the NvChad plugin files
-- TODO: Go through the pwnvim plugin files
-- TODO: Go through the kickstart-modular plugin files
-- TODO: Go through the LazyVim plugin files
-- TODO: Go through the LazyVim plugins/extras files
-- TODO: Go through the NvChad's `ui` files
-- TODO: Go through the mini and MiniMax repos
-- TODO: Go through the Snacks repo
-- TODO: Go through my nvim bookmarks
-- TODO: Check other TODOs in the plugin dir
-- TODO: Check all the plugins in `awesome-neovim`

---@module "lazy"
---@type LazyConfig
M.opts = {
  spec = {},

  defaults = {
    -- Set this to `true` to have all your plugins lazy-loaded by default.
    -- Only do this if you know what you are doing, as it can lead to unexpected behavior.
    lazy = true, -- should plugins be lazy-loaded?

    -- version = "*", -- try installing the latest stable version for plugins that support semver
    version = false, -- always use the latest git commit
  },

  ---@type table
  dev = {
    ---@type string | fun(plugin): string directory where you store your local plugin projects
    path = "~/projects",
  },

  install = {
    -- Try to load one of these colorschemes when starting an installation during startup
    colorscheme = { vim.g.colorscheme },
  },

  ui = {
    -- The border to use for the UI window. Accepts same border values as |nvim_open_win()|.
    border = "rounded",
    -- custom_keys = {}, -- disable the default keymaps
  },

  change_detection = {
    -- Automatically check for config file changes and reload the ui
    enabled = true,
    notify = false,
  },

  performance = {
    rtp = {
      -- Disable autoloaded files from $VIMRUNTIME/plugin
      -- How they affect startup can be seen in `:Lazy` -> Profile
      disabled_plugins = {
        -- "editorconfig", -- support for .editorconfig files
        "ftplugin", -- load configs from after/ftplugin/file_type.lua
        "gzip", -- edit compressed files
        "man", -- view man pages in vim
        "matchparen", -- highlight parens
        -- "matchit", -- go to open/close keyword with %
        "netrwPlugin", -- built-in file browser
        "optwin", -- activate the option-window command
        "osc52", -- used for copying to clipboard over SSH
        "rplugin", -- use remote plugins
        -- "shada", -- remember things from last session
        "spellfile", -- used for spelling mistakes
        "tarPlugin", -- browse tarfiles
        "tohtml", -- TOhtml command
        "tutor", -- vim tutorial
        "zipPlugin", -- browse zipfiles
      },
    },
  },
}

M.setup = tie("Setup lazy plugin manager", function()
  local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

  if not vim.uv.fs_stat(lazypath) then
    print("Installing lazy.nvim...")

    vim.fn.system({
      "git",
      "clone",
      "--filter=blob:none",
      "https://github.com/folke/lazy.nvim.git",
      "--branch=stable",
      lazypath,
    })

    print("Done.")
  end

  vim.opt.rtp:prepend(lazypath)

  tied.create_autocmd({
    desc = "Install missing plugins",
    group = tied.create_augroup("my.lazy.reload", true),
    event = "User",
    pattern = "LazyReload",
    callback = function()
      local lazy = require("lazy")
      local plugins = require("lazy.core.config").plugins
      local to_install = {}
      local to_update = {}

      tied.each(
        "Queue plugin for install or update",
        plugins,
        function(plugin_name, plugin)
          if not plugin._.installed and plugin._.kind ~= "disabled" then
            to_install[#to_install + 1] = plugin_name
          end

          if plugin._.updates ~= nil then
            to_update[#to_update + 1] = plugin_name
          end
        end
      )

      -- Always install to make sure that there are updates to be made
      lazy.install({ wait = true, show = (#to_install > 0 or #to_update > 0) })

      if #to_update > 0 then
        lazy.update({ wait = false, show = true, plugins = to_update })
      end

      -- Don't reload - not sure of side effects
      -- Don't clean - can cause errors in current session
    end,
  })

  M.opts.spec = tied.dir({
    path = vim.fn.stdpath("config") .. "/lua/plugin",
    type = "dir",
    map = function(dir)
      local plugin_path = "plugin." .. dir:gsub("[\\/]", ".")

      -- Use import so that change_detection works
      -- and there is no need to require the plugin
      -- lazy uses pcall for each import anyways
      return { import = plugin_path }
    end,
  })

  require("lazy").setup(M.opts)
end, tied.do_nothing)

return M
