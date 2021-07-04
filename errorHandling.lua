function genericTieUp (onTry, onError, shouldCall)
    if type(onTry) ~= "function" then
        error("onTry must be function, instead got " .. type(onTry))
    end

    local catch = function (err)
        print("ERROR:", err)

        if type(onError) == "function" then
            return onError(err)
        elseif type(onError) ~= "nil" then
            error("onError must be function, instead got " .. type(onError))
        end
    end

    if shouldCall == true then
        return xpcall(onTry, catch)
    else
        return function (...)
            return xpcall(onTry, catch, table.unpack({...}))
        end 
    end
end

local callTiedUp = function (onTry, onError)
    return genericTieUp(onTry, onError, true)
end

local tieUp = function (onTry, onError)
    return genericTieUp(onTry, onError, false)
end

callTiedUp(
    function ()
        print ("callTiedUp called")
        n = n/nil
    end,
    function ()
        print("custom handler")
    end
)

local myfunc = tieUp(
    function (a)
        print ("function called with " .. a)
        n = n/nil
    end,
    function ()
        print("custom handler")
    end
)

myfunc(5)
