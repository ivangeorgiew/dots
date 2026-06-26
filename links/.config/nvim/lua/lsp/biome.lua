---@type lsp_config
local M = {
  name = "biome",
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
    settings = {
      require_configuration = true,
    },
  },
}

return M
