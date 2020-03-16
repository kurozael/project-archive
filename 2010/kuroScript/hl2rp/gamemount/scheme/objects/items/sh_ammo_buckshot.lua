--[[
Name: "sh_ammo_buckshot.lua".
Product: "HL2 RP".
--]]

local ITEM = {};

-- Set some information.
ITEM.base = "ammo_base";
ITEM.name = "Shotgun Shells";
ITEM.cost = 75;
ITEM.model = "models/items/boxbuckshot.mdl";
ITEM.weight = 1;
ITEM.uniqueID = "ammo_buckshot";
ITEM.business = true;
ITEM.vocations = {VOC_OTA_EOW, VOC_OTA_OWC};
ITEM.ammoClass = "buckshot";
ITEM.ammoAmount = 16;
ITEM.description = "A red box filled with shells.";

-- Register the item.
kuroScript.item.Register(ITEM);