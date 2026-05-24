--- @meta

--- @class PluginSpec Plugin definition
--- @field [1] string
--- @field name string?
--- @field main string?
--- @field version string?
--- @field branch string?
--- @field tag string?
--- @field commit string?
--- @field dependencies table?
--- @field enabled boolean?
--- @field lazy boolean?
--- @field dev boolean?
--- @field opts table?
--- @field init function?
--- @field config function?
--- @field build string|function?
--- @field event string|string[]?
--- @field cmd string|string[]?

--- @class PluginSpecParsed Parsed plugin definition
--- @field src string
--- @field name string
--- @field main string
--- @field loaded boolean?
--- @field version string|table?
--- @field dependencies table?
--- @field enabled boolean?
--- @field lazy boolean?
--- @field dev boolean?
--- @field opts table?
--- @field init function?
--- @field config function?
--- @field build function?
--- @field event string[]?
--- @field cmd string[]?

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
