--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = Clockwork.item:New();
ITEM.name = "Fuel";
ITEM.cost = 10;
ITEM.model = "models/props_junk/gascan001a.mdl";
ITEM.weight = 1;
ITEM.access = "2";
ITEM.classes = {CLASS_MERCHANT};
ITEM.useText = "Fill";
ITEM.business = true;
ITEM.category = "Vehicles";
ITEM.description = "A red tank filled with delicious petroleum.";

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	local trace = player:GetEyeTraceNoCursor();
	local target = trace.Entity

	if (IsValid(target)) then
		if (target.Fuel) then
			target.Fuel = 100;
		else
			Clockwork.player:Notify(player, "This vehicle cannot be re-fueled!");

			return false;
		end;
	else
		Clockwork.player:Notify(player, "That is not a valid vehicle!");

		return false;
	end;
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

Clockwork.item:Register(ITEM);