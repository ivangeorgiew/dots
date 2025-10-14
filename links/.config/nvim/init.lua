-- For neovim's lua API info -> https://neovim.io/doc/user/lua-guide.html

require("tying") -- error handling wrapper

tie(
  "initialize nvim config",
  function()
    -- Delay notificatinos until vim.notify has been replaced
    require("notify").delay_notify()

    -- Order matters
    local configs = {
      "utils",
      "options",
      "plugin_manager",
      "keymaps",
      "usercmds",
      "autocmds",
    }

    for _, file in ipairs(configs) do
      tie(
        "require config/"..file..".lua",
        function() require("config." .. file).setup() end,
        do_nothing
      )()
    end
  end,
  do_nothing
)()
