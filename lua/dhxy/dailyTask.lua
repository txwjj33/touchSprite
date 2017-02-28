--作用：大话西游日常任务
--时间：2017.2.28
--备注：每天定时执行，包括帮派、师门、五环

require("utils")
require("dhxy.functions")
require("dhxy.gangs")
require("dhxy.masterTask")

local function main()
    if not initApp() then return end

    -- 开始帮派任务
    if enterGangs() then watchGangsTask() end

    -- 开始师门任务
    if enterMasterMap() then watchMasterTask() end

    -- 开始五环任务
    if toPosByWorldMap(pos(613, 1135), pos(416, 1176)) then
        mSleep(5 * 1000)
        click(304, 1606)
    else
        loge("start wuhuan error")
    end
end

main()