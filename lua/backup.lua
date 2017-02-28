--作用：一些备份的暂时没用到的函数
--时间：2017.2.28
--备注：
require("TSLib")

screenW, screenH = 1920, 1080

-- 手机纵向坐标转变横向坐标
function transToH(posx, posy)
    return posy, screenH - posx
end

-- 手机纵向区域转变横向区域
function transRectToH(posx1, posy1, posx2, posy2)
    return posy1, screenH - posx2, posy2, screenH - posx1
end

-- 手机横向坐标转成纵向坐标
function transToV(posx, posy)
    return screenH - posy, posx
end

-- 手机横向区域转成纵向区域
function transRectToV(posx1, posy1, posx2, posy2)
    return screenH - posy2, posx1, screenH - posy1, posx2
end

-- 计算两个点的相似度
local function calColorSimilary(color1, color2)
    local r1 = math.floor(color1 / (256 * 256))
    local g1 = math.floor((color1 - 256 * 256 * r1) / 256)
    local b1 = (color1 - 256 * 256 * r1) % 256

    local r2 = math.floor(color2 / (256 * 256))
    local g2 = math.floor((color2 - 256 * 256 * r2) / 256)
    local b2 = (color2 - 256 * 256 * r2) % 256

    local rSim = 1 - math.abs(r1 - r2) / 256
    local gSim = 1 - math.abs(g1 - g2) / 256
    local bSim = 1 - math.abs(b1 - b2) / 256

    return math.min(rSim, gSim, bSim)
end

-- 使用findMultiColorInRegionFuzzy实现多点找色
-- TSLib有了，不需要自己实现了
local function multiColor(data, sim)
    sim = sim or 1
    for i, v in ipairs(data) do
        if calColorSimilary(getColor(v[1], v[2]), v[3]) < sim then
            return false
        end
    end
    return true
end