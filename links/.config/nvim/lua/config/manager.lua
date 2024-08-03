-- Lazy Settings: https://lazy.folke.io/configuration
-- Plugin Settings: https://lazy.folke.io/spec

-- setup plugin manager
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
  -- root = vim.fn.stdpath("data") .. "/lazy", -- directory where plugins will be installed

  defaults = {
    -- Set this to `true` to have all your plugins lazy-loaded by default.
    -- Only do this if you know what you are doing, as it can lead to unexpected behavior.
    lazy = true, -- should plugins be lazy-loaded?

    -- It's recommended to leave version=false for now, since a lot the plugin that support versioning,
    -- have outdated releases, which may break your Neovim install.
    -- version = nil, -- always use the latest git commit
    -- version = "*", -- try installing the latest stable version for plugins that support semver

    -- default `cond` you can use to globally disable a lot of plugins
    -- when running inside vscode for example
    -- cond = nil, ---@type boolean|fun(self:LazyPlugin):boolean|nil
  },

  -- wrap plugins importing with error handling
  -- alternatively, without error handling -> spec = "plugins",
  spec = tie("requiring all plugins", {}, function()
    local plugin_files = vim.fn.readdir(vim.fn.stdpath("config") .. "/lua/plugins", [[v:val =~ "\.lua$"]])
    local plugins = {}

    for _, file in ipairs(plugin_files) do
      table.insert(plugins, tie(
        "requiring " .. file .. " plugins",
        {},
        function() return require("plugins/" .. file:gsub("%.lua$", "")) end,
        function() return {} end
      )())
    end

    return plugins
  end)(),

  -- local_spec = true, -- load project specific .lazy.lua spec files. They will be added at the end of the spec.

  -- lockfile = vim.fn.stdpath("config") .. "/lazy-lock.json", -- lockfile generated after running update.

  ---@type number? limit the maximum amount of concurrent tasks
  -- concurrency = jit.os:find("Windows") and (vim.uv.available_parallelism() * 2) or nil,

  -- git = {
  --   -- defaults for the `Lazy log` command
  --   -- log = { "--since=3 days ago" }, -- show commits from the last 3 days
  --   log = { "-8" }, -- show the last 8 commits

  --   timeout = 120, -- kill processes that take more than 2 minutes

  --   url_format = "https://github.com/%s.git",

  --   -- lazy.nvim requires git >=2.19.0. If you really want to use lazy with an older version,
  --   -- then set the below to false. This should work, but is NOT supported and will
  --   -- increase downloads a lot.
  --   filter = true,
  -- },

  -- pkg = {
  --   enabled = true,

  --   cache = vim.fn.stdpath("state") .. "/lazy/pkg-cache.lua",

  --   versions = true, -- Honor versions in pkg sources

  --   -- the first package source that is found for a plugin will be used.
  --   sources = {
  --     "lazy",
  --     "rockspec",
  --     "packspec",
  --   },
  -- },

  -- rocks = {
  --   root = vim.fn.stdpath("data") .. "/lazy-rocks",

  --   server = "https://nvim-neorocks.github.io/rocks-binaries/",
  -- },

  dev = {
    ---@type string | fun(plugin: LazyPlugin): string directory where you store your local plugin projects
    path = vim.fn.stdpath("config") .. "/local_plugins",

    ---@type string[] plugins that match these patterns will use your local versions instead of being fetched from GitHub
    -- patterns = {}, -- For example {"folke"}

    -- fallback = false, -- Fallback to git when local plugin doesn't exist
  },

  install = {
    -- install missing plugins on startup. This doesn't increase startup time.
    -- missing = true,

    -- try to load one of these colorschemes when starting an installation during startup
    colorscheme = { vim.g.colorscheme },
  },

  ui = {
    -- a number <1 is a percentage., >1 is a fixed size
    -- size = { width = 0.8, height = 0.8 },

    -- wrap = true, -- wrap the lines in the ui

    -- The border to use for the UI window. Accepts same border values as |nvim_open_win()|.
    border = "rounded",

    -- The backdrop opacity. 0 is fully opaque, 100 is fully transparent.
    -- backdrop = 60,

    -- title = nil, ---@type string only works when border is not "none"

    -- title_pos = "center", ---@type "center" | "left" | "right"

    -- Show pills on top of the Lazy window
    -- pills = true, ---@type boolean

    -- icons = {
    --   cmd = " ",
    --   config = "",
    --   event = " ",
    --   favorite = " ",
    --   ft = " ",
    --   init = " ",
    --   import = " ",
    --   keys = " ",
    --   lazy = "󰒲 ",
    --   loaded = "●",
    --   not_loaded = "○",
    --   plugin = " ",
    --   runtime = " ",
    --   require = "󰢱 ",
    --   source = " ",
    --   start = " ",
    --   task = "✔ ",
    --   list = {
    --     "●",
    --     "➜",
    --     "★",
    --     "‒",
    --   },
    -- },

    -- leave nil, to automatically select a browser depending on your OS.
    -- If you want to use a specific browser, you can define it here
    -- browser = nil, ---@type string?

    -- throttle = 20, -- how frequently should the ui process render events

    custom_keys = {},
  },

  -- diff = {
  --   -- diff command <d> can be one of:
  --   -- * browser: opens the github compare view. Note that this is always mapped to <K> as well,
  --   --   so you can have a different command for diff <d>
  --   -- * git: will run git diff and open a buffer with filetype git
  --   -- * terminal_git: will open a pseudo terminal with git diff
  --   -- * diffview.nvim: will open Diffview to show the diff
  --   cmd = "git",
  -- },

  checker = {
    -- automatically check for plugin updates
    enabled = false,

    -- concurrency = nil, ---@type number? set to 1 to check for updates very slowly

    -- notify = true, -- get a notification when new updates are found

    -- frequency = 3600, -- check for updates every hour

    -- check_pinned = false, -- check for pinned packages that can't be updated
  },

  change_detection = {
    -- automatically check for config file changes and reload the ui
    enabled = false,

    -- notify = true, -- get a notification when changes are found
  },

  performance = {
    cache = {
      enabled = true,
    },

    -- reset_packpath = true, -- reset the package path to improve startup time

    rtp = {
      -- reset the runtime path to $VIMRUNTIME and your config directory
      -- reset = true,

      ---@type string[]
      -- paths = {}, -- add any custom paths here that you want to includes in the rtp

      ---@type string[] list any plugins you want to disable here
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

  -- lazy can generate helptags from the headings in markdown readme files,
  -- so :help works even for plugins that don't have vim docs.
  -- when the readme opens with :help it will be correctly displayed as markdown
  -- readme = {
  --   enabled = true,

  --   root = vim.fn.stdpath("state") .. "/lazy/readme",

  --   files = { "README.md", "lua/**/README.md" },

  --   -- only generate markdown helptags for plugins that dont have docs
  --   skip_if_doc_exists = true,
  -- },

  -- state = vim.fn.stdpath("state") .. "/lazy/state.json", -- state info for checker and other things

  -- Enable profiling of lazy.nvim. This will add some overhead,
  -- so only enable this when you are debugging lazy.nvim
  -- profiling = {
  --   -- Enables extra stats on the debug tab related to the loader cache.
  --   -- Additionally gathers stats about all package.loaders
  --   loader = false,

  --   -- Track each new require in the Lazy profiling tab
  --   require = false,
  -- },
})
