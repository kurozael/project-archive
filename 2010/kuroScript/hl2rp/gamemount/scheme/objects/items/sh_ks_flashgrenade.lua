--[[
Name: "sh_ks_flashgrenade.lua".
Product: "HL2 RP".
--]]

local ITEM = {};

-- Set some information.
ITEM.base = "grenade_base";
ITEM.name = "Flash Grenade";
ITEM.cost = 25;
ITEM.model = "models/items/grenadeammo.mdl";
ITEM.weight = 0.8;
ITEM.uniqueID = "ks_flashgrenade";
ITEM.business = true;
ITEM.vocations = {VOC_CPA_EPU, VOC_OTA_OWC};
ITEM.description = "A dirty tube of dust, is this supposed to be a grenade?";

-- Register the item.
kuroScript.item.Register(ITEM);