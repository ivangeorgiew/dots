-- From: https://github.com/LazyVim/LazyVim/blob/a50f92f7550fb6e9f21c0852e6cb190e6fcd50f5/lua/lazyvim/util/init.lua#L90-L125
local notifs = {}

local orig_notify = vim.notify

--- @type fun(msg: string, level?: number, opts?: table)
local temp_notify = tie(
  "Save notifications for later",
  function(...) table.insert(notifs, vim.F.pack_len(...)) end,
  tied.do_nothing
)

local restore_notify = tie(
  "Restory vim.notify",
  function()
    if vim.notify == temp_notify then
      vim.notify = orig_notify
    end
  end,
  tied.do_nothing
)

tie(
  "Setup notifications delay",
  function()
    local timer = assert(vim.uv.new_timer())
    local check = assert(vim.uv.new_check())

    vim.notify = temp_notify

    local on_notify_change = tie(
      "After vim.notify has changed",
      function()
        timer:stop()
        check:stop()

        -- In case the timer passed
        restore_notify()

        -- Wrap the new notify and try to call the original on error
        local new_notify = vim.notify
        vim.notify = tie(
          "Tied vim.notify",
          new_notify,
          function(props) pcall(orig_notify, unpack(props.args)) end
        )

        vim.schedule(function()
          for _, notif in ipairs(notifs) do
            pcall(vim.notify, vim.F.unpack_len(notif))
          end
        end)
      end,
      restore_notify
    )

    check:start(tie(
      "Check if vim.notify has been replaced",
      function()
        if vim.notify ~= temp_notify then on_notify_change() end
      end,
      function() check:stop() end
    ))

    -- revert to original if too much time passed
    timer:start(500, 0, on_notify_change)
  end,
  restore_notify
)()
