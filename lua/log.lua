--[[
作用: log相关封装
时间: 2015.1.16
备注:
]]

Log = {}

local logName = nil

-- 开始把log写到自定义文件
function Log.start(appName)
    if not appName then
        print("Log.start need appName")
        lua_exit()
    end
    logName = appName .. os.date("_%Y_%m_%d-%H_%M_%S")
end

local function write(tag, format, ...)
    local args = {...}
    if not format then
        return
    elseif #args > 0 then
        log(tag .. string.format(format, ... ), logName)
    else
        log(tag .. tostring(format), logName)
    end
end

function Log.e(format, ...)
    write("[E]: ", format, ...)
end

function Log.w(format, ...)
    write("[W]: ", format, ...)
end

function Log.i(format, ...)
    write("[I]: ", format, ...)
end

function Log.d(format, ...)
    if DEBUG then
        write("[D]: ", format, ...)
    end
end

function Log.printArgs(...)
    local str = ""
    for i, v in ipairs({...}) do
        if i > 1 then str = str .. "-" end
        str = str .. tostring(v)
    end
    Log.d(str)
end

function Log.getLogName()
    return logName
end

function Log.getLogPath()
    return "/sdcard/TouchSprite/log"
end
