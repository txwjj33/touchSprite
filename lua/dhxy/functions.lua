--作用：大话西游通用函数
--时间：2017.2.28
--备注：

require("utils")
require("dhxy.constants")

-- 主界面左上角的图标
local mapButtonColors = {
    {38, 26, 0xefc26b},
    {38, 32, 0xde415a},
    {38, 41, 0xb58142},
    {38, 53, 0x6bf3f7},
    {38, 64, 0xf7f3a4},
    {38, 75, 0xadf3de},
    {38, 91, 0xf7f3ef},
}

-- 开始界面的按钮
local startGameButtonColors = {
    {829, 848, 0x3acea4},
    {829, 860, 0xf7efd6},
    {882, 893, 0xffffff},
    {1132, 855, 0xefdbc5},
    {1154, 928, 0x31cea4},
    {1106, 918, 0x63ba94},
}

-- 连接网络的按钮
local reconnectColors = {
    {1264, 672, 0xb5dfbd},
    {1189, 695, 0xeff7ef},
    {1047, 730, 0x3abe94},
    {870, 686, 0xfff3d6},
    {798, 696, 0x9c5919},
    {662, 730, 0xffe7a4},
}

-- 活动界面活跃度三个字的颜色
local activityDialogColors = {
    {229, 953, 0xb5756b},
    {242, 953, 0xa4554a},
    {265, 953, 0x9c3d3a},
    {282, 954, 0x8c2019},
    {314, 951, 0xa44942},
}

local friendDialogColors = {
    {269, 965, 0xffebb5},
    {278, 965, 0xfff3d6},
    {376, 965, 0xad693a},
    {394, 965, 0xad7142},
    {413, 973, 0xa45d19},
    {422, 980, 0xffe7ad},
}

-- -- 第一个前往的按钮颜色
-- local qianwangButtonColors = {
--     {  777,  753, 0xc5e7ce},
--     {  775,  797, 0xb5dfc5},
--     {  749,  795, 0x42ba8c},
--     {  725,  843, 0x5adfa4},
-- }

-- -- 右边的前往button的颜色，跟左边的不太一样
-- local qianwangRightButtonColors = {
--     {  753, 1433, 0x42ba84},
--     {  776, 1446, 0xf7fbf7},
--     {  779, 1475, 0x9cd7ad},
--     {  783, 1524, 0x4ac294},
--     {  723, 1528, 0x31caa4},
-- }

-- 启动大话西游，如果30s后还没到前台，就退出
function rundhxy()
    local bid = "com.netease.dhxy.wdj"
    if isFrontApp(bid) == 0 then
        local result = runApp(bid)
        if result ~= 0 then
            errorAndExit("rundhxy failed: run app failed(%d)", result)
        end
        mSleep(5 * 1000)
        local count = 0
        while isFrontApp(bid) == 0 do
            count = count + 1
            if count >= 5 then
                errorAndExit("rundhxy failed!")
            end
            mSleep(5 * 1000)
        end
        Log.i("rundhxy success!")
    else
        Log.i("rundhxy success: already in front")
        return true
    end
end

function enterdhxy()
    local time = os.time()
    while true do
        if multiColor(mapButtonColors) then
            Log.i("enterdhxy:enter game")
            -- 已进入界面
            return true
        elseif multiColor(startGameButtonColors) then
            -- 在开始游戏界面
            Log.i("enterdhxy:enter start game")
            click(967, 904)
            mSleep(10 * 1000)
        elseif multiColor(reconnectColors) then
            -- 连接网络界面
            Log.i("enterdhxy:enter connect scenes")
            click(1130, 707)
            mSleep(10 * 1000)
        else
            if os.time() - time > 3 * 60 then
                -- 3分钟还没进去，提示
                errorAndExit("enterdhxy:enter game timeout!!")
            else
                mSleep(5 * 1000)
            end
        end
    end
end

function initApp()
    Log.start("dhxy")
    Log.i("script begin!")
    unlockPhone()
    init(1)
    if rundhxy() then
        return enterdhxy()
    else
        return false
    end
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

-- 输出目标点的颜色，用于测试checkMultiColor
function debugMultiColor(colors)
    for _, v in ipairs(colors) do
        local color = getColor(v[1], v[2])
        Log.d(string.format("color: 0x%06x, 0x%06x", color, v[3]))
    end
end

-- 输入文本，pos是输入框的位置
function inputTextEx(pos, text)
    -- 切换到TS输入法
    switchTSInputMethod(true)

    -- 点击输入框
    click(pos)
    mSleep(4000)

    inputText(text)
    mSleep(4000)
    -- 点击确定按钮
    click(945, 1734)
    mSleep(4000)

    switchTSInputMethod(false)
end

-- 从大话精灵问道npc的坐标，自动寻路
-- npc的名字，答案中的自动寻路的位置
function gotoPosByDHJL(npc, position)
    click(90, 1404)
    sleep(2)

    -- 点击大话精灵
    click(683, 505)
    sleep(2)

    inputTextEx(pos(137, 603), npc)

    -- 点击旁边把选择结果去掉
    -- click(513, 201)
    -- sleep(2)

    -- 点击npc的位置
    click(position)
    sleep(1)

    -- 连续两次点击关闭
    click(929, 1660)
    sleep(2)
    click(929, 1660)
    sleep(2)

    return true
end

-- 点击按钮，弹出某个对话框
-- colors: 用于检测对话框是否真的弹出
-- function showDialog(buttonPos, colors, timeout)
--     click(buttonPos)
--     mSleep(100)
--     if colors then
--         return checkMultiColor(colors, timeout)
--     else
--         return true
--     end
-- end

-- 打开世界地图
-- function enterWorldMap()
--     if showDialog(pos(1000, 70), worldMapColors) then
--         Log.i("enterWorldMap success")
--         return true
--     else
--         Log.e("enterWorldMap failed")
--         return false
--     end
-- end

-- -- 打开本地地图
-- function enterLocalMap()
--     if showDialog(pos(1000, 215), localMapColors) then
--         Log.i("enterLocalMap success")
--         return true
--     else
--         Log.e("enterLocalMap failed")
--         return false
--     end
-- end

-- -- 关闭世界地图
-- function closeWorldMap()
--     if multiColor(worldMapColors) then
--         click(1031, 1871)
--         mSleep(100)
--         if checkMultiColor(worldMapColors) then
--             Log.e("closeWorldMap error")
--             return false
--         else
--             return true
--         end
--     else
--         return true
--     end
-- end

-- -- 关闭本地地图
-- function closeLocalMap()
--     if multiColor(localMapColors) then
--         click(968, 1565)
--         mSleep(100)
--         if checkMultiColor(localMapColors) then
--             Log.e("closeLocalMap error")
--             return false
--         else
--             return true
--         end
--     else
--         return true
--     end
-- end

-- 进入本地地图，点击某个点，并关闭本地地图
-- function toPosByLocalMap(x, y)
--     if not enterLocalMap() then return false end
--     click(x, y)
--     mSleep(50)
--     if closeLocalMap() then
--         return true
--     else
--         Log.e("toPosByLocalMap: local map not closed")
--         return false
--     end
-- end

-- 进入世界地图，点击某个场景，再点击小地图寻路，最后关闭小地图
-- function toPosByWorldMap(worldPos, localPos)
--     if not enterWorldMap() then return false end

--     click(worldPos)
--     mSleep(100)
--     if checkMultiColor(localMapColors) then
--         -- 本地地图已弹出
--         click(localPos)
--         mSleep(100)
--         if closeLocalMap() then
--             if closeWorldMap() then
--                 return true
--             else
--                 Log.e("toPosByWorldMap: world map not closed")
--                 return false
--             end
--         else
--             Log.e("toPosByWorldMap: local map not closed")
--             return false
--         end
--     else
--         Log.e("toPosByWorldMap: local map not open")
--         return false
--     end
-- end

-- 进入活动界面，检查活动是否完成,返回true和false，如果未完成，则点击前往按钮
-- colors: 相应活动的文字颜色，代替点阵寻找
-- 因为同样的坐标，scroll以后会到不同的位置，不知道怎么做到的，所以这个方法不可行
-- function checkActivityFinished(colors)
--     local xMargin, yMargin = 159, 698

--     if not showDialog(gActivityButtonPos, activityDialogColors) then
--         errorAndExit("enter activity dialog faield")
--         lua_exit()
--     end

--     local scrollCount = 0
--     while true do
--         -- 找到这个文字
--         if multiColor(colors) then
--             Log.d("find")
--             -- 未完成,点击前往
--             if multiColor(qianwangButtonColors) then
--                 click(777,  753)
--                 Log.d("not finish")
--                 return false
--             else
--                 -- 已完成
--                 Log.d("finished")
--                 return true
--             end
--         else
--             -- 没有找到，检查右边的那个任务
--             local rightColors = createNewColors(colors, 0, yMargin)
--             -- 右边找到了这个任务
--             if multiColor(rightColors) then
--                 Log.d("find in right")
--                 -- 右边的前往找到了，
--                 if multiColor(qianwangRightButtonColors) then
--                     Log.d("not finish")
--                     click(777, 753 + yMargin)
--                     return false
--                 else
--                     Log.d("finished")
--                     return true
--                 end
--             else
--                 Log.d("not find, scrolling")
--                 scrollCount = scrollCount + 1
--                 if scrollCount > 12 then
--                     -- 滚动多次还没找到，退出
--                     errorAndExit("not find avtivity text, exit!")
--                 end
--                 -- 右边也没有找到，开始翻页
--                 moveTo(333, 917, 333 + xMargin, 917, 10)
--                 mSleep(1000)
--                 -- continue
--                 -- break
--             end
--         end
--     end
-- end
