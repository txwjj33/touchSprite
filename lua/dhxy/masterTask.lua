--作用：师门任务
--时间：2017.2.28
--备注：

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
    {  330,  109, 0x94867b},
    {  343,  227, 0x949673},
    {  343,  337, 0xc5b294},
    {   30,  108, 0x847d6b},
    {   16,  206, 0x948e7b},
    {   16,  422, 0x948e73},
}

local enterMasterMapColors = {
    {  623,  804, 0xbdc24a},
    {  601,  855, 0xdee342},
    {  620,  901, 0xe6eb4a},
    {  219, 1358, 0x00e3e6},
    {  202, 1425, 0x08f3f7},
}

-- 进入师门
function enterMasterMap()
    if not enterWorldMap() then return false end

    -- 点击方寸山
    click(669, 275)
    mSleep(100)
    if checkMultiColor(localMapColors) then
        -- 本地地图已弹出，点击斜月三星洞的位置
        -- 点一次进不去，走到附近以后再点一次
        click(766, 629)
        mSleep(15 * 1000)
        click(763, 634)
        mSleep(100)
        -- 等待走到斜月三星洞，判断是否进入
        if checkMultiColor(enterMasterMapColors) then
            -- 点击菩提祖师的位置
            click(619, 830)
            mSleep(50)
            if closeLocalMap() then
                logi("enterMasterMap: sussess")
                return true
            else
                loge("enterMasterMap: local map not close")
                return false
            end
        else
            loge("enterMasterMap: enter master map error")
            return false
        end
    else
        loge("enterMasterMap: local map not open")
        return false
    end
end

-- 监视师门任务
function watchMasterTask()
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
