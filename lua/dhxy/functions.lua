--作用：大话西游通用函数
--时间：2017.2.28
--备注：

require("utils")
require("dhxy.constants")

-- 主界面左上角的图标
local colorsMapButton = {
    { 1054,   38, 0xefc26b},
    { 1048,   38, 0xde415a},
    { 1039,   38, 0xb58142},
    { 1027,   38, 0x6bf3f7},
    { 1016,   38, 0xf7f3a4},
    { 1005,   38, 0xadf3de},
    {  989,   38, 0xf7f3ef},
}
-- 开始界面的按钮
local colorsStartGameButton = {
    {  232,  829, 0x3acea4},
    {  220,  829, 0xf7efd6},
    {  187,  882, 0xffffff},
    {  225, 1132, 0xefdbc5},
    {  152, 1154, 0x31cea4},
    {  162, 1106, 0x63ba94},
}
-- 连接网络的按钮
local colorsReconnect = {
    {  408, 1264, 0xb5dfbd},
    {  385, 1189, 0xeff7ef},
    {  350, 1047, 0x3abe94},
    {  394,  870, 0xfff3d6},
    {  384,  798, 0x9c5919},
    {  350,  662, 0xffe7a4},
}

-- 本地地图数据
colorsLocalMap = {
    {  944,  663, 0xf7dbc5},
    {  941,  774, 0xefd2b5},
    {  959,  842, 0x9c9a94},
    { 1015, 1058, 0xa4ae9c},
    {  942, 1224, 0xe6ceb5},
    {  989, 1113, 0xb59273},
}

-- 世界地图
colorsWorldMap = {
    { 1044, 1858, 0xe6716b},
    { 1031, 1868, 0xef7173},
    { 1015, 1855, 0xe67173},
    { 1017, 1883, 0xe6716b},
    { 1041, 1880, 0xe67173},
    { 1044, 1867, 0xefdbbd},
}

-- 启动大话西游
function rundhxy()
    local time = os.time()
    runApp("com.netease.dhxy.wdj")
    logd("rundhxy:run app")
    mSleep(10 * 1000)
    while true do
        if multiColor(colorsMapButton) then
            logi("rundhxy:enter game")
            -- 已进入界面
            return true
        elseif multiColor(colorsStartGameButton) then
            -- 在开始游戏界面
            logi("rundhxy:enter start game")
            click(176, 967)
            mSleep(10 * 1000)
        elseif multiColor(colorsReconnect) then
            -- 连接网络界面
            logi("rundhxy:enter connect scenes")
            click(373, 1130)
            mSleep(10 * 1000)
        else
            if os.time() - time > 3 * 60 then
                -- 3分钟还没进去，提示
                loge("rundhxy:enter game timeout!!")
                vibratorTimes(5)
                dialog("rundhxy:enter game timeout!!")
                lua_exit()
            else
                mSleep(5 * 1000)
            end
        end
    end
end

function initApp()
    startLog("dhxy")
    logi("script begin!")
    unlockPhone()
    mSleep(50)
    return rundhxy()
end

-- 创建多点颜色检测的事件
-- 可以检测需点击按钮，或者任务完成等
-- data: 多点颜色检测的数据
-- count: 多点颜色检测连续成功的次数，大于等于maxCount次算识别成功
-- callback: 识别成功以后的回调
function createMultiColorEvent(data, maxCount, callback)
    local t = {}
    local count = 0
    maxCount = maxCount or 3

    -- 执行一次检测
    -- 返回值：0-识别成功，1-检测成功，2-检测失败
    t.check = function(self)
        if multiColor(data) then
            count = count + 1
            if count >= maxCount then
                if callback then callback() end
                count = 0
                return 0
            else
                return 1
            end
        else
            count = 0
            return 2
        end
    end

    t.reset = function(self)
        count = 0
    end

    return t
end

-- 检查所有的events
-- 每个event都是由createMultiColorEvent创建的
function checkAllEvents(events)
    for i, event in ipairs(events) do
        local result = event:check()
        if result == 0 or result == 1 then
            -- 这个识别了，把其他的reset
            for j, e in ipairs(events) do
                if j ~= i then e:reset() end
            end
            return true
        else
            event:reset()
        end
    end

    return false
end

-- 检查colors颜色是否找到，没找到持续等待
-- timeout为过期时间
function checkMultiColor(colors, timeout)
    timeout = timeout or 2
    local time = os.time()
    while true do
        if multiColor(colors) then
            return true
        else
            if os.time() - time > timeout then
                return false
            else
                mSleep(100)
            end
        end
    end
end

-- 点击按钮，弹出某个对话框
-- colors: 用于检测对话框是否真的弹出
function showDialog(buttonPos, colors, timeout)
    click(buttonPos)
    mSleep(100)
    if colors then
        return checkMultiColor(colors, timeout)
    else
        return true
    end
end

-- 打开世界地图
function enterWorldMap()
    if showDialog(gPosButtonWorldMap, colorsWorldMap) then
        logi("enterWorldMap success")
        return true
    else
        loge("enterWorldMap failed")
        return false
    end
end

-- 打开本地地图
function enterLocalMap()
    if showDialog(gPosButtonLocalMap, colorsLocalMap) then
        logi("enterLocalMap success")
        return true
    else
        loge("enterLocalMap failed")
        return false
    end
end

-- 关闭世界地图
function closeWorldMap()
    if multiColor(colorsWorldMap) then
        click(1031, 1871)
        mSleep(100)
        if checkMultiColor(colorsWorldMap) then
            loge("closeWorldMap error")
            return false
        else
            return true
        end
    else
        return true
    end
end

-- 关闭本地地图
function closeLocalMap()
    if multiColor(colorsLocalMap) then
        click(968, 1565)
        mSleep(100)
        if checkMultiColor(colorsLocalMap) then
            loge("closeLocalMap error")
            return false
        else
            return true
        end
    else
        return true
    end
end

-- 进入本地地图，点击某个点，并关闭本地地图
function toPosByLocalMap(x, y)
    if not enterLocalMap() then return false end
    click(x, y)
    mSleep(50)
    if closeLocalMap() then
        return true
    else
        loge("toPosByLocalMap: local map not closed")
        return false
    end
end

-- 进入世界地图，点击某个场景，再点击小地图寻路，最后关闭小地图
function toPosByWorldMap(worldPos, localPos)
    if not enterWorldMap() then return false end

    click(worldPos)
    mSleep(100)
    if checkMultiColor(colorsLocalMap) then
        -- 本地地图已弹出
        click(localPos)
        mSleep(100)
        if closeLocalMap() then
            if closeWorldMap() then
                return true
            else
                loge("toPosByWorldMap: world map not closed")
                return false
            end
        else
            loge("toPosByWorldMap: local map not closed")
            return false
        end
    else
        loge("toPosByWorldMap: local map not open")
        return false
    end
end
