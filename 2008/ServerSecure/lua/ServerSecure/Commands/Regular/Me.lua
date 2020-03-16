------------------------------------------------
----[ ME COMMAND ]--------------------
------------------------------------------------

local Me = SS.Commands:New("Me")

// Branch flag

SS.Flags.Branch("Regular", "Me")

// Me command

function Me.Command(Player, Args)
	Args = table.concat(Args, " ")
	
	local Players = player.GetAll()
	
	for K, V in pairs(Players) do
		V:PrintMessage(3, Player:Name().." "..Args)
	end
end

Me:Create(Me.Command, {"regular", "me"}, "Speak about yourself", "<Message>", 1, " ")