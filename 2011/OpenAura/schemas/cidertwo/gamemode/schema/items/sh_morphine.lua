--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.base = "drug_base";
ITEM.name = "Morphine";
ITEM.model = "models/jaanus/morphi.mdl";
ITEM.attributes = {Endurance = 75, Strength = 30, Acrobatics = -20};
ITEM.description = "Some bottled blue pills.\n+75 Endurance\n+30 Strength\n-20 Acrobatics\n+10 Health";
ITEM.addictionRate = 4;

-- Called when a player gets high.
function ITEM:OnGetHigh(player)
	player:SetHealth( math.Clamp( player:Health() + 10, 0, player:GetMaxHealth() ) );
end;

openAura.item:Register(ITEM);