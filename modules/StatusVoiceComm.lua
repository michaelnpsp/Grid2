local Voice = Grid2.statusPrototype:new("voice")

local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale("Grid2")

local Grid2 = Grid2
local C_VoiceChat_GetMemberGUID = C_VoiceChat.GetMemberGUID

local cache = {}

function Voice:Grid_UnitUpdated(_, unit)
	cache[unit] = nil
end

function Voice:OnEnable()
	self:RegisterEvent("VOICE_CHAT_CHANNEL_MEMBER_SPEAKING_STATE_CHANGED")
	self:RegisterMessage("Grid_UnitLeft", "Grid_UnitUpdated")
	self:RegisterMessage("Grid_UnitUpdated")
end
	
function Voice:OnDisable()
	self:UnregisterEvent("VOICE_CHAT_CHANNEL_MEMBER_SPEAKING_STATE_CHANGED")
	self:UnregisterMessage("Grid_UnitLeft")
	self:UnregisterMessage("Grid_UnitUpdated")
	wipe(cache)
end

function Voice:VOICE_CHAT_CHANNEL_MEMBER_SPEAKING_STATE_CHANGED(_, memberID, channelID, isSpeaking)
	local guid = C_VoiceChat_GetMemberGUID( memberID, channelID )
	if guid then
		local unit = Grid2:GetUnitidByGUID(guid) 
		if unit then
			cache[unit] = isSpeaking or nil
			self:UpdateIndicators(unit)
		end	
	end
end

function Voice:IsActive(unit)
	return cache[unit]
end

local text = L["talking"]
function Voice:GetText(unitid)
	return text
end

function Voice:GetIcon(unitid)
	return "Interface\\COMMON\\VOICECHAT-SPEAKER"
end

Voice.GetColor = Grid2.statusLibrary.GetColor

local function Create(baseKey, dbx)
	Grid2:RegisterStatus(Voice, {"color", "text", "icon"}, baseKey, dbx)

	return Voice
end

Grid2.setupFunc["voice"] = Create

Grid2:DbSetStatusDefaultValue( "voice", {type = "voice", color1 = {r=1,g=1,b=0,a=1}})
