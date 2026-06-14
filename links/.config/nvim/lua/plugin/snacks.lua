---@type PluginSpec
local M = {
  src = "ivangeorgiew/snacks.nvim",
  lazy = true,
  opts = {},
}

M.config = tie("Plugin snacks -> config", function(opts)
  require("snacks").setup(opts)

  tied.for_table(
    "Plugin snacks -> Setup a module",
    opts,
    function(module_name, module)
      if not module.enabled then
        return
      end

      local desc_start = ("Plugin snacks.%s -> "):format(module_name)

      tied.do_block(desc_start .. "Module config", function()
        if vim.tbl_get(module, "custom", "config") then
          module.custom.config(opts)
        end
      end)

      tied.do_block(desc_start .. "Create keymaps", function()
        if vim.tbl_get(module, "custom", "maps") then
          tied.for_list(
            desc_start .. "Create a keymap",
            module.custom.maps,
            function(_, map_args) tied.create_map(unpack(map_args)) end
          )
        end

        if vim.tbl_get(module, "custom", "which_key") then
          tied.on_plugins_load(
            desc_start .. "Modify which-key mappings",
            { "which-key" },
            function() require("which-key").add(module.custom.which_key) end
          )
        end
      end)
    end
  )
end, tied.do_nothing)

return M
