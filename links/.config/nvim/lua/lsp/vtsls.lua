-- TODO: Chech which settings you might want to change once you've worked on typescript projects extensively
-- TODO: Check the vtsls Readme for additional recommendations

local settings = require("lsp.utils.vtsls").settings

settings.both.referencesCodeLens.enabled = false
settings.both.referencesCodeLens.showOnAllFunctions = true
settings.both.updateImportsOnFileMove.enabled = "always"
settings.both.preferGoToSourceDefinition = true
settings.both.inlayHints.parameterNames.enabled = "all"
settings.both.inlayHints.parameterTypes.enabled = true
settings.both.inlayHints.variableTypes.enabled = true
settings.both.inlayHints.propertyDeclarationTypes.enabled = true
settings.both.inlayHints.functionLikeReturnTypes.enabled = true

-- Merge my custom property
-- stylua: ignore start
settings.typescript = vim.tbl_deep_extend("error", settings.typescript, settings.both)
settings.javascript = vim.tbl_deep_extend("error", settings.javascript, settings.both)
settings.both = nil
-- stylua: ignore end

-- Remove the noisy suggestions in javascript files for writing type definitions
settings.javascript.suggestionActions.enabled = false

settings.typescript.inlayHints.enumMemberValues.enabled = true
settings.typescript.implementationsCodeLens.enabled = true
settings.typescript.implementationsCodeLens.showOnInterfaceMethods = true
settings.typescript.implementationsCodeLens.showOnAllClassMethods = true
settings.typescript.tsserver.maxTsServerMemory = 4096

settings.typescript.tsserver.watchOptions.watchFile = "useFsEvents"
settings.typescript.tsserver.watchOptions.watchDirectory = "useFsEvents"
settings.typescript.tsserver.watchOptions.fallbackPolling =
  "dynamicPriorityPolling"
settings.typescript.tsserver.watchOptions.synchronousWatchDirectory = false

settings["js/ts"].implicitProjectConfig.checkJs = true

settings.vtsls.enableMoveToFileCodeAction = true
settings.vtsls.autoUseWorkspaceTsdk = true

---@type lsp_config
local M = {
  name = "vtsls",
  features = {
    -- TODO: which to enable?
    formatting = false,
    codelens = false,
    semantic_tokens = false,
    document_color = false,
    inline_completion = false,
    linked_editing_range = false,
    on_type_formatting = false,
  },
  config = {
    settings = settings,
    filetypes = {
      "javascript",
      "typescript",
      "javascriptreact",
      "typescriptreact",
    },
  },
}

-- TODO: Add useful LSP commands/codeaction keymaps in on_init
M.config.on_init = tie(
  "LSP vtsls -> on_init",
  ---@param client vim.lsp.Client
  function(client)
    -- TODO: remove unused, add and sort imports on save
    -- tied.create_autocmd({
    --   desc = "LSP vtsls -> Fix imports on save",
    --   event = "User",
    --   pattern = "BeforeConformFormat",
    --   group = tied.create_augroup("my.lsp.vtsls.on_save", true),
    --   callback = function(ev)
    --     if not client.attached_buffers[ev.buf] then
    --       return
    --     end
    --   end,
    -- })
  end,
  tied.do_nothing
)

return M
