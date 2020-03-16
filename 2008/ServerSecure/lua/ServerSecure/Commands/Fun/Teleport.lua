------------------------------------------------
----[ TELEPORT ]--------------------------
------------------------------------------------

local Teleport = SS.Commands:New("Teleport")

// Branch flag

SS.Flags.Branch("Fun", "Teleport")

// Teleport command

function Teleport.Command(Player, Args)
	local Person, Error = SS.Lib.Find(Args[1])
	
	local Trace = Player:GetEyeTrace()
	
	if (Person) then
		local Error = SS.Player.Immune(Player, Person)
		
		if (Error and Person != Player) then SS.PlayerMessage(Player, Error, 1) return end
		
		Person:SetPos(Trace.HitPos)
		
		local Effect = EffectData()
		
		Effect:SetEntity(V)
		Effect:SetOrigin(Trace.HitPos)
		Effect:SetStart(Trace.HitPos)
		Effect:SetScale(9999)
		Effect:SetMagnitude(250)
		
		util.Effect("ThumperDust", Effect)
		
		SS.PlayerMessage(0, Person:Name().." has been teleported!", 0)
	else
		SS.PlayerMessage(Player, Error, 1)
	end
end

Teleport:Create(Teleport.Command, {"administrator", "fun", "teleport"}, "Teleport somebody", "<Player>", 1, " ")