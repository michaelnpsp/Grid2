local Grid2 = Grid2
local next = next
local pairs = pairs

local Portraits = {}

local function Portrait_Create(self, parent)		
	local frame = self:CreateFrame("Frame", parent) 
	if self.dbx.portraitType == '3D' then
		frame.portraitModel = frame.portraitModel or CreateFrame("PlayerModel" , nil, frame)
	else
		frame.portraitTexture = frame.portraitTexture or frame:CreateTexture(nil, "ARTWORK")
	end
	if self.dbx.backColor then
		frame.portraitBack = frame.portraitBack or frame:CreateTexture(nil, "BACKGROUND")
		frame.portraitBack:SetAllPoints()
	end	
end

local function Portrait_OnUpdateClass(self, parent, unit)
	local Portrait = parent[self.name]
	local class = select(2, UnitClass(unit))
	if class then
		Portrait.portraitTexture:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes")
		Portrait.portraitTexture:SetTexCoord(CLASS_ICON_TCOORDS[class][1], CLASS_ICON_TCOORDS[class][2], CLASS_ICON_TCOORDS[class][3], CLASS_ICON_TCOORDS[class][4])
	else
		Portrait.portraitTexture:SetTexture("")
	end
end

local function Portrait_OnUpdate2D(self, parent, unit)
	local Portrait = parent[self.name]
	Portrait.portraitTexture:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	SetPortraitTexture(Portrait.portraitTexture, unit)
end

local function Portrait_OnUpdate3D(self, parent, unit, event)
	local Portrait = parent[self.name].portraitModel
	if not UnitIsVisible(unit) or not UnitIsConnected(unit) then
		Portrait:ClearModel()
		Portrait:SetCamDistanceScale(0.25)
		Portrait:SetPortraitZoom(0)
		Portrait:SetPosition(0, 0, 0.25)
		Portrait:SetModel([[Interface\Buttons\TalkToMeQuestionMark.m2]])
		Portrait.guid = nil
	else
		local guid = UnitGUID(unit)
		if guid ~= Portrait.guid or event == 'UNIT_MODEL_CHANGED' then
			Portrait:SetCamDistanceScale(1)
			Portrait:SetPortraitZoom(1)
			Portrait:SetPosition(0, 0, 0)
			Portrait:ClearModel()
			Portrait:SetUnit(unit)
			Portrait.guid = guid
		end	
	end
end

local function Portrait_Layout(self, parent)
	local Portrait, container = parent[self.name], parent.container
	local dbx = self.dbx
	local l   = dbx.location
	Portrait:SetParent(parent)
	Portrait:ClearAllPoints()
	Portrait:SetFrameLevel(parent:GetFrameLevel() + (dbx.level or 4) )
	Portrait:SetPoint(l.point, container, l.relPoint, l.x, l.y)
	Portrait:SetWidth( dbx.width or container:GetWidth() )
	Portrait:SetHeight( dbx.height or container:GetHeight() )
	local b = dbx.innerBorder or 0
	if dbx.portraitType == '3D' then
		Portrait.portraitModel:ClearAllPoints()
		Portrait.portraitModel:SetPoint("TOPLEFT", Portrait, "TOPLEFT", b, -b)
		Portrait.portraitModel:SetPoint("BOTTOMRIGHT", Portrait, "BOTTOMRIGHT", -b-1, b)
		Portrait.portraitModel:Show()

	else
		Portrait.portraitTexture:ClearAllPoints()
		Portrait.portraitTexture:SetPoint("TOPLEFT", Portrait, "TOPLEFT", b, -b)
		Portrait.portraitTexture:SetPoint("BOTTOMRIGHT", Portrait, "BOTTOMRIGHT", -b, b)
		Portrait.portraitTexture:Show()
	end
	local c = dbx.backColor
	if c then
		Portrait.portraitBack:SetColorTexture(c.r, c.g, c.b, c.a)
		Portrait.portraitBack:Show()
	end	
	Portrait:Show()
end

local function Portrait_Disable(self, parent)
	local f = parent[self.name]
	f:Hide()
	f:SetParent(nil)
	f:ClearAllPoints()
	if f.portraitModel    then f.portraitModel:Hide()   end
	if f.portraitTexture  then f.portraitTexture:Hide() end
	if f.portraitBack     then f.portraitBack:Hide()    end
end

local function Portrait_OnSuspend(self)
	Portraits[self] = nil
	if not next(Portraits) then
		Grid2:UnregisterEvent("UNIT_PORTRAIT_UPDATE")
		Grid2:UnregisterEvent("UNIT_MODEL_CHANGED")
	end
end

local function UpdatePortraits(event, unit)
	for parent in next, Grid2:GetUnitFrames(unit) do
		for indicator in pairs(Portraits) do
			indicator:OnUpdate(parent, unit, event)
		end
	end
end

local function Portrait_LoadDB(self)
	self.OnUpdate = (self.dbx.portraitType == '3D' and Portrait_OnUpdate3D) or
					(self.dbx.portraitType == 'class' and Portrait_OnUpdateClass) or
					Portrait_OnUpdate2D
	if not next(Portraits) then 
		Grid2:RegisterEvent("UNIT_PORTRAIT_UPDATE", UpdatePortraits)
		Grid2:RegisterEvent("UNIT_MODEL_CHANGED", UpdatePortraits)
	end
	Portraits[self] = true
end

local function Create(indicatorKey, dbx)
	local indicator = Grid2.indicators[indicatorKey] or Grid2.indicatorPrototype:new(indicatorKey)
	indicator.dbx = dbx
	indicator.Create = Portrait_Create
	indicator.Layout = Portrait_Layout
	indicator.Disable = Portrait_Disable
	indicator.OnSuspend = Portrait_OnSuspend
	indicator.LoadDB = Portrait_LoadDB
	Grid2:RegisterIndicator(indicator, { "portrait" })
	return indicator
end

Grid2.setupFunc["portrait"] = Create
