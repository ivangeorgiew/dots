--- @type table<string,MyLazySpec>
local M = {
  -- TODO: check the wiki: https://github.com/nvim-tree/nvim-tree.lua/wiki
  nvim_tree = {
    -- File tree viewer
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
  },
}

-- More options at
-- :h nvim-tree-opts
M.nvim_tree.opts = {
  hijack_cursor = true, -- keep cursor on first letter of filenames
  disable_netrw = true,
  sync_root_with_cwd = true, -- sync on event DirChanged
  select_prompts = true, -- use vim.ui.select
  sort = {
    sorter = "case_sensitive",
  },
  view = {
    width = 30,
    preserve_window_proportions = true,
  },
  live_filter = {
    prefix = "Filter: ",
    always_show_folders = false,
  },
  renderer = {
    add_trailing = true, -- add / after folders
    group_empty = true, -- group empty folders
    root_folder_label = false, -- disable root folder label
    special_files = {}, -- remove highlights of special files
    symlink_destination = true, -- show symlinks
    hidden_display = "simple", -- show how many hidden files
    highlight_git = "none",
    highlight_diagnostics = "name",
    indent_markers = { enable = true },
    icons = {
      show = {
        git = false,
        folder_arrow = false,
      },
    },
  },
  update_focused_file = {
    enable = true,
    update_root = { enable = false },
  },
  diagnostics = {
    enable = true,
    debounce_delay = 250,
    show_on_dirs = true,
    severity = {
      min = vim.diagnostic.severity.WARN,
    },
  },
  actions = {
    open_file = {
      quit_on_open = true,
    },
  },
  tab = {
    sync = {
      open = true,
      close = true,
    },
  },
  ui = {
    confirm = {
      default_yes = true,
    },
  },
  on_attach = tie("Plugin nvim-tree -> On attach", function(bufnr)
    -- See the default mappings with
    -- :h nvim-tree-mappings-default

    local api = require("nvim-tree.api")

    local toggle_folder = function()
      local node = api.tree.get_node_under_cursor()

      if node.nodes ~= nil then
        api.node.open.edit()
      else
        api.node.navigate.parent_close()
      end
    end

    -- NOTE: don't delete them, just un/comment and change if needed
    local maps = {
      -- { api.fs.copy.basename, "yn", "Yank file name" },
      -- { api.fs.copy.filename, "yf", "Yank full file name" },
      { api.fs.copy.absolute_path, "yP", "Yank absolute path" },
      { api.fs.copy.relative_path, "yp", "Yank relative path" },
      { api.fs.copy.node, "c", "Copy file" },
      { api.fs.create, "a", "Create file or directory" },
      { api.fs.cut, "x", "Cut file" },
      { api.fs.paste, "p", "Paste file" },
      { api.fs.remove, "d", "Delete file" },
      { api.fs.rename, "r", "Rename file" },
      -- { api.fs.rename_basename, "e", "Rename: Basename" },
      -- { api.fs.rename_full, "u", "Rename: Full Path" },
      -- { api.fs.rename_sub, "<C-r>", "Rename: Omit Filename" },
      -- { api.fs.trash, "D", "Trash" },
      { api.live_filter.clear, "F", "Live Filter: Clear" },
      { api.live_filter.start, "f", "Live Filter: Start" },
      -- { api.marks.bulk.delete, "bd", "Delete Bookmarked" },
      -- { api.marks.bulk.move, "bmv", "Move Bookmarked" },
      -- { api.marks.bulk.trash, "bt", "Trash Bookmarked" },
      -- { api.marks.toggle, "m", "Toggle Bookmark" },
      -- { api.node.navigate.diagnostics.next, "]e", "Next Diagnostic" },
      -- { api.node.navigate.diagnostics.prev, "[e", "Prev Diagnostic" },
      -- { api.node.navigate.git.next, "]c", "Next Git" },
      -- { api.node.navigate.git.prev, "[c", "Prev Git" },
      -- { api.node.navigate.parent_close, "<BS>", "Close Directory" },
      { api.node.navigate.parent, "P", "Parent Directory" },
      { api.node.navigate.sibling.first, "K", "First Sibling" },
      { api.node.navigate.sibling.last, "J", "Last Sibling" },
      { api.node.navigate.sibling.next, ">", "Next Sibling" },
      { api.node.navigate.sibling.prev, "<", "Previous Sibling" },
      { api.node.open.preview, "o", "Open preview" },
      { api.node.open.edit, "<CR>", "Open" },
      { api.node.open.horizontal, "<C-i>", "Open: Horizontal Split" },
      { api.node.open.tab, "<C-t>", "Open: New Tab" },
      { api.node.open.vertical, "<C-v>", "Open: Vertical Split" },
      -- { api.node.open.no_window_picker, "O", "Open: No Window Picker" },
      -- { api.node.open.replace_tree_buffer, "<C-e>", "Open: In Place" },
      -- { api.node.open.toggle_group_empty, "L", "Toggle Group Empty" },
      -- { api.node.run.cmd, ".", "Run Command" },
      -- { api.node.run.system, "s", "Run System" },
      -- { api.node.show_info_popup, "<C-k>", "Info" },
      { api.tree.change_root_to_node, "_", "Change root dir" },
      { api.tree.change_root_to_parent, "-", "Up root dir" },
      -- { api.tree.close, "q", "Close" },
      { api.tree.collapse_all, "W", "Collapse All" },
      { api.tree.expand_all, "C", "Expand All" },
      { toggle_folder, "e", "Toggle folder" },
      -- { api.tree.reload, "R", "Refresh" },
      -- { api.tree.search_node, "S", "Search" },
      -- { api.tree.toggle_custom_filter, "U", "Toggle Filter: Hidden" },
      -- { api.tree.toggle_git_clean_filter, "C", "Toggle Filter: Git Clean" },
      -- { api.tree.toggle_gitignore_filter, "I", "Toggle Filter: Git Ignore" },
      { api.tree.toggle_help, "?", "Help" },
      -- { api.tree.toggle_hidden_filter, "H", "Toggle Filter: Dotfiles" },
      -- { api.tree.toggle_no_bookmark_filter, "M", "Toggle Filter: No Bookmark" },
      -- { api.tree.toggle_no_buffer_filter, "B", "Toggle Filter: No Buffer" },
    }

    tied.each_i(
      maps,
      "Plugin nvim_tree -> Create keymap",
      function(_, map)
        tied.create_map(
          "n",
          map[2],
          map[1],
          { desc = "NvimTree -> " .. map[3], buffer = bufnr, nowait = true }
        )
      end
    )
  end, tied.do_nothing),
}

M.nvim_tree.config = tie("Plugin nvim-tree -> config", function(_, opts)
  require("nvim-tree").setup(opts)

  vim.api.nvim_set_hl(0, "NvimTreeWinSeparator", { link = "WinSeparator" })

  tied.create_map(
    "n",
    "<leader>ta",
    "<cmd>NvimTreeToggle<cr><cmd>wincmd =<cr>",
    { desc = "Toggle NvimTree" }
  )
end, tied.do_nothing)

return M
