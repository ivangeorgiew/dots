-- For neovim's lua API info -> https://neovim.io/doc/user/lua-guide.html

require("tying") -- error handling logic

tie(
  "initialize nvim config",
  function()
    require("builtins") -- replace some global builtin functions
    require("notify") -- delay notifications
    require("utils") -- add global util functions

    -- Order matters
    local configs = {
      "options",
      "keymaps",
      "usercmds",
      "autocmds",
      "plugin_manager",
    }

    for _, file in ipairs(configs) do
      require("config/"..file, tied.do_nothing).setup()
    end
  end,
  tied.do_nothing
)()
