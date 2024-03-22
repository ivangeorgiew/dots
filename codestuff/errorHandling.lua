local tieUp = function (descr, onTry, onError)
  local descrType = type(descr)
  local onTryType = type(onTry)
  local onErrorType = type(onError)

  -- pass 2 as second argument to error in order to blame the caller

  if descrType ~= "string" then
    error("descr must be string, instead got " .. descrType, 2)
  end

  if onTryType ~= "function" then
    error("onTry must be function, instead got " .. onTryType, 2)
  end

  if onErrorType ~= "function" and onErrorType ~= "nil" then
    error("onError must be function or nil, instead got " .. onErrorType, 2)
  end

  local catch = function(args)
    return function (err)
      print("\nError in [" .. descr .. "]:\n" .. err .. "\n")

      if type(onError) == "function" then
        return onError(err, args)
      end
    end
  end

  return function (...)
    local args = table.unpack({...})
    local isIntact, result = xpcall(onTry, catch(args), args)

    return not isIntact, result;
  end
end

--[[
local hasError, result = tieUp(
  "test function",
  function (a)
    print ("function called with " .. a)

    return 100/nil
  end,
  function ()
    print("Invoked the onError function\n")

    return "result from onError"
  end
)(5)

print("hasError: " .. tostring(hasError))
print("result: " .. tostring(result))
--]]

return tieUp
