--[[
Name: "sh_locker_key.lua".
Product: "HL2 RP".
--]]

local ITEM = {};

-- Set some information.
ITEM.name = "Locker Key";
ITEM.cost = 100;
ITEM.model = "models/props_lab/keypad.mdl";
ITEM.weight = 0.2;
ITEM.access = "i1";
ITEM.category = "Perpetuities"
ITEM.business = true;
ITEM.vocations = {VOC_CPA_EPU, VOC_OTA_OWC};
ITEM.description = "A strange keypad, it looks like it plugs in to something.";

-- Called when a player attempts to give the item to storage.
function ITEM:CanGiveStorage(player, storage)
	if (ValidEntity(storage.entity) and storage.entity:GetClass() == "ks_locker") then
		return false;
	end;
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

-- Register the item.
kuroScript.item.Register(ITEM);