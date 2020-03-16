--[[
Name: "sh_bandage.lua".
Product: "HL2 RP".
--]]

local ITEM = {};

-- Set some information.
ITEM.name = "Bandage";
ITEM.cost = 10;
ITEM.model = "models/props_wasteland/prison_toiletchunk01f.mdl";
ITEM.weight = 0.5;
ITEM.access = "iv2";
ITEM.useText = "Apply";
ITEM.classes = {CLASS_CPA, CLASS_OTA};
ITEM.category = "Medical"
ITEM.business = true;
ITEM.description = "A bandage roll, there isn't much so use it wisely.";
ITEM.customFunctions = {"Give"};

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	player:SetHealth( math.Clamp( player:Health() + kuroScript.game:GetHealAmount(player), 0, player:GetMaxHealth() ) );
	
	-- Call a mount hook.
	kuroScript.mount.Call("PlayerHealed", player, player, self);
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

-- Called when a custom function is used.
function ITEM:OnCustomFunction(player, name)
	if (name == "Give") then
		kuroScript.player.RunKuroScriptCommand(player, "heal", "bandage");
	end;
end;

-- Register the item.
kuroScript.item.Register(ITEM);