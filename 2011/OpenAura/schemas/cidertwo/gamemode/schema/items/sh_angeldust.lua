--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.base = "drug_base";
ITEM.name = "Angel Dust";
ITEM.model = "models/katharsmodels/syringe_out/syringe_out.mdl";
ITEM.attributes = {Strength = 75, Acrobatics = 75, Agility = -15};
ITEM.description = "A needle with a green liquid.\n+75 Strength\n+75 Acrobatics\n-15 Agilty\n+10 Health";
ITEM.addictionRate = 2;

-- Called when a player gets high.
function ITEM:OnGetHigh(player)
	player:SetHealth( math.Clamp( player:Health() + 10, 0, player:GetMaxHealth() ) );
end;

openAura.item:Register(ITEM);