--[[
Name: "sh_request_device.lua".
Product: "HL2 RP".
--]]

local ITEM = {};

-- Set some information.
ITEM.name = "Request Device";
ITEM.cost = 25;
ITEM.model = "models/gibs/shield_scanner_gib1.mdl";
ITEM.weight = 0.8;
ITEM.access = "i1";
ITEM.classes = {CLASS_CPA, CLASS_OTA};
ITEM.category = "Perpetuities"
ITEM.business = true;
ITEM.description = "A small radio-like device with one red button.";

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

-- Register the item.
kuroScript.item.Register(ITEM);