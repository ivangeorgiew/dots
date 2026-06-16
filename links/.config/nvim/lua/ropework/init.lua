require("ropework.tie") -- error-handling wrapper function

tie(
  "Replace some global functions",
  function() require("ropework.builtins") end,
  tied.do_nothing
)()

tie(
  "Add global utils",
  function() require("ropework.utils") end,
  tied.do_rethrow
)()
