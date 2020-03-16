--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.base = "weapon_base";
ITEM.name = "Grenade Base";
ITEM.color = Color(255, 0, 0, 255);
ITEM.category = "Grenades";
ITEM.isBaseItem = true;
ITEM.throwableWeapon = true;

-- Called when a player equips the item.
function ITEM:OnEquip(player)
	openAura.player:GiveSpawnAmmo(player, "grenade", 1);
end;

-- Called when a player holsters the item.
function ITEM:OnHolster(player, forced)
	openAura.player:TakeSpawnAmmo(player, "grenade", 1);
end;

-- Called when a player attempts to drop the weapon.
function ITEM:CanDropWeapon(player, attacker, noMessage)
	if (player:GetAmmoCount("grenade") == 0) then
		player:StripWeapon(self.weaponClass);
		
		return false;
	else
		return true;
	end;
end;

-- Called when a player attempts to holster the weapon.
function ITEM:CanHolsterWeapon(player, forceHolster, noMessage)
	if (player:GetAmmoCount("grenade") == 0) then
		player:StripWeapon(self.weaponClass);
		
		return false;
	else
		return true;
	end;
end;

openAura.item:Register(ITEM);