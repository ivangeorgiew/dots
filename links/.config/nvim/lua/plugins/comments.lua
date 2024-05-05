local tie = require("utils").tie
local map = require("utils").map

return {
  {
    "numToStr/Comment.nvim",
    keys = {
      { "gcc", mode = "n" },
      { "gbc", mode = "n" },
      { "gc",  mode = { "n", "v" } },
      { "gb",  mode = { "n", "v" } },
    },
    --event = "VeryLazy",
    config = tie(
    "config for Comment",
    {},
    function()
      require("Comment").setup({
        padding = true, -- Add a space b/w comment and the line
        sticky = true, -- Whether the cursor should stay at its position
        ignore = "^$", -- Lines to be ignored while (un)comment
        mappings = { basic = true, extra = false, }, -- Toggles keybindings creation
        toggler = { line = "gcc", block = "gbc", }, -- LHS of toggle mappings in NORMAL mode
        opleader = { line = "gc", block = "gb", }, -- LHS of operator-pending mappings in NORMAL and VISUAL mode
        extra = { above = "gcO", below = "gco", eol = "gcA", }, -- LHS of extra mappings
        pre_hook = nil, -- Function to call before (un)comment
        post_hook = nil, -- Function to call after (un)comment
      })

      local ft = require("Comment/ft")

      -- can add/modify commentstrings by filetype
      -- ft.javascript = { "//%s", "/*%s*/" }
    end
    )
  },
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = "BufReadPost",
    config = function()
      require("todo-comments").setup({
        signs = false, -- show icons in the signs column
        sign_priority = 8, -- sign priority
        -- keywords recognized as todo comments
        keywords = {
          FIX = {
            icon = " ", -- icon used for the sign, and in search results
            color = "error", -- can be a hex color, or a named color (see below)
            alt = { "FIXME", "FIXIT", "BUG", "ISSUE", "ERROR" }, -- a set of other keywords that all map to this FIX keywords
            -- signs = false, -- configure signs for some keywords individually
          },
          TODO = { icon = " ", color = "warning", alt = { "WARN", "HACK", "PERF" } },
          NOTE = { icon = " ", color = "info", alt = { "INFO" } },
          TEST = { icon = " ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
        },
        gui_style = {
          fg = "NONE", -- The gui style to use for the fg highlight group.
          bg = "BOLD", -- The gui style to use for the bg highlight group.
        },
        merge_keywords = true, -- when true, custom keywords will be merged with the defaults
        -- highlighting of the line containing the todo comment
        -- * before: highlights before the keyword (typically comment characters)
        -- * keyword: highlights of the keyword
        -- * after: highlights after the keyword (todo text)
        highlight = {
          multiline = true, -- enable multine todo comments
          multiline_pattern = "^.", -- lua pattern to match the next multiline from the start of the matched keyword
          multiline_context = 10, -- extra lines that will be re-evaluated when changing a line
          before = "", -- "fg" or "bg" or empty
          keyword = "bg", -- "fg", "bg", "wide" or empty. (wide is the same as bg, but will also highlight surrounding characters)
          after = "fg", -- "fg" or "bg" or empty
          -- pattern can be a string, or a table of regexes that will be checked
          pattern = [[.*<(KEYWORDS):]], -- pattern or table of patterns, used for highlightng (vim regex)
          -- pattern = { [[.*<(KEYWORDS)\s*:]], [[.*\@(KEYWORDS)\s*]] }, -- pattern used for highlightng (vim regex)
          comments_only = true, -- uses treesitter to match keywords in comments only
          max_line_len = 400, -- ignore lines longer than this
          exclude = {}, -- list of file types to exclude highlighting
          throttle = 200,
        },
        -- list of named colors where we try to extract the guifg from the
        -- list of hilight groups or use the hex color if hl not found as a fallback
        colors = {
          error = { "DiagnosticError", "ErrorMsg", "#DC2626" },
          warning = { "DiagnosticWarn", "WarningMsg", "#FBBF24" },
          info = { "DiagnosticInfo", "#2563EB" },
          hint = { "DiagnosticHint", "#10B981" },
          default = { "Identifier", "#7C3AED" },
          test = { "Identifier", "#FF00FF" },
        },
        search = {
          command = "rg",
          args = {
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
          },
          -- regex that will be used to match keywords.
          -- don't replace the (KEYWORDS) placeholder
          pattern = [[\b(KEYWORDS):]], -- ripgrep regex
          -- pattern = [[\b(KEYWORDS)\b]], -- match without the extra colon. You'll likely get false positives
        },
      })

      map("n", "<leader>pt", require("todo-comments").jump_prev, { desc = "Prev Todo (or other special) comment" })
      map("n", "<leader>nt", require("todo-comments").jump_next, { desc = "Next Todo (or other special) comment" })
    end
  }
}
