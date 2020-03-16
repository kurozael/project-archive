------------------------------------------------
----[ POINTS NAME ]--------------------
------------------------------------------------

local PointsName = SS.Commands:New("PointsName")

// Branch flag

SS.Flags.Branch("Server", "PointsName")

// Points name command

function PointsName.Command(Player, Args)
	local Backup = SS.Config.Request("Points")
	
	local New = table.concat(Args, " ")
	
	SS.Config.New("Points", New)
	
	local Players = player.GetAll()
	
	for K, V in pairs(Players) do
		SS.Player.PlayerUpdateGUI(V)
	end
	
	SS.PlayerMessage(0, Player:Name().." changed "..Backup.." to "..SS.Config.Request("Points").."!", 1)
end

PointsName:Create(PointsName.Command, {"server", "pointsname"}, "Change the name of the points", "<Name>", 1, " ")