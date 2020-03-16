--[[
Name: "sh_beer.lua".
Product: "HL2 RP".
--]]

local ITEM = {};

-- Set some information.
ITEM.base = "alcohol_base";
ITEM.name = "Beer";
ITEM.cost = 5;
ITEM.model = "models/props_junk/garbage_glassbottle003a.mdl";
ITEM.weight = 0.6;
ITEM.access = "v";
ITEM.business = true;
ITEM.attributes = {Strength = 2};
ITEM.description = "A glass bottle filled with liquid, it has a funny smell.";

-- Register the item.
kuroScript.item.Register(ITEM);