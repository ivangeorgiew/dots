---@type lsp_config
local M = {
  name = "nil_ls",
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
    init_options = { formatting = { command = { "alejandra" } } },
  },
}

return M
