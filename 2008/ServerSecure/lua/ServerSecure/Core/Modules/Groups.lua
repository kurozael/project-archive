SS.Groups = {} -- Groups functions.

// Variables

SS.Groups.List      = {} -- Groups.
SS.Groups.Loaded    = {} -- Loaded
SS.Groups.Current   = 0 -- Current Index.

// Add a group

function SS.Groups:New(ID)
	local Table = {}
	
	setmetatable(Table, self)
	
	self.__index = self
	
	Table.Settings         = {}
	Table.Settings.Name    = ID
	Table.Settings.Color   = Color(200, 200, 200, 200)
	Table.Settings.Weapons = {}
	Table.Settings.Flags   = {}
	Table.Settings.Bool    = false
	Table.Settings.Model   = ""
	
	return Table
end

// Color

function SS.Groups:Color(R, G, B, A)
	self.Settings.Color = Color(R, G, B, A)
end

// Weapons

function SS.Groups:Weapons(...)
	local Table = {}
	
	for I = 1, table.getn(arg) do
		Table[I] = arg[I]
	end
	
	self.Settings.Weapons = Table
end

// Flags

function SS.Groups:Flags(...)
	local Table = {}
	
	for I = 1, table.getn(arg) do
		Table[I] = arg[I]
	end
	
	self.Settings.Flags = Table
end

// Default

function SS.Groups:Starting()
	self.Settings.Bool = true
end

// Model

function SS.Groups:Model(Model)
	self.Settings.Model = Model
end

// Rank

function SS.Groups:Position(Number)
	self.Settings.Rank = Number
end

// Finish

function SS.Groups:Create()
	SS.Groups.Current = SS.Groups.Current + 1
	
	if not (self.Settings.Rank) then
		SS.Lib.Error("No rank specified for "..self.Settings.Name.."!")
	else
		table.insert(SS.Groups.List, {self.Settings.Name, SS.Groups.Current, self.Settings.Color, self.Settings.Model, self.Settings.Weapons, self.Settings.Rank, self.Settings.Bool, self.Settings.Flags})
	end
end

// Insert steamid to be a group

function SS.Groups.Insert(Steam, Group)
	if not (SS.Groups.Exists(Group)) then
		SS.Lib.Debug("Tried to insert "..Steam.." into "..Group.." which doesn't exist!")
	else
		Steam = string.lower(Steam)
		
		SS.Groups.Loaded[Steam] = Group
	end
end

// See if group exists

function SS.Groups.Exists(ID)
	for K, V in pairs(SS.Groups.List) do
		if (string.lower(V[1]) == string.lower(ID)) then
			return true
		end
	end
	
	return false
end

// Get group index by name

function SS.Groups.Index(ID)
	for K, V in pairs(SS.Groups.List) do
		if (string.lower(V[1]) == string.lower(ID)) then
			return V[2]
		end
	end
	
	return 0
end

// Get group name by index

function SS.Groups.Name(Index)
	for K, V in pairs(SS.Groups.List) do
		if (V[2] == Index) then
			return V[1]
		end
	end
	
	return "Unknown"
end

// Get starting group

function SS.Groups.Default()
	for K, V in pairs(SS.Groups.List) do
		if (V[7]) then
			return V[1]
		end
	end
	
	return "Unknown"
end

// Find a group

function SS.Groups.Find(String)
	for K, V in pairs(SS.Groups.List) do
		if (string.find(string.lower(V[1]), string.lower(String))) then
			return V[1], "Found a match!"
		end
	end
	
	return false, "No matches found for '"..String.."'"
end

// Get group rank

function SS.Groups.Rank(ID)
	for K, V in pairs(SS.Groups.List) do
		if (string.lower(V[1]) == string.lower(ID)) then
			return V[6]
		end
	end
	
	return 0
end

// Get group ID

function SS.Groups.ID(Rank)
	for K, V in pairs(SS.Groups.List) do
		if (V[6] == Rank) then
			return V[1]
		end
	end
	
	return SS.Groups.Default()
end

// PlayerInitialSpawn hook

function SS.Groups.Setup(Player)
	SS.Lib.Debug("Sending groups to "..Player:Name())
	
	for K, V in pairs(SS.Groups.List) do
		umsg.Start("SS.Groups.Setup", Player)
			umsg.String(V[1])
			umsg.Short(V[2])
			umsg.Short(V[3].r)
			umsg.Short(V[3].g)
			umsg.Short(V[3].b)
			umsg.Short(V[3].a)
			umsg.Short(V[6])
		umsg.End()
	end
end

// Hook into player initial spawn

SS.Hooks.Add("SS.Groups.Setup", "PlayerInitialSpawn", SS.Groups.Setup)

// ServerLoad hook

function SS.Groups.Import()
	SS.Lib.Debug("Setting up and importing user groups!")
	
	for K, V in pairs(SS.Groups.List) do
		team.SetUp(V[2], V[1], V[3])
	end
	
	SS.Lib.Debug("Importing user group data!")
	
	if (file.Exists("SS/Admins.txt")) then
		local File = file.Read("SS/Admins.txt")
		
		SS.Groups.Loaded = util.KeyValuesToTable(File)
	else
		SS.Lib.Error("Setting up Admins.txt with new users!")
		
		SS.Groups.Loaded = {}
	end
	
	// Add INI users

	local Parse = SS.Parser:New("lua/ServerSecure/Config/Users")

	if Parse:Exists() then
		local Results = Parse:Parse()
		
		for K, V in pairs(Results) do
			for B, J in pairs(V) do
				SS.Groups.Insert(B, J)
			end
		end
	end
	
	file.Write("SS/Admins.txt", util.TableToKeyValues(SS.Groups.Loaded))
end

// Hook into server load

SS.Hooks.Add("SS.Groups.Import", "ServerLoad", SS.Groups.Import)

// Set players group

function SS.Groups.Change(Player, Group)
	local File = file.Read("SS/Admins.txt")
	
	local Contents = File
	
	local Steam = Player:SteamID()
	
	local Identity = string.lower(Steam)
	
	// Take group-specific flags
	
	local Current = SS.Player.Rank(Player)
	
	for K, V in pairs(SS.Groups.List) do
		if (V[1] == Current) then
			for B, J in pairs(V[8]) do
				SS.Flags.PlayerTake(Player, J)
			end
		end
	end
	
	// Set group
	
	if (Group == SS.Groups.Default()) then
		SS.Groups.Loaded[Identity] = nil
	else
		SS.Groups.Loaded[Identity] = Group
	end
	
	local Contents = util.TableToKeyValues(SS.Groups.Loaded)
	
	file.Write("SS/Admins.txt", Contents)
	
	Player:SetTeam(SS.Groups.Index(Group))
	
	Player:Spawn()
	
	SS.Purchase.Free(Player)
	
	SS.Hooks.Run("PlayerChangedGroup", Player, Group)
end