--[[
Name: "sh_health_kit.lua".
Product: "HL2 RP".
--]]

local ITEM = {};

-- Set some information.
ITEM.name = "Health Kit";
ITEM.cost = 50;
ITEM.model = "models/items/healthkit.mdl";
ITEM.weight = 1;
ITEM.access = "v";
ITEM.useText = "Apply";
ITEM.classes = {CLASS_CPA, CLASS_OTA};
ITEM.category = "Medical"
ITEM.business = true;
ITEM.useSound = "items/medshot4.wav";
ITEM.blacklist = {VOC_CPA_RCT};
ITEM.description = "A white packet filled with medication.";
ITEM.customFunctions = {"Give"};

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	player:SetHealth( math.Clamp( player:Health() + kuroScript.game:GetHealAmount(player, 2), 0, player:GetMaxHealth() ) );
	
	-- Call a mount hook.
	kuroScript.mount.Call("PlayerHealed", player, player, self);
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

-- Called when a custom function is used.
function ITEM:OnCustomFunction(player, name)
	if (name == "Give") then
		kuroScript.player.RunKuroScriptCommand(player, "heal", "health_kit");
	end;
end;

-- Register the item.
kuroScript.item.Register(ITEM);