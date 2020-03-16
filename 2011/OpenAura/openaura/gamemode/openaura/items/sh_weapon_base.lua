--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.name = "Weapon Base";
ITEM.useText = "Equip";
ITEM.color = Color(0, 255, 0, 255);
ITEM.useSound = false;
ITEM.category = "Firearms";
ITEM.isBaseItem = true;
ITEM.useInVehicle = false;

local defaultWeapons = {
	["weapon_357"] = {"357", nil, true},
	["weapon_ar2"] = {"ar2", "ar2altfire", 30},
	["weapon_rpg"] = {"rpg_round", nil, 3},
	["weapon_smg1"] = {"smg1", "smg1_grenade", true},
	["weapon_slam"] = {"slam", nil, 2},
	["weapon_frag"] = {"grenade", nil, 1},
	["weapon_pistol"] = {"pistol", nil, true},
	["weapon_shotgun"] = {"buckshot", nil, true},
	["weapon_crossbow"] = {"xbowbolt", nil, 4}
};

-- Called to get whether a player has the item equipped.
function ITEM:HasPlayerEquipped(player, arguments)
	if (SERVER or !arguments) then
		local weapons = player:GetWeapons();
		
		for k, v in pairs(weapons) do
			if (openAura.item:GetWeapon(v) == self) then
				return true;
			end;
		end;
	elseif ( arguments[self] ) then
		return true;
	end;
end;

-- Called when a player attempts to holster the weapon.
function ITEM:CanHolsterWeapon(player, forceHolster, noMessage)
	return true;
end;

-- Called when the unequip should be handled.
function ITEM:OnHandleUnequip(Callback)
	if (self.OnDrop) then
		local menu = DermaMenu();
			menu:AddOption("Holster", function()
				Callback();
			end);
			menu:AddOption("Drop", function()
				Callback("drop");
			end);
		menu:Open();
	else
		Callback();
	end;
end;

-- Called when a player has unequipped the item.
function ITEM:OnPlayerUnequipped(player, arguments)
	local weapon = player:GetWeapon(self.weaponClass);
	
	if (IsValid(weapon) and openAura.item:GetWeapon(weapon) == self) then
		local class = weapon:GetClass();
		
		if (arguments != "drop") then
			if ( openAura.plugin:Call("PlayerCanHolsterWeapon", player, self) ) then
				if ( player:UpdateInventory(self.uniqueID, 1) ) then
					player:StripWeapon(class);
					player:SelectWeapon("aura_hands");
					
					openAura.plugin:Call("PlayerHolsterWeapon", player, self);
				end;
			end;
		elseif ( openAura.plugin:Call("PlayerCanDropWeapon", player, self) ) then
			local trace = player:GetEyeTraceNoCursor();
			
			if (player:GetShootPos():Distance(trace.HitPos) <= 192) then
				local entity = openAura.entity:CreateItem(player, self.uniqueID, trace.HitPos);
				
				if ( IsValid(entity) ) then
					openAura.entity:MakeFlushToGround(entity, trace.HitPos, trace.HitNormal);
					
					player:StripWeapon(class);
					player:SelectWeapon("aura_hands");
					
					openAura.plugin:Call("PlayerDropWeapon", player, self, entity);
				end;
			else
				openAura.player:Notify(player, "You cannot drop your weapon that far away!");
			end;
		end;
	end;
end;

-- A function to get whether the item has a secondary clip.
function ITEM:HasSecondaryClip()
	return !self.hasNoSecondaryClip;
end;

-- A function to get whether the item has a primary clip.
function ITEM:HasPrimaryClip()
	return !self.hasNoPrimaryClip;
end;

-- A function to get whether the item is a throwable weapon.
function ITEM:IsThrowableWeapon()
	return self.throwableWeapon;
end;

-- A function to get whether the item is a melee weapon.
function ITEM:IsMeleeWeapon()
	return self.meleeWeapon;
end;

-- A function to handle the item's ammo.
function ITEM:HandleAmmo(player, itemEntity)
	if (itemEntity.data.sClip) then
		local sClip = openAura.player:GetSecondaryAmmo(player, self.weaponClass, true);
		
		if (sClip == 0) then
			openAura.player:SetSecondaryAmmo(player, self.weaponClass, itemEntity.data.sClip);
		else
			player:GiveAmmo(itemEntity.data.sClip, self.secondaryAmmoClass);
		end;
	end;
	
	if (itemEntity.data.pClip) then
		local pClip = openAura.player:GetPrimaryAmmo(player, self.weaponClass, true);
		
		if (pClip == 0) then
			openAura.player:SetPrimaryAmmo(player, self.weaponClass, itemEntity.data.pClip);
		else
			player:GiveAmmo(itemEntity.data.pClip, self.primaryAmmoClass);
		end;
	end;
end;

-- Called when a player picks up the item.
function ITEM:OnPickup(player, quickUse, itemEntity)
	if ( !quickUse and IsValid(itemEntity) ) then
		self:HandleAmmo(player, itemEntity);
	end;
end;

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	if ( !player:HasWeapon(self.weaponClass) ) then
		local failure = player:Give(self.weaponClass, self.uniqueID);
		
		if (!failure) then
			if ( self.OnEquip and self:OnEquip(player) ) then
				return false;
			end;
		else
			return false;
		end;
	elseif ( !self.OnAlreadyHas or !self:OnAlreadyHas(player) ) then
		return false;
	end;
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

-- Called when the item should be setup.
function ITEM:OnSetup()
	if (!self.weaponClass) then
		self.weaponClass = self.uniqueID;
	end;
	
	self.weaponClass = string.lower(self.weaponClass);
	
	timer.Simple(2, function()
		local weaponTable = weapons.GetStored(self.weaponClass);
		
		if (weaponTable) then
			if (!self.primaryAmmoClass) then
				if (weaponTable.Primary and weaponTable.Primary.Ammo) then
					self.primaryAmmoClass = weaponTable.Primary.Ammo;
				end;
			end;
			
			if (!self.secondaryAmmoClass) then
				if (weaponTable.Secondary and weaponTable.Secondary.Ammo) then
					self.secondaryAmmoClass = weaponTable.Secondary.Ammo;
				end;
			end;
			
			if (!self.primaryDefaultAmmo) then
				if (weaponTable.Primary and weaponTable.Primary.DefaultClip) then
					if (weaponTable.Primary.DefaultClip > 0) then
						if (weaponTable.Primary.ClipSize == -1) then
							self.primaryDefaultAmmo = weaponTable.Primary.DefaultClip;
							self.hasNoPrimaryClip = true;
						else
							self.primaryDefaultAmmo = true;
						end;
					end;
				end;
			end;
			
			if (!self.secondaryDefaultAmmo) then
				if (weaponTable.Secondary and weaponTable.Secondary.DefaultClip) then
					if (weaponTable.Secondary.DefaultClip > 0) then
						if (weaponTable.Secondary.ClipSize == -1) then
							self.secondaryDefaultAmmo = weaponTable.Secondary.DefaultClip;
							self.hasNoSecondaryClip = true;
						else
							self.secondaryDefaultAmmo = true;
						end;
					end;
				end;
			end;
		elseif ( defaultWeapons[self.weaponClass] ) then
			if (!self.primaryAmmoClass) then
				self.primaryAmmoClass = defaultWeapons[self.weaponClass][1];
			end;
			
			if (!self.secondaryAmmoClass) then
				self.secondaryAmmoClass = defaultWeapons[self.weaponClass][2];
			end;
			
			if (!self.primaryDefaultAmmo) then
				self.primaryDefaultAmmo = defaultWeapons[self.weaponClass][3];
			end;
			
			if (!self.secondaryDefaultAmmo) then
				self.secondaryDefaultAmmo = defaultWeapons[self.weaponClass][4];
			end;
		end;
	end);
end;

-- Called when a player holsters the item.
function ITEM:OnHolster(player, forced) end;

openAura.item:Register(ITEM);