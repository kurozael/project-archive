------------------------------------------------
----[ GIVE PURCHASE ]------------------
------------------------------------------------

local Command = SS.Commands:New("GivePurchase")

// Branch flag

SS.Flags.Branch("Server", "GivePurchase")

// Give purchase command

function Command.Command(Player, Args)
	local Person, Error = SS.Lib.Find(Args[1])
	
	if Person then
		local Purchase = table.concat(Args, " ", 2)
		
		if not (SS.Purchase.Has(Person, Purchase)) then
			SS.Purchase.Give(Person, Purchase)
			
			SS.PlayerMessage(0, Player:Name().." gave purchase '"..Purchase.."' to "..Person:Name().."!", 0)
		else
			SS.PlayerMessage(Player, Person:Name().." has already purchased '"..Purchase.."'!", 1)
		end
	else
		SS.PlayerMessage(Player, Error, 1)
	end
end

Command:Create(Command.Command, {"givepurchase", "server"}, "Give a purchase to somebody", "<Player> <Purchase>", 2, " ")