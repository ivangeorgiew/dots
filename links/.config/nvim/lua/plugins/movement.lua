---@type LazyPluginSpec|LazyPluginSpec[]
return {
  {
    -- TODO I can use Snacks.scroll as alternative
    "karb94/neoscroll.nvim",
    event = "User FilePost",
    opts = {
      hide_cursor = true,
      stop_eof = true,
      respect_scrolloff = false,
      cursor_scrolls_alone = true,
      duration_multiplier = 0.5,
      easing = "linear",
      -- pre_hook = tie("Plugin neoscroll -> pre_hook", function() vim.wo.cursorline = false end, tied.do_nothing),
      -- post_hook = tie("Plugin neoscroll -> post_hook", function() vim.wo.cursorline = true end, tied.do_nothing),
    },
  }
}
