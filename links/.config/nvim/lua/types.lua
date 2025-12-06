--- @meta

--- @class MyLazySpec : LazyPluginSpec Used in plugin files
--- @field extra? table

--- @class LspConfig Used in lsp config files
--- @field enable? boolean
--- @field lsp_name string
--- @field pkg_name? string
--- @field config? vim.lsp.Config
--- @field extra? table

--- @class TiedDirOpts For tied.dir
--- @field path string
--- @field type "file"|"dir"
--- @field ext string?
--- @field depth number?
--- @field map function?

--- @class KeymapSetArgs All vim.keymap.set arguments
--- @field [1] string|string[]
--- @field [2] string
--- @field [3] string|function
--- @field [4] vim.keymap.set.Opts?

--- @class UserCmdArgs
--- @field [1] string
--- @field [2] string|fun(args: vim.api.keyset.create_user_command.command_args)
--- @field [3] vim.api.keyset.user_command
