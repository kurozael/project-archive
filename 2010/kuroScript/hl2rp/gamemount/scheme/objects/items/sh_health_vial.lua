--[[
Name: "sh_health_vial.lua".
Product: "HL2 RP".
--]]

local ITEM = {};

-- Set some information.
ITEM.name = "Health Vial";
ITEM.cost = 25;
ITEM.model = "models/healthvial.mdl";
ITEM.weight = 0.5;
ITEM.access = "v";
ITEM.useText = "Drink";
ITEM.classes = {CLASS_CPA, CLASS_OTA};
ITEM.category = "Medical"
ITEM.business = true;
ITEM.useSound = "items/medshot4.wav";
ITEM.description = "A strange vial filled with green liquid, be careful.";
ITEM.customFunctions = {"Give"};

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	player:SetHealth( math.Clamp( player:Health() + kuroScript.game:GetHealAmount(player, 1.5), 0, player:GetMaxHealth() ) );
	
	-- Call a mount hook.
	kuroScript.mount.Call("PlayerHealed", player, player, self);
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

-- Called when a custom function is used.
function ITEM:OnCustomFunction(player, name)
	if (name == "Give") then
		kuroScript.player.RunKuroScriptCommand(player, "heal", "health_vial");
	end;
end;

-- Register the item.
kuroScript.item.Register(ITEM);