local tie = require('utils').tie

-- autoinvoked by the ':checkhealth' command
return {
  check = tie(
    "checking health",
    {},
    function()
      local h = vim.health
      local ver_str = string.format("%s.%s.%s", vim.version().major, vim.version().minor, vim.version().patch)

      h.start("Global Checks")

      if vim.version.cmp and vim.version.cmp(vim.version(), { 0, 9, 4 }) >= 0 then
        h.ok(string.format("Neovim version is: '%s'", ver_str))
      else
        h.error(string.format("Neovim version is: '%s'. Upgrade to at least 0.9.4", ver_str))
      end

      -- check if required executables exist
      local execs = { 'git', 'make', 'unzip', 'rg', 'lazygit', "fswatch" }

      for _, exe in ipairs(execs) do
        local is_executable = vim.fn.executable(exe) == 1

        if is_executable then
          h.ok(string.format("Executable found: '%s'", exe))
        else
          h.warn(string.format("Could not find: '%s'", exe))
        end
      end
    end
  )
}
