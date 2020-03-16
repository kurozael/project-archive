--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = Clockwork.item:New("drug_base");
ITEM.name = "Cocaine";
ITEM.model = "models/cocn.mdl";
ITEM.attributes = {Agility = 75, Strength = 50, Endurance = -15};
ITEM.description = "A wrapped up white powder.\n+75 Agility\n+50 Strength\n-15 Endurance\n+10 Health";
ITEM.addictionRate = 4;

-- Called when a player gets high.
function ITEM:OnGetHigh(player)
	player:SetHealth(math.Clamp(player:Health() + 10, 0, player:GetMaxHealth()));
end;

Clockwork.item:Register(ITEM);