------------------------------------------------
----[ RAGDOLL]----------------------------
------------------------------------------------

local Ragdoll = SS.Commands:New("Ragdoll")

// Branch flag

SS.Flags.Branch("Fun", "Ragdoll")

// Ragdoll command

function Ragdoll.Command(Player, Args)
	local Table = Player:GetTable()
	
	if Table.Ghosting then
		SS.PlayerMessage(Player, "You need to stop ghosting before you can start ragdolling!", 1)
		return
	end
	
	if not Table.Ragdoll then
		if Player:InVehicle() then
			Player:ExitVehicle()
		end
		
		local Entity = ents.Create("prop_ragdoll")
		
		Entity:SetModel(Player:GetModel())
		Entity:SetPos(Player:GetPos())
		Entity:Spawn()
		Entity:Activate()
		
		Table.Ragdoll = Entity
		
		Ragdoll.Spectate(Player, Entity)
		
		Player:SetControllingEntity(Entity)
		
		Player:HideGUI("Hover", true)
		Player:HideGUI("Name", true)
		
		SS.PlayerMessage(Player, "You are now ragdolled!", 0)
	else
		Player:Spawn()
		
		SS.PlayerMessage(Player, "You are unragdolled!", 0)
	end
end

// Return from ragdolling

function Ragdoll.Return(Player)
	local Table = Player:GetTable()
	
	if (SS.Lib.Valid(Table.Ragdoll)) then
		Player:SetPos(Table.Ragdoll:GetPos() + Vector(0, 0, 32))
		
		Table.Ragdoll:Remove()
	end
	
	Player:SetControllingEntity(nil)
	
	Player:HideGUI("Hover", false)
	Player:HideGUI("Name", false)
end

// Spectate an entity

function Ragdoll.Spectate(Player, Entity)
	Player:Spectate(OBS_MODE_CHASE)
	Player:SpectateEntity(Entity)
	Player:StripWeapons()
end

// Respawn

function Ragdoll.Spawn(Player)
	local Table = Player:GetTable()
	
	if Table.Ragdoll then
		Ragdoll.Return(Player)
	end
	
	Table.Ragdoll = nil
end

hook.Add("PlayerSpawn", "Ragdoll.Spawn", Ragdoll.Spawn)

// Player disconnect

function Ragdoll.Disconnected(Player)
	local Table = Player:GetTable()
	
	if (Table.Ragdoll and SS.Lib.Valid(Table.Ragdoll)) then
		Table.Ragdoll:Remove()
	end
	
	Table.Ragdoll = nil
end

hook.Add("PlayerDisconnected", "Ragdoll.Disconnected", Ragdoll.Disconnected)

// Who module

function Ragdoll.Who(Player)
	local Table = Player:GetTable()
	
	if (Table.Ragdoll and SS.Lib.Valid(Table.Ragdoll)) then
		return true, Table.Ragdoll:GetModel()
	end
	
	return false
end

SS.Who.Module("Ragdolling", Ragdoll.Who)

Ragdoll:Create(Ragdoll.Command, {"administrator", "fun", "ragdoll"}, "Turn into a ragdoll")