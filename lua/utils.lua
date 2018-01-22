--[[
作用: 各项目通用的函数
时间: 2017.2.25
备注:
]]

require("log")
require("mathEx")
require("luaEx")
require("TSLib")

DEBUG = false

display = {}

-- 默认手机处于纵向状态，屏幕的左上角是（0,0），往右+x, 往下+y
-- width是1080，height是1920
-- init(rotate,bid)，设置屏幕方向
-- rotate: 必填，屏幕方向，0-竖屏，1-home键在右边，2-home键在左边
-- bid: 选填，目标程序的Bundle ID，填写"0"时自动使用当前运行的应用
-- 调用init不会影响display的width和height，
-- 所有屏幕方向下都是左上角为原点，所以init(1)是x最大值是1920
local function initDisplay()
    local width, height = getScreenSize()
    display.size               = {width = width, height = height}
    display.width              = display.size.width
    display.height             = display.size.height
    display.cx                 = display.width / 2
    display.cy                 = display.height / 2
    display.c_left             = -display.width / 2
    display.c_right            = display.width / 2
    display.c_top              = display.height / 2
    display.c_bottom           = -display.height / 2
    display.left               = 0
    display.right              = display.width
    display.top                = display.height
    display.bottom             = 0
    display.center             = pos(display.cx, display.cy)
    display.left_top           = pos(display.left, display.top)
    display.left_bottom        = pos(display.left, display.bottom)
    display.left_center        = pos(display.left, display.cy)
    display.right_top          = pos(display.right, display.top)
    display.right_bottom       = pos(display.right, display.bottom)
    display.right_center       = pos(display.right, display.cy)
    display.top_center         = pos(display.cx, display.top)
    display.top_bottom         = pos(display.cx, display.bottom)
end

-- 把x, y 坐标加上一个差值求得新的colors
function createNewColors(colors, xMargin, yMargin)
    local newColors = {}
    for _, v in ipairs(colors) do
        local data = {[1] = v[1] + xMargin, [2] = v[2] + yMargin, [3] = v[3]}
        table.insert(newColors, data)
    end
    return newColors
end

-- 依次点击多个点
function clickMultiPoint(points)
    for _, v in ipairs(points) do
        click(v)
        mSleep(30)
    end
end

-- 多次震动，默认四次
function vibratorTimes(times)
    times = times or 4
    for i = 1, times do
        if i > 1 then mSleep(1000) end
        vibrator()
    end
end

-- 解锁设备
function unlockPhone()
    if deviceIsLock() == 0 then return end

    Log.i("start unlock")
    mSleep(1000)
    unlockDevice()
    mSleep(1000)
    -- 往上滑
    moveTo(540, 1900, 540, 800, 30)
    mSleep(500)

    -- 输入密码
    local t = {pos(251, 1057), pos(251, 1057), pos(544, 1057), pos(838, 1057)}
    clickMultiPoint(t)
    mSleep(4000)
end

function pos(x, y)
    return {x = x, y = y}
end

-- 两个参数，是x, y
-- 一个参数，是pos类型的
function click(param1, param2)
    if param2 then
        tap(param1, param2)
    else
        tap(param1.x, param1.y)
    end
end

function errorAndExit(msg)
    if msg then Log.e(msg) end
    vibratorTimes()
    lua_exit()
end

-- 手机纵向坐标转变横向坐标
function transToH(posx, posy)
    return posy, display.width - posx
end

-- 手机纵向区域转变横向区域
function transRectToH(posx1, posy1, posx2, posy2)
    return posy1, display.width - posx2, posy2, display.width - posx1
end

-- 手机横向坐标转成纵向坐标
function transToV(posx, posy)
    return display.width - posy, posx
end

-- 手机横向区域转成纵向区域
function transRectToV(posx1, posy1, posx2, posy2)
    return display.width - posy2, posx1, display.width - posy1, posx2
end

-- 有时候按横屏量的坐标，需要用这个函数转化一下
-- local selectButtonColors = {
--     {  994,  665, 0xf7db73},
--     { 1001,  666, 0x734129},
-- }
function transColorsToV(colors)
    local result = {}
    for _, v in ipairs(colors) do
        local data = {}
        data[1], data[2] = transToV(v[1], v[2])
        data[3] = v[3]
        table.insert(result, data)
    end
    return result
end

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

-- s为单位
function sleep(time)
    mSleep(time * 1000)
end

-- init的参数
function snapshotEx(fileName, initParam)
    initParam = initParam or 0
    local snapshotName = string.format("/sdcard/TouchSprite/log/%s.png", fileName)
    if initParam == 0 then
        snapshot(snapshotName, 0, 0, display.width - 1, display.height - 1)
    else
        snapshot(snapshotName, 0, 0, display.height - 1, display.width - 1)
    end
end

function xpcallCustom(functionName)
    local function traceback(errorMessage)
        Log.i(errorMessage)
        -- 主动结束脚本
        if string.find(errorMessage, "User Exit") then return end

        Log.i("-----------------------------------------------------------------------")
        debug.tracebackex()
        Log.i("-----------------------------------------------------------------------")
        vibratorTimes()
        -- 这里系统会自动结束，因此不需要手动调用lua_exit
    end
    xpcall(functionName, traceback)
end

initDisplay()
