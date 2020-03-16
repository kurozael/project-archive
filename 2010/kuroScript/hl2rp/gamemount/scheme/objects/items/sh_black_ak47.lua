--[[
Name: "sh_black_ak47.lua".
Product: "HL2 RP".
--]]

local ITEM = {};

-- Set some information.
ITEM.base = "weapon_base";
ITEM.name = "Black AK47";
ITEM.model = "models/weapons/w_rif_ak47.mdl";
ITEM.weight = 3;
ITEM.uniqueID = "black_ak47";
ITEM.weaponClass = "weapon_ak47";
ITEM.description = "A solid black weapon with no hints of color.";
ITEM.assembleTime = 4;
ITEM.disassembleTime = 4;

-- Register the item.
kuroScript.item.Register(ITEM);