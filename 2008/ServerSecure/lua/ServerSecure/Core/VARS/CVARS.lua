CVAR            = {} -- CVAR table
CVAR.Store      = {} -- Where CVARS are stored
CVAR.Friendlies = {} -- Where friendly names are stored

// New CVAR

function CVAR.New(Player, Index, Friendly, Value)
	local Identity = Player:SteamID()
	
	Index = string.lower(Index)
	
	local Ready = Player:IsReady()
	
	if not (Ready) then return end
	
	CVAR.Store[Identity][Index] = CVAR.Store[Identity][Index] or Value
	
	CVAR.Friendlies[Index] = Friendly
end

// Create CVARS

function CVAR.Create(Player)
	local Identity = Player:SteamID()
	
	CVAR.Store[Identity] = CVAR.Store[Identity] or {}
end

// Format CVARS

function CVAR.Format(Index)
	Index = string.lower(Index)
	
	if (CVAR.Friendlies[Index]) then
		local Type = type(CVAR.Friendlies[Index])
		
		if (Type == "function") then
			return CVAR.Friendlies[Index]()
		end
		
		return CVAR.Friendlies[Index]
	end
end

// Get a CVAR

function CVAR.Request(Player, Index)
	local Identity = Player:SteamID()
	
	Index = string.lower(Index)

	local Ready = Player:IsReady()
	
	if not (Ready) then return end
	
	if (CVAR.Store[Identity][Index]) then
		CVAR.Store[Identity][Index] = SS.Lib.StringValue(CVAR.Store[Identity][Index])
	end

	return CVAR.Store[Identity][Index]
end

// Update CVAR

function CVAR.Update(Player, Index, Value)
	local Identity = Player:SteamID()
	
	Index = string.lower(Index)
	
	local Ready = Player:IsReady()
	
	if not (Ready) then return end
	
	CVAR.Store[Identity][Index] = Value
	
	SS.Player.PlayerUpdateGUI(Player)
end

// Insert value into a CVAR

function CVAR.Insert(Player, Index, Value)
	local Identity = Player:SteamID()
	
	Index = string.lower(Index)
	
	local Ready = Player:IsReady()
	
	if not (Ready) then return end
	
	if CVAR.Store[Identity][Index] then
		table.insert(CVAR.Store[Identity][Index], Value)
	end
end

// Clear CVAR

function CVAR.Clear(Player)
	local Identity = Player:SteamID()
	
	CVAR.Store[Identity] = nil
end

// Save CVARS

function CVAR.Save(Player)
	local Identity = Player:SteamID()
	
	local Ready = Player:IsReady()
	
	if not (Ready) then return end
	
	local Contents = util.TableToKeyValues(CVAR.Store[Identity])
	
	local Save = string.gsub(Identity, ":", "-")
	
	file.Write("SS/CVARS/"..Save..".txt", Contents)
	
	SS.Player.PlayerUpdateGUI(Player)
	
	SS.Hooks.Run("PlayerDataSaved", Player)
end

// Load CVARS

function CVAR.Load(Player)
	local Identity = Player:SteamID()
	
	local Save = string.gsub(Identity, ":", "-")
	
	if (file.Exists("SS/CVARS/"..Save..".txt")) then
		local File = file.Read("SS/CVARS/"..Save..".txt")
		
		if (File) then
			CVAR.Store[Identity] = util.KeyValuesToTable(File)
		end
	end
	
	SS.Hooks.Run("PlayerDataLoaded", Player)
end