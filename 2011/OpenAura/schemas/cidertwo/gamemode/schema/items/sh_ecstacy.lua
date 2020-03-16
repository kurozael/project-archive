--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.base = "drug_base";
ITEM.name = "Ecstacy";
ITEM.model = "models/jaanus/ecstac.mdl";
ITEM.attributes = {Acrobatics = 75, Agility = 25, Strength = -15};
ITEM.description = "Some bottled white pills.\n+75 Acrobatics\n+25 Agility\n-15 Strength\n+10 Health";

-- Called when a player gets high.
function ITEM:OnGetHigh(player)
	player:SetHealth( math.Clamp( player:Health() + 10, 0, player:GetMaxHealth() ) );
end;

openAura.item:Register(ITEM);