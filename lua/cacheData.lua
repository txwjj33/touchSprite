--[[
作用: 缓存数据
时间: 2018.2.2
备注:
]]

require("log")

CacheData = {}

local cachePath = nil

function CacheData.setFileName(name)
    cachePath = string.format("/sdcard/TouchSprite/cache/%s.lua", name)
end

function CacheData.getData()
    assert(cachePath, "must call setFileName first!")
    local func, msg = loadfile(cachePath)
    if func then
        local success, result = pcall(func)
        if success then
            return result
        else
            Log.e("pcall error: %s", result)
            return {}
        end
    else
        Log.w("loadfile error: %s", msg)
        return {}
    end
end

function CacheData.saveData(data)
    assert(cachePath, "must call setFileName first!")
    local file = io.open(cachePath, "w+b")
    if file then
        file:write(table.tostringex(data))
        file:flush()
        io.close(file)
    else
        Log.e("open cache file error")
    end
end

function CacheData.getStringForKey(key, value)
    assert(type(value) == "string", "getStringForKey type error")
    local data = CacheData.getData()
    if data[key] ~= nil then
        return data[key]
    else
        return value
    end
end

function CacheData.setStringForKey(key, value)
    assert(type(value) == "string", "setStringForKey type error")
    local data = CacheData.getData()
    data[key] = value
    CacheData.saveData(data)
end

function CacheData.getNumberForKey(key, value)
    assert(type(value) == "number", "getNumberForKey type error")
    local data = CacheData.getData()
    if data[key] ~= nil and tonumber(data[key]) ~= nil then
        return tonumber(data[key])
    else
        return value
    end
end

function CacheData.setNumberForKey(key, value)
    assert(type(value) == "number", "setNumberForKey type error")
    local data = CacheData.getData()
    data[key] = value
    CacheData.saveData(data)
end

function CacheData.getBoolForKey(key, value)
    assert(type(value) == "boolean", "getBoolForKey type error")
    local data = CacheData.getData()
    if data[key] ~= nil and type(data[key]) == "boolean" then
        return data[key]
    else
        return value
    end
end

function CacheData.setBoolForKey(key, value)
    assert(type(value) == "boolean", "setBoolForKey type error")
    local data = CacheData.getData()
    data[key] = value
    CacheData.saveData(data)
end

function CacheData.deleteValueForKey(key)
    local data = CacheData.getData()
    data[key] = nil
    CacheData.saveData(data)
end
