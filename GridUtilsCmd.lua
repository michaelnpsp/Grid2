-- Process command line order

local display = {  never = 'Never', always = 'Always', grouped = 'Grouped', raid = 'Raid', toggle = false }

function Grid2:ProcessCommandLine(input)
	local command, param = strsplit(" ", input or "", 2)
	local c, p = strlower(command), strlower(param or "")
	if c=='lock' then -- lock toggle
		Grid2Layout:FrameLock( p~='toggle' or nil )
	elseif c=='unlock' then
		Grid2Layout:FrameLock(false)
	elseif c=='show' and display[p]~=nil then
		Grid2Layout:FrameVisibility( display[p] )
	elseif c=='theme' and param and not InCombatLockdown() then
		self:SetDefaultTheme( tonumber(param) or strtrim(param,'" ') )
	elseif c=='profile' and param and not InCombatLockdown() then
		local specIndex, profileName = strmatch( param, "(%d+) (.+)" )
		self:SetProfileForSpec( strtrim(specIndex and profileName or param,'" '), tonumber(specIndex) )
	elseif c=='profilesperspec' and (p=='enable' or p=='disable') and not InCombatLockdown() then
		self:EnableProfilesPerSpec( p=='enable' )
	elseif c=='minimapicon' and param then
		if p=='toggle' then
			self:SetMinimapIcon()
		else
			self:SetMinimapIcon(p~='hide')
		end
	elseif c=='help' then
		self:Print("commands (/grid2, /gr2)")
		print("    /grid2")
		print("    /grid2 options")
		print("    /grid2 help")
		print("    /grid2 unlock")
		print("    /grid2 lock")
		print("    /grid2 lock toggle")
		print("    /grid2 theme name || index")
		print("    /grid2 show never || always || grouped || raid || toggle\n")
		print("    /grid2 minimapicon show || hide || toggle ")
		print("    /grid2 profile name")
		if not self.isClassic then
			print("    /grid2 profile specIndex name")
			print("    /grid2 profilesperspec enable || disable")
		end
	end
end
