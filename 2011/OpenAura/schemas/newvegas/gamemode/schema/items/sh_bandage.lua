--[[
	� 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.name = "Bandage";
ITEM.cost = 4; 
ITEM.model = "models/props_wasteland/prison_toiletchunk01f.mdl";
ITEM.batch = 1;
ITEM.weight = 0.2;
ITEM.access = "T";
ITEM.business = true;
ITEM.useText = "Apply";
ITEM.business = true;
ITEM.category = "Medical"
ITEM.description = "A bandage roll, there isn't much so use it wisely.";
ITEM.customFunctions = {"Give"};

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	player:SetHealth( math.Clamp( player:Health() + openAura.schema:GetHealAmount(player), 0, player:GetMaxHealth() ) );
	
	openAura.plugin:Call("PlayerHealed", player, player, self);
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

if (SERVER) then
	function ITEM:OnCustomFunction(player, name)
		if (name == "Give") then
			openAura.player:RunOpenAuraCommand(player, "CharHeal", "bandage");
		end;
	end;
end;

openAura.item:Register(ITEM);