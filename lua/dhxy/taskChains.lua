--作用：200环任务链
--时间：2017.3.4
--备注：

require("dhxy.functions")

-- 一个打五个的对话按钮
local fightButtonColors = {
    {  449, 1270, 0xfff7e6},
    {  408, 1270, 0xffe3a4},
    {  383, 1270, 0xf7dba4},
    {  383, 1755, 0xf7dba4},
    {  419, 1755, 0xffe7ad},
    {  447, 1755, 0xfff7de},
}

-- 回答问题的第二个按钮
local selectButtonColors = {
	{  416,  993, 0xffdf6b},
	{  412, 1003, 0x7b4931},
	{  435, 1100, 0xfff7de},
	{  365, 1219, 0xffebad},
	{  398, 1004, 0x7b4129},
	{  398, 1015, 0xffb263},
}

-- 选择题错了的对话框
local selectWrongColors = {
	{  285,  114, 0xefe3d6},
	{  288,  126, 0xbdbaa4},
	{  288,  149, 0xcec2b5},
	{  265,  183, 0xcecabd},
	{  261,  205, 0xe6dfce},
	{  269,  267, 0xefebd6},
	{  260,  273, 0xadaa9c},
}

-- 购买宠物的前往捕捉按钮
local buyPetColors = {
	{  868, 1384, 0xfffbe6},
	{  854, 1395, 0xce9e6b},
	{  852, 1418, 0xa46529},
	{  830, 1471, 0xa45d21},
	{  829, 1568, 0xa45d19},
	{  838, 1577, 0xffebb5},
}

-- 购买宠物的购买按钮
local buyPetButtonColors = {
	{  250, 1121, 0xd6efe6},
	{  266, 1147, 0x7bc69c},
	{  238, 1217, 0xa4bece},
	{  271, 1461, 0x8ccaa4},
	{  252, 1178, 0xeff7f7},
	{  210, 1488, 0x29c6a4},
}

-- 选择题
local function selectCallback()
	logi("selectCallback: start")
	click(416, 993)
	mSleep(500)
	local count = 0
	while checkMultiColor(selectWrongColors) do
		count = count + 1
		if count > 30 then
			loge("selectCallback: wrong too many times")
			vibratorTimes()
			lua_exit()
		end
		-- 点击屏幕中间，让对话框小时
		click(display.center)
		mSleep(500)
		-- 答错了，继续,点击200环任务
		click(764, 1647)
		mSleep(1000)
		if checkMultiColor(selectButtonColors) then
			-- 选择题弹出来了
			click(416, 993)
			mSleep(500)
		else
			-- 选择题没弹出来
			loge("selectCallback: question do not open")
			vibratorTimes()
			lua_exit()
		end
	end
	logi("selectCallback: finish")
	return true
end

local function buyPet()
	logi("buyPet: start")
	-- 横屏状态下最后一个需求标记的坐标
	local taskSignColors = {
		{  236, 1185, 0xffe394},
		{  248, 1203, 0xffefad},
		{  238, 1212, 0xf7d27b},
		{  234, 1249, 0xffca8c},
		{  230, 1261, 0xffba8c},
		{  221, 1274, 0xffc2a4},
	}
	-- 当前页寻找满足条件的宠物
	local function findPet()
		local width, height = 156, 475
		for i = 0, 7 do
			local colors = clone(taskSignColors)
			for _, v in ipairs(colors) do
				v[1] = v[1] + width * (i % 4)
				v[2] = v[2] - math.floor(i / 4)
			end
			if multiColor(colors) then
				-- 找到需求的标记，点击购买
				click(colors[1][1], colors[1][2] + 200)
				mSleep(1000)
				if checkMultiColor(buyPetButtonColors) then
					click(239, 1294)
					mSleep(500)
					return true
				else
					loge("buyPet: buy dialog not open")
					vibratorTimes()
					lua_exit()
				end
			end
		end
		return false
	end

	local count = 0
	while count < 10 do
		if findPet() then
			logi("buyPet: finish")
			return true
		else
			-- 这一页没有满足需求的，翻页
			click(117, 1587)
			mSleep(500)
			count = count + 1
		end
	end

	loge("buyPet: not find pet")
	lua_exit()
end

-- 监视帮派任务
function watchTaskChains(finishCallback)
    logi("watchTaskChains: start")
    local finished = false

    local fightEvent = createMultiColorEvent(fightButtonColors, nil, function()
        click(408, 1500)
    end)
    local selectEvent = createMultiColorEvent(selectButtonColors, nil, selectCallback)
    local buyPetEvent = createMultiColorEvent(buyPetColors, nil, buyPet)
    -- local stopEvent = createMultiColorEvent(finishedColors, 6, function()
    --     logi("watchTaskChains: finished")
    --     -- 点击屏幕中央，让完成的对话框消失
    --     click(display.center)
    --     finished = true
    --     if finishCallback then finishCallback() end
    -- end)

    -- local events = {fightEvent, buyEvent, stopEvent}
    local events = {fightEvent, selectEvent, buyPetEvent}
    while not finished do
        -- 匹配成功时，快速检查，没成功时检查比较慢，节约性能
        if checkAllEvents(events) then
            mSleep(1.5 * 1000)
        else
            mSleep(15 * 1000)
        end
    end
end

-- 直接调用
if ... == nil then
    startLog("dhxy")
    watchTaskChains(function()
        vibratorTimes()
    end)
end
