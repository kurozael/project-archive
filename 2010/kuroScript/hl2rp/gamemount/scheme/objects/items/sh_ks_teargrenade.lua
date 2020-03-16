--[[
Name: "sh_ks_teargrenade.lua".
Product: "HL2 RP".
--]]

local ITEM = {};

-- Set some information.
ITEM.base = "grenade_base";
ITEM.name = "Tear Grenade";
ITEM.cost = 50;
ITEM.model = "models/items/grenadeammo.mdl";
ITEM.weight = 0.8;
ITEM.uniqueID = "ks_teargrenade";
ITEM.business = true;
ITEM.vocations = {VOC_CPA_EPU, VOC_OTA_OWC};
ITEM.description = "A dirty tube of dust, is this supposed to be a grenade?";

-- Register the item.
kuroScript.item.Register(ITEM);