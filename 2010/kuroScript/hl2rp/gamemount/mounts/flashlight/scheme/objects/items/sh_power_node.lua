--[[
Name: "sh_power_node.lua".
Product: "HL2 RP".
--]]

local ITEM = {};

-- Set some information.
ITEM.name = "Power Node";
ITEM.cost = 5;
ITEM.model = "models/items/battery.mdl";
ITEM.weight = 0.5;
ITEM.access = "i2";
ITEM.useText = "Install";
ITEM.business = true;
ITEM.vocations = {VOC_CPA_EPU, VOC_OTA_OWC};
ITEM.description = "A strange device with a blue glow emitting from it.";
ITEM.customFunctions = {"Repair"};

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	player:SetCharacterData("flashlight", 100);
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

-- Called when a custom function is used.
function ITEM:OnCustomFunction(player, name)
	if (name == "Repair") then
		kuroScript.player.RunKuroScriptCommand(player, "heal", "power_node");
	end;
end;

-- Register the item.
kuroScript.item.Register(ITEM);