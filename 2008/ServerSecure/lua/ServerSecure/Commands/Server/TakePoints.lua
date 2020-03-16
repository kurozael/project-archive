------------------------------------------------
----[ TAKEPOINTS ]----------------------
------------------------------------------------

local Command = SS.Commands:New("TakePoints")

// Branch flag

SS.Flags.Branch("Server", "TakePoints")

// Take command

function Command.Command(Player, Args)
	local Amount = Args[2]
	
	if not Amount then SS.PlayerMessage(Player, "That isn't a valid number!", 1) return end
	
	Amount = math.floor(Amount)
	
	if Amount <= 0 then SS.PlayerMessage(Player, "That number is too small!", 1) return end
	
	local Person, Error = SS.Lib.Find(Args[1])
	
	if Person then
		SS.Points.Deduct(Person, Args[2])
		
		SS.PlayerMessage(0, Player:Name().." took "..Args[2].." "..SS.Config.Request("Points").." from "..Person:Name().."!", 0)
	else
		SS.PlayerMessage(Player, Error, 1)
	end
end

Command:Create(Command.Command, {"takepoints", "server"}, "Take points from somebody", "<Player> <Amount>", 2, " ")