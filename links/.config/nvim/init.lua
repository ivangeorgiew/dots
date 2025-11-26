require("tie") -- error handling logic

tied.each_i(
  "Initialize a config file",
  -- Order matters
  {
    "notify",
    "options",
    "lazy",
    "keymaps",
    "usercmds",
    "autocmds",
  },
  function(_, file) require("config." .. file).setup() end
)
