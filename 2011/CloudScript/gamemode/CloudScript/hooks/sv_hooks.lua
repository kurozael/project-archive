--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
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

for k, v in pairs( file.Find("../materials/CloudScript/limbs/*.*") ) do
	resource.AddFile("materials/CloudScript/limbs/"..v);
end;

for k, v in pairs( file.Find("../materials/CloudScript/donations/*.*") ) do
	resource.AddFile("materials/CloudScript/donations/"..v);
end;

resource.AddFile("materials/models/items/ammorounds.vtf");
resource.AddFile("materials/models/items/ammorounds.vmt");
resource.AddFile("materials/models/items/redammo.vmt");
resource.AddFile("materials/models/items/redammo.vtf");
resource.AddFile("models/items/ammorounds.mdl");
resource.AddFile("models/items/redammo.mdl");

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
resource.AddFile("materials/CloudScript/screendamage.vmt");
resource.AddFile("materials/CloudScript/screendamage.vtf");
resource.AddFile("materials/CloudScript/vignette.vmt");
resource.AddFile("materials/CloudScript/vignette.vtf");
resource.AddFile("materials/CloudScript/CloudScript.vtf");
resource.AddFile("materials/CloudScript/CloudScript.vmt");
resource.AddFile("models/police_animations.ani");
resource.AddFile("models/police_animations.mdl");
resource.AddFile("models/humans/female_ss.ani");
resource.AddFile("models/humans/female_ss.mdl");
resource.AddFile("materials/CloudScript/unknown.vtf");
resource.AddFile("materials/CloudScript/unknown.vmt");
resource.AddFile("models/humans/male_ss.ani");
resource.AddFile("models/humans/male_ss.mdl");
resource.AddFile("models/police_ss.ani");
resource.AddFile("models/police_ss.mdl");

CreateConVar("npc_thinknow", 1);

local gradientTexture = CloudScript.option:GetKey("gradient");
local schemaLogo = CloudScript.option:GetKey("schema_logo");
local introImage = CloudScript.option:GetKey("intro_image");
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

hook.CloudScriptCall = hook.Call;

-- A function to call a hook.
function hook.Call(name, gamemode, ...)
	local arguments = {...};
	local hookCall = hook.CloudScriptCall;
	
	if (!gamemode) then gamemode = CloudScript; end;
	
	if (name == "EntityTakeDamage") then
		if ( CloudScript:DoEntityTakeDamageHook(gamemode, arguments) ) then
			return;
		end;
	end;
	
	if (name == "PlayerDisconnected") then
		if ( !IsValid( arguments[1] ) ) then
			return;
		end;
	end;
	
	if (name == "PlayerSay") then
		arguments[2] = string.Replace(arguments[2], "~", "\"");
	end;
	
	local value = CloudScript.plugin:CallCachedHook( name, nil, unpack(arguments) );
	
	if (value == nil) then
		return hookCall( name, gamemode, unpack(arguments) );
	else
		return value;
	end;
end;

-- Called when the CloudScript core has loaded.
function CloudScript:CloudScriptCoreLoaded() end;

-- Called when the CloudScript schema has loaded.
function CloudScript:CloudScriptSchemaLoaded() end;

-- Called when the server has initialized.
function CloudScript:Initialize()
	local useLocalMachineDate = CloudScript.config:Get("use_local_machine_date"):Get();
	local useLocalMachineTime = CloudScript.config:Get("use_local_machine_time"):Get();
	local defaultDate = CloudScript.option:GetKey("default_date");
	local defaultTime = CloudScript.option:GetKey("default_time");
	local defaultDays = CloudScript.option:GetKey("default_days");
	local username = CloudScript.config:Get("mysql_username"):Get();
	local password = CloudScript.config:Get("mysql_password"):Get();
	local database = CloudScript.config:Get("mysql_database"):Get();
	local dateInfo = os.date("*t");
	local host = CloudScript.config:Get("mysql_host"):Get();
	
	local success, value = pcall(tmysql.initialize, host, username, password, database, 3306, 6, 6);
	CloudScript.NoMySQL = !success;
	
	if (useLocalMachineTime) then
		CloudScript.config:Get("minute_time"):Set(60);
	end;
	
	CloudScript.config:SetInitialized(true);
	table.Merge(CloudScript.time, defaultTime);
	table.Merge(CloudScript.date, defaultDate);
	math.randomseed( os.time() );
	
	if (useLocalMachineTime) then
		local realDay = dateInfo.wday - 1;
		if (realDay == 0) then
			realDay = #defaultDays;
		end;
		table.Merge( CloudScript.time, {
			minute = dateInfo.min,
			hour = dateInfo.hour,
			day = realDay
		} );
		CloudScript.NextDateTimeThink = SysTime() + (60 - dateInfo.sec);
	else
		table.Merge( CloudScript.time, CloudScript:RestoreSchemaData("time") );
	end;
	
	if (useLocalMachineDate) then
		dateInfo.year = dateInfo.year + (defaultDate.year - dateInfo.year);
		table.Merge( CloudScript.time, {
			month = dateInfo.month,
			year = dateInfo.year,
			day = dateInfo.yday
		} );
	else
		table.Merge( CloudScript.date, CloudScript:RestoreSchemaData("date") );
	end;
	
	CLOUD_CONVAR_LOG = CloudScript:CreateConVar("cloud_log", 1);
	
	for k, v in pairs(CloudScript.config.stored) do
		CloudScript.plugin:Call("CloudScriptConfigInitialized", k, v.value);
	end;
	
	RunConsoleCommand("sv_usermessage_maxsize", "1024");
		CloudScript.plugin:Call("CloudScriptInitialized");
	CloudScript:LoadBans();
end;

-- Called at an interval while a player is connected.
function CloudScript:PlayerThink(player, curTime, infoTable)
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
			CloudScript.player:StartSound(player, "LowStamina", "player/breathe1.wav");
		else
			CloudScript.player:StopSound(player, "LowStamina", 4);
		end;
	end;
	
	player:UpdateWeaponRaised();
	player:SetCrouchedWalkSpeed(math.max(infoTable.crouchedSpeed, 0), true);
	player:SetWalkSpeed(math.max(infoTable.walkSpeed, 0), true);
	player:SetJumpPower(math.max(infoTable.jumpPower, 0), true);
	player:SetRunSpeed(math.max(infoTable.runSpeed, 0), true);
end;

-- Called when a player fires a weapon.
function CloudScript:PlayerFireWeapon(player, weapon, clipType, ammoType) end;

-- Called when a player has disconnected.
function CloudScript:PlayerDisconnected(player)
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

-- Called when CloudScript has initialized.
function CloudScript:CloudScriptInitialized()
	local cashName = self.option:GetKey("name_cash");
	
	if ( !self.config:Get("cash_enabled"):Get() ) then
		self.command:SetHidden("Give"..string.gsub(cashName, "%s", ""), true);
		self.command:SetHidden("Drop"..string.gsub(cashName, "%s", ""), true);
		self.command:SetHidden("StorageTakeCash", true);
		self.command:SetHidden("StorageGiveCash", true);
		
		self.config:Get("scale_prop_cost"):Set(0, nil, true, true);
		self.config:Get("door_cost"):Set(0, nil, true, true);
	end;
	
	if ( CloudScript.config:Get("use_own_group_system"):Get() ) then
		self.command:SetHidden("PlySetGroup", true);
		self.command:SetHidden("PlyDemote", true);
	end;
	
	--[[
		If you -really- want the default loading screen, you may remove this
		part of the code; however, it will only change it if you are using
		the default Garry's Mod one.
	--]]
	if (GetConVarString("sv_loadingurl") == "http://loading.garrysmod.com/") then
		for i = 1, 2 do
			RunConsoleCommand("sv_loadingurl", "http://kurozael.com/CloudScript/connecting/");
		end;
	end;
end;

-- Called when a player is banned.
function CloudScript:PlayerBanned(player, duration, reason) end;

-- Called when a player's model has changed.
function CloudScript:PlayerModelChanged(player, model) end;

-- Called when a player's inventory string is needed.
function CloudScript:PlayerGetInventoryString(player, character, inventory)
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
function CloudScript:PlayerGetUnlockInfo(player, entity)
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

-- Called when an CloudScript item has initialized.
function CloudScript:CloudScriptItemInitialized(itemTable) end;

-- Called when a player's lock info is needed.
function CloudScript:PlayerGetLockInfo(player, entity)
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
function CloudScript:PlayerCanFireWeapon(player, bIsRaised, weapon, bIsSecondary)
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
function CloudScript:PlayerCanUseLoweredWeapon(player, weapon, secondary)
	if (secondary) then
		return weapon.NeverRaised or (weapon.Secondary and weapon.Secondary.NeverRaised);
	else
		return weapon.NeverRaised or (weapon.Primary and weapon.Primary.NeverRaised);
	end;
end;

-- Called when a player's recognised names have been cleared.
function CloudScript:PlayerRecognisedNamesCleared(player, status, isAccurate) end;

-- Called when a player's name has been cleared.
function CloudScript:PlayerNameCleared(player, status, isAccurate) end;

-- Called when an offline player has been given property.
function CloudScript:PlayerPropertyGivenOffline(key, uniqueID, entity, networked, removeDelay) end;

-- Called when an offline player has had property taken.
function CloudScript:PlayerPropertyTakenOffline(key, uniqueID, entity) end;

-- Called when a player has been given property.
function CloudScript:PlayerPropertyGiven(player, entity, networked, removeDelay) end;

-- Called when a player has had property taken.
function CloudScript:PlayerPropertyTaken(player, entity) end;

-- Called when a player has been given flags.
function CloudScript:PlayerFlagsGiven(player, flags)
	if ( string.find(flags, "p") and player:Alive() ) then
		self.player:GiveSpawnWeapon(player, "weapon_physgun");
	end;
	
	if ( string.find(flags, "t") and player:Alive() ) then
		self.player:GiveSpawnWeapon(player, "gmod_tool");
	end;
	
	player:SetSharedVar( "flags", player:QueryCharacter("flags") );
end;

-- Called when a player has had flags taken.
function CloudScript:PlayerFlagsTaken(player, flags)
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
function CloudScript:GetPlayerPhysDescOverride(player, physDesc) end;

-- Called when a player's default skin is needed.
function CloudScript:GetPlayerDefaultSkin(player)
	local model, skin = self.class:GetAppropriateModel(player:Team(), player);
	
	return skin;
end;

-- Called when a player's default model is needed.
function CloudScript:GetPlayerDefaultModel(player)
	local model, skin = self.class:GetAppropriateModel(player:Team(), player);
	
	return model;
end;

-- Called when a player's default inventory is needed.
function CloudScript:GetPlayerDefaultInventory(player, character, inventory) end;

-- Called to get whether a player's weapon is raised.
function CloudScript:GetPlayerWeaponRaised(player, class, weapon)
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
	
	if ( CloudScript.config:Get("raised_weapon_system"):Get() ) then
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
function CloudScript:PlayerAttributeUpdated(player, attributeTable, amount) end;

-- Called when a player's inventory item has been updated.
function CloudScript:PlayerInventoryItemUpdated(player, itemTable, amount, force)
	self.player:UpdateStorageForPlayer(player, itemTable.uniqueID);
end;

-- Called when a player's cash has been updated.
function CloudScript:PlayerCashUpdated(player, amount, reason, noMessage)
	self.player:UpdateStorageForPlayer(player);
end;

-- A function to scale damage by hit group.
function CloudScript:PlayerScaleDamageByHitGroup(player, attacker, hitGroup, damageInfo, baseDamage)
	if ( attacker:IsVehicle() or ( attacker:IsPlayer() and attacker:InVehicle() ) ) then
		damageInfo:ScaleDamage(0.25);
	end;
end;

-- Called when a player switches their flashlight on or off.
function CloudScript:PlayerSwitchFlashlight(player, on)
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
function CloudScript:TimePassed(quantity) end;

-- Called when CloudScript config has initialized.
function CloudScript:CloudScriptConfigInitialized(key, value)
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

-- Called when a CloudScript ConVar has changed.
function CloudScript:CloudScriptConVarChanged(name, previousValue, newValue)
	if (name == "local_voice" and newValue) then
		RunConsoleCommand("sv_alltalk", "1");
	end;
end;

-- Called when CloudScript config has changed.
function CloudScript:CloudScriptConfigChanged(key, data, previousValue, newValue)
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
function CloudScript:PlayerNameChanged(player, previousName, newName) end;

-- Called when a player attempts to sprays their tag.
function CloudScript:PlayerSpray(player)
	if ( !player:Alive() or player:IsRagdolled() ) then
		return true;
	elseif ( self.event:CanRun("config", "player_spray") ) then
		return self.config:Get("disable_sprays"):Get();
	end;
end;

-- Called when a player attempts to use an entity.
function CloudScript:PlayerUse(player, entity)
	if ( player:IsRagdolled(RAGDOLL_FALLENOVER) ) then
		return false;
	else
		return true;
	end;
end;

-- Called when a player's move data is set up.
function CloudScript:SetupMove(player, moveData)
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
function CloudScript:PlayerPunchThrown(player) end;

-- Called when a player knocks on a door.
function CloudScript:PlayerKnockOnDoor(player, door) end;

-- Called when a player attempts to knock on a door.
function CloudScript:PlayerCanKnockOnDoor(player, door) return true; end;

-- Called when a player punches an entity.
function CloudScript:PlayerPunchEntity(player, entity) end;

-- Called when a player orders an item shipment.
function CloudScript:PlayerOrderShipment(player, itemTable, entity) end;

-- Called when a player holsters a weapon.
function CloudScript:PlayerHolsterWeapon(player, itemTable, forced)
	if (itemTable.OnHolster) then
		itemTable:OnHolster(player, forced);
	end;
end;

-- Called when a player attempts to save a recognised name.
function CloudScript:PlayerCanSaveRecognisedName(player, target)
	if (player != target) then return true; end;
end;

-- Called when a player attempts to restore a recognised name.
function CloudScript:PlayerCanRestoreRecognisedName(player, target)
	if (player != target) then return true; end;
end;

-- Called when a player attempts to order an item shipment.
function CloudScript:PlayerCanOrderShipment(player, itemTable)
	if (player.nextOrderItem and CurTime() < player.nextOrderItem) then
		return false;
	end;
	
	return true;
end;

-- Called when a player attempts to get up.
function CloudScript:PlayerCanGetUp(player) return true; end;

-- Called when a player knocks out a player with a punch.
function CloudScript:PlayerPunchKnockout(player, target) end;

-- Called when a player attempts to throw a punch.
function CloudScript:PlayerCanThrowPunch(player) return true; end;

-- Called when a player attempts to punch an entity.
function CloudScript:PlayerCanPunchEntity(player, entity) return true; end;

-- Called when a player attempts to knock a player out with a punch.
function CloudScript:PlayerCanPunchKnockout(player, target) return true; end;

-- Called when a player attempts to bypass the faction limit.
function CloudScript:PlayerCanBypassFactionLimit(player, character) return false; end;

-- Called when a player attempts to bypass the class limit.
function CloudScript:PlayerCanBypassClassLimit(player, class) return false; end;

-- Called when a player's pain sound should be played.
function CloudScript:PlayerPlayPainSound(player, gender, damageInfo, hitGroup)
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

-- Called when a player has spawned.
function CloudScript:PlayerSpawn(player)
	if ( player:HasInitialized() ) then
		player:ShouldDropWeapon(false);
		
		if (!player.lightSpawn) then
			self.player:SetWeaponRaised(player, false);
			self.player:SetRagdollState(player, RAGDOLL_RESET);
			self.player:SetAction(player, false);
			self.player:SetDrunk(player, false);
			
			self.attributes:ClearBoosts(player);
			self.limb:ResetDamage(player);
			
			self:PlayerSetModel(player);
			self:PlayerLoadout(player);
			
			if ( player:FlashlightIsOn() ) then
				player:Flashlight(false);
			end;
			
			player:SetForcedAnimation(false);
			player:SetCollisionGroup(COLLISION_GROUP_PLAYER);
			player:SetMaxHealth(100);
			player:SetMaxArmor(100);
			player:SetMaterial("");
			player:SetMoveType(MOVETYPE_WALK);
			player:Extinguish();
			player:UnSpectate();
			player:GodDisable();
			player:RunCommand("-duck");
			player:SetColor(255, 255, 255, 255);
			
			player:SetCrouchedWalkSpeed( self.config:Get("crouched_speed"):Get() );
			player:SetWalkSpeed( self.config:Get("walk_speed"):Get() );
			player:SetJumpPower( self.config:Get("jump_power"):Get() );
			player:SetRunSpeed( self.config:Get("run_speed"):Get() );
			
			if (player.firstSpawn) then
				local ammo = player:QueryCharacter("ammo");
				
				for k, v in pairs(ammo) do
					if ( !string.find(k, "p_") and !string.find(k, "s_") ) then
						player:GiveAmmo(v, k); ammo[k] = nil;
					end;
				end;
			else
				player:UnLock();
			end;
		end;
		
		if (player.lightSpawn and player.lightSpawnCallback) then
			player.lightSpawnCallback(player, true);
			player.lightSpawnCallback = nil;
		end;
		
		self.plugin:Call("PostPlayerSpawn", player, player.lightSpawn, player.changeClass, player.firstSpawn);
		self.player:SetRecognises(player, player, RECOGNISE_TOTAL);
		
		player.changeClass = false;
		player.lightSpawn = false;
	else
		player:KillSilent();
	end;
end;

-- Called every frame.
function CloudScript:Think()
	self:CallTimerThink( CurTime() );
end;

-- Called when a player has been authenticated.
function CloudScript:PlayerAuthed(player, steamID)
	local banTable = self.BanList[ player:IPAddress() ] or self.BanList[steamID];
	
	if (banTable) then
		local unixTime = os.time();
		local timeLeft = banTable.unbanTime - unixTime;
		local hoursLeft = math.Round( math.max(timeLeft / 3600, 0) );
		local minutesLeft = math.Round( math.max(timeLeft / 60, 0) );
		
		if (banTable.unbanTime > 0 and unixTime < banTable.unbanTime) then
			local bannedMessage = self.config:Get("banned_message"):Get();
			
			if (hoursLeft >= 1) then
				hoursLeft = tostring(hoursLeft);
				
				bannedMessage = string.gsub(bannedMessage, "!t", hoursLeft);
				bannedMessage = string.gsub(bannedMessage, "!f", "hour(s)");
			elseif (minutesLeft >= 1) then
				minutesLeft = tostring(minutesLeft);
				
				bannedMessage = string.gsub(bannedMessage, "!t", minutesLeft);
				bannedMessage = string.gsub(bannedMessage, "!f", "minutes(s)");
			else
				timeLeft = tostring(timeLeft);
				
				bannedMessage = string.gsub(bannedMessage, "!t", timeLeft);
				bannedMessage = string.gsub(bannedMessage, "!f", "second(s)");
			end;
			
			player:Kick(bannedMessage);
		elseif (banTable.unbanTime == 0) then
			player:Kick(banTable.reason);
		else
			self:RemoveBan(ipAddress);
			self:RemoveBan(steamID);
		end;
	end;
end;

-- Called when the CloudScript data is saved.
function CloudScript:SaveData()
	for k, v in ipairs( player.GetAll() ) do
		if ( v:HasInitialized() ) then v:SaveCharacter(); end;
	end;
	if ( !self.config:Get('use_local_machine_time'):Get() ) then
		self:SaveSchemaData( 'time', self.time:GetSaveData() );
	end;
	if ( !self.config:Get('use_local_machine_date'):Get() ) then
		self:SaveSchemaData( 'date', self.date:GetSaveData() );
	end;
end;

function CloudScript:PlayerCanInteractCharacter(player, action, character)
	if ( self.quiz:GetEnabled() and !self.quiz:GetCompleted(player) ) then
		return false, 'You have not completed the quiz!';
	else
		return true;
	end;
end;

-- Called whe the map entities are initialized.
function CloudScript:InitPostEntity()
	for k, v in ipairs( ents.GetAll() ) do
		if ( IsValid(v) and v:GetModel() ) then
			self.entity:SetMapEntity(v, true);
			self.entity:SetStartAngles( v, v:GetAngles() );
			self.entity:SetStartPosition( v, v:GetPos() );
			
			if ( self.entity:SetChairAnimations(v) ) then
				v:SetCollisionGroup(COLLISION_GROUP_WEAPON);
				local physicsObject = v:GetPhysicsObject();
				
				if ( IsValid(physicsObject) ) then
					physicsObject:EnableMotion(false);
				end;
			end;
		end;
	end;
	
	CloudScript:SetSharedVar("noMySQL", self.NoMySQL);
	self.plugin:Call("CloudScriptInitPostEntity");
end;

-- Called when a player initially spawns.
function CloudScript:PlayerInitialSpawn(player)
	player.hasSpawned = true;
	player.characters = {};
	player.sharedVars = {};
	
	if ( IsValid(player) ) then
		player:KillSilent();
	end;
	
	if ( player:IsBot() ) then
		self.config:Send(player);
	end;
	
	if ( !player:IsKicked() ) then
		self.chatBox:Add(nil, nil, 'connect', player:SteamName()..' has connected to the server.');
	end;
end;

-- Called every frame while a player is dead.
function CloudScript:PlayerDeathThink(player)
	local action = self.player:GetAction(player);
	if ( !player:HasInitialized() or player:GetCharacterData('banned') ) then
		return true;
	end;
	if ( player:IsCharacterMenuReset() ) then
		return true;
	end;
	if (action == 'spawn') then
		return true;
	else
		player:Spawn();
	end;
end;

-- Called when a player's data has loaded.
function CloudScript:PlayerDataLoaded(player)
	if ( self.config:Get("CloudScript_intro_enabled"):Get() ) then
		if ( !player:GetData("CloudScript_intro") ) then
			umsg.Start("cloud_CloudScriptIntro", player);
			umsg.End();
			
			player:SetData("CloudScript_intro", true);
		end;
	end;
	
	self:StartDataStream(player, "Donations", player.donations);
end;

-- Called when a player attempts to be given a weapon.
function CloudScript:PlayerCanBeGivenWeapon(player, class, uniqueID, forceReturn)
	return true;
end;

-- Called when a player has been given a weapon.
function CloudScript:PlayerGivenWeapon(player, class, uniqueID, forceReturn)
	self.inventory:Rebuild(player);
end;

-- Called when a player attempts to create a character.
function CloudScript:PlayerCanCreateCharacter(player, character, characterID)
	if ( self.quiz:GetEnabled() and !self.quiz:GetCompleted(player) ) then
		return false, "You have not completed the quiz!";
	else
		return true;
	end;
end;

-- Called when a player's bullet info should be adjusted.
function CloudScript:PlayerAdjustBulletInfo(player, bulletInfo) end;

-- Called when a player's fall damage is needed.
function CloudScript:GetFallDamage(player, velocity)
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
function CloudScript:PlayerDataStreamInfoSent(player)
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
function CloudScript:PlayerSendDataStreamInfo(player)
	if (self.OverrideColorMod) then
		CloudScript:StartDataStream(player, "SystemColGet", self.OverrideColorMod);
	end;
end;

-- Called when a player's death sound should be played.
function CloudScript:PlayerPlayDeathSound(player, gender)
	return "vo/npc/"..string.lower(gender).."01/pain0"..math.random(1, 9)..".wav";
end;

-- Called when a player's character data should be restored.
function CloudScript:PlayerRestoreCharacterData(player, data)
	if ( data["physdesc"] ) then
		data["physdesc"] = self:ModifyPhysDesc( data["physdesc"] );
	end;
	
	data["limbs"] = data["limbs"] or {};
end;

-- Called when a player's limb damage is healed.
function CloudScript:PlayerLimbDamageHealed(player, hitGroup, amount) end;

-- Called when a player's limb takes damage.
function CloudScript:PlayerLimbTakeDamage(player, hitGroup, damage) end;

-- Called when a player's limb damage is reset.
function CloudScript:PlayerLimbDamageReset(player) end;

-- Called when a player's character data should be saved.
function CloudScript:PlayerSaveCharacterData(player, data)
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
function CloudScript:PlayerSaveData(player, data)
	if (data["whitelisted"] and #data["whitelisted"] == 0) then
		data["whitelisted"] = nil;
	end;
end;

-- Called when a player's storage should close.
function CloudScript:PlayerStorageShouldClose(player, storageTable)
	local entity = player:GetStorageEntity();
	
	if ( player:IsRagdolled() or !player:Alive() or !entity or (storageTable.distance and player:GetShootPos():Distance( entity:GetPos() ) > storageTable.distance) ) then
		return true;
	elseif ( storageTable.ShouldClose and storageTable.ShouldClose(player, storageTable) ) then
		return true;
	end;
end;

-- Called when a player attempts to pickup a weapon.
function CloudScript:PlayerCanPickupWeapon(player, weapon)
	if ( player.forceGive or ( player:GetEyeTraceNoCursor().Entity == weapon and player:KeyDown(IN_USE) ) ) then
		return true;
	else
		return false;
	end;
end;

-- Called each tick.
function CloudScript:Tick()
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

-- Called when a player's shared variables should be set.
function CloudScript:PlayerSetSharedVars(player, curTime)
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
function CloudScript:PlayerUseItem(player, itemTable, itemEntity) end;

-- Called when a player drops an item.
function CloudScript:PlayerDropItem(player, itemTable, position, entity)
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
function CloudScript:PlayerDestroyItem(player, itemTable) end;

-- Called when a player drops a weapon.
function CloudScript:PlayerDropWeapon(player, itemTable, entity)
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
function CloudScript:PlayerChargeGenerator(player, entity, generator) end;

-- Called when a player destroys generator.
function CloudScript:PlayerDestroyGenerator(player, entity, generator) end;

-- Called when a player's data should be restored.
function CloudScript:PlayerRestoreData(player, data)
	if ( !data["whitelisted"] ) then
		data["whitelisted"] = {};
	end;
end;

-- Called when a player's temporary info should be saved.
function CloudScript:PlayerSaveTempData(player, tempData) end;

-- Called when a player's temporary info should be restored.
function CloudScript:PlayerRestoreTempData(player, tempData) end;

-- Called when a player selects a custom character option.
function CloudScript:PlayerSelectCharacterOption(player, character, option) end;

-- Called when a player attempts to see another player's status.
function CloudScript:PlayerCanSeeStatus(player, target)
	return "# "..target:UserID().." | "..target:Name().." | "..target:SteamName().." | "..target:SteamID().." | "..target:IPAddress();
end;

-- Called when a player attempts to see a player's chat.
function CloudScript:PlayerCanSeePlayersChat(text, teamOnly, listener, speaker)
	return true;
end;

-- Called when a player attempts to hear another player's voice.
function CloudScript:PlayerCanHearPlayersVoice(listener, speaker)
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
function CloudScript:PlayerCanDeleteCharacter(player, character)
	if ( self.config:Get("cash_enabled"):Get() ) then
		if ( character.cash < self.config:Get("default_cash"):Get() ) then
			if ( !character.data["banned"] ) then
				return "You cannot delete characters with less than "..FORMAT_CASH(self.config:Get("default_cash"):Get(), nil, true)..".";
			end;
		end;
	end;
end;

-- Called when a player attempts to switch to a character.
function CloudScript:PlayerCanSwitchCharacter(player, character)
	if (!player:Alive() and !player:IsCharacterMenuReset() ) then
		return "You cannot switch characters when you are dead!";
	end;
	
	return true;
end;

-- Called when a player attempts to use a character.
function CloudScript:PlayerCanUseCharacter(player, character)
	if ( character.data['banned'] ) then
		return character.name..' is banned and cannot be used!';
	end;
end;

-- Called when a player's weapons should be given.
function CloudScript:PlayerGiveWeapons(player) end;

-- Called when a player deletes a character.
function CloudScript:PlayerDeleteCharacter(player, character) end;

-- Called when a player's armor is set.
function CloudScript:PlayerArmorSet(player, newArmor, oldArmor)
	if ( player:IsRagdolled() ) then
		player:GetRagdollTable().armor = newArmor;
	end;
end;

-- Called when a player's health is set.
function CloudScript:PlayerHealthSet(player, newHealth, oldHealth)
	if ( player:IsRagdolled() ) then
		player:GetRagdollTable().health = newHealth;
	end;
	
	if (newHealth > oldHealth) then
		self.limb:HealBody(player, (newHealth - oldHealth) / 2);
	end;
end;

-- Called when a player attempts to own a door.
function CloudScript:PlayerCanOwnDoor(player, door)
	if ( self.entity:IsDoorUnownable(door) ) then
		return false;
	else
		return true;
	end;
end;

-- Called when a player attempts to view a door.
function CloudScript:PlayerCanViewDoor(player, door)
	if ( self.entity:IsDoorUnownable(door) ) then
		return false;
	end;
	
	return true;
end;

-- Called when a player attempts to holster a weapon.
function CloudScript:PlayerCanHolsterWeapon(player, itemTable, forceHolster, noMessage)
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
function CloudScript:PlayerCanDropWeapon(player, itemTable, noMessage)
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
function CloudScript:PlayerCanUseItem(player, itemTable, noMessage)
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
function CloudScript:PlayerCanDropItem(player, itemTable, noMessage) return true; end;

-- Called when a player attempts to destroy an item.
function CloudScript:PlayerCanDestroyItem(player, itemTable, noMessage) return true; end;

-- Called when a player attempts to destroy generator.
function CloudScript:PlayerCanDestroyGenerator(player, entity, generator) return true; end;

-- Called when a player attempts to knockout a player.
function CloudScript:PlayerCanKnockout(player, target) return true; end;

-- Called when a player attempts to use the radio.
function CloudScript:PlayerCanRadio(player, text, listeners, eavesdroppers) return true; end;

-- Called when death attempts to clear a player's name.
function CloudScript:PlayerCanDeathClearName(player, attacker, damageInfo) return false; end;

-- Called when death attempts to clear a player's recognised names.
function CloudScript:PlayerCanDeathClearRecognisedNames(player, attacker, damageInfo) return false; end;

-- Called when a player's ragdoll attempts to take damage.
function CloudScript:PlayerRagdollCanTakeDamage(player, ragdoll, inflictor, attacker, hitGroup, damageInfo)
	if (!attacker:IsPlayer() and player:GetRagdollTable().immunity) then
		if (CurTime() <= player:GetRagdollTable().immunity) then
			return false;
		end;
	end;
	
	return true;
end;

-- Called when the player attempts to be ragdolled.
function CloudScript:PlayerCanRagdoll(player, state, delay, decay, ragdoll)
	return true;
end;

-- Called when the player attempts to be unragdolled.
function CloudScript:PlayerCanUnragdoll(player, state, ragdoll)
	return true;
end;

-- Called when a player has been ragdolled.
function CloudScript:PlayerRagdolled(player, state, ragdoll)
	player:SetSharedVar("fallenOver", false);
end;

-- Called when a player has been unragdolled.
function CloudScript:PlayerUnragdolled(player, state, ragdoll)
	player:SetSharedVar("fallenOver", false);
end;

-- Called to check if a player does have a flag.
function CloudScript:PlayerDoesHaveFlag(player, flag)
	if ( string.find(self.config:Get("default_flags"):Get(), flag) ) then
		return true;
	end;
end;

-- Called to check if a player does have door access.
function CloudScript:PlayerDoesHaveDoorAccess(player, door, access, isAccurate)
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
function CloudScript:PlayerDoesRecognisePlayer(player, target, status, isAccurate, realValue)
	return realValue;
end;

-- Called to check if a player does have an item.
function CloudScript:PlayerDoesHaveItem(player, itemTable) return false; end;

-- Called when a player attempts to lock an entity.
function CloudScript:PlayerCanLockEntity(player, entity)
	if ( self.entity:IsDoor(entity) ) then
		return self.player:HasDoorAccess(player, entity);
	else
		return true;
	end;
end;

-- Called when a player's class has been set.
function CloudScript:PlayerClassSet(player, newClass, oldClass, noRespawn, addDelay, noModelChange) end;

-- Called when a player attempts to unlock an entity.
function CloudScript:PlayerCanUnlockEntity(player, entity)
	if ( self.entity:IsDoor(entity) ) then
		return self.player:HasDoorAccess(player, entity);
	else
		return true;
	end;
end;

-- Called when a player attempts to use a door.
function CloudScript:PlayerCanUseDoor(player, door)
	if ( self.entity:GetOwner(door) and !self.player:HasDoorAccess(player, door) ) then
		return false;
	end;
	
	if ( self.entity:IsDoorFalse(door) ) then
		return false;
	end;
	
	return true;
end;

-- Called when a player uses a door.
function CloudScript:PlayerUseDoor(player, door) end;

-- Called when a player attempts to use an entity in a vehicle.
function CloudScript:PlayerCanUseEntityInVehicle(player, entity, vehicle)
	if ( entity.UsableInVehicle or self.entity:IsDoor(entity) ) then
		return true;
	end;
end;

-- Called when a player's ragdoll attempts to decay.
function CloudScript:PlayerCanRagdollDecay(player, ragdoll, seconds)
	return true;
end;

-- Called when a player attempts to exit a vehicle.
function CloudScript:CanExitVehicle(vehicle, player)
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
function CloudScript:PlayerLeaveVehicle(player, vehicle)
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
function CloudScript:PlayerEnteredVehicle(player, vehicle, class)
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
function CloudScript:PlayerCanChangeClass(player, class)
	local curTime = CurTime();
	
	if (player.nextChangeClass and curTime < player.nextChangeClass) then
		self.player:Notify(player, "You cannot change class for another "..math.ceil(player.nextChangeClass - curTime).." second(s)!");
		
		return false;
	else
		return true;
	end;
end;

-- Called when a player attempts to earn generator cash.
function CloudScript:PlayerCanEarnGeneratorCash(player, info, cash)
	return true;
end;

-- Called when a player earns generator cash.
function CloudScript:PlayerEarnGeneratorCash(player, info, cash) end;

-- Called when a player attempts to earn wages cash.
function CloudScript:PlayerCanEarnWagesCash(player, cash)
	return true;
end;

-- Called when a player is given wages cash.
function CloudScript:PlayerGiveWagesCash(player, cash, wagesName)
	return true;
end;

-- Called when a player earns wages cash.
function CloudScript:PlayerEarnWagesCash(player, cash) end;

-- Called when CloudScript has loaded all of the entities.
function CloudScript:CloudScriptInitPostEntity() end;

-- Called when a player attempts to say something in-character.
function CloudScript:PlayerCanSayIC(player, text)
	if ( ( !player:Alive() or player:IsRagdolled(RAGDOLL_FALLENOVER) ) and !self.player:GetDeathCode(player, true) ) then
		self.player:Notify(player, "You don't have permission to do this right now!");
		
		return false;
	else
		return true;
	end;
end;

-- Called when a player attempts to say something out-of-character.
function CloudScript:PlayerCanSayOOC(player, text) return true; end;

-- Called when a player attempts to say something locally out-of-character.
function CloudScript:PlayerCanSayLOOC(player, text) return true; end;

-- Called when attempts to use a command.
function CloudScript:PlayerCanUseCommand(player, commandTable, arguments) return true; end;

-- Called when a player says something.
function CloudScript:PlayerSay(player, text, public)
	text = CloudScript:Replace(text, " ' ", "'");
	text = CloudScript:Replace(text, " : ", ":");
	
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
		
		self.command:ConsoleCommand(player, "cloud", arguments);
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
function CloudScript:CanPlayerSuicide(player) return false; end;

-- Called when a player attempts to punt an entity with the gravity gun.
function CloudScript:GravGunPunt(player, entity)
	return self.config:Get("enable_gravgun_punt"):Get();
end;

-- Called when a player attempts to pickup an entity with the gravity gun.
function CloudScript:GravGunPickupAllowed(player, entity)
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
function CloudScript:GravGunOnPickedUp(player, entity)
	player.isHoldingEntity = entity;
	entity.isBeingHeld = player;
end;

-- Called when a player drops an entity with the gravity gun.
function CloudScript:GravGunOnDropped(player, entity)
	player.isHoldingEntity = nil;
	entity.isBeingHeld = nil;
end;

-- Called when a player attempts to unfreeze an entity.
function CloudScript:CanPlayerUnfreeze(player, entity, physicsObject)
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
function CloudScript:OnPhysgunFreeze(weapon, physicsObject, entity, player)
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
function CloudScript:PhysgunPickup(player, entity)
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
function CloudScript:PhysgunDrop(player, entity)
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
function CloudScript:PlayerSpawnNPC(player, model)
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
function CloudScript:OnNPCKilled(entity, attacker, inflictor) end;

-- Called to get whether an entity is being held.
function CloudScript:GetEntityBeingHeld(entity)
	return entity.isBeingHeld or entity:IsPlayerHolding();
end;

-- Called when an entity is removed.
function CloudScript:EntityRemoved(entity)
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
function CloudScript:EntityHandleMenuOption(player, entity, option, arguments)
	local class = entity:GetClass();
	local generator = self.generator:Get(class);
	
	if ( class == "cloud_item" and (arguments == "cloud_itemTake" or arguments == "cloud_itemUse") ) then
		if ( self.entity:BelongsToAnotherCharacter(player, entity) ) then
			self.player:Notify(player, "You cannot pick up items you dropped on another character!");
			
			return;
		end;
		
		player:EmitSound("physics/body/body_medium_impact_soft"..math.random(1, 7)..".wav");
		
		local itemTable = entity.itemTable;
		local quickUse = (arguments == "cloud_itemUse");
		
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
					
					if ( !self.player:RunCloudScriptCommand(player, "InvAction", itemTable.uniqueID, "use") ) then
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
	elseif (class == "cloud_item" and arguments == "cloud_itemAmmo") then
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
	elseif (class == "cloud_shipment" and arguments == "cloud_shipmentOpen") then
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
	elseif (class == "cloud_cash" and arguments == "cloud_cashTake") then
		if ( self.entity:BelongsToAnotherCharacter(player, entity) ) then
			self.player:Notify(player, "You cannot pick up "..self.option:GetKey("name_cash", true).." you dropped on another character!");
			
			return;
		end;
		
		self.player:GiveCash( player, entity:GetDTInt("amount"), self.option:GetKey("name_cash") );
		player:EmitSound("physics/body/body_medium_impact_soft"..math.random(1, 7)..".wav");
		player:FakePickup(entity);
		
		entity:Remove();
	elseif (generator and arguments == "cloud_generatorSupply") then
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
function CloudScript:PlayerSpawnedProp(player, model, entity)
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
function CloudScript:PlayerSpawnProp(player, model)
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
function CloudScript:PlayerSpawnRagdoll(player, model)
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
function CloudScript:PlayerSpawnEffect(player, model)
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
function CloudScript:PlayerSpawnVehicle(player, model)
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
function CloudScript:CanTool(player, trace, tool)
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
function CloudScript:PlayerNoClip(player)
	if ( player:IsRagdolled() ) then
		return false;
	elseif ( player:IsSuperAdmin() ) then
		return true;
	else
		return false;
	end;
end;

-- Called when a player's character has initialized.
function CloudScript:PlayerCharacterInitialized(player)
	umsg.Start("cloud_InventoryClear", player);
	umsg.End();
	
	umsg.Start("cloud_AttributesClear", player);
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
function CloudScript:PlayerDeathCodeUsed(player, commandTable, arguments) end;

-- Called when a player has created a character.
function CloudScript:PlayerCharacterCreated(player, character) end;

-- Called when a player's character has unloaded.
function CloudScript:PlayerCharacterUnloaded(player)
	self.player:SetupRemovePropertyDelays(player);
	self.player:DisableProperty(player);
	self.player:SetRagdollState(player, RAGDOLL_RESET);
	self.player:CloseStorage(player, true)
	
	player:SetTeam(TEAM_UNASSIGNED);
end;

-- Called when a player's character has loaded.
function CloudScript:PlayerCharacterLoaded(player)
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
	
	hook.Call( "PlayerRestoreCharacterData", CloudScript, player, player:QueryCharacter("data") );
	hook.Call( "PlayerRestoreTempData", CloudScript, player, player:CreateTempData() );
	
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
function CloudScript:PlayerReturnProperty(player) end;

-- Called when config has initialized for a player.
function CloudScript:PlayerConfigInitialized(player)
	self.plugin:Call("PlayerSendDataStreamInfo", player);
	
	if ( player:IsBot() ) then
		self.plugin:Call("PlayerDataStreamInfoSent", player);
	else
		timer.Simple(FrameTime() * 32, function()
			if ( IsValid(player) ) then
				umsg.Start("cloud_DataStreaming", player);
				umsg.End();
			end;
		end);
	end;
end;

-- Called when a player has used their radio.
function CloudScript:PlayerRadioUsed(player, text, listeners, eavesdroppers) end;

-- Called when a player's drop weapon info should be adjusted.
function CloudScript:PlayerAdjustDropWeaponInfo(player, info)
	return true;
end;

-- Called when a player's character creation info should be adjusted.
function CloudScript:PlayerAdjustCharacterCreationInfo(player, info, data) end;

-- Called when a player's earn generator info should be adjusted.
function CloudScript:PlayerAdjustEarnGeneratorInfo(player, info) end;

-- Called when a player's order item should be adjusted.
function CloudScript:PlayerAdjustOrderItemTable(player, itemTable) end;

-- Called when a player's next punch info should be adjusted.
function CloudScript:PlayerAdjustNextPunchInfo(player, info) end;

-- Called when a player has an unknown inventory item.
function CloudScript:PlayerHasUnknownInventoryItem(player, inventory, item, amount) end;

-- Called when a player uses an unknown item function.
function CloudScript:PlayerUseUnknownItemFunction(player, itemTable, itemFunction) end;

-- Called when a player has an unknown attribute.
function CloudScript:PlayerHasUnknownAttribute(player, attributes, attribute, amount, progress) end;

-- Called when a player's character table should be adjusted.
function CloudScript:PlayerAdjustCharacterTable(player, character)
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
function CloudScript:PlayerAdjustCharacterScreenInfo(player, character, info) end;

-- Called when a player's prop cost info should be adjusted.
function CloudScript:PlayerAdjustPropCostInfo(player, entity, info) end;

-- Called when a player's death info should be adjusted.
function CloudScript:PlayerAdjustDeathInfo(player, info) end;

-- Called when chat box info should be adjusted.
function CloudScript:ChatBoxAdjustInfo(info) end;

-- Called when a chat box message has been added.
function CloudScript:ChatBoxMessageAdded(info) end;

-- Called when a player's radio text should be adjusted.
function CloudScript:PlayerAdjustRadioInfo(player, info) end;

-- Called when a player should gain a frag.
function CloudScript:PlayerCanGainFrag(player, victim) return true; end;

-- Called when a player's model should be set.
function CloudScript:PlayerSetModel(player)
	self.player:SetDefaultModel(player);
	self.player:SetDefaultSkin(player);
end;

-- Called just after a player spawns.
function CloudScript:PostPlayerSpawn(player, lightSpawn, changeClass, firstSpawn)
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
function CloudScript:PlayerShouldTakeDamage(player, attacker, inflictor, damageInfo)
	if ( self.player:IsNoClipping(player) ) then
		return false;
	end;
	
	return true;
end;

-- Called when a player is attacked by a trace.
function CloudScript:PlayerTraceAttack(player, damageInfo, direction, trace)
	player.lastHitGroup = trace.HitGroup;
	
	return false;
end;

-- Called just before a player dies.
function CloudScript:DoPlayerDeath(player, attacker, damageInfo)
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
function CloudScript:PlayerDeath(player, inflictor, attacker, damageInfo)
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
function CloudScript:PlayerLoadout(player)
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
		self.player:GiveSpawnWeapon(player, "cloud_hands");
	end;
	
	if ( self.config:Get("give_keys"):Get() ) then
		self.player:GiveSpawnWeapon(player, "cloud_keys");
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
		player:SelectWeapon("cloud_hands");
	end;
end

-- Called when the server shuts down.
function CloudScript:ShutDown()
	self.ShuttingDown = true;
end;

-- Called when a player presses F1.
function CloudScript:ShowHelp(player)
	umsg.Start("cloud_InfoToggle", player);
	umsg.End();
end;

-- Called when a player presses F2.
function CloudScript:ShowTeam(player)
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
				umsg.Start("cloud_RecogniseMenu", player);
				umsg.End();
			end;
		end;
	end;
end;

-- Called when a player selects a custom character option.
function CloudScript:PlayerSelectCustomCharacterOption(player, action, character) end;

-- Called when a player takes damage.
function CloudScript:PlayerTakeDamage(player, inflictor, attacker, hitGroup, damageInfo)
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
function CloudScript:EntityTakeDamage(entity, inflictor, attacker, amount, damageInfo)
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
function CloudScript:PlayerDeathSound(player) return true; end;

-- Called when a player attempts to spawn a SWEP.
function CloudScript:PlayerSpawnSWEP(player, class, weapon)
	if ( !player:IsSuperAdmin() ) then
		return false;
	else
		return true;
	end;
end;

-- Called when a player is given a SWEP.
function CloudScript:PlayerGiveSWEP(player, class, weapon)
	if ( !player:IsSuperAdmin() ) then
		return false;
	else
		return true;
	end;
end;

-- Called when attempts to spawn a SENT.
function CloudScript:PlayerSpawnSENT(player, class)
	if ( !player:IsSuperAdmin() ) then
		return false;
	else
		return true;
	end;
end;

-- Called when a player presses a key.
function CloudScript:KeyPress(player, key)
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
function CloudScript:KeyRelease(player, key)
	if (key == IN_RELOAD and player.reloadHoldTime) then
		player.reloadHoldTime = nil;
	end;
end;

-- A function to get the game description.
function CloudScript:GetGameDescription()
	return "[CS-"..self:GetCoreVersion().."] "..self.schema:GetName();
end;

-- A function to setup a player's visibility.
function CloudScript:SetupPlayerVisibility(player)
	local ragdollEntity = player:GetRagdollEntity();
	local curTime = CurTime();
	
	if (ragdollEntity) then
		AddOriginToPVS( ragdollEntity:GetPos() );
	end;
	
	if ( player:HasInitialized() ) then
		if (!player.nextThink) then
			player.nextThink = curTime + 0.5;
		end;
		
		if (!player.nextSetSharedVars) then
			player.nextSetSharedVars = curTime + 3;
		end;
		
		if (curTime >= player.nextThink) then
			self.player:CallThinkHook(player, (curTime >= player.nextSetSharedVars), {}, curTime);
		end;
	end;
end;

CloudScript:HookDataStream("RecogniseOption", function(player, data)
	if ( CloudScript.config:Get("recognise_system"):Get() ) then
		if (type(data) == "string") then
			local talkRadius = CloudScript.config:Get("talk_radius"):Get();
			local playSound = false;
			local position = player:GetPos();
			
			for k, v in ipairs( _player.GetAll() ) do
				if (v:HasInitialized() and player != v) then
					if ( !CloudScript.player:IsNoClipping(v) ) then
						local distance = v:GetPos():Distance(position);
						local recognise = false;
						
						if (data == "whisper") then
							if ( distance <= math.min(talkRadius / 3, 80) ) then
								recognise = true;
							end;
						elseif (data == "yell") then
							if (distance <= talkRadius * 2) then
								recognise = true;
							end;
						elseif (data == "talk") then
							if (distance <= talkRadius) then
								recognise = true;
							end;
						end;
						
						if (recognise) then
							CloudScript.player:SetRecognises(v, player, RECOGNISE_SAVE);
							
							if (!playSound) then
								playSound = true;
							end;
						end;
					end;
				end;
			end;
			
			if (playSound) then
				CloudScript.player:PlaySound(player, "buttons/button17.wav");
			end;
		end;
	end;
end);

CloudScript:HookDataStream("Door", function(player, data)
	if ( IsValid( data[1] ) and player:GetEyeTraceNoCursor().Entity == data[1] ) then
		if (data[1]:GetPos():Distance( player:GetPos() ) <= 192) then
			if (data[2] == "Purchase") then
				if ( !CloudScript.entity:GetOwner( data[1] ) ) then
					if ( hook.Call( "PlayerCanOwnDoor", CloudScript, player, data[1] ) ) then
						local doors = CloudScript.player:GetDoorCount(player);
						
						if ( doors == CloudScript.config:Get("max_doors"):Get() ) then
							CloudScript.player:Notify(player, "You cannot purchase another door!");
						else
							local doorCost = CloudScript.config:Get("door_cost"):Get();
							
							if ( doorCost == 0 or CloudScript.player:CanAfford(player, doorCost) ) then
								local doorName = CloudScript.entity:GetDoorName( data[1] );
								
								if (doorName == "false" or doorName == "hidden" or doorName == "") then
									doorName = "Door";
								end;
								
								if (doorCost > 0) then
									CloudScript.player:GiveCash(player, -doorCost, doorName);
								end;
								
								CloudScript.player:GiveDoor( player, data[1] );
							else
								local amount = doorCost - CloudScript.player:GetCash(player);
								CloudScript.player:Notify(player, "You need another "..FORMAT_CASH(amount, nil, true).."!");
							end;
						end;
					end;
				end;
			elseif (data[2] == "Access") then
				if ( CloudScript.player:HasDoorAccess(player, data[1], DOOR_ACCESS_COMPLETE) ) then
					if ( IsValid( data[3] ) and data[3] != player and data[3] != CloudScript.entity:GetOwner( data[1] ) ) then
						if (data[4] == DOOR_ACCESS_COMPLETE) then
							if ( CloudScript.player:HasDoorAccess(data[3], data[1], DOOR_ACCESS_COMPLETE) ) then
								CloudScript.player:GiveDoorAccess(data[3], data[1], DOOR_ACCESS_BASIC);
							else
								CloudScript.player:GiveDoorAccess(data[3], data[1], DOOR_ACCESS_COMPLETE);
							end;
						elseif (data[4] == DOOR_ACCESS_BASIC) then
							if ( CloudScript.player:HasDoorAccess(data[3], data[1], DOOR_ACCESS_BASIC) ) then
								CloudScript.player:TakeDoorAccess( data[3], data[1] );
							else
								CloudScript.player:GiveDoorAccess(data[3], data[1], DOOR_ACCESS_BASIC);
							end;
						end;
						
						if ( CloudScript.player:HasDoorAccess(data[3], data[1], DOOR_ACCESS_COMPLETE) ) then
							CloudScript:StartDataStream( player, "DoorAccess", {data[3], DOOR_ACCESS_COMPLETE} );
						elseif ( CloudScript.player:HasDoorAccess(data[3], data[1], DOOR_ACCESS_BASIC) ) then
							CloudScript:StartDataStream( player, "DoorAccess", {data[3], DOOR_ACCESS_BASIC} );
						else
							CloudScript:StartDataStream( player, "DoorAccess", { data[3] } );
						end;
					end;
				end;
			elseif (data[2] == "Unshare") then
				if ( CloudScript.entity:IsDoorParent( data[1] ) ) then
					if (data[3] == "Text") then
						CloudScript:StartDataStream(player, "SetSharedText", false);
						
						data[1].sharedText = nil;
					else
						CloudScript:StartDataStream(player, "SetSharedAccess", false);
						
						data[1].sharedAccess = nil;
					end;
				end;
			elseif (data[2] == "Share") then
				if ( CloudScript.entity:IsDoorParent( data[1] ) ) then
					if (data[3] == "Text") then
						CloudScript:StartDataStream(player, "SetSharedText", true);
						
						data[1].sharedText = true;
					else
						CloudScript:StartDataStream(player, "SetSharedAccess", true);
						
						data[1].sharedAccess = true;
					end;
				end;
			elseif (data[2] == "Text" and data[3] != "") then
				if ( CloudScript.player:HasDoorAccess(player, data[1], DOOR_ACCESS_COMPLETE) ) then
					if ( !string.find(string.gsub(string.lower( data[3] ), "%s", ""), "thisdoorcanbepurchased")
					and string.find(data[3], "%w") ) then
						CloudScript.entity:SetDoorText( data[1], string.sub(data[3], 1, 32) );
					end;
				end;
			elseif (data[2] == "Sell") then
				if (CloudScript.entity:GetOwner( data[1] ) == player) then
					if ( !CloudScript.entity:IsDoorUnsellable( data[1] ) ) then
						CloudScript.player:TakeDoor( player, data[1] );
					end;
				end;
			end;
		end;
	end;
end);

CloudScript:HookDataStream("DataStreamInfoSent", function(player, data)
	if (!player.dataStreamInfoSent) then
		CloudScript.plugin:Call("PlayerDataStreamInfoSent", player);
		
		timer.Simple(FrameTime() * 32, function()
			if ( IsValid(player) ) then
				umsg.Start("cloud_DataStreamed", player);
				umsg.End();
			end;
		end);
		
		player.dataStreamInfoSent = true;
	end;
end);

CloudScript:HookDataStream("LocalPlayerCreated", function(player, data)
	if ( IsValid(player) and !player:HasConfigInitialized() ) then
		CloudScript:CreateTimer("send_cfg_"..player:UniqueID(), FrameTime() * 64, 1, function()
			if ( IsValid(player) ) then
				CloudScript.config:Send(player);
			end;
		end);
	end;
end);

CloudScript:HookDataStream("UnequipItem", function(player, data)
	local arguments = nil;
	local uniqueID = data;
	
	if (type(data) == "table") then
		arguments = data[2];
		uniqueID = data[1];
	end;
	
	if (type(uniqueID) == "string") then
		if ( player:Alive() and !player:IsRagdolled() ) then
			local itemTable = CloudScript.item:Get(uniqueID);
			
			if (itemTable and itemTable.OnPlayerUnequipped and itemTable.HasPlayerEquipped) then
				if ( itemTable:HasPlayerEquipped(player, arguments) ) then
					itemTable:OnPlayerUnequipped(player, arguments);
					
					player:RebuildInventory();
				end;
			end;
		end;
	end;
end);

CloudScript:HookDataStream("GetTargetRecognises", function(player, data)
	if ( ValidEntity(data) and data:IsPlayer() ) then
		player:SetSharedVar( "targetRecognises", CloudScript.player:DoesRecognise(data, player) );
	end;
end);

CloudScript:HookDataStream("EntityMenuOption", function(player, data)
	local entity = data[1];
	local option = data[2];
	local shootPos = player:GetShootPos();
	local arguments = data[3];
	
	if (IsValid(entity) and type(option) == "string") then
		if (entity:NearestPoint(shootPos):Distance(shootPos) <= 80) then
			if ( CloudScript.plugin:Call("PlayerUse", player, entity) ) then
				CloudScript.plugin:Call("EntityHandleMenuOption", player, entity, option, arguments);
			end;
		end;
	end;
end);

CloudScript:HookDataStream("CreateCharacter", function(player, data)
	if (!player.creatingCharacter) then
		local minimumPhysDesc = CloudScript.config:Get("minimum_physdesc"):Get();
		local attributesTable = CloudScript.attribute:GetAll();
		local factionTable = CloudScript.faction:Get(data.faction);
		local attributes;
		local info = {};
		
		if (table.Count(attributesTable) > 0) then
			for k, v in pairs(attributesTable) do
				if (v.characterScreen) then
					attributes = true;
					
					break;
				end;
			end;
		end;
		
		if (factionTable) then
			info.attributes = {};
			info.faction = factionTable.name;
			info.gender = data.gender;
			info.model = data.model;
			info.data = {};
			
			if (attributes and type(data.attributes) == "table") then
				local maximumPoints = CloudScript.config:Get("default_attribute_points"):Get();
				local pointsSpent = 0;
				
				if (factionTable.attributePointsScale) then
					maximumPoints = math.Round(maximumPoints * factionTable.attributePointsScale);
				end;
				
				if (factionTable.maximumAttributePoints) then
					maximumPoints = factionTable.maximumAttributePoints;
				end;
				
				for k, v in pairs(data.attributes) do
					local attributeTable = CloudScript.attribute:Get(k);
					
					if (attributeTable and attributeTable.characterScreen) then
						local uniqueID = attributeTable.uniqueID;
						local amount = math.Clamp(v, 0, attributeTable.maximum);
						
						info.attributes[uniqueID] = {
							amount = amount,
							progress = 0
						};
						
						pointsSpent = pointsSpent + amount;
					end;
				end;
				
				if (pointsSpent > maximumPoints) then
					return CloudScript.player:CreationError(player, "You have chosen more "..CloudScript.option:GetKey("name_attribute", true).." points than you can afford to spend!");
				end;
			elseif (attributes) then
				return CloudScript.player:CreationError(player, "You did not choose any "..CloudScript.option:GetKey("name_attributes", true).." or the ones that you did are not valid!");
			end;
			
			if (!factionTable.GetName) then
				if (!factionTable.useFullName) then
					if (data.forename and data.surname) then
						data.forename = string.gsub(data.forename, "^.", string.upper);
						data.surname = string.gsub(data.surname, "^.", string.upper);
						
						if ( string.find(data.forename, "[%p%s%d]") or string.find(data.surname, "[%p%s%d]") ) then
							return CloudScript.player:CreationError(player, "Your forename and surname must not contain punctuation, spaces or digits!");
						end;
						
						if ( !string.find(data.forename, "[aeiou]") or !string.find(data.surname, "[aeiou]") ) then
							return CloudScript.player:CreationError(player, "Your forename and surname must both contain at least one vowel!");
						end;
						
						if ( string.len(data.forename) < 2 or string.len(data.surname) < 2) then
							return CloudScript.player:CreationError(player, "Your forename and surname must both be at least 2 characters long!");
						end;
						
						if ( string.len(data.forename) > 16 or string.len(data.surname) > 16) then
							return CloudScript.player:CreationError(player, "Your forename and surname must not be greater than 16 characters long!");
						end;
					else
						return CloudScript.player:CreationError(player, "You did not choose a name, or the name that you chose is not valid!");
					end;
				elseif (!data.fullName or data.fullName == "") then
					return CloudScript.player:CreationError(player, "You did not choose a name, or the name that you chose is not valid!");
				end;
			end;
			
			if (CloudScript.command:Get("CharPhysDesc") != nil) then
				if (type(data.physDesc) != "string") then
					return CloudScript.player:CreationError(player, "You did not enter a physical description!");
				elseif (string.len(data.physDesc) < minimumPhysDesc) then
					return CloudScript.player:CreationError(player, "The physical description must be at least "..minimumPhysDesc.." characters long!");
				end;
				
				info.data["physdesc"] = CloudScript:ModifyPhysDesc(data.physDesc);
			end;
			
			if (!factionTable.GetModel and !info.model) then
				return CloudScript.player:CreationError(player, "You did not choose a model, or the model that you chose is not valid!");
			end;
			
			if ( !CloudScript.faction:IsGenderValid(info.faction, info.gender) ) then
				return CloudScript.player:CreationError(player, "You did not choose a gender, or the gender that you chose is not valid!");
			end;
			
			if ( factionTable.whitelist and !CloudScript.player:IsWhitelisted(player, info.faction) ) then
				return CloudScript.player:CreationError(player, "You are not on the "..info.faction.." whitelist!");
			elseif ( CloudScript.faction:IsModelValid(factionTable.name, info.gender, info.model) or (factionTable.GetModel and !info.model) ) then
				local charactersTable = CloudScript.config:Get("mysql_characters_table"):Get();
				local schemaFolder = CloudScript:GetSchemaFolder();
				local characterID = nil;
				local characters = player:GetCharacters();
				
				if ( CloudScript.faction:HasReachedMaximum(player, factionTable.name) ) then
					return CloudScript.player:CreationError(player, "You cannot create any more characters in this faction.");
				end;
				
				for i = 1, CloudScript.player:GetMaximumCharacters(player) do
					if ( !characters[i] ) then
						characterID = i; break;
					end;
				end;
				
				if (characterID) then
					if (factionTable.GetName) then
						info.name = factionTable:GetName(player, info, data);
					elseif (!factionTable.useFullName) then
						info.name = data.forename.." "..data.surname;
					else
						info.name = data.fullName;
					end;
					
					if (factionTable.GetModel) then
						info.model = factionTable:GetModel(player, info, data);
					else
						info.model = data.model;
					end;
					
					if (factionTable.OnCreation) then
						local fault = factionTable:OnCreation(player, info);
						
						if (fault == false or type(fault) == "string") then
							return CloudScript.player:CreationError(player, fault or "There was an error creating this character!");
						end;
					end;
					
					for k, v in pairs(characters) do
						if (v.name == info.name) then
							return CloudScript.player:CreationError(player, "You already have a character with the name '"..info.name.."'!");
						end;
					end;
					
					local fault = CloudScript.plugin:Call("PlayerAdjustCharacterCreationInfo", player, info, data);
					
					if (fault == false or type(fault) == "string") then
						return CloudScript.player:CreationError(player, fault or "There was an error creating this character!");
					end;
					
					tmysql.query("SELECT * FROM "..charactersTable.." WHERE _Schema = \""..schemaFolder.."\" AND _Name = \""..tmysql.escape(info.name).."\"", function(result)
						if ( IsValid(player) ) then
							if (result and type(result) == "table" and #result > 0) then
								CloudScript.player:CreationError(player, "A character with the name '"..info.name.."' already exists!");
								
								player.creatingCharacter = nil;
							else
								CloudScript.player:LoadCharacter( player, characterID, {
									attributes = info.attributes,
									faction = info.faction,
									gender = info.gender,
									model = info.model,
									name = info.name,
									data = info.data
								}, function()
									CloudScript:PrintLog(4, player:SteamName().." has created a "..info.faction.." character called '"..info.name.."'.");
									
									umsg.Start("cloud_CharacterFinish", player)
										umsg.Bool(true);
									umsg.End();
									
									player.creatingCharacter = nil;
								end);
							end;
						end;
					end, 1);
					
					player.creatingCharacter = true;
				else
					return CloudScript.player:CreationError(player, "You cannot create any more characters!");
				end;
			else
				return CloudScript.player:CreationError(player, "You did not choose a model, or the model that you chose is not valid!");
			end;
		else
			return CloudScript.player:CreationError(player, "You did not choose a faction, or the faction that you chose is not valid!");
		end;
	end;
end);

CloudScript:HookDataStream("InteractCharacter", function(player, data)
	local characterID = data.characterID;
	local action = data.action;
	
	if (characterID and action) then
		local character = player:GetCharacters()[characterID];
		
		if (character) then
			local fault = CloudScript.plugin:Call("PlayerCanInteractCharacter", player, action, character);
			
			if (fault == false or type(fault) == "string") then
				return CloudScript.player:CreationError(fault or "You cannot interact with this character!");
			elseif (action == "delete") then
				local success, fault = CloudScript.player:DeleteCharacter(player, characterID);
				
				if (!success) then
					CloudScript.player:CreationError(player, fault);
				end;
			elseif (action == "use") then
				local success, fault = CloudScript.player:UseCharacter(player, characterID);
				
				if (!success) then
					CloudScript.player:CreationError(player, fault);
				end;
			else
				CloudScript.plugin:Call("PlayerSelectCustomCharacterOption", player, action, character);
			end;
		end;
	end;
end);

CloudScript:HookDataStream("QuizAnswer", function(player, data)
	if (!player.quizAnswers) then
		player.quizAnswers = {};
	end;
	
	local question = data[1];
	local answer = data[2];
	
	if ( CloudScript.quiz:GetQuestion(question) ) then
		player.quizAnswers[question] = answer;
	end;
end);

CloudScript:HookDataStream("QuizCompleted", function(player, data)
	if ( player.quizAnswers and !CloudScript.quiz:GetCompleted(player) ) then
		local questionsAmount = CloudScript.quiz:GetQuestionsAmount();
		local correctAnswers = 0;
		local quizQuestions = CloudScript.quiz:GetQuestions();
		
		for k, v in pairs(quizQuestions) do
			if ( player.quizAnswers[k] ) then
				if ( CloudScript.quiz:IsAnswerCorrect( k, player.quizAnswers[k] ) ) then
					correctAnswers = correctAnswers + 1;
				end;
			end;
		end;
		
		if ( correctAnswers < math.Round( questionsAmount * (CloudScript.quiz:GetPercentage() / 100) ) ) then
			CloudScript.quiz:CallKickCallback(player, correctAnswers);
		else
			CloudScript.quiz:SetCompleted(player, true);
		end;
	end;
end);

CloudScript:HookDataStream("GetQuizStatus", function(player, data)
	if ( !CloudScript.quiz:GetEnabled() or CloudScript.quiz:GetCompleted(player) ) then
		umsg.Start("cloud_QuizCompleted", player);
			umsg.Bool(true);
		umsg.End();
	else
		umsg.Start("cloud_QuizCompleted", player);
			umsg.Bool(false);
		umsg.End();
	end;
end);

local entityMeta = FindMetaTable("Entity");
local playerMeta = FindMetaTable("Player");

playerMeta.CloudScriptSetCrouchedWalkSpeed = playerMeta.SetCrouchedWalkSpeed;
playerMeta.CloudScriptLastHitGroup = playerMeta.LastHitGroup;
playerMeta.CloudScriptSetJumpPower = playerMeta.SetJumpPower;
playerMeta.CloudScriptSetWalkSpeed = playerMeta.SetWalkSpeed;
playerMeta.CloudScriptStripWeapons = playerMeta.StripWeapons;
playerMeta.CloudScriptSetRunSpeed = playerMeta.SetRunSpeed;
entityMeta.CloudScriptSetMaterial = entityMeta.SetMaterial;
playerMeta.CloudScriptStripWeapon = playerMeta.StripWeapon;
entityMeta.CloudScriptFireBullets = entityMeta.FireBullets;
playerMeta.CloudScriptGodDisable = playerMeta.GodDisable;
entityMeta.CloudScriptExtinguish = entityMeta.Extinguish;
entityMeta.CloudScriptWaterLevel = entityMeta.WaterLevel;
playerMeta.CloudScriptGodEnable = playerMeta.GodEnable;
entityMeta.CloudScriptSetHealth = entityMeta.SetHealth;
entityMeta.CloudScriptSetColor = entityMeta.SetColor;
entityMeta.CloudScriptIsOnFire = entityMeta.IsOnFire;
entityMeta.CloudScriptSetModel = entityMeta.SetModel;
playerMeta.CloudScriptSetArmor = playerMeta.SetArmor;
entityMeta.CloudScriptSetSkin = entityMeta.SetSkin;
entityMeta.CloudScriptAlive = playerMeta.Alive;
playerMeta.CloudScriptGive = playerMeta.Give;
playerMeta.SteamName = playerMeta.Name;

-- A function to get a player's name.
function playerMeta:Name()
	return self:QueryCharacter( "name", self:SteamName() );
end;

-- A function to make a player fire bullets.
function entityMeta:FireBullets(bulletInfo)
	if ( self:IsPlayer() ) then
		CloudScript.plugin:Call("PlayerAdjustBulletInfo", self, bulletInfo);
	end;
	
	return self:CloudScriptFireBullets(bulletInfo);
end;

-- A function to get whether a player is alive.
function playerMeta:Alive()
	if (!self.fakingDeath) then
		return self:CloudScriptAlive();
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
	CloudScript.player:SaveCharacter(self);
end;

-- A function to give a player an item weapon.
function playerMeta:GiveItemWeapon(item)
	CloudScript.player:GiveItemWeapon(self, item);
end;

-- A function to give a weapon to a player.
function playerMeta:Give(class, uniqueID, forceReturn)
	if ( !CloudScript.plugin:Call("PlayerCanBeGivenWeapon", self, class, uniqueID, forceReturn) ) then
		return;
	end;
	
	local itemTable = CloudScript.item:GetWeapon(class, uniqueID);
	local teamIndex = self:Team();
	
	if (self:IsRagdolled() and !forceReturn) then
		local ragdollWeapons = self:GetRagdollWeapons();
		local spawnWeapon = CloudScript.player:GetSpawnWeapon(self, class);
		local canHolster;
		
		if ( itemTable and CloudScript.plugin:Call("PlayerCanHolsterWeapon", self, itemTable, true, true) ) then
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
			self:CloudScriptGive(class);
		self.forceGive = nil;
		
		local weapon = self:GetWeapon(class);
		
		if ( IsValid(weapon) ) then
			if (itemTable) then
				CloudScript.player:StripDefaultAmmo(self, weapon, itemTable);
				CloudScript.player:RestorePrimaryAmmo(self, weapon);
				CloudScript.player:RestoreSecondaryAmmo(self, weapon);
			end;
			
			if (uniqueID and uniqueID != "") then
				weapon:SetNetworkedString("uniqueID", uniqueID);
			end;
		else
			return true;
		end;
	end;
	
	CloudScript.plugin:Call("PlayerGivenWeapon", self, class, uniqueID, forceReturn);
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
	
	self:CloudScriptSetSkin(skin);
end;

-- A function to set an entity's model.
function entityMeta:SetModel(model)
	if ( self:IsPlayer() and self:IsRagdolled() ) then
		self:GetRagdollEntity():SetModel(model);
	end;
	
	self:CloudScriptSetModel(model);
	CloudScript.plugin:Call("PlayerModelChanged", self, model);
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
	return CloudScript.entity:IsMapEntity(self);
end;

-- A function to get an entity's start position.
function entityMeta:GetStartPosition()
	return CloudScript.entity:GetStartPosition(self);
end;

-- A function to set an entity's material.
function entityMeta:SetMaterial(material)
	if ( self:IsPlayer() and self:IsRagdolled() ) then
		self:GetRagdollEntity():SetMaterial(material);
	end;
	
	self:CloudScriptSetMaterial(material);
end;

-- A function to set an entity's color.
function entityMeta:SetColor(r, g, b, a)
	if ( self:IsPlayer() and self:IsRagdolled() ) then
		self:GetRagdollEntity():SetColor(r, g, b, a);
	end;
	
	self:CloudScriptSetColor(r, g, b, a);
end;

-- A function to set a player's armor.
function playerMeta:SetArmor(armor)
	local oldArmor = self:Armor();
	
	self:CloudScriptSetArmor(armor);
	CloudScript.plugin:Call("PlayerArmorSet", self, armor, oldArmor);
end;

-- A function to set a player's health.
function playerMeta:SetHealth(health)
	local oldHealth = self:Health();
	
	self:CloudScriptSetHealth(health);
	CloudScript.plugin:Call("PlayerHealthSet", self, health, oldHealth);
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
		self:CloudScriptStripWeapon(weaponClass);
	end;
end;

-- A function to handle a player's attribute progress.
function playerMeta:HandleAttributeProgress(curTime)
	if (self.attributeProgressTime and curTime >= self.attributeProgressTime) then
		self.attributeProgressTime = curTime + 30;
		
		for k, v in pairs(self.attributeProgress) do
			local attributeTable = CloudScript.attribute:Get(k);
			
			if (attributeTable) then
				umsg.Start("cloud_AttributeProgress", self);
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
		self:CloudScriptStripWeapons();
	end;
end;

-- A function to enable God for a player.
function playerMeta:GodEnable()
	self.godMode = true; self:CloudScriptGodEnable();
end;

-- A function to disable God for a player.
function playerMeta:GodDisable()
	self.godMode = nil; self:CloudScriptGodDisable();
end;

-- A function to get whether a player has God mode enabled.
function playerMeta:IsInGodMode()
	return self.godMode;
end;

-- A function to update whether a player's weapon is raised.
function playerMeta:UpdateWeaponRaised()
	CloudScript.player:UpdateWeaponRaised(self);
end;

-- A function to get a player's water level.
function playerMeta:WaterLevel()
	if ( self:IsRagdolled() ) then
		return self:GetRagdollEntity():WaterLevel();
	else
		return self:CloudScriptWaterLevel();
	end;
end;

-- A function to get whether a player is on fire.
function playerMeta:IsOnFire()
	if ( self:IsRagdolled() ) then
		return self:GetRagdollEntity():IsOnFire();
	else
		return self:CloudScriptIsOnFire();
	end;
end;

-- A function to extinguish a player.
function playerMeta:Extinguish()
	if ( self:IsRagdolled() ) then
		return self:GetRagdollEntity():Extinguish();
	else
		return self:CloudScriptExtinguish();
	end;
end;

-- A function to get whether a player is using their hands.
function playerMeta:IsUsingHands()
	return CloudScript.player:GetWeaponClass(self) == "cloud_hands";
end;

-- A function to get whether a player is using their hands.
function playerMeta:IsUsingKeys()
	return CloudScript.player:GetWeaponClass(self) == "cloud_keys";
end;

-- A function to get a player's wages.
function playerMeta:GetWages()
	return CloudScript.player:GetWages(self);
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
	return CloudScript.player:IsRagdolled(self, exception, entityless);
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
	CloudScript:AddBan(self:SteamID(), duration * 60, reason);
end;

-- A function to get a player's character table.
function playerMeta:GetCharacter() return CloudScript.player:GetCharacter(self); end;

-- A function to get a player's storage table.
function playerMeta:GetStorageTable() return CloudScript.player:GetStorageTable(self); end;
 
-- A function to get a player's ragdoll table.
function playerMeta:GetRagdollTable() return CloudScript.player:GetRagdollTable(self); end;

-- A function to get a player's ragdoll state.
function playerMeta:GetRagdollState() return CloudScript.player:GetRagdollState(self); end;

-- A function to get a player's storage entity.
function playerMeta:GetStorageEntity() return CloudScript.player:GetStorageEntity(self); end;

-- A function to get a player's ragdoll entity.
function playerMeta:GetRagdollEntity() return CloudScript.player:GetRagdollEntity(self); end;

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
	return self.lastHitGroup or self:CloudScriptLastHitGroup();
end;

-- A function to get whether an entity is being held.
function entityMeta:IsBeingHeld()
	if ( IsValid(self) ) then
		return CloudScript.plugin:Call("GetEntityBeingHeld", self);
	end;
end;

-- A function to run a command on a player.
function playerMeta:RunCommand(...)
	CloudScript:StartDataStream( self, "RunCommand", {...} );
end;

-- A function to get a player's wages name.
function playerMeta:GetWagesName()
	return CloudScript.player:GetWagesName(self);
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
				CloudScript:CreateTimer("forced_anim_"..self:UniqueID(), delay, 1, function()
					if ( IsValid(self) ) then
						local forcedAnimation = self:GetForcedAnimation();
						
						if (forcedAnimation) then
							self:SetForcedAnimation(false);
						end;
					end;
				end);
			else
				CloudScript:DestroyTimer( "forced_anim_"..self:UniqueID() );
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
	
	if ( !CloudScript.TempPlayerData[uniqueID] ) then
		CloudScript.TempPlayerData[uniqueID] = {};
	end;
	
	return CloudScript.TempPlayerData[uniqueID];
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

-- A function to set the player's CloudScript user group.
function playerMeta:SetCloudScriptUserGroup(userGroup)
	if (self:GetCloudScriptUserGroup() != userGroup) then
		self.userGroup = userGroup;
		self:SaveCharacter();
	end;
end;

-- A function to get the player's CloudScript user group.
function playerMeta:GetCloudScriptUserGroup()
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
	return CloudScript.inventory:HasItem(self, item, anywhere);
end;

-- A function to get a player's attribute boosts.
function playerMeta:GetAttributeBoosts()
	return self.attributeBoosts;
end;

-- A function to rebuild a player's inventory.
function playerMeta:RebuildInventory()
	CloudScript.inventory:Rebuild(self);
end;

-- A function to update a player's inventory.
function playerMeta:UpdateInventory(item, amount, force, noMessage)
	return CloudScript.inventory:Update(self, item, amount, force, noMessage);
end;

-- A function to update a player's attribute.
function playerMeta:UpdateAttribute(attribute, amount)
	return CloudScript.attributes:Update(self, attribute, amount);
end;

-- A function to progress a player's attribute.
function playerMeta:ProgressAttribute(attribute, amount, gradual)
	return CloudScript.attributes:Progress(self, attribute, amount, gradual);
end;

-- A function to boost a player's attribute.
function playerMeta:BoostAttribute(identifier, attribute, amount, duration)
	return CloudScript.attributes:Boost(self, identifier, attribute, amount, duration);
end;

-- A function to get whether a boost is active for a player.
function playerMeta:IsBoostActive(identifier, attribute, amount, duration)
	return CloudScript.attributes:IsBoostActive(self, identifier, attribute, amount, duration);
end;

-- A function to get a player's characters.
function playerMeta:GetCharacters()
	return self.characters;
end;

-- A function to set a player's run speed.
function playerMeta:SetRunSpeed(speed, CloudScript)
	if (!CloudScript) then self.runSpeed = speed; end;
	
	self:CloudScriptSetRunSpeed(speed);
end;

-- A function to set a player's walk speed.
function playerMeta:SetWalkSpeed(speed, CloudScript)
	if (!CloudScript) then self.walkSpeed = speed; end;
	
	self:CloudScriptSetWalkSpeed(speed);
end;

-- A function to set a player's jump power.
function playerMeta:SetJumpPower(power, CloudScript)
	if (!CloudScript) then self.jumpPower = power; end;
	
	self:CloudScriptSetJumpPower(power);
end;

-- A function to set a player's crouched walk speed.
function playerMeta:SetCrouchedWalkSpeed(speed, CloudScript)
	if (!CloudScript) then self.crouchedSpeed = speed; end;
	
	self:CloudScriptSetCrouchedWalkSpeed(speed);
end;

-- A function to get whether a player has initialized.
function playerMeta:HasInitialized()
	return self.initialized;
end;

-- A function to query a player's character table.
function playerMeta:QueryCharacter(key, default)
	if ( self:GetCharacter() ) then
		return CloudScript.player:Query(self, key, default);
	else
		return default;
	end;
end;

-- A function to get a player's shared variable.
function entityMeta:GetSharedVar(key)
	if ( self:IsPlayer() ) then
		return CloudScript.player:GetSharedVar(self, key);
	else
		return CloudScript.entity:GetSharedVar(self, key);
	end;
end;

-- A function to set a shared variable for a player.
function entityMeta:SetSharedVar(key, value)
	if ( self:IsPlayer() ) then
		CloudScript.player:SetSharedVar(self, key, value);
	else
		CloudScript.entity:SetSharedVar(self, key, value);
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