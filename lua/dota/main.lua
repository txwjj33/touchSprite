--[[
作用: 刀塔传奇
时间: 2018.1.17
备注: 洗练要某两项属性之和增加的脚本
]]

require("init")
require("dota.config")

local appName = "dota"
local count = 0

-- 获取重洗的数值
local function getRefreshNumber()
    -- 获取重洗的文本
    -- y: 数字所在位置的左上角y坐标
    local function getText(y)
        return ocrText(900, y, 1000, y + 30, 0, "0123456789+-()")
    end

    local function transToNumber(text)
        local len = string.len(text)
        -- 某项属性有可能不改变
        if len <= 2 or string.at(text, 1) ~= "(" or string.at(text, len) ~= ")" then
            return nil
        end
        -- 去掉前后的括号
        return tonumber(string.sub(text, 2, string.len(text) - 1))
    end

    local strengthText, agilityText, intelligenceText
    local strength, agility, intelligence
    local tryTimes = 0
    local maxTryTimes = 15
    while tryTimes < maxTryTimes do
        local strengthTextNew = getText(378)
        local agilityTextNew = getText(441)
        local intelligenceTextNew = getText(505)
        Log.d("getRefreshNumber text: %s:%s:%s", strengthTextNew, agilityTextNew, intelligenceTextNew)
        strength = transToNumber(strengthTextNew)
        agility = transToNumber(agilityTextNew)
        intelligence = transToNumber(intelligenceTextNew)
        -- 三个属性至少有一个不是nil才对
        if strength or agility or intelligence then
            -- 因为会有数字变大变小的动画，变化过程中识别可能出错
            -- 因此以同样的间隔多次识别，相邻两次识别文本相同的情况下才认为识别成功了
            -- 否则抛弃前一次的识别结果，继续下一次识别
            if strengthTextNew == strengthText and agilityTextNew == agilityText
                    and intelligenceTextNew == intelligenceText then
                Log.d("getRefreshNumber finish")
                break
            else
                strengthText = strengthTextNew
                agilityText = agilityTextNew
                intelligenceText = intelligenceTextNew
                mSleep(400)
            end
        else
            mSleep(400)
        end
        tryTimes = tryTimes + 1
    end

    if tryTimes == maxTryTimes then
        errorAndExit("try too many times")
    end

    return strength or 0, agility or 0, intelligence or 0
end

-- 检查属性是否需要保存
-- 保存条件: 前两个之和大于0，或者前两个之和等于0，第三个大于0
local function checkNeedSave(n1, n2, n3)
    if n1 + n2 > 0 then
        return true
    elseif n1 + n2 == 0 and n3 > 0 then
        return true
    else
        return false
    end
end

-- 返回某个属性的新的值
-- 同时检查某项属性是否正确，用于进一步检测数字识别是否正确
-- y: 属性的上面的y坐标
-- propertyValue: 属性变化值
local function getAndCheckNewValue(y, changeValue)
    local oldValuaText = ocrText(724, y, 764, y + 33, 0, "0123456789")
    local newValuaText = ocrText(836, y, 876, y + 33, 0, "0123456789")
    Log.d("getAndCheckNewValue: %d:%d", oldValuaText, newValuaText)
    local oldValua = tonumber(oldValuaText)
    local newValua = tonumber(newValuaText)
    if oldValua and newValua and oldValua + changeValue == newValua then
        return newValua
    else
        errorAndExit("getAndCheckNewValue error")
    end
end

-- 重洗
local function refresh()
    -- TODO: 检查是否还有钱
    click(1269, 961)
    mSleep(400)
end

-- 保存结果
local function save()
    Log.d("needSave")
    if DEBUG then
        snapshotFullScreen(tostring(count))
    end

    click(780, 988)
    -- 等待一定时间，等待保存的动画停止
    mSleep(2000)
    -- 如果弹出对话框，说明另一项减得很多，正常应该点确定
    -- TODO: 但是也有可能是脚本出bug，为了稳妥先停止
    if isColor(406, 900, 0x6b4f38, 95) then
        errorAndExit("found dialog, exit")
    end
end

local function doLoop()
    -- 正在连接，跳过这次循环
    if isColor(1093, 491, 0x312d28, 95) then
        Log.d("connecting, wait")
        mSleep(200)
        return
    end

    count = count + 1
    Log.i("start loop %d", count)

    local strength, agility, intelligence = getRefreshNumber()
    Log.d("number:%d:%d:%d", strength, agility, intelligence)
    local needSave = false
    if config == 1 and checkNeedSave(strength, agility, intelligence) then
        needSave = true
    elseif config == 2 and checkNeedSave(strength, intelligence, agility) then
        needSave = true
    elseif config == 3 and checkNeedSave(agility, intelligence, strength) then
        needSave = true
    end

    if needSave then
        keepScreen(true)
        local strengthNew = getAndCheckNewValue(378, strength)
        local agilityNew = getAndCheckNewValue(441, agility)
        local intelligenceNew = getAndCheckNewValue(505, intelligence)
        save()
        if strengthNew >= strengthMax or agilityNew >= agilityMax or intelligenceNew >= intelligenceMax then
            errorAndExit("achieve max, exit")
        end
        keepScreen(false)
    end
    refresh()
end

local function main()
    Log.start(appName)
    init(1)
    refresh()
    while true do
        doLoop()
    end
end

xpcallEx(main)
