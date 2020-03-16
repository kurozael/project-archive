--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.base = "drug_base";
ITEM.name = "Weed";
ITEM.model = "models/katharsmodels/contraband/zak_wiet/zak_wiet.mdl";
ITEM.attributes = {Medical = 25, Endurance = 25, Dexterity = -10};
ITEM.description = "A bag of the green stuff.\n+25 Medical\n+25 Endurance\n-10 Dexterity\n+10 Health";

-- Called when a player gets high.
function ITEM:OnGetHigh(player)
	player:SetHealth( math.Clamp( player:Health() + 10, 0, player:GetMaxHealth() ) );
end;

openAura.item:Register(ITEM);