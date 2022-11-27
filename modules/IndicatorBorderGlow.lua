--[[ Square indicator, created by Grid2 original authors, modified by Michael ]]--

local LCG = LibStub("LibCustomGlow-1.0")

local Grid2 = Grid2

local colorTable = {}

local function BorderGlow_GetFrame(parent)
	return parent
end

local function BorderGlow_OnUpdate(self, parent, unit, status)
	if status then
		local color = self.color
		if not color then
			color = colorTable
			colorTable[1], colorTable[2], colorTable[3], colorTable[4] = status:GetColor(unit)
		end
		local effect = self.effect
		if effect==1 then
			LCG.PixelGlow_Start( parent, color, self.linesCount, self.frequency, nil, self.thickness, self.offsetX, self.offsetY, false, self.name )
		elseif effect==2 then
			LCG.AutoCastGlow_Start( parent, color, self.particlesCount, self.frequency, self.particlesScale, self.offsetX, self.offsetY, self.name )
		else
			LCG.ButtonGlow_Start( parent, color, self.frequency )
		end
	else
		self.GlowStop(parent, self.name)
	end
end

local function BorderGlow_Disable(self, parent)
	self.GlowStop(parent, self.name)
end

local function BorderGlow_UpdateDB(self)
	local dbx = self.dbx
	local color = dbx.glowColor
	self.color  = color and { color.r, color.g, color.b, color.a } or nil
	self.effect = dbx.glowType or 1
	self.frequency = dbx.frequency or (self.effect==1 and 0.25) or 0.12
	self.offsetX = dbx.offsetX or 0
	self.offsetY = dbx.offsetY or 0
	self.linesCount= dbx.linesCount or 8
	self.thickness = dbx.thickness or 2
	self.particlesCount = dbx.particlesCount or 4
	self.particlesScale = dbx.particlesScale or 1
	self.GlowStop = (self.effect==1 and LCG.PixelGlow_Stop) or (self.effect==2 and LCG.AutoCastGlow_Stop) or LCG.ButtonGlow_Stop
end


local function Create(indicatorKey, dbx)
	local indicator = Grid2.indicatorPrototype:new(indicatorKey)
	indicator.dbx = dbx
	indicator.Create = Grid2.Dummy
	indicator.Layout = Grid2.Dummy
	indicator.GetFrame = BorderGlow_GetFrame
	indicator.OnUpdate = BorderGlow_OnUpdate
	indicator.Disable = BorderGlow_Disable
	indicator.UpdateDB = BorderGlow_UpdateDB
	Grid2:RegisterIndicator(indicator, { "color" })
	return indicator
end

Grid2.setupFunc["glowborder"] = Create
