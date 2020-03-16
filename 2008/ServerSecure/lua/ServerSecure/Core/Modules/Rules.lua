------------------------------------------------
----[ RULES ]-------------------------------
------------------------------------------------

SS.Rules      = {} -- Rules table.
SS.Rules.List = {} -- Rules list.

// Current

SS.Rules.Current = 0 -- What rules start at

// Add a rule

function SS.Rules.Add(Text)
	SS.Rules.Current = SS.Rules.Current + 1
	
	table.insert(SS.Rules.List, SS.Rules.Current..": "..Text)
end

// Show rules

function SS.Rules.Show(Player)
	local Panel = SS.Panel:New(Player, "Rules")
	
	for K, V in pairs(SS.Rules.List) do
		Panel:Words(V)
	end
	
	Panel:Send()
end

// Initial spawn

function SS.Rules.PlayerInitialSpawn(Player)
	SS.Rules.Show(Player)
end

SS.Hooks.Add("SS.Rules.PlayerInitialSpawn", "PlayerInitialSpawn", SS.Rules.PlayerInitialSpawn)