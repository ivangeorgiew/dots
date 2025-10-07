-- For neovim's lua API info -> https://neovim.io/doc/user/lua-guide.html

require("tying") -- error handling wrapper

tie(
  "initialize nvim config",
  function()
    -- order matters
    local configs = {
      "utils",
      "options",
      "plugin_manager",
      "keymaps",
      "usercmds",
      "autocmds",
    }

    for _, file in ipairs(configs) do
      local desc = "require " .. file .. ".lua"

      tie(desc, function() require("config/" .. file:gsub("%.lua$", "")).setup() end, do_nothing)()
    end
  end,
  do_nothing
)()
