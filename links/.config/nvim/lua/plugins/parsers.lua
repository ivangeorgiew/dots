return {
  -- Language parsing which provides better highlight, indentation, etc.
  -- You can see the difference with `:TSToggle highlight lua` in a lua buffer
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = ":TSUpdate",
    event = "VeryLazy",
    main = "nvim-treesitter.configs", -- name to require(main).setup(opts)
    -- :h nvim-treesitter-quickstart (and scroll to modules as well)
    opts = {
      -- A list of parser names, or "all" (the listed parsers MUST always be installed)
      -- ensure_installed =  { "lua", "luadoc", "printf", "vim", "vimdoc" },
      ensure_installed = "all",

      -- List of parsers to ignore installing from `ensure_installed = "all"`
      -- Need to be uninstalled with `:TSUninstall x` if they are already present
      ignore_install = {
        "ipkg", -- broken
        "comment" -- use folke/todo-comments instead
      },

      -- Install parsers synchronously (only applied to `ensure_installed`)
      sync_install = false,

      -- Automatically install missing parsers when entering buffer
      -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
      auto_install = true,

      -- A directory to install the parsers into.
      -- If this is excluded or nil parsers are installed to either the package dir, or the "site" dir.
      -- If a custom path is used (not nil) it must be added to the runtimepath.
      -- parser_install_dir = vim.fn.stdpath("data") .. "/lazy/nvim-treesitter/",

      highlight = {
        enable = true,
        disable = { "ruby" },

        -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
        -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
        -- Using this option may slow down your editor, and you may see some duplicate highlights.
        -- Instead of true it can also be a list of languages
        additional_vim_regex_highlighting = false,
      },

      indent = {
        enable = true,
        disable = { "ruby" },
      },
    },
  },
}
