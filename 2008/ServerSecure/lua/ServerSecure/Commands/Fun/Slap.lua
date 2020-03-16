------------------------------------------------
----[ SLAP ]----------------------------------
------------------------------------------------

local Slap = SS.Commands:New("Slap")

// Branch flag

SS.Flags.Branch("Fun", "Slap")

// Slap command

function Slap.Command(Player, Args)
	if (Args[3] < 0) then
		SS.PlayerMessage(Player, "You can not slap with negative damage!", 1)
		
		return
	end
	
	local Person, Error = SS.Lib.Find(Args[1])
	
	if Person then
		local Error = SS.Player.Immune(Player, Person)
		
		if (Error and Person != Player) then SS.PlayerMessage(Player, Error, 1) return end
		
		local function Slap(Player, Damage)
			local Dead = not Player:Alive()
			
			if (Dead) then return end
			
			Person:SetVelocity(Vector(math.random(-1000, 1000), math.random(-500, 500), 1000))
			
			Person:TakeDamage(Damage, Player)
		end
		
		timer.Create("Slap: "..Player:UniqueID(), 1, Args[2], Slap, Player, Args[3])
		
		SS.PlayerMessage(0, Person:Name().." has been slapped "..Args[2].." times with "..Args[3].." damage!", 0)
	else
		SS.PlayerMessage(Player, Error, 1)
	end
end

Slap:Create(Slap.Command, {"slap", "administrator", "fun"}, "Slap somebody", "<Player> <Amount> <Damage>", 3, " ")