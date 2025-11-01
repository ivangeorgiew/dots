-- For neovim's lua API info -> https://neovim.io/doc/user/lua-guide.html

require("tying") -- error handling logic

tie(
  "initialize nvim config",
  function()
    require("builtins") -- replace some global builtins
    require("notify") -- delay notifications
    require("utils") -- add global utils

    -- Order matters
    local configs = {
      "options",
      "plugin_manager",
      "keymaps",
      "usercmds",
      "autocmds",
    }

    local init = tie(
      "initialize config file",
      function(file) require("config/"..file).setup() end,
      tied.do_nothing
    )

    for _, file in ipairs(configs) do init(file) end
  end,
  tied.do_nothing
)()
