require("functions")

-- 天庭每50分钟启动一次
--for i = 1, 4 do
--	runApp("com.netease.dhxy.wdj")
--	mSleep(3000)
--	lockDevice()
--	mSleep(5000)
--	unlockDevice()
--	mSleep(50 * 60 * 1000)
--end
--initLog(log_name, flag)

--runApp("com.netease.dhxy.wdj")
mSleep(1000)
lockDevice()
unlock()

local t = {{251, 1057}, {251, 1057}, {544, 1057}, {838, 1057}}
clickMultiPoint(t)