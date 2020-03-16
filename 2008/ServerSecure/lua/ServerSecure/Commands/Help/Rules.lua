------------------------------------------------
----[ RULES ]-------------------------------
------------------------------------------------

local Rules = SS.Commands:New("Rules")

// Rules

function Rules.Command(Player, Args)
	SS.Rules.Show(Player)
end

// Create it

Rules:Create(Rules.Command, {"basic"}, "View the server rules")

// Advert

SS.Adverts.Add("Type "..SS.Commands.Prefix().."rules to see the rules of the server!")