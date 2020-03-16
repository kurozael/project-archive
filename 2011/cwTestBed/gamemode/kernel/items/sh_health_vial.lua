--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = Clockwork.item:New();
ITEM.name = "Health Vial";
ITEM.cost = 60;
ITEM.model = "models/healthvial.mdl";
ITEM.weight = 0.5;
ITEM.useText = "Drink";
ITEM.category = "Disposables";
ITEM.business = true;
ITEM.useSound = "items/medshot4.wav";
ITEM.description = "A strange vial filled with green liquid, be careful.";
ITEM.customFunctions = {"Give"};

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	player:SetHealth(math.Clamp(player:Health() + Clockwork.schema:GetHealAmount(player, 1.5), 0, player:GetMaxHealth()));
	Clockwork.plugin:Call("PlayerHealed", player, player, self);
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

-- Called when a custom function is used.
function ITEM:OnCustomFunction(player, name)
	if (name == "Give") then
		Clockwork.player:RunClockworkCommand(player, "CharHeal", "health_vial");
	end;
end;

Clockwork.item:Register(ITEM);