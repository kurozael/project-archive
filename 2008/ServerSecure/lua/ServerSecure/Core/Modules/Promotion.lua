SS.Promotion        = {} -- Promotion.
SS.Promotion.List   = {} -- Promotion list.

// Add new promotion

function SS.Promotion.Add(Group, Hours)
	table.insert(SS.Promotion.List, {Group, Hours})
end

// ServerMinute hook

function SS.Promotion.Minute()
	local Players = player.GetAll()
	
	for K, V in pairs(Players) do
		local Ready = V:IsReady()
		
		SS.Lib.Debug("Promotion called for "..V:Name())
		
		if (Ready) then
			CVAR.Update(V, "PlayingMinutes", CVAR.Request(V, "PlayingMinutes") + 1)
			
			if CVAR.Request(V, "PlayingMinutes") >= 60 then
				CVAR.Update(V, "PlayingMinutes", 0)
				
				CVAR.Update(V, "PlayingHours", CVAR.Request(V, "PlayingHours") + 1)
				
				SS.Promotion.Check(V)
			end
			
			CVAR.Save(V)
		end
	end
end

// Hook into server minute

SS.Hooks.Add("SS.Promotion.Minute", "ServerMinute", SS.Promotion.Minute)

// PlayerSetVariables hook

function SS.Promotion.PlayerSetVariables(Player)
	CVAR.New(Player, "PlayingHours", "Hours Played", 0)
	CVAR.New(Player, "PlayingMinutes", "Minutes Played", 0)
end

// Hook into player set variables

SS.Hooks.Add("SS.Promotion.PlayerSetVariables", "PlayerSetVariables", SS.Promotion.PlayerSetVariables)

// Check

function SS.Promotion.Check(Player)
	for K, V in pairs(SS.Promotion.List) do
		if (SS.Groups.Exists(V[1])) then
			if (CVAR.Request(Player, "PlayingHours") >= V[2]) then
				if (SS.Groups.Rank(SS.Player.Rank(Player)) > SS.Groups.Rank(V[1])) then 
					SS.PlayerMessage(0, Player:Name().." is now "..V[1]..", he has "..V[2].." or more playing hours!", 0)
					
					SS.Groups.Change(Player, V[1])
					
					local Panel = SS.Panel:New(Player, "Promotion")
					
					Panel:Words([[
						You've been promoted to ]]..V[1]..[[!
						If you would like to find information about this group then you can do ]]..SS.Commands.Prefix()..[[groups
						If you wish to see new commands that you can do just type ]]..SS.Commands.Prefix()..[[commands!
					]])
					
					Panel:Send()
					
					break
				end
			end
		end
	end
end