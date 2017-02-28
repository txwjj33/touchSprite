--作用：帮派任务
--时间：2017.2.25
--备注：

-- 一个打五个的对话按钮
local fightButtonData = {
    {  449, 1270, 0xfff7e6},
    {  408, 1270, 0xffe3a4},
    {  383, 1270, 0xf7dba4},
    {  383, 1755, 0xf7dba4},
    {  419, 1755, 0xffe7ad},
    {  447, 1755, 0xfff7de},
}

-- 购买按钮
local buyButtonData = {
    {  220, 1243, 0xffffff},
    {  148, 1243, 0x31c6a4},
    {  161, 1558, 0x31ba94},
    {  225, 1553, 0x9cdbbd},
}

-- 帮派任务做完对话框里的两个表情
local stopData = {
    {  330,  109, 0x94867b},
    {  343,  227, 0x949673},
    {  343,  337, 0xc5b294},
    {   30,  108, 0x847d6b},
    {   16,  206, 0x948e7b},
    {   16,  422, 0x948e73},
}

-- 开始帮派任务
local function startBangPaiTask()
end

-- 监视帮派任务
local function watchTask()
    local fightEvent = createMultiColorEvent(fightButtonData, nil, function()
            tap(408, 1500)
        end)
    local buyEvent = createMultiColorEvent(buyButtonData, nil, function()
            tap(188, 1429)
        end)

    local stopEvent = createMultiColorEvent(stopData, 5, function()
            vibratorTimes()
        end)

    local events = {fightEvent, buyEvent, stopEvent}
    while true do
        checkAllEvents(events)
        mSleep(2000)
    end
end

watchTask()

