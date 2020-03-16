--------[ FLAGS ]------------

SS.Flags        = {} -- Flags table
SS.Flags.Tree   = {} -- Where flags are stored

// Has flag

function SS.Flags.PlayerHas(Player, Flag)
	if (Player:GetName() == "Console") then return true end
	
	if not Player:IsReady() then return false end
	
	local Type = type(Flag)
	
	if (Type == "string") then
		Flag = string.lower(Flag)
		
		for K, V in pairs(SS.Flags.Tree) do
			for B, J in pairs(V) do
				if (J == Flag) then
					if (SS.Flags.PlayerHas(Player, K)) then
						return true
					end
				end
			end
		end
		
		if (CVAR.Request(Player, "Flags")[Flag]) then
			return true
		end
	else
		for B, J in pairs(Flag) do
			if SS.Flags.PlayerHas(Player, J) then
				return true
			end
		end
	end
	
	return false
end

// Give flag

function SS.Flags.PlayerGive(Player, Flag)
	local Type = type(Flag)
	
	if (Type == "table") then
		for K, V in pairs(Flag) do
			SS.Flags.PlayerGive(Player, V)
		end
		
		return true
	end
	
	Flag = string.lower(Flag)
	
	if (CVAR.Request(Player, "Flags")[Flag]) then
		return false
	end
	
	CVAR.Request(Player, "Flags")[Flag] = Flag
	
	SS.Hooks.Run("PlayerGivenFlag", Player, Flag)
	
	SS.Purchase.Free(Player)
	
	return true
end

// Add flag to tree

function SS.Flags.Branch(Tree, Flag)
	Tree = string.lower(Tree)
	Flag = string.lower(Flag)
	
	SS.Flags.Tree[Tree] = SS.Flags.Tree[Tree] or {}
	
	SS.Flags.Tree[Tree][Flag] = Flag
end

// Take flag

function SS.Flags.PlayerTake(Player, Flag)
	Flag = string.lower(Flag)
	
	if (CVAR.Request(Player, "Flags")[Flag]) then
		CVAR.Request(Player, "Flags")[Flag] = nil
		
		SS.Hooks.Run("PlayerTakenFlag", Player, Flag)
		
		return true
	end
	
	return false
end

// Check if player should get free flag

function SS.Flags.Free(Player)
	CVAR.New(Player, "Flags", "Flags", {})
	
	// Give basic flags
	
	SS.Flags.PlayerGive(Player, "basic")
	
	for K, V in pairs(SS.Groups.List) do
		if (V[1] == SS.Player.Rank(Player)) then
			for B, J in pairs(V[8]) do
				SS.Flags.PlayerGive(Player, J)
			end
		end
	end
	
	SS.Hooks.Run("PlayerGiveFreeFlags", Player)
end

// Hook into player set variables

SS.Hooks.Add("SS.Flags.Free", "PlayerSetVariables", SS.Flags.Free)