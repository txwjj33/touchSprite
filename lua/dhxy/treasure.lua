--作用：挖宝
--时间：2017.3.4
--备注：

require("dhxy.functions")

-- 使用按钮
local useButtonColors = {
    {1224, 371, 0x94e3ce},
    {1219, 378, 0xffffff},
    {1219, 399, 0x52ba8c},
    {1261, 407, 0xffffff},
    {1283, 408, 0xffffff},
    {1329, 407, 0x42b68c},
}

-- 挖下一个宝使用按钮2
local digNextButtonColors = {
    {1424, 647, 0x9c8173},
    {1458, 661, 0xc5493a},
    {1462, 699, 0xf7f3bd},
    {1466, 801, 0x4aba94},
    {1477, 807, 0xe6f7ef},
    {1518, 803, 0x4aba94},
}

-- 监视宝图任务
function watchTreasuresTask(finishCallback)
    Log.i("watchTreasuresTask: start")
    local count = 0

    local event1 = createMultiColorEvent(useButtonColors, nil, function()
        click(1224, 371)
    end)
    local event2 = createMultiColorEvent(digNextButtonColors, nil, function()
        click(1466, 801)
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
    if not initApp() then return end
    watchTreasuresTask(function()
        vibratorTimes()
    end)
end

-- 直接调用
if ... == nil then
    xpcallCustom(main)
end
