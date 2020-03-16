--[[
Name: "sh_weapon_base.lua".
Product: "kuroScript".
--]]

local ITEM = {};

-- Set some information.
ITEM.name = "Weapon Base";
ITEM.useText = "Equip";
ITEM.useSound = false;
ITEM.category = "Weapons";
ITEM.isBaseItem = true;
ITEM.useInVehicle = false;

-- Set some information.
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

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	if ( !player:HasWeapon(self.weaponClass) ) then
		local failure = player:Give(self.weaponClass, self.uniqueID);
		
		-- Check if a statement is true.
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
	
	-- Set some information.
	self.weaponClass = string.lower(self.weaponClass);
	
	-- Set some information.
	timer.Simple(1, function()
		local SWEP = weapons.GetStored(self.weaponClass);
		local k, v;
		
		-- Check if a statement is true.
		if (SWEP) then
			if (!self.primaryAmmoClass) then
				if (SWEP.Primary and SWEP.Primary.Ammo) then
					self.primaryAmmoClass = SWEP.Primary.Ammo;
				end;
			end;
			
			-- Check if a statement is true.
			if (!self.secondaryAmmoClass) then
				if (SWEP.Secondary and SWEP.Secondary.Ammo) then
					self.secondaryAmmoClass = SWEP.Secondary.Ammo;
				end;
			end;
			
			-- Check if a statement is true.
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
			
			-- Check if a statement is true.
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
			
			-- Check if a statement is true.
			if (!self.secondaryAmmoClass) then
				self.secondaryAmmoClass = defaultWeapons[self.weaponClass][2];
			end;
			
			-- Check if a statement is true.
			if (!self.primaryDefaultAmmo) then
				self.primaryDefaultAmmo = defaultWeapons[self.weaponClass][3];
			end;
			
			-- Check if a statement is true.
			if (!self.secondaryDefaultAmmo) then
				self.secondaryDefaultAmmo = defaultWeapons[self.weaponClass][4];
			end;
		end;
	end);
end;

-- Called when a player holsters the item.
function ITEM:OnHolster(player, forced) end;

-- Called when a player attempts to holster the item.
function ITEM:CanHolster(player, silent, forced)
	return true;
end;

-- Register the item.
kuroScript.item.Register(ITEM);