--作用：帮派任务
--时间：2017.2.25
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

-- 帮派任务做完对话框
local finishedColors = {
    {  288,  117, 0xd6cabd},
    {  288,  149, 0xd6cabd},
    {  288,  193, 0xe6dbc5},
    {  286,  219, 0xd6d2bd},
    {  288,  254, 0xcecab5},
    {  288,  289, 0xc5c2ad},
    {  286,  359, 0xded2c5},
    {  288,  400, 0xcecebd},
}
-- 进入帮派
function enterGangs()
    local colors = {
        {  138,  266, 0xceebde},
        {  134,  481, 0xffefc5},
        {  283, 1271, 0xf78e8c},
        {  146, 1294, 0xefe3ce},
    }
    -- 打开帮派界面
    if not showDialog(gGangsButtonPos, colors) then
        loge("enterGangs: gGangsButtonPos failed")
        return false
    end

    local gangsColors = {
        { 1032,  210, 0x422d29},
        { 1030,  210, 0xd6d2b5},
        { 1028,  210, 0x735952},
        { 1025,  210, 0xf7e7d6},
        { 1023,  210, 0x846963},
        { 1020,  210, 0xcec2ad},
    }
    -- 点击回到帮派
    click(121, 351)
    mSleep(2000)
    if not checkMultiColor(gangsColors) then
        loge("enterGangs: repalce scene failed")
        return false
    end

    -- 打开本地地图，寻路到帮派总管
    if not toPosByLocalMap(732, 1336) then return false end

    mSleep(10 * 1000)
    logi("enterGangs: success")
    return true
end

-- 监视帮派任务
function watchGangsTask(finishCallback)
    logi("watchGangsTask: start")
    local finished = false

    local fightEvent = createMultiColorEvent(fightButtonColors, nil, function()
        click(408, 1500)
    end)
    local buyEvent = createMultiColorEvent(buyButtonColors, nil, function()
        click(188, 1429)
    end)
    local stopEvent = createMultiColorEvent(finishedColors, 6, function()
        logi("watchGangsTask: finished")
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
    watchGangsTask(function()
        vibratorTimes()
    end)
end
