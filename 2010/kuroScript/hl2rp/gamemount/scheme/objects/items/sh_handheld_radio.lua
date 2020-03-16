--[[
Name: "sh_handheld_radio.lua".
Product: "HL2 RP".
--]]

local ITEM = {};

-- Set some information.
ITEM.name = "Handheld Radio";
ITEM.cost = 50;
ITEM.model = "models/items/combine_rifle_cartridge01.mdl";
ITEM.weight = 1;
ITEM.access = "v";
ITEM.category = "Perpetuities"
ITEM.business = true;
ITEM.vocations = {VOC_CPA_EPU, VOC_OTA_OWC};
ITEM.description = "A shiny handheld radio with a frequency tuner.";

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

-- Register the item.
kuroScript.item.Register(ITEM);