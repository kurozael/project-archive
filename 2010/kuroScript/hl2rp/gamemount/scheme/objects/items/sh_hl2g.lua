--[[
Name: "sh_hl2g.lua".
Product: "HL2 RP".
--]]

local ITEM = {};

-- Set some information.
ITEM.base = "clothes_base2";
ITEM.name = "Green Winter Jumpsuit";
ITEM.model = "models/props_c17/suitcase_passenger_physics.mdl";
ITEM.cost = 50;
ITEM.group = "alpha1/group01";
ITEM.weight = 1;
ITEM.access = "m";
ITEM.business = true;
ITEM.protection = 0.1;
ITEM.description = "A large, warm winter coat in green.";

-- Called when a replacement is needed for a player.
function ITEM:GetReplacement(player)
	if (string.lower( player:GetModel() ) == "models/humans/group01/jasona.mdl") then
		return "models/humans/group03m/male_02.mdl";
	end;
end;

-- Register the item.
kuroScript.item.Register(ITEM);