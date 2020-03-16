--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.name = "Ammo Base";
ITEM.color = Color(255, 255, 0, 255);
ITEM.useText = "Load";
ITEM.useSound = false;
ITEM.category = "Ammunition";
ITEM.ammoClass = "pistol";
ITEM.ammoAmount = 0;
ITEM.isBaseItem = true;

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	for k, v in pairs( player:GetWeapons() ) do
		local weaponTable = openAura.item:GetWeapon(v);
		
		if ( weaponTable and (weaponTable.primaryAmmoClass == self.ammoClass
		or weaponTable.secondaryAmmoClass == self.ammoClass) ) then
			player:GiveAmmo(self.ammoAmount, self.ammoClass);
			
			return;
		end;
	end;
	
	openAura.player:Notify(player, "You need to equip a weapon that uses this ammunition!");
	
	return false;
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

openAura.item:Register(ITEM);