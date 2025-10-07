-- autoinvoked by the ':checkhealth' command
return {
  check = tie(
    "check health",
    function()
      local h = vim.health
      local min_ver = { 0, 11, 2 }
      local ver_str = string.format("%s.%s.%s", vim.version().major, vim.version().minor, vim.version().patch)

      h.start("Global Checks")

      if vim.version.cmp and vim.version.cmp(vim.version(), min_ver) >= 0 then
        h.ok(string.format("Neovim version is: '%s'", ver_str))
      else
        h.error(string.format("Neovim version is: '%s'. Upgrade to at least '%s'", ver_str, table.concat(min_ver, '.')))
      end

      -- check if required executables exist
      local execs = {
        "curl",
        "fd",
        "fswatch",
        "fzf",
        "git",
        "lazygit",
        "make",
        "rg",
        "unzip",
      }

      for _, exe in ipairs(execs) do
        local is_executable = vim.fn.executable(exe) == 1

        if is_executable then
          h.ok(string.format("Executable found: '%s'", exe))
        else
          h.warn(string.format("Could not find: '%s'", exe))
        end
      end
    end,
    do_nothing
  )
}
