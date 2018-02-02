--[[
作用: 大话西游通用函数
时间: 2017.2.28
备注:
]]

require("dhxy.constants")

function enterdhxy()
    local time = os.time()
    while true do
        if multiColor(gMapButtonColors) then
            Log.i("enterdhxy:enter game")
            -- 已进入界面
            return true
        elseif ocrText(386, 6, 524, 31, 1, "抵制不良游戏") == "抵制不良游戏" then
            -- 在开始游戏界面
            Log.i("enterdhxy:enter start game")
            click(967, 904)
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
    if runAppEx(gDHXYBid) then
        return enterdhxy()
    else
        return false
    end
end

-- 检查当前程序是否在前台
-- 如果在前台，返回false
-- 如果不在, 重新启动, 启动成功返回true, 启动失败退出
function checkDHXYFront(bid)
    if isFrontApp(gDHXYBid) == 0 then
        Log.w("app not in front, restart")
        if runAppEx(gDHXYBid) then
            return enterdhxy()
        else
            errorAndExit("restart failed")
        end
    else
        return false
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

-- 进入活动界面，检查活动是否完成,返回true和false，如果未完成，则点击前往按钮
-- name: 活动的名字
-- x2: 活动的名字ocr识别时x2值, 默认是529, 不同的活动名字长度不一样
function checkTaskFinished(name, x2)
    click(gActivityButtonPos)
    mSleep(500)
    if not Condition.checkText(225, 946, 331, 983, 1, "活跃度") then
        errorAndExit("checkTaskFinished: enter activity dialog failed")
    end

    -- 大理寺答题可能识别为 大王星寺答
    local words = "家园灵修魔王窟大理寺答题200环任务链竞技场帮派师门情花宝图五环地煞星入定修炼独步天下武曜台"
    words = words .. "天庭降妖野外封妖三界妖王大雁塔心魔试炼地宫八卦降魔混元顶寻芳南斗星象"
    words = words .. "天降灵猴决战长安水陆大会帮派大战大闹天宫"
    local i = 0
    -- 每页6个任务，一般最多4页
    while i < 4 do
        for j = 0, 5 do
            local xFixed = (j % 2) * 700
            local yFixed = math.floor(j / 2) * 174
            if ocrTextDebug(392 + xFixed, 310 + yFixed, (x2 or 529) + xFixed, 357 + yFixed, 1, words) == name then
                Log.i("%s found", name)
                -- 前往按钮
                local x, y = findMultiColorInRegionFuzzyDebug(0x6bc69c, "36|-1|0xe6f7ef", 90,
                    730 + xFixed, 300 + yFixed, 840 + xFixed, 360 + yFixed)
                if x ~= -1 and y ~= -1 then
                    -- 未完成, 点击前往, 活动界面自动关闭
                    click(x, y)
                    Log.i("%s not finish", name)
                    return false
                else
                    Log.i("%s finished", name)
                    -- 关闭活动界面
                    click(1663, 152)
                    mSleep(500)
                    return true
                end
            end
        end
        -- 滚动到下一页
        moveTo(917, 747, 917, 747 - 492, 10)
        mSleep(1000)
        i = i + 1
    end
    errorAndExit("not find task %s, exit!", name)
end

-- 执行任务, data是任务的数据，包含的字段有以下
-- name: 任务名字
-- ocrName: 活动面板上识别的名字, 可能跟任务名字不一样, 如果为空, 则使用name
-- ocrX2: 活动的名字ocr识别时x2值, 可以为空, 默认是529
-- loop: loop函数
-- interval: loop的间隔时间, 单位是, 默认10s
-- finishCondition: 完成条件
-- finishCallback: 完成回调, 可以为空
-- timeout: 任务超时时间, 从点击开始按钮时算起, 默认15分钟
--  TODO(优化): startEvent, 如果任一个event监测成功，那么置started标记，startEvent事件不再监测，节省时间
function runTask(data)
    Log.i("start task %s", data.name)
    if checkTaskFinished(data.ocrName or data.name, data.ocrX2) then return end

    local startTime = os.time()
    local interval = data.interval or 10
    sleep(interval)
    while not data.finishCondition() do
        if checkDHXYFront() then
            Log.i("restart dhxy, restart task %s", data.name)
            -- 重启成功, 重新开始当前任务
            runTask(data)
            return
        end
        if os.time() - startTime > (data.timeout or 15 * 60) then
            errorAndExit("runTask error, timeout: %s", data.name)
        end
        if data.loop then data.loop() end
        sleep(interval)
    end
    Log.i("finish task %s", data.name)
    if data.finishCallback then data.finishCallback() end
end
