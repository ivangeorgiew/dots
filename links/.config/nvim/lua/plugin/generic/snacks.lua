-- TODO: enable dashboard

---@module "snacks"
---@type LazyPluginSpec
local M = {
  "ivangeorgiew/snacks.nvim",
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {},
}

M.config = tie("Plugin snacks -> config", function(_, opts)
  require("snacks").setup(opts)

  tied.each(
    "Plugin snacks -> Traverse modules",
    opts,
    function(module_name, module)
      if not module.enabled then
        return
      end

      local desc_start = ("Plugin snacks.%s -> "):format(module_name)

      tied.do_block(desc_start .. "Custom config", function()
        if vim.tbl_get(module, "custom", "config") then
          module.custom.config(_, opts)
        end
      end)

      tied.do_block(desc_start .. "Create keymaps", function()
        if vim.tbl_get(module, "custom", "maps") then
          tied.each_i(
            "Plugin snacks -> Create a keymap",
            module.custom.maps,
            function(_, map_args) tied.create_map(unpack(map_args)) end
          )
        end
      end)
    end
  )
end, tied.do_nothing)

return M
