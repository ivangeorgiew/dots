-- For neovim's lua API info -> https://neovim.io/doc/user/lua-guide.html

require("utils") -- load utils

tie("require config files", {}, function()
  --local configs = vim.fn.readdir(vim.fn.stdpath("config") .. "/lua/config", [[v:val =~ "\.lua$"]])
  --table.sort(configs)

  local configs = {
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
