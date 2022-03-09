function generic_tie_up (descr, on_try, on_catch, should_call)
    if type(descr) ~= "string" then
        error("descr must be string, instead got " .. type(descr))
    end

    if type(on_try) ~= "function" then
        error("on_try must be function, instead got " .. type(on_try))
    end

    if type(should_call) ~= "boolean" then
        error("should_call must be boolean, instead got " .. type(should_call))
    end

    local inner_catch = function (args)
        return function (error)
            local strigified_args = ""

            for i,v in ipairs(args) do
                strigified_args = strigified_args .. tostring(v) .. " "
            end

            print("\n  Error at: " .. descr)
            if should_call == false then
                print("  Function args: " .. strigified_args)
            end
            print("  " .. error .. "\n")

            if type(on_catch) == "function" then
                return on_catch(descr, args, error)
            end
        end
    end

    if should_call == true then
        return xpcall(on_try, inner_catch({}))
    else
        return function (...)
            return xpcall(on_try, inner_catch({...}), table.unpack({...}))
        end
    end
end

local call_tied_up = function (descr, on_try, on_catch)
    return generic_tie_up(descr, on_try, on_catch, true)
end

local tie_up = function (descr, on_try, on_catch)
    return generic_tie_up(descr, on_try, on_catch, false)
end

call_tied_up(
    "executing order 66",
    function ()
        print ("call_tied_up called")
        n = 5/nil
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
    function (descr, args, error)
        print("custom handler for " .. descr)
        for i,v in ipairs(args) do
            print(tostring(v))
        end
    end
)

myfunc(5, 10, true, "sup")
