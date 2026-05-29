--- @meta

--- @class PluginDependency
--- @field src string
--- @field name string?

--- @class PluginSpec Plugin definition
--- @field src string
--- @field name string?
--- @field main string?
--- @field submodule boolean?
--- @field version string|vim.VersionRange?
--- @field dependencies string[]|PluginDependency[]?
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

--- @class UserCmdArgs For tied.create_usrcmd
--- @field [1] string
--- @field [2] string|fun(args: vim.api.keyset.create_user_command.command_args)
--- @field [3] vim.api.keyset.user_command

--- @class AutoCmdArgs : vim.api.keyset.create_autocmd For tied.create_autocmd
--- @field desc string
--- @field event string|string[]
