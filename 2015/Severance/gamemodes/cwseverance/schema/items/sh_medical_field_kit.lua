--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

ITEM = Clockwork.item:New();
ITEM.name = "Field Kit";
ITEM.model = "models/items/items/w_eq_fieldkit.mdl";
ITEM.weight = 1;
ITEM.useText = "Use";
ITEM.category = "Medical"
ITEM.uniqueID = "field_kit";
ITEM.useSound = "items/firstaid.wav";
ITEM.description = "A red fabric bag filled with medical supplies for a variety of minor wounds.";
ITEM.customFunctions = {"Give"};

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	player:SetHealth(math.Clamp(player:Health() + Severance:GetHealAmount(player, 2), 0, player:GetMaxHealth()));
	
	Clockwork.plugin:Call("PlayerHealed", player, player, self);
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

if (SERVER) then
	function ITEM:OnCustomFunction(player, name)
		if (name == "Give") then
			Clockwork.player:RunClockworkCommand(player, "CharHeal", "health_kit");
		end;
	end;
end;

Clockwork.item:Register(ITEM);