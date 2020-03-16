------------------------------------------------
----[ DROP PURCHASE ]------------------
------------------------------------------------

local Command = SS.Commands:New("DropPurchase")

// Branch flag

SS.Flags.Branch("Server", "DropPurchase")

// Give purchase command

function Command.Command(Player, Args)
	local String = table.concat(Args, " ")
	
	local Purchase = false
	
	for K, V in pairs(SS.Purchase.List) do
		if (string.lower(String) == string.lower(V[1])) then
			Purchase = {V[1], V[5]}
		end
	end
	
	if not (Purchase) then SS.PlayerMessage(Player, "Could not find purchase "..String.."!", 1) return end
	
	local Trace = Player:TraceLine()
	
	local Entity = ents.Create("Purchase")
	
	Entity.Purchase = Purchase
	
	Entity:SetPos(Trace.HitPos + (Player:GetAimVector() * -5))
	
	Entity:Spawn()
	
	Entity:SetPlayer(Player)
	
	Player:AddCount("props", Entity)
	Player:AddCleanup("props", Entity)
	
	undo.Create("Prop")
		undo.AddEntity(Entity)
		undo.SetPlayer(Player)
	undo.Finish()
	
	SS.PlayerMessage(Player, "Successfully dropped purchase "..Purchase[2].."!", 0)
end

Command:Create(Command.Command, {"droppurchase", "server"}, "Drop a specific purchase", "<Purchase>", 1, " ")