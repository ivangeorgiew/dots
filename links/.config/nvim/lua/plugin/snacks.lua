-- TODO: enable dashboard

---@module "snacks"
---@type LazyPluginSpec
local M = {
  "ivangeorgiew/snacks.nvim",
  lazy = false,
  ---@type snacks.Config
  opts = {},
}

M.config = tie("Plugin snacks -> config", function(_, opts)
  require("snacks").setup(opts)

  tied.for_table(
    "Plugin snacks -> Traverse modules",
    opts,
    function(module_name, module)
      if not module.enabled then
        return
      end

      local desc_start = ("Plugin snacks.%s -> "):format(module_name)

      -- NOTE:
      -- Don't check for proper types of module.custom.whatever
      -- Let them fail so you notice there's an error

      tied.do_block(desc_start .. "Custom config", function()
        if vim.tbl_get(module, "custom", "config") then
          module.custom.config(_, opts)
        end
      end)

      tied.do_block(desc_start .. "Create keymaps", function()
        if vim.tbl_get(module, "custom", "maps") then
          tied.for_list(
            "Plugin snacks -> Create a keymap",
            module.custom.maps,
            function(_, map_args) tied.create_map(unpack(map_args)) end
          )
        end
      end)

      if vim.tbl_get(module, "custom", "which_key") then
        tied.on_plugin_load(
          "which-key.nvim",
          desc_start .. "Modify which-key mappings",
          function() require("which-key").add(module.custom.which_key) end
        )
      end
    end
  )
end, tied.do_nothing)

return M
