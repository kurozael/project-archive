--[[
Name: "sh_ammo_xbowbolt.lua".
Product: "HL2 RP".
--]]

local ITEM = {};

-- Set some information.
ITEM.base = "ammo_base";
ITEM.name = "Crossbow Bolts";
ITEM.cost = 75;
ITEM.model = "models/items/crossbowrounds.mdl";
ITEM.weight = 2;
ITEM.uniqueID = "ammo_xbowbolt";
ITEM.business = true;
ITEM.vocations = {VOC_OTA_EOW, VOC_OTA_OWC};
ITEM.ammoClass = "xbowbolt";
ITEM.ammoAmount = 4;
ITEM.description = "A set of iron bolts, the coating is rusting away.";

-- Register the item.
kuroScript.item.Register(ITEM);