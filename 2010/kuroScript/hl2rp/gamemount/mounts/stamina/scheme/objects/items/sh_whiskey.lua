--[[
Name: "sh_whiskey.lua".
Product: "HL2 RP".
--]]

local ITEM = {};

-- Set some information.
ITEM.base = "alcohol_base";
ITEM.name = "Whiskey";
ITEM.cost = 5;
ITEM.model = "models/props_junk/garbage_glassbottle002a.mdl";
ITEM.weight = 1.2;
ITEM.access = "v";
ITEM.business = true;
ITEM.attributes = {Stamina = 2};
ITEM.description = "A brown colored whiskey bottle, be careful!";

-- Register the item.
kuroScript.item.Register(ITEM);