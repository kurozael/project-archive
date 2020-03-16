------------------------------------------------
----[ CLEARDECALS ]--------------------
------------------------------------------------

local ClearDecals = SS.Commands:New("ClearDecals")

// Branch flag

SS.Flags.Branch("Moderator", "Alert")

// ClearDecals command

function ClearDecals.Command(Player, Args)
	local Command = table.concat(Args, " ")
	
	local Players = player.GetAll()
	
	for K, V in pairs(Players) do
		V:ConCommand("r_cleardecals\n")
	end
	
	SS.PlayerMessage(0, Player:Name().." cleared all decals on the map!", 0)
end

ClearDecals:Create(ClearDecals.Command, {"moderator", "cleardecals"}, "Clear everybodies decals")