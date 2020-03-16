local Plugin = SS.Plugins:New("Stats")

// When players variables are set

function Plugin.PlayerSetVariables(Player)
	local Players = player.GetAll()
	
	if not CVAR.Request(Player, "Visits") then
		for K, V in pairs(Players) do
			V:PrintMessage(3, Player:Name().." '"..Player:SteamID().."' has not been here before, creating a profile!")
		end
	else
		local Visits = CVAR.Request(Player, "Visits")
		
		for K, V in pairs(Players) do
			V:PrintMessage(3, Player:Name().." '"..Player:SteamID().."' recognised, he has been here "..Visits.." times before!")
		end
	end
	
	CVAR.New(Player, "Visits", "Server Visits", 0)
	CVAR.New(Player, "Bans", "Bans", 0)
	CVAR.New(Player, "Time Banned", "Total Time Banned", 0)
	CVAR.New(Player, "Previous IDS", "Previous Names", {})
	
	Plugin.Name(Player)
end

// Track players name

function Plugin.Name(Player)
	local ID = Player:Name()
	
	CVAR.Request(Player, "Previous IDS")[ID] = ID
end

// When name changes

function Plugin.PlayerNameChanged(Player, Backup, New)
	CVAR.Request(Player, "Previous IDS")[New] = New
end

// Stats command

local Stats = SS.Commands:New("Stats")

function Stats.Command(Player, Args)
	local Panel = SS.Panel:New(Player, "Server Statistics")
	
	Panel:Words("Total Visits: "..SVAR.Request("Visits"))
	Panel:Words("Total Sentances Spoken: "..SVAR.Request("TextSpoken"))
	Panel:Words("Total "..SS.Config.Request("Points").." Given: "..SVAR.Request("PointsGiven"))
	Panel:Words("Total Commands Entered: "..SVAR.Request("Commands"))
	Panel:Words("Total Server Shutdowns: "..SVAR.Request("Shutdowns"))
	Panel:Words("Total Player Spawns: "..SVAR.Request("Spawns"))
	Panel:Words("Total Players Killed: "..SVAR.Request("Killed"))
	Panel:Words("Total Props Spawned: "..SVAR.Request("Props"))
	Panel:Words("Total Bans Given: "..SVAR.Request("Bans"))
	
	Panel:Send()
end

Stats:Create(Stats.Command, {"basic"}, "View server statistics")

// When player is killed

function Plugin.PlayerDeath()
	SVAR.Update("Killed", SVAR.Request("Killed") + 1)
end

// When player spawns

function Plugin.PlayerSpawn()
	SVAR.Update("Spawns", SVAR.Request("Spawns") + 1)
end

// When player typed a command

function Plugin.PlayerTypedCommand()
	SVAR.Update("Commands", SVAR.Request("Commands") + 1)
end

// When player is given points

function Plugin.PlayerGivenPoints(Player, Amount)
	SVAR.Update("PointsGiven", SVAR.Request("PointsGiven") + Amount)
end

// When player says something

function Plugin.PlayerTypedText(Player, Text)
	SVAR.Update("TextSpoken", SVAR.Request("TextSpoken") + 1)
end

// When player initially spawns

function Plugin.PlayerInitialSpawn(Player)
	SVAR.Update("Visits", SVAR.Request("Visits") + 1)
	
	CVAR.Update(Player, "Visits", CVAR.Request(Player, "Visits") + 1)
end

// When server shuts down

function Plugin.ServerShutdown()
	SVAR.Update("Shutdowns", SVAR.Request("Shutdowns") + 1)
end

// When player spawns a prop

function Plugin.PlayerPropSpawned()
	SVAR.Update("Props", SVAR.Request("Props") + 1)
end

// When a player is banned

function Plugin.PlayerBanned(Player, Time, Reason)
	SVAR.Update("Bans", SVAR.Request("Bans") + 1)
	
	CVAR.Update(Player, "Bans", CVAR.Request(Player, "Bans") + 1)
	CVAR.Update(Player, "Time Banned", CVAR.Request(Player, "Time Banned") + Time)
end

// When servers loads

function Plugin.ServerLoad()
	SVAR.New("Bans", 0)
	SVAR.New("Props", 0)
	SVAR.New("Shutdowns", 0)
	SVAR.New("Visits", 0)
	SVAR.New("TextSpoken", 0)
	SVAR.New("PointsGiven", 0)
	SVAR.New("Commands", 0)
	SVAR.New("Spawns", 0)
	SVAR.New("Killed", 0)
end

Plugin:Create()