local tie_up = require("tie_up")

local au = tie_up(
  "create augroup",
  { "string", { "string", "table" }, "table"},
  function(group_name, events, opts)
    opts.group = vim.api.nvim_create_augroup(group_name, { clear = true })

    if type(opts.callback) == "function" then
      opts.callback = tie_up(group_name, {}, opts.callback)
    end

    vim.api.nvim_create_autocmd(events, opts)
  end
)

au(
  "reload_file_on_change",
  { "FocusGained", "TermClose", "TermLeave" },
  { command = "checktime" }
)

au(
  "highlight_on_yank",
  "TextYankPost",
  { callback = function() vim.highlight.on_yank() end, }
)

au(
  "resize_splits_on_window_resize",
  "VimResized",
  {
    callback = function()
      local current_tab = vim.fn.tabpagenr()
      vim.cmd("tabdo wincmd =")
      vim.cmd("tabnext " .. current_tab)
    end,
  }
)

au(
  "wrap_and_spell_in_text_files",
  "FileType",
  {
    pattern = { "gitcommit", "markdown" },
    callback = function()
      vim.opt_local.wrap = true
      vim.opt_local.spell = true
    end,
  }
)

au(
  "set_buffer_options",
  "BufEnter",
  {
    callback = function()
      local o = vim.opt

      o.formatoptions = "tcrqlj" -- formatting options
    end
  }
)
