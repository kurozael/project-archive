--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

ITEM = Clockwork.item:New();
ITEM.name = "Painkillers";
ITEM.model = "models/items/items/w_eq_pills.mdl";
ITEM.weight = 0.5;
ITEM.useText = "Drink";
ITEM.category = "Medical"
ITEM.useSound = "items/pills_deploy_2.wav";
ITEM.uniqueID = "health_vial";
ITEM.description = "A uniform white bottle filled with red pills.";
ITEM.customFunctions = {"Give"};

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	player:SetHealth(math.Clamp(player:Health() + Severance:GetHealAmount(player, 1.5), 0, player:GetMaxHealth()));
	
	player:BoostAttribute(self("name"), ATB_ENDURANCE, 50, 600);
	player:BoostAttribute(self("name"), ATB_STRENGTH, 25, 600);
	Clockwork.plugin:Call("PlayerHealed", player, player, self);
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

if (SERVER) then
	function ITEM:OnCustomFunction(player, name)
		if (name == "Give") then
			Clockwork.player:RunClockworkCommand(player, "CharHeal", "health_vial");
		end;
	end;
end;

Clockwork.item:Register(ITEM);