--- @type table<string,PluginSpec>
local M = {
  mason = {
    --- External tools installer
    src = "mason-org/mason.nvim",
    opts = {
      PATH = "skip", -- manually added
    },
  },
  mason_lock = {
    -- Lockfile for mason
    src = "zapling/mason-lock.nvim",
    dependencies = { "mason-org/mason.nvim" },
    cmd = { "Mason", "MasonLock", "MasonLockRestore" },
    opts = {},
  },
}

M.mason.init = tie("Plugin mason -> init", function()
  tied.do_block("Plugin mason -> Add tools to PATH", function()
    local mason_path = vim.fn.stdpath("data") .. "/mason/bin"

    -- Append so project specific versions of tools take precedence
    if not (vim.env.PATH):match(mason_path) then
      vim.env.PATH = ("%s:%s"):format(vim.env.PATH, mason_path)
    end
  end)

  tied.mason_install = tie(
    "Plugin mason -> Install tools",
    --- @param to_install string[]
    function(to_install)
      vim.validate("to_install", to_install, "table")

      to_install = vim.tbl_filter(
        tie("Filter tools to install with mason", function(tool)
          local name = tool:match("^([^@]+)@?(.*)$")
          return vim.fn.executable(name) == 0
        end, function() return false end),
        to_install
      )

      if #to_install == 0 then
        return
      end

      tied.load_plugins({ "mason", "mason-lock" })
      tied.on_plugins_load(
        "Install tools after mason loaded",
        { "mason", "mason-lock" },
        function()
          local mr = require("mason-registry")

          mr.refresh()

          local installed = mr.get_installed_package_names()

          tied.for_list(
            "Auto-install a mason tool",
            to_install,
            function(_, tool)
              local name = tool:match("^([^@]+)@?(.*)$")

              if
                mr.has_package(name) and not vim.list_contains(installed, name)
              then
                vim.cmd("MasonInstall " .. tool)
              end
            end
          )
        end
      )
    end,
    tied.do_nothing
  )
end, tied.do_nothing)

return vim.tbl_values(M)
