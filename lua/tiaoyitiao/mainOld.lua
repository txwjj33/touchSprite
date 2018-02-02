--[[
作用: 跳一跳
时间: 2018.1.13
备注: 由于背景颜色过段时间会变成完全不同的颜色，所以不能基于背景颜色来编码
]]

require("init")

-- 初始的棋子和物体位置固定
local initChessPos = pos(337, 1110)
local initItemPos = pos(789, 849)
local chessColor = getColor(initChessPos.x, initChessPos.y)
-- 背景从下往上有区别，所以选靠中间的点
local bgColor = getColor(display.cx, 600)
-- 观察到棋子和目标物体的中心位置好像是相对固定的,可以用这个中心位置来做粗略的寻找
-- 棋子与目标位置的中间点位置
local keyPosX = (initChessPos.x + initItemPos.x) / 2
local keyPosY = (initChessPos.y + initItemPos.y) / 2
local chessSimilar = 92
local bgSimilar = 95
local itemSimilar = 95

-- 在经过关键点的直线上，根据x，k计算y的值
-- 触动精灵把屏幕左上角作为原点，为了便于想象，计算的时候以左下角作为原点，因此y坐标需要调整
local function calY(x, k)
    local keyPosYFixed = display.height - keyPosY
    local yFixed = math.round((x - keyPosX) * k + keyPosYFixed)
    return display.height - yFixed
end

-- 在[x1, x2)区间中寻找棋子
local function findChessInRegion(x1, x2, k)
    -- 正斜率从左往右寻找，负斜率从右往左
    local step = k > 0 and 1 or -1
    for x = x1, x2, step do
        local y = calY(x, k)
        if isColor(x, y, chessColor, 94) then
            Log.d("findChessInRegion:%d-%d", x, y)
            -- 找到棋子上的一个点，往左右两边寻找边缘
            local xLeft = x - 1
            while isColor(xLeft, y, chessColor, chessSimilar) do
                xLeft = xLeft - 1
            end
            local xRight = x + 1
            while isColor(xRight, y, chessColor, chessSimilar) do
                xRight = xRight + 1
            end
            Log.d("xLeft-xright:%d-%d", xLeft, xRight)
            local chessPosX = math.floor((xLeft + xRight) / 2)
            -- 寻找棋子的最低点
            while isColor(chessPosX, y, chessColor, chessSimilar) do
                y = y + 1
            end
            -- 棋子的最低点到中心点的距离写死
            return pos(chessPosX, y - 20)
        end
    end
    return nil
end

local function findChess(k)
    local chessPos = nil
    if k > 0 then
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

-- 根据估算的物体位置计算精确的物体位置的x
-- x往上寻找第一个背景点，如果这个点的左右两边都是背景点，那么这个点就是所需
-- 如果右边的点不是背景点，那么以右边的点开始重复这个过程
-- 如果左边的点不是背景点，那么以左边的点开始重复这个过程
-- 因为左上方有阴影，所以必须先判断右边的点
local function findItem(itemPosEstimateX, itemPosEstimateY)
    -- 注意y坐标往上是-1
    local yTop = itemPosEstimateY - 1
    while not isColor(itemPosEstimateX, yTop, bgColor, bgSimilar) do
        yTop = yTop - 1
        -- 有时候可能寻找背景色一直找不到，防止死循环，这里强制返回
        if yTop < itemPosEstimateY - 160 then
            Log.i("not found bgColor, return")
            return itemPosEstimateX
        end
    end
    Log.d("yTop:%d", yTop)
    -- 因为锯齿有可能是有多个点，所以这里判断多个点，特别是圆形的物体顶部平行的点很多
    local checkNum = 20
    -- 检查右边的点
    for i = 1, checkNum do
        if not isColor(itemPosEstimateX + i, yTop, bgColor, bgSimilar) then
            Log.d("findItem right pos: %d", i)
            return findItem(itemPosEstimateX + i, yTop)
        end
    end
    -- 检查左边的点
    for i = 1, checkNum do
        if not isColor(itemPosEstimateX - i, yTop, bgColor, bgSimilar) then
            Log.d("findItem left pos: %d", i)
            return findItem(itemPosEstimateX - i, yTop)
        end
    end
    -- 物体的最上面那一行可能有多个像素，特别是圆形，所以求左右边界然后取平均值
    local itemMaxY = yTop + 1
    local itemColor = getColor(itemPosEstimateX, itemMaxY)
    local xLeft = itemPosEstimateX - 1
    while isColor(xLeft, itemMaxY, itemColor, itemSimilar) do
        xLeft = xLeft - 1
    end
    local xRight = itemPosEstimateX + 1
    while isColor(xRight, itemMaxY, itemColor, itemSimilar) do
        xRight = xRight + 1
    end
    return (xLeft + xRight) * 0.5
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
        Log.d("find chess: %d-%d-%f", chessPos.x, chessPos.y, k)
        -- 估算的物品的x
        local itemPosEstimateX = 2 * keyPosX - chessPos.x
        local itemPosEstimateY = calY(itemPosEstimateX, k)
        Log.d("find itemPosEstimateX: %d-%d", itemPosEstimateX, itemPosEstimateY)
        local itemPosX = findItem(itemPosEstimateX, itemPosEstimateY)
        local itemPosY = calY(itemPosX, k)
        Log.d("find item: %d-%d", itemPosX, itemPosY)
        keepScreen(false)
        -- 距离1：棋子到物品的距离
        -- return math.distance(itemPosX, itemPosY, chessPos.x, chessPos.y)
        -- 距离2：棋子到经过物品中心的斜率为-1/k的直线（与斜率为k的支线垂直）的距离
        -- 设物品中心坐标(x0, y0), 直线的方程是y = (-1/k)*x + (y0 - (-1/k) * x0)
        -- 化简是x + k*y - y0 * k - x0 = 0
        -- return math.abs(chessPos.x + k * chessPos.y - itemPosY * k - itemPosX) / math.sqrt(1 + k * k)
        local d1 = math.distance(itemPosX, itemPosY, chessPos.x, chessPos.y)
        local chessPosYFixed = display.height - chessPos.y
        local itemPosYFixed = display.height - itemPosY
        local d2 = math.abs(chessPos.x + k * chessPosYFixed - itemPosYFixed * k - itemPosX) / math.sqrt(1 + k * k)
        Log.d("dis:%f-%f", d1, d2)
        return d2
    end
end

local function main()
    sleep(1)
    Log.start("tiaoyitiao")
    Log.d("chessColor:0x%06x", chessColor)
    Log.d("bgColor:0x%06x", bgColor)
    local firstLoop = true
    local i = 0
    while true do
        i = i + 1
        snapshot(string.format("%s/%d.png", Log.getLogPath(), i), 0, 0, display.width - 1, display.height - 1)
        Log.d("start loop %d", i)
        local time
        if firstLoop then
            firstLoop = false
            -- 初始的物体位置固定
            local distance = math.distance(initChessPos.x, initChessPos.y, initItemPos.x, initItemPos.y)
            time = distance * 1.32
            -- time = math.abs(initChessPos.x - initItemPos.x) * 1.525
        else
            local k = - (initItemPos.y - initChessPos.y) / (initItemPos.x - initChessPos.x)
            local distance = nil
            while true do
                distance = calDisChessToItem(k)
                if not distance then
                    distance = calDisChessToItem(-k)
                end
                if not distance then
                    -- 没找到，可能是之前有点误差，在上面一点点寻找
                    keyPosY = keyPosY - 10
                    Log.d("search with keyPosY: %f", keyPosY)
                    if keyPosY < (initChessPos.y + initItemPos.y) / 2 - 80 then
                        errorAndExit("not find chess!")
                    end
                else
                    time = distance * 1.32
                    -- time = distance * 1.557
                    -- time = distance * 1.525
                    break
                end
            end
            keyPosY = (initChessPos.y + initItemPos.y) / 2
        end
        Log.d("time:%f", time)
        tap(display.cx, display.height - 100, time)
        -- 暂停等待跳跃动画结束
        sleep(4)
    end
end

main()
