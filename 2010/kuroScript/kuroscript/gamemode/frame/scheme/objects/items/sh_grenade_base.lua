--[[
Name: "sh_grenade_base.lua".
Product: "kuroScript".
--]]

local ITEM = {};

-- Set some information.
ITEM.base = "weapon_base";
ITEM.name = "Grenade Base";
ITEM.isBaseItem = true;
ITEM.expireOnEmpty = true;
ITEM.canUseAmmoless = true;

-- Called when a player equips the item.
function ITEM:OnEquip(player)
	kuroScript.player.GiveSpawnAmmo(player, "grenade", 1);
end;

-- Called when a player holsters the item.
function ITEM:OnHolster(player, forced)
	kuroScript.player.TakeSpawnAmmo(player, "grenade", 1);
end;

-- Called when a player already has the item.
function ITEM:OnAlreadyHas(player)
	kuroScript.player.GiveSpawnAmmo(player, "grenade", 1);
	
	-- Return true to break the function.
	return true;
end;

-- Register the item.
kuroScript.item.Register(ITEM);