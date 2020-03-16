// Restrict stools

RestrictStools = SS.Plugins:New("RestrictStools")

// Store all tools

RestrictStools.List = {}

// Add a tool

function RestrictStools.Add(Tool, Flags)
	RestrictStools.List[Tool] = Flags
end

// Can use a tool

function RestrictStools.Tool(Player, Trace, Tool)
	for K, V in pairs(RestrictStools.List) do
		if (string.lower(K) == string.lower(Tool)) then
			if not (SS.Flags.PlayerHas(Player, V)) then
				local Flags = table.concat(V, ", ")
				
				SS.PlayerMessage(Player, "You do not have access to this STOOL, you need "..Flags.." flags!", 1)
				
				return false
			end
		end
	end
end

hook.Add("CanTool", "RestrictStools.Tool", RestrictStools.Tool)

// Include the config file

include("Config.lua")

// Create it

RestrictStools:Create()