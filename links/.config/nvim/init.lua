-- Measure startup time until UIEnter
vim.g.time_table = { Startup = vim.uv.hrtime() }
vim.api.nvim_create_autocmd("UIEnter", {
  desc = "Record the nvim startup time",
  once = true,
  group = vim.api.nvim_create_augroup("my.startup_time", { clear = true }),
  callback = function() tied.set_exec_time("Startup") end,
})

vim.loader.enable() -- Cached loader (should improve startup time)
require("ropework") -- Error-handling logic

tied.for_list(
  "Initialize a config file",
  -- Order matters
  {
    "notify",
    "options",
    "pack",
    "usercmds",
    "autocmds",
    "keymaps",
  },
  function(_, file) require("config." .. file).setup() end
)
