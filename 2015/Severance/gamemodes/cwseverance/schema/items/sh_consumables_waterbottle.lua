--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

ITEM = Clockwork.item:New();
ITEM.name = "Water Bottle";
ITEM.model = "models/props_junk/GlassBottle01a.mdl";
ITEM.weight = 0.5;
ITEM.useText = "Drink";
ITEM.category = "Consumables"
ITEM.description = "A bottle filled with water.";
ITEM.useSound = "npc/barnacle/barnacle_gulp1.wav";
ITEM.ThirstAmount = 40

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	player:SetHealth(math.Clamp(player:Health() + 5, 0, player:GetMaxHealth()));
	player:BoostAttribute(self("name"), ATB_ENDURANCE, 1, 600);
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

Clockwork.item:Register(ITEM);