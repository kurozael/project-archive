// Purchase flags

PurchaseFlags = SS.Plugins:New("PurchaseFlags")

// Store all flags

PurchaseFlags.List = {}

// Add a flag to the list

function PurchaseFlags.Add(Flag, ID, Cost, Description, Function)
	local Friendly = Flag
	
	Flag = string.lower(Flag)
	
	PurchaseFlags.List[Flag] = {Cost, ID, Friendly, Description, Flag, Avatar}
end

// When script loads

function PurchaseFlags.ServerLoad()
	for K, V in pairs(PurchaseFlags.List) do
		local Flag = SS.Purchase:New(V[2], V[3])
		
		function Flag.Condition(Player, Item)
			for K, V in pairs(PurchaseFlags.List) do
				if (string.lower(Item) == string.lower(V[2])) then
					if (SS.Flags.PlayerHas(Player, V[5])) then
						return false
					end
				end
			end
			
			return true
		end
		
		function Flag.Remove(Player, Item)
			for K, V in pairs(PurchaseFlags.List) do
				if (string.lower(Item) == string.lower(V[2])) then
					if (SS.Flags.PlayerHas(Player, V[5])) then
						SS.Flags.PlayerTake(Player, V[5])
					end
				end
			end
		end
		
		Flag:Create(V[1], {}, "Flags", V[4])
	end
end

// Player purchase

function PurchaseFlags.PlayerGivenPurchase(Player, Item)
	for K, V in pairs(PurchaseFlags.List) do
		if (string.lower(Item) == string.lower(V[2])) then
			if not (SS.Flags.PlayerHas(Player, V[5])) then
				SS.Flags.PlayerGive(Player, V[5])
				
				if (V[6]) then
					V[6](Player)
				end
			end
		end
	end
end

// Include the config file

include("Config.lua")

// Create it

PurchaseFlags:Create()