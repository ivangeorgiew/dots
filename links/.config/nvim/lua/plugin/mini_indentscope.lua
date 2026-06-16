--- @type plugin_spec
local M = {
  -- Show virtual line for current code scope
  src = "nvim-mini/mini.indentscope",
  lazy = true,
  opts = {
    symbol = "▏",
    options = {
      border = "both",
      indent_at_cursor = false, -- if true use cursor column instead of cursor line
      try_as_border = true, -- if true mark start and end lines as part of the inner scope
      n_lines = 10000, -- max lines above or below within which scope is computed
    },
    draw = {
      delay = 100, -- Delay (in ms) between event and start of draw
      priority = 2, -- Increase to display on top of more symbols.
    },
    mappings = {
      -- Use "" to disable one.
      object_scope = "is", -- inside scope
      object_scope_with_border = "as", -- around scope
      goto_top = "[s", -- go to start of scope
      goto_bottom = "]s", -- go to end of scope
    },
  },
}

M.opts.draw.predicate = tie(
  "Plugin mini.indentscope -> opts.draw.predicate",
  ---@param scope table
  ---@return boolean
  function(scope)
    local scope_lines = scope.body.bottom - scope.body.top + 1

    return (not scope.body.is_incomplete and scope_lines >= 2)
  end,
  function() return false end
)

M.opts.draw.animation = tie(
  "Plugin mini.indentscope -> opts.draw.animation",
  ---@param step number
  ---@param n_steps number
  ---@return number
  function(step, n_steps)
    local anim_tbl = require("mini.indentscope").gen_animation
    local anim_opts = {
      easing = "in", --- @type "in"|"out"|"in-out" (default "in-out")
      duration = 10, --- @type number (default 20)
      unit = "step", --- @type "step"|"total" (default "step")
    }
    -- stylua: ignore
    local anim_types = { "none", "linear", "quadratic", "cubic", "quartic", "exponential", }

    return anim_tbl[anim_types[1]](anim_opts)(step, n_steps)
  end,
  function() return 0 end
)

M.config = tie("Plugin mini.indentscope -> config", function(opts)
  require("mini.indentscope").setup(opts)

  tied.set_hl(0, "MiniIndentscopeSymbol", { link = "LineNr" })

  tied.create_autocmd({
    desc = "Set mini.indentscope buffer local options",
    event = "FileType",
    group = tied.create_augroup("my.mini.indentscope", true),
    callback = function(e)
      local ft = e.match
      local indent_langs = { "python", "haskell", "elm", "nim" }

      -- Disable on non-files
      vim.b[e.buf].miniindentscope_disable = (
        not tied.check_if_buf_is_file(e.buf)
      )

      -- Fix scope on off-side rule languages (indent scoped)
      if vim.list_contains(indent_langs, ft) then
        vim.b[e.buf].miniindentscope_config = { options = { border = "top" } }
      end
    end,
  })
end, tied.do_nothing)

return M
