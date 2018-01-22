--作用：200环任务链
--时间：2017.3.4
--备注：

require("dhxy.functions")

-- 一个打五个的对话按钮
local fightButtonColors = {
    {1270, 631, 0xfff7e6},
    {1270, 672, 0xffe3a4},
    {1270, 697, 0xf7dba4},
    {1755, 697, 0xf7dba4},
    {1755, 661, 0xffe7ad},
    {1755, 633, 0xfff7de},
}

-- 回答问题的第二个按钮
local selectButtonColors = {
    {999, 639, 0xfff7e6},
    {1035, 635, 0xfffbe6},
    {995, 719, 0xf7dfa4},
    {995, 729, 0xd6a252},
    {1002, 685, 0xf7aa63},
    {1008, 681, 0x7b4531},
}

-- 活动面板上的文字颜色
-- local avtivityTextColors = {
--  {  753,  394, 0xad5552},
--  {  736,  394, 0xbd7d73},
--  {  736,  417, 0xa44d4a},
--  {  736,  443, 0xbd7973},
--  {  733,  470, 0x942d29},
--  {  733,  521, 0x943531},
--  {  733,  564, 0xce9a8c},
-- }

-- 选择题错了的对话框
local selectWrongColors = {
    {110, 796, 0xcecab5},
    {110, 793, 0x292421},
    {116, 795, 0xe6e3ce},
    {117, 804, 0xefebd6},
    {131, 805, 0xdedfc5},
    {170, 805, 0xded7c5},
    {143, 811, 0xd6cebd},
}

-- 购买宠物的前往捕捉按钮
local buyPetColors = {
    {1384, 212, 0xfffbe6},
    {1395, 226, 0xce9e6b},
    {1418, 228, 0xa46529},
    {1471, 250, 0xa45d21},
    {1568, 251, 0xa45d19},
    {1577, 242, 0xffebb5},
}

-- 购买宠物的购买按钮
local buyPetButtonColors = {
    {1121, 830, 0xd6efe6},
    {1147, 814, 0x7bc69c},
    {1217, 842, 0xa4bece},
    {1461, 809, 0x8ccaa4},
    {1178, 828, 0xeff7f7},
    {1488, 870, 0x29c6a4},
}

-- 上交按钮
local uploadButtonColors = {
    {1055, 813, 0x9cd7b5},
    {1144, 819, 0x8ccaa4},
    {1252, 843, 0x42b68c},
    {1054, 877, 0x29c6a4},
    {1170, 879, 0x29caad},
    {1270, 875, 0x31b694},
}

-- 选择题
local function selectCallback()
    Log.i("selectCallback: start")
    click(993, 664)
    mSleep(500)
    local count = 0
    while checkMultiColor(selectWrongColors) do
        count = count + 1
        if count > 30 then
            Log.e("selectCallback: wrong too many times")
            vibratorTimes()
            lua_exit()
        end
        -- 点击屏幕中间，让对话框小时
        click(display.center)
        mSleep(500)
        -- 答错了，继续,点击200环任务
        click(1647, 316)
        mSleep(1000)
        if checkMultiColor(selectButtonColors) then
            -- 选择题弹出来了
            click(993, 664)
            mSleep(500)
        else
            -- 选择题没弹出来
            Log.e("selectCallback: question do not open")
            vibratorTimes()
            lua_exit()
        end
    end
    Log.i("selectCallback: finish")
    return true
end

local function buyPet()
    Log.i("buyPet: start")
    -- 最后一个需求标记的坐标
    local taskSignColors = {
        {1185, 844, 0xffe394},
        {1203, 832, 0xffefad},
        {1212, 842, 0xf7d27b},
        {1249, 846, 0xffca8c},
        {1261, 850, 0xffba8c},
        {1274, 859, 0xffc2a4},
    }
    -- 当前页寻找满足条件的宠物
    local function findPet()
        local width, height = 475, 156
        for i = 0, 7 do
            local colors = clone(taskSignColors)
            for _, v in ipairs(colors) do
                v[1] = v[1] - width * math.floor(i / 4)
                v[2] = v[2] + height * (i % 4)
            end
            if multiColor(colors) then
                -- 找到需求的标记，点击购买
                click(colors[1][1] + 200, colors[1][2])
                mSleep(1000)
                if checkMultiColor(buyPetButtonColors) then
                    click(1294, 841)
                    mSleep(500)
                    return true
                else
                    Log.e("buyPet: buy dialog not open")
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
            Log.i("buyPet: finish")
            return true
        else
            -- 这一页没有满足需求的，翻页
            click(1587, 963)
            mSleep(500)
            count = count + 1
        end
    end

    Log.e("buyPet: not find pet")
    lua_exit()
end

-- 监视帮派任务
function watchTaskChains(finishCallback)
    Log.i("watchTaskChains: start")
    local finished = false

    local fightEvent = createMultiColorEvent(fightButtonColors, nil, function()
        click(1500, 672)
    end)
    local selectEvent = createMultiColorEvent(selectButtonColors, nil, selectCallback)
    local buyPetEvent = createMultiColorEvent(buyPetColors, nil, buyPet)
    local uploadEvent = createMultiColorEvent(uploadButtonColors, nil, function()
        click(1055, 813)
    end)
    -- local stopEvent = createMultiColorEvent(finishedColors, 6, function()
    --     Log.i("watchTaskChains: finished")
    --     -- 点击屏幕中央，让完成的对话框消失
    --     click(display.center)
    --     finished = true
    --     if finishCallback then finishCallback() end
    -- end)

    -- local events = {fightEvent, buyEvent, stopEvent}
    local events = {fightEvent, selectEvent, buyPetEvent, uploadEvent}
    while not finished do
        -- 匹配成功时，快速检查，没成功时检查比较慢，节约性能
        if checkAllEvents(events) then
            mSleep(1.5 * 1000)
        else
            mSleep(15 * 1000)
        end
    end
end

function main()
    if not initApp() then return end
    watchTaskChains(function()
        vibratorTimes()
    end)
end

-- 直接调用
if ... == nil then
    xpcallCustom(main)
end
