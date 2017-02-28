--作用：帮派任务
--时间：2017.2.25
--备注：

-- 一个打五个的对话按钮
local fightButtonData = {
	{  449, 1270, 0xfff7e6},
	{  408, 1270, 0xffe3a4},
	{  383, 1270, 0xf7dba4},
	{  383, 1755, 0xf7dba4},
	{  419, 1755, 0xffe7ad},
	{  447, 1755, 0xfff7de},
}

-- 购买按钮
local buyButtonData = {
	{  220, 1243, 0xffffff},
	{  148, 1243, 0x31c6a4},
	{  161, 1558, 0x31ba94},
	{  225, 1553, 0x9cdbbd},
}

-- 帮派任务做完对话框里的两个表情
local stopData = {
	{  330,  109, 0x94867b},
	{  343,  227, 0x949673},
	{  343,  337, 0xc5b294},
	{   30,  108, 0x847d6b},
	{   16,  206, 0x948e7b},
	{   16,  422, 0x948e73},
}

local function click(x, y, time)
	touchDown(x, y)
	mSleep(time or 50)
	touchUp(x, y)
end

-- 多次震动，默认四次
local function vibratorTimes(times)
	times = times or 4
	for i = 0, times do
		vibrator()
		mSleep(1000)
	end
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
local function multiColor(data, sim)
	sim = sim or 1
	for i, v in ipairs(data) do
		if calColorSimilary(getColor(v[1], v[2]), v[3]) < sim then
			return false
		end
	end
	return true
end

-- 创建多点颜色检测的事件
-- 可以检测需点击按钮，或者任务完成等
-- data: 多点颜色检测的数据
-- count: 多点颜色检测连续成功的次数，大于等于maxCount次算识别成功
-- callback: 识别成功以后的回调
local function createMultiColorEvent(data, maxCount, callback)
	local t = {}
	local count = 0
	maxCount = maxCount or 3

	-- 执行一次检测
	-- 返回值：0-识别成功，1-检测成功，2-检测失败
	t.check = function(self)
		if multiColor(data, 0.9) then
			count = count + 1
			if count >= maxCount then
				if callback then callback() end
				count = 0
				return 0
			else 
				return 1
			end
		else
			count = 0
			return 2
		end
	end

	t.reset = function(self)
		count = 0
	end

	return t
end

-- 检查所有的events
-- 每个event都是由createMultiColorEvent创建的
local function checkAllEvents(events)
	for i, event in ipairs(events) do
		local result = event:check()
		if result == 0 or result == 1 then
			-- 这个识别了，把其他的reset
			for j, e in ipairs(events) do
				if j ~= i then e:reset() end
			end
			return
		else
			event:reset()
		end
	end
end

-- 检查当前任务类型
local function checkTaskType()
end

-- 开始帮派任务
local function startBangPaiTask()
end

-- 监视帮派任务
local function watchTask()
	local fightEvent = createMultiColorEvent(fightButtonData, nil, function()
			click(408, 1500)
		end)
	local buyEvent = createMultiColorEvent(buyButtonData, nil, function()
			click(188, 1429)
		end) 

	local stopEvent = createMultiColorEvent(stopData, 5, function()
			vibratorTimes()
		end)

	local events = {fightEvent, buyEvent, stopEvent}
	while true do
		checkAllEvents(events)
		mSleep(2000)
	end
end

watchTask()

