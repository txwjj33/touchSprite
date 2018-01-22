--[[
作用：数学增强库
时间：2018.1.15
备注：
1）直线方程ax+by+c=0，直线对象为{a=a, b=b, c=c}
2）经过两点(x1, y1), (x2, y2)的直线，斜率为(y2-y1)/(x2-x1)
3）以下实现的函数都以过一点及斜率的方式确定直线
]]

require("math")

function math.round(x)
    return math.floor(x + 0.5)
end

-- 求两点之间的距离
function math.distance(x1, y1, x2, y2)
    return math.sqrt(math.pow(x1 - x2, 2) + math.pow(y1 - y2, 2))
end

-- 经过点(x0, y0)的斜率为k的直线，返回直线对象
-- 方程为kx-y+(y0-k*x0)=0
function math.line(x, y, k)
    return {a = k, b = -1, c = y - k * x}
end

-- 经过点(x0, y0)的斜率为k的直线的垂直直线，返回直线对象
-- 斜率为-1/k，直线方程是y=(-1/k)*x+(y0-(-1/k)*x0)
-- 化简是x+k*y+(-y0*k-x0)=0
function math.perpendicularLine(x, y, k)
    return {a = 1, b = k, c = -y * k - x}
end

-- 计算直线上某点x对应的y
function math.calYInLine(x, line)
    local a, b, c = line.a, line.b, line.c
    return - (a * x + c) / b
end

-- 计算直线上某点y对应的x
function math.calXInLine(y, line)
    local a, b, c = line.a, line.b, line.c
    return - (b * y + c) / a
end

-- 点(x0, y0)到直线(ax+by+c=0)的距离
-- |a*x0+b*y0+c|/sqrt(a*a+b*b)
function math.disPosToLine(x, y, line)
    local a, b, c = line.a, line.b, line.c
    return math.abs(a * x + b * y + c) / math.sqrt(a * a + b * b)
end

-- 点(x0, y0)到直线(ax+by+c=0)的垂足
function math.perpendicularPoint(x, y, line)
    local a, b, c = line.a, line.b, line.c
    local x1 = (b * b * x - a * b * y - a * c) / (a * a + b * b)
    local y1 = (- a * b * x + a * a * y - b * c) / (a * a + b * b)
    return x1, y1
end

-- 点(x0, y0)到直线(ax+by+c=0)的对称点
function math.symmetryPoint(x, y, line)
    local a, b, c = line.a, line.b, line.c
    local k = - 2 * (a * x + b * y + c) / (a * a + b * b)
    return x + k * a, y + k * b
end

-- 两条直线的交点
function math.intersectionPoint(line1, line2)
    local a1, b1, c1 = line1.a, line1.b, line1.c
    local a2, b2, c2 = line2.a, line2.b, line2.c
    local x = (c2 * b1 - c1 * b2) / (a1 * b2 - a2 * b1)
    local y = (c2 * a1 - c1 * a2) / (b1 * a2 - b2 * a1)
    return x, y
end

--判断某个点是否在某个多边形内部
function math.isPointInPolyon(vertices, point)
    local i, j
    local result = false
    local n = #vertices
    local j = n
    for i = 1, n do
        if ((vertices[i].y > point.y) ~= (vertices[j].y > point.y)) and
            (point.x < (vertices[j].x - vertices[i].x) * (point.y - vertices[i].y) / (vertices[j].y - vertices[i].y) + vertices[i].x) then
            result = not result
        end
        j = i
        i = i + 1
    end
    return result
end

--判断某个点是否在某个多边形内部(含边)
function math.isPointInPolyonIncludeSide(vertices, point)
    local i, j
    local result = false
    local n = #vertices
    local j = n
    for i = 1, n do
        if vertices[j].y == vertices[i].y then
            --在边上
            if point.y == vertices[i].y and (point.x - vertices[i].x) * (point.x - vertices[j].x) <= 0 then
                return true
            end
        else
            --在边上
            if (point.y - vertices[i].y) * (point.y - vertices[j].y) <= 0 and
                (point.x == (vertices[j].x - vertices[i].x) * (point.y - vertices[i].y) / (vertices[j].y - vertices[i].y) + vertices[i].x) then
                return true
            end
            if ((vertices[i].y > point.y) ~= (vertices[j].y > point.y)) and
                (point.x < (vertices[j].x - vertices[i].x) * (point.y - vertices[i].y) / (vertices[j].y - vertices[i].y) + vertices[i].x) then
                result = not result
            end
        end
        j = i
        i = i + 1
    end
    return result
end
