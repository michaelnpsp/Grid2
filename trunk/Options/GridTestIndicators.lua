--[[
Created by Michael
--]]

local TestIcons = {
	[1] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_1", 
	[2] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_2", 
	[3] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_3", 
	[4] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_4", 
	[5] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_5", 
	[6] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_6",
	[7] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_7", 
	[8] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_8"  
}

local Test
local function CreateTestStatus()
	Test = Grid2.statusPrototype:new("test",false)
	function Test:OnEnable() 
	end
	function Test:OnDisable() 
	end
	function Test:IsActive() 
		return true 
	end
	function Test:GetText()
		return "99"
	end
	function Test:GetColor()
		return math.random(0,1),math.random(0,1),math.random(0,1),1
	end
	function Test:GetPercent()
		return math.random()
	end
	function Test:GetIcon(unit)
		return TestIcons[ math.random(#TestIcons) ]
	end
	Grid2:RegisterStatus(Test, { "text","color", "percent", "icon"}, "test")
end

local function IndicatorsEnableTestMode()
	CreateTestStatus()
	for _, indicator in Grid2:IterateIndicators() do
		indicator:RegisterStatus(Test,1)
	end
	Grid2Frame:UpdateIndicators()
end

local function IndicatorsDisableTestMode()
	for _, indicator in Grid2:IterateIndicators() do
		indicator:UnregisterStatus(Test)
	end
	Test= nil
	Grid2Frame:UpdateIndicators()
end

function Grid2Options:IndicatorsTestMode()
	if Test then
		IndicatorsDisableTestMode()
		return false
	else
		IndicatorsEnableTestMode()
		return true
	end
end

