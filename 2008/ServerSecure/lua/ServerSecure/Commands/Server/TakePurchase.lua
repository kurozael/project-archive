------------------------------------------------
----[ TAKE PURCHASE ]-----------------
------------------------------------------------

local Command = SS.Commands:New("TakePurchase")

// Branch flag

SS.Flags.Branch("Server", "TakePurchase")

// Take purchase command

function Command.Command(Player, Args)
	local Person, Error = SS.Lib.Find(Args[1])
	
	if Person then
		local Error = SS.Player.Immune(Player, Person)
		
		if (Error and Person != Player) then SS.PlayerMessage(Player, Error, 1) return end
		
		local Purchase = table.concat(Args, " ", 2)
		
		if (SS.Purchase.Has(Person, Purchase)) then
			SS.Purchase.Remove(Person, Purchase)
			
			SS.PlayerMessage(0, Player:Name().." removed purchase '"..Purchase.."' from "..Person:Name().."!", 0)
		else
			SS.PlayerMessage(Player, Person:Name().." hasn't purchased '"..Purchase.."'!", 1)
		end
	else
		SS.PlayerMessage(Player, Error, 1)
	end
end

Command:Create(Command.Command, {"takepurchase", "server"}, "Take a purchase from somebody", "<Player> <Purchase>", 2, " ")