--[[
Name: "sh_weapon_base.lua".
Product: "nexus".
--]]

local ITEM = {};

ITEM.name = "Weapon Base";
ITEM.useText = "Equip";
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
	local weapons = player:GetWeapons();
	
	for k, v in pairs(weapons) do
		if (nexus.item.GetWeapon(v) == self) then
			return true;
		end;
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
	
	if (IsValid(weapon) and nexus.item.GetWeapon(weapon) == self) then
		local class = weapon:GetClass();
		
		if (arguments != "drop") then
			if ( nexus.mount.Call("PlayerCanHolsterWeapon", player, self) ) then
				if ( player:UpdateInventory(self.uniqueID, 1) ) then
					player:StripWeapon(class);
					player:SelectWeapon("nx_hands");
					
					nexus.mount.Call("PlayerHolsterWeapon", player, self);
				end;
			end;
		elseif ( nexus.mount.Call("PlayerCanDropWeapon", player, nil, self) ) then
			local trace = player:GetEyeTraceNoCursor();
			
			if (player:GetShootPos():Distance(trace.HitPos) <= 192) then
				local entity = nexus.entity.CreateItem(player, self.uniqueID, trace.HitPos);
				
				if ( IsValid(entity) ) then
					nexus.entity.MakeFlushToGround(entity, trace.HitPos, trace.HitNormal);
					
					player:StripWeapon(class);
					player:SelectWeapon("nx_hands");
					
					nexus.mount.Call("PlayerDropWeapon", player, self, entity);
				end;
			else
				nexus.player.Notify(player, "You cannot drop your weapon that far away!");
			end;
		end;
	end;
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
	if (itemEntity.data.sClip and itemEntity.data.sClip > 0) then
		local sClip = nexus.player.GetSecondaryAmmo(player, self.weaponClass, true);
		
		if (sClip == 0) then
			nexus.player.SetSecondaryAmmo(player, self.weaponClass, itemEntity.data.sClip);
		else
			player:GiveAmmo(itemEntity.data.sClip, self.secondaryAmmoClass);
		end;
	end;
	
	if (itemEntity.data.pClip and itemEntity.data.pClip > 0) then
		local pClip = nexus.player.GetPrimaryAmmo(player, self.weaponClass, true);
		
		if (pClip == 0) then
			nexus.player.SetPrimaryAmmo(player, self.weaponClass, itemEntity.data.pClip);
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
	if ( IsValid(itemEntity) ) then
		self:HandleAmmo(player, itemEntity);
	end;
	
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
	
	timer.Simple(1, function()
		local SWEP = weapons.GetStored(self.weaponClass);
		
		if (SWEP) then
			if (!self.primaryAmmoClass) then
				if (SWEP.Primary and SWEP.Primary.Ammo) then
					self.primaryAmmoClass = SWEP.Primary.Ammo;
				end;
			end;
			
			if (!self.secondaryAmmoClass) then
				if (SWEP.Secondary and SWEP.Secondary.Ammo) then
					self.secondaryAmmoClass = SWEP.Secondary.Ammo;
				end;
			end;
			
			if (!self.primaryDefaultAmmo) then
				if (SWEP.Primary and SWEP.Primary.DefaultClip) then
					if (SWEP.Primary.DefaultClip > 0) then
						if (SWEP.Primary.ClipSize == -1) then
							self.primaryDefaultAmmo = SWEP.Primary.DefaultClip;
						else
							self.primaryDefaultAmmo = true;
						end;
					end;
				end;
			end;
			
			if (!self.secondaryDefaultAmmo) then
				if (SWEP.Secondary and SWEP.Secondary.DefaultClip) then
					if (SWEP.Secondary.DefaultClip > 0) then
						if (SWEP.Secondary.ClipSize == -1) then
							self.secondaryDefaultAmmo = SWEP.Secondary.DefaultClip;
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

nexus.item.Register(ITEM);