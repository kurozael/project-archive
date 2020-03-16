------------------------------------------------
----[ MESSAGE ]---------------------------
------------------------------------------------

local Message = SS.Commands:New("Message")

// Message command

function Message.Command(Player, Args)
	local Flag = Args[1]
	
	local Players = player.GetAll()
	
	for K, V in pairs(Players) do
		if (SS.Flags.PlayerHas(V, Args[1]) or V == Player) then
			local Message = table.concat(Args, ", ", 2)
			
			SS.PlayerMessage(V, "(Flag: "..Args[1]..") "..Player:Name()..": "..Message, 0)
		end
	end
end

Message:Create(Message.Command, {"basic"}, "Send message to people with certain flags", "<Flag>, <Text>", 2, ", ")