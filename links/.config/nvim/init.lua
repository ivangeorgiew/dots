require("ropework") -- error handling logic

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
