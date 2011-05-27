-- Simple color status , created by Michael 

local Grid2= Grid2

local function Color_Dummy()
end

local function Color_IsActive()
	return true
end

local function Color_GetColor(self)
	local c = self.dbx.color1
	return c.r, c.g, c.b, c.a
end

local function CreateColor(baseKey, dbx)
	local status = Grid2.statusPrototype:new(baseKey, false)
	status.OnEnable = Color_Dummy
	status.OnDisable= Color_Dummy
	status.IsActive = Color_IsActive
	status.GetColor = Color_GetColor
	Grid2:RegisterStatus(status, {"color"}, baseKey, dbx)
	return status
end

Grid2.setupFunc["color"] = CreateColor
