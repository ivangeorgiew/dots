-- Settings for both quickfix and loclist buffers

vim.cmd("wincmd J") -- move to the bottom of all other windows

local replace_text = tie("Replace text in files", function()
  tied.ui_input({ prompt = "Search for: " }, function(search)
    if type(search) ~= "string" then
      return
    end

    tied.ui_input({ prompt = "Replace with: " }, function(replace)
      if type(replace) ~= "string" then
        return
      end

      tied.ui_select(
        { "Yes, but only full words", "Yes, any occurance", "No" },
        { prompt = ("Replace `%s` with `%s` ?"):format(search, replace) },
        function(choice)
          if type(choice) ~= "string" then
            return
          end

          if choice:match("full words") then
            search = ("\\<%s\\>"):format(search)
          end

          if choice:match("Yes") then
            vim.cmd("cfirst | only | copen")
            vim.cmd(
              ("%s %%sno@%s@%s@gIe | update | bdelete"):format(
                "silent noautocmd keepjumps keepalt cfdo",
                search,
                replace
              )
            )
            vim.cmd("clast | cclose")
            vim.cmd([[exe "normal! 2\<c-o>"]])
          end
        end
      )
    end)
  end)
end, tied.do_nothing)

---@type KeymapSetArgs[]
local maps = {
  -- stylua: ignore start
  { "n", "<C-r>", replace_text, { desc = "Replace text in files" } },
  { "n", "<CR>",  "<CR>:cclose<cr>", { desc = "Open list item" } },
  { "n", "o",     "<CR>:cclose<cr>:copen<cr>", { desc = "Preview list item" } },
  { "n", "<C-s>", "<C-w><CR>:cclose<cr>", { desc = "Open list item in hor. split" } },
  { "n", "<C-v>", "<C-w><CR>:cclose<cr><C-w>L", { desc = "Open list item in vert. split" } },
  { "n", "<C-t>", "<C-w><CR>:cclose<cr><C-w>T", { desc = "Open list item in new tab" } },
  -- stylua: ignore end
}

tied.for_list("Create quickfix/loc list keymap", maps, function(_, map_args)
  map_args[4].buf = 0
  tied.create_map(unpack(map_args))
end)
