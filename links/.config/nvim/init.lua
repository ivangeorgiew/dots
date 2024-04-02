local tie = require("utils").tie

tie("require config files", {}, function()
  local configs = vim.fn.readdir(vim.fn.stdpath("config") .. "/lua/config", [[v:val =~ "\.lua$"]])

  table.sort(configs)

  for _, file in ipairs(configs) do
    local descr = "requiring " .. file .. ".lua"

    tie(descr, {}, function() require("config/" .. file:gsub("%.lua$", "")) end)()
  end
end)()
