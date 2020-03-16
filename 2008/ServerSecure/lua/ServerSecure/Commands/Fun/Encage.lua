------------------------------------------------
----[ ENCAGE PLAYER ]------------------
------------------------------------------------

local Encage = SS.Commands:New("Encage")

// Branch flag

SS.Flags.Branch("Fun", "Encage")

// Encage command

function Encage.Command(Player, Args)
	local Person, Error = SS.Lib.Find(Args[1])
	
	if Person then
		local Error = SS.Player.Immune(Player, Person)
		
		if (Error and Person != Player) then SS.PlayerMessage(Player, Error, 1) return end
		
		local Cage = ents.Create("prop_physics")
		
		util.PrecacheModel("models/props_junk/TrashDumpster02.mdl")
		
		Cage:SetModel("models/props_junk/TrashDumpster02.mdl")
		Cage:SetPos(Person:GetPos() + Vector(0, 0, 64))
		Cage:SetAngles(Angle(180, 0, 0))
		Cage:Spawn()
		
		Player:AddCount("props", Cage)
		Player:AddCleanup("props", Cage)
		
		Cage:GetPhysicsObject():EnableMotion(false)
		
		undo.Create("Prop")
			undo.SetPlayer(Player)
			undo.AddEntity(Cage)
		undo.Finish()
		
		SS.PlayerMessage(0, Person:Name().." has been encaged!", 0)
	else
		SS.PlayerMessage(Player, Error, 1)
	end
end

Encage:Create(Encage.Command, {"administrator", "fun", "encage"}, "Encage somebody", "<Player>", 1, " ")