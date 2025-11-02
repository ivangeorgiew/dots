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

    tied.each_i(configs, "initialize config file", function(_, file)
      require("config/"..file).setup()
    end)
  end,
  tied.do_nothing
)()
