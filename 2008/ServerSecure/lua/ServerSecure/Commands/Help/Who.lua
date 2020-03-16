------------------------------------------------
----[ WHO ]---------------------------------
-------------------------------------------------

local Who = SS.Commands:New("Who")

// Who command

function Who.Command(Player, Args)
	local Panel = SS.Panel:New(Player, "Who is doing what activity")
	
	for K, V in pairs(SS.Who.List) do
		Panel:Button(K, 'ss whocommand "'..K..'"')
	end
	
	Panel:Send()
end

// View

function Who.Console(Player, Args)
	local Index = Args[1]
	
	if (SS.Who.List[Index]) then
		local Panel = SS.Panel:New(Player, Index)
		
		local Players = player.GetAll()
		
		for K, V in pairs(Players) do
			local Bool, Message = SS.Who.List[Index](V)
			
			if (Bool) then
				local Info = V:Name()
				
				if (Message) then
					Info = Info.." - "..Message
				end
				
				Panel:Words(Info)
			end
		end
		
		Panel:Send()
	else
		SS.PlayerMessage(Player, "There is no such Who module: '"..Index.."'!", 1)
	end
end

SS.ConsoleCommand.Simple("whocommand", Who.Console, 1)

// Create it

Who:Create(Who.Command, {"basic"}, "See who is doing what")