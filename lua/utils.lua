--[[
作用: 各项目通用的函数
时间: 2017.2.25
备注:
]]

require("log")
require("TSLib")

function pos(x, y)
    return {x = x, y = y}
end

-- 默认手机处于纵向状态, 屏幕的左上角是(0,0), 往右+x, 往下+y
-- width是1080, height是1920
-- 调用init后的对应关系在下面说明
display = {}
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
initDisplay()

-- 重写init函数, 保存rotate的值
-- rotate: 必填, 屏幕方向, 0-竖屏, 1-home键在右边, 2-home键在左边
-- bid: 选填, 目标程序的Bundle ID, 填写"0"时自动使用当前运行的应用
-- 调用init不会影响display的width和height
-- 所有屏幕方向下都是左上角为原点, 所以init(1)时x最大值是1920
local initRotate = 0
local initOld = init
init = function(rotate, bid)
    initRotate = rotate
    if bid then
        initOld(rotate, bid)
    else
        initOld(rotate)
    end
end

-- 全屏截图
function snapshotFullScreen(fileName)
    local snapshotName = string.format("%s/%s.png", Log.getLogPath(), fileName)
    if initRotate == 0 then
        snapshot(snapshotName, 0, 0, display.width - 1, display.height - 1)
    else
        snapshot(snapshotName, 0, 0, display.height - 1, display.width - 1)
    end
end

-- 把x, y 坐标加上一个差值求得新的colors
function getColorsByMargin(colors, xMargin, yMargin)
    local newColors = {}
    for _, v in ipairs(colors) do
        local data = {[1] = v[1] + xMargin, [2] = v[2] + yMargin, [3] = v[3]}
        table.insert(newColors, data)
    end
    return newColors
end

-- 两个参数, 是x, y
-- 一个参数, 是pos类型的
function click(param1, param2)
    if param2 then
        tap(param1, param2)
    else
        tap(param1.x, param1.y)
    end
end

-- 依次点击多个点
function clickMultiPoint(points)
    for _, v in ipairs(points) do
        click(v)
        mSleep(30)
    end
end

-- 多次震动
function vibratorTimes(times)
    -- debug的时候为了安静，只震动一次
    local defaultTimes = DEBUG and 1 or 4
    times = times or defaultTimes
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

function errorAndExit(format, ...)
    if format then Log.e(format, ...) end
    snapshotFullScreen("errorAndExit")
    vibratorTimes()
    lua_exit()
end

-- s为单位
function sleep(time)
    mSleep(time * 1000)
end

function xpcallEx(functionName)
    local function traceback(errorMessage)
        Log.i(errorMessage)
        -- 主动结束脚本
        if string.find(errorMessage, "User Exit") then return end

        Log.i("-----------------------------------------------------------------------")
        debug.tracebackex()
        Log.i("-----------------------------------------------------------------------")
        vibratorTimes()
        -- 这里系统会自动结束, 因此不需要手动调用lua_exit
    end
    xpcall(functionName, traceback)
end

local currentBid = nil
function runAppEx(bid)
    currentBid = bid
    if isFrontApp(bid) == 0 then
        -- 启动前需要有延时, 否则可能失败
        mSleep(2000)
        local result = runApp(bid)
        if result ~= 0 then
            errorAndExit("runAppEx %s failed: %d", bid, result)
        end
        mSleep(5000)
        local count = 0
        while isFrontApp(bid) == 0 do
            count = count + 1
            if count >= 5 then
                errorAndExit("runAppEx %s failed: timeout", bid)
            end
            mSleep(5000)
        end
        Log.i("runAppEx %s success!", bid)
        return true
    else
        Log.i("runAppEx %s success: already in front", bid)
        return true
    end
end

-- 检查当前程序是否在前台
-- 如果不在的话，重新启动
-- bid为空时，使用runAppEx的bid
function checkAppFront(bid)
    if not bid and not currentBid then
        errorAndExit("checkAppFront error: no bid")
    end
    bid = bid or currentBid
    if isFrontApp(bid) == 0 then
        Log.w("app not in front, restart")
        return runAppEx()
    end
end

local ocrTextNum = 0
function ocrTextDebug(x1, y1, x2, y2, flag, whiteList)
    local text = ocrText(x1, y1, x2, y2, flag, whiteList)
    if DEBUG then
        ocrTextNum = ocrTextNum + 1
        local fileName = string.format("%s/%s_ocrText_%03d.png", Log.getLogPath(), Log.getLogName(), ocrTextNum)
        snapshot(fileName, x1, y1, x2, y2)
        Log.d("ocrTextDebug: %d-%s", ocrTextNum, text)
    end
    return text
end

local findMultiColorNum = 0
function findMultiColorInRegionFuzzyDebug(color, posandcolor, degree, x1, y1, x2, y2)
    local x, y = findMultiColorInRegionFuzzy(color, posandcolor, degree, x1, y1, x2, y2)
    if DEBUG then
        findMultiColorNum = findMultiColorNum + 1
        local fileName = string.format("%s/%s_findMultiColor_%03d.png", Log.getLogPath(),
            Log.getLogName(), findMultiColorNum)
        snapshot(fileName, x1, y1, x2, y2)
        Log.d("findMultiColorInRegionFuzzyEx: %d-%d-%d", findMultiColorNum, x, y)
    end
    return x, y
end
