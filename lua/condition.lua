--[[
作用: 判断条件以及满足条件时的回调
时间: 2017.2.25
备注: 常用于一些延时事件的判断，比如点击了某个按钮，持续的任务等
静态画面的判断不需要用到这个
]]

require("log")
require("TSLib")

Condition = {}

local snapshotNum = 0

-- 根据颜色判断条件
function Condition.colorsCondition(colors)
    return function()
        return multiColor(colors)
    end
end

-- 根据文本判断条件
function Condition.textCondition(x1, y1, x2, y2, flag, whiteList, targetText)
    if not targetText then targetText = whiteList end
    return function()
        return targetText == ocrTextDebug(x1, y1, x2, y2, flag, whiteList)
    end
end

-- 某个条件的反条件
function Condition.reverseCondition(condition)
    return function()
        return not condition()
    end
end

-- 检查条件是否满足，在timeout时间内
-- conditionFunc: 条件函数，返回boolean值
function Condition.check(conditionFunc, timeout)
    timeout = timeout or 5
    local time = os.time()
    while true do
        if conditionFunc() then
            return true
        else
            if os.time() - time > timeout then
                return false
            else
                mSleep(200)
            end
        end
    end
end

-- 检查颜色是否找到
function Condition.checkColors(colors, timeout)
    return Condition.check(Condition.colorsCondition(colors), timeout)
end

-- 检查文字是否找到
function Condition.checkText(x1, y1, x2, y2, flag, whiteList, targetText, timeout)
    local condition = Condition.textCondition(x1, y1, x2, y2, flag, whiteList, targetText)
    return Condition.check(condition, timeout)
end

-- 检测条件满足以及满足后的回调
-- conditionFunc: 条件函数，返回boolean值
-- callback: 识别成功以后的回调
-- checkCount: 检查次数，连续检查成功checkCount次才算识别成功，默认为1
-- interval: 相邻检查之间间隔的时间
function Condition.createEvent(conditionFunc, callback, checkCount, interval)
    checkCount = checkCount or 1
    interval = interval or 200
    return {conditionFunc = conditionFunc, callback = callback, checkCount = checkCount, interval = interval}
end

function Condition.createColorsEvent(colors, callback, checkCount, interval)
    local condition = Condition.colorsCondition(colors)
    return Condition.createEvent(condition, callback, checkCount or 3, interval)
end

function Condition.checkEvent(event)
    local count = 0
    while count < event.checkCount do
        if event.conditionFunc() then
            count = count + 1
            if count >= event.checkCount then
                if event.callback then event.callback() end
                return true
            else
                mSleep(event.interval)
            end
        else
            return false
        end
    end
end
