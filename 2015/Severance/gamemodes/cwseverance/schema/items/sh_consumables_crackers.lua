--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

ITEM = Clockwork.item:New();
ITEM.name = "Box of Crackers";
ITEM.model = "models/props_junk/garbage_bag001a.mdl";
ITEM.weight = 0.6;
ITEM.useText = "Eat";
ITEM.category = "Consumables"
ITEM.description = "A box of salty crackers.";
ITEM.useSound = "npc/barnacle/barnacle_crunch3.wav";
ITEM.HungerAmount = 15
ITEM.ThirstAmount = -5

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	player:SetHealth(math.Clamp(player:Health() + 5, 0, player:GetMaxHealth()));
	player:BoostAttribute(self("name"), ATB_ENDURANCE, 1, 600);
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

Clockwork.item:Register(ITEM);