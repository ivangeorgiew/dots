--local config_files = vim.fn.readdir(vim.fn.stdpath("config") .. "/lua/config", [[v:val =~ "\.lua$"]])

local tie = require("utils").tie

tie("require config files", {}, function()
  local ordered_configs = { "options", "plugins", "autocmds", "keymaps" }

  for _, file in ipairs(ordered_configs) do
    local descr = "requiring " .. file .. ".lua"

    tie(descr, {}, function() require("config/" .. file:gsub("%.lua$", "")) end)()
  end
end)()
