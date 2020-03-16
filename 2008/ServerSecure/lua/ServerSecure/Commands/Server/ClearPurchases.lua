------------------------------------------------
----[ CLEAR PURCHASES ]--------------
------------------------------------------------

local Command = SS.Commands:New("ClearPurchases")

// Branch flag

SS.Flags.Branch("Server", "ClearPurchases")

// Give purchase command

function Command.Command(Player, Args)
	local Person, Error = SS.Lib.Find(Args[1])
	
	if (Person) then
		CVAR.Update(Person, "Purchases", {})
		
		SS.PlayerMessage(0, Player:Name().." has emptied "..Person:Name().."'s purchases list!", 0)
	else
		SS.PlayerMessage(Player, Error, 1)
	end
end

Command:Create(Command.Command, {"clearpurchases", "server"}, "Clear all of somebodies purchases", "<Player>", 1, " ")