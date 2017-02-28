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
end

main()