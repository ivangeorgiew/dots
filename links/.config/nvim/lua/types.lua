--- @meta

-- Used in plugin files
--- @class MyLazySpec: LazyPluginSpec
--- @field extra_opts? table

-- Used in lsp config files
--- @class LspConfig
--- @field enable? boolean
--- @field lsp_name string
--- @field pkg_name? string
--- @field config? vim.lsp.Config
--- @field utils? table

-- For tied.dir
--- @class TiedDirOpts
--- @field path string
--- @field type "file"|"dir"
--- @field ext string?
--- @field depth number?
--- @field map function?
