--作用：挖宝
--时间：2017.3.4
--备注：

require("dhxy.functions")

-- 使用按钮
local useButtonColors = {
    {  709, 1224, 0x94e3ce},
    {  702, 1219, 0xffffff},
    {  681, 1219, 0x52ba8c},
    {  673, 1261, 0xffffff},
    {  672, 1283, 0xffffff},
    {  673, 1329, 0x42b68c},
}

-- 挖下一个宝使用按钮2
local digNextButtonColors = {
    {  433, 1424, 0x9c8173},
    {  419, 1458, 0xc5493a},
    {  381, 1462, 0xf7f3bd},
    {  279, 1466, 0x4aba94},
    {  273, 1477, 0xe6f7ef},
    {  277, 1518, 0x4aba94},
}

-- 监视宝图任务
function watchTreasuresTask(finishCallback)
    Log.i("watchTreasuresTask: start")
    local count = 0

    local event1 = createMultiColorEvent(useButtonColors, nil, function()
        click(709, 1224)
    end)
    local event2 = createMultiColorEvent(digNextButtonColors, nil, function()
        click(279, 1466)
    end)

    local events = {event1, event2}
    while count < 40 do
        -- 匹配成功时，快速检查，没成功时检查比较慢，节约性能
        if checkAllEvents(events) then
            mSleep(1.5 * 1000)
        else
            count = count + 1
            mSleep(15 * 1000)
        end
    end

    Log.i("watchTreasuresTask: finish")
end

function main()
    Log.start("dhxy")
    watchTreasuresTask(function()
        vibratorTimes()
    end)
end

-- 直接调用
if ... == nil then
    xpcallCustom(main)
end
