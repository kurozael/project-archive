------------------------------------------------
----[ PROMOTIONS ]---------------------
------------------------------------------------

local Promotions = SS.Commands:New("Promotions")

// View command

function Promotions.Command(Player, Args)
	local Panel = SS.Panel:New(Player, "Promotions")
	
	for K, V in pairs(SS.Promotion.List) do
		Panel:Words(V[1]..": "..V[2].." hours needed")
	end
	
	Panel:Send()
end

Promotions:Create(Promotions.Command, {"basic"}, "View available promotions")