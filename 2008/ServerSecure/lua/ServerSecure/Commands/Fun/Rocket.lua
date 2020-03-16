------------------------------------------------
----[ ROCKET PLAYER ]------------------
------------------------------------------------

local Rocket = SS.Commands:New("Rocket")

// Branch flag

SS.Flags.Branch("Fun", "Rocket")

// Rocket command

function Rocket.Command(Player, Args)
	local Person, Error = SS.Lib.Find(Args[1])
	
	if Person then
		local Error = SS.Player.Immune(Player, Person)
		
		if (Error and Person != Player) then SS.PlayerMessage(Player, Error, 1) return end
		
		if not (Person:Alive()) then
			SS.PlayerMessage(Player, "This person is not alive!", 1)
			
			return
		end
		
		SS.PlayerMessage(0, Person:Name().." has been rocketed into the sky!", 0)
		
		Person:SetVelocity(Vector(0, 0, 1500))
		
		local Col = team.GetColor(Person:Team())
		
		local Smoke = SS.Lib.CreateSmokeTrail(Person, {Col.r.." "..Col.g.." "..Col.b, "255 215 0"})
		
		Person:RemoveWhenKilled(Smoke)
		
		timer.Simple(2, SS.Lib.EntityExplode, Person)
	else
		SS.PlayerMessage(Player, Error, 1)
	end
end

Rocket:Create(Rocket.Command, {"administrator", "fun", "rocket"}, "Cause somebody to fly into the sky", "<Player>", 1, " ")