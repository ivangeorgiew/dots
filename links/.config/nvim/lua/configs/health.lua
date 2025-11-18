-- autoinvoked by the ':checkhealth' command
return {
  check = tie("Check health", function()
    local h = vim.health
    local min_ver = { 0, 11, 2 }
    local ver_str = string.format(
      "%s.%s.%s",
      vim.version().major,
      vim.version().minor,
      vim.version().patch
    )

    h.start("Global Checks")

    if vim.version.cmp and vim.version.cmp(vim.version(), min_ver) >= 0 then
      h.ok(string.format("Neovim version is: '%s'", ver_str))
    else
      h.error(
        string.format(
          "Neovim version is: '%s'. Upgrade to at least '%s'",
          ver_str,
          table.concat(min_ver, ".")
        )
      )
    end

    tied.each_i(
      {
        "curl",
        "fd",
        "fswatch",
        "fzf",
        "git",
        "lazygit",
        "make",
        "rg",
        "unzip",
      },
      "Warn if executable is missing",
      function(_, exe)
        local is_executable = vim.fn.executable(exe) == 1

        if is_executable then
          h.ok(string.format("Executable found: '%s'", exe))
        else
          h.warn(string.format("Could not find: '%s'", exe))
        end
      end
    )
  end, tied.do_nothing),
}
