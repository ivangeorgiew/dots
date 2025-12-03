--- @type MyLazySpec
local M = {
  --- External tools installer
  "mason-org/mason.nvim",
  cmd = { "Mason" },
  build = ":MasonUpdate",
  opts = {
    PATH = "skip", -- I add it manually
    ui = {
      border = "single", -- same as nvim_open_win()
      width = 0.6, -- 0-1 for a percentage of screen width.
      height = 0.8, -- 0-1 for a percentage of screen height.
    },
  },
}

-- Executed even when the plugin isn't loaded yet
M.init = tie("Plugin mason -> init", function()
  tied.do_block(
    "Plugin mason -> Add tools to PATH",
    function()
      vim.env.PATH = ("%s/mason/bin:%s"):format(
        vim.fn.stdpath("data"),
        vim.env.PATH
      )
    end
  )

  tied.mason_install = tie(
    "Plugin mason -> Install tools",
    --- @param to_install string[]
    function(to_install)
      vim.validate("to_install", to_install, "table")

      to_install = vim.tbl_filter(
        function(exe) return vim.fn.executable(exe) == 0 end,
        to_install
      )

      if #to_install == 0 then
        return
      end

      local mr = require("mason-registry")
      local installed = mr.get_installed_package_names()

      mr:on(
        "package:install:success",
        vim.defer_wrap(
          tie("Plugin mason -> Start newly installed LSPs", function()
            tied.each_i(
              "Start LSP in opened file",
              vim.api.nvim_list_wins(),
              function(_, winnr)
                local bufnr = vim.api.nvim_win_get_buf(winnr)

                if tied.check_if_buf_is_file(bufnr) then
                  vim.api.nvim_exec_autocmds("FileType", {
                    buffer = bufnr,
                    group = "nvim.lsp.enable",
                    modeline = false,
                  })
                end
              end
            )
          end, tied.do_nothing),
          100
        )
      )

      tied.each_i("Auto-install a mason tool", to_install, function(_, tool)
        if mr.has_package(tool) and not vim.list_contains(installed, tool) then
          vim.cmd("MasonInstall " .. tool)
        end
      end)
    end,
    tied.do_nothing
  )
end, tied.do_nothing)

return M
