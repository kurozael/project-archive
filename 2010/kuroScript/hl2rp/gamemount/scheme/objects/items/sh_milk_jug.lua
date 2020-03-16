--[[
Name: "sh_milk_jug.lua".
Product: "HL2 RP".
--]]

local ITEM = {};

-- Set some information.
ITEM.name = "Milk Jugs";
ITEM.cost = 10;
ITEM.model = "models/props_junk/garbage_milkcarton001a.mdl";
ITEM.weight = 1;
ITEM.access = "v";
ITEM.useText = "Drink";
ITEM.classes = {CLASS_CPA};
ITEM.category = "Consumables"
ITEM.business = true;
ITEM.description = "A jug filled with delicious milk.";

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	player:SetHealth( math.Clamp(player:Health() + 10, 0, 100) );
	
	-- Boost the player's attribute.
	kuroScript.attributes.Boost(player, self.name, ATB_ENDURANCE, 2, 120);
	kuroScript.attributes.Boost(player, self.name, ATB_STRENGTH, 2, 120);
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

-- Register the item.
kuroScript.item.Register(ITEM);