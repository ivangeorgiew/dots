-- TODO: I can use Snacks.scroll as alternative

--- @type plugin_spec
local M = {
  -- Smooth scrolling in files
  src = "karb94/neoscroll.nvim",
  lazy = true,
  opts = {
    mappings = { "<C-u>", "<C-d>" },
    hide_cursor = false,
    stop_eof = true,
    respect_scrolloff = false,
    cursor_scrolls_alone = true,
    duration_multiplier = 0.333,
    easing = "linear",
    -- pre_hook = tie("Plugin neoscroll -> pre_hook", function() vim.wo.cursorline = false end, tied.do_nothing),
    -- post_hook = tie("Plugin neoscroll -> post_hook", function() vim.wo.cursorline = true end, tied.do_nothing),
  },
}

return M
