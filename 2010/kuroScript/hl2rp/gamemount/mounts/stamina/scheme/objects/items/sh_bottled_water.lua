--[[
Name: "sh_bottled_water.lua".
Product: "HL2 RP".
--]]

local ITEM = {};

-- Set some information.
ITEM.name = "Bottled Water";
ITEM.cost = 10;
ITEM.model = "models/props_junk/glassbottle01a.mdl";
ITEM.plural = "Bottled Waters";
ITEM.weight = 0.5;
ITEM.access = "v";
ITEM.useText = "Drink";
ITEM.classes = {CLASS_CPA};
ITEM.category = "Consumables"
ITEM.business = true;
ITEM.description = "A clear bottle, the liquid inside looks dirty.";

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	player:SetCharacterData("stamina", 100);
	player:SetHealth( math.Clamp(player:Health() + 10, 0, 100) );
	
	-- Boost the player's attribute.
	kuroScript.attributes.Boost(player, self.name, ATB_AGILITY, 4, 120);
	kuroScript.attributes.Boost(player, self.name, ATB_STAMINA, 4, 120);
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

-- Register the item.
kuroScript.item.Register(ITEM);