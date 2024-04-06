local tie = require("tie")

local map = tie(
  "create mapping",
  { { "string", "table" }, "string", { "string", "function" }, "table" },
  function(modes, lhs, rhs, opts)
    -- too lazy to write out spec for args right now

    if type(opts) == "table" and opts.silent == nil then
      opts.silent = true
    end

    if type(rhs) == "function" then
      rhs = tie(opts.desc, {}, rhs)
    end

    vim.keymap.set(modes, lhs, rhs, opts)
  end
)

local au = tie(
  "create augroup",
  { "string", { "string", "table" }, "table"},
  function(group_name, events, opts)
    opts.group = vim.api.nvim_create_augroup(group_name, { clear = true })

    if type(opts.callback) == "function" then
      opts.callback = tie(group_name, {}, opts.callback)
    end

    vim.api.nvim_create_autocmd(events, opts)
  end
)

local M = {}

M.map = map
M.au = au
M.uv = vim.uv or vim.loop

return M
