-- For neovim's lua API info -> https://neovim.io/doc/user/lua-guide.html

require("tying") -- error handling wrapper

tie("require config files", {}, function()
  -- order matters
  local configs = {
    "utils",
    "options",
    "manager",
    "usercmds",
    "autocmds",
    "keymaps",
  }

  for _, file in ipairs(configs) do
    local descr = "requiring " .. file .. ".lua"

    tie(descr, {}, function() require("config/" .. file:gsub("%.lua$", "")) end)()
  end
end)()
