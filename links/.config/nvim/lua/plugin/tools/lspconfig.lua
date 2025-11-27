--- @class MyLazySpec
local M = {
  -- Provides good default LSP configs
  -- :h lspconfig
  "neovim/nvim-lspconfig",
  event = tied.LazyEvent,
}

M.config = tie("Plugin nvim-lspconfig -> config", function()
  tied.do_block("Config, enable and install LSPs", function()
    local to_install = {}

    tied.each_i("Setup an LSP", require("lsp"), function(_, lsp)
      if lsp.config then
        vim.lsp.config(lsp.lsp_name, lsp.config)
      end

      if lsp.enable ~= false then
        vim.lsp.enable(lsp.lsp_name)

        if lsp.pkg_name then
          to_install[#to_install + 1] = lsp.pkg_name
        end
      end
    end)

    tied.mason_install(to_install)
  end)

  -- NOTE: Example inlay hints configs: https://github.com/MysticalDevil/inlay-hints.nvim/tree/master
  -- tied.set_hl(0, "LspInlayHint", { link = "Comment" })
end, tied.do_nothing)

return M
