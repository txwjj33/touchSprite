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

-- local gangsTextColors = {
--     {  759,  395, 0xa44d4a},
--     {  761,  431, 0xad615a},
--     {  761,  458, 0xd6a29c},
--     {  762,  472, 0xbd867b},
--     {  763,  507, 0xdebeb5},
--     {  733,  513, 0xd6aa9c},
-- }

-- 进入帮派
function enterGangs()
    click(90, 1256)
    sleep(2)

    -- 点击回到帮派
    click(121, 351)
    sleep(3)

    -- 打开本地地图
    click(1000, 215)
    sleep(3)
    -- 点击帮派总管的位置
    click(732, 1336)
    sleep(1)
    -- 关闭本地地图
    click(968, 1565)
    sleep(0.1)

    sleep(10)
    Log.i("enterGangs: success")
    return true
    -- 帮派任务的回答里面的坐标导航不对，所以不能用以下方法
    -- if not gotoPosByDHJL("帮派任务坐标", pos(431, 1105)) then
    --     return false
    -- end
    -- mSleep(30 * 1000)
    -- -- 点击帮派总管
    -- click(display.center)
    -- return true
end

-- 监视帮派任务
function watchGangsTask(finishCallback)
    Log.i("watchGangsTask: start")
    local finished = false

    local fightEvent = createMultiColorEvent(fightButtonColors, nil, function()
        click(408, 1500)
    end)
    local buyEvent = createMultiColorEvent(buyButtonColors, nil, function()
        click(188, 1429)
    end)
    local stopEvent = createMultiColorEvent(finishedColors, 6, function()
        Log.i("watchGangsTask: finished")
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
    Log.start("dhxy")
    watchGangsTask(function()
        vibratorTimes()
    end)
end

-- 直接调用
if ... == nil then
    xpcallCustom(main)
end
