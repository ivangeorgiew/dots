vim.loader.enable() -- Cached loader (should increase startup time)
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
