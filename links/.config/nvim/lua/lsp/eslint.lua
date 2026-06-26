---@type lsp_config
local M = {
  name = "eslint",
  features = {
    formatting = true,
    codelens = false,
    semantic_tokens = false,
    document_color = false,
    inline_completion = false,
    linked_editing_range = false,
    on_type_formatting = false,
  },
  config = {
    -- https://github.com/microsoft/vscode-eslint/tree/main#settings-options
    -- https://github.com/microsoft/vscode-eslint/blob/main/%24shared/settings.ts#L166
    settings = {
      useFlatConfig = true, -- Enable for eslint version >= 8.57.0. Deprecates experimental.useFlatConfig
      useRealpaths = false, -- Not sure if needed. Defaults to false.
      codeActionOnSave = {
        mode = "all", ---@type "all"|"problems"
      },
      format = true,
      quiet = false,
      onIgnoredFiles = "off", ---@type "off"|"warn"|"error"
      bulkSuppression = { enable = false }, -- https://eslint.org/docs/latest/use/suppressions
      problems = { shortenToSingleLine = true }, -- Defaults to false
      workingDirectory = {
        mode = "auto", ---@type "auto"|"location"
      },
      run = "onType", ---@type "onType"|"onSave"
      rulesCustomizations = {}, -- change severity of rules (warn, error, etc) for neovim only
      options = {}, -- TODO: https://eslint.org/docs/latest/integrate/nodejs-api#parameters
    },
  },
}

M.config.on_attach = tie(
  "LSP eslint -> on_attach",
  ---@param client vim.lsp.Client
  ---@param bufnr integer
  function(client, bufnr)
    -- TODO: Issue tracked in https://github.com/neovim/neovim/issues/40391
    vim.lsp.diagnostic._refresh(bufnr, client.id, true)
  end,
  tied.do_nothing
)

-- NOTE: Unneeded with `format = true`, but left for example
-- M.config.on_init = tie(
--   "LSP eslint -> on_init",
--   ---@param client vim.lsp.Client
--   function(client)
--     tied.create_autocmd({
--       desc = "Format eslint on save",
--       event = "BufWritePre",
--       group = tied.create_augroup("my.lsp.eslint.applyAllFixes", true),
--       callback = function(ev)
--         if not client.attached_buffers[ev.buf] then
--           return
--         end
--
--         -- NOTE: All commands are in
--         -- vim.print(client.server_capabilities.executeCommandProvider.commands)
--         client:request_sync("workspace/executeCommand", {
--           command = "eslint.applyAllFixes",
--           arguments = {
--             {
--               uri = vim.uri_from_bufnr(ev.buf),
--               version = vim.lsp.util.buf_versions[ev.buf],
--             },
--           },
--         }, 1000, ev.buf)
--       end,
--     })
--   end,
--   tied.do_nothing
-- )

return M
