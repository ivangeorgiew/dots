-- From: https://github.com/LazyVim/LazyVim/blob/a50f92f7550fb6e9f21c0852e6cb190e6fcd50f5/lua/lazyvim/util/init.lua#L90-L125
local M = {}

---@type table[]
M.notifs = {}

M.orig_notify = vim.notify

--- @type fun(msg: string, level?: number, opts?: table)
M.temp_notify = tie(
  "Save notifications for later",
  function(...) table.insert(M.notifs, vim.F.pack_len(...)) end,
  tied.do_nothing
)

M.restore_notify = tie("Restory vim.notify", function()
  if vim.notify == M.temp_notify then
    vim.notify = M.orig_notify
  end
end, tied.do_nothing)

M.setup = tie("Setup notifications delay", function()
  local timer = assert(vim.uv.new_timer())
  local check = assert(vim.uv.new_check())

  vim.notify = M.temp_notify

  local on_notify_change = tie("After vim.notify has changed", function()
    check:stop()
    timer:stop()
    timer:close()

    -- In case the timer passed
    M.restore_notify()

    -- Wrap the new notify and try to call the original on error
    local new_notify = vim.notify

    vim.notify = tie(
      "Tied vim.notify",
      new_notify,
      function(props) pcall(M.orig_notify, unpack(props.args)) end
    )

    tied.each_i(
      "Play stored delayed notification",
      M.notifs,
      vim.schedule_wrap(
        function(_, notif) vim.notify(vim.F.unpack_len(notif)) end
      )
    )
  end, M.restore_notify)

  check:start(tie("Check if vim.notify has been replaced", function()
    if vim.notify ~= M.temp_notify then
      on_notify_change()
    end
  end, function() check:stop() end))

  -- revert to original if too much time passed
  timer:start(500, 0, on_notify_change)
end, M.restore_notify)

return M
