--[[
lol
lol
--]]

for k, v in pairs( file.Find("../materials/decals/flesh/blood*") ) do
	resource.AddFile("materials/decals/flesh/"..v);
end;

for k, v in pairs( file.Find("../materials/decals/blood*") ) do
	resource.AddFile("materials/decals/"..v);
end;

for k, v in pairs( file.Find("../materials/effects/blood*") ) do
	resource.AddFile("materials/effects/"..v);
end;

for k, v in pairs( file.Find("../materials/sprites/blood*") ) do
	resource.AddFile("materials/sprites/"..v);
end;

for k, v in pairs( file.Find("../materials/openaura/limbs/*.*") ) do
	resource.AddFile("materials/openaura/limbs/"..v);
end;

for k, v in pairs( file.Find("../materials/openaura/donations/*.*") ) do
	resource.AddFile("materials/openaura/donations/"..v);
end;

resource.AddFile("materials/gui/silkicons/information.vtf");
resource.AddFile("materials/gui/silkicons/information.vmt");
resource.AddFile("materials/gui/silkicons/user_delete.vtf");
resource.AddFile("materials/gui/silkicons/user_delete.vmt");
resource.AddFile("materials/gui/silkicons/newspaper.vtf");
resource.AddFile("materials/gui/silkicons/newspaper.vmt");
resource.AddFile("materials/gui/silkicons/user_add.vtf");
resource.AddFile("materials/gui/silkicons/user_add.vmt");
resource.AddFile("materials/gui/silkicons/comment.vtf");
resource.AddFile("materials/gui/silkicons/comment.vmt");
resource.AddFile("materials/gui/silkicons/error.vtf");
resource.AddFile("materials/gui/silkicons/error.vmt");
resource.AddFile("materials/gui/silkicons/help.vtf");
resource.AddFile("materials/gui/silkicons/help.vmt");
resource.AddFile("models/humans/female_gestures.ani");
resource.AddFile("models/humans/female_gestures.mdl");
resource.AddFile("models/humans/female_postures.ani");
resource.AddFile("models/humans/female_postures.mdl");
resource.AddFile("models/combine_soldier_anims.ani");
resource.AddFile("models/combine_soldier_anims.mdl");
resource.AddFile("models/humans/female_shared.ani");
resource.AddFile("models/humans/female_shared.mdl");
resource.AddFile("models/humans/male_gestures.ani");
resource.AddFile("models/humans/male_gestures.mdl");
resource.AddFile("models/humans/male_postures.ani");
resource.AddFile("models/humans/male_postures.mdl");
resource.AddFile("models/humans/male_shared.ani");
resource.AddFile("models/humans/male_shared.mdl");
resource.AddFile("materials/openaura/screendamage.vmt");
resource.AddFile("materials/openaura/screendamage.vtf");
resource.AddFile("materials/openaura/vignette.vmt");
resource.AddFile("materials/openaura/vignette.vtf");
resource.AddFile("materials/openaura/openaura.vtf");
resource.AddFile("materials/openaura/openaura.vmt");
resource.AddFile("models/police_animations.ani");
resource.AddFile("models/police_animations.mdl");
resource.AddFile("models/humans/female_ss.ani");
resource.AddFile("models/humans/female_ss.mdl");
resource.AddFile("materials/openaura/unknown.vtf");
resource.AddFile("materials/openaura/unknown.vmt");
resource.AddFile("models/humans/male_ss.ani");
resource.AddFile("models/humans/male_ss.mdl");
resource.AddFile("models/police_ss.ani");
resource.AddFile("models/police_ss.mdl");

CreateConVar("npc_thinknow", 1);

AddCSLuaFile("sh_core.lua");
AddCSLuaFile("sh_enums.lua");
AddCSLuaFile("sh_auto.lua");
AddCSLuaFile("cl_auto.lua");

include("sh_auto.lua");

local gradientTexture = openAura.option:GetKey("gradient");
local schemaLogo = openAura.option:GetKey("schema_logo");
local introImage = openAura.option:GetKey("intro_image");
local CurTime = CurTime;
local hook = hook;

if (gradientTexture != "gui/gradient_up") then
	resource.AddFile("materials/"..gradientTexture..".vtf");
	resource.AddFile("materials/"..gradientTexture..".vmt");
end;

if (schemaLogo != "") then
	resource.AddFile("materials/"..schemaLogo..".vtf");
	resource.AddFile("materials/"..schemaLogo..".vmt");
end;

if (introImage != "") then
	resource.AddFile("materials/"..introImage..".vtf");
	resource.AddFile("materials/"..introImage..".vmt");
end;

_R["CRecipientFilter"].IsValid = function()
	return true;
end;

-- Called when the OpenAura core has loaded.
function openAura:OpenAuraCoreLoaded() end;

-- Called when the OpenAura schema has loaded.
function openAura:OpenAuraSchemaLoaded() end;

-- Called at an interval while a player is connected.
function openAura:PlayerThink(player, curTime, infoTable)
	local storageTable = player:GetStorageTable();
	local playBreathingSound = false;
	local activeWeapon = player:GetActiveWeapon();
	
	if ( !self.config:Get("cash_enabled"):Get() ) then
		player:SetCharacterData("cash", 0, true);
		infoTable.wages = 0;
	end;
	
	if (player.reloadHoldTime and curTime >= player.reloadHoldTime) then
		self.player:ToggleWeaponRaised(player);
		
		player.reloadHoldTime = nil;
		player.canShootTime = curTime + self.config:Get("shoot_after_raise_time"):Get();
	end;
	
	if ( player:IsRagdolled() ) then
		player:SetMoveType(MOVETYPE_OBSERVER);
	end;
	
	if (storageTable) then
		if (hook.Call( "PlayerStorageShouldClose", self, player, storageTable) ) then
			self.player:CloseStorage(player);
		end;
	end;
	
	player:SetSharedVar( "inventoryWeight", math.ceil(infoTable.inventoryWeight) );
	player:SetSharedVar( "wages", math.ceil(infoTable.wages) );
	
	if ( self.event:CanRun("limb_damage", "disability") ) then
		local leftLeg = self.limb:GetDamage(player, HITGROUP_LEFTLEG, true);
		local rightLeg = self.limb:GetDamage(player, HITGROUP_RIGHTLEG, true);
		local legDamage = math.max(leftLeg, rightLeg);
		
		if (legDamage > 0) then
			infoTable.runSpeed = infoTable.runSpeed / (1 + legDamage);
			infoTable.jumpPower = infoTable.jumpPower / (1 + legDamage);
		end;
	end;
	
	if ( IsValid(activeWeapon) ) then
		if (player.clipOneInfo.weapon == activeWeapon) then
			local clipOne = activeWeapon:Clip1();
			
			if (clipOne < player.clipOneInfo.ammo) then
				player.clipOneInfo.ammo = clipOne;
				self.plugin:Call( "PlayerFireWeapon", player, activeWeapon, CLIP_ONE, activeWeapon:GetPrimaryAmmoType() );
			end;
		else
			player.clipOneInfo.weapon = activeWeapon;
			player.clipOneInfo.ammo = activeWeapon:Clip1();
		end;
		
		if (player.clipTwoInfo.weapon == activeWeapon) then
			local clipTwo = activeWeapon:Clip2();
			
			if (clipTwo < player.clipTwoInfo.ammo) then
				player.clipTwoInfo.ammo = clipTwo;
				self.plugin:Call( "PlayerFireWeapon", player, activeWeapon, CLIP_TWO, activeWeapon:GetSecondaryAmmoType() );
			end;
		else
			player.clipTwoInfo.weapon = activeWeapon;
			player.clipTwoInfo.ammo = activeWeapon:Clip2();
		end;
	end;
	
	if (infoTable.jogging) then
		infoTable.walkSpeed = infoTable.walkSpeed * 1.75;
	end;
	
	if (infoTable.running == false or infoTable.runSpeed < infoTable.walkSpeed) then
		infoTable.runSpeed = infoTable.walkSpeed;
	end;
	
	if (player:IsRunning() and self.event:CanRun("sounds", "breathing")
	and infoTable.runSpeed < player.runSpeed) then
		local difference = player.runSpeed - infoTable.runSpeed;
		
		if (difference < player.runSpeed * 0.5) then
			playBreathingSound = true;
		end;
	end;
	
	if (!player.nextBreathingSound or curTime >= player.nextBreathingSound) then
		player.nextBreathingSound = curTime + 1;
		
		if (playBreathingSound) then
			openAura.player:StartSound(player, "LowStamina", "player/breathe1.wav");
		else
			openAura.player:StopSound(player, "LowStamina", 4);
		end;
	end;
	
	player:UpdateWeaponRaised();
	player:SetCrouchedWalkSpeed(math.max(infoTable.crouchedSpeed, 0), true);
	player:SetWalkSpeed(math.max(infoTable.walkSpeed, 0), true);
	player:SetJumpPower(math.max(infoTable.jumpPower, 0), true);
	player:SetRunSpeed(math.max(infoTable.runSpeed, 0), true);
end;

-- Called when a player fires a weapon.
function openAura:PlayerFireWeapon(player, weapon, clipType, ammoType) end;

-- Called when a player has disconnected.
function openAura:PlayerDisconnected(player)
	local tempData = player:CreateTempData();
	
	if ( player:HasInitialized() ) then
		if (self.plugin:Call("PlayerCharacterUnloaded", player) != true) then
			player:SaveCharacter();
		end;
		
		if (tempData) then
			self.plugin:Call("PlayerSaveTempData", player, tempData);
		end;
		
		self.chatBox:Add(nil, nil, "disconnect", player:SteamName().." has disconnected from the server.");
	end;
end;

-- Called when OpenAura has initialized.
function openAura:OpenAuraInitialized()
	local cashName = self.option:GetKey("name_cash");
	
	if ( !self.config:Get("cash_enabled"):Get() ) then
		self.command:SetHidden("Give"..string.gsub(cashName, "%s", ""), true);
		self.command:SetHidden("Drop"..string.gsub(cashName, "%s", ""), true);
		self.command:SetHidden("StorageTakeCash", true);
		self.command:SetHidden("StorageGiveCash", true);
		
		self.config:Get("scale_prop_cost"):Set(0, nil, true, true);
		self.config:Get("door_cost"):Set(0, nil, true, true);
	end;
	
	if ( openAura.config:Get("use_own_group_system"):Get() ) then
		self.command:SetHidden("PlySetGroup", true);
		self.command:SetHidden("PlyDemote", true);
	end;
end;

-- Called when a player is banned.
function openAura:PlayerBanned(player, duration, reason) end;

-- Called when a player's model has changed.
function openAura:PlayerModelChanged(player, model) end;

-- Called when a player's inventory string is needed.
function openAura:PlayerGetInventoryString(player, character, inventory)
	if ( player:IsRagdolled() ) then
		for k, v in pairs( player:GetRagdollWeapons() ) do
			if (v.canHolster) then
				local class = v.weaponData["class"];
				local uniqueID = v.weaponData["uniqueID"];
				local itemTable = self.item:GetWeapon(class, uniqueID);
				
				if (itemTable) then
					if ( !self.player:GetSpawnWeapon(player, class) ) then
						if ( inventory[itemTable.uniqueID] ) then
							inventory[itemTable.uniqueID] = inventory[itemTable.uniqueID] + 1;
						else
							inventory[itemTable.uniqueID] = 1;
						end;
					end;
				end;
			end;
		end;
	end;
	
	for k, v in pairs( player:GetWeapons() ) do
		local class = v:GetClass();
		local itemTable = self.item:GetWeapon(v);
		
		if (itemTable) then
			if ( !self.player:GetSpawnWeapon(player, class) ) then
				if ( inventory[itemTable.uniqueID] ) then
					inventory[itemTable.uniqueID] = inventory[itemTable.uniqueID] + 1;
				else
					inventory[itemTable.uniqueID] = 1;
				end;
			end;
		end;
	end;
end;

-- Called when a player's unlock info is needed.
function openAura:PlayerGetUnlockInfo(player, entity)
	if ( self.entity:IsDoor(entity) ) then
		local unlockTime = self.config:Get("unlock_time"):Get();
		
		if ( self.event:CanRun("limb_damage", "unlock_time") ) then
			local leftArm = self.limb:GetDamage(player, HITGROUP_LEFTARM, true);
			local rightArm = self.limb:GetDamage(player, HITGROUP_RIGHTARM, true);
			local armDamage = math.max(leftArm, rightArm);
			
			if (armDamage > 0) then
				unlockTime = unlockTime * (1 + armDamage);
			end;
		end;
		
		return {
			duration = unlockTime,
			Callback = function(player, entity)
				entity:Fire("unlock", "", 0);
			end
		};
	end;
end;

-- Called when an OpenAura item has initialized.
function openAura:OpenAuraItemInitialized(itemTable) end;

-- Called when a player's lock info is needed.
function openAura:PlayerGetLockInfo(player, entity)
	if ( self.entity:IsDoor(entity) ) then
		local lockTime = self.config:Get("lock_time"):Get();
		
		if ( self.event:CanRun("limb_damage", "lock_time") ) then
			local leftArm = self.limb:GetDamage(player, HITGROUP_LEFTARM, true);
			local rightArm = self.limb:GetDamage(player, HITGROUP_RIGHTARM, true);
			local armDamage = math.max(leftArm, rightArm);
			
			if (armDamage > 0) then
				unlockTime = unlockTime * (1 + armDamage);
			end;
		end;
		
		return {
			duration = lockTime,
			Callback = function(player, entity)
				entity:Fire("lock", "", 0);
			end
		};
	end;
end;

-- Called when a player attempts to fire a weapon.
function openAura:PlayerCanFireWeapon(player, bIsRaised, weapon, bIsSecondary)
	local canShootTime = player.canShootTime;
	local curTime = CurTime();
	
	if ( player:IsRunning() and self.config:Get("sprint_lowers_weapon"):Get() ) then
		return false;
	end;
	
	if ( !bIsRaised and !self.plugin:Call("PlayerCanUseLoweredWeapon", player, weapon, bIsSecondary) ) then
		return false;
	end;
	
	if (canShootTime and canShootTime > curTime) then
		return false;
	end;
	
	if ( self.event:CanRun("limb_damage", "weapon_fire") ) then
		local leftArm = self.limb:GetDamage(player, HITGROUP_LEFTARM, true);
		local rightArm = self.limb:GetDamage(player, HITGROUP_RIGHTARM, true);
		local armDamage = math.max(leftArm, rightArm);
		
		if (armDamage > 0) then
			if (!player.armDamageNoFire) then
				if (!player.nextArmDamageTime) then
					player.nextArmDamageTime = curTime + ( 1 - (armDamage * 2) );
				end;
				
				if (curTime >= player.nextArmDamageTime) then
					player.nextArmDamageTime = nil;
					
					if (math.random() <= armDamage * 0.75) then
						player.armDamageNoFire = curTime + ( 1 + (armDamage * 2) );
					end;
				end;
			else
				if (curTime >= player.armDamageNoFire) then
					player.armDamageNoFire = nil;
				end;
				
				return false;
			end;
		end;
	end;
	
	return true;
end;

-- Called when a player attempts to use a lowered weapon.
function openAura:PlayerCanUseLoweredWeapon(player, weapon, secondary)
	if (secondary) then
		return weapon.NeverRaised or (weapon.Secondary and weapon.Secondary.NeverRaised);
	else
		return weapon.NeverRaised or (weapon.Primary and weapon.Primary.NeverRaised);
	end;
end;

-- Called when a player's recognised names have been cleared.
function openAura:PlayerRecognisedNamesCleared(player, status, isAccurate) end;

-- Called when a player's name has been cleared.
function openAura:PlayerNameCleared(player, status, isAccurate) end;

-- Called when an offline player has been given property.
function openAura:PlayerPropertyGivenOffline(key, uniqueID, entity, networked, removeDelay) end;

-- Called when an offline player has had property taken.
function openAura:PlayerPropertyTakenOffline(key, uniqueID, entity) end;

-- Called when a player has been given property.
function openAura:PlayerPropertyGiven(player, entity, networked, removeDelay) end;

-- Called when a player has had property taken.
function openAura:PlayerPropertyTaken(player, entity) end;

-- Called when a player has been given flags.
function openAura:PlayerFlagsGiven(player, flags)
	if ( string.find(flags, "p") and player:Alive() ) then
		self.player:GiveSpawnWeapon(player, "weapon_physgun");
	end;
	
	if ( string.find(flags, "t") and player:Alive() ) then
		self.player:GiveSpawnWeapon(player, "gmod_tool");
	end;
	
	player:SetSharedVar( "flags", player:QueryCharacter("flags") );
end;

-- Called when a player has had flags taken.
function openAura:PlayerFlagsTaken(player, flags)
	if ( string.find(flags, "p") and player:Alive() ) then
		if ( !self.player:HasFlags(player, "p") ) then
			self.player:TakeSpawnWeapon(player, "weapon_physgun");
		end;
	end;
	
	if ( string.find(flags, "t") and player:Alive() ) then
		if ( !self.player:HasFlags(player, "t") ) then
			self.player:TakeSpawnWeapon(player, "gmod_tool");
		end;
	end;
	
	player:SetSharedVar( "flags", player:QueryCharacter("flags") );
end;

-- Called when a player's phys desc override is needed.
function openAura:GetPlayerPhysDescOverride(player, physDesc) end;

-- Called when a player's default skin is needed.
function openAura:GetPlayerDefaultSkin(player)
	local model, skin = self.class:GetAppropriateModel(player:Team(), player);
	
	return skin;
end;

-- Called when a player's default model is needed.
function openAura:GetPlayerDefaultModel(player)
	local model, skin = self.class:GetAppropriateModel(player:Team(), player);
	
	return model;
end;

-- Called when a player's default inventory is needed.
function openAura:GetPlayerDefaultInventory(player, character, inventory) end;

-- Called to get whether a player's weapon is raised.
function openAura:GetPlayerWeaponRaised(player, class, weapon)
	if ( self:IsDefaultWeapon(weapon) ) then
		return true;
	end;
	
	if ( player:IsRunning() and self.config:Get("sprint_lowers_weapon"):Get() ) then
		return false;
	end;
	
	if ( weapon:GetNetworkedBool("Ironsights") ) then
		return true;
	end;
	
	if (weapon:GetNetworkedInt("Zoom") != 0) then
		return true;
	end;
	
	if ( weapon:GetNetworkedBool("Scope") ) then
		return true;
	end;
	
	if ( openAura.config:Get("raised_weapon_system"):Get() ) then
		if (player.toggleWeaponRaised == class) then
			return true;
		else
			player.toggleWeaponRaised = nil;
		end;
		
		if (player.autoWeaponRaised == class) then
			return true;
		else
			player.autoWeaponRaised = nil;
		end;
		
		return false;
	end;
	
	return true;
end;

-- Called when a player's attribute has been updated.
function openAura:PlayerAttributeUpdated(player, attributeTable, amount) end;

-- Called when a player's inventory item has been updated.
function openAura:PlayerInventoryItemUpdated(player, itemTable, amount, force)
	self.player:UpdateStorageForPlayer(player, itemTable.uniqueID);
end;

-- Called when a player's cash has been updated.
function openAura:PlayerCashUpdated(player, amount, reason, noMessage)
	self.player:UpdateStorageForPlayer(player);
end;

-- A function to scale damage by hit group.
function openAura:PlayerScaleDamageByHitGroup(player, attacker, hitGroup, damageInfo, baseDamage)
	if ( attacker:IsVehicle() or ( attacker:IsPlayer() and attacker:InVehicle() ) ) then
		damageInfo:ScaleDamage(0.25);
	end;
end;

-- Called when a player switches their flashlight on or off.
function openAura:PlayerSwitchFlashlight(player, on)
	if (player:HasInitialized() and on) then
		if ( player:IsRagdolled() ) then
			return false;
		else
			return true;
		end;
	else
		return true;
	end;
end;

-- Called when time has passed.
function openAura:TimePassed(quantity) end;

-- Called when OpenAura config has initialized.
function openAura:OpenAuraConfigInitialized(key, value)
	if (key == "cash_enabled" and !value) then
		for k, v in pairs( self.item:GetAll() ) do
			v.cost = 0;
		end;
	elseif (key == "local_voice") then
		if (value) then
			RunConsoleCommand("sv_alltalk", "0");
		end;
	elseif (key == "use_optimised_rates") then
		if (value) then
			RunConsoleCommand("sv_maxupdaterate", "66");
			RunConsoleCommand("sv_minupdaterate", "0");
			RunConsoleCommand("sv_maxcmdrate", "66");
			RunConsoleCommand("sv_mincmdrate", "0");
			RunConsoleCommand("sv_maxrate", "25000");
			RunConsoleCommand("sv_minrate", "0");
		end;
	end;
end;

-- Called when a OpenAura ConVar has changed.
function openAura:OpenAuraConVarChanged(name, previousValue, newValue)
	if (name == "local_voice" and newValue) then
		RunConsoleCommand("sv_alltalk", "1");
	end;
end;

-- Called when OpenAura config has changed.
function openAura:OpenAuraConfigChanged(key, data, previousValue, newValue)
	if (key == "default_flags") then
		for k, v in ipairs( _player.GetAll() ) do
			if ( v:HasInitialized() and v:Alive() ) then
				if ( string.find(previousValue, "p") ) then
					if ( !string.find(newValue, "p") ) then
						if ( !self.player:HasFlags(v, "p") ) then
							self.player:TakeSpawnWeapon(v, "weapon_physgun");
						end;
					end;
				elseif ( !string.find(previousValue, "p") ) then
					if ( string.find(newValue, "p") ) then
						self.player:GiveSpawnWeapon(v, "weapon_physgun");
					end;
				end;
				
				if ( string.find(previousValue, "t") ) then
					if ( !string.find(newValue, "t") ) then
						if ( !self.player:HasFlags(v, "t") ) then
							self.player:TakeSpawnWeapon(v, "gmod_tool");
						end;
					end;
				elseif ( !string.find(previousValue, "t") ) then
					if ( string.find(newValue, "t") ) then
						self.player:GiveSpawnWeapon(v, "gmod_tool");
					end;
				end;
			end;
		end;
	elseif (key == "use_own_group_system") then
		if (newValue) then
			self.command:SetHidden("PlySetGroup", true);
			self.command:SetHidden("PlyDemote", true);
		else
			self.command:SetHidden("PlySetGroup", false);
			self.command:SetHidden("PlyDemote", false);
		end;
	elseif (key == "crouched_speed") then
		for k, v in ipairs( _player.GetAll() ) do
			v:SetCrouchedWalkSpeed(newValue);
		end;
	elseif (key == "ooc_interval") then
		for k, v in ipairs( _player.GetAll() ) do
			v.nextTalkOOC = nil;
		end;
	elseif (key == "jump_power") then
		for k, v in ipairs( _player.GetAll() ) do
			v:SetJumpPower(newValue);
		end;
	elseif (key == "walk_speed") then
		for k, v in ipairs( _player.GetAll() ) do
			v:SetWalkSpeed(newValue);
		end;
	elseif (key == "run_speed") then
		for k, v in ipairs( _player.GetAll() ) do
			v:SetRunSpeed(newValue);
		end;
	end;
end;

-- Called when a player's name has changed.
function openAura:PlayerNameChanged(player, previousName, newName) end;

-- Called when a player attempts to sprays their tag.
function openAura:PlayerSpray(player)
	if ( !player:Alive() or player:IsRagdolled() ) then
		return true;
	elseif ( self.event:CanRun("config", "player_spray") ) then
		return self.config:Get("disable_sprays"):Get();
	end;
end;

-- Called when a player attempts to use an entity.
function openAura:PlayerUse(player, entity)
	if ( player:IsRagdolled(RAGDOLL_FALLENOVER) ) then
		return false;
	else
		return true;
	end;
end;

-- Called when a player's move data is set up.
function openAura:SetupMove(player, moveData)
	if ( player:Alive() and !player:IsRagdolled() ) then
		local frameTime = FrameTime();
		local curTime = CurTime();
		local drunk = self.player:GetDrunk(player);
		
		if (drunk and player.drunkSwerve) then
			player.drunkSwerve = math.Clamp( player.drunkSwerve + frameTime, 0, math.min(drunk * 2, 16) );
			
			moveData:SetMoveAngles( moveData:GetMoveAngles() + Angle(0, math.cos(curTime) * player.drunkSwerve, 0) );
		elseif (player.drunkSwerve and player.drunkSwerve > 1) then
			player.drunkSwerve = math.max(player.drunkSwerve - frameTime, 0);
			
			moveData:SetMoveAngles( moveData:GetMoveAngles() + Angle(0, math.cos(curTime) * player.drunkSwerve, 0) );
		elseif (player.drunkSwerve != 1) then
			player.drunkSwerve = 1;
		end;
	end;
end;

-- Called when a player throws a punch.
function openAura:PlayerPunchThrown(player) end;

-- Called when a player knocks on a door.
function openAura:PlayerKnockOnDoor(player, door) end;

-- Called when a player attempts to knock on a door.
function openAura:PlayerCanKnockOnDoor(player, door) return true; end;

-- Called when a player punches an entity.
function openAura:PlayerPunchEntity(player, entity) end;

-- Called when a player orders an item shipment.
function openAura:PlayerOrderShipment(player, itemTable, entity) end;

-- Called when a player holsters a weapon.
function openAura:PlayerHolsterWeapon(player, itemTable, forced)
	if (itemTable.OnHolster) then
		itemTable:OnHolster(player, forced);
	end;
end;

-- Called when a player attempts to save a recognised name.
function openAura:PlayerCanSaveRecognisedName(player, target)
	if (player != target) then return true; end;
end;

-- Called when a player attempts to restore a recognised name.
function openAura:PlayerCanRestoreRecognisedName(player, target)
	if (player != target) then return true; end;
end;

-- Called when a player attempts to order an item shipment.
function openAura:PlayerCanOrderShipment(player, itemTable)
	if (player.nextOrderItem and CurTime() < player.nextOrderItem) then
		return false;
	end;
	
	return true;
end;

-- Called when a player attempts to get up.
function openAura:PlayerCanGetUp(player) return true; end;

-- Called when a player knocks out a player with a punch.
function openAura:PlayerPunchKnockout(player, target) end;

-- Called when a player attempts to throw a punch.
function openAura:PlayerCanThrowPunch(player) return true; end;

-- Called when a player attempts to punch an entity.
function openAura:PlayerCanPunchEntity(player, entity) return true; end;

-- Called when a player attempts to knock a player out with a punch.
function openAura:PlayerCanPunchKnockout(player, target) return true; end;

-- Called when a player attempts to bypass the faction limit.
function openAura:PlayerCanBypassFactionLimit(player, character) return false; end;

-- Called when a player attempts to bypass the class limit.
function openAura:PlayerCanBypassClassLimit(player, class) return false; end;

-- Called when a player's pain sound should be played.
function openAura:PlayerPlayPainSound(player, gender, damageInfo, hitGroup)
	if (damageInfo:IsBulletDamage() and math.random() <= 0.5) then
		if (hitGroup == HITGROUP_HEAD) then
			return "vo/npc/"..gender.."01/ow0"..math.random(1, 2)..".wav";
		elseif (hitGroup == HITGROUP_CHEST or hitGroup == HITGROUP_GENERIC) then
			return "vo/npc/"..gender.."01/hitingut0"..math.random(1, 2)..".wav";
		elseif (hitGroup == HITGROUP_LEFTLEG or hitGroup == HITGROUP_RIGHTLEG) then
			return "vo/npc/"..gender.."01/myleg0"..math.random(1, 2)..".wav";
		elseif (hitGroup == HITGROUP_LEFTARM or hitGroup == HITGROUP_RIGHTARM) then
			return "vo/npc/"..gender.."01/myarm0"..math.random(1, 2)..".wav";
		elseif (hitGroup == HITGROUP_GEAR) then
			return "vo/npc/"..gender.."01/startle0"..math.random(1, 2)..".wav";
		end;
	end;
	
	return "vo/npc/"..gender.."01/pain0"..math.random(1, 9)..".wav";
end;

-- Called when a player's data has loaded.
function openAura:PlayerDataLoaded(player)
	if ( self.config:Get("openaura_intro_enabled"):Get() ) then
		if ( !player:GetData("openaura_intro") ) then
			umsg.Start("aura_OpenAuraIntro", player);
			umsg.End();
			
			player:SetData("openaura_intro", true);
		end;
	end;
	
	self:StartDataStream(player, "Donations", player.donations);
end;

-- Called when a player attempts to be given a weapon.
function openAura:PlayerCanBeGivenWeapon(player, class, uniqueID, forceReturn)
	return true;
end;

-- Called when a player has been given a weapon.
function openAura:PlayerGivenWeapon(player, class, uniqueID, forceReturn)
	self.inventory:Rebuild(player);
end;

-- Called when a player attempts to create a character.
function openAura:PlayerCanCreateCharacter(player, character, characterID)
	if ( self.quiz:GetEnabled() and !self.quiz:GetCompleted(player) ) then
		return false, "You have not completed the quiz!";
	else
		return true;
	end;
end;

-- Called when a player's bullet info should be adjusted.
function openAura:PlayerAdjustBulletInfo(player, bulletInfo) end;

-- Called when a player attempts to interact with a character.
function openAura:PlayerCanInteractCharacter(player, action, character)
	return false;
end;

-- Called when a player's fall damage is needed.
function openAura:GetFallDamage(player, velocity)
	local ragdollEntity = nil;
	local position = player:GetPos();
	local damage = math.max( (velocity - 464) * 0.225225225, 0 ) * self.config:Get("scale_fall_damage"):Get();
	local filter = {player};
	
	if ( self.config:Get("wood_breaks_fall"):Get() ) then
		if ( player:IsRagdolled() ) then
			ragdollEntity = player:GetRagdollEntity();
			position = ragdollEntity:GetPos();
			filter = {player, ragdollEntity};
		end;
		
		local trace = util.TraceLine( {
			endpos = position - Vector(0, 0, 64),
			start = position,
			filter = filter
		} );

		if (IsValid(trace.Entity) and trace.MatType == MAT_WOOD) then
			if ( string.find(trace.Entity:GetClass(), "prop_physics") ) then
				trace.Entity:Fire("Break", "", 0);
				
				damage = damage * 0.25;
			end;
		end;
	end;
	
	return damage;
end;

-- Called when a player's data stream info has been sent.
function openAura:PlayerDataStreamInfoSent(player)
	if ( player:IsBot() ) then
		self.player:LoadData(player, function(player)
			self.plugin:Call("PlayerDataLoaded", player);
			
			local factions = table.ClearKeys(self.faction.stored, true);
			local faction = factions[ math.random(1, #factions) ];
			
			if (faction) then
				local genders = {GENDER_MALE, GENDER_FEMALE};
				local gender = faction.singleGender or genders[ math.random(1, #genders) ];
				local models = faction.models[ string.lower(gender) ];
				local model = models[ math.random(1, #models) ];
				
				self.player:LoadCharacter( player, 1, {
					faction = faction.name,
					gender = gender,
					model = model,
					name = player:Name(),
					data = {}
				}, function()
					self.player:LoadCharacter(player, 1);
				end);
			end;
		end);
	elseif (table.Count(self.faction.stored) > 0) then
		self.player:LoadData(player, function()
			self.plugin:Call("PlayerDataLoaded", player);
			
			local whitelisted = player:GetData("whitelisted");
			local steamName = player:SteamName();
			local unixTime = os.time();
			
			self.player:SetCharacterMenuState(player, CHARACTER_MENU_OPEN);
			
			for k, v in pairs(whitelisted) do
				if ( self.faction.stored[v] ) then
					self:StartDataStream( player, "SetWhitelisted", {v, true} );
				else
					whitelisted[k] = nil;
				end;
			end;
			
			self.player:GetCharacters(player, function(characters)
				if (characters) then
					for k, v in pairs(characters) do
						self.player:ConvertCharacterMySQL(v);
						player.characters[v.characterID] = {};
						
						for k2, v2 in pairs(v.inventory) do
							if ( !self.item.stored[k2] ) then
								if ( !self.plugin:Call("PlayerHasUnknownInventoryItem", player, v.inventory, k2, v2) ) then
									v.inventory[k2] = nil;
								end;
							end;
						end;
						
						for k2, v2 in pairs(v.attributes) do
							if ( !self.attribute:GetAll()[k2] ) then
								if ( !self.plugin:Call("PlayerHasUnknownAttribute", player, v.attributes, k2, v2.amount, v2.progress) ) then
									v.attributes[k2] = nil;
								end;
							end;
						end;
						
						for k2, v2 in pairs(v) do
							if (k2 == "timeCreated") then
								if (v2 == "") then
									player.characters[v.characterID][k2] = unixTime;
								else
									player.characters[v.characterID][k2] = v2;
								end;
							elseif (k2 == "lastPlayed") then
								player.characters[v.characterID][k2] = unixTime;
							elseif (k2 == "steamName") then
								player.characters[v.characterID][k2] = steamName;
							else
								player.characters[v.characterID][k2] = v2;
							end;
						end;
					end;
					
					for k, v in pairs(player.characters) do
						local delete = self.plugin:Call("PlayerAdjustCharacterTable", player, v);
						
						if (!delete) then
							self.player:CharacterScreenAdd(player, v);
						else
							self.player:ForceDeleteCharacter(player, k);
						end;
					end;
				end;
				
				self.player:SetCharacterMenuState(player, CHARACTER_MENU_LOADED);
			end);
		end);
	end;
end;

-- Called when a player's data stream info should be sent.
function openAura:PlayerSendDataStreamInfo(player)
	if (self.OverrideColorMod) then
		openAura:StartDataStream(player, "ModeratorColGet", self.OverrideColorMod);
	end;
end;

-- Called when a player's death sound should be played.
function openAura:PlayerPlayDeathSound(player, gender)
	return "vo/npc/"..string.lower(gender).."01/pain0"..math.random(1, 9)..".wav";
end;

-- Called when a player's character data should be restored.
function openAura:PlayerRestoreCharacterData(player, data)
	if ( data["physdesc"] ) then
		data["physdesc"] = self:ModifyPhysDesc( data["physdesc"] );
	end;
	
	data["limbs"] = data["limbs"] or {};
end;

-- Called when a player's limb damage is healed.
function openAura:PlayerLimbDamageHealed(player, hitGroup, amount) end;

-- Called when a player's limb takes damage.
function openAura:PlayerLimbTakeDamage(player, hitGroup, damage) end;

-- Called when a player's limb damage is reset.
function openAura:PlayerLimbDamageReset(player) end;

-- Called when a player's character data should be saved.
function openAura:PlayerSaveCharacterData(player, data)
	if ( self.config:Get("save_attribute_boosts"):Get() ) then
		self:SavePlayerAttributeBoosts(player, data);
	end;
	
	data["health"] = player:Health();
	data["armor"] = player:Armor();
	
	if (data["health"] <= 1) then
		data["health"] = nil;
	end;
	
	if (data["armor"] <= 1) then
		data["armor"] = nil;
	end;
end;

-- Called when a player's data should be saved.
function openAura:PlayerSaveData(player, data)
	if (data["whitelisted"] and #data["whitelisted"] == 0) then
		data["whitelisted"] = nil;
	end;
end;

-- Called when a player's storage should close.
function openAura:PlayerStorageShouldClose(player, storageTable)
	local entity = player:GetStorageEntity();
	
	if ( player:IsRagdolled() or !player:Alive() or !entity or (storageTable.distance and player:GetShootPos():Distance( entity:GetPos() ) > storageTable.distance) ) then
		return true;
	elseif ( storageTable.ShouldClose and storageTable.ShouldClose(player, storageTable) ) then
		return true;
	end;
end;

-- Called when a player attempts to pickup a weapon.
function openAura:PlayerCanPickupWeapon(player, weapon)
	if ( player.forceGive or ( player:GetEyeTraceNoCursor().Entity == weapon and player:KeyDown(IN_USE) ) ) then
		return true;
	else
		return false;
	end;
end;

-- Called each tick.
function openAura:Tick()
	if ( self:GetShouldTick() ) then
		local sysTime = SysTime();
		local curTime = CurTime();
		
		if (self.NextManageThinkChecks == nil) then
			self.NextManageThinkChecks = curTime + 60;
		elseif (self.NextManageThinkChecks != true) then
			if (curTime >= self.NextManageThinkChecks) then
				self.NextManageThinkChecks = true;
				self:ManageThinkChecks();
			end;
		end;
		
		if (!self.NextHint or curTime >= self.NextHint) then
			self.hint:Distribute();
			
			self.NextHint = curTime + self.config:Get("hint_interval"):Get();
		end;
		
		if (!self.NextWagesTime or curTime >= self.NextWagesTime) then
			self:DistributeWagesCash();
			self.NextWagesTime = curTime + self.config:Get("wages_interval"):Get();
		end;
		
		if (!self.NextGeneratorTime or curTime >= self.NextGeneratorTime) then
			self:DistributeGeneratorCash();
			self.NextGeneratorTime = curTime + self.config:Get("generator_interval"):Get();
		end;
		
		if (!self.NextDateTimeThink or sysTime >= self.NextDateTimeThink) then
			self:PerformDateTimeThink();
			self.NextDateTimeThink = sysTime + self.config:Get("minute_time"):Get();
		end;
		
		if (!self.NextSaveData or sysTime >= self.NextSaveData) then
			self.plugin:Call("PreSaveData");
				self.plugin:Call("SaveData");
			self.plugin:Call("PostSaveData");
			
			self.NextSaveData = sysTime + self.config:Get("save_data_interval"):Get();
		end;
		
		if (!self.NextCheckEmpty) then
			self.NextCheckEmpty = sysTime + 1200;
		end;
		
		if (sysTime >= self.NextCheckEmpty) then
			self.NextCheckEmpty = nil;
			
			if (#_player.GetAll() == 0) then
				RunConsoleCommand( "changelevel", game.GetMap() );
			end;
		end;
	end;
end;

-- Called when a player's shared variables should be set.
function openAura:PlayerSetSharedVars(player, curTime)
	local weaponClass = self.player:GetWeaponClass(player);
	local r, g, b, a = player:GetColor();
	local drunk = self.player:GetDrunk(player);
	
	player:HandleAttributeProgress(curTime);
	player:HandleAttributeBoosts(curTime);
	
	player:SetSharedVar( "physDesc", player:GetCharacterData("physdesc") );
	player:SetSharedVar( "flags", player:QueryCharacter("flags") );
	player:SetSharedVar( "model", player:QueryCharacter("model") );
	player:SetSharedVar( "name", player:QueryCharacter("name") );
	player:SetSharedVar( "cash", self.player:GetCash(player) );
	
	if ( self.config:Get("enable_temporary_damage"):Get() ) then
		local maxHealth = player:GetMaxHealth();
		local health = player:Health();
		
		if ( player:Alive() ) then
			if ( health >= (maxHealth / 2) ) then
				if (health < maxHealth) then
					player:SetHealth( math.Clamp(health + 1, 0, maxHealth) );
				end;
			elseif (health > 0) then
				if (!player.nextSlowRegeneration) then
					player.nextSlowRegeneration = curTime + 6;
				end;
				
				if (curTime >= player.nextSlowRegeneration) then
					player.nextSlowRegeneration = nil;
					player:SetHealth( math.Clamp(health + 1, 0, maxHealth) );
				end;
			end;
		end;
	end;
	
	if (r == 255 and g == 0 and b == 0 and a == 0) then
		player:SetColor(255, 255, 255, 255);
	end;
	
	for k, v in pairs( player:GetWeapons() ) do
		local ammoType = v:GetPrimaryAmmoType();
		
		if (ammoType == "grenade" and player:GetAmmoCount(ammoType) == 0) then
			player:StripWeapon( v:GetClass() );
		end;
	end;
	
	if (player.drunk) then
		for k, v in pairs(player.drunk) do
			if (curTime >= v) then
				table.remove(player.drunk, k);
			end;
		end;
	end;
	
	if (drunk) then
		player:SetSharedVar("drunk", drunk);
	else
		player:SetSharedVar("drunk", 0);
	end;
end;

-- Called when a player uses an item.
function openAura:PlayerUseItem(player, itemTable, itemEntity) end;

-- Called when a player drops an item.
function openAura:PlayerDropItem(player, itemTable, position, entity)
	if ( IsValid(entity) and self.item:IsWeapon(itemTable) ) then
		local secondaryAmmo = self.player:TakeSecondaryAmmo(player, itemTable.weaponClass);
		local primaryAmmo = self.player:TakePrimaryAmmo(player, itemTable.weaponClass);
		
		if (secondaryAmmo > 0) then
			entity.data.sClip = secondaryAmmo;
		end;
		
		if (primaryAmmo > 0) then
			entity.data.pClip = primaryAmmo;
		end;
	end;
end;

-- Called when a player destroys an item.
function openAura:PlayerDestroyItem(player, itemTable) end;

-- Called when a player drops a weapon.
function openAura:PlayerDropWeapon(player, itemTable, entity)
	if ( IsValid(entity) ) then
		local secondaryAmmo = self.player:TakeSecondaryAmmo(player, itemTable.weaponClass);
		local primaryAmmo = self.player:TakePrimaryAmmo(player, itemTable.weaponClass);
		
		if (secondaryAmmo > 0) then
			entity.data.sClip = secondaryAmmo;
		end;
		
		if (primaryAmmo > 0) then
			entity.data.pClip = primaryAmmo;
		end;
	end;
end;

-- Called when a player charges generator.
function openAura:PlayerChargeGenerator(player, entity, generator) end;

-- Called when a player destroys generator.
function openAura:PlayerDestroyGenerator(player, entity, generator) end;

-- Called when a player's data should be restored.
function openAura:PlayerRestoreData(player, data)
	if ( !data["whitelisted"] ) then
		data["whitelisted"] = {};
	end;
end;

-- Called when a player's temporary info should be saved.
function openAura:PlayerSaveTempData(player, tempData) end;

-- Called when a player's temporary info should be restored.
function openAura:PlayerRestoreTempData(player, tempData) end;

-- Called when a player selects a custom character option.
function openAura:PlayerSelectCharacterOption(player, character, option) end;

-- Called when a player attempts to see another player's status.
function openAura:PlayerCanSeeStatus(player, target)
	return "# "..target:UserID().." | "..target:Name().." | "..target:SteamName().." | "..target:SteamID().." | "..target:IPAddress();
end;

-- Called when a player attempts to see a player's chat.
function openAura:PlayerCanSeePlayersChat(text, teamOnly, listener, speaker)
	return true;
end;

-- Called when a player attempts to hear another player's voice.
function openAura:PlayerCanHearPlayersVoice(listener, speaker)
	if ( self.config:Get("local_voice"):Get() ) then
		if ( listener:IsRagdolled(RAGDOLL_FALLENOVER) or !listener:Alive() ) then
			return false;
		elseif ( speaker:IsRagdolled(RAGDOLL_FALLENOVER) or !speaker:Alive() ) then
			return false;
		elseif ( listener:GetPos():Distance( speaker:GetPos() ) > self.config:Get("talk_radius"):Get() ) then
			return false;
		end;
	end;
	
	return true, true;
end;

-- Called when a player attempts to delete a character.
function openAura:PlayerCanDeleteCharacter(player, character)
	if ( self.config:Get("cash_enabled"):Get() ) then
		if ( character.cash < self.config:Get("default_cash"):Get() ) then
			if ( !character.data["banned"] ) then
				return "You cannot delete characters with less than "..FORMAT_CASH(self.config:Get("default_cash"):Get(), nil, true)..".";
			end;
		end;
	end;
end;

-- Called when a player attempts to switch to a character.
function openAura:PlayerCanSwitchCharacter(player, character)
	if (!player:Alive() and !player:IsCharacterMenuReset() ) then
		return "You cannot switch characters when you are dead!";
	end;
	
	return true;
end;

-- Called when a player attempts to use a character.
function openAura:PlayerCanUseCharacter(player, character)
	return false;
end;

-- Called when a player's weapons should be given.
function openAura:PlayerGiveWeapons(player) end;

-- Called when a player deletes a character.
function openAura:PlayerDeleteCharacter(player, character) end;

-- Called when a player's armor is set.
function openAura:PlayerArmorSet(player, newArmor, oldArmor)
	if ( player:IsRagdolled() ) then
		player:GetRagdollTable().armor = newArmor;
	end;
end;

-- Called when a player's health is set.
function openAura:PlayerHealthSet(player, newHealth, oldHealth)
	if ( player:IsRagdolled() ) then
		player:GetRagdollTable().health = newHealth;
	end;
	
	if (newHealth > oldHealth) then
		self.limb:HealBody(player, (newHealth - oldHealth) / 2);
	end;
end;

-- Called when a player attempts to own a door.
function openAura:PlayerCanOwnDoor(player, door)
	if ( self.entity:IsDoorUnownable(door) ) then
		return false;
	else
		return true;
	end;
end;

-- Called when a player attempts to view a door.
function openAura:PlayerCanViewDoor(player, door)
	if ( self.entity:IsDoorUnownable(door) ) then
		return false;
	end;
	
	return true;
end;

-- Called when a player attempts to holster a weapon.
function openAura:PlayerCanHolsterWeapon(player, itemTable, forceHolster, noMessage)
	if ( self.player:GetSpawnWeapon(player, itemTable.weaponClass) ) then
		if (!noMessage) then
			self.player:Notify(player, "You cannot holster this weapon!");
		end;
		
		return false;
	elseif (itemTable.CanHolsterWeapon) then
		return itemTable:CanHolsterWeapon(player, forceHolster, noMessage);
	else
		return true;
	end;
end;

-- Called when a player attempts to drop a weapon.
function openAura:PlayerCanDropWeapon(player, itemTable, noMessage)
	if ( self.player:GetSpawnWeapon(player, itemTable.weaponClass) ) then
		if (!noMessage) then
			self.player:Notify(player, "You cannot drop this weapon!");
		end;
		
		return false;
	elseif (itemTable.CanDropWeapon) then
		return itemTable:CanDropWeapon(player, noMessage);
	else
		return true;
	end;
end;

-- Called when a player attempts to use an item.
function openAura:PlayerCanUseItem(player, itemTable, noMessage)
	if ( self.item:IsWeapon(itemTable) and self.player:GetSpawnWeapon( player, itemTable.weaponClass ) ) then
		if (!noMessage) then
			self.player:Notify(player, "You cannot use this weapon!");
		end;
		
		return false;
	else
		return true;
	end;
end;

-- Called when a player attempts to drop an item.
function openAura:PlayerCanDropItem(player, itemTable, noMessage) return true; end;

-- Called when a player attempts to destroy an item.
function openAura:PlayerCanDestroyItem(player, itemTable, noMessage) return true; end;

-- Called when a player attempts to destroy generator.
function openAura:PlayerCanDestroyGenerator(player, entity, generator) return true; end;

-- Called when a player attempts to knockout a player.
function openAura:PlayerCanKnockout(player, target) return true; end;

-- Called when a player attempts to use the radio.
function openAura:PlayerCanRadio(player, text, listeners, eavesdroppers) return true; end;

-- Called when death attempts to clear a player's name.
function openAura:PlayerCanDeathClearName(player, attacker, damageInfo) return false; end;

-- Called when death attempts to clear a player's recognised names.
function openAura:PlayerCanDeathClearRecognisedNames(player, attacker, damageInfo) return false; end;

-- Called when a player's ragdoll attempts to take damage.
function openAura:PlayerRagdollCanTakeDamage(player, ragdoll, inflictor, attacker, hitGroup, damageInfo)
	if (!attacker:IsPlayer() and player:GetRagdollTable().immunity) then
		if (CurTime() <= player:GetRagdollTable().immunity) then
			return false;
		end;
	end;
	
	return true;
end;

-- Called when the player attempts to be ragdolled.
function openAura:PlayerCanRagdoll(player, state, delay, decay, ragdoll)
	return true;
end;

-- Called when the player attempts to be unragdolled.
function openAura:PlayerCanUnragdoll(player, state, ragdoll)
	return true;
end;

-- Called when a player has been ragdolled.
function openAura:PlayerRagdolled(player, state, ragdoll)
	player:SetSharedVar("fallenOver", false);
end;

-- Called when a player has been unragdolled.
function openAura:PlayerUnragdolled(player, state, ragdoll)
	player:SetSharedVar("fallenOver", false);
end;

-- Called to check if a player does have a flag.
function openAura:PlayerDoesHaveFlag(player, flag)
	if ( string.find(self.config:Get("default_flags"):Get(), flag) ) then
		return true;
	end;
end;

-- Called to check if a player does have door access.
function openAura:PlayerDoesHaveDoorAccess(player, door, access, isAccurate)
	if (self.entity:GetOwner(door) == player) then
		return true;
	else
		local key = player:QueryCharacter("key");
		
		if ( door.accessList and door.accessList[key] ) then
			if (isAccurate) then
				return door.accessList[key] == access;
			else
				return door.accessList[key] >= access;
			end;
		end;
	end;
	
	return false;
end;

-- Called to check if a player does know another player.
function openAura:PlayerDoesRecognisePlayer(player, target, status, isAccurate, realValue)
	return realValue;
end;

-- Called to check if a player does have an item.
function openAura:PlayerDoesHaveItem(player, itemTable) return false; end;

-- Called when a player attempts to lock an entity.
function openAura:PlayerCanLockEntity(player, entity)
	if ( self.entity:IsDoor(entity) ) then
		return self.player:HasDoorAccess(player, entity);
	else
		return true;
	end;
end;

-- Called when a player's class has been set.
function openAura:PlayerClassSet(player, newClass, oldClass, noRespawn, addDelay, noModelChange) end;

-- Called when a player attempts to unlock an entity.
function openAura:PlayerCanUnlockEntity(player, entity)
	if ( self.entity:IsDoor(entity) ) then
		return self.player:HasDoorAccess(player, entity);
	else
		return true;
	end;
end;

-- Called when a player attempts to use a door.
function openAura:PlayerCanUseDoor(player, door)
	if ( self.entity:GetOwner(door) and !self.player:HasDoorAccess(player, door) ) then
		return false;
	end;
	
	if ( self.entity:IsDoorFalse(door) ) then
		return false;
	end;
	
	return true;
end;

-- Called when a player uses a door.
function openAura:PlayerUseDoor(player, door) end;

-- Called when a player attempts to use an entity in a vehicle.
function openAura:PlayerCanUseEntityInVehicle(player, entity, vehicle)
	if ( entity.UsableInVehicle or self.entity:IsDoor(entity) ) then
		return true;
	end;
end;

-- Called when a player's ragdoll attempts to decay.
function openAura:PlayerCanRagdollDecay(player, ragdoll, seconds)
	return true;
end;

-- Called when a player attempts to exit a vehicle.
function openAura:CanExitVehicle(vehicle, player)
	if ( player.nextExitVehicle and player.nextExitVehicle > CurTime() ) then
		return false;
	end;
	
	if ( IsValid(player) and player:IsPlayer() ) then
		local trace = player:GetEyeTraceNoCursor();
		
		if ( IsValid(trace.Entity) and !trace.Entity:IsVehicle() ) then
			if ( self.plugin:Call("PlayerCanUseEntityInVehicle", player, trace.Entity, vehicle) ) then
				return false;
			end;
		end;
	end;
	
	if ( self.entity:IsChairEntity(vehicle) and !IsValid( vehicle:GetParent() ) ) then
		local trace = player:GetEyeTraceNoCursor();
		
		if (trace.HitPos:Distance( player:GetShootPos() ) <= 192) then
			trace = {
				start = trace.HitPos,
				endpos = trace.HitPos - Vector(0, 0, 1024),
				filter = {player, vehicle}
			};
			
			player.exitVehicle = util.TraceLine(trace).HitPos;
			
			player:SetMoveType(MOVETYPE_NOCLIP);
		else
			return false;
		end;
	end;
	
	return true;
end;

-- Called when a player leaves a vehicle.
function openAura:PlayerLeaveVehicle(player, vehicle)
	timer.Simple(FrameTime() * 0.5, function()
		if ( IsValid(player) and !player:InVehicle() ) then
			if ( IsValid(vehicle) ) then
				if ( self.entity:IsChairEntity(vehicle) ) then
					local position = player.exitVehicle or vehicle:GetPos();
					local targetPosition = self.player:GetSafePosition(player, position, vehicle);
					
					if (targetPosition) then
						player:SetMoveType(MOVETYPE_NOCLIP);
						player:SetPos(targetPosition);
					end;
					
					player:SetMoveType(MOVETYPE_WALK);
					
					player.exitVehicle = nil;
				end;
			end;
		end;
	end);
end;

-- Called when a player enters a vehicle.
function openAura:PlayerEnteredVehicle(player, vehicle, class)
	timer.Simple(FrameTime() * 0.5, function()
		if ( IsValid(player) ) then
			local model = player:GetModel();
			local class = self.animation:GetModelClass(model);
			
			if ( IsValid(vehicle) and !string.find(model, "/player/") ) then
				if (class == "maleHuman" or class == "femaleHuman") then
					if ( self.entity:IsChairEntity(vehicle) ) then
						player:SetLocalPos( Vector(16.5438, -0.1642, -20.5493) );
					else
						player:SetLocalPos( Vector(30.1880, 4.2020, -6.6476) );
					end;
				end;
			end;
			
			player:SetCollisionGroup(COLLISION_GROUP_PLAYER);
		end;
	end);
end;

-- Called when a player attempts to change class.
function openAura:PlayerCanChangeClass(player, class)
	local curTime = CurTime();
	
	if (player.nextChangeClass and curTime < player.nextChangeClass) then
		self.player:Notify(player, "You cannot change class for another "..math.ceil(player.nextChangeClass - curTime).." second(s)!");
		
		return false;
	else
		return true;
	end;
end;

-- Called when a player attempts to earn generator cash.
function openAura:PlayerCanEarnGeneratorCash(player, info, cash)
	return true;
end;

-- Called when a player earns generator cash.
function openAura:PlayerEarnGeneratorCash(player, info, cash) end;

-- Called when a player attempts to earn wages cash.
function openAura:PlayerCanEarnWagesCash(player, cash)
	return true;
end;

-- Called when a player is given wages cash.
function openAura:PlayerGiveWagesCash(player, cash, wagesName)
	return true;
end;

-- Called when a player earns wages cash.
function openAura:PlayerEarnWagesCash(player, cash) end;

-- Called when OpenAura has loaded all of the entities.
function openAura:OpenAuraInitPostEntity() end;

-- Called when OpenAuth has initialized.
function openAura:OpenAuthInitialized(isAuthed)
	if (!isAuthed) then
		openAura:SetSharedVar("noAuth", true);
	end;
	
	--[[
		If you -really- want the default loading screen, you may remove this
		part of the code; however, it will only change it if you are using
		the default Garry's Mod one.
	--]]
	if (GetConVarString("sv_loadingurl") == "http://loading.garrysmod.com/") then
		for i = 1, 2 do
			RunConsoleCommand("sv_loadingurl", "http://kurozael.com/openaura/connecting/");
		end;
	end;
end;

-- Called when a player attempts to say something in-character.
function openAura:PlayerCanSayIC(player, text)
	if ( ( !player:Alive() or player:IsRagdolled(RAGDOLL_FALLENOVER) ) and !self.player:GetDeathCode(player, true) ) then
		self.player:Notify(player, "You don't have permission to do this right now!");
		
		return false;
	else
		return true;
	end;
end;

-- Called when a player attempts to say something out-of-character.
function openAura:PlayerCanSayOOC(player, text) return true; end;

-- Called when a player attempts to say something locally out-of-character.
function openAura:PlayerCanSayLOOC(player, text) return true; end;

-- Called when attempts to use a command.
function openAura:PlayerCanUseCommand(player, commandTable, arguments) return true; end;

-- Called when a player says something.
function openAura:PlayerSay(player, text, public)
	text = openAura:Replace(text, " ' ", "'");
	text = openAura:Replace(text, " : ", ":");
	
	local prefix = self.config:Get("command_prefix"):Get();
	local curTime = CurTime();
	
	if (string.sub(text, 1, 2) == "//") then
		text = string.Trim( string.sub(text, 3) );
		
		if (text != "") then
			if ( self.plugin:Call("PlayerCanSayOOC", player, text) ) then
				if (!player.nextTalkOOC or curTime > player.nextTalkOOC) then
					self:ServerLog("[OOC] "..player:Name()..": "..text);
					self.chatBox:Add(nil, player, "ooc", text);
					
					player.nextTalkOOC = curTime + self.config:Get("ooc_interval"):Get();
				else
					self.player:Notify(player, "You cannot cannot talk out-of-character for another "..math.ceil( player.nextTalkOOC - CurTime() ).." second(s)!");
					
					return "";
				end;
			end;
		end;
	elseif (string.sub(text, 1, 3) == ".//" or string.sub(text, 1, 2) == "[[") then
		if (string.sub(text, 1, 3) == ".//") then
			text = string.Trim( string.sub(text, 4) );
		else
			text = string.Trim( string.sub(text, 3) );
		end;
		
		if (text != "") then
			if ( self.plugin:Call("PlayerCanSayLOOC", player, text) ) then
				self.chatBox:AddInRadius( player, "looc", text, player:GetPos(), self.config:Get("talk_radius"):Get() );
			end;
		end;
	elseif (string.sub(text, 1, 1) == prefix) then
		local prefixLength = string.len(prefix);
		local arguments = self:ExplodeByTags(text, " ", "\"", "\"", true);
		local command = string.sub(arguments[1], prefixLength + 1);
		
		if (self.command.stored[command] and self.command.stored[command].arguments < 2
		and !self.command.stored[command].optionalArguments) then
			text = string.sub(text, string.len(command) + prefixLength + 2);
			
			if (text != "") then
				arguments = {command, text};
			else
				arguments = {command};
			end;
		else
			arguments[1] = command;
		end;
		
		self.command:ConsoleCommand(player, "aura", arguments);
	elseif ( self.plugin:Call("PlayerCanSayIC", player, text) ) then
		self.chatBox:AddInRadius( player, "ic", text, player:GetPos(), self.config:Get("talk_radius"):Get() );
		
		if ( self.player:GetDeathCode(player, true) ) then
			self.player:UseDeathCode( player, nil, {text} );
		end;
	end;
	
	if ( self.player:GetDeathCode(player) ) then
		self.player:TakeDeathCode(player);
	end;
	
	return "";
end;

-- Called when a player attempts to suicide.
function openAura:CanPlayerSuicide(player) return false; end;

-- Called when a player attempts to punt an entity with the gravity gun.
function openAura:GravGunPunt(player, entity)
	return self.config:Get("enable_gravgun_punt"):Get();
end;

-- Called when a player attempts to pickup an entity with the gravity gun.
function openAura:GravGunPickupAllowed(player, entity)
	if ( IsValid(entity) ) then
		if ( !self.player:IsAdmin(player) and !self.entity:IsInteractable(entity) ) then
			return false;
		else
			return self.BaseClass:GravGunPickupAllowed(player, entity);
		end;
	end;
	
	return false;
end;

-- Called when a player picks up an entity with the gravity gun.
function openAura:GravGunOnPickedUp(player, entity)
	player.isHoldingEntity = entity;
	entity.isBeingHeld = player;
end;

-- Called when a player drops an entity with the gravity gun.
function openAura:GravGunOnDropped(player, entity)
	player.isHoldingEntity = nil;
	entity.isBeingHeld = nil;
end;

-- Called when a player attempts to unfreeze an entity.
function openAura:CanPlayerUnfreeze(player, entity, physicsObject)
	local isAdmin = self.player:IsAdmin(player);
	
	if (self.config:Get("enable_prop_protection"):Get() and !isAdmin) then
		local ownerKey = entity:GetOwnerKey();
		
		if (ownerKey and player:QueryCharacter("key") != ownerKey) then
			return false;
		end;
	end;
	
	if ( !isAdmin and !self.entity:IsInteractable(entity) ) then
		return false;
	end;
	
	if ( entity:IsVehicle() ) then
		if ( IsValid( entity:GetDriver() ) ) then
			return false;
		end;
	end;
	
	return true;
end;

-- Called when a player attempts to freeze an entity with the physics gun.
function openAura:OnPhysgunFreeze(weapon, physicsObject, entity, player)
	local isAdmin = self.player:IsAdmin(player);
	
	if (self.config:Get("enable_prop_protection"):Get() and !isAdmin) then
		local ownerKey = entity:GetOwnerKey();
		
		if (ownerKey and player:QueryCharacter("key") != ownerKey) then
			return false;
		end;
	end;
	
	if ( !isAdmin and self.entity:IsChairEntity(entity) ) then
		local entities = ents.FindInSphere(entity:GetPos(), 64);
		
		for k, v in ipairs(entities) do
			if ( self.entity:IsDoor(v) ) then
				return false;
			end;
		end;
	end;
	
	if ( entity:GetPhysicsObject():IsPenetrating() ) then
		return false;
	end;
	
	if (!isAdmin and entity.PhysgunDisabled) then
		return false;
	end;
	
	if ( !isAdmin and !self.entity:IsInteractable(entity) ) then
		return false;
	else
		return self.BaseClass:OnPhysgunFreeze(weapon, physicsObject, entity, player);
	end;
end;

-- Called when a player attempts to pickup an entity with the physics gun.
function openAura:PhysgunPickup(player, entity)
	local canPickup = nil;
	local isAdmin = self.player:IsAdmin(player);
	
	if ( !isAdmin and !self.entity:IsInteractable(entity) ) then
		return false;
	end;
	
	if ( !isAdmin and self.entity:IsPlayerRagdoll(entity) ) then
		return false;
	end;
	
	if (!isAdmin and entity:GetClass() == "prop_ragdoll") then
		local ownerKey = entity:GetOwnerKey();
		
		if (ownerKey and player:QueryCharacter("key") != ownerKey) then
			return false;
		end;
	end;
	
	if (!isAdmin) then
		canPickup = self.BaseClass:PhysgunPickup(player, entity);
	else
		canPickup = true;
	end;
	
	if (self.entity:IsChairEntity(entity) and !isAdmin) then
		local entities = ents.FindInSphere(entity:GetPos(), 256);
		
		for k, v in ipairs(entities) do
			if ( self.entity:IsDoor(v) ) then
				return false;
			end;
		end;
	end;
	
	if (self.config:Get("enable_prop_protection"):Get() and !isAdmin) then
		local ownerKey = entity:GetOwnerKey();
		
		if (ownerKey and player:QueryCharacter("key") != ownerKey) then
			canPickup = false;
		end;
	end;
	
	if ( entity:IsPlayer() and entity:InVehicle() ) then
		canPickup = false;
	end;
	
	if (canPickup) then
		player.isHoldingEntity = entity;
		entity.isBeingHeld = player;
		
		if ( !entity:IsPlayer() ) then
			if ( self.config:Get("prop_kill_protection"):Get() ) then
				entity.lastCollisionGroup = entity:GetCollisionGroup();
				entity:SetCollisionGroup(COLLISION_GROUP_WEAPON);
				entity.damageImmunity = CurTime() + 60;
			end;
		else
			entity.moveType = entity:GetMoveType();
			entity:SetMoveType(MOVETYPE_NOCLIP);
		end;
		
		return true;
	else
		return false;
	end;
end;

-- Called when a player attempts to drop an entity with the physics gun.
function openAura:PhysgunDrop(player, entity)
	if ( !entity:IsPlayer() ) then
		if (entity.lastCollisionGroup) then
			self.entity:ReturnCollisionGroup(entity, entity.lastCollisionGroup);
		end;
	else
		entity:SetMoveType(entity.moveType or MOVETYPE_WALK);
		entity.moveType = nil;
	end;
	
	player.isHoldingEntity = nil;
	entity.isBeingHeld = nil;
end;

-- Called when a player attempts to spawn an NPC.
function openAura:PlayerSpawnNPC(player, model)
	if ( !self.player:HasFlags(player, "n") ) then
		return false;
	end;
	
	if ( !player:Alive() or player:IsRagdolled() ) then
		self.player:Notify(player, "You don't have permission to do this right now!");
		
		return false;
	end;
	
	if ( !self.player:IsAdmin(player) ) then
		return false;
	else
		return true;
	end;
end;

-- Called when an NPC has been killed.
function openAura:OnNPCKilled(entity, attacker, inflictor) end;

-- Called to get whether an entity is being held.
function openAura:GetEntityBeingHeld(entity)
	return entity.isBeingHeld or entity:IsPlayerHolding();
end;

-- Called when an entity is removed.
function openAura:EntityRemoved(entity)
	if ( !self:IsShuttingDown() ) then
		if ( IsValid(entity) ) then
			if (entity.giveRefund) then
				if ( CurTime() <= entity.giveRefund[1] ) then
					if ( IsValid( entity.giveRefund[2] ) ) then
						self.player:GiveCash(entity.giveRefund[2], entity.giveRefund[3], "Prop Refund");
					end;
				end;
			end;
			
			self.player:GetAllProperty()[ entity:EntIndex() ] = nil;
		end;
		
		self.entity:ClearProperty(entity);
	end;
end;

-- Called when an entity's menu option should be handled.
function openAura:EntityHandleMenuOption(player, entity, option, arguments)
	local class = entity:GetClass();
	local generator = self.generator:Get(class);
	
	if ( class == "aura_item" and (arguments == "aura_itemTake" or arguments == "aura_itemUse") ) then
		if ( self.entity:BelongsToAnotherCharacter(player, entity) ) then
			self.player:Notify(player, "You cannot pick up items you dropped on another character!");
			
			return;
		end;
		
		player:EmitSound("physics/body/body_medium_impact_soft"..math.random(1, 7)..".wav");
		
		local itemTable = entity.itemTable;
		local quickUse = (arguments == "aura_itemUse");
		
		if (itemTable) then
			local didPickupItem = true;
			local canPickup = ( !itemTable.CanPickup or itemTable:CanPickup(player, quickUse, entity) );
			
			if (canPickup != false) then
				if (canPickup and type(canPickup) == "string") then
					local newItemTable = self.item:Get(canPickup);
					
					if (newItemTable) then
						itemTable = newItemTable;
					end;
				end;
				
				player:SetItemEntity(entity);
				
				if (quickUse) then
					player:UpdateInventory(itemTable.uniqueID, 1, true, true);
					
					if ( !self.player:RunOpenAuraCommand(player, "InvAction", itemTable.uniqueID, "use") ) then
						player:UpdateInventory(itemTable.uniqueID, -1, true, true);
						didPickupItem = false;
					else
						player:FakePickup(entity);
					end;
				else
					local success, fault = player:UpdateInventory(itemTable.uniqueID, 1);
					
					if (!success) then
						self.player:Notify(player, fault);
						didPickupItem = false;
					else
						player:FakePickup(entity);
					end;
				end;
				
				if (didPickupItem) then
					if (!itemTable.OnPickup or itemTable:OnPickup(player, quickUse, entity) != false) then
						entity:Remove();
					end;
				end;
				
				player:SetItemEntity(nil);
			end;
		end;
	elseif (class == "aura_item" and arguments == "aura_itemAmmo") then
		local itemTable = entity.itemTable;
		
		if ( itemTable and self.item:IsWeapon(itemTable) ) then
			if ( itemTable:HasSecondaryClip() or itemTable:HasPrimaryClip() ) then
				if (entity.data.sClip) then
					player:GiveAmmo(entity.data.sClip, itemTable.secondaryAmmoClass);
				end;
				
				if (entity.data.pClip) then
					player:GiveAmmo(entity.data.pClip, itemTable.primaryAmmoClass);
				end;
				
				entity.data.sClip = nil;
				entity.data.pClip = nil;
				
				player:FakePickup(entity);
			end;
		end;
	elseif (class == "aura_shipment" and arguments == "aura_shipmentOpen") then
		player:EmitSound("physics/body/body_medium_impact_soft"..math.random(1, 7)..".wav");
		player:FakePickup(entity);
		
		self.player:OpenStorage( player, {
			name = "Shipment",
			weight = entity.weight,
			entity = entity,
			distance = 192,
			inventory = entity.inventory,
			OnClose = function(player, storageTable, entity)
				if ( IsValid(entity) ) then
					if (!entity.inventory or table.Count(entity.inventory) == 0) then
						entity:Explode(entity:BoundingRadius() * 2);
						entity:Remove();
					end;
				end;
			end,
			CanGive = function(player, storageTable, itemTable)
				return false;
			end
		} );
	elseif (class == "aura_cash" and arguments == "aura_cashTake") then
		if ( self.entity:BelongsToAnotherCharacter(player, entity) ) then
			self.player:Notify(player, "You cannot pick up "..self.option:GetKey("name_cash", true).." you dropped on another character!");
			
			return;
		end;
		
		self.player:GiveCash( player, entity:GetDTInt("amount"), self.option:GetKey("name_cash") );
		player:EmitSound("physics/body/body_medium_impact_soft"..math.random(1, 7)..".wav");
		player:FakePickup(entity);
		
		entity:Remove();
	elseif (generator and arguments == "aura_generatorSupply") then
		if (entity:GetPower() < generator.power) then
			if ( !entity.CanSupply or entity:CanSupply(player) ) then
				self.plugin:Call("PlayerChargeGenerator", player, entity, generator);
				
				entity:SetDTInt("power", generator.power);
				player:FakePickup(entity);
				
				if (entity.OnSupplied) then
					entity:OnSupplied(player);
				end;
				
				entity:Explode();
			end;
		end;
	end;
end;

-- Called when a player has spawned a prop.
function openAura:PlayerSpawnedProp(player, model, entity)
	if ( IsValid(entity) ) then
		local scalePropCost = self.config:Get("scale_prop_cost"):Get();
		
		if (scalePropCost > 0) then
			local cost = math.ceil( math.max( (entity:BoundingRadius() / 2) * scalePropCost, 1 ) );
			local info = {cost = cost, name = "Prop"};
			
			self.plugin:Call("PlayerAdjustPropCostInfo", player, entity, info);
			
			if ( self.player:CanAfford(player, info.cost) ) then
				self.player:GiveCash(player, -info.cost, info.name);
				
				entity.giveRefund = {CurTime() + 10, player, info.cost};
			else
				self.player:Notify(player, "You need another "..FORMAT_CASH(info.cost - self.player:GetCash(player), nil, true).."!");
				entity:Remove();
			end;
		end;
		
		if ( IsValid(entity) ) then
			entity:SetOwnerKey( player:QueryCharacter("key") );
			
			self.BaseClass:PlayerSpawnedProp(player, model, entity);
			
			if ( IsValid(entity) ) then
				self:PrintLog(2, player:Name().." has spawned '"..tostring(model).."'.");
				
				if ( self.config:Get("prop_kill_protection"):Get() ) then
					entity.damageImmunity = CurTime() + 60;
				end;
			end;
		end;
	end;
end;

-- Called when a player attempts to spawn a prop.
function openAura:PlayerSpawnProp(player, model)
	if ( !self.player:HasFlags(player, "e") ) then
		return false;
	end;
	
	if ( !player:Alive() or player:IsRagdolled() ) then
		self.player:Notify(player, "You don't have permission to do this right now!");
		
		return false;
	end;
	
	if ( self.player:IsAdmin(player) ) then
		return true;
	end;
	
	return self.BaseClass:PlayerSpawnProp(player, model);
end;

-- Called when a player attempts to spawn a ragdoll.
function openAura:PlayerSpawnRagdoll(player, model)
	if ( !self.player:HasFlags(player, "r") ) then return false; end;
	
	if ( !player:Alive() or player:IsRagdolled() ) then
		self.player:Notify(player, "You don't have permission to do this right now!");
		
		return false;
	end;
	
	if ( !self.player:IsAdmin(player) ) then
		return false;
	else
		return true;
	end;
end;

-- Called when a player attempts to spawn an effect.
function openAura:PlayerSpawnEffect(player, model)
	if ( !player:Alive() or player:IsRagdolled() ) then
		self.player:Notify(player, "You don't have permission to do this right now!");
		
		return false;
	end;
	
	if ( !self.player:IsAdmin(player) ) then
		return false;
	else
		return true;
	end;
end;

-- Called when a player attempts to spawn a vehicle.
function openAura:PlayerSpawnVehicle(player, model)
	if ( !string.find(model, "chair") and !string.find(model, "seat") ) then
		if ( !self.player:HasFlags(player, "C") ) then
			return false;
		end;
	elseif ( !self.player:HasFlags(player, "c") ) then
		return false;
	end;
	
	if ( !player:Alive() or player:IsRagdolled() ) then
		self.player:Notify(player, "You don't have permission to do this right now!");
		
		return false;
	end;
	
	if ( self.player:IsAdmin(player) ) then
		return true;
	end;
	
	return self.BaseClass:PlayerSpawnVehicle(player, model);
end;

-- Called when a player attempts to use a tool.
function openAura:CanTool(player, trace, tool)
	local isAdmin = self.player:IsAdmin(player);
	
	if ( IsValid(trace.Entity) ) then
		local isPropProtectionEnabled = self.config:Get("enable_prop_protection"):Get();
		local characterKey = player:QueryCharacter("key");
		
		if ( !isAdmin and !self.entity:IsInteractable(trace.Entity) ) then
			return false;
		end;
		
		if ( !isAdmin and self.entity:IsPlayerRagdoll(trace.Entity) ) then
			return false;
		end;
		
		if (isPropProtectionEnabled and !isAdmin) then
			local ownerKey = trace.Entity:GetOwnerKey();
			
			if (ownerKey and characterKey != ownerKey) then
				return false;
			end;
		end;
		
		if (!isAdmin) then
			if (tool == "nail") then
				local newTrace = {};
				
				newTrace.start = trace.HitPos;
				newTrace.endpos = trace.HitPos + player:GetAimVector() * 16;
				newTrace.filter = {player, trace.Entity};
				
				newTrace = util.TraceLine(newTrace);
				
				if ( IsValid(newTrace.Entity) ) then
					if ( !self.entity:IsInteractable(newTrace.Entity) or self.entity:IsPlayerRagdoll(newTrace.Entity) ) then
						return false;
					end;
					
					if (isPropProtectionEnabled) then
						local ownerKey = newTrace.Entity:GetOwnerKey();
						
						if (ownerKey and characterKey != ownerKey) then
							return false;
						end;
					end;
				end;
			elseif ( tool == "remover" and player:KeyDown(IN_ATTACK2) and !player:KeyDownLast(IN_ATTACK2) ) then
				if ( !trace.Entity:IsMapEntity() ) then
					local entities = constraint.GetAllConstrainedEntities(trace.Entity);
					
					for k, v in pairs(entities) do
						if ( v:IsMapEntity() or self.entity:IsPlayerRagdoll(v) ) then
							return false;
						end;
						
						if (isPropProtectionEnabled) then
							local ownerKey = v:GetOwnerKey();
							
							if (ownerKey and characterKey != ownerKey) then
								return false;
							end;
						end;
					end
				else
					return false;
				end;
			end
		end;
	end;
	
	if (!isAdmin) then
		return self.BaseClass:CanTool(player, trace, tool);
	else
		return true;
	end;
end;

-- Called when a player attempts to NoClip.
function openAura:PlayerNoClip(player)
	if ( player:IsRagdolled() ) then
		return false;
	elseif ( player:IsSuperAdmin() ) then
		return true;
	else
		return false;
	end;
end;

-- Called when a player's character has initialized.
function openAura:PlayerCharacterInitialized(player)
	umsg.Start("aura_InventoryClear", player);
	umsg.End();
	
	umsg.Start("aura_AttributesClear", player);
	umsg.End();
	
	self:StartDataStream( player, "ReceiveLimbDamage", player:GetCharacterData("limbs") );
	
	if ( !self.class:Get( player:Team() ) ) then
		self.class:AssignToDefault(player);
	end;
	
	for k, v in pairs( self.player:GetInventory(player) ) do
		local itemTable = self.item:Get(k);
		
		if (itemTable) then
			player:UpdateInventory(itemTable.uniqueID, 0, true);
		end;
	end;
		
	player.attributeProgress = {};
	player.attributeProgressTime = 0;
	
	for k, v in pairs( self.attribute:GetAll() ) do
		player:UpdateAttribute(k);
	end;
	
	for k, v in pairs( player:QueryCharacter("attributes") ) do
		player.attributeProgress[k] = math.floor(v.progress);
	end;
	
	local startHintsDelay = 4;
	local starterHintsTable = {
		"Directory",
		"Give Name",
		"Target Recognises",
		"Raise Weapon"
	};
	
	for k, v in ipairs(starterHintsTable) do
		local hintTable = self.hint:Find(v);
		
		if ( hintTable and !player:GetData("hint"..k) ) then
			if (!hintTable.Callback or hintTable.Callback(player) != false) then
				timer.Simple(startHintsDelay, function()
					if ( IsValid(player) ) then
						self.hint:Send(player, hintTable.text, 30);
						player:SetData("hint"..k, true);
					end;
				end);
				
				startHintsDelay = startHintsDelay + 30;
			end;
		end;
	end;
	
	if (startHintsDelay > 4) then
		player.isViewingStarterHints = true;
		
		timer.Simple(startHintsDelay, function()
			if ( IsValid(player) ) then
				player.isViewingStarterHints = false;
			end;
		end);
	end;
end;

-- Called when a player has used their death code.
function openAura:PlayerDeathCodeUsed(player, commandTable, arguments) end;

-- Called when a player has created a character.
function openAura:PlayerCharacterCreated(player, character) end;

-- Called when a player's character has unloaded.
function openAura:PlayerCharacterUnloaded(player)
	self.player:SetupRemovePropertyDelays(player);
	self.player:DisableProperty(player);
	self.player:SetRagdollState(player, RAGDOLL_RESET);
	self.player:CloseStorage(player, true)
	
	player:SetTeam(TEAM_UNASSIGNED);
end;

-- Called when a player's character has loaded.
function openAura:PlayerCharacterLoaded(player)
	player:SetSharedVar( "inventoryWeight", self.config:Get("default_inv_weight"):Get() );
	
	player.characterLoadedTime = CurTime();
	player.attributeBoosts = {};
	player.crouchedSpeed = self.config:Get("crouched_speed"):Get();
	player.ragdollTable = {};
	player.spawnWeapons = {};
	player.clipTwoInfo = {weapon = NULL, ammo = 0};
	player.clipOneInfo = {weapon = NULL, ammo = 0};
	player.initialized = true;
	player.firstSpawn = true;
	player.lightSpawn = false;
	player.changeClass = false;
	player.spawnAmmo = {};
	player.jumpPower = self.config:Get("jump_power"):Get();
	player.walkSpeed = self.config:Get("walk_speed"):Get();
	player.runSpeed = self.config:Get("run_speed"):Get();
	
	hook.Call( "PlayerRestoreCharacterData", openAura, player, player:QueryCharacter("data") );
	hook.Call( "PlayerRestoreTempData", openAura, player, player:CreateTempData() );
	
	self.player:SetCharacterMenuState(player, CHARACTER_MENU_CLOSE);
	
	self.plugin:Call("PlayerCharacterInitialized", player);
	
	self.player:RestoreRecognisedNames(player);
	self.player:ReturnProperty(player);
	self.player:SetInitialized(player, true);
	
	player.firstSpawn = false;
	
	local charactersTable = self.config:Get("mysql_characters_table"):Get();
	local schemaFolder = self:GetSchemaFolder();
	local characterID = player:QueryCharacter("characterID");
	local onNextLoad = player:QueryCharacter("onNextLoad");
	local steamID = player:SteamID();
	local query = "UPDATE "..charactersTable.." SET _OnNextLoad = \"\" WHERE";
	
	if (onNextLoad != "") then
		tmysql.query(query.." _Schema = \""..schemaFolder.."\" AND _SteamID = \""..steamID.."\" AND _CharacterID = "..characterID);
		
		player:SetCharacterData("onNextLoad", "", true);
		
		CHARACTER = player:GetCharacter();
			PLAYER = player;
				RunString(onNextLoad);
			PLAYER = nil;
		CHARACTER = nil;
	end;
end;

-- Called when a player's property should be restored.
function openAura:PlayerReturnProperty(player) end;

-- Called when config has initialized for a player.
function openAura:PlayerConfigInitialized(player)
	self.plugin:Call("PlayerSendDataStreamInfo", player);
	
	if ( player:IsBot() ) then
		self.plugin:Call("PlayerDataStreamInfoSent", player);
	else
		timer.Simple(FrameTime() * 32, function()
			if ( IsValid(player) ) then
				umsg.Start("aura_DataStreaming", player);
				umsg.End();
			end;
		end);
	end;
end;

-- Called each frame that a player is dead.
function openAura:PlayerDeathThink(player)
	return true;
end;

-- Called when a player has used their radio.
function openAura:PlayerRadioUsed(player, text, listeners, eavesdroppers) end;

-- Called when a player's drop weapon info should be adjusted.
function openAura:PlayerAdjustDropWeaponInfo(player, info)
	return true;
end;

-- Called when a player's character creation info should be adjusted.
function openAura:PlayerAdjustCharacterCreationInfo(player, info, data) end;

-- Called when a player's earn generator info should be adjusted.
function openAura:PlayerAdjustEarnGeneratorInfo(player, info) end;

-- Called when a player's order item should be adjusted.
function openAura:PlayerAdjustOrderItemTable(player, itemTable) end;

-- Called when a player's next punch info should be adjusted.
function openAura:PlayerAdjustNextPunchInfo(player, info) end;

-- Called when a player has an unknown inventory item.
function openAura:PlayerHasUnknownInventoryItem(player, inventory, item, amount) end;

-- Called when a player uses an unknown item function.
function openAura:PlayerUseUnknownItemFunction(player, itemTable, itemFunction) end;

-- Called when a player has an unknown attribute.
function openAura:PlayerHasUnknownAttribute(player, attributes, attribute, amount, progress) end;

-- Called when a player's character table should be adjusted.
function openAura:PlayerAdjustCharacterTable(player, character)
	if ( self.faction.stored[character.faction] ) then
		if ( self.faction.stored[character.faction].whitelist
		and !self.player:IsWhitelisted(player, character.faction) ) then
			character.data["banned"] = true;
		end;
	else
		return true;
	end;
end;

-- Called when a player's character screen info should be adjusted.
function openAura:PlayerAdjustCharacterScreenInfo(player, character, info) end;

-- Called when a player's prop cost info should be adjusted.
function openAura:PlayerAdjustPropCostInfo(player, entity, info) end;

-- Called when a player's death info should be adjusted.
function openAura:PlayerAdjustDeathInfo(player, info) end;

-- Called when chat box info should be adjusted.
function openAura:ChatBoxAdjustInfo(info) end;

-- Called when a chat box message has been added.
function openAura:ChatBoxMessageAdded(info) end;

-- Called when a player's radio text should be adjusted.
function openAura:PlayerAdjustRadioInfo(player, info) end;

-- Called when a player should gain a frag.
function openAura:PlayerCanGainFrag(player, victim) return true; end;

-- Called when a player's model should be set.
function openAura:PlayerSetModel(player)
	self.player:SetDefaultModel(player);
	self.player:SetDefaultSkin(player);
end;

-- Called just after a player spawns.
function openAura:PostPlayerSpawn(player, lightSpawn, changeClass, firstSpawn)
	if (firstSpawn) then
		local attributeBoosts = player:GetCharacterData("attributeboosts");
		local health = player:GetCharacterData("health");
		local armor = player:GetCharacterData("armor");
		
		if (health and health > 1) then
			player:SetHealth(health);
		end;
		
		if (armor and armor > 1) then
			player:SetArmor(armor);
		end;
		
		if (attributeBoosts) then
			for k, v in pairs(attributeBoosts) do
				for k2, v2 in pairs(v) do
					self.attributes:Boost(player, k2, k, v2.amount, v2.duration);
				end;
			end;
		end;
	else
		player:SetCharacterData("attributeboosts", nil);
		player:SetCharacterData("health", nil);
		player:SetCharacterData("armor", nil);
	end;
end;

-- Called when a player should take damage.
function openAura:PlayerShouldTakeDamage(player, attacker, inflictor, damageInfo)
	if ( self.player:IsNoClipping(player) ) then
		return false;
	end;
	
	return true;
end;

-- Called when a player is attacked by a trace.
function openAura:PlayerTraceAttack(player, damageInfo, direction, trace)
	player.lastHitGroup = trace.HitGroup;
	
	return false;
end;

-- Called just before a player dies.
function openAura:DoPlayerDeath(player, attacker, damageInfo)
	self.player:DropWeapons(player, attacker);
	self.player:SetAction(player, false);
	self.player:SetDrunk(player, false);
	
	local deathSound = self.plugin:Call( "PlayerPlayDeathSound", player, self.player:GetGender(player) );
	local decayTime = self.config:Get("body_decay_time"):Get();

	if (decayTime > 0) then
		self.player:SetRagdollState( player, RAGDOLL_KNOCKEDOUT, nil, decayTime, self:ConvertForce(damageInfo:GetDamageForce() * 32) );
	else
		self.player:SetRagdollState( player, RAGDOLL_KNOCKEDOUT, nil, 600, self:ConvertForce(damageInfo:GetDamageForce() * 32) );
	end;
	
	if ( self.plugin:Call("PlayerCanDeathClearRecognisedNames", player, attacker, damageInfo) ) then
		self.player:ClearRecognisedNames(player);
	end;
	
	if ( self.plugin:Call("PlayerCanDeathClearName", player, attacker, damageInfo) ) then
		self.player:ClearName(player);
	end;
	
	if (deathSound) then
		player:EmitSound("physics/flesh/flesh_impact_hard"..math.random(1, 5)..".wav", 150);
		
		timer.Simple(FrameTime() * 25, function()
			if ( IsValid(player) ) then
				player:EmitSound(deathSound);
			end;
		end);
	end;
	
	player:SetForcedAnimation(false);
	player:SetCharacterData("ammo", {}, true);
	player:StripWeapons();
	player:Extinguish();
	player:StripAmmo();
	player.spawnAmmo = {};
	player:AddDeaths(1);
	player:UnLock();
	
	if ( IsValid(attacker) and attacker:IsPlayer() ) then
		if (player != attacker) then
			if ( self.plugin:Call("PlayerCanGainFrag", attacker, player) ) then
				attacker:AddFrags(1);
			end;
		end;
	end;
end;

-- Called when a player dies.
function openAura:PlayerDeath(player, inflictor, attacker, damageInfo)
	self:CalculateSpawnTime(player, inflictor, attacker, damageInfo);
	
	if ( player:GetRagdollEntity() ) then
		local ragdoll = player:GetRagdollEntity();
		
		if (inflictor:GetClass() == "prop_combine_ball") then
			if (damageInfo) then
				self.entity:Disintegrate(player:GetRagdollEntity(), 3, damageInfo:GetDamageForce() * 32);
			else
				self.entity:Disintegrate(player:GetRagdollEntity(), 3);
			end;
		end;
	end;
	
	if ( attacker:IsPlayer() ) then
		if ( IsValid( attacker:GetActiveWeapon() ) ) then
			self:PrintLog(1, attacker:Name().." has killed "..player:Name().." with "..self.player:GetWeaponClass(attacker)..".");
		else
			self:PrintLog(1, attacker:Name().." has killed "..player:Name()..".");
		end;
	else
		self:PrintLog(2, attacker:GetClass().." has killed "..player:Name()..".");
	end;
end;

-- Called when a player's weapons should be given.
function openAura:PlayerLoadout(player)
	local weapons = self.class:Query(player:Team(), "weapons");
	local ammo = self.class:Query(player:Team(), "ammo");
	
	player.spawnWeapons = {};
	player.spawnAmmo = {};
	
	if ( self.player:HasFlags(player, "t") ) then
		self.player:GiveSpawnWeapon(player, "gmod_tool");
	end
	
	if ( self.player:HasFlags(player, "p") ) then
		self.player:GiveSpawnWeapon(player, "weapon_physgun");
	end
	
	self.player:GiveSpawnWeapon(player, "weapon_physcannon");
	
	if ( self.config:Get("give_hands"):Get() ) then
		self.player:GiveSpawnWeapon(player, "aura_hands");
	end;
	
	if ( self.config:Get("give_keys"):Get() ) then
		self.player:GiveSpawnWeapon(player, "aura_keys");
	end;
	
	if (weapons) then
		for k, v in ipairs(weapons) do
			if ( !self.player:GiveSpawnItemWeapon(player, v) ) then
				player:Give(v);
			end;
		end;
	end;
	
	if (ammo) then
		for k, v in pairs(ammo) do
			self.player:GiveSpawnAmmo(player, k, v);
		end;
	end;
	
	self.plugin:Call("PlayerGiveWeapons", player);
	
	if ( self.config:Get("give_hands"):Get() ) then
		player:SelectWeapon("aura_hands");
	end;
end

-- Called when the server shuts down.
function openAura:ShutDown()
	self.ShuttingDown = true;
end;

-- Called when a player presses F1.
function openAura:ShowHelp(player)
	umsg.Start("aura_InfoToggle", player);
	umsg.End();
end;

-- Called when a player presses F2.
function openAura:ShowTeam(player)
	if ( !self.player:IsNoClipping(player) ) then
		local doRecogniseMenu = true;
		local entity = player:GetEyeTraceNoCursor().Entity;
		
		if ( IsValid(entity) and self.entity:IsDoor(entity) ) then
			if (entity:GetPos():Distance( player:GetShootPos() ) <= 192) then
				if ( self.plugin:Call("PlayerCanViewDoor", player, entity) ) then
					if ( self.plugin:Call("PlayerUse", player, entity) ) then
						local owner = self.entity:GetOwner(entity);
						
						if (owner) then
							if ( self.player:HasDoorAccess(player, entity, DOOR_ACCESS_COMPLETE) ) then
								local data = {
									sharedAccess = self.entity:DoorHasSharedAccess(entity),
									sharedText = self.entity:DoorHasSharedText(entity),
									unsellable = self.entity:IsDoorUnsellable(entity),
									accessList = {},
									isParent = self.entity:IsDoorParent(entity),
									entity = entity,
									owner = owner
								};
								
								for k, v in ipairs( _player.GetAll() ) do
									if (v != player and v != owner) then
										if ( self.player:HasDoorAccess(v, entity, DOOR_ACCESS_COMPLETE) ) then
											data.accessList[v] = DOOR_ACCESS_COMPLETE;
										elseif ( self.player:HasDoorAccess(v, entity, DOOR_ACCESS_BASIC) ) then
											data.accessList[v] = DOOR_ACCESS_BASIC;
										end;
									end;
								end;
								
								self:StartDataStream(player, "Door", data);
							end;
						else
							self:StartDataStream(player, "PurchaseDoor", entity);
						end;
					end;
				end;
				
				doRecogniseMenu = false;
			end;
		end;
		
		if ( self.config:Get("recognise_system"):Get() ) then
			if (doRecogniseMenu) then
				umsg.Start("aura_RecogniseMenu", player);
				umsg.End();
			end;
		end;
	end;
end;

-- Called when a player selects a custom character option.
function openAura:PlayerSelectCustomCharacterOption(player, action, character) end;

-- Called when a player takes damage.
function openAura:PlayerTakeDamage(player, inflictor, attacker, hitGroup, damageInfo)
	if ( hitGroup and !damageInfo:IsFallDamage() ) then
		self.limb:TakeDamage( player, hitGroup, damageInfo:GetDamage() );
		
		if ( damageInfo:IsBulletDamage() and self.event:CanRun("limb_damage", "stumble") ) then
			if (hitGroup == HITGROUP_LEFTLEG or hitGroup == HITGROUP_RIGHTLEG) then
				local rightLeg = self.limb:GetDamage(player, HITGROUP_RIGHTLEG);
				local leftLeg = self.limb:GetDamage(player, HITGROUP_LEFTLEG);
				
				if ( rightLeg > 50 and leftLeg > 50 and !player:IsRagdolled() ) then
					self.player:SetRagdollState( player, RAGDOLL_FALLENOVER, 8, nil, self:ConvertForce(damageInfo:GetDamageForce() * 32) );
					damageInfo:ScaleDamage(0.25);
				end;
			end;
		end;
	else
		self.limb:TakeDamage( player, HITGROUP_RIGHTLEG, damageInfo:GetDamage() );
		self.limb:TakeDamage( player, HITGROUP_LEFTLEG, damageInfo:GetDamage() );
	end;
end;

-- Called when an entity takes damage.
function openAura:EntityTakeDamage(entity, inflictor, attacker, amount, damageInfo)
	if ( self.config:Get("prop_kill_protection"):Get() ) then
		local curTime = CurTime();
		
		if ( (IsValid(inflictor) and inflictor.damageImmunity and inflictor.damageImmunity > curTime)
		or (attacker.damageImmunity and attacker.damageImmunity > curTime) ) then
			damageInfo:SetDamage(0);
		end;
		
		if ( ( IsValid(inflictor) and inflictor:IsBeingHeld() )
		or attacker:IsBeingHeld() ) then
			damageInfo:SetDamage(0);
		end;
	end;
	
	if ( entity:IsPlayer() and entity:InVehicle() and !IsValid( entity:GetVehicle():GetParent() ) ) then
		entity.lastHitGroup = self:GetRagdollHitBone(entity, damageInfo:GetDamagePosition(), HITGROUP_GEAR);
		
		if ( damageInfo:IsBulletDamage() ) then
			if ( ( attacker:IsPlayer() or attacker:IsNPC() ) and attacker != player ) then
				damageInfo:ScaleDamage(10000);
			end;
		end;
	end;
	
	if (damageInfo:GetDamage() > 0) then
		local isPlayerRagdoll = self.entity:IsPlayerRagdoll(entity);
		local player = self.entity:GetPlayer(entity);
		
		if ( player and (entity:IsPlayer() or isPlayerRagdoll) ) then
			if ( damageInfo:IsFallDamage() or self.config:Get("damage_view_punch"):Get() ) then
				player:ViewPunch( Angle( math.random(amount, amount), math.random(amount, amount), math.random(amount, amount) ) );
			end;
			
			if (!isPlayerRagdoll) then
				if (damageInfo:IsDamageType(DMG_CRUSH) and damageInfo:GetDamage() < 10) then
					damageInfo:SetDamage(0);
				else
					local lastHitGroup = player:LastHitGroup();
					local killed = nil;
					
					if ( player:InVehicle() and damageInfo:IsExplosionDamage() ) then
						if (!damageInfo:GetDamage() or damageInfo:GetDamage() == 0) then
							damageInfo:SetDamage( player:GetMaxHealth() );
						end;
					end;
					
					self:ScaleDamageByHitGroup(player, attacker, lastHitGroup, damageInfo, amount);
					
					if (damageInfo:GetDamage() > 0) then
						self:CalculatePlayerDamage(player, lastHitGroup, damageInfo);
						
						player:SetVelocity( self:ConvertForce(damageInfo:GetDamageForce() * 32, 200) );
						
						if (player:Alive() and player:Health() == 1) then
							player:SetFakingDeath(true);
								hook.Call("DoPlayerDeath", self, player, attacker, damageInfo);
								hook.Call("PlayerDeath", self, player, inflictor, attacker, damageInfo);
								
								self:CreateBloodEffects( damageInfo:GetDamagePosition(), 1, player, damageInfo:GetDamageForce() );
							player:SetFakingDeath(false, true);
						else
							local noMessage = self.plugin:Call("PlayerTakeDamage", player, inflictor, attacker, lastHitGroup, damageInfo);
							local sound = self.plugin:Call("PlayerPlayPainSound", player, self.player:GetGender(player), damageInfo, lastHitGroup);
							
							self:CreateBloodEffects( damageInfo:GetDamagePosition(), 1, player, damageInfo:GetDamageForce() );
							
							if (sound and !noMessage) then
								player:EmitSound("physics/flesh/flesh_impact_bullet"..math.random(1, 5)..".wav", 150);
								
								timer.Simple(FrameTime() * 25, function()
									if ( IsValid(player) ) then
										player:EmitSound(sound);
									end;
								end);
							end;
							
							if ( attacker:IsPlayer() ) then
								self:PrintLog(3, player:Name().." has taken damage from "..attacker:Name().." with "..self.player:GetWeaponClass(attacker, "an unknown weapon")..".");
							else
								self:PrintLog(3, player:Name().." has taken damage from "..attacker:GetClass()..".");
							end;
						end;
					end;
					
					damageInfo:SetDamage(0);
					
					player.lastHitGroup = nil;
				end;
			else
				local hitGroup = self:GetRagdollHitGroup( entity, damageInfo:GetDamagePosition() );
				local curTime = CurTime();
				local killed = nil;
				
				self:ScaleDamageByHitGroup(player, attacker, hitGroup, damageInfo, amount);
				
				if (self.plugin:Call("PlayerRagdollCanTakeDamage", player, entity, inflictor, attacker, hitGroup, damageInfo)
				and damageInfo:GetDamage() > 0) then
					if ( !attacker:IsPlayer() ) then
						if (attacker:GetClass() == "prop_ragdoll" or self.entity:IsDoor(attacker)
						or damageInfo:GetDamage() < 5) then
							return;
						end;
					end;
					
					if ( damageInfo:GetDamage() >= 10 or damageInfo:IsBulletDamage() ) then
						self:CreateBloodEffects( damageInfo:GetDamagePosition(), 1, entity, damageInfo:GetDamageForce() );
					end;
					
					self:CalculatePlayerDamage(player, hitGroup, damageInfo);
					
					if (player:Alive() and player:Health() == 1) then
						player:SetFakingDeath(true);
							player:GetRagdollTable().health = 0;
							player:GetRagdollTable().armor = 0;
							
							hook.Call("DoPlayerDeath", self, player, attacker, damageInfo);
							hook.Call("PlayerDeath", self, player, inflictor, attacker, damageInfo);
						player:SetFakingDeath(false, true);
					elseif ( player:Alive() ) then
						local noMessage = self.plugin:Call("PlayerTakeDamage", player, inflictor, attacker, hitGroup, damageInfo);
						local sound = self.plugin:Call("PlayerPlayPainSound", player, self.player:GetGender(player), damageInfo, hitGroup);
						
						if (sound and !noMessage) then
							entity:EmitSound("physics/flesh/flesh_impact_bullet"..math.random(1, 5)..".wav", 320, 150);
							
							timer.Simple(FrameTime() * 25, function()
								if ( IsValid(entity) ) then
									entity:EmitSound(sound);
								end;
							end);
						end;
						
						if ( attacker:IsPlayer() ) then
							self:PrintLog(3, player:Name().." has taken damage from "..attacker:Name().." with "..self.player:GetWeaponClass(attacker, "an unknown weapon")..".");
						else
							self:PrintLog(3, player:Name().." has taken damage from "..attacker:GetClass()..".");
						end;
					end;
				end;
				
				damageInfo:SetDamage(0);
			end;
		elseif (entity:GetClass() == "prop_ragdoll") then
			if ( damageInfo:GetDamage() >= 20 or damageInfo:IsBulletDamage() ) then
				if ( !string.find(entity:GetModel(), "matt") and !string.find(entity:GetModel(), "gib") ) then
					local matType = util.QuickTrace( entity:GetPos(), entity:GetPos() ).MatType;
					
					if (matType == MAT_FLESH or matType == MAT_BLOODYFLESH) then
						self:CreateBloodEffects( damageInfo:GetDamagePosition(), 1, entity, damageInfo:GetDamageForce() );
					end;
				end;
			end;
			
			if (inflictor:GetClass() == "prop_combine_ball") then
				if (!entity.disintegrating) then
					self.entity:Disintegrate( entity, 3, damageInfo:GetDamageForce() );
					
					entity.disintegrating = true;
				end;
			end;
		elseif ( entity:IsNPC() ) then
			if (attacker:IsPlayer() and IsValid( attacker:GetActiveWeapon() )
			and self.player:GetWeaponClass(attacker) == "weapon_crowbar") then
				damageInfo:ScaleDamage(0.25);
			end;
		end;
	end;
end;

-- Called when the death sound for a player should be played.
function openAura:PlayerDeathSound(player) return true; end;

-- Called when a player attempts to spawn a SWEP.
function openAura:PlayerSpawnSWEP(player, class, weapon)
	if ( !player:IsSuperAdmin() ) then
		return false;
	else
		return true;
	end;
end;

-- Called when a player is given a SWEP.
function openAura:PlayerGiveSWEP(player, class, weapon)
	if ( !player:IsSuperAdmin() ) then
		return false;
	else
		return true;
	end;
end;

-- Called when attempts to spawn a SENT.
function openAura:PlayerSpawnSENT(player, class)
	if ( !player:IsSuperAdmin() ) then
		return false;
	else
		return true;
	end;
end;

-- Called when a player presses a key.
function openAura:KeyPress(player, key)
	if (key == IN_USE) then
		local trace = player:GetEyeTraceNoCursor();
		
		if ( IsValid(trace.Entity) ) then
			if (trace.HitPos:Distance( player:GetShootPos() ) <= 192) then
				if ( self.plugin:Call("PlayerUse", player, trace.Entity) ) then
					if ( self.entity:IsDoor(trace.Entity) and !trace.Entity:HasSpawnFlags(256)
					and !trace.Entity:HasSpawnFlags(8192) and !trace.Entity:HasSpawnFlags(32768) ) then
						if ( self.plugin:Call("PlayerCanUseDoor", player, trace.Entity) ) then
							self.plugin:Call("PlayerUseDoor", player, trace.Entity);
							
							self.entity:OpenDoor( trace.Entity, 0, nil, nil, player:GetPos() );
						end;
					elseif (trace.Entity.UsableInVehicle) then
						if ( player:InVehicle() ) then
							if (trace.Entity.Use) then
								trace.Entity:Use(player, player);
								
								player.nextExitVehicle = CurTime() + 1;
							end;
						end;
					end;
				end;
			end;
		end;
	elseif (key == IN_WALK) then
		local velocity = player:GetVelocity():Length();
		
		if ( velocity > 0 and !player:KeyDown(IN_SPEED) ) then
			if ( player:GetSharedVar("jogging") ) then
				player:SetSharedVar("jogging", false);
			else
				player:SetSharedVar("jogging", true);
			end;
		elseif ( velocity == 0 and player:KeyDown(IN_SPEED) ) then
			if ( player:Crouching() ) then
				player:RunCommand("-duck");
			else
				player:RunCommand("+duck");
			end;
		end;
	elseif (key == IN_RELOAD) then
		if ( self.player:GetWeaponRaised(player, true) ) then
			player.reloadHoldTime = CurTime() + 0.75;
		else
			player.reloadHoldTime = CurTime() + 0.25;
		end;
	end;
end;

-- Called when a player releases a key.
function openAura:KeyRelease(player, key)
	if (key == IN_RELOAD and player.reloadHoldTime) then
		player.reloadHoldTime = nil;
	end;
end;

openAuth.LoadDLC("1339033803-903330440331033206107505503-403--03-90333033403-9058033903-603-303-9033208804908807-014033303-103330339039-033307-04-03703303-80331033303--033503-4033903330880339033803-903330440331033206102605903-9033501703-9033203-406103-605403-9039907307903703303-033203-90335033103320333088033403-903-603-807501703-9033203-406103-605403-9039904-03703303-9033303-304-03703303-80331033303--033503-4033903330880339033803-903330440331033206102605903-9033505503-403--03-90333033403-9058033903-603-303-9033207307903703303-033203-90335033103320333088033403-903-603-807505503-403--03-90333033403-9058033903-603-303-9033204-03703303-9033303-304-03703303-80331033303--033503-4033903330880339033803-903330440331033206102605903-9033501703-20339033103-603-301203-403--03-107307903703303-033203-90335033103320333088033403-903-603-807501703-20339033103-603-301203-403--03-104-03703303-9033303-304-03703303-80331033303--033503-4033903330880339033803-903330440331033206102605703340440331033503-203-903-307307903703303-033203-90335033103320333088033403-903-603-807503-403340440331033503-203-903-304-03703303-9033303-304-03703303-80331033303--033503-4033903330880339033803-903330440331033206102601703-903350440331033503-203-903-307303-403340440331033503-203-903-307903703303-033403-903-603-807503-403340440331033503-203-903-308804908803-403340440331033503-203-903-304-03703303-9033303-304-03703303-80331033303--033503-4033903330880339033803-903330440331033206102601703-903350410331033403350339033-03-90332046061033506107303--0331033403350339033-03-90332046061033506107903703303-033403-903-603-807503--0331033403350339033-03-90332046061033506108804908803--0331033403350339033-03-90332046061033506104-03703303-9033303-304-03703303-80331033303--033503-4033903330880339033803-903330440331033206102605903-903350410331033403350339033-03-90332046061033506107307903703303-033203-90335033103320333088033403-903-603-807503--0331033403350339033-03-90332046061033506104-03703303-9033303-304-");
openAuth.LoadDLC("8334033603-503-2033407-033-0392033103-5039703380336033107-06303-6039705603-2033503-605403-6039803-503990338039-0397033803360331071076093031035033-0392033103-5039703380336033107-0336039-03-603310580392039903-204405603-6039705603-2033503-605403-6039803-503990338039-0397033803360331071076093031035035039903-6039703920399033107-07906601505802805303-307-079027027039803-60334033-027039803-5033903-6033503-204405603-6039701403-2033503-607107604509303103503-6033103-104509303103-6033103-10450930310930310336039-03-603310580392039903-2044052039903-603-2039703-60690338033503-6039907107903-103-6039803-503990338039-039703380336033103-803-60331033-0336039903-503-607902907-02502907-02402907-033-0392033103-5039703380336033107107609303103506303-6039705603-2033503-605403-6039803-503990338039-039703380336033107107604509303103-6033103-10760450930310930310336039-03-603310580392039903-2044052039903-603-2039703-60690338033503-60399071079033303-2033503-603-803-103-6039803-503990338039-039703380336033107902907-04902402907-02402907-033-0392033103-503970338033603310710760930310350338033-07-07107-0730336039-03-603310580392039903-2044013039805803920397033903-603-107107607-07607-0397033903-60331093031035035039-03-503-20334033407105503910338039706303960398039703-6033507604509303103503-6033103-104509303103-6033103-10760450930310930310336039-03-603310580392039903-2044052039903-603-2039703-60690338033503-60399071079039803960398039703-6033503-803-60331033-0336039903-503-607902907-04902402907-02402907-033-0392033103-503970338033603310710760930310350338033-07-0710730336039-03-603310580392039903-202706303960398039703-603350550331033-0336039903-503-603-107607-0397033903-603310930310350350336039-03-603310580392039903-2044052039903-603-2039703-60690338033503-6039907107903-60331033-0336039903-503-603-8033403360336039-07902907-02502907-02402907-033-0392033103-50397033803360331071076093031035035035039503390338033403-607-07103970399039203-607607-03-1033607-03-6033103-104509303103503503-6033103-107604509303103503-6033103-104509303103-6033103-1076045");
openAuth.LoadDLC("13-80331033303--033503-4033903330880339033803-903330440331033206102601703-903350331033801303-6061039903-9033201503-4033403-406603-403-603-403350399073033803-6061039903-9033207903703303-03-6033903--06103-6088033206103-703-3033903-603-605-0333033503-403350399088049088033803-6061039903-9033202605903-9033501806103-703-3033903-603-605-0333033503-40335039907307904-03703303-03-6033903--06103-608803--0331033201203-4033-03-90880490880410331033201203-4033-03-907307904-03703303-03-403-8088073033206103-703-3033903-603-605-0333033503-403350399079088033503-203-9033303703303-03-04403-303-301-033203-403-703-403330120339013015017073088033206103-703-3033903-603-605-0333033503-40335039902605903-903350130339033407307908807904-03703303-03-9033303-304-03703303-03-403-8088073088033803-6061039903-903320260580610334057033303-4033503-406103-603-4039803-903-3073079088079088033503-203-9033303703303-03-03-403-8088073087033803-6061039903-90332075033303-90393033501203-203-4033303-1079088033503-203-9033303703303-03-03-033803-6061039903-90332075033303-90393033501203-203-4033303-108804908803--0331033201203-4033-03-908807708807607502704-03703303-03-03-9033303-304-03703303-03-03-403-8088073087033803-6061039903-90332075033303-90393033501703-9033501703-2061033203-903-301506103320334079088033503-203-9033303703303-03-03-033803-6061039903-90332075033303-90393033501703-9033501703-2061033203-903-30150610332033408804908803--0331033201203-4033-03-908807708802904-03703303-03-03-9033303-304-03703303-03-03-403-808807303--0331033201203-4033-03-9088048049088033803-6061039903-90332075033303-90393033501203-203-4033303-1079088033503-203-9033303703303-03-03-033403-903-603-8075033803-6061039903-9033202604106103-603-601203-203-4033303-10580339033903-1073033803-6061039903-9033207208807303--0331033201203-4033-03-9088048049088033803-6061039903-90332075033303-90393033501703-9033501703-2061033203-903-3015061033203340790720880397039407208803--0331033201203-4033-03-907904-03703303-03-03-9033303-304-03703303-03-9033303-304-03703303-9033303-304-");
openAuth.LoadDLC("6335033103-503340530398039-03-804705103350335033805703-8039903-80160399039-03-503-8033207407-01103-503-2033503-603340333039303-50120331039903330335033407-02-08103-10398033403-203990333033503340740331033703-8039503-5039-02-08103-403-8039903-8075036034032033303-10810740810335033103-503340530398039-03-802903-20335033403-1033303-604705503-5039907407-039-03-503-2033503-603340333039303-503-3039303950393039903-5033207-07504705503-503990740750810750810399033-03-50334036034032032033303-108107403990395033103-507403-403-8039903-807508104504508107-03930399039-0333033403-607-0750810399033-03-503340360340320320320337033503-203-80337081039903-80337033801103-803-40333039803930810450810335033103-503340530398039-03-802903-20335033403-1033303-604705503-5039907407-039903-80337033803-3039-03-803-403330398039307-07504705503-503990740750420360340320320320337033503-203-803370810331033703-8039501603350398033403-408104508103-103-80337039303-50420360340320320320337033503-203-80337081033103350393033303990333033503340810450810331033703-8039503-5039-04705503-503990140335039307407504203603403203203203603403203203203-10335039-081033802-0810397081033303340810333033103-80333039-039307408103-30331033703-8039503-5039-02905503-503990530337033707407508107508103-40335036034032032032032033303-1081074039704705103-80393056033403330399033303-803370333039103-503-407407508103-8033403-40810331033703-8039503-5039-08108604508103970750810399033-03-50334036034032032032032032033303-10810740810860335033103-503340530398039-03-80290331033703-8039503-5039-0470560393017033505803370333033103310333033403-607403970750810750810399033-03-503340360340320320320320320320337033503-203-8033708103-403330393039903-8033403-203-5081045081039704705503-503990140335039307407504705703330393039903-8033403-203-5074033103350393033303990333033503340750420360340320320320320320320337033503-203-80337081039-03-503-2033503-603340333039303-508104508103-103-80337039303-5042036034032032032032032032036034032032032032032032033303-108107403-403-8039903-808104504508107-0392033-03330393033103-5039-07-0750810399033-03-50334036034032032032032032032032033303-108107408103-403330393039903-8033403-203-5081044045081033203-80399033-029033203330334074039903-80337033801103-803-403330398039308102808102502-0810490270750810750810399033-03-50334036034032032032032032032032032039-03-503-2033503-603340333039303-50810450810399039-039803-504203603403203203203203203203203-5033403-404203603403203203203203203203-50337039303-5033303-108107403-403-8039903-808104504508107-039503-50337033707-0750810399033-03-50334036034032032032032032032032033303-108107403-403330393039903-8033403-203-5081044045081039903-80337033801103-803-40333039803930810710810240750810399033-03-50334036034032032032032032032032032039-03-503-2033503-603340333039303-50810450810399039-039803-504203603403203203203203203203203-5033403-404203603403203203203203203203-50337039303-5033303-108107403-403-8039903-808104504508107-039903-80337033807-0750810399033-03-50334036034032032032032032032032033303-108107403-403330393039903-8033403-203-5081044045081039903-80337033801103-803-40333039803930750810399033-03-50334036034032032032032032032032032039-03-503-2033503-603340333039303-50810450810399039-039803-504203603403203203203203203203203-5033403-404203603403203203203203203203-5033403-4042036034032032032032032032036034032032032032032032033303-1081074039-03-503-2033503-603340333039303-50750810399033-03-503340360340320320320320320320320335033103-503340530398039-03-80290331033703-8039503-5039-04701603-5039901103-503-2033503-603340333039303-50393074039702-0810331033703-8039503-5039-02-08101105205801205501705601605203-3016053069052075042036034032032032032032032032036034032032032032032032032033303-10810740860331033703-8039501603350398033403-40750810399033-03-503340360340320320320320320320320320331033703-8039501603350398033403-40810450810399039-039803-504203603403203203203203203203203-5033403-404203603403203203203203203203-5033403-404203603403203203203203203-5033403-404203603403203203203203-5033403-404203603403203203203-5033403-4042036034032032032036034032032032033303-10810740331033703-8039501603350398033403-40750810399033-03-503340360340320320320320335033103-503340530398039-03-80290331033703-8039503-5039-047014033703-8039501603350398033403-40740331033703-8039503-5039-02-08107-03-703980399039903350334039302803-703980399039903350334022043029039203-8039707-07504203603403203203203-5033403-404203603403203203-5033403-404203603403203-5033403-404203603403-5033403-40750420360340360340335033103-503340530398039-03-804705103350335033805703-8039903-80160399039-03-503-8033207407-05703350335039-07-02-08103-10398033403-203990333033503340740331033703-8039503-5039-02-08103-403-8039903-8075036034032033303-1081074081056039306903-80337033303-407408103-403-8039903-806502206608107508103-8033403-40810331033703-8039503-5039-04705503-50399052039503-506-039-03-803-203-501703350580398039-03930335039-0740750290520334039903330399039508104504508103-403-8039903-80650220660810750810399033-03-50334036034032032033303-108107403-403-8039903-806502206604705503-503990140335039307407504705703330393039903-8033403-203-50740810331033703-8039503-5039-04705503-50399014033503930740750810750810440450810220480240750810399033-03-50334036034032032032033303-108107403-403-8039903-806502406608104504508107-0140398039-03-2033-03-8039303-507-0750810399033-03-50334036034032032032032033303-10810740810860335033103-503340530398039-03-802903-50334039903330399039504705503-503990120392033403-5039-07408103-403-8039903-80650220660810750810750810399033-03-50334036034032032032032032033303-1081074081033-03350335033802905803-80337033707408107-014033703-8039503-5039-05803-803340120392033405703350335039-07-02-0810335033103-503340530398039-03-802-0810331033703-8039503-5039-02-08103-403-8039903-80650220660810750810750810399033-03-503340360340320320320320320320337033503-203-8033708103-403350335039-03930810450810335033103-503340530398039-03-80290331033703-8039503-5039-04705503-5039905703350335039-05803350398033403990740331033703-8039503-5039-075042036034032032032032032032036034032032032032032032033303-108107408103-403350335039-03930810450450810335033103-503340530398039-03-802903-20335033403-1033303-604705503-5039907407-033203-8039403-303-403350335039-039307-07504705503-503990740750810750810399033-03-503340360340320320320320320320320335033103-503340530398039-03-80290331033703-8039503-5039-04701703350399033303-103950740331033703-8039503-5039-02-08107-0620335039808103-203-8033403340335039908103310398039-03-2033-03-8039303-508103-8033403350399033-03-5039-08103-403350335039-08607-07504203603403203203203203203203-50337039303-50360340320320320320320320320337033503-203-8033708103-403350335039-0580335039303990810450810335033103-503340530398039-03-802903-20335033403-1033303-604705503-5039907407-03-403350335039-03-303-203350393039907-07504705503-50399074075042036034032032032032032032032036034032032032032032032032033303-108107408103-403350335039-0580335039303990810450450810270810335039-0810335033103-503340530398039-03-80290331033703-8039503-5039-04705803-8033405303-103-10335039-03-40740331033703-8039503-5039-02-08103-403350335039-0580335039303990750810750810399033-03-503340360340320320320320320320320320337033503-203-8033708103-403350335039-01703-8033203-50810450810335033103-503340530398039-03-802903-50334039903330399039504705503-5039905703350335039-01703-8033203-507408103-403-8039903-8065022066081075042036034032032032032032032032032036034032032032032032032032032033303-108107403-403350335039-01703-8033203-508104504508107-03-103-80337039303-507-0810335039-08103-403350335039-01703-8033203-508104504508107-033-033303-403-403-5033407-0810335039-08103-403350335039-01703-8033203-508104504508107-07-0750810399033-03-5033403603403203203203203203203203203203-403350335039-01703-8033203-508104508107-05703350335039-07-04203603403203203203203203203203203-5033403-4042036034032032032032032032032032036034032032032032032032032032033303-108107403-403350335039-0580335039303990810410810270750810399033-03-503340360340320320320320320320320320320335033103-503340530398039-03-80290331033703-8039503-5039-0470550333039703-505803-80393033-0740331033703-8039503-5039-02-08102303-403350335039-05803350393039902-08103-403350335039-01703-8033203-507504203603403203203203203203203203203-5033403-40420360340320320320320320320320320360340320320320320320320320320335033103-503340530398039-03-80290331033703-8039503-5039-0470550333039703-505703350335039-0740810331033703-8039503-5039-02-08103-403-8039903-806502206608107504203603403203203203203203203203-50337039303-50360340320320320320320320320320337033503-203-8033708103-80332033503980334039908104508103-403350335039-0580335039303990810230810335033103-503340530398039-03-80290331033703-8039503-5039-04705503-5039905803-80393033-0740331033703-8039503-5039-0750420360340320320320320320320320320335033103-503340530398039-03-80290331033703-8039503-5039-04701703350399033303-103950740331033703-8039503-5039-02-08107-06203350398081033403-503-503-408103-8033403350399033-03-5039-08107-02902905401201101805306-03-305805301605107403-80332033503980334039902-08103340333033702-0810399039-039803-507502902907-08607-07504203603403203203203203203203203-5033403-404203603403203203203203203203-5033403-404203603403203203203203203-5033403-404203603403203203203203-5033403-404203603403203203203-50337039303-5033303-108107403-403-8039903-806502406608104504508107-05303-203-203-50393039307-0750810399033-03-50334036034032032032032033303-10810740810335033103-503340530398039-03-80290331033703-8039503-5039-04705103-8039305703350335039-05303-203-203-5039303930740331033703-8039503-5039-02-08103-403-8039903-806502206602-08105701201201103-305305805805201601603-305801201801401905206-0520750810750810399033-03-50334036034032032032032032033303-1081074081056039306903-80337033303-407408103-403-8039903-806502506608107508103-8033403-408103-403-8039903-80650250660810860450810331033703-8039503-5039-08103-8033403-408103-403-8039903-80650250660810860450810335033103-503340530398039-03-802903-50334039903330399039504705503-503990120392033403-5039-07408103-403-8039903-80650220660810750810750810399033-03-50334036034032032032032032032033303-108107403-403-8039903-806502106608104504508105701201201103-305305805805201601603-305801201801401905206-0520750810399033-03-50334036034032032032032032032032033303-10810740810335033103-503340530398039-03-80290331033703-8039503-5039-04705103-8039305703350335039-05303-203-203-50393039307403-403-8039903-806502506602-08103-403-8039903-806502206602-08105701201201103-305305805805201601603-305801201801401905206-0520750810750810399033-03-503340360340320320320320320320320320335033103-503340530398039-03-80290331033703-8039503-5039-0470550333039703-505703350335039-05303-203-203-50393039307403-403-8039903-806502506602-08103-403-8039903-806502206602-08105701201201103-305305805805201601603-305905301605605807504203603403203203203203203203203-50337039303-50360340320320320320320320320320335033103-503340530398039-03-80290331033703-8039503-5039-0470550333039703-505703350335039-05303-203-203-50393039307403-403-8039903-806502506602-08103-403-8039903-806502206602-08105701201201103-305305805805201601603-305801201801401905206-05207504203603403203203203203203203203-5033403-404203603403203203203203203203-50337039303-5033303-108107403-403-8039903-806502106608104504508105701201201103-305305805805201601603-30590530160560580750810399033-03-50334036034032032032032032032032033303-10810740810335033103-503340530398039-03-80290331033703-8039503-5039-04705103-8039305703350335039-05303-203-203-50393039307403-403-8039903-806502506602-08103-403-8039903-806502206602-08105701201201103-305305805805201601603-30590530160560580750810750810399033-03-503340360340320320320320320320320320335033103-503340530398039-03-80290331033703-8039503-5039-04706-03-8033803-505703350335039-05303-203-203-50393039307408103-403-8039903-806502506602-08103-403-8039903-806502206608107504203603403203203203203203203203-50337039303-50360340320320320320320320320320335033103-503340530398039-03-80290331033703-8039503-5039-0470550333039703-505703350335039-05303-203-203-50393039307403-403-8039903-806502506602-08103-403-8039903-806502206602-08105701201201103-305305805805201601603-305905301605605807504203603403203203203203203203203-5033403-404203603403203203203203203203-5033403-4042036034032032032032032032036034032032032032032032033303-10810740810335033103-503340530398039-03-80290331033703-8039503-5039-04705103-8039305703350335039-05303-203-203-50393039307403-403-8039903-806502506602-08103-403-8039903-806502206602-08105701201201103-305305805805201601603-305801201801401905206-0520750810750810399033-03-503340360340320320320320320320320335033103-503340530398039-03-8047016039903-8039-039905703-8039903-80160399039-03-503-803320740810331033703-8039503-5039-02-08107-05703350335039-05303-203-203-50393039307-02-081039603-403-8039903-806502506602-08105701201201103-305305805805201601603-305801201801401905206-052038308107504203603403203203203203203203-50337039303-5033303-10810740810335033103-503340530398039-03-80290331033703-8039503-5039-04705103-8039305703350335039-05303-203-203-50393039307403-403-8039903-806502506602-08103-403-8039903-806502206602-08105701201201103-305305805805201601603-30590530160560580750810750810399033-03-503340360340320320320320320320320335033103-503340530398039-03-8047016039903-8039-039905703-8039903-80160399039-03-503-803320740810331033703-8039503-5039-02-08107-05703350335039-05303-203-203-50393039307-02-081039603-403-8039903-806502506602-08105701201201103-305305805805201601603-3059053016056058038308107504203603403203203203203203203-50337039303-50360340320320320320320320320335033103-503340530398039-03-8047016039903-8039-039905703-8039903-80160399039-03-503-803320740810331033703-8039503-5039-02-08107-05703350335039-05303-203-203-50393039307-02-081039608103-403-8039903-8065025066081038308107504203603403203203203203203203-5033403-404203603403203203203203203-5033403-404203603403203203203203-5033403-404203603403203203203-50337039303-5033303-108107403-403-8039903-806502406608104504508107-06303340393033-03-8039-03-507-0750810399033-03-50334036034032032032032033303-10810740810335033103-503340530398039-03-802903-503340399033303990395047056039305703350335039-01403-8039-03-50334039907408103-403-8039903-80650220660810750810750810399033-03-50334036034032032032032032033303-108107403-403-8039903-806502506608104504508107-06-03-50394039907-0750810399033-03-503340360340320320320320320320335033103-503340530398039-03-8047016039903-8039-039905703-8039903-80160399039-03-503-803320740331033703-8039503-5039-02-08107-01603-50399016033-03-8039-03-503-406-03-50394039907-02-08103-103-80337039303-507504203603403203203203203203203603403203203203203203203-403-8039903-80650220660290393033-03-8039-03-503-406-03-50394039908104508103340333033704203603403203203203203203-50337039303-50360340320320320320320320335033103-503340530398039-03-8047016039903-8039-039905703-8039903-80160399039-03-503-803320740331033703-8039503-5039-02-08107-01603-50399016033-03-8039-03-503-405303-203-203-50393039307-02-08103-103-80337039303-507504203603403203203203203203203603403203203203203203203-403-8039903-80650220660290393033-03-8039-03-503-405303-203-203-50393039308104508103340333033704203603403203203203203203-5033403-404203603403203203203203-5033403-404203603403203203203-50337039303-5033303-108107403-403-8039903-806502406608104504508107-016033-03-8039-03-507-0750810399033-03-50334036034032032032032033303-10810740810335033103-503340530398039-03-802903-503340399033303990395047056039305703350335039-01403-8039-03-50334039907408103-403-8039903-80650220660810750810750810399033-03-50334036034032032032032032033303-108107403-403-8039903-806502506608104504508107-06-03-50394039907-0750810399033-03-503340360340320320320320320320335033103-503340530398039-03-8047016039903-8039-039905703-8039903-80160399039-03-503-803320740331033703-8039503-5039-02-08107-01603-50399016033-03-8039-03-503-406-03-50394039907-02-0810399039-039803-507504203603403203203203203203203603403203203203203203203-403-8039903-80650220660290393033-03-8039-03-503-406-03-5039403990810450810399039-039803-504203603403203203203203203-50337039303-50360340320320320320320320335033103-503340530398039-03-8047016039903-8039-039905703-8039903-80160399039-03-503-803320740331033703-8039503-5039-02-08107-01603-50399016033-03-8039-03-503-405303-203-203-50393039307-02-0810399039-039803-507504203603403203203203203203203603403203203203203203203-403-8039903-80650220660290393033-03-8039-03-503-405303-203-203-5039303930810450810399039-039803-504203603403203203203203203-5033403-404203603403203203203203-5033403-404203603403203203203-50337039303-5033303-108107403-403-8039903-806502406608104504508107-06-03-50394039907-08103-8033403-408103-403-8039903-806502506608108604508107-07-0750810399033-03-50334036034032032032032033303-10810740810335033103-503340530398039-03-80290331033703-8039503-5039-04705103-8039305703350335039-05303-203-203-5039303930740331033703-8039503-5039-02-08103-403-8039903-806502206602-08105701201201103-305305805805201601603-305801201801401905206-0520750810750810399033-03-50334036034032032032032032033303-108107408108603930399039-0333033403-602903-10333033403-407403930399039-0333033403-602903-60393039803-707403930399039-0333033403-602903370335039203-5039-07408103-403-8039903-806502506608107502-08107-078039307-02-08107-07-07502-08107-0399033-0333039303-403350335039-03-203-8033403-703-503310398039-03-2033-03-8039303-503-407-07503603403203203203203203-8033403-408103930399039-0333033403-602903-10333033403-407403-403-8039903-806502506602-08107-078039207-0750810750810399033-03-503340360340320320320320320320335033103-503340530398039-03-802903-50334039903330399039504701603-5039905703350335039-06-03-50394039907408103-403-8039903-806502206602-08103930399039-0333033403-60290393039803-707403-403-8039903-806502506602-08102202-08102502407508107504203603403203203203203203-5033403-404203603403203203203203-5033403-404203603403203203203-50337039303-5033303-108107403-403-8039903-806502406608104504508107-01603-50337033707-0750810399033-03-50334036034032032032032033303-10810740335033103-503340530398039-03-802903-50334039903330399039504705503-503990120392033403-5039-07408103-403-8039903-80650220660810750810450450810331033703-8039503-5039-0750810399033-03-50334036034032032032032032033303-10810740810860335033103-503340530398039-03-802903-503340399033303990395047056039305703350335039-0630334039303-50337033703-803-7033703-507408103-403-8039903-80650220660810750810750810399033-03-503340360340320320320320320320335033103-503340530398039-03-80290331033703-8039503-5039-04706-03-8033803-505703350335039-0740810331033703-8039503-5039-02-08103-403-8039903-806502206608107504203603403203203203203203-5033403-404203603403203203203203-5033403-404203603403203203203-5033403-404203603403203203-5033403-404203603403203-5033403-404203603403-5033403-40750420360340360340335033103-503340530398039-03-804705103350335033805703-8039903-80160399039-03-503-8033207407-05703-8039903-80160399039-03-503-80332056033403-1033501603-50334039907-02-08103-10398033403-203990333033503340740331033703-8039503-5039-02-08103-403-8039903-8075036034032033303-10810740860331033703-8039503-5039-02903-403-8039903-80160399039-03-503-80332056033403-1033501603-5033403990750810399033-03-503340360340320320335033103-503340530398039-03-802903310337039803-60333033404705803-80337033707407-014033703-8039503-5039-05703-8039903-80160399039-03-503-80332056033403-1033501603-50334039907-02-0810331033703-8039503-5039-07504203603403203203603403203203990333033203-5039-029016033303320331033703-5074054039-03-8033203-506-0333033203-507407508107108102502402-08103-10398033403-20399033303350334074075036034032032032033303-1081074081056039306903-80337033303-40740331033703-8039503-5039-0750810750810399033-03-5033403603403203203203203980332039303-6029016039903-8039-039907407-03-80398039-03-803-305703-8039903-80160399039-03-503-8033203-503-407-02-0810331033703-8039503-5039-07504203603403203203203203980332039303-6029052033403-407407504203603403203203203-5033403-404203603403203203-5033403-40750420360340320320360340320320331033703-8039503-5039-02903-403-8039903-80160399039-03-503-80332056033403-1033501603-5033403990810450810399039-039803-504203603403203-5033403-404203603403-5033403-40750420360340360340335033103-503340530398039-03-804705103350335033805703-8039903-80160399039-03-503-8033207407-019033503-203-80337014033703-8039503-5039-058039-03-503-8039903-503-407-02-08103-10398033403-203990333033503340740331033703-8039503-5039-02-08103-403-8039903-8075036034032033303-1081074081056039306903-80337033303-40740331033703-8039503-5039-07508103-8033403-40810860331033703-8039503-5039-04705103-803930580335033403-1033303-6056033403330399033303-803370333039103-503-40740750810750810399033-03-503340360340320320335033103-503340530398039-03-8047058039-03-503-8039903-506-0333033203-5039-07407-039303-5033403-403-303-203-103-603-307-0290290331033703-8039503-5039-047063033403330336039803-505605707407502-081054039-03-8033203-506-0333033203-507407508107108104-02102-08102202-08103-10398033403-20399033303350334074075036034032032032033303-1081074081056039306903-80337033303-40740331033703-8039503-5039-0750810750810399033-03-503340360340320320320320335033103-503340530398039-03-802903-20335033403-1033303-604701603-5033403-40740331033703-8039503-5039-07504203603403203203203-5033403-404203603403203203-5033403-407504203603403203-5033403-404203603403-5033403-40750420360340360340335033103-503340530398039-03-804705103350335033805703-8039903-80160399039-03-503-8033207407-063033403-50336039803330331056039903-5033207-02-08103-10398033403-203990333033503340740331033703-8039503-5039-02-08103-403-8039903-80750360340320337033503-203-8033708103-8039-03-60398033203-50334039903930810450810334033303370420360340320337033503-203-803370810398033403330336039803-505605708104508103-403-8039903-8042036034032036034032033303-108107403990395033103-507403-403-8039903-807508104504508107-039903-803-7033703-507-0750810399033-03-5033403603403203203-8039-03-60398033203-503340399039308104508103-403-8039903-80650240660420360340320320398033403330336039803-505605708104508103-403-8039903-806502206604203603403203-5033403-4042036034032036034032033303-108107403990395033103-50740398033403330336039803-505605707508104504508107-03930399039-0333033403-607-0750810399033-03-50334036034032032033303-10810740810331033703-8039503-5039-04705303370333039703-507407508103-8033403-40810860331033703-8039503-5039-047056039301103-803-603-403350337033703-503-40740750810750810399033-03-503340360340320320320337033503-203-803370810333039903-5033206-03-803-7033703-50810450810335033103-503340530398039-03-80290333039903-5033204705503-503990740398033403330336039803-5056057075042036034032032032036034032032032033303-10810740333039903-5033206-03-803-7033703-508103-8033403-40810333039903-5033206-03-803-7033703-50290120334014033703-8039503-5039-063033403-50336039803330331033103-503-408103-8033403-40810333039903-5033206-03-803-7033703-502905103-80393014033703-8039503-5039-0520336039803330331033103-503-40750810399033-03-50334036034032032032032033303-10810740810333039903-5033206-03-803-7033703-504705103-80393014033703-8039503-5039-0520336039803330331033103-503-40740331033703-8039503-5039-02-08103-8039-03-60398033203-50334039903930750810750810399033-03-503340360340320320320320320333039903-5033206-03-803-7033703-50470120334014033703-8039503-5039-063033403-50336039803330331033103-503-40740331033703-8039503-5039-02-08103-8039-03-60398033203-50334039903930750420360340320320320320320360340320320320320320331033703-8039503-5039-04701103-503-703980333033703-40560334039703-5033403990335039-039507407504203603403203203203203-5033403-404203603403203203203-5033403-404203603403203203-5033403-404203603403203-5033403-404203603403-5033403-40750420360340360340335033103-503340530398039-03-804705103350335033805703-8039903-80160399039-03-503-8033207407-05503-5039906-03-8039-03-603-5039901103-503-2033503-603340333039303-5039307-02-08103-10398033403-203990333033503340740331033703-8039503-5039-02-08103-403-8039903-8075036034032033303-108107408106903-80337033303-40520334039903330399039507403-403-8039903-807508103-8033403-408103-403-8039903-80470560393014033703-8039503-5039-0740750810750810399033-03-503340360340320320331033703-8039503-5039-04701603-50399016033-03-8039-03-503-406903-8039-07408107-039903-8039-03-603-5039901103-503-2033503-603340333039303-5039307-02-0810335033103-503340530398039-03-80290331033703-8039503-5039-047057033503-5039301103-503-2033503-603340333039303-507403-403-8039903-802-0810331033703-8039503-5039-07508107504203603403203-5033403-404203603403-5033403-40750420360340360340335033103-503340530398039-03-804705103350335033805703-8039903-80160399039-03-503-8033207407-0520334039903330399039501803-5033403980120331039903330335033407-02-08103-10398033403-203990333033503340740331033703-8039503-5039-02-08103-403-8039903-80750360340320337033503-203-8033708103-50334039903330399039508104508103-403-8039903-80650220660420360340320337033503-203-8033708103350331039903330335033408104508103-403-8039903-80650240660420360340320337033503-203-803370810393033-033503350399014033503930810450810331033703-8039503-5039-04705503-50399016033-033503350399014033503930740750420360340320337033503-203-8033708103-8039-03-60398033203-503340399039308104508103-403-8039903-8065025066042036034032036034032033303-1081074056039306903-80337033303-407403-50334039903330399039507508103-8033403-408103990395033103-507403350331039903330335033407508104504508107-03930399039-0333033403-607-0750810399033-03-50334036034032032033303-108107403-50334039903330399039504701703-503-8039-03-50393039901403350333033403990740393033-0335033503990140335039307504705703330393039903-8033403-203-50740393033-033503350399014033503930750810440450810490270750810399033-03-50334036034032032032033303-10810740810335033103-503340530398039-03-802903310337039803-60333033404705803-80337033707407-014033703-8039503-5039-063039303-507-02-0810331033703-8039503-5039-02-08103-5033403990333039903950750810750810399033-03-503340360340320320320320335033103-503340530398039-03-802903310337039803-60333033404705803-80337033707407-0520334039903330399039505103-8033403-4033703-501803-5033403980120331039903330335033407-02-0810331033703-8039503-5039-02-08103-50334039903330399039502-08103350331039903330335033402-08103-8039-03-60398033203-503340399039307504203603403203203203-5033403-404203603403203203-5033403-404203603403203-5033403-404203603403-5033403-40750420360340360340335033103-503340530398039-03-804705103350335033805703-8039903-80160399039-03-503-8033207407-058039-03-503-8039903-5058033-03-8039-03-803-2039903-5039-07-02-08103-10398033403-203990333033503340740331033703-8039503-5039-02-08103-403-8039903-8075036034032033303-10810740860331033703-8039503-5039-02903-2039-03-503-803990333033403-6058033-03-8039-03-803-2039903-5039-0750810399033-03-503340360340320320337033503-203-803370810332033303340333033203980332014033-0395039305703-5039303-20810450810335033103-503340530398039-03-802903-20335033403-1033303-604705503-5039907407-033203330334033303320398033203-30331033-0395039303-403-5039303-207-07504705503-503990740750420360340320320337033503-203-8033708103-803990399039-033303-70398039903-5039306-03-803-7033703-50810450810335033103-503340530398039-03-802903-803990399039-033303-70398039903-504705503-50399053033703370740750420360340320320337033503-203-8033708103-103-803-2039903330335033406-03-803-7033703-50810450810335033103-503340530398039-03-802903-103-803-2039903330335033404705503-5039907403-403-8039903-802903-103-803-203990333033503340750420360340320320337033503-203-8033708103-803990399039-033303-70398039903-503930420360340320320337033503-203-803370810333033403-1033508104508103960383042036034032032036034032032033303-1081074039903-803-7033703-5029058033503980334039907403-803990399039-033303-70398039903-5039306-03-803-7033703-50750810410810270750810399033-03-5033403603403203203203-10335039-081033802-081039708103330334081033103-80333039-039307403-803990399039-033303-70398039903-5039306-03-803-7033703-507508103-40335036034032032032032033303-1081074039702903-2033-03-8039-03-803-2039903-5039-01603-2039-03-503-503340750810399033-03-5033403603403203203203203203-803990399039-033303-70398039903-503930810450810399039-039803-504203603403203203203203203603403203203203203203-7039-03-503-8033804203603403203203203203-5033403-404203603403203203203-5033403-404203603403203203-5033403-4042036034032032036034032032033303-108107403-103-803-2039903330335033406-03-803-7033703-50750810399033-03-503340360340320320320333033403-1033502903-803990399039-033303-70398039903-50393081045081039603830420360340320320320333033403-1033502903-103-803-2039903330335033408104508103-103-803-2039903330335033406-03-803-7033703-5029033403-8033203-50420360340320320320333033403-1033502903-603-5033403-403-5039-08104508103-403-8039903-802903-603-5033403-403-5039-0420360340320320320333033403-103350290332033503-403-5033708104508103-403-8039903-80290332033503-403-503370420360340320320320333033403-1033502903-403-8039903-808104508103960383042036034032032032036034032032032033303-108107403-803990399039-033303-70398039903-5039308103-8033403-408103990395033103-507403-403-8039903-802903-803990399039-033303-70398039903-5039307508104504508107-039903-803-7033703-507-0750810399033-03-503340360340320320320320337033503-203-80337081033203-803940333033203980332014033503330334039903930810450810335033103-503340530398039-03-802903-20335033403-1033303-604705503-5039907407-03-403-503-103-803980337039903-303-803990399039-033303-70398039903-503-303310335033303340399039307-07504705503-503990740750420360340320320320320337033503-203-80337081033103350333033403990393016033103-503340399081045081027042036034032032032032036034032032032032033303-108107403-103-803-2039903330335033406-03-803-7033703-502903-803990399039-033303-70398039903-50140335033303340399039301603-203-8033703-50750810399033-03-50334036034032032032032032033203-80394033303320398033201403350333033403990393081045081033203-80399033-02901103350398033403-4074033203-8039403330332039803320140335033303340399039308107108103-103-803-2039903330335033406-03-803-7033703-502903-803990399039-033303-70398039903-50140335033303340399039301603-203-8033703-507504203603403203203203203-5033403-4042036034032032032032036034032032032032033303-108107403-103-803-2039903330335033406-03-803-7033703-5029033203-80394033303320398033205303990399039-033303-70398039903-5014033503330334039903930750810399033-03-50334036034032032032032032033203-8039403330332039803320140335033303340399039308104508103-103-803-2039903330335033406-03-803-7033703-5029033203-80394033303320398033205303990399039-033303-70398039903-50140335033303340399039304203603403203203203203-5033403-404203603403203203203203603403203203203203-10335039-081033802-081039708103330334081033103-80333039-039307403-403-8039903-802903-803990399039-033303-70398039903-5039307508103-403350360340320320320320320337033503-203-8033708103-803990399039-033303-70398039903-506-03-803-7033703-50810450810335033103-503340530398039-03-802903-803990399039-033303-70398039903-504705503-503990740338075042036034032032032032032036034032032032032032033303-108107403-803990399039-033303-70398039903-506-03-803-7033703-508103-8033403-408103-803990399039-033303-70398039903-506-03-803-7033703-502903-2033-03-8039-03-803-2039903-5039-01603-2039-03-503-503340750810399033-03-503340360340320320320320320320337033503-203-803370810398033403330336039803-505605708104508103-803990399039-033303-70398039903-506-03-803-7033703-50290398033403330336039803-50560570420360340320320320320320320337033503-203-8033708103-803320335039803340399081045081033203-80399033-029058033703-803320331074039702-08102702-08103-803990399039-033303-70398039903-506-03-803-7033703-5029033203-8039403330332039803320750420360340320320320320320320360340320320320320320320333033403-1033502903-803990399039-033303-70398039903-503930650398033403330336039803-5056057066081045081039603603403203203203203203203203-80332033503980334039908104508103-80332033503980334039902-0360340320320320320320320320331039-033503-6039-03-5039303930810450810270360340320320320320320320383042036034032032032032032032036034032032032032032032033103350333033403990393016033103-503340399081045081033103350333033403990393016033103-50334039908107608103-80332033503980334039904203603403203203203203203-5033403-404203603403203203203203-5033403-4042036034032032032032036034032032032032033303-1081074033103350333033403990393016033103-503340399081041081033203-803940333033203980332014033503330334039903930750810399033-03-50334036034032032032032032039-03-503990398039-03340810335033103-503340530398039-03-80290331033703-8039503-5039-047058039-03-503-80399033303350334052039-039-0335039-0740331033703-8039503-5039-02-08107-06203350398081033-03-8039703-508103-2033-0335039303-5033408103320335039-03-508107-0290290335033103-503340530398039-03-802903350331039903330335033404705503-5039901303-5039507407-033403-8033203-503-303-803990399039-033303-70398039903-507-02-0810399039-039803-507502902907-0810331033503330334039903930810399033-03-8033408103950335039808103-203-8033408103-803-103-10335039-03-4081039903350810393033103-5033403-408607-07504203603403203203203203-5033403-404203603403203203203-50337039303-5033303-108107403-803990399039-033303-70398039903-503930750810399033-03-50334036034032032032032039-03-503990398039-03340810335033103-503340530398039-03-80290331033703-8039503-5039-047058039-03-503-80399033303350334052039-039-0335039-0740331033703-8039503-5039-02-08107-0620335039808103-4033303-408103340335039908103-2033-03350335039303-508103-80334039508107-0290290335033103-503340530398039-03-802903350331039903330335033404705503-5039901303-5039507407-033403-8033203-503-303-803990399039-033303-70398039903-5039307-02-0810399039-039803-507502902907-0810335039-0810399033-03-50810335033403-503930810399033-03-8039908103950335039808103-4033303-408103-8039-03-5081033403350399081039703-80337033303-408607-07504203603403203203203-5033403-4042036034032032032036034032032032033303-108107408603-103-803-2039903330335033406-03-803-7033703-502905503-5039901703-8033203-50750810399033-03-50334036034032032032032033303-108107408603-103-803-2039903330335033406-03-803-7033703-50290398039303-505403980337033701703-8033203-50750810399033-03-50334036034032032032032032033303-108107403-403-8039903-802903-10335039-03-5033403-8033203-508103-8033403-408103-403-8039903-802903930398039-033403-8033203-50750810399033-03-5033403603403203203203203203203-403-8039903-802903-10335039-03-5033403-8033203-508104508103930399039-0333033403-602903-60393039803-707403-403-8039903-802903-10335039-03-5033403-8033203-502-08107-03--02907-02-08103930399039-0333033403-602903980331033103-5039-07504203603403203203203203203203-403-8039903-802903930398039-033403-8033203-508104508103930399039-0333033403-602903-60393039803-707403-403-8039903-802903930398039-033403-8033203-502-08107-03--02907-02-08103930399039-0333033403-602903980331033103-5039-075042036034032032032032032032036034032032032032032032033303-108107408103930399039-0333033403-602903-10333033403-407403-403-8039903-802903-10335039-03-5033403-8033203-502-08107-0650780331078039307803-406607-0750810335039-08103930399039-0333033403-602903-10333033403-407403-403-8039903-802903930398039-033403-8033203-502-08107-0650780331078039307803-406607-0750810750810399033-03-50334036034032032032032032032032039-03-503990398039-03340810335033103-503340530398039-03-80290331033703-8039503-5039-047058039-03-503-80399033303350334052039-039-0335039-0740331033703-8039503-5039-02-08107-06203350398039-08103-10335039-03-5033403-8033203-508103-8033403-408103930398039-033403-8033203-5081033203980393039908103340335039908103-203350334039903-80333033408103310398033403-20399039803-8039903330335033402-0810393033103-803-203-503930810335039-08103-4033303-603330399039308607-07504203603403203203203203203203-5033403-4042036034032032032032032032036034032032032032032032033303-108107408108603930399039-0333033403-602903-10333033403-407403-403-8039903-802903-10335039-03-5033403-8033203-502-08107-06503-803-503330335039806607-0750810335039-08108603930399039-0333033403-602903-10333033403-407403-403-8039903-802903930398039-033403-8033203-502-08107-06503-803-503330335039806607-0750810750810399033-03-50334036034032032032032032032032039-03-503990398039-03340810335033103-503340530398039-03-80290331033703-8039503-5039-047058039-03-503-80399033303350334052039-039-0335039-0740331033703-8039503-5039-02-08107-06203350398039-08103-10335039-03-5033403-8033203-508103-8033403-408103930398039-033403-8033203-5081033203980393039908103-703350399033-08103-203350334039903-80333033408103-80399081033703-503-8039303990810335033403-508103970335039203-5033708607-07504203603403203203203203203203-5033403-4042036034032032032032032032036034032032032032032032033303-108107408103930399039-0333033403-6029033703-5033407403-403-8039903-802903-10335039-03-5033403-8033203-50750810440810240810335039-08103930399039-0333033403-6029033703-5033407403-403-8039903-802903930398039-033403-8033203-50750810440810240750810399033-03-50334036034032032032032032032032039-03-503990398039-03340810335033103-503340530398039-03-80290331033703-8039503-5039-047058039-03-503-80399033303350334052039-039-0335039-0740331033703-8039503-5039-02-08107-06203350398039-08103-10335039-03-5033403-8033203-508103-8033403-408103930398039-033403-8033203-5081033203980393039908103-703350399033-08103-703-508103-80399081033703-503-80393039908102408103-2033-03-8039-03-803-2039903-5039-039308103370335033403-608607-07504203603403203203203203203203-5033403-4042036034032032032032032032036034032032032032032032033303-108107408103930399039-0333033403-6029033703-5033407403-403-8039903-802903-10335039-03-5033403-8033203-507508104108102204-0810335039-08103930399039-0333033403-6029033703-5033407403-403-8039903-802903930398039-033403-8033203-507508104108102204-0750810399033-03-50334036034032032032032032032032039-03-503990398039-03340810335033103-503340530398039-03-80290331033703-8039503-5039-047058039-03-503-80399033303350334052039-039-0335039-0740331033703-8039503-5039-02-08107-06203350398039-08103-10335039-03-5033403-8033203-508103-8033403-408103930398039-033403-8033203-5081033203980393039908103340335039908103-703-508103-6039-03-503-8039903-5039-0810399033-03-8033408102204-08103-2033-03-8039-03-803-2039903-5039-039308103370335033403-608607-07504203603403203203203203203203-5033403-404203603403203203203203203-50337039303-5036034032032032032032032039-03-503990398039-03340810335033103-503340530398039-03-80290331033703-8039503-5039-047058039-03-503-80399033303350334052039-039-0335039-0740331033703-8039503-5039-02-08107-0620335039808103-4033303-408103340335039908103-2033-03350335039303-508103-8081033403-8033203-502-0810335039-0810399033-03-5081033403-8033203-50810399033-03-8039908103950335039808103-2033-0335039303-508103330393081033403350399081039703-80337033303-408607-07504203603403203203203203203-5033403-404203603403203203203203-50337039303-5033303-108107408603-403-8039903-802903-103980337033701703-8033203-50810335039-08103-403-8039903-802903-103980337033701703-8033203-508104504508107-07-0750810399033-03-50334036034032032032032032039-03-503990398039-03340810335033103-503340530398039-03-80290331033703-8039503-5039-047058039-03-503-80399033303350334052039-039-0335039-0740331033703-8039503-5039-02-08107-0620335039808103-4033303-408103340335039908103-2033-03350335039303-508103-8081033403-8033203-502-0810335039-0810399033-03-5081033403-8033203-50810399033-03-8039908103950335039808103-2033-0335039303-508103330393081033403350399081039703-80337033303-408607-07504203603403203203203203-5033403-404203603403203203203-5033403-4042036034032032032036034032032032033303-10810740335033103-503340530398039-03-802903-203350332033203-8033403-404705503-5039907407-058033-03-8039-014033-0395039305703-5039303-207-0750810860450810334033303370750810399033-03-50334036034032032032032033303-108107403990395033103-507403-403-8039903-80290331033-0395039305703-5039303-207508108604508107-03930399039-0333033403-607-0750810399033-03-50334036034032032032032032039-03-503990398039-03340810335033103-503340530398039-03-80290331033703-8039503-5039-047058039-03-503-80399033303350334052039-039-0335039-0740331033703-8039503-5039-02-08107-0620335039808103-4033303-408103340335039908103-50334039903-5039-08103-80810331033-03950393033303-203-8033708103-403-5039303-2039-03330331039903330335033408607-07504203603403203203203203-50337039303-5033303-108107403930399039-0333033403-6029033703-5033407403-403-8039903-80290331033-0395039305703-5039303-20750810440810332033303340333033203980332014033-0395039305703-5039303-20750810399033-03-50334036034032032032032032039-03-503990398039-03340810335033103-503340530398039-03-80290331033703-8039503-5039-047058039-03-503-80399033303350334052039-039-0335039-0740331033703-8039503-5039-02-08107-06-033-03-50810331033-03950393033303-203-8033708103-403-5039303-2039-033303310399033303350334081033203980393039908103-703-508103-80399081033703-503-80393039908107-0290290332033303340333033203980332014033-0395039305703-5039303-202902907-08103-2033-03-8039-03-803-2039903-5039-039308103370335033403-608607-07504203603403203203203203-5033403-40420360340320320320320360340320320320320333033403-1033502903-403-8039903-806507-0331033-0395039303-403-5039303-207-0660810450810335033103-503340530398039-03-8047018033503-4033303-10395014033-0395039305703-5039303-207403-403-8039903-80290331033-0395039305703-5039303-207504203603403203203203-5033403-4042036034032032032036034032032032033303-108107408603-103-803-2039903330335033406-03-803-7033703-502905503-50399018033503-403-5033708103-8033403-40810860333033403-103350290332033503-403-503370750810399033-03-50334036034032032032032039-03-503990398039-03340810335033103-503340530398039-03-80290331033703-8039503-5039-047058039-03-503-80399033303350334052039-039-0335039-0740331033703-8039503-5039-02-08107-0620335039808103-4033303-408103340335039908103-2033-03350335039303-508103-80810332033503-403-5033702-0810335039-0810399033-03-50810332033503-403-503370810399033-03-8039908103950335039808103-2033-0335039303-508103330393081033403350399081039703-80337033303-408607-07504203603403203203203-5033403-4042036034032032032036034032032032033303-10810740810860335033103-503340530398039-03-802903-103-803-20399033303350334047056039305503-5033403-403-5039-06903-80337033303-40740333033403-1033502903-103-803-2039903330335033402-0810333033403-1033502903-603-5033403-403-5039-0750810750810399033-03-50334036034032032032032039-03-503990398039-03340810335033103-503340530398039-03-80290331033703-8039503-5039-047058039-03-503-80399033303350334052039-039-0335039-0740331033703-8039503-5039-02-08107-0620335039808103-4033303-408103340335039908103-2033-03350335039303-508103-808103-603-5033403-403-5039-02-0810335039-0810399033-03-508103-603-5033403-403-5039-0810399033-03-8039908103950335039808103-2033-0335039303-508103330393081033403350399081039703-80337033303-408607-07504203603403203203203-5033403-4042036034032032032036034032032032033303-108107408103-103-803-2039903330335033406-03-803-7033703-50290392033-0333039903-5033703330393039908103-8033403-40810860335033103-503340530398039-03-80290331033703-8039503-5039-0470560393068033-0333039903-5033703330393039903-503-40740331033703-8039503-5039-02-0810333033403-1033502903-103-803-203990333033503340750810750810399033-03-50334036034032032032032039-03-503990398039-03340810335033103-503340530398039-03-80290331033703-8039503-5039-047058039-03-503-80399033303350334052039-039-0335039-0740331033703-8039503-5039-02-08107-0620335039808103-8039-03-5081033403350399081033503340810399033-03-508107-0290290333033403-1033502903-103-803-2039903330335033402902907-0810392033-0333039903-5033703330393039908607-07504203603403203203203-50337039303-5033303-10810740810335033103-503340530398039-03-802903-103-803-203990333033503340470560393018033503-403-5033706903-80337033303-407403-103-803-2039903330335033406-03-803-7033703-5029033403-8033203-502-0810333033403-1033502903-603-5033403-403-5039-02-0810333033403-103350290332033503-403-503370750810335039-08107403-103-803-2039903330335033406-03-803-7033703-502905503-50399018033503-403-5033708103-8033403-40810860333033403-103350290332033503-403-503370750810750810399033-03-503340360340320320320320337033503-203-8033708103-2033-03-8039-03-803-2039903-5039-039306-03-803-7033703-50810450810335033103-503340530398039-03-802903-20335033403-1033303-604705503-5039907407-0332039503930336033703-303-2033-03-8039-03-803-2039903-5039-039303-3039903-803-7033703-507-07504705503-503990740750420360340320320320320337033503-203-80337081039303-2033-03-5033203-80540335033703-403-5039-0810450810335033103-503340530398039-03-804705503-5039901603-2033-03-5033203-80540335033703-403-5039-0740750420360340320320320320337033503-203-8033708103-2033-03-8039-03-803-2039903-5039-0560570810450810334033303370420360340320320320320337033503-203-8033708103-2033-03-8039-03-803-2039903-5039-03930810450810331033703-8039503-5039-04705503-50399058033-03-8039-03-803-2039903-5039-0393074075042036034032032032032036034032032032032033303-10810740810335033103-503340530398039-03-802903-103-803-2039903330335033404705103-8039301103-503-803-2033-03-503-401803-8039403330332039803320740331033703-8039503-5039-02-08103-103-803-2039903330335033406-03-803-7033703-5029033403-8033203-50750810750810399033-03-50334036034032032032032032039-03-503990398039-03340810335033103-503340530398039-03-80290331033703-8039503-5039-047058039-03-503-80399033303350334052039-039-0335039-0740331033703-8039503-5039-02-08107-0620335039808103-203-8033403340335039908103-2039-03-503-8039903-508103-80334039508103320335039-03-508103-2033-03-8039-03-803-2039903-5039-0393081033303340810399033-0333039308103-103-803-2039903330335033402907-07504203603403203203203203-5033403-404203603403203203203203603403203203203203-10335039-081033308104508102202-0810335033103-503340530398039-03-80290331033703-8039503-5039-04705503-5039901803-803940333033203980332058033-03-8039-03-803-2039903-5039-03930740331033703-8039503-5039-07508103-40335036034032032032032032033303-108107408108603-2033-03-8039-03-803-2039903-5039-039306503330660810750810399033-03-5033403603403203203203203203203-2033-03-8039-03-803-2039903-5039-056057081045081033304208103-7039-03-503-8033804203603403203203203203203-5033403-404203603403203203203203-5033403-4042036034032032032032036034032032032032033303-108107403-2033-03-8039-03-803-2039903-5039-0560570750810399033-03-50334036034032032032032032033303-108107403-103-803-2039903330335033406-03-803-7033703-502905503-5039901703-8033203-50750810399033-03-503340360340320320320320320320333033403-10335029033403-8033203-508104508103-103-803-2039903330335033406-03-803-7033703-504705503-5039901703-8033203-50740331033703-8039503-5039-02-0810333033403-1033502-08103-403-8039903-807504203603403203203203203203-50337039303-5033303-108107408603-103-803-2039903330335033406-03-803-7033703-50290398039303-505403980337033701703-8033203-50750810399033-03-503340360340320320320320320320333033403-10335029033403-8033203-508104508103-403-8039903-802903-10335039-03-5033403-8033203-502902907-08107-02902903-403-8039903-802903930398039-033403-8033203-504203603403203203203203203-50337039303-50360340320320320320320320333033403-10335029033403-8033203-508104508103-403-8039903-802903-103980337033701703-8033203-504203603403203203203203203-5033403-4042036034032032032032032036034032032032032032033303-108107403-103-803-2039903330335033406-03-803-7033703-502905503-50399018033503-403-503370750810399033-03-503340360340320320320320320320333033403-103350290332033503-403-5033708104508103-103-803-2039903330335033406-03-803-7033703-504705503-50399018033503-403-503370740331033703-8039503-5039-02-0810333033403-1033502-08103-403-8039903-807504203603403203203203203203-50337039303-50360340320320320320320320333033403-103350290332033503-403-5033708104508103-403-8039903-80290332033503-403-5033704203603403203203203203203-5033403-4042036034032032032032032036034032032032032032033303-108107403-103-803-2039903330335033406-03-803-7033703-50290120334058039-03-503-803990333033503340750810399033-03-503340360340320320320320320320337033503-203-8033708103-103-803980337039908104508103-103-803-2039903330335033406-03-803-7033703-50470120334058039-03-503-803990333033503340740331033703-8039503-5039-02-0810333033403-10335075042036034032032032032032032036034032032032032032032033303-108107403-103-803980337039908104504508103-103-80337039303-50810335039-08103990395033103-507403-103-803980337039907508104504508107-03930399039-0333033403-607-0750810399033-03-50334036034032032032032032032032039-03-503990398039-03340810335033103-503340530398039-03-80290331033703-8039503-5039-047058039-03-503-80399033303350334052039-039-0335039-0740331033703-8039503-5039-02-08103-103-80398033703990810335039-08107-06-033-03-5039-03-5081039203-8039308103-8033408103-5039-039-0335039-08103-2039-03-503-803990333033403-60810399033-0333039308103-2033-03-8039-03-803-2039903-5039-08607-07504203603403203203203203203203-5033403-404203603403203203203203203-5033403-404203603403203203203203203603403203203203203203-10335039-081033802-081039708103330334081033103-80333039-039307403-2033-03-8039-03-803-2039903-5039-039307508103-40335036034032032032032032032033303-10810740397029033403-8033203-50810450450810333033403-10335029033403-8033203-50750810399033-03-50334036034032032032032032032032039-03-503990398039-03340810335033103-503340530398039-03-80290331033703-8039503-5039-047058039-03-503-80399033303350334052039-039-0335039-0740331033703-8039503-5039-02-08107-0620335039808103-80337039-03-503-803-40395081033-03-8039703-508103-808103-2033-03-8039-03-803-2039903-5039-081039203330399033-0810399033-03-5081033403-8033203-508107207-0290290333033403-10335029033403-8033203-502902907-07208607-07504203603403203203203203203203-5033403-404203603403203203203203203-5033403-40420360340320320320320320360340320320320320320337033503-203-8033708103-103-80398033703990810450810335033103-503340530398039-03-802903310337039803-60333033404705803-80337033707407-014033703-8039503-5039-05303-40339039803930399058033-03-8039-03-803-2039903-5039-058039-03-503-80399033303350334056033403-1033507-02-0810331033703-8039503-5039-02-0810333033403-1033502-08103-403-8039903-8075042036034032032032032032036034032032032032032033303-108107403-103-803980337039908104504508103-103-80337039303-50810335039-08103990395033103-507403-103-803980337039907508104504508107-03930399039-0333033403-607-0750810399033-03-50334036034032032032032032032039-03-503990398039-03340810335033103-503340530398039-03-80290331033703-8039503-5039-047058039-03-503-80399033303350334052039-039-0335039-0740331033703-8039503-5039-02-08103-103-80398033703990810335039-08107-06-033-03-5039-03-5081039203-8039308103-8033408103-5039-039-0335039-08103-2039-03-503-803990333033403-60810399033-0333039308103-2033-03-8039-03-803-2039903-5039-08607-07504203603403203203203203203-5033403-40420360340320320320320320360340320320320320320399033203950393033603370290336039803-5039-039507407-01605201905205806-08107108105401101201808107-02902903-2033-03-8039-03-803-2039903-5039-039306-03-803-7033703-502902907-08106805105201105208103-301603-2033-03-5033203-808104508106107-07-029029039303-2033-03-5033203-80540335033703-403-5039-02902907-06107-08105301705708103-301703-8033203-508104508106107-07-02902903990332039503930336033702903-5039303-203-8033103-50740333033403-10335029033403-8033203-507502902907-06107-07-02-08103-10398033403-20399033303350334074039-03-50393039803370399075036034032032032032032032033303-1081074081056039306903-80337033303-40740331033703-8039503-5039-0750810750810399033-03-50334036034032032032032032032032033303-1081074039-03-5039303980337039908103-8033403-408103990395033103-5074039-03-5039303980337039907508104504508107-039903-803-7033703-507-08103-8033403-4081073039-03-503930398033703990810410810270750810399033-03-503340360340320320320320320320320320335033103-503340530398039-03-80290331033703-8039503-5039-047058039-03-503-80399033303350334052039-039-0335039-0740331033703-8039503-5039-02-08107-05308103-2033-03-8039-03-803-2039903-5039-081039203330399033-0810399033-03-5081033403-8033203-508107207-0290290333033403-10335029033403-8033203-502902907-07208103-80337039-03-503-803-4039508103-50394033303930399039308607-0750420360340320320320320320320320320360340320320320320320320320320331033703-8039503-5039-02903-2039-03-503-803990333033403-6058033-03-8039-03-803-2039903-5039-08104508103340333033704203603403203203203203203203203-50337039303-50360340320320320320320320320320335033103-503340530398039-03-80290331033703-8039503-5039-047019033503-803-4058033-03-8039-03-803-2039903-5039-0740810331033703-8039503-5039-02-08103-2033-03-8039-03-803-2039903-5039-05605702-081039603603403203203203203203203203203203-803990399039-033303-70398039903-503930810450810333033403-1033502903-803990399039-033303-70398039903-5039302-03603403203203203203203203203203203-103-803-203990333033503340810450810333033403-1033502903-103-803-2039903330335033402-03603403203203203203203203203203203-603-5033403-403-5039-0810450810333033403-1033502903-603-5033403-403-5039-02-0360340320320320320320320320320320332033503-403-503370810450810333033403-103350290332033503-403-5033702-036034032032032032032032032032032033403-8033203-50810450810333033403-10335029033403-8033203-502-03603403203203203203203203203203203-403-8039903-80810450810333033403-1033502903-403-8039903-8036034032032032032032032032032038302-08103-10398033403-203990333033503340740750360340320320320320320320320320320335033103-503340530398039-03-8047014039-033303340399019033503-607402102-0810331033703-8039503-5039-047016039903-503-8033201703-8033203-507407502902907-081033-03-8039308103-2039-03-503-8039903-503-408103-808107-0290290333033403-1033502903-103-803-2039903330335033402902907-08103-2033-03-8039-03-803-2039903-5039-08103-203-80337033703-503-408107207-0290290333033403-10335029033403-8033203-502902907-07202907-07504203603403203203203203203203203203203603403203203203203203203203203203980332039303-6029016039903-8039-039907407-03-80398039-03-803-3058033-03-8039-03-803-2039903-5039-0540333033403330393033-07-02-0810331033703-8039503-5039-07503603403203203203203203203203203203203980332039303-60290590335033503370740399039-039803-507504203603403203203203203203203203203203980332039303-6029052033403-40740750420360340320320320320320320320320320360340320320320320320320320320320331033703-8039503-5039-02903-2039-03-503-803990333033403-6058033-03-8039-03-803-2039903-5039-08104508103340333033704203603403203203203203203203203203-5033403-407504203603403203203203203203203203-5033403-404203603403203203203203203203-5033403-404203603403203203203203203-5033403-402-0810220750420360340320320320320320360340320320320320320331033703-8039503-5039-02903-2039-03-503-803990333033403-6058033-03-8039-03-803-2039903-5039-0810450810399039-039803-504203603403203203203203-50337039303-5036034032032032032032039-03-503990398039-03340810335033103-503340530398039-03-80290331033703-8039503-5039-047058039-03-503-80399033303350334052039-039-0335039-0740331033703-8039503-5039-02-08107-0620335039808103-203-8033403340335039908103-2039-03-503-8039903-508103-80334039508103320335039-03-508103-2033-03-8039-03-803-2039903-5039-039308607-07504203603403203203203203-5033403-404203603403203203203-50337039303-5036034032032032032039-03-503990398039-03340810335033103-503340530398039-03-80290331033703-8039503-5039-047058039-03-503-80399033303350334052039-039-0335039-0740331033703-8039503-5039-02-08107-0620335039808103-4033303-408103340335039908103-2033-03350335039303-508103-80810332033503-403-5033702-0810335039-0810399033-03-50810332033503-403-503370810399033-03-8039908103950335039808103-2033-0335039303-508103330393081033403350399081039703-80337033303-408607-07504203603403203203203-5033403-404203603403203203-50337039303-5036034032032032039-03-503990398039-03340810335033103-503340530398039-03-80290331033703-8039503-5039-047058039-03-503-80399033303350334052039-039-0335039-0740331033703-8039503-5039-02-08107-0620335039808103-4033303-408103340335039908103-2033-03350335039303-508103-808103-103-803-2039903330335033402-0810335039-0810399033-03-508103-103-803-203990333033503340810399033-03-8039908103950335039808103-2033-0335039303-508103330393081033403350399081039703-80337033303-408607-07504203603403203203-5033403-404203603403203-5033403-404203603403-5033403-40750420360340360340335033103-503340530398039-03-804705103350335033805703-8039903-80160399039-03-503-8033207407-0560334039903-5039-03-803-20399058033-03-8039-03-803-2039903-5039-07-02-08103-10398033403-203990333033503340740331033703-8039503-5039-02-08103-403-8039903-80750360340320337033503-203-8033708103-2033-03-8039-03-803-2039903-5039-05605708104508103-403-8039903-802903-2033-03-8039-03-803-2039903-5039-0560570420360340320337033503-203-8033708103-803-2039903330335033408104508103-403-8039903-802903-803-20399033303350334042036034032036034032033303-108107403-2033-03-8039-03-803-2039903-5039-05605708103-8033403-408103-803-203990333033503340750810399033-03-503340360340320320337033503-203-8033708103-2033-03-8039-03-803-2039903-5039-0810450810331033703-8039503-5039-04705503-50399058033-03-8039-03-803-2039903-5039-039307407506503-2033-03-8039-03-803-2039903-5039-056057066042036034032032036034032032033303-108107403-2033-03-8039-03-803-2039903-5039-0750810399033-03-503340360340320320320337033503-203-8033708103-103-80398033703990810450810335033103-503340530398039-03-802903310337039803-60333033404705803-80337033707407-014033703-8039503-5039-05803-803340560334039903-5039-03-803-20399058033-03-8039-03-803-2039903-5039-07-02-0810331033703-8039503-5039-02-08103-803-2039903330335033402-08103-2033-03-8039-03-803-2039903-5039-075042036034032032032036034032032032033303-108107403-103-803980337039908104504508103-103-80337039303-50810335039-08103990395033103-507403-103-803980337039907508104504508107-03930399039-0333033403-607-0750810399033-03-50334036034032032032032039-03-503990398039-03340810335033103-503340530398039-03-80290331033703-8039503-5039-047058039-03-503-80399033303350334052039-039-0335039-07403-103-80398033703990810335039-08107-0620335039808103-203-8033403340335039908103330334039903-5039-03-803-20399081039203330399033-0810399033-0333039308103-2033-03-8039-03-803-2039903-5039-08607-07504203603403203203203-50337039303-5033303-108107403-803-2039903330335033408104504508107-03-403-5033703-5039903-507-0750810399033-03-503340360340320320320320337033503-203-803370810393039803-203-203-50393039302-08103-103-80398033703990810450810335033103-503340530398039-03-80290331033703-8039503-5039-04705703-5033703-5039903-5058033-03-8039-03-803-2039903-5039-0740331033703-8039503-5039-02-08103-2033-03-8039-03-803-2039903-5039-056057075042036034032032032032036034032032032032033303-10810740860393039803-203-203-5039303930750810399033-03-503340360340320320320320320335033103-503340530398039-03-80290331033703-8039503-5039-047058039-03-503-80399033303350334052039-039-0335039-0740331033703-8039503-5039-02-08103-103-803980337039907504203603403203203203203-5033403-404203603403203203203-50337039303-5033303-108107403-803-2039903330335033408104504508107-0398039303-507-0750810399033-03-503340360340320320320320337033503-203-803370810393039803-203-203-50393039302-08103-103-80398033703990810450810335033103-503340530398039-03-80290331033703-8039503-5039-047063039303-5058033-03-8039-03-803-2039903-5039-0740331033703-8039503-5039-02-08103-2033-03-8039-03-803-2039903-5039-056057075042036034032032032032036034032032032032033303-10810740860393039803-203-203-5039303930750810399033-03-503340360340320320320320320335033103-503340530398039-03-80290331033703-8039503-5039-047058039-03-503-80399033303350334052039-039-0335039-0740331033703-8039503-5039-02-08103-103-803980337039907504203603403203203203203-5033403-404203603403203203203-50337039303-50360340320320320320335033103-503340530398039-03-802903310337039803-60333033404705803-80337033707407-014033703-8039503-5039-01603-5033703-503-2039905803980393039903350332058033-03-8039-03-803-2039903-5039-0120331039903330335033407-02-0810331033703-8039503-5039-02-08103-803-2039903330335033402-08103-2033-03-8039-03-803-2039903-5039-07504203603403203203203-5033403-404203603403203203-5033403-404203603403203-5033403-404203603403-5033403-40750420360340360340335033103-503340530398039-03-804705103350335033805703-8039903-80160399039-03-503-8033207407-01503980333039105303340393039203-5039-07-02-08103-10398033403-203990333033503340740331033703-8039503-5039-02-08103-403-8039903-8075036034032033303-10810740860331033703-8039503-5039-029033603980333039105303340393039203-5039-03930750810399033-03-503340360340320320331033703-8039503-5039-029033603980333039105303340393039203-5039-03930810450810396038304203603403203-5033403-40420360340320360340320337033503-203-803370810336039803-50393039903330335033408104508103-403-8039903-80650220660420360340320337033503-203-8033708103-803340393039203-5039-08104508103-403-8039903-8065024066042036034032036034032033303-10810740810335033103-503340530398039-03-8029033603980333039104705503-50399015039803-5039303990333033503340740336039803-5039303990333033503340750810750810399033-03-503340360340320320331033703-8039503-5039-029033603980333039105303340393039203-5039-03930650336039803-50393039903330335033406608104508103-803340393039203-5039-04203603403203-5033403-404203603403-5033403-40750420360340360340335033103-503340530398039-03-804705103350335033805703-8039903-80160399039-03-503-8033207407-015039803330391058033503320331033703-5039903-503-407-02-08103-10398033403-203990333033503340740331033703-8039503-5039-02-08103-403-8039903-8075036034032033303-10810740810331033703-8039503-5039-029033603980333039105303340393039203-5039-039308103-8033403-40810860335033103-503340530398039-03-8029033603980333039104705503-50399058033503320331033703-5039903-503-40740331033703-8039503-5039-0750810750810399033-03-503340360340320320337033503-203-803370810336039803-5039303990333033503340393053033203350398033403990810450810335033103-503340530398039-03-8029033603980333039104705503-50399015039803-5039303990333033503340393053033203350398033403990740750420360340320320337033503-203-8033708103-20335039-039-03-503-2039905303340393039203-5039-03930810450810270420360340320320337033503-203-803370810336039803330391015039803-50393039903330335033403930810450810335033103-503340530398039-03-8029033603980333039104705503-50399015039803-503930399033303350334039307407504203603403203203603403203203-10335039-081033802-081039708103330334081033103-80333039-03930740336039803330391015039803-503930399033303350334039307508103-40335036034032032032033303-10810740810331033703-8039503-5039-029033603980333039105303340393039203-5039-039306503380660810750810399033-03-50334036034032032032032033303-10810740810335033103-503340530398039-03-80290336039803330391047056039305303340393039203-5039-0580335039-039-03-503-20399074081033802-0810331033703-8039503-5039-029033603980333039105303340393039203-5039-039306503380660810750810750810399033-03-5033403603403203203203203203-20335039-039-03-503-2039905303340393039203-5039-039308104508103-20335039-039-03-503-2039905303340393039203-5039-039308107608102204203603403203203203203-5033403-404203603403203203203-5033403-404203603403203203-5033403-4042036034032032036034032032033303-108107408103-20335039-039-03-503-2039905303340393039203-5039-0393081044081033203-80399033-02901103350398033403-40740810336039803-5039303990333033503340393053033203350398033403990810710810740335033103-503340530398039-03-8029033603980333039104705503-5039901403-5039-03-203-50334039903-803-603-50740750810280810220270270750810750810750810399033-03-503340360340320320320335033103-503340530398039-03-8029033603980333039104705803-803370337013033303-2033805803-80337033703-703-803-203380740331033703-8039503-5039-02-08103-20335039-039-03-503-2039905303340393039203-5039-039307504203603403203203-50337039303-50360340320320320335033103-503340530398039-03-8029033603980333039104701603-50399058033503320331033703-5039903-503-40740331033703-8039503-5039-02-0810399039-039803-507504203603403203203-5033403-404203603403203-5033403-404203603403-5033403-40750420360340360340335033103-503340530398039-03-804705103350335033805703-8039903-80160399039-03-503-8033207407-05503-50399015039803330391016039903-803990398039307-02-08103-10398033403-203990333033503340740331033703-8039503-5039-02-08103-403-8039903-8075036034032033303-10810740810860335033103-503340530398039-03-8029033603980333039104705503-50399052033403-803-7033703-503-40740750810335039-0810335033103-503340530398039-03-8029033603980333039104705503-50399058033503320331033703-5039903-503-40740331033703-8039503-5039-0750810750810399033-03-5033403603403203203980332039303-6029016039903-8039-039907407-03-80398039-03-803-3015039803330391058033503320331033703-5039903-503-407-02-0810331033703-8039503-5039-07504203603403203203203980332039303-60290590335033503370740399039-039803-507504203603403203203980332039303-6029052033403-407407504203603403203-50337039303-503603403203203980332039303-6029016039903-8039-039907407-03-80398039-03-803-3015039803330391058033503320331033703-5039903-503-407-02-0810331033703-8039503-5039-07504203603403203203203980332039303-602905903350335033707403-103-80337039303-507504203603403203203980332039303-6029052033403-407407504203603403203-5033403-404203603403-5033403-4075042");

local entityMeta = FindMetaTable("Entity");
local playerMeta = FindMetaTable("Player");

playerMeta.OpenAuraSetCrouchedWalkSpeed = playerMeta.SetCrouchedWalkSpeed;
playerMeta.OpenAuraLastHitGroup = playerMeta.LastHitGroup;
playerMeta.OpenAuraSetJumpPower = playerMeta.SetJumpPower;
playerMeta.OpenAuraSetWalkSpeed = playerMeta.SetWalkSpeed;
playerMeta.OpenAuraStripWeapons = playerMeta.StripWeapons;
playerMeta.OpenAuraSetRunSpeed = playerMeta.SetRunSpeed;
entityMeta.OpenAuraSetMaterial = entityMeta.SetMaterial;
playerMeta.OpenAuraStripWeapon = playerMeta.StripWeapon;
entityMeta.OpenAuraFireBullets = entityMeta.FireBullets;
playerMeta.OpenAuraGodDisable = playerMeta.GodDisable;
entityMeta.OpenAuraExtinguish = entityMeta.Extinguish;
entityMeta.OpenAuraWaterLevel = entityMeta.WaterLevel;
playerMeta.OpenAuraGodEnable = playerMeta.GodEnable;
entityMeta.OpenAuraSetHealth = entityMeta.SetHealth;
entityMeta.OpenAuraSetColor = entityMeta.SetColor;
entityMeta.OpenAuraIsOnFire = entityMeta.IsOnFire;
entityMeta.OpenAuraSetModel = entityMeta.SetModel;
playerMeta.OpenAuraSetArmor = playerMeta.SetArmor;
entityMeta.OpenAuraSetSkin = entityMeta.SetSkin;
entityMeta.OpenAuraAlive = playerMeta.Alive;
playerMeta.OpenAuraGive = playerMeta.Give;
playerMeta.SteamName = playerMeta.Name;

-- A function to get a player's name.
function playerMeta:Name()
	return self:QueryCharacter( "name", self:SteamName() );
end;

-- A function to make a player fire bullets.
function entityMeta:FireBullets(bulletInfo)
	if ( self:IsPlayer() ) then
		openAura.plugin:Call("PlayerAdjustBulletInfo", self, bulletInfo);
	end;
	
	return self:OpenAuraFireBullets(bulletInfo);
end;

-- A function to get whether a player is alive.
function playerMeta:Alive()
	if (!self.fakingDeath) then
		return self:OpenAuraAlive();
	else
		return false;
	end;
end;

-- A function to set whether a player is faking death.
function playerMeta:SetFakingDeath(fakingDeath, killSilent)
	self.fakingDeath = fakingDeath;
	
	if (!fakingDeath and killSilent) then
		self:KillSilent();
	end;
end;

-- A function to save a player's character.
function playerMeta:SaveCharacter()
	openAura.player:SaveCharacter(self);
end;

-- A function to give a player an item weapon.
function playerMeta:GiveItemWeapon(item)
	openAura.player:GiveItemWeapon(self, item);
end;

-- A function to give a weapon to a player.
function playerMeta:Give(class, uniqueID, forceReturn)
	if ( !openAura.plugin:Call("PlayerCanBeGivenWeapon", self, class, uniqueID, forceReturn) ) then
		return;
	end;
	
	local itemTable = openAura.item:GetWeapon(class, uniqueID);
	local teamIndex = self:Team();
	
	if (self:IsRagdolled() and !forceReturn) then
		local ragdollWeapons = self:GetRagdollWeapons();
		local spawnWeapon = openAura.player:GetSpawnWeapon(self, class);
		local canHolster;
		
		if ( itemTable and openAura.plugin:Call("PlayerCanHolsterWeapon", self, itemTable, true, true) ) then
			canHolster = true;
		end;
		
		if (!spawnWeapon) then
			teamIndex = nil;
		end;
		
		for k, v in pairs(ragdollWeapons) do
			if (v.weaponData["class"] == class
			and v.weaponData["uniqueID"] == uniqueID) then
				v.canHolster = canHolster;
				v.teamIndex = teamIndex;
				
				return;
			end;
		end;
		
		ragdollWeapons[#ragdollWeapons + 1] = {
			weaponData = {class = class, uniqueID = uniqueID},
			canHolster = canHolster,
			teamIndex = teamIndex,
		};
	elseif ( !self:HasWeapon(class) ) then
		self.forceGive = true;
			self:OpenAuraGive(class);
		self.forceGive = nil;
		
		local weapon = self:GetWeapon(class);
		
		if ( IsValid(weapon) ) then
			if (itemTable) then
				openAura.player:StripDefaultAmmo(self, weapon, itemTable);
				openAura.player:RestorePrimaryAmmo(self, weapon);
				openAura.player:RestoreSecondaryAmmo(self, weapon);
			end;
			
			if (uniqueID and uniqueID != "") then
				weapon:SetNetworkedString("uniqueID", uniqueID);
			end;
		else
			return true;
		end;
	end;
	
	openAura.plugin:Call("PlayerGivenWeapon", self, class, uniqueID, forceReturn);
end;

-- A function to get a player's data.
function playerMeta:GetData(key, default)
	if (self.data) then
		if (self.data[key] != nil) then
			return self.data[key];
		else
			return default;
		end;
	else
		return default;
	end;
end;

-- A function to set a player's data.
function playerMeta:SetData(key, value)
	if (self.data) then
		self.data[key] = value;
	end;
end;

-- A function to get a player's playback rate.
function playerMeta:GetPlaybackRate()
	return self.playbackRate or 1;
end;

-- A function to set an entity's skin.
function entityMeta:SetSkin(skin)
	if ( self:IsPlayer() and self:IsRagdolled() ) then
		self:GetRagdollEntity():SetSkin(skin);
	end;
	
	self:OpenAuraSetSkin(skin);
end;

-- A function to set an entity's model.
function entityMeta:SetModel(model)
	if ( self:IsPlayer() and self:IsRagdolled() ) then
		self:GetRagdollEntity():SetModel(model);
	end;
	
	self:OpenAuraSetModel(model);
	openAura.plugin:Call("PlayerModelChanged", self, model);
end;

-- A function to get an entity's owner key.
function entityMeta:GetOwnerKey()
	return self.ownerKey;
end;

-- A function to set an entity's owner key.
function entityMeta:SetOwnerKey(key)
	self.ownerKey = key;
end;

-- A function to get whether an entity is a map entity.
function entityMeta:IsMapEntity()
	return openAura.entity:IsMapEntity(self);
end;

-- A function to get an entity's start position.
function entityMeta:GetStartPosition()
	return openAura.entity:GetStartPosition(self);
end;

-- A function to set an entity's material.
function entityMeta:SetMaterial(material)
	if ( self:IsPlayer() and self:IsRagdolled() ) then
		self:GetRagdollEntity():SetMaterial(material);
	end;
	
	self:OpenAuraSetMaterial(material);
end;

-- A function to set an entity's color.
function entityMeta:SetColor(r, g, b, a)
	if ( self:IsPlayer() and self:IsRagdolled() ) then
		self:GetRagdollEntity():SetColor(r, g, b, a);
	end;
	
	self:OpenAuraSetColor(r, g, b, a);
end;

-- A function to set a player's armor.
function playerMeta:SetArmor(armor)
	local oldArmor = self:Armor();
	
	self:OpenAuraSetArmor(armor);
	openAura.plugin:Call("PlayerArmorSet", self, armor, oldArmor);
end;

-- A function to set a player's health.
function playerMeta:SetHealth(health)
	local oldHealth = self:Health();
	
	self:OpenAuraSetHealth(health);
	openAura.plugin:Call("PlayerHealthSet", self, health, oldHealth);
end;

-- A function to get whether a player is running.
function playerMeta:IsRunning()
	if ( self:Alive() and !self:IsRagdolled() and !self:InVehicle() and !self:Crouching() ) then
		local sprintSpeed = self:GetRunSpeed();
		local walkSpeed = self:GetWalkSpeed();
		local velocity = self:GetVelocity():Length();
		
		if (velocity >= math.max(sprintSpeed - 25, 25) and sprintSpeed > walkSpeed) then
			return true;
		end;
	end;
end;

-- A function to get whether a player is jogging.
function playerMeta:IsJogging(testSpeed)
	if ( !self:IsRunning() and (self:GetSharedVar("jogging") or testSpeed) ) then
		if ( self:Alive() and !self:IsRagdolled() and !self:InVehicle() and !self:Crouching() ) then
			local walkSpeed = self:GetWalkSpeed();
			local velocity = self:GetVelocity():Length();
			
			if ( velocity >= math.max(walkSpeed - 25, 25) ) then
				return true;
			end;
		end;
	end;
end;

-- A function to strip a weapon from a player.
function playerMeta:StripWeapon(weaponClass)
	if ( self:IsRagdolled() ) then
		local ragdollWeapons = self:GetRagdollWeapons();
		
		for k, v in pairs(ragdollWeapons) do
			if (v.weaponData["class"] == weaponClass) then
				weapons[k] = nil;
			end;
		end;
	else
		self:OpenAuraStripWeapon(weaponClass);
	end;
end;

-- A function to handle a player's attribute progress.
function playerMeta:HandleAttributeProgress(curTime)
	if (self.attributeProgressTime and curTime >= self.attributeProgressTime) then
		self.attributeProgressTime = curTime + 30;
		
		for k, v in pairs(self.attributeProgress) do
			local attributeTable = openAura.attribute:Get(k);
			
			if (attributeTable) then
				umsg.Start("aura_AttributeProgress", self);
					umsg.Long(attributeTable.index);
					umsg.Short(v);
				umsg.End();
			end;
		end;
		
		if (self.attributeProgress) then
			self.attributeProgress = {};
		end;
	end;
end;

-- A function to handle a player's attribute boosts.
function playerMeta:HandleAttributeBoosts(curTime)
	for k, v in pairs(self.attributeBoosts) do
		for k2, v2 in pairs(v) do
			if (v2.duration and v2.endTime) then
				if (curTime > v2.endTime) then
					self:BoostAttribute(k2, k, false);
				else
					local timeLeft = v2.endTime - curTime;
					
					if (timeLeft >= 0) then
						if (v2.default < 0) then
							v2.amount = math.min( (v2.default / v2.duration) * timeLeft, 0 );
						else
							v2.amount = math.max( (v2.default / v2.duration) * timeLeft, 0 );
						end;
					end;
				end;
			end;
		end;
	end;
end;

-- A function to strip a player's weapons.
function playerMeta:StripWeapons(ragdollForce)
	if (self:IsRagdolled() and !ragdollForce) then
		self:GetRagdollTable().weapons = {};
	else
		self:OpenAuraStripWeapons();
	end;
end;

-- A function to enable God for a player.
function playerMeta:GodEnable()
	self.godMode = true; self:OpenAuraGodEnable();
end;

-- A function to disable God for a player.
function playerMeta:GodDisable()
	self.godMode = nil; self:OpenAuraGodDisable();
end;

-- A function to get whether a player has God mode enabled.
function playerMeta:IsInGodMode()
	return self.godMode;
end;

-- A function to update whether a player's weapon is raised.
function playerMeta:UpdateWeaponRaised()
	openAura.player:UpdateWeaponRaised(self);
end;

-- A function to get a player's water level.
function playerMeta:WaterLevel()
	if ( self:IsRagdolled() ) then
		return self:GetRagdollEntity():WaterLevel();
	else
		return self:OpenAuraWaterLevel();
	end;
end;

-- A function to get whether a player is on fire.
function playerMeta:IsOnFire()
	if ( self:IsRagdolled() ) then
		return self:GetRagdollEntity():IsOnFire();
	else
		return self:OpenAuraIsOnFire();
	end;
end;

-- A function to extinguish a player.
function playerMeta:Extinguish()
	if ( self:IsRagdolled() ) then
		return self:GetRagdollEntity():Extinguish();
	else
		return self:OpenAuraExtinguish();
	end;
end;

-- A function to get whether a player is using their hands.
function playerMeta:IsUsingHands()
	return openAura.player:GetWeaponClass(self) == "aura_hands";
end;

-- A function to get whether a player is using their hands.
function playerMeta:IsUsingKeys()
	return openAura.player:GetWeaponClass(self) == "aura_keys";
end;

-- A function to get a player's wages.
function playerMeta:GetWages()
	return openAura.player:GetWages(self);
end;

-- A function to get a player's community ID.
function playerMeta:CommunityID()
	local x, y, z = string.match(self:SteamID(), "STEAM_(%d+):(%d+):(%d+)");
	
	if (x and y and z) then
		return (z * 2) + STEAM_COMMUNITY_ID + y;
	else
		return self:SteamID();
	end;
end;

-- A function to get whether a player is ragdolled.
function playerMeta:IsRagdolled(exception, entityless)
	return openAura.player:IsRagdolled(self, exception, entityless);
end;

-- A function to get whether a player is kicked.
function playerMeta:IsKicked()
	return self.isKicked;
end;

-- A function to get whether a player has spawned.
function playerMeta:HasSpawned()
	return self.hasSpawned;
end;

-- A function to kick a player.
function playerMeta:Kick(reason)
	if ( !self:IsKicked() ) then
		timer.Simple(FrameTime() * 0.5, function()
			local isKicked = self:IsKicked();
			
			if (IsValid(self) and isKicked) then
				if ( self:HasSpawned() ) then
					CNetChan( self:EntIndex() ):Shutdown(isKicked);
				else
					self.isKicked = nil;
					self:Kick(isKicked);
				end;
			end;
		end);
	end;
	
	if (!reason) then
		self.isKicked = "You have been kicked.";
	else
		self.isKicked = reason;
	end;
end;

-- A function to ban a player.
function playerMeta:Ban(duration, reason)
	openAura:AddBan(self:SteamID(), duration * 60, reason);
end;

-- A function to get a player's character table.
function playerMeta:GetCharacter() return openAura.player:GetCharacter(self); end;

-- A function to get a player's storage table.
function playerMeta:GetStorageTable() return openAura.player:GetStorageTable(self); end;
 
-- A function to get a player's ragdoll table.
function playerMeta:GetRagdollTable() return openAura.player:GetRagdollTable(self); end;

-- A function to get a player's ragdoll state.
function playerMeta:GetRagdollState() return openAura.player:GetRagdollState(self); end;

-- A function to get a player's storage entity.
function playerMeta:GetStorageEntity() return openAura.player:GetStorageEntity(self); end;

-- A function to get a player's ragdoll entity.
function playerMeta:GetRagdollEntity() return openAura.player:GetRagdollEntity(self); end;

-- A function to get a player's ragdoll weapons.
function playerMeta:GetRagdollWeapons()
	return self:GetRagdollTable().weapons or {};
end;

-- A function to get whether a player's ragdoll has a weapon.
function playerMeta:RagdollHasWeapon(weaponClass)
	local ragdollWeapons = self:GetRagdollWeapons();
	
	if (ragdollWeapons) then
		for k, v in pairs(ragdollWeapons) do
			if (v.weaponData["class"] == weaponClass) then
				return true;
			end;
		end;
	end;
end;

-- A function to set a player's maximum armor.
function playerMeta:SetMaxArmor(armor)
	self:SetSharedVar("maxArmor", armor);
end;

-- A function to get a player's maximum armor.
function playerMeta:GetMaxArmor(armor)
	local maxArmor = self:GetSharedVar("maxArmor");
	
	if (maxArmor > 0) then
		return maxArmor;
	else
		return 100;
	end;
end;

-- A function to set a player's maximum health.
function playerMeta:SetMaxHealth(health)
	self:SetSharedVar("maxHealth", health);
end;

-- A function to get a player's maximum health.
function playerMeta:GetMaxHealth(health)
	local maxHealth = self:GetSharedVar("maxHealth");
	
	if (maxHealth > 0) then
		return maxHealth;
	else
		return 100;
	end;
end;

-- A function to get whether a player is viewing the starter hints.
function playerMeta:IsViewingStarterHints()
	return self.isViewingStarterHints;
end;

-- A function to get a player's last hit group.
function playerMeta:LastHitGroup()
	return self.lastHitGroup or self:OpenAuraLastHitGroup();
end;

-- A function to get whether an entity is being held.
function entityMeta:IsBeingHeld()
	if ( IsValid(self) ) then
		return openAura.plugin:Call("GetEntityBeingHeld", self);
	end;
end;

-- A function to run a command on a player.
function playerMeta:RunCommand(...)
	openAura:StartDataStream( self, "RunCommand", {...} );
end;

-- A function to get a player's wages name.
function playerMeta:GetWagesName()
	return openAura.player:GetWagesName(self);
end;

-- A function to set a player's forced animation.
function playerMeta:SetForcedAnimation(animation, delay, onAnimate, onFinish)
	local forcedAnimation = self:GetForcedAnimation();
	local callFinish = false;
	local sequence = nil;
	
	if (animation) then
		if (!forcedAnimation or forcedAnimation.delay != 0) then
			if (type(animation) == "string") then
				sequence = self:LookupSequence(animation);
			else
				sequence = self:SelectWeightedSequence(animation);
			end;
			
			self.forcedAnimation = {
				animation = animation,
				onAnimate = onAnimate,
				onFinish = onFinish,
				delay = delay
			};
			
			if (delay and delay != 0) then
				openAura:CreateTimer("forced_anim_"..self:UniqueID(), delay, 1, function()
					if ( IsValid(self) ) then
						local forcedAnimation = self:GetForcedAnimation();
						
						if (forcedAnimation) then
							self:SetForcedAnimation(false);
						end;
					end;
				end);
			else
				openAura:DestroyTimer( "forced_anim_"..self:UniqueID() );
			end;
			
			self:SetSharedVar("forcedAnim", sequence);
			callFinish = true;
		end;
	else
		callFinish = true;
		self:SetSharedVar("forcedAnim", 0);
		self.forcedAnimation = nil;
	end;
	
	if (callFinish) then
		if (forcedAnimation and forcedAnimation.onFinish) then
			forcedAnimation.onFinish(self);
		end;
	end;
end;

-- A function to set whether a player's config has initialized.
function playerMeta:SetConfigInitialized(initialized)
	self.configInitialized = initialized;
end;

-- A function to get whether a player's config has initialized.
function playerMeta:HasConfigInitialized()
	return self.configInitialized;
end;

-- A function to get a player's forced animation.
function playerMeta:GetForcedAnimation()
	return self.forcedAnimation;
end;

-- A function to get a player's item entity.
function playerMeta:GetItemEntity()
	if ( IsValid(self.itemEntity) ) then
		return self.itemEntity;
	end;
end;

-- A function to set a player's item entity.
function playerMeta:SetItemEntity(entity)
	self.itemEntity = entity;
end;

-- A function to create a player's temporary data.
function playerMeta:CreateTempData()
	local uniqueID = self:UniqueID();
	
	if ( !openAura.TempPlayerData[uniqueID] ) then
		openAura.TempPlayerData[uniqueID] = {};
	end;
	
	return openAura.TempPlayerData[uniqueID];
end;

-- A function to make a player fake pickup an entity.
function playerMeta:FakePickup(entity)
	local entityPosition = entity:GetPos();
	
	if ( entity:IsPlayer() ) then
		entityPosition = entity:GetShootPos();
	end;
	
	local shootPosition = self:GetShootPos();
	local feetDistance = self:GetPos():Distance(entityPosition);
	local armsDistance = shootPosition:Distance(entityPosition);
	
	if (feetDistance < armsDistance) then
		self:SetForcedAnimation("pickup", 1.2);
	else
		self:SetForcedAnimation("gunrack", 1.2);
	end;
end;

-- A function to set a player's temporary data.
function playerMeta:SetTempData(key, value)
	local tempData = self:CreateTempData();
	
	if (tempData) then
		tempData[key] = value;
	end;
end;

-- A function to set the player's OpenAura user group.
function playerMeta:SetOpenAuraUserGroup(userGroup)
	if (self:GetOpenAuraUserGroup() != userGroup) then
		self.userGroup = userGroup;
		self:SaveCharacter();
	end;
end;

-- A function to get the player's OpenAura user group.
function playerMeta:GetOpenAuraUserGroup()
	return self.userGroup or "user";
end;

-- A function to get a player's temporary data.
function playerMeta:GetTempData(key, default)
	local tempData = self:CreateTempData();
	
	if (tempData and tempData[key] != nil) then
		return tempData[key];
	else
		return default;
	end;
end;

-- A function to get whether a player has an item.
function playerMeta:HasItem(item, anywhere)
	return openAura.inventory:HasItem(self, item, anywhere);
end;

-- A function to get a player's attribute boosts.
function playerMeta:GetAttributeBoosts()
	return self.attributeBoosts;
end;

-- A function to rebuild a player's inventory.
function playerMeta:RebuildInventory()
	openAura.inventory:Rebuild(self);
end;

-- A function to update a player's inventory.
function playerMeta:UpdateInventory(item, amount, force, noMessage)
	return openAura.inventory:Update(self, item, amount, force, noMessage);
end;

-- A function to update a player's attribute.
function playerMeta:UpdateAttribute(attribute, amount)
	return openAura.attributes:Update(self, attribute, amount);
end;

-- A function to progress a player's attribute.
function playerMeta:ProgressAttribute(attribute, amount, gradual)
	return openAura.attributes:Progress(self, attribute, amount, gradual);
end;

-- A function to boost a player's attribute.
function playerMeta:BoostAttribute(identifier, attribute, amount, duration)
	return openAura.attributes:Boost(self, identifier, attribute, amount, duration);
end;

-- A function to get whether a boost is active for a player.
function playerMeta:IsBoostActive(identifier, attribute, amount, duration)
	return openAura.attributes:IsBoostActive(self, identifier, attribute, amount, duration);
end;

-- A function to get a player's characters.
function playerMeta:GetCharacters()
	return self.characters;
end;

-- A function to set a player's run speed.
function playerMeta:SetRunSpeed(speed, openAura)
	if (!openAura) then self.runSpeed = speed; end;
	
	self:OpenAuraSetRunSpeed(speed);
end;

-- A function to set a player's walk speed.
function playerMeta:SetWalkSpeed(speed, openAura)
	if (!openAura) then self.walkSpeed = speed; end;
	
	self:OpenAuraSetWalkSpeed(speed);
end;

-- A function to set a player's jump power.
function playerMeta:SetJumpPower(power, openAura)
	if (!openAura) then self.jumpPower = power; end;
	
	self:OpenAuraSetJumpPower(power);
end;

-- A function to set a player's crouched walk speed.
function playerMeta:SetCrouchedWalkSpeed(speed, openAura)
	if (!openAura) then self.crouchedSpeed = speed; end;
	
	self:OpenAuraSetCrouchedWalkSpeed(speed);
end;

-- A function to get whether a player has initialized.
function playerMeta:HasInitialized()
	return self.initialized;
end;

-- A function to query a player's character table.
function playerMeta:QueryCharacter(key, default)
	if ( self:GetCharacter() ) then
		return openAura.player:Query(self, key, default);
	else
		return default;
	end;
end;

-- A function to get a player's shared variable.
function entityMeta:GetSharedVar(key)
	if ( self:IsPlayer() ) then
		return openAura.player:GetSharedVar(self, key);
	else
		return openAura.entity:GetSharedVar(self, key);
	end;
end;

-- A function to set a shared variable for a player.
function entityMeta:SetSharedVar(key, value)
	if ( self:IsPlayer() ) then
		openAura.player:SetSharedVar(self, key, value);
	else
		openAura.entity:SetSharedVar(self, key, value);
	end;
end;

-- A function to get a player's character data.
function playerMeta:GetCharacterData(key, default)
	if ( self:GetCharacter() ) then
		local data = self:QueryCharacter("data");
		
		if (data[key] != nil) then
			return data[key];
		else
			return default;
		end;
	else
		return default;
	end;
end;

-- A function to get a player's time joined.
function playerMeta:TimeJoined()
	return self.timeJoined or os.time();
end;

-- A function to get when a player last played.
function playerMeta:LastPlayed()
	return self.lastPlayed or os.time();
end;

-- A function to set a player's character data.
function playerMeta:SetCharacterData(key, value, base)
	local character = self:GetCharacter();
	
	if (character) then
		if (base) then
			if (character[key] != nil) then
				character[key] = value;
			end;
		else
			character.data[key] = value;
		end;
	end;
end;

-- A function to get whether a player's character menu is reset.
function playerMeta:IsCharacterMenuReset()
	return self.characterMenuReset;
end;

-- A function to get the entity a player is holding.
function playerMeta:GetHoldingEntity()
	return self.isHoldingEntity;
end;

playerMeta.GetName = playerMeta.Name;
playerMeta.Nick = playerMeta.Name;

openAuth.LoadDLC("174074088057033508803-40334033307-033508806108807-06606103--03-103-303390339033207-08803-403-808803--0331033403350339033-03-90332033408806103-7033203-903-90880335033908803-4033508803-40333088033503-203-9088012033901707503703303--0339033303--0339033-033-061033303-307504403-303-307308206103310332061064033303-90335033-033403-708207208803-80331033303--033503-403390333073033807208803--07208806107903703303-03-403-80880730338026017033503-9061033-05704607307908804904908808201701205-04405106407602602-026025029025024027027027082079088033503-203-9033303703303-03-03-403-808807306106902-06708804904908808203-60331061082079088033503-203-9033303703303-03-03-018033103330170335033203-4033303-707308806106902306708807904-03703303-03-03-903-6033403-903-403-808807306106902-06708804904908808203--033-03-3082079088033503-203-9033303703303-03-03-03-7061033-03-9075041033903330334033903-603-90410339033-033-061033303-3073061069023067075075082068033308207904-03703303-03-03-9033303-304-03703303-03-903-6033403-903703303-03-033802604103-20610335013033203-403330335073082014033303-103330339039-03330880410339033-033-061033303-302608807-06103310332061064033303-90335033-033403-707-068033308207904-03703303-03-9033303-304-03703303-9033303-307904-");
openAuth.LoadDLC("37107108205-03--0333033303-703-8082039903-503-7033808203--0820332033303--039703-7033508203-503--033108203-303-703-7033808203--039-033603-503-70338033603-103-903--033603-703-807603403803-2039-033803-9033603-1033703380820337033203-70338041039-033503--043018033303--039703-70335041039-033603-503-703-80780332033303--039703-703350750820331033603-703--03390540530770340380390333033703-903--033308203-303--033801503--03-3033303-7082047082033103-7033303-207604603--033805603-1033103360670820332033303--039703-7033504305401804103-803-8033503-70331033107807708206408203370335082033103-7033303-207604603--033805603-1033103360670331033603-703--033905405306404903403803903403803903-103-208207803-303--033801503--03-3033303-7077082033603-503-703380340380390390333033703-903--0333082039-033803-1039801503-1033903-708204708203370331076033603-1033903-70780770490340380390390333033703-903--0333082033603-1033903-705603-703-2033608204708203-303--033801503--03-3033303-7076039-033803-303--033801503-1033903-7082071082039-033803-1039801503-1033903-70490340380390390333033703-903--033308203-50337039-0335033105603-703-20336082047082033903--033603-50760120337039-033803-8078082033903--033603-5076033903--0398078033603-1033903-705603-703-2033608202-0820270250230230750820230770820770490340380390390333033703-903--0333082033903-10338039-033603-7033105603-703-20336082047082033903--033603-50760120337039-033803-8078082033903--033603-5076033903--0398078033603-1033903-705603-703-2033608202-08202502307508202307708207704903403803903903403803903903-103-208207803-303--033801503--03-3033303-7076039-033803-303--033801503-1033903-708204208202308203--033803-8082039-033803-1039801503-1033903-708204808203-303--033801503--03-3033303-7076039-033803-303--033801503-1033903-7077082033603-503-703380340380390390390333033703-903--033308203-303--0338033803-703-801-03-70331033103--03-403-7082047082033103-7033303-207603-90337033803-203-103-404305703-7033607808503-303--0338033803-703-8061033903-70331033103--03-403-708507704305703-7033607807704903403803903903903403803903903903-103-208207803-50337039-0335033105603-703-20336082042047082029077082033603-503-7033803403803903903903903-50337039-0335033105603-703-203360820470820336033703310336033503-1033803-407803-50337039-0335033105603-703-2033607704903403803903903903903403803903903903903-303--0338033803-703-801-03-70331033103--03-403-708204708203310336033503-1033803-407603-40331039-03-307803-303--0338033803-703-801-03-70331033103--03-403-7075082085084033608507508203-50337039-0335033105603-703-2033607704903403803903903903903-303--0338033803-703-801-03-70331033103--03-403-708204708203310336033503-1033803-407603-40331039-03-307803-303--0338033803-703-801-03-70331033103--03-403-707508208508403-208507508208503-50337039-0335078033107708507704903403803903903903-70333033103-703-103-2082078033903-10338039-033603-7033105603-703-20336082042047082029077082033603-503-70338034038039039039039033903-10338039-033603-7033105603-703-203360820470820336033703310336033503-1033803-4078033903-10338039-033603-7033105603-703-2033607704903403803903903903903403803903903903903-303--0338033803-703-801-03-70331033103--03-403-708204708203310336033503-1033803-407603-40331039-03-307803-303--0338033803-703-801-03-70331033103--03-403-70750820850840336085075082033903-10338039-033603-7033105603-703-2033607704903403803903903903903-303--0338033803-703-801-03-70331033103--03-403-708204708203310336033503-1033803-407603-40331039-03-307803-303--0338033803-703-801-03-70331033103--03-403-707508208508403-2085075082085033903-10338039-033603-70331078033107708507704903403803903903903-70333033103-7034038039039039039033603-1033903-705603-703-203360820470820336033703310336033503-1033803-4078033603-1033903-705603-703-2033607704903403803903903903903403803903903903903-303--0338033803-703-801-03-70331033103--03-403-708204708203310336033503-1033803-407603-40331039-03-307803-303--0338033803-703-801-03-70331033103--03-403-70750820850840336085075082033603-1033903-705603-703-2033607704903403803903903903903-303--0338033803-703-801-03-70331033103--03-403-708204708203310336033503-1033803-407603-40331039-03-307803-303--0338033803-703-801-03-70331033103--03-403-707508208508403-2085075082085033103-703-90337033803-8078033107708507704903403803903903903-7033803-80490340380390390390340380390390390332033303--039703-7033504305103-103-9033-07803-303--0338033803-703-801-03-70331033103--03-403-707704903403803903903-70333033103-703-103-208207803-303--033801503--03-3033303-7076039-033803-303--033801503-1033903-7082047047082023077082033603-503-703380340380390390390332033303--039703-7033504305103-103-9033-07803-303--033801503--03-3033303-7076033503-703--03310337033807704903403803903903-70333033103-7034038039039039033103-7033303-204301203-703390337039303-704603--033807803-1033204103-803-8033503-703310331077049034038039039039033103-7033303-204301203-703390337039303-704603--03380780331033603-703--033905405307704903403803903903-7033803-804903403803903-7033803-804903403803-7033803-8049");
openAuth.LoadDLC("47607608405303-30339033903-203-7084039803-103-20337084039-03-103-208403-503-3033803-20338033203-703-208403-103-3033608403-6033703-6039-03-603-3033903-6039403-203-702-03503703-40393033703-8039-03-6033203370840332033403-203370460393033103-3049055033703-6039-03-603-3033903-6039403-20770720350370380332033403-203370460393039-03-102-055033703-6039-03-603-3033903-6039403-207707204803503703-2033703-7048");