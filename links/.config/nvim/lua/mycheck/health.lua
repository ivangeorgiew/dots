local tie = require('utils').tie

-- autoinvoked by the ':checkhealth' command
return {
  check = tie(
    "checking health",
    {},
    function()
      local uv = require('utils').uv
      local ver_str = string.format("%s.%s.%s", vim.version().major, vim.version().minor, vim.version().patch)

      vim.health.start("Neovim")

      if vim.version.cmp and vim.version.cmp(vim.version(), { 0, 9, 4 }) >= 0 then
        vim.health.ok(string.format("Version is: '%s'", ver_str))
      else
        vim.health.error(string.format("Version is: '%s'. Upgrade to at least 0.9.4", ver_str))
      end

      vim.health.start("Global Executables")

      -- check if required executables exist
      local execs = { 'git', 'make', 'unzip', 'rg', 'lazygit', "fswatch" }

      for _, exe in ipairs(execs) do
        local is_executable = vim.fn.executable(exe) == 1

        if is_executable then
          vim.health.ok(string.format("Found: '%s'", exe))
        else
          vim.health.warn(string.format("Could not find: '%s'", exe))
        end
      end
    end
  )
}
