------------------------------------------------
----[ BAN ]-----------------------------------
------------------------------------------------

SS.Ban      = {} -- Ban table.
SS.Ban.List = {} -- Ban list.

// Add a ban

function SS.Ban.Add(ID, Reason)
	SS.Ban.List[ID] = Reason
	
	Msg("\t[Ban] "..ID.." - "..Reason.."\n")
end

// PlayerInitialSpawn hook

function SS.Ban.PlayerInitialSpawn(Player)
	local ID = Player:SteamID()
	
	if (SS.Ban.List[ID]) then
		SS.Lib.ConCommand("kickid", ID, SS.Ban.List[ID])
	end
end

// Hook into player initial spawn

SS.Hooks.Add("SS.Ban.PlayerInitialSpawn", "PlayerInitialSpawn", SS.Ban.PlayerInitialSpawn)