--[[
	Profiles export&import options
	General -> Profiles Tab -> Advanced Tab
--]]

local L = Grid2Options.L
local Grid2 = Grid2

local includeCustomLayouts

-- Plain hexadecimal encoding/decoding functions
local function HexEncode(s,title)
	local hex= { "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F" }
	local b_rshift = bit.rshift
	local b_and = bit.band
	local byte= string.byte
	local t= { string.format("[=== %s profile ===]",title or "") }
	local j= 0
	for i=1,#s do
		if j<=0 then
			t[#t+1], j = "\n", 32
		end
		j = j - 1
		--
		local b= byte(s,i)
		t[#t+1]= hex[ b_and(b,15) + 1 ]
		t[#t+1]= hex[ b_and(b_rshift(b,4),15) + 1 ]
	end
	t[#t+1]= "\n"
	t[#t+1]= t[1]
	return table.concat(t)
end

local function HexDecode(s)
	-- remove header,footer and any non hex character
	s= s:gsub("%[.-%]",""):gsub("[^0123456789ABCDEF]","")
	if (#s==0) or (#s%2 ~= 0) then return false, "Invalid Hex string" end
	-- lets go decoding
	local b_lshift= bit.lshift
	local byte= string.byte
	local char= string.char
	local t = {}
	local bl,bh
	local i = 1
	repeat
		bl = byte(s,i)
		bl = bl>=65 and bl-55 or bl-48
		i = i + 1
		bh = byte(s,i)
		bh = bh>=65 and bh-55 or bh-48
		i = i + 1
		t[#t+1] = char( b_lshift(bh,4) + bl )
	until i>=#s
	return table.concat(t)
end

-- Its not a deep copy, only root keys are duplicated
local function MoveTableKeys(src,dst)
	if src and dst then
		for k,v in pairs(src) do
			dst[k] = v
		end
	end
end

-- Serialize current profile table into a string variable
-- Hex:  true/Encode in plain hexadecimal   false/Encode to be transmited by addon comm channel
local function SerializeCurrentProfile(Hex, exportCustomLayouts )
	local config= { ["Grid2"] = Grid2.db.profile }
	for name, module in Grid2:IterateModules() do
		local data = Grid2.db:GetNamespace(name,true)
		if data then
			config[name] = data.profile
		end
	end
	config["@Grid2Options"] = Grid2Options.db.profile
	if exportCustomLayouts then -- Special ugly case for Custom Layouts
		local data = Grid2.db:GetNamespace('Grid2Layout',true)
		if data then
			config["@Grid2Layout"] = data.global
		end
	end
	local Serializer = LibStub:GetLibrary("AceSerializer-3.0")
	local Compresor = LibStub:GetLibrary("LibCompress")
	local result = Compresor:CompressHuffman(Serializer:Serialize(config))
	if Hex then
		result= HexEncode(result, Grid2.db:GetCurrentProfile())
	else
		result= Compresor:GetAddonEncodeTable():Encode(result)
	end
	return result
end

-- Deserialize a profile string into a table:
-- Hex:  true/String is encoded in plain hexadecimal   false/String is encoded to be transmited through chat channels
local function UnserializeProfile(data,Hex)
	local Compresor = LibStub:GetLibrary("LibCompress")
	local err
	if Hex then
		data,err = HexDecode(data)
	else
		data,err = Compresor:GetAddonEncodeTable():Decode(data), "Error decoding profile"
	end
	if data	then
		data,err = Compresor:DecompressHuffman(data)
		if data then
			return LibStub:GetLibrary("AceSerializer-3.0"):Deserialize( data )
		end
	end
	return false,err
end

-- Generates a new profile name
local function ExtractProfileName(data)
	local header= strsub(data,1,64)
	local name= (header:match("%[(.-)%]") or header):gsub("=",""):gsub("profile",""):trim()
	if name~="" then
		return name
	end
end

local function ValidateProfileName(profileName)
	local profiles= Grid2.db:GetProfiles()
	local function ProfileExists(name)
		for _,value in ipairs(profiles) do
			if name==value then return true end
		end
	end
	if not profileName then
		profileName = UnitName("player").." - "..GetRealmName()
	end
	local name,i = profileName,1
	while ProfileExists(profileName) do
		i = i + 1
		profileName= name .. i
	end
	return profileName
end

-- Unserialize a profile string into a new AceDB profile
local function ImportProfile(sender, data, Hex, importCustomLayouts)
	if type(data)~="string" then
		print("Grid2 Import profile failed, data supplied must be a string")
		return false
	end
	if not sender and Hex then
		sender= ExtractProfileName(data)
	end
	local profileName= ValidateProfileName(sender)
	local Success
	Success,data= UnserializeProfile(data,Hex)
	if not Success then
		print("Grid2 Import profile failed: ",data)
		return false
	end
	if importCustomLayouts and data["@Grid2Layout"] then -- Special ugly case for Custom Layouts
		local db = Grid2.db:GetNamespace("Grid2Layout",true)
		if db then
			local customLayouts = data["@Grid2Layout"].customLayouts
			if customLayouts then
				if not db.global.customLayouts then	db.global.customLayouts = {} end
				MoveTableKeys( customLayouts, db.global.customLayouts)
				Grid2Layout:AddCustomLayouts()
			end
		end
	end
	local prev_Hook= Grid2.ProfileChanged
	Grid2.ProfileChanged= function(self)
		self.ProfileChanged= prev_Hook
		for key,section in pairs(data) do
			local db
			if key=="Grid2" then
				db= self.db
			elseif key=="@Grid2Options" then
				db= Grid2Options.db
			else
				db= self:GetModule(key,true) and self.db:GetNamespace(key,true)
			end
			if db then
				MoveTableKeys(section, db.profile)
			end
		end
		self:ProfileChanged()
		Grid2Options:NotifyChange()
	end
	Grid2.db:SetProfile(profileName)
	if importCustomLayouts then
		Grid2Options:AddNewCustomLayoutsOptions()
	end
	return true
end

-- Show a Editbox where the user can copy or paste serialized profiles
local function ShowSerializeFrame(title,subtitle,data)
	local AceGUI = LibStub("AceGUI-3.0")
	local frame = AceGUI:Create("Frame")
	frame:SetTitle(L["Profile import/export"])
	frame:SetStatusText(subtitle)
	frame:SetLayout("Flow")
	frame:SetCallback("OnClose", function(widget) AceGUI:Release(widget) end)
	frame:SetWidth(525)
	frame:SetHeight(375)
	local editbox = AceGUI:Create("MultiLineEditBox")
	editbox.editBox:SetFontObject(GameFontHighlightSmall)
	editbox:SetLabel(title)
	editbox:SetFullWidth(true)
	editbox:SetFullHeight(true)
	frame:AddChild(editbox)
	if data then
		editbox:DisableButton(true)
		editbox:SetText(data)
		editbox.editBox:SetFocus()
		editbox.editBox:HighlightText()
		editbox:SetCallback("OnLeave", function(widget)	widget.editBox:HighlightText() widget:SetFocus() end)
		editbox:SetCallback("OnEnter", function(widget)	widget.editBox:HighlightText() widget:SetFocus() end)
	else
		editbox:DisableButton(false)
		editbox.button:SetScript("OnClick",
								function()
									frame:Hide()
									ImportProfile(nil, editbox:GetText(), true, includeCustomLayouts)
									collectgarbage()
								end)
	end
end

-- Network Communication management
local Comm = {}

function Comm:Enable(receive)
	if not self.RegisterComm then
		LibStub("AceComm-3.0"):Embed(self)
	end
	if not C_ChatInfo.IsAddonMessagePrefixRegistered("Grid2") then
		C_ChatInfo.RegisterAddonMessagePrefix("Grid2")
	end
	if receive then
		self.listening= true
		self:RegisterComm("Grid2","OnCommReceived")
	else
		self.listening= false
		self:UnregisterAllComm()
	end
end

function Comm:SendMessage(message, target)
	if not self.RegisterComm then self:Enable() end
	self:SendCommMessage("Grid2", message, "WHISPER", target, "NORMAL", Comm.ShowProgress, self)
end

function Comm:ShowProgress(sent,total)
	local label= self.label
	if not label then
		local AceGUI = LibStub("AceGUI-3.0")
		local frame = AceGUI:Create("Frame")
		frame:SetTitle(L["Progress"] )
		frame:SetStatusText( string.format(L["Data size: %.1fKB"],total/1000) )
		frame:SetLayout("Fill")
		frame:SetCallback("OnClose", function(widget) AceGUI:Release(widget) self.label= nil end)
		frame:SetWidth(380)
		frame:SetHeight(160)
		label = AceGUI:Create("Label")
		frame:AddChild(label)
		label:SetFontObject(GameFontHighlightHuge)
		label:SetFullWidth(true)
		label:SetFullHeight(true)
		self.textFmt= "\n" .. L["Transmision progress: %d%%"]
		self.label= label
	end
	if sent<total then
		label:SetText( string.format(self.textFmt,sent/total*100) )
	else
		label:SetText( "\n"..L["Transmission completed"] )
	end
end

function Comm:OnCommReceived(prefix, message, distribution, sender)
	Grid2Options:ConfirmDialog(
		string.format(L["\"%s\" has sent you a profile configuration. Do you want to activate received profile ?"],sender or "unknow"),
		function()
			ImportProfile(sender, message)
			collectgarbage()
		end
	)
end

-- Profile database cleaning
local CleanDatabase, uiReloadPending
do
	local count
	local function msg(text)
		count = count + 1
		print( 'Grid2: '..text )
	end
	local function CleanDatabaseItems( itemType, setup )
		for baseKey, dbx in pairs(setup) do
			if not (dbx.type and Grid2.setupFunc[dbx.type]) then
				setup[baseKey] = nil
				msg( string.format( "Removed orphan %s type=[%s] name=[%s]:", itemType, dbx.type or "nil", baseKey) )
			end
		end
	end
	local function GetMultibarCheck(indicator) -- return max valid priority for the multibar indicator, sanity check to multibar priorities removing invalid status mapings
		return (indicator.dbx and indicator.dbx.type == 'multibar' and -- is a multibar ?
				indicator.parentName==nil and  -- ignore multibar-color indicators (they share same dbx than multibar)
				#indicator.dbx+1)  -- #indicator.dbx+1 == number of statuses in statusMap[indicator-name] entry for the multibar indicator
	end

	local function CleanStatusMap(setup)
		for baseKey, map in pairs(setup) do
			local indicator = Grid2.indicators[baseKey]
			if indicator then
				local multibarCheck = GetMultibarCheck(indicator)
				for statusKey, priority in pairs(map) do
					local status = Grid2.statuses[statusKey]
					if (not ( status and tonumber(priority) )) or (multibarCheck and priority>multibarCheck) then
						map[statusKey] = nil
						msg( string.format( "Removed map for indicator=[%s] <=> status=[%s], reason: status does not exist or wrong priority.", baseKey, statusKey ) )
					end
				end
			else
				setup[baseKey] = nil
				msg( string.format( "Removed statusMap for non existent [%s] indicator.", baseKey ) )
			end
		end
	end

	local function RenameIndicator(db, oldName, newName)
		if db.indicators[oldName]~=nil and db.indicators[newName]==nil then
			db.indicators[newName] = db.indicators[oldName]
			db.indicators[oldName] = nil
			if db.statusMap[oldName]~=nil and db.statusMap[newName]==nil then
				db.statusMap[newName] = db.statusMap[oldName]
				db.statusMap[oldName] = nil
			end
		end
	end

	local function FixDatabaseIndicators(db)
		local blacklist = Grid2Options.indicatorBlacklistNames
		local indicators = {}
		for k,v in pairs(db.indicators) do
			if blacklist[k] then
				indicators[#indicators+1] = k
			end
		end
		if #indicators>0 then
			uiReloadPending = true
			for _,oldName in ipairs(indicators) do
				local newName = oldName..'-indicator'
				RenameIndicator(db, oldName, newName)
				RenameIndicator(db, oldName..'-color', newName..'-color')
				msg( string.format( "Indicator [%s] renamed to [%s].", oldName, newName ) )
			end
		end
	end

	CleanDatabase = function(db)
		count = 0
		CleanDatabaseItems( "status", db.statuses )
		CleanDatabaseItems( "indicator", db.indicators )
		CleanStatusMap( db.statusMap )
		FixDatabaseIndicators(db)
		return count
	end
end

-- Publish some useful functions
function Grid2Options:ExportText(title,data)
	ShowSerializeFrame(title,'',data)
end

-- {{ Create profile advanced options
Grid2Options.AdvancedProfileOptions = { type = "group", order= 200, name = L["Import&Export"], desc = L["Options for %s."]:format(L["Import&Export"]), args = {
	header1 ={
		type = "header",
		order = 10,
		name = L["Profile import/export"],
	},
	import = {
		type = "execute",
		order = 11,
		name = L["Import profile"],
		func = function ()
			ShowSerializeFrame(	L["Paste here a profile in text format"],
								L["Press CTRL-V to paste a Grid2 configuration text"] )
		end,
	},
	export = {
		type = "execute",
		order = 12,
		name = L["Export profile"],
		func = function (info)
			ShowSerializeFrame(	L["This is your current profile in text format"],
								L["Press CTRL-C to copy the configuration to your clipboard"],
								SerializeCurrentProfile(true, includeCustomLayouts) )
		end,
	},
	incLayouts = {
		type = "toggle",
		order = 13,
		name = L["Include Custom Layouts"],
		width = "double",
		get = function () return includeCustomLayouts end,
		set = function () includeCustomLayouts = not includeCustomLayouts end,
	},
	header2 ={
		type = "header",
		order = 35,
		name = L["Network sharing"],
	},
	network= {
		type = "toggle",
		order = 60,
		name = L["Accept profiles from other players"],
		width= "double",
		get = function () return Comm.listening	end,
		set = function () Comm:Enable(not Comm.listening) end,
	},
	player = {
		type = "input",
		order = 40,
		width = "normal",
		name = L["Type player name"],
		get = function()  return Comm.target or "" end,
		set = function(_,v)	Comm.target= v end,
	},
	send = {
		type = "execute",
		order = 50,
		name = L["Send current profile"],
		func = function ()
			if Comm.target and Comm.target~="" then
				local message = SerializeCurrentProfile()
				Comm:SendMessage(message, Comm.target)
			end
		end,
	},
	header3 ={
		type = "header",
		order = 90,
		name = L["Profile database maintenance"],
	},
	cleanDatabase = {
		type = "execute",
		order= 100,
		width = 2,
		name = L["Clean Current Profile"],
		desc = L["Remove invalid or obsolete objects (indicators, statuses, etc) from the current profile database."],
		func = function()
			if CleanDatabase(Grid2.db.profile)>0 then
				print("Grid2: Database clean finished, some errors were fixed, an UI Reload is advised.")
			else
				print("Grid2: Database check finished, database is ok, nothing to fix.")
			end
		end,
		confirm = function() return L["Warning, the clean process will remove statuses and indicators of non enabled modules. Are you sure you want to clean the current profile ?"] end,
		disabled = function() return uiReloadPending end, -- We cannot clean the database a second time without a ui reload if an indicator was renamed in the first cleaning
	},
} }
-- }}
