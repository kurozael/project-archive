--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.name = "Jetpack Fuel";
ITEM.cost = 120;
ITEM.model = "models/props_junk/gascan001a.mdl";
ITEM.weight = 1;
ITEM.useText = "Refuel";
ITEM.business = true;
ITEM.description = "A red gas canister filled with jetpack fuel.";

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	player:SetCharacterData("fuel", 100);
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

openAura.item:Register(ITEM);