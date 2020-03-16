PurchaseWeapons = SS.Plugins:New("PurchaseWeapons")

// Store all tools

PurchaseWeapons.List = {}

// When script loads

function PurchaseWeapons.ServerLoad()
	PurchaseWeapons.Generate()
end

// Add a tool to the list

function PurchaseWeapons.Add(Weapon, ID, Groups, Cost, Friendly, Description)
	PurchaseWeapons.List[Weapon] = {Groups, ID, Cost, Friendly, Description}
end

// Generate purchases

function PurchaseWeapons.Generate()
	for K, V in pairs(PurchaseWeapons.List) do
		local Tool = SS.Purchase:New(V[2], V[4])
		
		Tool:Create(V[3], V[1], "Weapons", V[5])
	end
end

// When a player is given weapons

function PurchaseWeapons.PlayerGivenWeapons(Player)
	for K, V in pairs(PurchaseWeapons.List) do
		if (SS.Purchase.Has(Player, V[2])) then
			Player:Give(K)
		end
	end
end

// Include the config file

include("Config.lua")

// Create it

PurchaseWeapons:Create()