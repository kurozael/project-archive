--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.base = "drug_base";
ITEM.name = "Heroin";
ITEM.model = "models/katharsmodels/syringe_out/heroine_out.mdl";
ITEM.attributes = {Dexterity = 75, Endurance = 50, Strength = -30};
ITEM.description = "A needle to chase the dragon with.\n+75 Acrobatics\n+50 Endurance\n-30 Strength\n+10 Health";
ITEM.addictionRate = 3;

-- Called when a player gets high.
function ITEM:OnGetHigh(player)
	player:SetHealth( math.Clamp( player:Health() + 10, 0, player:GetMaxHealth() ) );
end;

openAura.item:Register(ITEM);