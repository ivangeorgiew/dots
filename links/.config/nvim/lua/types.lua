--- @meta

--- @class plugin_dependency
--- @field src string
--- @field name string?

--- @class plugin_spec Plugin definition
--- @field src string
--- @field name string?
--- @field path string?
--- @field submodule boolean?
--- @field version string|vim.VersionRange?
--- @field dependencies string[]|plugin_dependency[]?
--- @field enabled boolean?
--- @field lazy boolean?
--- @field dev boolean?
--- @field opts table?
--- @field init function?
--- @field config function?
--- @field build string|function?
--- @field cmd string|string[]?
--- @field ft string|string[]?
--- @field loaded boolean?

--- @class lsp_features all lsp features which have `feature.enable(true, { client_id })`
--- @field semantic_tokens boolean? highlight words
--- @field codelens boolean? show references with virtual text
--- @field document_color boolean? add virtual text that shows color
--- @field inline_completion boolean? multiline completion (usefull for ai)
--- @field linked_editing_range boolean? ex: changing starting html tag, changes closing html tag
--- @field on_type_formatting boolean? try to format text while you type it

--- @class lsp_config Used in lsp config files
--- @field name string
--- @field features lsp_features
--- @field enabled? boolean
--- @field config? vim.lsp.Config
--- @field custom? table

--- @class tied.dir.opts
--- @field path string
--- @field type "file"|"dir"
--- @field ext string?
--- @field depth number?
--- @field map function?

--- @class tied.create_map.args
--- @field [1] string|string[]
--- @field [2] string
--- @field [3] string|function
--- @field [4] vim.keymap.set.Opts?

--- @class tied.create_usercmd.args
--- @field [1] string
--- @field [2] string|fun(args: vim.api.keyset.create_user_command.command_args)
--- @field [3] vim.api.keyset.user_command

--- @class tied.create_autocmd.opts : vim.api.keyset.create_autocmd
--- @field desc string
--- @field event string|string[]
