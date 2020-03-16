------------------------------------------------
----[ GIVE ]---------------------------------
------------------------------------------------

local Command = SS.Commands:New("Give")

// Give command

function Command.Command(Player, Args)
	local Amount = Args[2]
	
	if not (Amount) then SS.PlayerMessage(Player, "That isn't a valid number!", 1) return end
	
	Amount = math.floor(Amount)
	
	if Amount <= 0 then SS.PlayerMessage(Player, "That number is too small!", 1) return end
	
	local Person, Error = SS.Lib.Find(Args[1])
	
	if (Person) then
		if (CVAR.Request(Player, "Points") >= Amount) then
			SS.Points.Gain(Person, Amount)
			SS.Points.Deduct(Player, Amount)
			
			SS.PlayerMessage(Person, Player:Name().." gave you "..Amount.." "..SS.Config.Request("Points").."!", 0)
			SS.PlayerMessage(Player, "You gave "..Person:Name().." "..Amount.." "..SS.Config.Request("Points").."!", 0)
		else
			SS.PlayerMessage(Player, "You do not have enough "..SS.Config.Request("Points").."!", 1)
		end
	else
		SS.PlayerMessage(Player, Error, 1)
	end
end

Command:Create(Command.Command, {"basic"}, "Give somebody points", "<Player> <Amount>", 2, " ")