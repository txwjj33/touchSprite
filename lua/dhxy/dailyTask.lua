--[[
作用: 大话西游日常任务
时间: 2017.2.28
备注: 每天定时执行，包括帮派、师门、五环
]]

require("dhxy.functions")

-- 常用的按钮的位置
local firstButtonPos = pos(1500, 660)
local secondButtonPos = pos(1500, 770)

-- 一个打五个的事件
local fightCondition = Condition.textCondition(1378, 639, 1518, 676, 1, "让你知道")
local fightEvent = Condition.createEvent(fightCondition, function()
    Log.d("handle fightEvent")
    click(firstButtonPos)
end)

-- 买东西的事件
local buyCondition = Condition.textCondition(1329, 675, 1473, 713, 1, "购买数量")
local buyEvent = Condition.createEvent(buyCondition, function()
    Log.d("handle buyEvent")
    click(1429, 892)
end)

-- 回答问题的第二个按钮
local answerColors = {
    {  976,  633, 0xfffbf7},
    {  995,  659, 0xffdf63},
    { 1007,  656, 0x844931},
    { 1019,  683, 0xce9e7b},
    {  995,  684, 0xf7a663},
    {  999,  680, 0x7b4129},
}
local answerEvent = Condition.createColorsEvent(answerColors, function()
    Log.d("handle answerEvent")
    click(993, 664)
end)

-- 帮派和师门任务的data生成函数
local function taskDataHelper(name, finishText)
    local data = {}
    data.name = name
    local startCondition = Condition.textCondition(1446, 640, 1593, 678, 1, name)
    local startEvent = Condition.createEvent(startCondition, function()
        Log.d("handle startEvent")
        click(firstButtonPos)
    end)
    data.loop = function()
        local events = {fightEvent, buyEvent, startEvent}
        for _, event in ipairs(events) do
            if Condition.checkEvent(event) then break end
        end
    end
    data.finishCondition = Condition.textCondition(103, 784, 245, 824, 1, finishText)
    data.finishCallback = function()
        -- 点击屏幕中央，让完成的对话框消失
        click(display.center)
    end
    return data
end

-- 大理寺答题
local function da_li_si()
    local data = {}
    data.name = "大理寺答题"
    data.ocrName = "大理寺答"
    data.interval = 4
    local startCondition = Condition.textCondition(1376, 640, 1517, 678, 1, "我要参加")
    local startEvent = Condition.createEvent(startCondition, function()
        Log.d("handle startEvent")
        click(firstButtonPos)
    end)
    data.loop = function()
        local events = {answerEvent, startEvent}
        for _, event in ipairs(events) do
            if Condition.checkEvent(event) then break end
        end
    end
    data.finishCondition = Condition.textCondition(103, 784, 245, 824, 1, "你已完成")
    data.finishCallback = function()
        -- 点击屏幕中央，让完成的对话框消失
        click(display.center)
    end
    runTask(data)
end

-- 五环任务
local function wu_huan()
    local data = {}
    data.name = "五环任务"
    data.loop = function()
        if data.started then return end
        if ocrTextDebug(1393, 640, 1534, 678, 1, "让我来帮") == "让我来帮" then
            Log.d("handle startEvent")
            click(secondButtonPos)
            data.started = true
        end
    end
    data.finishCondition = function()
        -- 完成条件是在主界面且任务列表中第一条任务不是五环任务
        -- 如果是中途继续的，那么data.started一直未false, 也就不会结束
        if data.started then
            return multiColor(gMapButtonColors) and ocrTextDebug(1534, 268, 1663, 305, 1, "五环任务") ~= "五环任务"
        else
            return false
        end
    end
    data.interval = 20
    data.timeout = 10 * 60
    runTask(data)
end

local function main()
    if not initApp() then return end
    runTask(taskDataHelper("帮派任务", "英雄今天"))
    runTask(taskDataHelper("师门任务", "徒儿你已"))
    da_li_si()
    wu_huan()
    vibratorTimes()
end

-- 直接调用
if ... == nil then
    xpcallEx(main)
end
