--[[
Name: "sh_mysterious_fiveseven.lua".
Product: "HL2 RP".
--]]

local ITEM = {};

-- Set some information.
ITEM.base = "weapon_base";
ITEM.name = "Mysterious's FiveSeven";
ITEM.model = "models/weapons/w_pist_fiveseven.mdl";
ITEM.weight = 1.5;
ITEM.uniqueID = "mysterious_fiveseven";
ITEM.weaponClass = "weapon_fiveseven";
ITEM.description = "A small pistol with odd markings engraved into it.";

-- Register the item.
kuroScript.item.Register(ITEM);