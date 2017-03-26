--作用：师门任务
--时间：2017.2.28
--备注：

require("dhxy.functions")

-- 一个打五个的对话按钮
local fightButtonColors = {
    {  449, 1270, 0xfff7e6},
    {  408, 1270, 0xffe3a4},
    {  383, 1270, 0xf7dba4},
    {  383, 1755, 0xf7dba4},
    {  419, 1755, 0xffe7ad},
    {  447, 1755, 0xfff7de},
}

-- 购买按钮
local buyButtonColors = {
    {  220, 1243, 0xffffff},
    {  148, 1243, 0x31c6a4},
    {  161, 1558, 0x31ba94},
    {  225, 1553, 0x9cdbbd},
}

-- 师门任务做完对话框里
local finishedColors = {
    {  281,  110, 0xd6cebd},
    {  260,  144, 0xbdbaa4},
    {  288,  185, 0xd6cebd},
    {  268,  241, 0xd6cebd},
    {  288,  262, 0xc5c2ad},
    {  288,  300, 0xd6d2bd},
    {  288,  331, 0xded7c5},
    {  285,  438, 0xc5baad},
    {  275,  590, 0xcec6b5},
}

local enterMasterMapColors = {
    {  157,   52, 0x634942},
    {  164,   45, 0x5a3d3a},
    {  197,   46, 0x5a413a},
    {  235,   47, 0x4a2d31},
    {  263,   49, 0x4a2d31},
    {  303,   49, 0x63514a},
    {  322,   49, 0x423129},
}

-- 进入师门
function enterMasterMap()
    if not gotoPosByDHJL("菩提祖师坐标", pos(533, 745)) then
        return false
    end
    sleep(10)
    -- 点击菩提祖师
    click(display.center)
    return true
end

-- 监视师门任务
function watchMasterTask(finishCallback)
    logi("watchMasterTask: start")
    local finished = false

    local fightEvent = createMultiColorEvent(fightButtonColors, nil, function()
        click(408, 1500)
    end)
    local buyEvent = createMultiColorEvent(buyButtonColors, nil, function()
        click(188, 1429)
    end)
    local stopEvent = createMultiColorEvent(finishedColors, 6, function()
        logi("watchMasterTask: finished")
        -- 点击屏幕中央，让完成的对话框消失
        click(display.center)
        finished = true
        if finishCallback then finishCallback() end
    end)

    local events = {fightEvent, buyEvent, stopEvent}
    while not finished do
        -- 匹配成功时，快速检查，没成功时检查比较慢，节约性能
        if checkAllEvents(events) then
            mSleep(1.5 * 1000)
        else
            mSleep(15 * 1000)
        end
    end
end

-- 直接调用
if ... == nil then
    startLog("dhxy")
    watchMasterTask(function()
        vibratorTimes()
    end)
end
