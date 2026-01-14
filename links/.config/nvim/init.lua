-- TODO: after moving to nvim 0.12
-- 1. :restart instead of my custom vim alias
-- 2. Look at https://github.com/mezdelex/NeovimConfig/tree/main
-- 3. vim.loader.enable
-- 4. vim.pack.add

require("ropework") -- Error handling logic

tied.each_i(
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
