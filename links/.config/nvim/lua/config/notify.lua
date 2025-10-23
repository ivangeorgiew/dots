-- From: https://github.com/LazyVim/LazyVim/blob/a50f92f7550fb6e9f21c0852e6cb190e6fcd50f5/lua/lazyvim/util/init.lua#L90-L125
local M = {}

M.notifs = {}

M.orig_notify = vim.notify
M.temp_notify = tie(
  "save notifications for later",
  function(...) table.insert(M.notifs, vim.F.pack_len(...)) end,
  tied.do_nothing
)

M.restore_notify = tie(
  "restory vim.notify",
  function()
    if vim.notify == M.temp_notify then
      vim.notify = M.orig_notify
    end
  end,
  tied.do_nothing
)

M.setup = tie(
  "setup notifications delay",
  function()
    local timer = assert(vim.uv.new_timer())
    local check = assert(vim.uv.new_check())

    vim.notify = M.temp_notify

    local on_notify_change = tie(
      "after vim.notify has changed",
      function()
        timer:stop()
        check:stop()

        -- in case 500ms timer passed
        M.restore_notify()

        vim.schedule(tie(
          "play the stored notifications",
          function()
            for _, notif in ipairs(M.notifs) do
              vim.notify(vim.F.unpack_len(notif))
            end
          end,
          tied.do_nothing
        ))
      end,
      M.restore_notify
    )

    check:start(tie(
      "check if vim.notify has been replaced",
      function()
        if vim.notify ~= M.temp_notify then on_notify_change() end
      end,
      tied.do_rethrow
    ))

    -- if it took more than 500ms revert to original
    timer:start(500, 0, on_notify_change)
  end,
  M.restore_notify
)

return M
