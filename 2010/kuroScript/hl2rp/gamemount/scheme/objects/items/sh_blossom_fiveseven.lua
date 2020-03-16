--[[
Name: "sh_blossom_fiveseven.lua".
Product: "HL2 RP".
--]]

local ITEM = {};

-- Set some information.
ITEM.base = "weapon_base";
ITEM.name = "Blossom's FiveSeven";
ITEM.model = "models/weapons/w_pist_fiveseven.mdl";
ITEM.weight = 1.5;
ITEM.uniqueID = "blossom_fiveseven";
ITEM.weaponClass = "weapon_fiveseven";
ITEM.description = "A small pistol with Blossom engraved into the side.";

-- Register the item.
kuroScript.item.Register(ITEM);