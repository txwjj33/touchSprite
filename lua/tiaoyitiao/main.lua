--[[
作用: 跳一跳
时间: 2018.1.13
备注:
]]

require("utils")

local initChessPos, initItemPos   -- 初始的棋子和物体位置固定
local chessColor   -- 棋子的颜色
local chessSimilar = 94   -- 棋子颜色的精确度
local chessBottomMargin = 20   --棋子底部到中心的距离
-- 观察到棋子和目标物体的中心位置好像是相对固定的,可以用这个中心位置来做粗略的寻找
-- 棋子与目标位置的中间点位置
local keyPosX, keyPosY

local function init()
    if display.width == 1080 and display.height == 1920 then
        initChessPos = pos(337, 1110)
        initItemPos = pos(789, 849)
    elseif display.width == 1080 and display.height == 2160 then
        initChessPos = pos(337, 1230)
        initItemPos = pos(789, 969)
    end
    chessColor = getColor(initChessPos.x, initChessPos.y)
    keyPosX = (initChessPos.x + initItemPos.x) / 2
    keyPosY = (initChessPos.y + initItemPos.y) / 2
end
-- 在经过关键点的直线上，根据x，k计算y的值
local function calY(x, k)
    return math.round(keyPosY + (x - keyPosX) * k)
end

-- 在[x1, x2)区间中寻找棋子
local function findChessInRegion(x1, x2, k)
    -- 正斜率从左往右寻找，负斜率从右往左
    local step = k < 0 and 1 or -1
    for x = x1, x2, step do
        local y = calY(x, k)
        if isColor(x, y, chessColor, chessSimilar) then
            Log.i("findChessInRegion:%d-%d", x, y)
            -- 找到棋子上的一个点，往左右两边寻找边缘
            local xLeft = x - 1
            while isColor(xLeft, y, chessColor, chessSimilar) do
                xLeft = xLeft - 1
            end
            local xRight = x + 1
            while isColor(xRight, y, chessColor, chessSimilar) do
                xRight = xRight + 1
            end
            Log.i("xLeft-xright:%d-%d", xLeft, xRight)
            local chessPosX = math.floor((xLeft + xRight) / 2)
            -- 寻找棋子的最低点
            while isColor(chessPosX, y, chessColor, chessSimilar) do
                y = y + 1
            end
            return pos(chessPosX, y - chessBottomMargin)
        end
    end
    return nil
end

local function findChess(k)
    local chessPos = nil
    if k < 0 then
        -- 先找比较靠近中心的，节省时间
        chessPos = findChessInRegion(200, keyPosX, k)
        if not chessPos then chessPos = findChessInRegion(100, 200, k) end
        if not chessPos then chessPos = findChessInRegion(0, 100, k) end
    else
        chessPos = findChessInRegion(display.width - 200, keyPosX, k)
        if not chessPos then chessPos = findChessInRegion(display.width - 100, display.width - 200, k) end
        if not chessPos then chessPos = findChessInRegion(display.width, display.width - 100, k) end
    end
    return chessPos
end

-- 在关键点所处的两个直线下往上寻找棋子，计算棋子到关键点的位置
-- k直线对应的斜率
local function calDisChessToItem(k)
    keepScreen(true)
    local chessPos = findChess(k)
    if not chessPos then
        keepScreen(false)
        return nil
    else
        Log.i("find chess: %d-%d-%f", chessPos.x, chessPos.y, k)
        local line1 = math.line(keyPosX, keyPosY, k)
        local line2 = math.line(chessPos.x, chessPos.y, -k)
        -- 如果某次跳跃有点不准，且下次跳跃的方向不一样时，通过取这两条直线的交点可以修正失误
        local px, py = math.intersectionPoint(line1, line2)
        Log.i("find intersectionPoint: %d-%d", px, py)
        local itemPosX = 2 * keyPosX - px
        local itemPosY = calY(itemPosX, k)
        Log.i("find itemPos: %d-%d", itemPosX, itemPosY)
        keepScreen(false)
        return math.distance(itemPosX, itemPosY, px, py)
    end
end

local function main()
    sleep(1)
    Log.start("tiaoyitiao")
    init()
    local firstLoop = true
    local i = 0
    while true do
        i = i + 1
        if DEBUG then
            snapshotEx(tostring(i))
        end
        Log.i("start loop %d", i)
        local time
        if firstLoop then
            firstLoop = false
            -- 初始的物体位置固定
            local distance = math.distance(initChessPos.x, initChessPos.y, initItemPos.x, initItemPos.y)
            time = distance * 1.32
        else
            local k = (initItemPos.y - initChessPos.y) / (initItemPos.x - initChessPos.x)
            local distance = nil
            while true do
                distance = calDisChessToItem(k)
                if not distance then
                    distance = calDisChessToItem(-k)
                end
                if not distance then
                    -- 没找到，可能是之前有点误差，在上面一点点寻找
                    keyPosY = keyPosY - 10
                    Log.i("search with keyPosY: %f", keyPosY)
                    if keyPosY < (initChessPos.y + initItemPos.y) / 2 - 120 then
                        errorAndExit("not find chess!")
                    end
                else
                    time = distance * 1.32
                    break
                end
            end
            keyPosY = (initChessPos.y + initItemPos.y) / 2
        end
        tap(display.cx, display.height - 100, time)
        -- 暂停等待跳跃动画结束
        sleep(4)
    end
end

xpcallCustom(main)
