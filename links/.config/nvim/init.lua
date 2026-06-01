-- TODO: Go through the mini and MiniMax repos
-- TODO: Create custom statusline without plugin which uses: vim.lsp.status() and vim.diagnostic.status()
-- TODO: Add the diffview.nvim plugin
-- TODO: Consider using the fff file picker for speed
-- TODO: Change all the `go to` commands to open in new tab/vsplit (gf, -i, -d, etc.)
-- TODO: Maybe use vim.ui2 - https://www.reddit.com/r/neovim/comments/1shj1jn/routing_and_filtering_messages_via_type_and_kind/
-- TODO: Go through the NvChad plugin files
-- TODO: Go through the pwnvim plugin files
-- TODO: Go through the kickstart-modular plugin files
-- TODO: Go through the LazyVim plugin files
-- TODO: Go through the LazyVim plugins/extras files
-- TODO: Go through the NvChad's `ui` files
-- TODO: Go through the Snacks repo
-- TODO: Go through my nvim bookmarks
-- TODO: Check other TODOs throughout my neovim config
-- TODO: Check all the plugins in `awesome-neovim`

-- Measure nvim startup time as the first code that is executed for accuracy
vim.g.startup_time = vim.uv.hrtime()
vim.api.nvim_create_autocmd("UIEnter", {
  desc = "Record the nvim startup time",
  once = true,
  callback = function()
    vim.g.startup_time = ("Startup time: %.2f ms"):format(
      1e-6 * (vim.uv.hrtime() - vim.g.startup_time)
    )
  end,
})

vim.loader.enable() -- Cached loader (should improve startup time)
require("ropework") -- Error-handling logic

tied.for_list(
  "Initialize a config file",
  -- Order matters
  {
    "notify",
    "options",
    "pack",
    "autocmds",
    "usercmds",
    "keymaps",
  },
  function(_, file) require("config." .. file).setup() end
)
