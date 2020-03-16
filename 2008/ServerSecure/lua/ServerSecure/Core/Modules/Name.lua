--------[ PLAYER NAME CHANGED ]------------

SS.Names = {}

// When player spawns

function SS.Names.PlayerInitialSpawn(Player)
	local ID = Player:Name()
	
	TVAR.New(Player, "name", ID)
end

SS.Hooks.Add("SS.Names.PlayerInitialSpawn", "PlayerInitialSpawn", SS.Names.PlayerInitialSpawn)

// ServerSecond hook

function SS.Names.ServerSecond(Player)
	local Players = player.GetAll()
	
	for K, V in pairs(Players) do
		local Ready = V:IsReady()
		
		if (Ready) then
			if not (TVAR.Request(V, "name") == V:Name()) then
				local New = V:Name()
				
				local Backup = TVAR.Request(V, "name")
				
				TVAR.Update(V, "name", New)
				
				SS.Hooks.Run("PlayerNameChanged", V, Backup, New)
			end
		end
	end
end

// Hook into server second

SS.Hooks.Add("SS.Names.ServerSecond", "ServerSecond", SS.Names.ServerSecond)