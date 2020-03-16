------------------------------------------------
----[ MAP ]----------------------------------
------------------------------------------------

local Map = SS.Commands:New("Map")

// Branch flag

SS.Flags.Branch("Administrator", "Map")

// Map command

function Map.Command(Player, Args)
	local Players = player.GetAll()
	
	for K, V in pairs(Players) do
		V:StripWeapons()
	end
	
	SS.PlayerMessage(0, "Changing map to "..Args[1].." in 5 seconds!", 0)
	
	timer.Simple(5, game.ConsoleCommand, "changelevel "..Args[1].."\n")
end

Map:Create(Map.Command, {"administrator", "map"}, "Change map", "<Name>", 1, " ")