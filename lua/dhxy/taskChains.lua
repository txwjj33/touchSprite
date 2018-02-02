--[[
作用: 200环任务链
时间: 2017.3.4
备注:
]]

require("dhxy.functions")

-- 常用的按钮的位置
local firstButtonPos = pos(1500, 660)
local secondButtonPos = pos(1500, 770)

-- 一个打五个的对话按钮
local fightButtonColors = {
    {1270, 631, 0xfff7e6},
    {1270, 672, 0xffe3a4},
    {1270, 697, 0xf7dba4},
    {1755, 697, 0xf7dba4},
    {1755, 661, 0xffe7ad},
    {1755, 633, 0xfff7de},
}

-- 回答问题的第二个按钮
local selectButtonColors = {
    {  976,  633, 0xfffbf7},
    {  995,  659, 0xffdf63},
    { 1007,  656, 0x844931},
    { 1019,  683, 0xce9e7b},
    {  995,  684, 0xf7a663},
    {  999,  680, 0x7b4129},
}

-- 购买宠物界面的前往捕捉按钮
local buyPetColors = {
    { 1396,  221, 0xad713a},
    { 1407,  223, 0xb5753a},
    { 1427,  248, 0xffebad},
    { 1481,  210, 0xfffbef},
    { 1489,  243, 0xa46121},
    { 1567,  249, 0xb5793a},
    { 1562,  222, 0xd6ae84},
}

-- 上交按钮
local uploadButtonColors = {
    {1055, 813, 0x9cd7b5},
    {1144, 819, 0x8ccaa4},
    {1252, 843, 0x42b68c},
    {1054, 877, 0x29c6a4},
    {1170, 879, 0x29caad},
    {1270, 875, 0x31b694},
}

-- 第一个需求标记的坐标
local taskSignColors = {
    {  708,  373, 0xffdf84},
    {  717,  364, 0xcea663},
    {  738,  365, 0x6b4119},
    {  799,  380, 0xf7aa73},
    {  768,  366, 0xffe78c},
    {  723,  412, 0xffa684},
}

local function checkWrongAnswer()
    -- 问题鬼和诗词鬼的答错对话里面的逗号不一样，导致后面的文字的坐标有点不一样
    -- 不要用颜色，因为对话框有透明度，用颜色不准确
    local function condition()
        local text = "通不过我"
        return ocrText(200, 789, 339, 827, 1, text) == text or ocrText(183, 789, 322, 827, 1, text) == text
    end
    return Condition.check(condition)
end

-- 选择题
local function selectCallback()
    Log.i("selectCallback: start")
    click(993, 664)
    mSleep(500)
    while checkWrongAnswer() do
        Log.i("wrong answer, try again")
        -- 点击屏幕中间，让对话框消失
        click(display.center)
        mSleep(500)
        -- 点击200环任务
        click(1647, 316)
        mSleep(1000)
        if Condition.checkColors(selectButtonColors) then
            click(993, 664)
            mSleep(500)
        else
            -- 选择题没弹出来
            errorAndExit("selectCallback: question do not open")
        end
    end
    Log.i("selectCallback: finish")
end

-- 当前页寻找满足条件的宠物
local function findPet()
    for i = 0, 7 do
        local colors = getColorsByMargin(taskSignColors, 475 * (i % 2), 156 * math.floor(i / 2))
        if multiColor(colors) then
            -- 找到需求的标记，点击右边的按钮购买
            click(colors[1][1] + 200, colors[1][2])
            mSleep(1000)
            if Condition.checkText(1122, 277, 1261, 313, 1, "确定购买") then
                click(1294, 841)
                mSleep(500)
                return true
            else
                errorAndExit("buyPet error: buy dialog not open")
            end
        end
    end
    return false
end

local function buyPet()
    Log.i("buyPet: start")

    local count = 0
    while count < 20 do
        if findPet() then
            Log.i("buyPet: finish")
            return true
        else
            -- 这一页没有满足需求的，翻页
            click(1587, 963)
            mSleep(1000)
            count = count + 1
        end
    end
    errorAndExit("buyPet error: not find pet")
end

function runTaskChains()
    local data = {}
    data.name = "200环任务"
    data.ocrX2 = 548
    data.timeout = 2 * 60 * 60
    data.finishCondition = function()
       return false
    end

    local startEvent = Condition.createColorsEvent(fightButtonColors, function()
        Log.d("handle startEvent")
        click(firstButtonPos)
    end)
    local fightEvent = Condition.createColorsEvent(fightButtonColors, function()
        Log.d("handle fightEvent")
        click(firstButtonPos)
    end)
    local selectEvent = Condition.createColorsEvent(selectButtonColors, selectCallback)
    local buyPetEvent = Condition.createColorsEvent(buyPetColors, buyPet)
    local uploadEvent = Condition.createColorsEvent(uploadButtonColors, function()
        Log.d("handle uploadEvent")
        click(1055, 813)
    end)
    -- local finishEvent =
    data.loop = function()
        local events = {fightEvent, selectEvent, buyPetEvent, uploadEvent, startEvent}
        for _, event in ipairs(events) do
            if Condition.checkEvent(event) then break end
        end
    end

    runTask(data)
end

function main()
    if not initApp() then return end
    runTaskChains()
end

-- 直接调用
if ... == nil then
    xpcallEx(main)
end
