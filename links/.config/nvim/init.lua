--local config_files = vim.fn.readdir(vim.fn.stdpath("config") .. "/lua/config", [[v:val =~ "\.lua$"]])

-- require config files
local ordered_configs = { "options", "plugins", "utils", "autocmds", "keymaps" }
for _, file in ipairs(ordered_configs) do require("config." .. file:gsub("%.lua$", "")) end
