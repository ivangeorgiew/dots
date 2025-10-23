-- For neovim's lua API info -> https://neovim.io/doc/user/lua-guide.html

require("tying") -- error handling logic

tie(
  "initialize nvim config",
  function()
    -- Order matters
    local configs = {
      "notify",
      "utils",
      "options",
      "plugin_manager",
      "keymaps",
      "usercmds",
      "autocmds",
    }

    for _, file in ipairs(configs) do
      require("config/"..file, do_nothing).setup()
    end
  end,
  do_nothing
)()
