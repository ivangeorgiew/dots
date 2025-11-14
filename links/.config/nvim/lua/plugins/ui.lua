--- @type table<string,MyLazySpec>
local M = {
  -- NOTE: Alternatives are "saghen/blink.indent", "folke/snacks.nvim".indent
  indentscope = {
    -- Show virtual line for current code scope
    "nvim-mini/mini.indentscope",
    version = false,
    event = "User FilePost",
  },
}

M.indentscope.opts = {
  symbol = "▏",
  options = {
    indent_at_cursor = false, -- if true use cursor column instead of cursor line
    try_as_border = false, -- if true mark start and end lines as part of the inner scope
    n_lines = 10000, -- max lines above or below within which scope is computed
  },
  draw = {
    -- animation() and predicate() are setup in M.config()
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
}

M.indentscope.extra_opts = {
  min_lines = 2, -- Min lines to show scope for
  hl_group = "LineNr", -- Highlight group to use (ex: "LineNr" or "Whitespace")
  anim_opts = {
    equation_idx = 2, -- 1 for no animation
    easing = "in", --- @type "in"|"out"|"in-out" (default "in-out")
    duration = 10, --- @type number (default 20)
    unit = "step", --- @type "step"|"total" (default "step")
  },
  ignore = {
    ft = {
      "checkhealth", "gitcommit", "help", "lspinfo", "man", "",
      "TelescopePrompt", "TelescopeResults",
    },
    bt = {
      "nofile", "prompt", "quickfix", "terminal",
    },
  },
}

M.indentscope.config = tie(
  "Plugin mini.indentscope -> config",
  function(_, opts)
    local extra_opts = M.indentscope.extra_opts or {}

    opts.draw.predicate = tie(
      "Plugin mini.indentscope -> opts.draw.predicate",
      ---@param scope table
      ---@return boolean
      function(scope)
        local scope_lines = scope.border.bottom - scope.border.top

        return (
          not scope.body.is_incomplete and
          scope_lines > extra_opts.min_lines
        )
      end,
      function() return false end
    )

    opts.draw.animation = tie(
      "Plugin mini.indentscope -> opts.draw.animation",
      ---@param step number
      ---@param n_steps number
      ---@return number
      function(step, n_steps)
        local anim_tbl = require("mini.indentscope").gen_animation
        local anim_types = {
          "none", "linear", "quadratic",
          "cubic", "quartic", "exponential"
        }
        local anim_opts = extra_opts.anim_opts
        local anim_type = anim_types[anim_opts.equation_idx]

        return anim_tbl[anim_type](anim_opts)(step, n_steps)
      end,
      function() return 0 end
    )

    require("mini.indentscope").setup(opts)

    -- Change the symbol color
    vim.api.nvim_set_hl(0, "MiniIndentscopeSymbol", { link = extra_opts.hl_group })

    tied.create_autocmd({
      desc = "Disable plugin mini.indentscope on certain buffers/filetypes",
      event = "BufEnter",
      group = tied.create_augroup("my.mini.indentscope.ignore", true),
      callback = function(e)
        vim.b[e.buf].miniindentscope_disable = (
          vim.list_contains(extra_opts.ignore.bt, vim.bo[e.buf].buftype) or
          vim.list_contains(extra_opts.ignore.ft, vim.bo[e.buf].filetype)
        )
      end
    })

    tied.on_plugin_load(
      { "which-key.nvim" },
      "Modify mini.indentscope mappings for which-key",
      function()
        local maps = {}
        local desc_tbl = {
          object_scope = "inner scope",
          object_scope_with_border = "scope",
          goto_top = "Scope start",
          goto_bottom = "Scope end",
        }

        for k, v in pairs(desc_tbl) do
          local lhs = opts.mappings[k]

          if lhs ~= "" then
            maps[#maps + 1] = { lhs, desc = v }
          end
        end

        if #maps > 0 then
          maps.mode = { "o", "x", }
          require("which-key").add(maps)
        end
      end
    )
  end,
  tied.do_nothing
)

return M
