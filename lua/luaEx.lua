--[[
作用: lua的增强库函数
时间: 2015.1.16
备注:
]]

-------------------------------table的扩充函数-------------------------------
-- 输出table
function table.print(luaTable, printInRelease)
    if not printInRelease and not DEBUG then return end

    local log = printInRelease and Log.i or Log.d
    local info = debug.getinfo(2, "Sln")
    if not info then return end
    log("---------------------- table ------------------------------")
    log("%s in line %d", info.short_src, info.currentline)

    if type(luaTable) ~= "table" then
        Log.e("table.print error, not table, type:%s", type(luaTable))
        return
    end

    log(table.tostring(luaTable))
    log("-----------------------------------------------------------")
end

--table转化成string
function table.tostring(luaTable, addLineBreak, indent)
    if type(luaTable) ~= "table" then
        Log.e("table.tostring error, not table, type:%s", type(luaTable))
        return nil
    end

    local result = ""
    local indent = indent or 0
    if addLineBreak == nil then addLineBreak = true end
    local lineBreak = addLineBreak and "\n" or ""
    for k, v in pairs(luaTable) do
        if type(k) == "string" then
            k = string.format("%q", k)
        end
        local szSuffix = ""
        if type(v) == "table" then
            szSuffix = "{"
        end
        local szPrefix = string.rep("    ", indent)
        formatting = szPrefix .. "[" .. k .. "]" .. " = " .. szSuffix
        if type(v) == "table" then
            result = result .. formatting .. lineBreak
            result = result .. table.tostring(v, addLineBreak, addLineBreak and indent + 1 or 0)
            result = result .. szPrefix .. "}," .. lineBreak
        else
            local szValue = ""
            if type(v) == "string" then
                szValue = string.format("%q", v)
            else
                szValue = tostring(v)
            end
            result = result .. formatting .. szValue .. "," .. lineBreak
        end
    end

    return result
end

--table转化成string，前面加上local x=, 最后加上return，可以使用pcall(loadstring(dataStr))变成table
function table.tostringex(luaTable, addLineBreak)
    if type(luaTable) ~= "table" then
        Log.e("table.tostringex error, not table, type:%s", type(luaTable))
        return nil
    end

    if addLineBreak == nil then addLineBreak = true end
    local lineBreak = addLineBreak and "\n" or ""
    local result = table.tostring(luaTable, addLineBreak, addLineBreak and 1 or 0)
    return "local t = {" .. lineBreak .. result .. "}" .. lineBreak .. "return t" .. lineBreak
end

--将table输出到文件，可以直接使用require得到table
function table.printtofile(fileName, luaTable, addLineBreak)
    if type(luaTable) ~= "table" then
        Log.e("table.printtofile error, not table, type:%s", type(luaTable))
        return nil
    end
    local file = io.open(fileName, "w+b")
    file:write(table.tostringex(luaTable, addLineBreak))
    file:flush()
    io.close(file)
end

function table.containKey(tab, key)
    for k, v in pairs(tab) do
        if k == key then
            return true
        end
    end
    return false
end

function table.containValue(tab, value)
    for k, v in pairs(tab) do
        if v == value then
            return true
        end
    end
    return false
end


-------------------------------string的扩充函数-------------------------------
--返回str的第index个字符（返回结果是一个字符串）
--index >= 1 && index <= string.len(index)
function string.at(str, index)
    return string.sub(str, index, index)
end

function string.first(str)
    return string.at(str, 1)
end

function string.last(str)
    return string.at(str, string.len(str))
end

function string.tobool(str)
    return str == "true"
end

function string.tonumber(str)
    return tonumber(str)
end

--如果str是使用table.tostring生成的，那么这个函数会返回原本的table，否则返回nil
function string.totable(str)
    local dataStr = "local t = {" .. str .. "}" .. "return t"
    local error, result = pcall(loadstring(dataStr))
    if error then
        return result
    else
        return nil
    end
end

--如果str是使用table.tostringex生成的，那么这个函数会返回原本的table，否则返回nil
function string.totableex(str)
    local error, result = pcall(loadstring(str))
    if error then
        return result
    else
        return nil
    end
end

function string.findlastof(str, substr)
    local i = str:match(".*" .. substr .. "()")
    if i == nil then return nil else return i - 1 end
end


-------------------------------debug的扩充函数-------------------------------
-- 输出堆栈及局部变量信息
-- 因为release下需要这个函数来输出crash堆栈，所以使用Log.i()
function debug.tracebackex(printTable, printTemporary, printUserdata, printFunction)
    local level = 2
    Log.i("INFO: please call debug.tracebackex(true) if you want to print the detail of table")
    Log.i("stack traceback:")
    while true do
        --get stack info
        local info = debug.getinfo(level, "Sln")
        if not info then break end
        if info.what == "C" then
            Log.i("level %d: C function, namewhat: %s, name: %s", level, info.namewhat or "", info.name or "")
        else
            Log.i("level %d: [%s]:%d in %s \'%s\'", level, info.short_src, info.currentline,
                info.namewhat or "", info.name or "")
        end

        --get local vars
        local i = 1
        while true do
            local name, value = debug.getlocal(level, i)
            if not name then break end
            local needPrint = false

            if name == "(*temporary)" then
                if printTemporary then
                    needPrint = true
                end
            else
                if type(value) == "table" then
                    if printTable then
                        Log.i(name .. " = ")
                        table.print(value, false)
                    end
                elseif type(value) == "userdata" then
                    if printUserdata then
                        needPrint = true
                    end
                elseif type(value) == "function" then
                    if printFunction then
                        needPrint = true
                    end
                else
                    needPrint = true
                end
            end

            if needPrint then
                Log.i("%s = %s(%s)", tostring(name), tostring(value), type(value))
            end
            i = i + 1
        end
        level = level + 1
    end
end

-- 输出函数的信息
function debug.printfunction(func, name)
    if type(func) == "function" then
        local info = debug.getinfo(func)
        Log.d("name: %s, func: %s, source: %s, lineDefined: %d", tostring(info.func),
            name or "function", info.source, info.linedefined)
    else
        Log.d("func is not a function, type is: " .. type(func))
    end
end

-- 执行此函数后，当前文件接下来的代码不可以使用全局变量
-- 只会改变当前文件的环境
-- 触动精灵貌似把setfenv函数给删除了，暂时注释这个
-- function debug.finalizeCurrentEnvironment()
--     if not DEBUG then return end
--     local mt = {}
--     mt.__index = function (t, k)
--         local globalValue = _G[k]
--         if globalValue == nil then
--             error("undeclared global var : " .. k, 2)
--         else
--             return globalValue
--         end
--     end
--     mt.__newindex = function (t, k, v)
--         error("forbidden global var : " .. k, 2)
--     end
--     local newgt = {}
--     setmetatable(newgt,mt)
--     setfenv(2, newgt)
-- end


-------------------------------其他扩充函数-------------------------------
function clone(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local newObject = {}
        lookup_table[object] = newObject
        for key, value in pairs(object) do
            newObject[_copy(key)] = _copy(value)
        end
        return setmetatable(newObject, getmetatable(object))
    end
    return _copy(object)
end
