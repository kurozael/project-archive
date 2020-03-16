--[[
Name: "sh_ammo_ar2.lua".
Product: "HL2 RP".
--]]

local ITEM = {};

-- Set some information.
ITEM.base = "ammo_base";
ITEM.name = "Pulse-Rifle Energy";
ITEM.cost = 50;
ITEM.model = "models/items/combine_rifle_cartridge01.mdl";
ITEM.plural = "Pulse-Rifle Energy";
ITEM.weight = 1;
ITEM.uniqueID = "ammo_ar2";
ITEM.business = true;
ITEM.vocations = {VOC_OTA_EOW, VOC_OTA_OWC};
ITEM.ammoClass = "ar2";
ITEM.ammoAmount = 30;
ITEM.description = "A cartridge with a blue glow emitting from it.";

-- Register the item.
kuroScript.item.Register(ITEM);