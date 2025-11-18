require("tying") -- error handling logic

tied.each_i(
  -- Order matters
  {
    "notify",
    "options",
    "lazy",
    "keymaps",
    "usercmds",
    "autocmds",
  },
  "Initialize a config file",
  function(_, file) require("configs." .. file).setup() end
)
