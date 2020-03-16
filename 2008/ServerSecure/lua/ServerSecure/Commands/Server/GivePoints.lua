------------------------------------------------
----[ GIVEPOINTS ]----------------------
------------------------------------------------

local Command = SS.Commands:New("GivePoints")

// Branch flag

SS.Flags.Branch("Server", "GivePoints")

// Take command

function Command.Command(Player, Args)
	local Amount = Args[2]
	
	if not Amount then SS.PlayerMessage(Player, "That isn't a valid number!", 1) return end
	
	Amount = math.floor(Amount)
	
	if Amount <= 0 then SS.PlayerMessage(Player, "That number is too small!", 1) return end
	
	local Person, Error = SS.Lib.Find(Args[1])
	
	if (Person) then
		SS.Points.Gain(Person, Amount)
		
		SS.PlayerMessage(0, Player:Name().." gave "..Amount.." "..SS.Config.Request("Points").." to "..Person:Name().."!", 0)
	else
		SS.PlayerMessage(Player, Error, 1)
	end
end

Command:Create(Command.Command, {"givepoints", "server"}, "Give points to somebody", "<Player> <Amount>", 2, " ")