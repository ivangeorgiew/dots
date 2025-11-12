require("tying") -- error handling logic

tie(
  "Initialize nvim config",
  function()
    require("builtins") -- replace some global builtins
    require("utils") -- add global utils

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
      "Initialize config file",
      function(_, file) require("config/"..file).setup() end
    )
  end,
  tied.do_nothing
)()
