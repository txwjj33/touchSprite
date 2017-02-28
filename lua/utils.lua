--作用：各项目通用的函数
--时间：2017.2.25
--备注：
require("TSLib")

screenW, screenH = 1920, 1080

-- 依次点击多个点
function clickMultiPoint(points)
    for _, v in ipairs(points) do
        tap(v[1], v[2])
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
    local t = {{251, 1057}, {251, 1057}, {544, 1057}, {838, 1057}}
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
