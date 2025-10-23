-- Lazy Settings: https://lazy.folke.io/configuration
-- Plugin Settings: https://lazy.folke.io/spec
local M = {}

M.setup = tie(
  "setup plugin manager",
  function()
    local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

    if not vim.uv.fs_stat(lazypath) then
      print("Installing lazy.nvim...")

      vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath,
      })

      print("Done.")
    end

    vim.opt.rtp:prepend(lazypath)

    require("lazy").setup({
      defaults = {
        -- Set this to `true` to have all your plugins lazy-loaded by default.
        -- Only do this if you know what you are doing, as it can lead to unexpected behavior.
        lazy = true, -- should plugins be lazy-loaded?
      },

      -- Wrap plugins importing with error handling
      -- Alternatively, without error handling -> spec = "plugins",
      spec = tied.get_files({
        path = vim.fn.stdpath("config") .. "/lua/plugins",
        ext = ".lua",
        map = function(file)
          local full_path = "plugins/"..file:gsub("%.lua$", "")
          return require(full_path, function() return {} end)
        end
      }),

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
        enabled = false,
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
    })
  end,
  do_nothing
)

return M
