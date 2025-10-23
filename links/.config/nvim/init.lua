-- For neovim's lua API info -> https://neovim.io/doc/user/lua-guide.html

require("tying") -- error handling logic
require("builtins") -- replace some global builtin functions
require("utils") -- add some tied function utils

tie(
  "initialize nvim config",
  function()
    -- Order matters
    local configs = {
      "notify",
      "options",
      "plugin_manager",
      "keymaps",
      "usercmds",
      "autocmds",
    }

    for _, file in ipairs(configs) do
      require("config/"..file, tied.do_nothing).setup()
    end
  end,
  tied.do_nothing
)()
