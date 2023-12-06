-- map leader keybind (before plugins are loaded)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- execute config files
local config_files = vim.fn.readdir(vim.fn.stdpath("config") .. "/lua/config", [[v:val =~ "\.lua$"]])
for _, file in ipairs(config_files) do require("config." .. file:gsub("%.lua$", "")) end

-- execute plugins file
require("setup_plugins")
