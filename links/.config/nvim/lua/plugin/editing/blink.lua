--- @module "blink-cmp"
--- @type MyLazySpec
local M = {
  -- Autocompletion
  "saghen/blink.cmp",
  version = "1.*", -- to download prebuilt binaries
  -- TODO: add snippets deps
  -- and setup: https://cmp.saghen.dev/configuration/snippets.html
  -- dependencies = { "rafamadriz/friendly-snippets" },
  event = "ModeChanged",
  extra = {},
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
      treesitter_highlighting = true, -- NOTE: disable if perf. issues
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
        -- Better visualisation then default
        columns = {
          { "label", "label_description", gap = 1 },
          { "kind_icon", "kind", gap = 1 },
        },
      },
    },
    ghost_text = { enabled = false },
    documentation = {
      auto_show = true,
      auto_show_delay_ms = 250,
      update_delay_ms = 250,
      treesitter_highlighting = true, -- NOTE: disable if perf. issues
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
      show_in_snippet = true,
      show_on_backspace = true,
    },
  },
  -- TODO: https://cmp.saghen.dev/configuration/sources#community-sources
  sources = {
    default = { "lsp", "path", "snippets", "buffer" },
    providers = {
      path = {
        opts = {
          -- Affects whether path completions are relative to the buffer or the project root
          get_cwd = vim.fn.getcwd,
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

  ["<S-Tab>"] = { "snippet_backward", "fallback" }, -- prefer <C-p>
  ["<Tab>"] = { "snippet_forward", "fallback" }, -- prefer <C-n>

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
M.extra.lazydev_opts = {
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

M.config = tie("Plugin blink.cmp", function(_, opts)
  tied.do_block(
    "Plugin blink.cmp -> Add lazydev completions to lua files",
    function()
      if not tied.has_plugin("lazydev.nvim") then
        return
      end

      opts = vim.tbl_deep_extend("force", opts, M.extra.lazydev_opts)
    end
  )

  require("blink.cmp").setup(opts)
end, tied.do_nothing)

return M
