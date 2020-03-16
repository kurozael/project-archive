local Plugin = SS.Plugins:New("Hide")

// When players values get set

function Plugin.PlayerSetVariables(Player)
	CVAR.New(Player, "Hidden", "Hidden", false)
end

// Chat command

local Hide = SS.Commands:New("Hide")

function Hide.Command(Player, Args)
	local Bool = SS.Lib.StringBoolean(Args[1])
	
	CVAR.Update(Player, "Hidden", Bool)

	if (Bool) then
		SS.PlayerMessage(Player, "You are now hidden!", 0)
		
		Player:ConCommand("name MingeBag\n")
		Player:Spawn()
	else
		SS.PlayerMessage(Player, "You no longer hidden!", 0)
	end
end

Hide:Create(Hide.Command, {"server", "hide"}, "Hide/Unhide", "<1|0>", 1, " ")

// Player spawn

function Plugin.PlayerSpawn(Player)
	timer.Create("Hide: PlayerSpawn", 0.5, 1,
	
	function(Player)
		if (CVAR.Request(Player, "Hidden")) then
			Player:HideGUI("Hover", true)
		else
			Player:HideGUI("Hover", false)
		end
	end,
	
	Player)
end

// Player choose model

function Plugin.PlayerChooseModel(Player)
	timer.Create("Hide: PlayerChooseModel", 0.5, 1,
	
	function(Player)
		if (CVAR.Request(Player, "Hidden")) then
			for K, V in pairs(SS.Groups.List) do
				if (V[7]) then
					if (V[4] != "") then
						Player:SetModel(V[4])
					end
				end
			end
		end
	end,
	
	Player)
end

// Player choose team

function Plugin.PlayerChooseTeam(Player)
	timer.Create("Hide: PlayerChooseTeam", 0.5, 1,
	
	function(Player)
		if (CVAR.Request(Player, "Hidden")) then
			local Default = SS.Groups.Default()
			
			Player:SetTeam(SS.Groups.Index(Default))
		end
	end,
	
	Player)
end

// Meta

local Meta = FindMetaTable("Player")

local Backup = Meta.Name

function Meta:Name(String)
	if (CVAR.Request(self, "Hidden")) then
		return SS.Lib.StringRandom(10)
	else
		return Backup(self, String)
	end
end

// Finish plugin

Plugin:Create()