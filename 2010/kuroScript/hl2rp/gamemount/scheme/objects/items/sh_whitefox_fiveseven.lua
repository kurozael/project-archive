--[[
Name: "sh_whitefox_fiveseven.lua".
Product: "HL2 RP".
--]]

local ITEM = {};

-- Set some information.
ITEM.base = "weapon_base";
ITEM.name = "WhiteFox's FiveSeven";
ITEM.model = "models/weapons/w_pist_fiveseven.mdl";
ITEM.weight = 1.5;
ITEM.uniqueID = "whitefox_fiveseven";
ITEM.weaponClass = "weapon_fiveseven";
ITEM.description = "A small pistol with WhiteFox engraved into the side.";

-- Register the item.
kuroScript.item.Register(ITEM);