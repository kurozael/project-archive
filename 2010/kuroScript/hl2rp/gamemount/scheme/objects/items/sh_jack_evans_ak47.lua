--[[
Name: "sh_jack_evans_ak47.lua".
Product: "HL2 RP".
--]]

local ITEM = {};

-- Set some information.
ITEM.base = "weapon_base";
ITEM.name = "Jack Evans' AK47";
ITEM.model = "models/weapons/w_rif_ak47.mdl";
ITEM.weight = 3;
ITEM.uniqueID = "jack_evans_ak47";
ITEM.weaponClass = "weapon_ak47";
ITEM.description = "A grey and brown weapon with Jack Evans engraved into the side.";
ITEM.assembleTime = 4;
ITEM.disassembleTime = 4;

-- Register the item.
kuroScript.item.Register(ITEM);