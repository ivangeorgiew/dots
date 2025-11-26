--- @meta

-- Used in plugin files
--- @class MyLazySpec: LazyPluginSpec
--- @field extra? table

-- Used in lsp config files
--- @class LspConfig
--- @field enable? boolean
--- @field lsp_name string
--- @field pkg_name? string
--- @field config? vim.lsp.Config
--- @field extra? table

-- For tied.dir
--- @class TiedDirOpts
--- @field path string
--- @field type "file"|"dir"
--- @field ext string?
--- @field depth number?
--- @field map function?

--- @class KeymapSetArgs
--- @field [1] string|string[]
--- @field [2] string
--- @field [3] string|function
--- @field [4] vim.keymap.set.Opts?
