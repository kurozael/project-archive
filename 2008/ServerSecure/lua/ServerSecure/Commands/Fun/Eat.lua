------------------------------------------------
----[ EAT PLAYER ]------------------------
------------------------------------------------

local Eat = SS.Commands:New("Eat")

// Branch flag

SS.Flags.Branch("Fun", "Eat")

// Eat command

function Eat.Command(Player, Args)
	local Person, Error = SS.Lib.Find(Args[1])
	
	if (Person) then
		local Error = SS.Player.Immune(Player, Person)
		
		if (Error and Person != Player) then SS.PlayerMessage(Player, Error, 1) return end
		
		Person:Freeze(true)
		
		local function Func(Person)
			local NPC = ents.Create("npc_barnacle")
			
			NPC:SetPos(Person:GetPos() + Vector(0, 0, 256))
			NPC:Spawn()
			NPC:Activate()
			
			Person:RemoveWhenKilled(NPC)
		end
		
		SS.PlayerMessage(0, Person:Name().." is being eaten!", 0)
		
		timer.Simple(1, Func, Person)
	else
		SS.PlayerMessage(Player, Error, 1)
	end
end

Eat:Create(Eat.Command, {"administrator", "fun", "eat"}, "Eat somebody", "<Player>", 1, " ")