local check_exes = tie(
  "Check if executables are installed",
  ---@param name string
  ---@param exes string[]
  function(name, exes)
    vim.validate("name", name, "string")
    vim.validate("exes", exes, "table")

    local h = vim.health

    h.start(name)

    tied.for_list("Warn if executable is missing", exes, function(_, exe)
      local is_executable = vim.fn.executable(exe) == 1

      if is_executable then
        h.ok(("Executable found: '%s'"):format(exe))
      else
        h.warn(("Could not find: '%s'"):format(exe))
      end
    end)
  end,
  tied.do_nothing
)

-- Autoinvoked by the ':checkhealth config' command
return {
  check = tie("Check health", function()
    local h = vim.health
    local min_ver = { 0, 12, 0 }
    local ver_str = string.format(
      "%s.%s.%s",
      vim.version().major,
      vim.version().minor,
      vim.version().patch
    )

    if vim.version.cmp and vim.version.cmp(vim.version(), min_ver) >= 0 then
      h.ok(("Neovim version is: '%s'"):format(ver_str))
    else
      h.error(
        string.format(
          "Neovim version is: '%s'. Upgrade to at least '%s'",
          ver_str,
          table.concat(min_ver, ".")
        )
      )
    end

    check_exes("Checks for utils:", {
      "curl",
      "fd",
      "fswatch",
      "fzf",
      "git",
      "lazygit",
      "make",
      "rg",
      "unzip",
    })

    check_exes(
      "Checks for LSPs, formatters, linters, etc:",
      vim.list.unique(tied.exes)
    )
  end, tied.do_nothing),
}
