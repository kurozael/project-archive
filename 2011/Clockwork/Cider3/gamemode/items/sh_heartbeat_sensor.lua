--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = Clockwork.item:New();
ITEM.name = "Heartbeat Sensor";
ITEM.cost = 80;
ITEM.model = "models/gibs/shield_scanner_gib1.mdl";
ITEM.weight = 1.5;
ITEM.classes = {CLASS_BLACKMARKET, CLASS_DISPENSER};
ITEM.category = "Reusables"
ITEM.business = true;
ITEM.description = "A state-of-the-art heartbeat sensor.";

-- Called to get whether a player has the item equipped.
function ITEM:HasPlayerEquipped(player, bIsValidWeapon)
	return (player:GetSharedVar("Sensor") == self("itemID"));
end;

-- Called when a player has unequipped the item.
function ITEM:OnPlayerUnequipped(player, extraData)
	player:SetCharacterData("Sensor", nil);
	player:SetSharedVar("Sensor", 0);
end;

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	if (player:Alive() and !player:IsRagdolled()) then
		player:SetCharacterData("Sensor", true);
		player:SetSharedVar("Sensor", self("itemID"));
		
		if (itemEntity) then
			return true;
		end;
	else
		Clockwork.player:Notify(player, "You cannot do this action at the moment!");
	end;
	
	return false;
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

Clockwork.item:Register(ITEM);