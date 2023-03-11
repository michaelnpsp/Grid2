local L = Grid2Options.L

function Grid2Options:MakeStatusBuffsListOptions(status, options, optionParams)
	self:MakeHeaderOptions( options, "AurasExpanded" )
	options.aurasList = {
		type = "input", dialogControl = "Grid2ExpandedEditBox",
		order = 310,
		width = "full",
		name = "",
		multiline = math.min( math.max(status.dbx.auras and #status.dbx.auras or 0,5),10),
		get = function()
			local auras = {}
			for _,aura in pairs(status.dbx.auras) do
				auras[#auras+1]= (type(aura)=="number") and GetSpellInfo(aura) or aura
			end
			return table.concat( auras, "\n" )
		end,
		set = function(_, v)
			wipe(status.dbx.auras)
			local auras = { strsplit("\n,", strtrim(v)) }
			for _,name in pairs(auras) do
				local aura = strtrim(name)
				if #aura>0 then
					table.insert(status.dbx.auras, tonumber(aura) or aura )
				end
			end
			status:Refresh()
		end,
		hidden = function() return status.dbx.auras==nil end
	}
	return options
end

Grid2Options:RegisterStatusOptions("buffs", "buff", function(self, status, options, optionParams)
	if status.dbx.subType == 'blizzard' then
		self:MakeStatusColorOptions(status, options, optionParams)
	else
		self:MakeStatusBuffsListOptions(status, options, optionParams)
		self:MakeStatusAuraCommonOptions(status, options, optionParams)
		self:MakeStatusAuraMissingOptions(status, options, optionParams)
		self:MakeStatusColorOptions(status, options, optionParams)
		self:MakeStatusAuraColorThresholdOptions(status, options, optionParams)
		self:MakeStatusBlinkThresholdOptions(status, options, optionParams)
	end
end,{
	groupOrder = 20, isDeletable = true,
})
