--[[
Name: "sh_vegetable_oil.lua".
Product: "HL2 RP".
--]]

local ITEM = {};

-- Set some information.
ITEM.name = "Vegetable Oil";
ITEM.cost = 5;
ITEM.model = "models/props_junk/garbage_plasticbottle002a.mdl";
ITEM.weight = 0.6;
ITEM.access = "iv";
ITEM.useText = "Drink";
ITEM.business = true;
ITEM.description = "A bottle of vegetable oil, it isn't very tasty.";

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	player:TakeDamage(5, player, player);
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

-- Register the item.
kuroScript.item.Register(ITEM);