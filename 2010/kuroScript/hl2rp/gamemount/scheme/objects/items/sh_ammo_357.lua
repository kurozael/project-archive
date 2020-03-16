--[[
Name: "sh_ammo_357.lua".
Product: "HL2 RP".
--]]

local ITEM = {};

-- Set some information.
ITEM.base = "ammo_base";
ITEM.name = ".357 Magnum Bullets";
ITEM.cost = 100;
ITEM.model = "models/items/357ammo.mdl";
ITEM.weight = 1;
ITEM.access = "V";
ITEM.uniqueID = "ammo_357";
ITEM.business = true;
ITEM.vocations = {VOC_OTA_EOW, VOC_OTA_OWC};
ITEM.ammoClass = "357";
ITEM.ammoAmount = 21;
ITEM.description = "A small box filled with bullets and Magnum printed on the side.";

-- Register the item.
kuroScript.item.Register(ITEM);