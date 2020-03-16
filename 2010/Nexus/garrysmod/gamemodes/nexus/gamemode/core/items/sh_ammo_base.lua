--[[
Name: "sh_ammo_base.lua".
Product: "nexus".
--]]

local ITEM = {};

ITEM.name = "Ammo Base";
ITEM.useText = "Load";
ITEM.useSound = false;
ITEM.category = "Ammunition";
ITEM.ammoClass = "pistol";
ITEM.ammoAmount = 0;
ITEM.isBaseItem = true;

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	for k, v in pairs( player:GetWeapons() ) do
		local weaponTable = nexus.item.GetWeapon(v);
		
		if ( weaponTable and (weaponTable.primaryAmmoClass == self.ammoClass
		or weaponTable.secondaryAmmoClass == self.ammoClass) ) then
			player:GiveAmmo(self.ammoAmount, self.ammoClass);
			
			return;
		end;
	end;
	
	nexus.player.Notify(player, "You need to equip a weapon that uses this ammunition!");
	
	return false;
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

nexus.item.Register(ITEM);