--- @module "blink.cmp"
--- @type plugin_spec
local M = {
  -- Autocompletion
  src = "saghen/blink.cmp",
  version = vim.version.range("1.*"), -- to download prebuilt binaries
  -- TODO: add snippets deps
  -- and setup: https://cmp.saghen.dev/configuration/snippets.html
  -- dependencies = { "rafamadriz/friendly-snippets" },
  lazy = true,
  custom = {},
}

--- @type blink.cmp.Config
M.opts = {
  appearance = {
    nerd_font_variant = "mono",
  },
  fuzzy = {
    max_typos = 0,
    implementation = "prefer_rust_with_warning",
    sorts = { "score", "sort_text", "label" },
  },
  -- Show function signature automatically
  signature = {
    enabled = true,
    window = {
      show_documentation = false,
      treesitter_highlighting = false, -- NOTE: disable if perf. issues
    },
  },
  completion = {
    -- Match before and after cursor for completions
    keyword = { range = "prefix" },
    list = {
      -- So that <C-n> can be used to select and insert first option
      selection = { preselect = false, auto_insert = true },
    },
    -- Completion menu options
    menu = {
      auto_show = true,
      auto_show_delay_ms = 0,
      draw = {
        components = {
          source_name = {
            text = tie(
              "Plugin blink.cmp -> Format completion source",
              function(ctx) return ("[%s]"):format(ctx.source_name) end,
              function() return "" end
            ),
          },
        },
        -- Better visualisation then default
        columns = {
          { "label", "label_description", gap = 1 },
          { "kind_icon", "source_name", gap = 1 },
        },
      },
    },
    ghost_text = { enabled = false },
    documentation = {
      auto_show = true,
      auto_show_delay_ms = 250,
      update_delay_ms = 250,
      treesitter_highlighting = false, -- NOTE: disable if perf. issues
    },
    accept = {
      -- Disable auto () on function name completion
      -- Might need to be disabled in LSPs too
      auto_brackets = { enabled = false },
      -- How long to wait for the LSP to resolve the item with additional info
      resolve_timeout_ms = 100,
    },
    -- NOTE: might want to change those later (there are a bunch more options)
    trigger = {
      show_in_snippet = false,
      show_on_backspace = true,
      show_on_backspace_in_keyword = true,
      -- show_on_insert = true,
      -- show_on_blocked_trigger_characters = {},
      -- show_on_x_blocked_trigger_characters = {},
    },
  },
  -- TODO: https://cmp.saghen.dev/configuration/sources#community-sources
  sources = {
    default = { "lsp", "path", "snippets", "buffer" },
    providers = {
      lsp = { fallbacks = {}, score_offset = 50 },
      path = {
        opts = {
          -- Affects whether path completions are relative to the buffer or the project root
          get_cwd = function(_) return vim.fn.getcwd() end,
          trailing_slash = false,
          label_trailing_slash = true,
        },
      },
    },
  },
}

M.opts.keymap = {
  preset = "none",

  -- stylua: ignore start
  ["<C-e>"] = { "cancel", "fallback" },
  ["<C-Space>"] = { "select_and_accept", "show", "fallback" },

  ["<C-p>"] = { "select_prev", "snippet_backward", "fallback" },
  ["<C-n>"] = { "select_next", "snippet_forward", "fallback" },

  ["<C-b>"] = { "scroll_documentation_up", "fallback" },
  ["<C-f>"] = { "scroll_documentation_down", "fallback" },

  ["<S-Tab>"] = { "snippet_backward", "select_prev", "fallback" }, -- prefer <C-p>
  ["<Tab>"] = { "snippet_forward", "select_next", "fallback" }, -- prefer <C-n>

  ["<C-k>"] = { "show_documentation", "hide_documentation", "fallback_to_mappings" },
  ["<C-j>"] = { "show_signature", "hide_signature", "fallback_to_mappings" },
  -- stylua: ignore end
}

---@type blink.cmp.CmdlineConfigPartial
M.opts.cmdline = {
  enabled = true,
  keymap = { preset = "inherit" },
  completion = {
    list = M.opts.completion.list,
    ghost_text = { enabled = false },
    menu = {
      auto_show = tie(
        "Plugin blink.cmp -> opts.cmdline.completion.menu.auto_show",
        function(ctx) return vim.fn.getcmdtype() == ":" or ctx.mode == "cmdwin" end,
        function() return false end
      ),
    },
  },
}

-- TODO: maybe enable and config
---@type blink.cmp.TermConfigPartial
M.opts.term = { enabled = false }

--- @type blink.cmp.Config
M.custom.lazydev_opts = {
  sources = {
    per_filetype = {
      lua = { inherit_defaults = true, "lazydev" },
    },
    providers = {
      lazydev = {
        name = "LazyDev",
        module = "lazydev.integrations.blink",
        score_offset = 100, -- make top priority
      },
    },
  },
}

M.config = tie("Plugin blink.cmp -> Config", function(opts)
  local to_load = {}

  if tied.plugins["lazydev"] then
    -- Always load lazydev if installed
    -- It has internal logic to enable only on lua projects
    table.insert(to_load, "lazydev")

    opts = vim.tbl_deep_extend("force", opts, M.custom.lazydev_opts)
  end

  tied.load_plugins(to_load)
  tied.on_plugins_load(
    "Run blink.cmp setup()",
    to_load,
    function() require("blink.cmp").setup(opts) end
  )
end, tied.do_nothing)

return M
