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

function clickMultiPoint(points)
	for _, v in ipairs(points) do
		tap(v[1], v[2])
		mSleep(30)
	end
end

-- 多次震动，默认四次
function vibratorTimes(times)
	times = times or 4
	for i = 0, times do
		vibrator()
		mSleep(1000)
	end
end

function unlock()
	if deviceIsLock() == 0 then return end

	logi("start unlock")
	mSleep(1000)
	unlockDevice()
	mSleep(1000)
	-- 往上滑
	moveTo(540, 1900, 540, 800, 30)
	mSleep(500)

	-- 输入密码
	local t = {{251, 1057}, {251, 1057}, {544, 1057}, {838, 1057}}
	clickMultiPoint(t)
end

function rundhxy()
	-- 主界面左上角的图标
	local enterData = {
		{ 1054,   38, 0xefc26b},
		{ 1048,   38, 0xde415a},
		{ 1039,   38, 0xb58142},
		{ 1027,   38, 0x6bf3f7},
		{ 1016,   38, 0xf7f3a4},
		{ 1005,   38, 0xadf3de},
		{  989,   38, 0xf7f3ef},
	}
	-- 开始界面的按钮
	local startButton = {
		{  232,  829, 0x3acea4},
		{  220,  829, 0xf7efd6},
		{  187,  882, 0xffffff},
		{  225, 1132, 0xefdbc5},
		{  152, 1154, 0x31cea4},
		{  162, 1106, 0x63ba94},
	}
	-- 连接网络的按钮
	local connectButton = {
		{  408, 1264, 0xb5dfbd},
		{  385, 1189, 0xeff7ef},
		{  350, 1047, 0x3abe94},
		{  394,  870, 0xfff3d6},
		{  384,  798, 0x9c5919},
		{  350,  662, 0xffe7a4},
	}

	local time = os.time()
	runApp("com.netease.dhxy.wdj")
	logd("rundhxy:run app")
	mSleep(20 * 1000)
	while true do
		if multiColor(enterData) then
			logi("rundhxy:enter game")
			-- 已进入界面
			return true
		elseif multiColor(startButton) then
			-- 在开始游戏界面
			logi("rundhxy:enter start game")
			tap(176, 967)
			mSleep(10 * 1000)
		elseif multiColor(connectButton) then
			-- 连接网络界面
			logi("rundhxy:enter connect scenes")
			tap(373, 1130)
			mSleep(10 * 1000)
		else
			logd("time:" .. os.time() - time)
			if os.time() - time > 3 * 60 then
				-- 3分钟还没进去，提示
				loge("rundhxy:enter game timeout!!")
				vibratorTimes(5)
				return false
			else
				mSleep(5 * 1000)
			end
		end
	end
end

function startLog()
	logName = os.date("%Y_%m_%d-%H_%M_%S")
end

function logd(msg)
	log(string.format("[D]%s", msg), logName)
end

function logi(msg)
	log(string.format("[I]%s", msg), logName)
end

function loge(msg)
	log(string.format("[E]%s", msg), logName)
end


function test()
	startLog()
	logi("script begin!")
	unlock()
	mSleep(50)
	if not rundhxy() then return end
	
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

test()
require("bangpai")




