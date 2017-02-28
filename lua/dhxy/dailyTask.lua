--作用：大话西游日常任务
--时间：2017.2.28
--备注：每天定时执行，包括帮派、师门、五环

require("utils")
require("functions")

local function main()
    if not initApp() then return end

    -- 进入帮派
    tap(1023, 1485)
    mSleep(2 * 1000)
    tap(381, 1159)
    mSleep(2 * 1000)
    tap(520, 1359)
    mSleep(2 *1000)
    tap(922, 1664)
    mSleep(10 * 1000)
    tap(100, 100)
    mSleep(2 * 1000)
    tap(600, 1477)
end

main()