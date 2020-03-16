--[[
Name: "sh_battery.lua".
Product: "HL2 RP".
--]]

local ITEM = {};

-- Set some information.
ITEM.name = "Battery";
ITEM.cost = 50;
ITEM.model = "models/items/car_battery01.mdl";
ITEM.plural = "Batteries";
ITEM.weight = 1.5;
ITEM.access = "i2";
ITEM.useText = "Install";
ITEM.business = true;
ITEM.vocations = {VOC_CPA_EPU, VOC_OTA_OWC};
ITEM.description = "A large car battery, you'll find a use for it.";

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	if (player:GetCharacterData("flashlight") == -1) then
		kuroScript.player.Notify(player, "You are already using a battery!");
		
		-- Return false to break the function.
		return false;
	else
		player:SetCharacterData("flashlight", -1);
	end;
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

-- Register the item.
kuroScript.item.Register(ITEM);