---@type LspConfig[]
local M = tied.dir({
  path = vim.fn.stdpath("config") .. "/lua/lsp",
  type = "file",
  ext = "lua",
  map = function(file_name)
    if file_name ~= "init.lua" then
      return require("lsp." .. file_name:gsub("%.lua$", ""))
    end
  end
})

return M
