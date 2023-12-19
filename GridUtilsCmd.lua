-- Process command line order

local Grid2 = Grid2

local display = { never = 'Never', always = 'Always', grouped = 'Grouped', raid = 'Raid', toggle = false }

local function ProcessMinimapCmd(p)
	if p=='global' then
		Grid2.db.global.minimapIcon = (Grid2.db.global.minimapIcon==nil) and {hide=false} or nil
		ReloadUI()
	elseif p=='toggle' then
		Grid2:SetMinimapIcon()
	else
		Grid2:SetMinimapIcon(p~='hide')
	end
end

local ProcessNameListCmd
do
	local function GetHeaderType(header)
		return header.headerName or header.type or 'players'
	end

	local function DisplayNameListError()
		print("Grid2 Error: Name list or header type not found in the active layout. You must open the layout editor to create a custom layout and a namelist to use this feature.")
	end

	local function SearchHeader(headerName)
		local layout, header = Grid2Layout.layoutSettings[Grid2Layout.layoutName]
		headerName = strlower(headerName)
		for idx, data in ipairs(layout) do
			if data.nameList then
				header = header or data
				if headerName==strlower(data.headerName or '*') then
					return data, true
				end
			end
		end
		return header, false
	end

	local function GetMouseOverPlayer()
		local name, server = UnitName('mouseover')
		if name then
			return (server and server ~= "") and name.."-"..server or name
		end
	end

	local function ToggleNameList(header, name)
	   if name then
		  local lst = header.nameList
		  local nam = ',' .. name .. ','
		  local str = ',' .. lst .. ','
		  if strfind(str, nam, 1, true) then -- del player name
			 nam = nam:gsub("(%W)", "%%%1")
			 repeat
				local old = str
				str = old:gsub(nam, ',')
			 until str == old
			 header.nameList = str:gsub('^,',''):gsub(',$','')
			 print( string.format( 'Grid2: Removed [%s] from [%s] name list.', name, GetHeaderType(header)) )
		  else -- add player name
			 header.nameList = (lst=='') and name or (lst..','..name)
			 print( string.format( 'Grid2: Added [%s] to [%s] name list.', name, GetHeaderType(header)) )

		  end
	   end
	end

	local function DisplayNameList(header)
		if header then
			print( string.format( 'Grid2 nameList [%s]: "%s"', GetHeaderType(header), header.nameList) )
		else
			DisplayNameListError()
		end
	end

	function ProcessNameListCmd(param)
		if param then
			local cmd, rst = strsplit(" ", param, 2)
			local header, flag = SearchHeader(cmd)
			if header then
				if flag then
					cmd = rst
				elseif rst then
					print("Grid2 Error: Too many command line arguments or specified header type not found in active layout.");	return
				end
				if cmd==nil then
					DisplayNameList(header); return
				elseif strlower(cmd) == 'clear' then
					header.nameList = ""
					print( string.format( 'Grid2: Removed all players from [%s] name list.', GetHeaderType(header)) )
				elseif strlower(cmd) == '@mouseover' then
					ToggleNameList( header, GetMouseOverPlayer() )
				elseif cmd then
					ToggleNameList( header, cmd )
				end
				Grid2Layout:RefreshLayout()
				if Grid2Options then Grid2Options:RefreshOptions() end
			else
				DisplayNameListError();	return
			end
		else
			DisplayNameList( SearchHeader('') )
		end
	end
end

local function ProcessHelpCmd()
	Grid2:Print("commands (/grid2, /gr2)")
	print("    /grid2")
	print("    /grid2 options")
	print("    /grid2 help")
	print("    /grid2 unlock")
	print("    /grid2 lock")
	print("    /grid2 lock toggle")
	print("    /grid2 theme name || index")
	print("    /grid2 show never || always || grouped || raid || toggle\n")
	print("    /grid2 minimapicon show || hide || toggle || global")
	print("    /grid2 profile <profile_name>")
	if not Grid2.isClassic then
		print("    /grid2 profile specIndex name")
		print("    /grid2 profilesperspec enable || disable")
	end
	print("    /grid2 namelist || nl [header_type] clear || @mouseover || <player_name>")
end

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
		ProcessMinimapCmd(p)
	elseif c=='help' then
		ProcessHelpCmd()
	elseif c=='namelist' or c=='nl' then
		ProcessNameListCmd(param)
	end
end
