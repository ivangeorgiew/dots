function generic_tie_up (descr, on_try, on_error, should_call)
    if type(descr) ~= "string" then
        error("descr must be string, instead got " .. type(descr))
    end

    if type(on_try) ~= "function" then
        error("on_try must be function, instead got " .. type(on_try))
    end

    local inner_on_error = function (err)
        print("  Issue with " .. descr .. ":")
        print("  " .. err)

        if type(on_error) == "function" then
            return on_error(err)
        elseif type(on_error) ~= "nil" then
            error("on_error must be function, instead got " .. type(on_error))
        end
    end

    if should_call == true then
        return xpcall(on_try, inner_on_error)
    else
        return function (...)
            return xpcall(on_try, inner_on_error, table.unpack({...}))
        end 
    end
end

local call_tied_up = function (descr, on_try, on_error)
    return generic_tie_up(descr, on_try, on_error, true)
end

local tie_up = function (descr, on_try, on_error)
    return generic_tie_up(descr, on_try, on_error, false)
end

call_tied_up(
    "executing order 66",
    function ()
        print ("call_tied_up called")
        n = n/nil
    end,
    function ()
        print("custom handler")
    end
)

local myfunc = tie_up(
    "executing order 66",
    function (a)
        print ("function called with " .. a)
        n = n/nil
    end,
    function ()
        print("custom handler")
    end
)

myfunc(5)
