-- TODO: Maybe change to vim.pack.add from lazy.nvim
-- TODO: Go through the mini and MiniMax repos
-- TODO: Maybe use vim.ui2 - https://www.reddit.com/r/neovim/comments/1shj1jn/routing_and_filtering_messages_via_type_and_kind/
-- TODO: Maybe use the nvim 0.12 ins-completion
-- TODO: Go through the NvChad plugin files
-- TODO: Go through the pwnvim plugin files
-- TODO: Go through the kickstart-modular plugin files
-- TODO: Go through the LazyVim plugin files
-- TODO: Go through the LazyVim plugins/extras files
-- TODO: Go through the NvChad's `ui` files
-- TODO: Go through the Snacks repo
-- TODO: Go through my nvim bookmarks
-- TODO: Check other TODOs in the plugin dir
-- TODO: Check all the plugins in `awesome-neovim`

vim.g.startup_time = vim.uv.hrtime() -- Measure nvim startup time later
vim.loader.enable() -- Cached loader (should improve startup time)
require("ropework") -- Error handling logic

tied.for_list(
  "Initialize a config file",
  -- Order matters
  {
    "notify",
    "options",
    "lazy",
    "autocmds",
    "usercmds",
    "keymaps",
  },
  function(_, file) require("config." .. file).setup() end
)
