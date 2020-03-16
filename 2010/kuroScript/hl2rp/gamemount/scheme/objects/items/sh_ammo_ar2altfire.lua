--[[
Name: "sh_ammo_ar2altfire.lua".
Product: "HL2 RP".
--]]

local ITEM = {};

-- Set some information.
ITEM.base = "ammo_base";
ITEM.name = "Pulse-Rifle Orb";
ITEM.cost = 250;
ITEM.model = "models/items/combine_rifle_ammo01.mdl";
ITEM.weight = 1;
ITEM.uniqueID = "ammo_ar2altfire";
ITEM.business = true;
ITEM.vocations = {VOC_OTA_EOW, VOC_OTA_OWC};
ITEM.ammoClass = "ar2altfire";
ITEM.ammoAmount = 1;
ITEM.description = "A strange item which an orange glow emitting from it.";

-- Register the item.
kuroScript.item.Register(ITEM);