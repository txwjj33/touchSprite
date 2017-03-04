--作用：各项目通用的函数
--时间：2017.2.25
--备注：
require("TSLib")

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
    for i = 0, times do
        vibrator()
        mSleep(1000)
    end
end

-- 解锁设备
function unlockPhone()
    if deviceIsLock() == 0 then return end

    logi("start unlock")
    mSleep(1000)
    unlockDevice()
    mSleep(1000)
    -- 往上滑
    moveTo(540, 1900, 540, 800, 30)
    mSleep(500)

    -- 输入密码
    local t = {pos(251, 1057), pos(251, 1057), pos(544, 1057), pos(838, 1057)}
    clickMultiPoint(t)
end

-- 开始log记录
function startLog(appName)
    if not appName then
        dialog("startLog need appName")
        lua_exit()
    end
    logName = appName .. os.date("_%Y_%m_%d-%H_%M_%S")
end

function logd(msg)
    log(string.format("[D]%s", msg), logName)
end

function logi(msg)
    log(string.format("[I]%s", msg), logName)
end

function loge(msg)
    log(string.format("[E]%s", msg), logName)
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

initDisplay()
