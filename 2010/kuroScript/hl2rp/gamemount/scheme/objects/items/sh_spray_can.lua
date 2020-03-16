--[[
Name: "sh_spray_can.lua".
Product: "Terminator RP".
--]]

local ITEM = {};

-- Set some information.
ITEM.name = "Spray Can";
ITEM.cost = 25;
ITEM.model = "models/sprayca2.mdl";
ITEM.weight = 1;
ITEM.access = "v";
ITEM.category = "Perpetuities"
ITEM.business = true;
ITEM.description = "A standard spray can filled with paint.";

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

-- Register the item.
kuroScript.item.Register(ITEM);