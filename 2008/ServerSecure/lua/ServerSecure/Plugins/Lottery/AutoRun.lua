SS.Lottery = SS.Plugins:New("Lottery")

// Variables

SS.Lottery.Active = false

// Config

include("Config.lua")

// Function

function SS.Lottery.Timer()
	if (SS.Lottery.Ticket > 0) then
		SS.PlayerMessage(0, "Lottery has begun! Type "..SS.Commands.Prefix().."lottery <0-9> <0-9> <0-9> ("..SS.Lottery.Ticket.." "..SS.Config.Request("Points")..")!", 0)
	else
		SS.PlayerMessage(0, "Lottery has begun! Type "..SS.Commands.Prefix().."lottery <0-9> <0-9> <0-9>!", 0)
	end
	
	SS.Lottery.Active = true
	
	timer.Simple(SS.Lottery.Time / 10, SS.Lottery.Winner)
end

timer.Create("SS.Lottery", SS.Lottery.Time, 0, SS.Lottery.Timer)

// Winner

function SS.Lottery.Winner()
	local Numbers = {}
	local Winners = {}
	
	for I = 1, 3 do
		Numbers[I] = math.random(9)
	end
	
	while (Numbers[1] == Numbers[2] or Numbers[2] == Numbers [3] or Numbers[3] == Numbers[1]) do
		Numbers[1] = math.random(9)
		Numbers[2] = math.random(9)
		Numbers[3] = math.random(9)
	end
	
	local Players = player.GetAll()
	
	for K, V in pairs(Players) do
		local Picked = TVAR.Request(V, "Lottery")
		
		if (Picked) then
			local Count = 0
			
			for I = 1, 3 do
				if (Picked[I] == Numbers[I]) then
					Count = Count + 1
				end
			end
			
			if (Count > 0 and Count < 3) then
				SS.PlayerMessage(V, "You didn't win the lottery, but you got "..Count.."/3 numbers correct!", 0)
			elseif (Count == 3) then
				SS.PlayerMessage(V, "You have won the lottery! You win "..SS.Lottery.Prize.." "..SS.Config.Request("Points").."!", 0)
				
				CVAR.Update(V, "Points", CVAR.Request(V, "Points") + SS.Lottery.Prize)
				
				Winners[V] = V
			end
			
			TVAR.Update(V, "Lottery", nil)
		end
	end
	
	local Winning = table.concat(Numbers, ", ")
	
	if (table.Count(Winners) == 0) then
		SS.PlayerMessage(0, "The lottery is over and nobody has won, the winning numbers were "..Winning.."!", 0)
	else
		local Names = {}
		
		for K, V in pairs(Winners) do
			local ID = V:Name()
			
			table.insert(Names, ID)
		end
		
		Names = table.concat(Names, ", ")
		
		SS.PlayerMessage(0, "The lottery is over, winners: "..Names, 0)
	end
	
	SS.Lottery.Active = false
end

// Chat command

local Command = SS.Commands:New("Lottery")

function Command.Command(Player, Args)
	if (TVAR.Request(Player, "Lottery")) then
		SS.PlayerMessage(Player, "You have already bought a lottery ticket!", 1)
		
		return
	end
	
	if (SS.Lottery.Ticket > 0) then
		if (CVAR.Request(Player, "Points") < SS.Lottery.Ticket) then
			SS.PlayerMessage(Player, "You do not have enough for a lottery ticket, 1 ticket is "..SS.Lottery.Ticket.." "..SS.Config.Request("Points").."!", 1)
			
			return
		else
			CVAR.Update(Player, "Points", CVAR.Request(Player, "Points") - SS.Lottery.Ticket)
		end
	end
	
	if not (SS.Lottery.Active) then SS.PlayerMessage(Player, "The lottery is not currently on!", 1) return end
	
	for I = 1, 3 do
		for P = 1, 3 do
			if (I != P) then
				if (Args[I] == Args[P]) then
					SS.PlayerMessage(Player, "Two of your lottery numbers are the same, please make them unique!", 1)
					
					return
				end
			end
		end
	end
	
	for I = 1, 3 do
		if (Args[1] > 9 or Args[1] < 0) then SS.PlayerMessage(Player, "The lottery numbers must be between 0 and 9!", 1) return end
	end
	
	TVAR.New(Player, "Lottery", {})
	
	TVAR.Update(Player, "Lottery", {Args[1], Args[2], Args[3]})
	
	SS.PlayerMessage(0, Player:Name().." entered the lottery with "..table.concat(Args, ", ").."!", 0)
end

Command:Create(Command.Command, {"basic"}, "Enter the lottery with 3 numbers between 0 and 9", "<0-9> <0-9> <0-9>", 3, " ")

SS.Lottery:Create()