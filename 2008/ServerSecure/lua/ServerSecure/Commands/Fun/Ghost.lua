------------------------------------------------
----[ GHOST ]----------------------------
------------------------------------------------

local Ghost = SS.Commands:New("Ghost")

// Branch flag

SS.Flags.Branch("Fun", "Ghost")

// Ghost command

function Ghost.Command(Player, Args)
	local Table = Player:GetTable()
	
	if Table.Ragdoll then
		SS.PlayerMessage(Player, "You need to stop ragdolling before you can start ghosting!", 1)
		return
	end
	
	if not Table.Ghosting then
		if Player:InVehicle() then
			Player:ExitVehicle()
		end
		
		local TR = Player:GetEyeTrace()
		
		if not (SS.Lib.Valid(TR.Entity)) then
			SS.PlayerMessage(Player, "You must aim at a valid entity!", 1)
			
			return
		end
		
		if TR.Entity:IsPlayer() then
			SS.PlayerMessage(Player, "Can not ghost players!", 1)
			
			return
		end
		
		if not (SS.Flags.PlayerHas(Player, {"server", "administrator", "fun"})) then
			if (PropSecure) then
				if not (PropSecure.IsPlayers(Player, TR.Entity)) then
					SS.PlayerMessage(Player, "This is not your prop!", 1)
					
					return
				end
			end
		end
		
		Table.Ghosting = TR.Entity
		
		Ghost.Spectate(Player, TR.Entity)
		
		Player:SetControllingEntity(TR.Entity)
		
		Player:HideGUI("Hover", true)
		Player:HideGUI("Name", true)
		
		SS.PlayerMessage(Player, "You are now ghosting!", 0)
	else
		Player:Spawn()
		
		SS.PlayerMessage(Player, "You are no longer ghosting!", 0)
	end
end

// Return from ghosting

function Ghost.Return(Player)
	local Table = Player:GetTable()
	
	if (SS.Lib.Valid(Table.Ghosting)) then
		Player:SetPos(Table.Ghosting:GetPos() + Vector(0, 0, 32))
	end
	
	Player:SetControllingEntity(nil)
	
	Player:HideGUI("Hover", false)
	Player:HideGUI("Name", false)
end

// Spectate entity

function Ghost.Spectate(Player, Entity)
	Player:Spectate(OBS_MODE_CHASE)
	Player:SpectateEntity(Entity)
	Player:StripWeapons()
end

// Respawn

function Ghost.Spawn(Player)
	local Table = Player:GetTable()
	
	if Table.Ghosting then
		Ghost.Return(Player)
	end
	
	Table.Ghosting = nil
end

hook.Add("PlayerSpawn", "Ghost.Spawn", Ghost.Spawn)

// Control entity

function Ghost.Control(Player)
	local Table = Player:GetTable()
	
	local Entity = Table.Ghosting
	
	if (SS.Lib.Valid(Entity)) then
		local Phys = Entity:GetPhysicsObject()
		
		if (SS.Lib.Valid(Phys)) then
			local Mass = Phys:GetMass() * 50
			
			if Player:KeyDown(IN_FORWARD) then
				Phys:ApplyForceCenter(Player:GetAimVector() * Mass)
			end
		end
	end
end

// Think function

Ghost.Time = 0

function Ghost.Think()
	local Cur = CurTime()
	
	if (Ghost.Time < Cur) then
		local Players = player.GetAll()
		
		for K, V in pairs(Players) do
			local Table = V:GetTable()
			
			if Table.Ghosting then
				Ghost.Control(V)
			end
		end
		
		Ghost.Time = Cur + 0.05
	end
end

hook.Add("Think", "Ghost.Think", Ghost.Think)

// Disconnect

function Ghost.Disconnected(Player)
	local Table = Player:GetTable()
	
	if (Table.Ghosting and SS.Lib.Valid(Table.Ghosting)) then
		Table.Ghosting:Remove()
	end
	
	Table.Ghosting = nil
end

hook.Add("PlayerDisconnected", "Ghost.Disconnected", Ghost.Disconnected)

// Who module

function Ghost.Who(Player)
	local Table = Player:GetTable()
	
	if (Table.Ghosting and SS.Lib.Valid(Table.Ghosting)) then
		return true, Table.Ghosting:GetModel()
	end
	
	return false
end

SS.Who.Module("Ghosting", Ghost.Who)

Ghost:Create(Ghost.Command, {"administrator", "fun", "ghost"}, "Control an entity")