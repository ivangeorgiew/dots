---@module "snacks"
---@type LazyPluginSpec
local M = {
  "ivangeorgiew/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {},
}

M.config = tie("Plugin snacks -> config", function(_, opts)
  require("snacks").setup(opts)

  tied.each(
    "Plugin snacks -> Create keymaps for a plugin module",
    opts,
    function(_, module)
      if not module.enabled or not vim.tbl_get(module, "custom", "maps") then
        return
      end

      tied.each_i(
        "Plugin snacks -> Create a keymap",
        module.custom.maps,
        function(_, map_opts) tied.create_map(unpack(map_opts)) end
      )
    end
  )
end, tied.do_nothing)

return M
