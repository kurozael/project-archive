------------------------------------------------
----[ DROP ]---------------------------------
------------------------------------------------

local Command = SS.Commands:New("Drop")

function Command.Command(Player, Args)
	local Amount = Args[1]
	
	if not SS.Lib.StringNumber(Amount) then SS.PlayerMessage(Player, "That isn't a valid amount!", 1) return end
	
	Amount = math.floor(Amount)
	
	if (Amount <= 0) then SS.PlayerMessage(Player, "That amount is too small!", 1) return end
	
	if (CVAR.Request(Player, "Points") >= Amount) then
		SS.Points.Deduct(Player, Amount)
		
		local Trace = Player:TraceLine()
		
		local Entity = ents.Create("Points")
		
		Entity.Amount = Amount
		
		Entity:SetPos(Trace.HitPos + (Player:GetAimVector() * -5))
		
		Entity:Spawn()
		
		Entity:SetPlayer(Player)
		
		Player:AddCount("props", Entity)
		Player:AddCleanup("props", Entity)
		
		local function Function(Undo, Player, Entity, Amount)
			if (SS.Lib.Valid(Entity)) then
				SS.Points.Gain(Player, Amount)
			end
		end
		
		undo.Create("Points")
			undo.AddEntity(Entity)
			undo.AddFunction(Function, Player, Entity, Amount)
			undo.SetPlayer(Player)
		undo.Finish()
		
		SS.PlayerMessage(Player, "You dropped "..Amount.." "..SS.Config.Request("Points").."!", 0)
	else
		SS.PlayerMessage(Player, "You don't have enough "..SS.Config.Request("Points").."!", 1)
	end
end

Command:Create(Command.Command, {"basic"}, "Drop a specific amount of points", "<Amount>", 1, " ")