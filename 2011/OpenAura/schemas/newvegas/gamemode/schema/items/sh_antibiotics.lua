--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.name = "Antibiotics";
ITEM.cost = 6;
ITEM.batch = 1;
ITEM.model = "models/healthvial.mdl";
ITEM.weight = 0.2;
ITEM.access = "T";
ITEM.business = true;
ITEM.useText = "Swallow";
ITEM.business = true;
ITEM.category = "Medical"
ITEM.useSound = "items/medshot4.wav";
ITEM.description = "A strange vial filled drugs, it says 'take twice a day' on the bottle.";
ITEM.customFunctions = {"Give"};

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	player:SetHealth( math.Clamp( player:Health() + openAura.schema:GetHealAmount(player, 1.5), 0, player:GetMaxHealth() ) );
	
	openAura.plugin:Call("PlayerHealed", player, player, self);
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

if (SERVER) then
	function ITEM:OnCustomFunction(player, name)
		if (name == "Give") then
			openAura.player:RunOpenAuraCommand(player, "CharHeal", "antibiotics");
		end;
	end;
end;

openAura.item:Register(ITEM);