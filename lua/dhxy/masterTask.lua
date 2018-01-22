--作用：师门任务
--时间：2017.2.28
--备注：

require("dhxy.functions")

-- 一个打五个的对话按钮
local fightButtonColors = {
    {1270, 631, 0xfff7e6},
    {1270, 672, 0xffe3a4},
    {1270, 697, 0xf7dba4},
    {1755, 697, 0xf7dba4},
    {1755, 661, 0xffe7ad},
    {1755, 633, 0xfff7de},
}

-- 购买按钮
local buyButtonColors = {
    {1243, 860, 0xffffff},
    {1243, 932, 0x31c6a4},
    {1558, 919, 0x31ba94},
    {1553, 855, 0x9cdbbd},
}

-- 师门任务做完对话框里
local finishedColors = {
    {110, 799, 0xd6cebd},
    {144, 820, 0xbdbaa4},
    {185, 792, 0xd6cebd},
    {241, 812, 0xd6cebd},
    {262, 792, 0xc5c2ad},
    {300, 792, 0xd6d2bd},
    {331, 792, 0xded7c5},
    {438, 795, 0xc5baad},
    {590, 805, 0xcec6b5},
}

local enterMasterMapColors = {
    {52, 923, 0x634942},
    {45, 916, 0x5a3d3a},
    {46, 883, 0x5a413a},
    {47, 845, 0x4a2d31},
    {49, 817, 0x4a2d31},
    {49, 777, 0x63514a},
    {49, 758, 0x423129},
}

-- 进入师门
function enterMasterMap()
    if not gotoPosByDHJL("菩提祖师坐标", pos(745, 547)) then
        return false
    end
    sleep(10)
    -- 点击菩提祖师
    click(display.center)
    return true
end

-- 监视师门任务
function watchMasterTask(finishCallback)
    Log.i("watchMasterTask: start")
    local finished = false

    local fightEvent = createMultiColorEvent(fightButtonColors, nil, function()
        click(1500, 672)
    end)
    local buyEvent = createMultiColorEvent(buyButtonColors, nil, function()
        click(1429, 892)
    end)
    local stopEvent = createMultiColorEvent(finishedColors, 6, function()
        Log.i("watchMasterTask: finished")
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

function main()
    if not initApp() then return end
    watchMasterTask(function()
        vibratorTimes()
    end)
end

-- 直接调用
if ... == nil then
    xpcallCustom(main)
end
