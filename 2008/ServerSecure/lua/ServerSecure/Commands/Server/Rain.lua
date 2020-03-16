------------------------------------------------
----[ RAIN ]---------------------------------
------------------------------------------------

local Rain = SS.Commands:New("Rain")

// Branch flag

SS.Flags.Branch("Server", "Rain")

// Rain command

function Rain.Command(Player, Args)
	local Pos = Vector(0, 0, 3096)
	
	local Spread = Args[3]
	
	undo.Create("Points")
	
	for I = 1, Args[1] do
		local Entity = ents.Create("Points")
		
		Entity:SetPos(Pos + Vector(math.random(-Spread, Spread) * I, math.random(-Spread, Spread) * I, math.random(-Spread, Spread)))
		
		Entity.Amount = Args[2]
		
		Entity:Spawn()
		
		Entity:SetPlayer(Player)
		
		if not (Entity:IsInWorld()) then
			Entity:Remove()
		else
			Player:AddCount("props", Entity)
			Player:AddCleanup("props", Entity)
			
			undo.AddEntity(Entity)
		end
	end
	
	undo.SetPlayer(Player)
	
	undo.Finish()
	
	SS.PlayerMessage(0, "It's raining "..SS.Config.Request("Points").." and each one is worth "..Args[2].."!", 0)
end

Rain:Create(Rain.Command, {"rain", "server"}, "Points rain from the sky", "<Count> <Amount> <Spread>", 3, " ")