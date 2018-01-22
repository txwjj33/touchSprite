--作用：大话西游日常任务
--时间：2017.2.28
--备注：每天定时执行，包括帮派、师门、五环

require("utils")
require("dhxy.functions")
require("dhxy.gangs")
require("dhxy.masterTask")

local function main()
    -- 先关闭程序 免得大话精灵的回答坐标位置变化
    closeApp(gBid)
    mSleep(5 * 1000)

    if not initApp() then return end

    -- 开始帮派任务
    if enterGangs() then watchGangsTask() end

    -- 开始师门任务
    if enterMasterMap() then watchMasterTask() end

    -- 开始五环任务
    if not gotoPosByDHJL("五环任务坐标", pos(1017, 439)) then
        return false
    end
    sleep(10)
    click(display.center)
    sleep(2)
    click(1606, 776)
end

-- 直接调用
if ... == nil then
    xpcallCustom(main)
end
