// Original by OverloadUT

PurchaseStools = SS.Plugins:New("PurchaseStools")

// Store all tools

PurchaseStools.List = {}

// When script loads

function PurchaseStools.ServerLoad()
	PurchaseStools.Generate()
end

// Add a tool to the list

function PurchaseStools.Add(Tool, ID, Groups, Cost, Friendly, Description)
	if (file.Exists("../lua/weapons/gmod_tool/stools/"..Tool..".lua")) then
		PurchaseStools.List[Tool] = {Groups, ID, Cost, Friendly, Description}
	end
end

// Generate purchases

function PurchaseStools.Generate()
	for K, V in pairs(PurchaseStools.List) do
		local Tool = SS.Purchase:New(V[2], V[4])
		
		Tool:Create(V[3], V[1], "Scripted Tools", V[5])
	end
end

// Can use a tool

function PurchaseStools.Tool(Player, Trace, Tool)
	for K, V in pairs(PurchaseStools.List) do
		if (string.lower(K) == string.lower(Tool)) then
			if not (SS.Purchase.Has(Player, V[2])) then
				SS.PlayerMessage(Player, "You must purchase this STOOL with "..SS.Config.Request("Points")..", type "..SS.Commands.Prefix().."purchase!", 1)
				
				return false
			end
		end
	end
end

hook.Add("CanTool", "PurchaseStools.Tool", PurchaseStools.Tool)

// Include the config file

include("Config.lua")

// Create it

PurchaseStools:Create()