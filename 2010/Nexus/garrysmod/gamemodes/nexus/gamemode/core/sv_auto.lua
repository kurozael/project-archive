--[[
Name: "sv_auto.lua".
Product: "nexus".
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
resource.AddFile("materials/nexus/nexusthree.vtf");
resource.AddFile("materials/nexus/nexusthree.vmt");
resource.AddFile("models/police_animations.ani");
resource.AddFile("models/police_animations.mdl");
resource.AddFile("models/humans/female_ss.ani");
resource.AddFile("models/humans/female_ss.mdl");
resource.AddFile("materials/nexus/unknown.vtf");
resource.AddFile("materials/nexus/unknown.vmt");
resource.AddFile("models/humans/male_ss.ani");
resource.AddFile("models/humans/male_ss.mdl");
resource.AddFile("models/police_ss.ani");
resource.AddFile("models/police_ss.mdl");

CreateConVar("npc_thinknow", 1);

AddCSLuaFile("sh_enums.lua");
AddCSLuaFile("sh_core.lua");
AddCSLuaFile("sh_auto.lua");
AddCSLuaFile("cl_auto.lua");

include("sh_auto.lua");

local introImage = nexus.schema.GetOption("intro_image");
local CurTime = CurTime;
local hook = hook;

if (introImage != "") then
	resource.AddFile("materials/"..introImage..".vtf");
	resource.AddFile("materials/"..introImage..".vmt");
end;

_R["CRecipientFilter"].IsValid = function()
	return true;
end;

hook.NexusCall = hook.Call;

-- A function to call a hook.
function hook.Call(name, gamemode, ...)
	local callCachedHook = nexus.mount.CallCachedHook;
	local arguments = {...};
	local hookCall = hook.NexusCall;
	
	if (!gamemode) then
		gamemode = NEXUS;
	end;
	
	if (name == "EntityTakeDamage") then
		if ( NEXUS:DoEntityTakeDamageHook(gamemode, arguments) ) then
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
	
	local value = callCachedHook(name, arguments);
	
	if (value == nil) then
		return hookCall( name, gamemode, unpack(arguments) );
	else
		return value;
	end;
end;

-- Called when the server initializes.
function NEXUS:Initialize()
	local useLocalMachineDate = nexus.config.Get("use_local_machine_date"):Get();
	local useLocalMachineTime = nexus.config.Get("use_local_machine_time"):Get();
	local defaultDate = nexus.schema.GetOption("default_date");
	local defaultTime = nexus.schema.GetOption("default_time");
	local defaultDays = nexus.schema.GetOption("default_days");
	local username = nexus.config.Get("mysql_username"):Get();
	local password = nexus.config.Get("mysql_password"):Get();
	local database = nexus.config.Get("mysql_database"):Get();
	local dateInfo = os.date("*t");
	local host = nexus.config.Get("mysql_host"):Get();
	
	local success, value = pcall(tmysql.initialize, host, username, password, database, 3306, 6, 6);
		NEXUS.NoMySQL = !success;
		
	if (useLocalMachineTime) then
		nexus.config.Get("minute_time"):Set(60);
	end;
	
	nexus.config.SetInitialized(true);
	
	table.Merge(nexus.time, defaultTime);
	table.Merge(nexus.date, defaultDate);
	
	math.randomseed( os.time() );
	
	if (useLocalMachineTime) then
		local realDay = dateInfo.wday - 1;
		
		if (realDay == 0) then
			realDay = #defaultDays;
		end;
		
		table.Merge( nexus.time, {
			minute = dateInfo.min,
			hour = dateInfo.hour,
			day = realDay
		} );
		
		self.NextDateTimeThink = SysTime() + (60 - dateInfo.sec);
	else
		table.Merge( nexus.time, self:RestoreSchemaData("time") );
	end;
	
	if (useLocalMachineDate) then
		dateInfo.year = dateInfo.year + (defaultDate.year - dateInfo.year);
		
		table.Merge( nexus.time, {
			month = dateInfo.month,
			year = dateInfo.year,
			day = dateInfo.yday
		} );
	else
		table.Merge( nexus.date, self:RestoreSchemaData("date") );
	end;
	
	NX_CONVAR_DEBUG = self:CreateConVar("nx_debug", 1);
	NX_CONVAR_LOG = self:CreateConVar("nx_log", 1)
	
	for k, v in pairs(nexus.config.stored) do
		nexus.mount.Call("NexusConfigInitialized", k, v.value);
	end;
	
	RunConsoleCommand("sv_usermessage_maxsize", "1024");
		nexus.mount.Call("NexusInitialized");
	self:LoadBans();
end;

-- Called when a player has disconnected.
function NEXUS:PlayerDisconnected(player)
	local tempData = player:CreateTempData();
	
	if ( player:HasInitialized() ) then
		player:SaveCharacter();
		
		nexus.mount.Call("PlayerCharacterUnloaded", player);
		
		if (tempData) then
			nexus.mount.Call("PlayerSaveTempData", player, tempData);
		end;
		
		nexus.chatBox.Add(nil, nil, "disconnect", player:SteamName().." has disconnected from the server.");
		
		self:PrintDebug(player:SteamName().." ("..player:SteamID().."|"..player:IPAddress()..") has disconnected from the server.");
	end;
end;

-- Called when the nexus core has loaded.
function NEXUS:NexusCoreLoaded()
	nexus.config.Import("nexus/mysql.cfg");
end;

-- Called when nexus has initialized.
function NEXUS:NexusInitialized()
	local cashName = nexus.schema.GetOption("name_cash");
	
	if ( !nexus.config.Get("cash_enabled"):Get() ) then
		nexus.command.SetHidden(string.gsub(cashName, "%s", "").."Give", true);
		nexus.command.SetHidden(string.gsub(cashName, "%s", "").."Drop", true);
		nexus.command.SetHidden("StorageTakeCash", true);
		nexus.command.SetHidden("StorageGiveCash", true);
		
		nexus.config.Get("scale_prop_cost"):Set(0, nil, true, true);
		nexus.config.Get("door_cost"):Set(0, nil, true, true);
	end;
end;

-- Called when a player is banned.
function NEXUS:PlayerBanned(player, duration, reason) end;

-- Called when a player's model has changed.
function NEXUS:PlayerModelChanged(player, model) end;

-- Called when a player's inventory string is needed.
function NEXUS:PlayerGetInventoryString(player, character, inventory)
	if ( player:IsRagdolled() ) then
		for k, v in pairs( player:GetRagdollWeapons() ) do
			if (v.canHolster) then
				local class = v.weaponData["class"];
				local uniqueID = v.weaponData["uniqueID"];
				local itemTable = nexus.item.GetWeapon(class, uniqueID);
				
				if (itemTable) then
					if ( !nexus.player.GetSpawnWeapon(player, class) ) then
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
		local itemTable = nexus.item.GetWeapon(v);
		
		if (itemTable) then
			if ( !nexus.player.GetSpawnWeapon(player, class) ) then
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
function NEXUS:PlayerGetUnlockInfo(player, entity)
	if ( nexus.entity.IsDoor(entity) ) then
		return {
			duration = nexus.config.Get("unlock_time"):Get(),
			Callback = function(player, entity)
				entity:Fire("unlock", "", 0);
			end
		};
	end;
end;

-- Called when a player's lock info is needed.
function NEXUS:PlayerGetLockInfo(player, entity)
	if ( nexus.entity.IsDoor(entity) ) then
		return {
			duration = nexus.config.Get("lock_time"):Get(),
			Callback = function(player, entity)
				entity:Fire("lock", "", 0);
			end
		};
	end;
end;

-- Called when data should be saved.
function NEXUS:SaveData()
	for k, v in ipairs( g_Player.GetAll() ) do
		if ( v:HasInitialized() ) then
			v:SaveCharacter();
		end;
	end;
	
	if ( !nexus.config.Get("use_local_machine_time"):Get() ) then
		self:SaveSchemaData( "time", nexus.time.GetSaveData() );
	end;
	
	if ( !nexus.config.Get("use_local_machine_date"):Get() ) then
		self:SaveSchemaData( "date", nexus.date.GetSaveData() );
	end;
end;

-- Called when a player attempts to fire a weapon.
function NEXUS:PlayerCanFireWeapon(player, raised, weapon, secondary)
	local canShootTime = player.canShootTime;
	local curTime = CurTime();
	
	if (nexus.config.Get("raised_weapon_system"):Get() and !raised) then
		if ( !nexus.mount.Call("PlayerCanUseLoweredWeapon", player, weapon, secondary) ) then
			return false;
		end;
	end;
	
	if (canShootTime and canShootTime > curTime) then
		return false;
	end;
	
	return true;
end;

-- Called when a player attempts to use a lowered weapon.
function NEXUS:PlayerCanUseLoweredWeapon(player, weapon, secondary)
	if (secondary) then
		return weapon.NeverRaised or (weapon.Secondary and weapon.Secondary.NeverRaised);
	else
		return weapon.NeverRaised or (weapon.Primary and weapon.Primary.NeverRaised);
	end;
end;

-- Called when a player's recognised names have been cleared.
function NEXUS:PlayerRecognisedNamesCleared(player, status, simple) end;

-- Called when a player's name has been cleared.
function NEXUS:PlayerNameCleared(player, status, simple) end;

-- Called when an offline player has been given property.
function NEXUS:PlayerPropertyGivenOffline(key, uniqueID, entity, networked, removeDelay) end;

-- Called when an offline player has had property taken.
function NEXUS:PlayerPropertyTakenOffline(key, uniqueID, entity) end;

-- Called when a player has been given property.
function NEXUS:PlayerPropertyGiven(player, entity, networked, removeDelay) end;

-- Called when a player has had property taken.
function NEXUS:PlayerPropertyTaken(player, entity) end;

-- Called when a player's visibility should be set up.
function NEXUS:SetupPlayerVisibility(player)
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
			nexus.player.CallThinkHook(player, (curTime >= player.nextSetSharedVars), {}, curTime);
		end;
	end;
end;

-- Called when a player has been given flags.
function NEXUS:PlayerFlagsGiven(player, flags)
	if ( string.find(flags, "p") and player:Alive() ) then
		nexus.player.GiveSpawnWeapon(player, "weapon_physgun");
	end;
	
	if ( string.find(flags, "t") and player:Alive() ) then
		nexus.player.GiveSpawnWeapon(player, "gmod_tool");
	end;
	
	player:SetSharedVar( "sh_Flags", player:QueryCharacter("flags") );
end;

-- Called when a player has had flags taken.
function NEXUS:PlayerFlagsTaken(player, flags)
	if ( string.find(flags, "p") and player:Alive() ) then
		if ( !nexus.player.HasFlags(player, "p") ) then
			nexus.player.TakeSpawnWeapon(player, "weapon_physgun");
		end;
	end;
	
	if ( string.find(flags, "t") and player:Alive() ) then
		if ( !nexus.player.HasFlags(player, "t") ) then
			nexus.player.TakeSpawnWeapon(player, "gmod_tool");
		end;
	end;
	
	player:SetSharedVar( "sh_Flags", player:QueryCharacter("flags") );
end;

-- Called when the game description is needed.
function NEXUS:GetGameDescription()
	if (SCHEMA and SCHEMA.name != "Base") then
		return SCHEMA.name;
	else
		return self.Name;
	end;
end;

-- Called when a player's phys desc override is needed.
function NEXUS:GetPlayerPhysDescOverride(player, physDesc) end;

-- Called when a player's default skin is needed.
function NEXUS:GetPlayerDefaultSkin(player)
	local model, skin = nexus.class.GetAppropriateModel(player:Team(), player);
	
	return skin;
end;

-- Called when a player's default model is needed.
function NEXUS:GetPlayerDefaultModel(player)
	local model, skin = nexus.class.GetAppropriateModel(player:Team(), player);
	
	return model;
end;

-- Called when a player's default inventory is needed.
function NEXUS:GetPlayerDefaultInventory(player, character, inventory) end;

-- Called to get whether a player's weapon is raised.
function NEXUS:GetPlayerWeaponRaised(player, class, weapon)
	if (class == "weapon_physgun" or class == "weapon_physcannon" or class == "gmod_tool") then
		return true;
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
end;

-- Called when a player's attribute has been updated.
function NEXUS:PlayerAttributeUpdated(player, attributeTable, amount) end;

-- Called when a player's inventory item has been updated.
function NEXUS:PlayerInventoryItemUpdated(player, itemTable, amount, force)
	nexus.player.UpdateStorageForPlayer(player, itemTable.uniqueID);
end;

-- Called when a player's cash has been updated.
function NEXUS:PlayerCashUpdated(player, amount, reason, noMessage)
	nexus.player.UpdateStorageForPlayer(player);
end;

-- A function to scale damage by hit group.
function NEXUS:PlayerScaleDamageByHitGroup(player, attacker, hitGroup, damageInfo, baseDamage)
	if ( attacker:IsVehicle() or ( attacker:IsPlayer() and attacker:InVehicle() ) ) then
		damageInfo:ScaleDamage(0.25);
	end;
end;

-- Called when a player switches their flashlight on or off.
function NEXUS:PlayerSwitchFlashlight(player, on)
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
function NEXUS:TimePassed(quantity) end;

-- Called when nexus config has initialized.
function NEXUS:NexusConfigInitialized(key, value)
	if (key == "cash_enabled" and !value) then
		for k, v in pairs( nexus.item.GetAll() ) do
			v.cost = 0;
		end;
	elseif (key == "local_voice") then
		if (value) then
			RunConsoleCommand("sv_alltalk", "0");
		end;
	elseif (key == "use_optimised_rates") then
		if (value) then
			RunConsoleCommand("sv_client_cmdrate_difference", "1");
			RunConsoleCommand("sv_client_max_interp_ratio", "-1");
			RunConsoleCommand("sv_client_min_interp_ratio", "-1");
			RunConsoleCommand("sv_client_interpolate", "1");
			RunConsoleCommand("sv_client_predict", "1");
			RunConsoleCommand("sv_maxupdaterate", "66");
			RunConsoleCommand("sv_minupdaterate", "33");
			RunConsoleCommand("sv_maxcmdrate", "66");
			RunConsoleCommand("sv_mincmdrate", "33");
			RunConsoleCommand("sv_maxrate", "40000");
			RunConsoleCommand("sv_minrate", "30000");
		end;
	end;
end;

-- Called when a nexus ConVar has changed.
function NEXUS:NexusConVarChanged(name, previousValue, newValue)
	if (name == "local_voice" and newValue) then
		RunConsoleCommand("sv_alltalk", "1");
	end;
end;

-- Called when nexus config has changed.
function NEXUS:NexusConfigChanged(key, data, previousValue, newValue)
	if (key == "default_flags") then
		for k, v in ipairs( g_Player.GetAll() ) do
			if ( v:HasInitialized() and v:Alive() ) then
				if ( string.find(previousValue, "p") ) then
					if ( !string.find(newValue, "p") ) then
						if ( !nexus.player.HasFlags(v, "p") ) then
							nexus.player.TakeSpawnWeapon(v, "weapon_physgun");
						end;
					end;
				elseif ( !string.find(previousValue, "p") ) then
					if ( string.find(newValue, "p") ) then
						nexus.player.GiveSpawnWeapon(v, "weapon_physgun");
					end;
				end;
				
				if ( string.find(previousValue, "t") ) then
					if ( !string.find(newValue, "t") ) then
						if ( !nexus.player.HasFlags(v, "t") ) then
							nexus.player.TakeSpawnWeapon(v, "gmod_tool");
						end;
					end;
				elseif ( !string.find(previousValue, "t") ) then
					if ( string.find(newValue, "t") ) then
						nexus.player.GiveSpawnWeapon(v, "gmod_tool");
					end;
				end;
			end;
		end;
	elseif (key == "crouched_speed") then
		for k, v in ipairs( g_Player.GetAll() ) do
			v:SetCrouchedWalkSpeed(newValue);
		end;
	elseif (key == "ooc_interval") then
		for k, v in ipairs( g_Player.GetAll() ) do
			v.nextTalkOOC = nil;
		end;
	elseif (key == "jump_power") then
		for k, v in ipairs( g_Player.GetAll() ) do
			v:SetJumpPower(newValue);
		end;
	elseif (key == "walk_speed") then
		for k, v in ipairs( g_Player.GetAll() ) do
			v:SetWalkSpeed(newValue);
		end;
	elseif (key == "run_speed") then
		for k, v in ipairs( g_Player.GetAll() ) do
			v:SetRunSpeed(newValue);
		end;
	end;
end;

-- Called when a player's name has changed.
function NEXUS:PlayerNameChanged(player, previousName, newName) end;

-- Called when a player attempts to sprays their tag.
function NEXUS:PlayerSpray(player)
	if ( !player:Alive() or player:IsRagdolled() ) then
		return true;
	else
		return nexus.config.Get("disable_sprays"):Get();
	end;
end;

-- Called when a player attempts to use an entity.
function NEXUS:PlayerUse(player, entity)
	if ( player:IsRagdolled(RAGDOLL_FALLENOVER) ) then
		return false;
	else
		return true;
	end;
end;

-- Called when a player's move data is set up.
function NEXUS:SetupMove(player, moveData)
	if ( player:Alive() and !player:IsRagdolled() ) then
		local frameTime = FrameTime();
		local curTime = CurTime();
		local drunk = nexus.player.GetDrunk(player);
		
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
function NEXUS:PlayerPunchThrown(player) end;

-- Called when a player knocks on a door.
function NEXUS:PlayerKnockOnDoor(player, door) end;

-- Called when a player attempts to knock on a door.
function NEXUS:PlayerCanKnockOnDoor(player, door) return true; end;

-- Called when a player punches an entity.
function NEXUS:PlayerPunchEntity(player, entity) end;

-- Called when a player orders an item shipment.
function NEXUS:PlayerOrderShipment(player, itemTable, entity) end;

-- Called when a player holsters a weapon.
function NEXUS:PlayerHolsterWeapon(player, itemTable, forced)
	if (itemTable.OnHolster) then
		itemTable:OnHolster(player, forced);
	end;
end;

-- Called when a player attempts to save a recognised name.
function NEXUS:PlayerCanSaveRecognisedName(player, target)
	if (player != target) then return true; end;
end;

-- Called when a player attempts to restore a recognised name.
function NEXUS:PlayerCanRestoreRecognisedName(player, target)
	if (player != target) then return true; end;
end;

-- Called when a player attempts to order an item shipment.
function NEXUS:PlayerCanOrderShipment(player, itemTable)
	return true;
end;

-- Called when a player attempts to get up.
function NEXUS:PlayerCanGetUp(player) return true; end;

-- Called when a player knocks out a player with a punch.
function NEXUS:PlayerPunchKnockout(player, target) end;

-- Called when a player attempts to throw a punch.
function NEXUS:PlayerCanThrowPunch(player) return true; end;

-- Called when a player attempts to punch an entity.
function NEXUS:PlayerCanPunchEntity(player, entity) return true; end;

-- Called when a player attempts to knock a player out with a punch.
function NEXUS:PlayerCanPunchKnockout(player, target) return true; end;

-- Called when a player attempts to bypass the faction limit.
function NEXUS:PlayerCanBypassFactionLimit(player, character) return false; end;

-- Called when a player attempts to bypass the class limit.
function NEXUS:PlayerCanBypassClassLimit(player, class) return false; end;

-- Called when a player's pain sound should be played.
function NEXUS:PlayerPlayPainSound(player, gender, damageInfo, hitGroup)
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
function NEXUS:PlayerDataLoaded(player)
	if ( nexus.config.Get("nexus_intro_enabled"):Get() ) then
		if ( !player:GetData("nexus_intro") ) then
			umsg.Start("nx_NexusIntro", player);
			umsg.End();
			
			player:SetData("nexus_intro", true);
		end;
	end;
end;

-- Called when a player attempts to be given a weapon.
function NEXUS:PlayerCanBeGivenWeapon(player, class, uniqueID, forceReturn)
	return true;
end;

-- Called when a player has been given a weapon.
function NEXUS:PlayerGivenWeapon(player, class, uniqueID, forceReturn)
	nexus.inventory.Rebuild(player);
end;

-- Called when a player attempts to create a character.
function NEXUS:PlayerCanCreateCharacter(player, character, characterID)
	if ( nexus.quiz.GetEnabled() and !nexus.quiz.GetCompleted(player) ) then
		return false, "You have not completed the quiz!";
	else
		return true;
	end;
end;

-- Called when a player attempts to interact with a character.
function NEXUS:PlayerCanInteractCharacter(player, action, character)
	if ( nexus.quiz.GetEnabled() and !nexus.quiz.GetCompleted(player) ) then
		return false, "You have not completed the quiz!";
	else
		return true;
	end;
end;

-- Called when a player's fall damage is needed.
function NEXUS:GetFallDamage(player, velocity)
	local ragdollEntity = nil;
	local position = player:GetPos();
	local damage = math.max( (velocity - 464) * 0.225225225, 0 ) * nexus.config.Get("scale_fall_damage"):Get();
	local filter = {player};
	
	if ( nexus.config.Get("wood_breaks_fall"):Get() ) then
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
function NEXUS:PlayerDataStreamInfoSent(player)
	if ( player:IsBot() ) then
		nexus.player.LoadData(player, function(player)
			nexus.mount.Call("PlayerDataLoaded", player);
			
			local factions = table.ClearKeys(nexus.faction.stored, true);
			local faction = factions[ math.random(1, #factions) ];
			
			if (faction) then
				local genders = {GENDER_MALE, GENDER_FEMALE};
				local gender = faction.singleGender or genders[ math.random(1, #genders) ];
				local models = faction.models[ string.lower(gender) ];
				local model = models[ math.random(1, #models) ];
				
				nexus.player.LoadCharacter( player, 1, {
					faction = faction.name,
					gender = gender,
					model = model,
					name = player:Name(),
					data = {}
				}, function()
					nexus.player.LoadCharacter(player, 1);
				end);
			end;
		end);
	elseif (table.Count(nexus.faction.stored) > 0) then
		nexus.player.LoadData(player, function()
			nexus.mount.Call("PlayerDataLoaded", player);
			
			local whitelisted = player:GetData("whitelisted");
			local steamName = player:SteamName();
			local unixTime = os.time();
			
			nexus.player.SetCharacterMenuState(player, CHARACTER_MENU_OPEN);
			
			for k, v in pairs(whitelisted) do
				if ( nexus.faction.stored[v] ) then
					self:StartDataStream( player, "SetWhitelisted", {v, true} );
				else
					whitelisted[k] = nil;
				end;
			end;
			
			nexus.player.GetCharacters(player, function(characters)
				if (characters) then
					for k, v in pairs(characters) do
						nexus.player.ConvertCharacterMySQL(v);
						
						player.characters[v.characterID] = {};
						
						for k2, v2 in pairs(v.inventory) do
							if ( !nexus.item.GetAll()[k2] ) then
								if ( !nexus.mount.Call("PlayerHasUnknownInventoryItem", player, v.inventory, k2, v2) ) then
									v.inventory[k2] = nil;
								end;
							end;
						end;
						
						for k2, v2 in pairs(v.attributes) do
							if ( !nexus.attribute.GetAll()[k2] ) then
								if ( !nexus.mount.Call("PlayerHasUnknownAttribute", player, v.attributes, k2, v2.amount, v2.progress) ) then
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
						local delete = nexus.mount.Call("PlayerAdjustCharacterTable", player, v);
						
						if (!delete) then
							nexus.player.CharacterScreenAdd(player, v);
						else
							nexus.player.ForceDeleteCharacter(player, k);
						end;
					end;
				end;
				
				nexus.player.SetCharacterMenuState(player, CHARACTER_MENU_LOADED);
			end);
		end);
	end;
end;

-- Called when a player's data stream info should be sent.
function NEXUS:PlayerSendDataStreamInfo(player) end;

-- Called when a player's death sound should be played.
function NEXUS:PlayerPlayDeathSound(player, gender)
	return "vo/npc/"..string.lower(gender).."01/pain0"..math.random(1, 9)..".wav";
end;

-- Called when a player's character data should be restored.
function NEXUS:PlayerRestoreCharacterData(player, data)
	if ( data["physdesc"] ) then
		data["physdesc"] = self:ModifyPhysDesc( data["physdesc"] );
	end;
end;

-- Called when a player's character data should be saved.
function NEXUS:PlayerSaveCharacterData(player, data)
	if ( nexus.config.Get("save_attribute_boosts"):Get() ) then
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
function NEXUS:PlayerSaveData(player, data)
	if (data["whitelisted"] and #data["whitelisted"] == 0) then
		data["whitelisted"] = nil;
	end;
end;

-- Called when a player's storage should close.
function NEXUS:PlayerStorageShouldClose(player, storageTable)
	local entity = player:GetStorageEntity();
	
	if ( player:IsRagdolled() or !player:Alive() or !entity or (storageTable.distance and player:GetShootPos():Distance( entity:GetPos() ) > storageTable.distance) ) then
		return true;
	elseif ( storageTable.ShouldClose and storageTable.ShouldClose(player, storageTable) ) then
		return true;
	end;
end;

-- Called when a player attempts to pickup a weapon.
function NEXUS:PlayerCanPickupWeapon(player, weapon)
	if ( player.forceGive or ( player:GetEyeTraceNoCursor().Entity == weapon and player:KeyDown(IN_USE) ) ) then
		return true;
	else
		return false;
	end;
end;

-- Called each tick.
function NEXUS:Tick()
	if (NEXUS_TICK) then
		local sysTime = SysTime();
		local curTime = CurTime();
		
		if (!self.NextHint or curTime >= self.NextHint) then
			nexus.hint.Distribute();
			
			self.NextHint = curTime + nexus.config.Get("hint_interval"):Get();
		end;
		
		if (!self.NextWagesTime or curTime >= self.NextWagesTime) then
			self:DistributeWagesCash();
			self.NextWagesTime = curTime + nexus.config.Get("wages_interval"):Get();
		end;
		
		if (!self.NextGeneratorTime or curTime >= self.NextGeneratorTime) then
			self:DistributeGeneratorCash();
			self.NextGeneratorTime = curTime + nexus.config.Get("generator_interval"):Get();
		end;
		
		if (!self.NextDateTimeThink or sysTime >= self.NextDateTimeThink) then
			self:PerformDateTimeThink();
			self.NextDateTimeThink = sysTime + nexus.config.Get("minute_time"):Get();
		end;
		
		if (!self.NextSaveData or sysTime >= self.NextSaveData) then
			nexus.mount.Call("PreSaveData");
				nexus.mount.Call("SaveData");
			nexus.mount.Call("PostSaveData");
			
			self.NextSaveData = sysTime + nexus.config.Get("save_data_interval"):Get();
		end;
		
		if (!self.NextCheckEmpty) then
			self.NextCheckEmpty = sysTime + 1200;
		end;
		
		if (sysTime >= self.NextCheckEmpty) then
			self.NextCheckEmpty = nil;
			
			if (#g_Player.GetAll() == 0) then
				RunConsoleCommand( "changelevel", game.GetMap() );
			end;
		end;
	end;
end;

-- Called each frame.
function NEXUS:Think()
	self:CallTimerThink( CurTime() );
end;

-- Called when a player's shared variables should be set.
function NEXUS:PlayerSetSharedVars(player, curTime)
	local weaponClass = nexus.player.GetWeaponClass(player);
	local r, g, b, a = player:GetColor();
	local drunk = nexus.player.GetDrunk(player);
	
	player:HandleAttributeProgress(curTime);
	player:HandleAttributeBoosts(curTime);
	
	player:SetSharedVar( "sh_PhysDesc", player:GetCharacterData("physdesc") );
	player:SetSharedVar( "sh_Flags", player:QueryCharacter("flags") );
	player:SetSharedVar( "sh_Model", player:QueryCharacter("model") );
	player:SetSharedVar( "sh_Name", player:QueryCharacter("name") );
	player:SetSharedVar( "sh_Cash", nexus.player.GetCash(player) );
	
	if ( nexus.config.Get("enable_temporary_damage"):Get() ) then
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
	
	if (player.drunk) then
		for k, v in pairs(player.drunk) do
			if (curTime >= v) then
				table.remove(player.drunk, k);
			end;
		end;
	end;
	
	if (drunk) then
		player:SetSharedVar("sh_Drunk", drunk);
	else
		player:SetSharedVar("sh_Drunk", 0);
	end;
end;

-- Called at an interval while a player is connected.
function NEXUS:PlayerThink(player, curTime, infoTable)
	local storageTable = player:GetStorageTable();
	
	if ( !nexus.config.Get("cash_enabled"):Get() ) then
		player:SetCharacterData("cash", 0, true);
		
		infoTable.wages = 0;
	end;
	
	if (player.reloadHoldTime and curTime >= player.reloadHoldTime) then
		nexus.player.ToggleWeaponRaised(player);
		
		player.reloadHoldTime = nil;
		player.canShootTime = curTime + nexus.config.Get("shoot_after_raise_time"):Get();
	end;
	
	if ( player:IsRagdolled() ) then
		player:SetMoveType(MOVETYPE_OBSERVER);
	elseif ( player:Alive() ) then
		nexus.player.PreserveAmmo(player);
	end;
	
	if (storageTable) then
		if (hook.Call( "PlayerStorageShouldClose", self, player, storageTable) ) then
			nexus.player.CloseStorage(player);
		end;
	end;
	
	player:SetSharedVar( "sh_InventoryWeight", math.ceil(infoTable.inventoryWeight) );
	player:SetSharedVar( "sh_Wages", math.ceil(infoTable.wages) );
	
	if (infoTable.running == false or infoTable.runSpeed < infoTable.walkSpeed) then
		infoTable.runSpeed = infoTable.walkSpeed;
	end;
	
	if (infoTable.jogging) then
		infoTable.walkSpeed = infoTable.walkSpeed * 1.75;
	end;
	
	player:UpdateWeaponRaised();
	player:SetCrouchedWalkSpeed(math.max(infoTable.crouchedSpeed, 0), true);
	player:SetWalkSpeed(math.max(infoTable.walkSpeed, 0), true);
	player:SetJumpPower(math.max(infoTable.jumpPower, 0), true);
	player:SetRunSpeed(math.max(infoTable.runSpeed, 0), true);
end;

-- Called when a player uses an item.
function NEXUS:PlayerUseItem(player, itemTable, itemEntity) end;

-- Called when a player drops an item.
function NEXUS:PlayerDropItem(player, itemTable, position, entity)
	if ( IsValid(entity) and nexus.item.IsWeapon(itemTable) ) then
		entity.data.sClip = nexus.player.TakeSecondaryAmmo(player, itemTable.weaponClass);
		entity.data.pClip = nexus.player.TakePrimaryAmmo(player, itemTable.weaponClass);
	end;
end;

-- Called when a player destroys an item.
function NEXUS:PlayerDestroyItem(player, itemTable) end;

-- Called when a player drops a weapon.
function NEXUS:PlayerDropWeapon(player, itemTable, entity)
	if ( IsValid(entity) ) then
		entity.data.sClip = nexus.player.TakeSecondaryAmmo(player, itemTable.weaponClass);
		entity.data.pClip = nexus.player.TakePrimaryAmmo(player, itemTable.weaponClass);
	end;
end;

-- Called when a player charges generator.
function NEXUS:PlayerChargeGenerator(player, entity, generator) end;

-- Called when a player destroys generator.
function NEXUS:PlayerDestroyGenerator(player, entity, generator) end;

-- Called when a player's data should be restored.
function NEXUS:PlayerRestoreData(player, data)
	if ( !data["whitelisted"] ) then
		data["whitelisted"] = {};
	end;
end;

-- Called when a player's temporary info should be saved.
function NEXUS:PlayerSaveTempData(player, tempData) end;

-- Called when a player's temporary info should be restored.
function NEXUS:PlayerRestoreTempData(player, tempData) end;

-- Called when a player selects a custom character option.
function NEXUS:PlayerSelectCharacterOption(player, character, option) end;

-- Called when a player attempts to see another player's status.
function NEXUS:PlayerCanSeeStatus(player, target)
	return "# "..target:UserID().." | "..target:Name().." | "..target:SteamName().." | "..target:SteamID().." | "..target:IPAddress();
end;

-- Called when a player attempts to see a player's chat.
function NEXUS:PlayerCanSeePlayersChat(text, teamOnly, listener, speaker)
	return true;
end;

-- Called when a player attempts to hear another player's voice.
function NEXUS:PlayerCanHearPlayersVoice(listener, speaker)
	if ( nexus.config.Get("local_voice"):Get() ) then
		if ( listener:IsRagdolled(RAGDOLL_FALLENOVER) or !listener:Alive() ) then
			return false;
		elseif ( speaker:IsRagdolled(RAGDOLL_FALLENOVER) or !speaker:Alive() ) then
			return false;
		elseif ( listener:GetPos():Distance( speaker:GetPos() ) > nexus.config.Get("talk_radius"):Get() ) then
			return false;
		end;
	end;
	
	return true;
end;

-- Called when a player attempts to delete a character.
function NEXUS:PlayerCanDeleteCharacter(player, character)
	if ( nexus.config.Get("cash_enabled"):Get() ) then
		if ( character.cash < nexus.config.Get("default_cash"):Get() ) then
			if ( !character.data["banned"] ) then
				return "You cannot delete characters with less than "..FORMAT_CASH(nexus.config.Get("default_cash"):Get(), nil, true)..".";
			end;
		end;
	end;
end;

-- Called when a player attempts to switch to a character.
function NEXUS:PlayerCanSwitchCharacter(player, character)
	local fault = nexus.mount.Call("PlayerCanUseCharacter", player, character);
	local canUse = false;
	
	if (fault == nil or fault == true) then
		canUse = true;
	end;
	
	if (!player:Alive() and canUse) then
		return "You cannot switch characters when you are dead!";
	else
		return true;
	end;
end;

-- Called when a player attempts to use a character.
function NEXUS:PlayerCanUseCharacter(player, character)
	if ( character.data["banned"] ) then
		return character.name.." is banned and cannot be used!";
	end;
end;

-- Called when a player's weapons should be given.
function NEXUS:PlayerGiveWeapons(player) end;

-- Called when a player deletes a character.
function NEXUS:PlayerDeleteCharacter(player, character) end;

-- Called when a player's armor is set.
function NEXUS:PlayerArmorSet(player, armor)
	if ( player:IsRagdolled() ) then
		player:GetRagdollTable().armor = armor;
	end;
end;

-- Called when a player's health is set.
function NEXUS:PlayerHealthSet(player, health)
	if ( player:IsRagdolled() ) then
		player:GetRagdollTable().health = health;
	end;
end;

-- Called when a player attempts to own a door.
function NEXUS:PlayerCanOwnDoor(player, door)
	if ( nexus.entity.IsDoorUnownable(door) ) then
		return false;
	else
		return true;
	end;
end;

-- Called when a player attempts to view a door.
function NEXUS:PlayerCanViewDoor(player, door)
	if ( nexus.entity.IsDoorUnownable(door) ) then
		return false;
	end;
	
	return true;
end;

-- Called when a player attempts to holster a weapon.
function NEXUS:PlayerCanHolsterWeapon(player, itemTable, forceHolster, noMessage)
	if ( nexus.player.GetSpawnWeapon(player, itemTable.weaponClass) ) then
		if (!noMessage) then
			nexus.player.Notify(player, "You cannot holster this weapon!");
		end;
		
		return false;
	elseif (itemTable.CanHolsterWeapon) then
		return itemTable:CanHolsterWeapon(player, forceHolster, noMessage);
	else
		return true;
	end;
end;

-- Called when a player attempts to drop a weapon.
function NEXUS:PlayerCanDropWeapon(player, attacker, itemTable, noMessage)
	if ( nexus.player.GetSpawnWeapon(player, itemTable.weaponClass) ) then
		if (!noMessage) then
			nexus.player.Notify(player, "You cannot drop this weapon!");
		end;
		
		return false;
	elseif (itemTable.CanDropWeapon) then
		return itemTable:CanDropWeapon(player, attacker, noMessage);
	else
		return true;
	end;
end;

-- Called when a player attempts to use an item.
function NEXUS:PlayerCanUseItem(player, itemTable, noMessage)
	if ( nexus.item.IsWeapon(itemTable) and nexus.player.GetSpawnWeapon( player, itemTable.weaponClass ) ) then
		if (!noMessage) then
			nexus.player.Notify(player, "You cannot use this weapon!");
		end;
		
		return false;
	else
		return true;
	end;
end;

-- Called when a player attempts to drop an item.
function NEXUS:PlayerCanDropItem(player, itemTable, noMessage) return true; end;

-- Called when a player attempts to destroy an item.
function NEXUS:PlayerCanDestroyItem(player, itemTable, noMessage) return true; end;

-- Called when a player attempts to destroy generator.
function NEXUS:PlayerCanDestroyGenerator(player, entity, generator) return true; end;

-- Called when a player attempts to knockout a player.
function NEXUS:PlayerCanKnockout(player, target) return true; end;

-- Called when a player attempts to use the radio.
function NEXUS:PlayerCanRadio(player, text, listeners, eavesdroppers) return true; end;

-- Called when death attempts to clear a player's name.
function NEXUS:PlayerCanDeathClearName(player, attacker, damageInfo) return false; end;

-- Called when death attempts to clear a player's recognised names.
function NEXUS:PlayerCanDeathClearRecognisedNames(player, attacker, damageInfo) return false; end;

-- Called when a player's ragdoll attempts to take damage.
function NEXUS:PlayerRagdollCanTakeDamage(player, ragdoll, inflictor, attacker, hitGroup, damageInfo)
	if (!attacker:IsPlayer() and player:GetRagdollTable().immunity) then
		if (CurTime() <= player:GetRagdollTable().immunity) then
			return false;
		end;
	end;
	
	return true;
end;

-- Called when a player has been authenticated.
function NEXUS:PlayerAuthed(player, steamID)
	local banTable = self.BanList[ player:IPAddress() ] or self.BanList[steamID];
	
	if (banTable) then
		local unixTime = os.time();
		local timeLeft = banTable.unbanTime - unixTime;
		local hoursLeft = math.Round( math.max(timeLeft / 3600, 0) );
		local minutesLeft = math.Round( math.max(timeLeft / 60, 0) );
		
		if (banTable.unbanTime > 0 and unixTime < banTable.unbanTime) then
			local bannedMessage = nexus.config.Get("banned_message"):Get();
			
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
			player:Kick("You are permanently banned.");
		else
			self:RemoveBan(ipAddress);
			self:RemoveBan(steamID);
		end;
	end;
end;

-- Called when the player attempts to be ragdolled.
function NEXUS:PlayerCanRagdoll(player, state, delay, decay, ragdoll)
	return true;
end;

-- Called when the player attempts to be unragdolled.
function NEXUS:PlayerCanUnragdoll(player, state, ragdoll)
	return true;
end;

-- Called when a player has been ragdolled.
function NEXUS:PlayerRagdolled(player, state, ragdoll)
	player:SetSharedVar("sh_FallenOver", false);
end;

-- Called when a player has been unragdolled.
function NEXUS:PlayerUnragdolled(player, state, ragdoll)
	player:SetSharedVar("sh_FallenOver", false);
end;

-- Called to check if a player does have an flag.
function NEXUS:PlayerDoesHaveFlag(player, flag)
	if ( string.find(nexus.config.Get("default_flags"):Get(), flag) ) then
		return true;
	end;
end;

-- Called to check if a player does have door access.
function NEXUS:PlayerDoesHaveDoorAccess(player, door, access, simple)
	if (nexus.entity.GetOwner(door) == player) then
		return true;
	else
		local key = player:QueryCharacter("key");
		
		if ( door.accessList and door.accessList[key] ) then
			if (simple) then
				return door.accessList[key] == access;
			else
				return door.accessList[key] >= access;
			end;
		end;
	end;
	
	return false;
end;

-- Called to check if a player does know another player.
function NEXUS:PlayerDoesRecognisePlayer(player, target, status, simple, default)
	return default;
end;

-- Called to check if a player does have an item.
function NEXUS:PlayerDoesHaveItem(player, itemTable) return false; end;

-- Called when a player attempts to lock an entity.
function NEXUS:PlayerCanLockEntity(player, entity)
	if ( nexus.entity.IsDoor(entity) ) then
		return nexus.player.HasDoorAccess(player, entity);
	else
		return true;
	end;
end;

-- Called when a player's class has been set.
function NEXUS:PlayerClassSet(player, newClass, oldClass, noRespawn, addDelay, noModelChange) end;

-- Called when a player attempts to unlock an entity.
function NEXUS:PlayerCanUnlockEntity(player, entity)
	if ( nexus.entity.IsDoor(entity) ) then
		return nexus.player.HasDoorAccess(player, entity);
	else
		return true;
	end;
end;

-- Called when a player attempts to use a door.
function NEXUS:PlayerCanUseDoor(player, door)
	if ( nexus.entity.GetOwner(door) and !nexus.player.HasDoorAccess(player, door) ) then
		return false;
	end;
	
	if ( nexus.entity.IsDoorFalse(door) ) then
		return false;
	end;
	
	return true;
end;

-- Called when a player uses a door.
function NEXUS:PlayerUseDoor(player, door) end;

-- Called when a player attempts to use an entity in a vehicle.
function NEXUS:PlayerCanUseEntityInVehicle(player, entity, vehicle)
	if ( entity.UsableInVehicle or nexus.entity.IsDoor(entity) ) then
		return true;
	end;
end;

-- Called when a player's ragdoll attempts to decay.
function NEXUS:PlayerCanRagdollDecay(player, ragdoll, seconds)
	return true;
end;

-- Called when a player attempts to exit a vehicle.
function NEXUS:CanExitVehicle(vehicle, player)
	if ( player.nextExitVehicle and player.nextExitVehicle > CurTime() ) then
		return false;
	end;
	
	if ( IsValid(player) and player:IsPlayer() ) then
		local trace = player:GetEyeTraceNoCursor();
		
		if ( IsValid(trace.Entity) and !trace.Entity:IsVehicle() ) then
			if ( nexus.mount.Call("PlayerCanUseEntityInVehicle", player, trace.Entity, vehicle) ) then
				return false;
			end;
		end;
	end;
	
	if ( nexus.entity.IsChairEntity(vehicle) and !IsValid( vehicle:GetParent() ) ) then
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
function NEXUS:PlayerLeaveVehicle(player, vehicle)
	timer.Simple(FrameTime() * 0.5, function()
		if ( IsValid(player) and !player:InVehicle() ) then
			if ( IsValid(vehicle) ) then
				if ( nexus.entity.IsChairEntity(vehicle) ) then
					local position = player.exitVehicle or vehicle:GetPos();
					local targetPosition = nexus.player.GetSafePosition(player, position, vehicle);
					
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
function NEXUS:PlayerEnteredVehicle(player, vehicle, class)
	timer.Simple(FrameTime() * 0.5, function()
		if ( IsValid(player) ) then
			local model = player:GetModel();
			local class = nexus.animation.GetModelClass(model);
			
			if ( IsValid(vehicle) and !string.find(model, "/player/") ) then
				if (class == "maleHuman" or class == "femaleHuman") then
					if ( nexus.entity.IsChairEntity(vehicle) ) then
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
function NEXUS:PlayerCanChangeClass(player, class)
	local curTime = CurTime();
	
	if (player.nextChangeClass and curTime < player.nextChangeClass) then
		nexus.player.Notify(player, "You cannot change class for another "..math.ceil(player.nextChangeClass - curTime).." second(s)!");
		
		return false;
	else
		return true;
	end;
end;

-- Called when a player attempts to earn generator cash.
function NEXUS:PlayerCanEarnGeneratorCash(player, info, cash)
	return true;
end;

-- Called when a player earns generator cash.
function NEXUS:PlayerEarnGeneratorCash(player, info, cash) end;

-- Called when a player attempts to earn wages cash.
function NEXUS:PlayerCanEarnWagesCash(player, cash)
	return true;
end;

-- Called when a player is given wages cash.
function NEXUS:PlayerGiveWagesCash(player, cash, wagesName)
	return true;
end;

-- Called when a player earns wages cash.
function NEXUS:PlayerEarnWagesCash(player, cash) end;

-- Called when nexus has loaded all of the entities.
function NEXUS:NexusInitPostEntity() end;

-- Called when the map has loaded all the entities.
function NEXUS:InitPostEntity()
	for k, v in ipairs( ents.GetAll() ) do
		if ( IsValid(v) and v:GetModel() ) then
			nexus.entity.SetMapEntity(v, true);
			nexus.entity.SetStartAngles( v, v:GetAngles() );
			nexus.entity.SetStartPosition( v, v:GetPos() );
			
			if ( nexus.entity.SetChairAnimations(v) ) then
				v:SetCollisionGroup(COLLISION_GROUP_WEAPON);
				
				local physicsObject = v:GetPhysicsObject();
				
				if ( IsValid(physicsObject) ) then
					physicsObject:EnableMotion(false);
				end;
			end;
		end;
	end;
	
	nexus.entity.RegisterSharedVars(GetWorldEntity(), self.GlobalSharedVars);
		NEXUS:SetSharedVar("sh_NoMySQL", self.NoMySQL);
	nexus.mount.Call("NexusInitPostEntity");
	
	NEXUS_TICK = true;
end;

-- Called when a player attempts to say something in-character.
function NEXUS:PlayerCanSayIC(player, text)
	if ( ( !player:Alive() or player:IsRagdolled(RAGDOLL_FALLENOVER) ) and !nexus.player.GetDeathCode(player, true) ) then
		nexus.player.Notify(player, "You don't have permission to do this right now!");
		
		return false;
	else
		return true;
	end;
end;

-- Called when a player attempts to say something out-of-character.
function NEXUS:PlayerCanSayOOC(player, text) return true; end;

-- Called when a player attempts to say something locally out-of-character.
function NEXUS:PlayerCanSayLOOC(player, text) return true; end;

-- Called when attempts to use a command.
function NEXUS:PlayerCanUseCommand(player, commandTable, arguments) return true; end;

-- Called when a player says something.
function NEXUS:PlayerSay(player, text, public)
	text = string.Replace(text, " ' ", "'");
	text = string.Replace(text, " : ", ":");
	
	local prefix = nexus.config.Get("command_prefix"):Get();
	local curTime = CurTime();
	
	if (string.sub(text, 1, 2) == "//") then
		text = string.Trim( string.sub(text, 3) );
		
		if (text != "") then
			if ( nexus.mount.Call("PlayerCanSayOOC", player, text) ) then
				if (!player.nextTalkOOC or curTime > player.nextTalkOOC) then
					self:Log("[OOC] "..player:Name()..": "..text);
					
					nexus.chatBox.Add(nil, player, "ooc", text);
					
					player.nextTalkOOC = curTime + nexus.config.Get("ooc_interval"):Get();
				else
					nexus.player.Notify(player, "You cannot cannot talk out-of-character for another "..math.ceil( player.nextTalkOOC - CurTime() ).." second(s)!");
					
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
			if ( nexus.mount.Call("PlayerCanSayLOOC", player, text) ) then
				nexus.chatBox.AddInRadius( player, "looc", text, player:GetPos(), nexus.config.Get("talk_radius"):Get() );
			end;
		end;
	elseif (string.sub(text, 1, 1) == prefix) then
		local prefixLength = string.len(prefix);
		local arguments = self:ExplodeByTags(text, " ", "\"", "\"", true);
		local command = string.sub(arguments[1], prefixLength + 1);
		
		if (nexus.command.stored[command] and nexus.command.stored[command].arguments < 2
		and !nexus.command.stored[command].optionalArguments) then
			text = string.sub(text, string.len(command) + prefixLength + 2);
			
			if (text != "") then
				arguments = {command, text};
			else
				arguments = {command};
			end;
		else
			arguments[1] = command;
		end;
		
		nexus.command.ConsoleCommand(player, "nx", arguments);
	elseif ( nexus.mount.Call("PlayerCanSayIC", player, text) ) then
		nexus.chatBox.AddInRadius( player, "ic", text, player:GetPos(), nexus.config.Get("talk_radius"):Get() );
		
		if ( nexus.player.GetDeathCode(player, true) ) then
			nexus.player.UseDeathCode( player, nil, {text} );
		end;
	end;
	
	if ( nexus.player.GetDeathCode(player) ) then
		nexus.player.TakeDeathCode(player);
	end;
	
	return "";
end;

-- Called when a player attempts to suicide.
function NEXUS:CanPlayerSuicide(player) return false; end;

-- Called when a player attempts to punt an entity with the gravity gun.
function NEXUS:GravGunPunt(player, entity)
	return nexus.config.Get("enable_gravgun_punt"):Get();
end;

-- Called when a player attempts to pickup an entity with the gravity gun.
function NEXUS:GravGunPickupAllowed(player, entity)
	if ( IsValid(entity) ) then
		if ( !nexus.player.IsAdmin(player) and !nexus.entity.IsInteractable(entity) ) then
			return false;
		else
			return self.BaseClass:GravGunPickupAllowed(player, entity);
		end;
	end;
	
	return false;
end;

-- Called when a player picks up an entity with the gravity gun.
function NEXUS:GravGunOnPickedUp(player, entity)
	player.isHoldingEntity = entity;
	entity.isBeingHeld = player;
end;

-- Called when a player drops an entity with the gravity gun.
function NEXUS:GravGunOnDropped(player, entity)
	player.isHoldingEntity = nil;
	entity.isBeingHeld = nil;
end;

-- Called when a player attempts to unfreeze an entity.
function NEXUS:CanPlayerUnfreeze(player, entity, physicsObject)
	local isAdmin = nexus.player.IsAdmin(player);
	
	if (nexus.config.Get("enable_prop_protection"):Get() and !isAdmin) then
		local ownerKey = entity:GetOwnerKey();
		
		if (ownerKey and player:QueryCharacter("key") != ownerKey) then
			return false;
		end;
	end;
	
	if ( !isAdmin and !nexus.entity.IsInteractable(entity) ) then
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
function NEXUS:OnPhysgunFreeze(weapon, physicsObject, entity, player)
	local isAdmin = nexus.player.IsAdmin(player);
	
	if (nexus.config.Get("enable_prop_protection"):Get() and !isAdmin) then
		local ownerKey = entity:GetOwnerKey();
		
		if (ownerKey and player:QueryCharacter("key") != ownerKey) then
			return false;
		end;
	end;
	
	if ( !isAdmin and nexus.entity.IsChairEntity(entity) ) then
		local entities = ents.FindInSphere(entity:GetPos(), 64);
		
		for k, v in ipairs(entities) do
			if ( nexus.entity.IsDoor(v) ) then
				return false;
			end;
		end;
	end;
	
	if ( !isAdmin and !nexus.entity.IsInteractable(entity) ) then
		return false;
	else
		return self.BaseClass:OnPhysgunFreeze(weapon, physicsObject, entity, player);
	end;
end;

-- Called when a player attempts to pickup an entity with the physics gun.
function NEXUS:PhysgunPickup(player, entity)
	local canPickup = nil;
	local isAdmin = nexus.player.IsAdmin(player);
	
	if ( !isAdmin and !nexus.entity.IsInteractable(entity) ) then
		return false;
	end;
	
	if ( !isAdmin and nexus.entity.IsPlayerRagdoll(entity) ) then
		return false;
	end;
	
	if (!isAdmin) then
		canPickup = self.BaseClass:PhysgunPickup(player, entity);
	else
		canPickup = true;
	end;
	
	if (nexus.entity.IsChairEntity(entity) and !isAdmin) then
		local entities = ents.FindInSphere(entity:GetPos(), 256);
		
		for k, v in ipairs(entities) do
			if ( nexus.entity.IsDoor(v) ) then
				return false;
			end;
		end;
	end;
	
	if (nexus.config.Get("enable_prop_protection"):Get() and !isAdmin) then
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
			if ( nexus.config.Get("prop_kill_protection"):Get() ) then
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
function NEXUS:PhysgunDrop(player, entity)
	if ( !entity:IsPlayer() ) then
		if (entity.lastCollisionGroup) then
			entity:SetCollisionGroup(lastCollisionGroup);
		end;
	else
		entity:SetMoveType(entity.moveType or MOVETYPE_WALK);
		entity.moveType = nil;
	end;
	
	player.isHoldingEntity = nil;
	entity.isBeingHeld = nil;
end;

-- Called when a player attempts to spawn an NPC.
function NEXUS:PlayerSpawnNPC(player, model)
	if ( !nexus.player.HasFlags(player, "n") ) then
		return false;
	end;
	
	if ( !player:Alive() or player:IsRagdolled() ) then
		nexus.player.Notify(player, "You don't have permission to do this right now!");
		
		return false;
	end;
	
	if ( !nexus.player.IsAdmin(player) ) then
		return false;
	else
		return true;
	end;
end;

-- Called when an NPC has been killed.
function NEXUS:OnNPCKilled(entity, attacker, inflictor) end;

-- Called to get whether an entity is being held.
function NEXUS:GetEntityBeingHeld(entity)
	return entity.isBeingHeld or entity:IsPlayerHolding();
end;

-- Called when an entity is removed.
function NEXUS:EntityRemoved(entity)
	if ( !self:IsShuttingDown() ) then
		if ( IsValid(entity) ) then
			if (entity.giveRefund) then
				if ( CurTime() <= entity.giveRefund[1] ) then
					if ( IsValid( entity.giveRefund[2] ) ) then
						nexus.player.GiveCash(entity.giveRefund[2], entity.giveRefund[3], "Prop Refund");
					end;
				end;
			end;
			
			nexus.player.GetAllProperty()[ entity:EntIndex() ] = nil;
		end;
	end;
end;

-- Called when an entity's menu option should be handled.
function NEXUS:EntityHandleMenuOption(player, entity, option, arguments)
	local class = entity:GetClass();
	local generator = nexus.generator.Get(class);
	
	if ( class == "nx_item" and (arguments == "nx_itemTake" or arguments == "nx_itemUse") ) then
		player:EmitSound("physics/body/body_medium_impact_soft"..math.random(1, 7)..".wav");
		
		local itemTable = entity.item;
		local quickUse = (arguments == "nx_itemUse");
		
		if (itemTable) then
			local canPickup = ( !itemTable.CanPickup or itemTable:CanPickup(player, quickUse, entity) );
			
			if (canPickup != false) then
				if (canPickup and type(canPickup) == "string") then
					local newItemTable = nexus.item.Get(canPickup);
					
					if (newItemTable) then
						itemTable = newItemTable;
					else
						return;
					end;
				end;
				
				player:SetItemEntity(entity);
					if (quickUse) then
						player:FakePickup(entity);
						player:UpdateInventory(itemTable.uniqueID, 1, true, true);
						
						if ( !nexus.player.RunNexusCommand(player, "InvAction", itemTable.uniqueID, "use") ) then
							player:UpdateInventory(itemTable.uniqueID, -1, true, true);
							player:SetItemEntity(nil);
							
							return;
						end;
					else
						local success, fault = player:UpdateInventory(itemTable.uniqueID, 1);
						
						if (!success) then
							nexus.player.Notify(player, fault);
							player:SetItemEntity(nil);
							
							return;
						else
							player:FakePickup(entity);
						end;
					end;
					
					if (!itemTable.OnPickup or itemTable:OnPickup(player, quickUse, entity) != false) then
						entity:Remove();
					end;
				player:SetItemEntity(nil);
			end;
		end;
	elseif (class == "nx_shipment" and arguments == "nx_shipmentOpen") then
		player:EmitSound("physics/body/body_medium_impact_soft"..math.random(1, 7)..".wav");
		player:FakePickup(entity);
		
		nexus.player.OpenStorage( player, {
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
	elseif (class == "nx_cash" and arguments == "nx_cashTake") then
		nexus.player.GiveCash( player, entity:GetSharedVar("sh_Amount"), nexus.schema.GetOption("name_cash") );
		player:EmitSound("physics/body/body_medium_impact_soft"..math.random(1, 7)..".wav");
		player:FakePickup(entity);
		
		entity:Remove();
	elseif (generator and arguments == "nx_generatorSupply") then
		if (entity:GetPower() < generator.power) then
			if ( !entity.CanSupply or entity:CanSupply(player) ) then
				nexus.mount.Call("PlayerChargeGenerator", player, entity, generator);
				entity:SetSharedVar("sh_Power", generator.power);
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
function NEXUS:PlayerSpawnedProp(player, model, entity)
	if ( IsValid(entity) ) then
		local scalePropCost = nexus.config.Get("scale_prop_cost"):Get();
		
		if (scalePropCost > 0) then
			local cost = math.floor( math.max( (entity:BoundingRadius() / 50) * scalePropCost, 1 ) );
			local info = {cost = cost, name = "Prop"};
			
			nexus.mount.Call("PlayerAdjustPropCostInfo", player, entity, info);
			
			if ( nexus.player.CanAfford(player, info.cost) ) then
				nexus.player.GiveCash(player, -info.cost, info.name);
				
				entity.giveRefund = {CurTime() + 10, player, info.cost};
			else
				nexus.player.Notify(player, "You need another "..FORMAT_CASH(info.cost - nexus.player.GetCash(player), nil, true).."!");
				
				entity:Remove();
			end;
		end;
		
		if ( IsValid(entity) ) then
			entity:SetOwnerKey( player:QueryCharacter("key") );
			
			self.BaseClass:PlayerSpawnedProp(player, model, entity);
			
			if ( IsValid(entity) ) then
				self:PrintDebug(player:Name().." spawned "..tostring(model).." ("..tostring(entity)..").");
				
				if ( nexus.config.Get("prop_kill_protection"):Get() ) then
					entity.damageImmunity = CurTime() + 60;
				end;
			end;
		end;
	end;
end;

-- Called when a player attempts to spawn a prop.
function NEXUS:PlayerSpawnProp(player, model)
	if ( !nexus.player.HasFlags(player, "e") ) then
		return false;
	end;
	
	if ( !player:Alive() or player:IsRagdolled() ) then
		nexus.player.Notify(player, "You don't have permission to do this right now!");
		
		return false;
	end;
	
	if ( nexus.player.IsAdmin(player) ) then
		return true;
	end;
	
	return self.BaseClass:PlayerSpawnProp(player, model);
end;

-- Called when a player attempts to spawn a ragdoll.
function NEXUS:PlayerSpawnRagdoll(player, model)
	if ( !nexus.player.HasFlags(player, "r") ) then return false; end;
	
	if ( !player:Alive() or player:IsRagdolled() ) then
		nexus.player.Notify(player, "You don't have permission to do this right now!");
		
		return false;
	end;
	
	if ( !nexus.player.IsAdmin(player) ) then
		return false;
	else
		return true;
	end;
end;

-- Called when a player attempts to spawn an effect.
function NEXUS:PlayerSpawnEffect(player, model)
	if ( !player:Alive() or player:IsRagdolled() ) then
		nexus.player.Notify(player, "You don't have permission to do this right now!");
		
		return false;
	end;
	
	if ( !nexus.player.IsAdmin(player) ) then
		return false;
	else
		return true;
	end;
end;

-- Called when a player attempts to spawn a vehicle.
function NEXUS:PlayerSpawnVehicle(player, model)
	if ( !string.find(model, "chair") and !string.find(model, "seat") ) then
		if ( !nexus.player.HasFlags(player, "C") ) then
			return false;
		end;
	elseif ( !nexus.player.HasFlags(player, "c") ) then
		return false;
	end;
	
	if ( !player:Alive() or player:IsRagdolled() ) then
		nexus.player.Notify(player, "You don't have permission to do this right now!");
		
		return false;
	end;
	
	if ( nexus.player.IsAdmin(player) ) then
		return true;
	end;
	
	return self.BaseClass:PlayerSpawnVehicle(player, model);
end;

-- Called when a player attempts to use a tool.
function NEXUS:CanTool(player, trace, tool)
	local isAdmin = nexus.player.IsAdmin(player);
	
	if ( IsValid(trace.Entity) ) then
		local isPropProtectionEnabled = nexus.config.Get("enable_prop_protection"):Get();
		local characterKey = player:QueryCharacter("key");
		
		if ( !isAdmin and !nexus.entity.IsInteractable(trace.Entity) ) then
			return false;
		end;
		
		if ( !isAdmin and nexus.entity.IsPlayerRagdoll(trace.Entity) ) then
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
					if ( !nexus.entity.IsInteractable(newTrace.Entity) or nexus.entity.IsPlayerRagdoll(newTrace.Entity) ) then
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
						if ( v:IsMapEntity() or nexus.entity.IsPlayerRagdoll(v) ) then
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
	
	self:PrintDebug(player:Name().." used the "..tostring(tool).." tool.");
	
	if (!isAdmin) then
		return self.BaseClass:CanTool(player, trace, tool);
	else
		return true;
	end;
end;

-- Called when a player attempts to NoClip.
function NEXUS:PlayerNoClip(player)
	if ( player:IsRagdolled() ) then
		return false;
	elseif ( player:IsSuperAdmin() ) then
		return true;
	else
		return false;
	end;
end;

-- Called when a player's character has initialized.
function NEXUS:PlayerCharacterInitialized(player)
	umsg.Start("nx_InventoryClear", player)
	umsg.End();
	
	umsg.Start("nx_AttributesClear", player)
	umsg.End();
	
	if ( !nexus.class.Get( player:Team() ) ) then
		nexus.class.AssignToDefault(player);
	end;
	
	for k, v in pairs( nexus.player.GetInventory(player) ) do
		local itemTable = nexus.item.Get(k);
		
		if (itemTable) then
			player:UpdateInventory(itemTable.uniqueID, 0, true);
		end;
	end;
		
	player.attributeProgress = {};
	player.attributeProgressTime = 0;
	
	for k, v in pairs( nexus.attribute.GetAll() ) do
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
		local hintTable = nexus.hint.Find(v);
		
		if ( hintTable and !player:GetData("hint"..k) ) then
			if (!hintTable.Callback or hintTable.Callback(player) != false) then
				timer.Simple(startHintsDelay, function()
					if ( IsValid(player) ) then
						nexus.hint.Send(player, hintTable.text, 30);
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
function NEXUS:PlayerDeathCodeUsed(player, commandTable, arguments) end;

-- Called when a player has created a character.
function NEXUS:PlayerCharacterCreated(player, character) end;

-- Called when a player's character has unloaded.
function NEXUS:PlayerCharacterUnloaded(player)
	nexus.player.SetupRemovePropertyDelays(player);
	nexus.player.DisableProperty(player);
	nexus.player.SetRagdollState(player, RAGDOLL_RESET);
	nexus.player.CloseStorage(player, true)
	
	player:SetTeam(TEAM_UNASSIGNED);
end;

-- Called when a player's character has loaded.
function NEXUS:PlayerCharacterLoaded(player)
	player:SetSharedVar( "sh_InventoryWeight", nexus.config.Get("default_inv_weight"):Get() );
	
	player.characterLoadedTime = CurTime();
	player.attributeBoosts = {};
	player.crouchedSpeed = nexus.config.Get("crouched_speed"):Get();
	player.ragdollTable = {};
	player.spawnWeapons = {};
	player.initialized = true;
	player.firstSpawn = true;
	player.lightSpawn = false;
	player.changeClass = false;
	player.spawnAmmo = {};
	player.jumpPower = nexus.config.Get("jump_power"):Get();
	player.walkSpeed = nexus.config.Get("walk_speed"):Get();
	player.runSpeed = nexus.config.Get("run_speed"):Get();
	
	hook.Call( "PlayerRestoreCharacterData", NEXUS, player, player:QueryCharacter("data") );
	hook.Call( "PlayerRestoreTempData", NEXUS, player, player:CreateTempData() );
	
	nexus.player.SetCharacterMenuState(player, CHARACTER_MENU_CLOSE);
	
	nexus.mount.Call("PlayerCharacterInitialized", player);
	
	nexus.player.RestoreRecognisedNames(player);
	nexus.player.ReturnProperty(player);
	nexus.player.SetInitialized(player, true);
	
	player.firstSpawn = false;
	
	local charactersTable = nexus.config.Get("mysql_characters_table"):Get();
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
function NEXUS:PlayerReturnProperty(player) end;

-- Called when config has initialized for a player.
function NEXUS:PlayerConfigInitialized(player)
	nexus.mount.Call("PlayerSendDataStreamInfo", player);
	
	if ( player:IsBot() ) then
		nexus.mount.Call("PlayerDataStreamInfoSent", player);
	else
		timer.Simple(FrameTime() * 32, function()
			if ( IsValid(player) ) then
				umsg.Start("nx_DataStreaming", player);
				umsg.End();
			end;
		end);
	end;
end;

-- Called when a player initially spawns.
function NEXUS:PlayerInitialSpawn(player)
	player.hasSpawned = true;
	player.characters = {};
	player.sharedVars = {};
	
	if ( IsValid(player) ) then
		player:KillSilent();
	end;
	
	if ( player:IsBot() ) then
		nexus.config.Send(player);
	end;
	
	if ( !player:IsKicked() ) then
		nexus.chatBox.Add(nil, nil, "connect", player:SteamName().." has connected to the server.");
		
		self:PrintDebug(player:SteamName().." ("..player:SteamID().."|"..player:IPAddress()..") has connected to the server.");
	end;
end;

-- Called each frame that a player is dead.
function NEXUS:PlayerDeathThink(player)
	local action = nexus.player.GetAction(player);
	
	if ( !player:HasInitialized() or player:GetCharacterData("banned") ) then
		return true;
	end;
	
	if (action == "spawn") then
		return true;
	else
		player:Spawn();
	end;
end;

-- Called when a player has used their radio.
function NEXUS:PlayerRadioUsed(player, text, listeners, eavesdroppers) end;

-- Called when a player's drop weapon info should be adjusted.
function NEXUS:PlayerAdjustDropWeaponInfo(player, info)
	return true;
end;

-- Called when a player's character creation info should be adjusted.
function NEXUS:PlayerAdjustCharacterCreationInfo(player, info, data) end;

-- Called when a player's earn generator info should be adjusted.
function NEXUS:PlayerAdjustEarnGeneratorInfo(player, info) end;

-- Called when a player's order item should be adjusted.
function NEXUS:PlayerAdjustOrderItemTable(player, itemTable) end;

-- Called when a player's next punch info should be adjusted.
function NEXUS:PlayerAdjustNextPunchInfo(player, info) end;

-- Called when a player has an unknown inventory item.
function NEXUS:PlayerHasUnknownInventoryItem(player, inventory, item, amount) end;

-- Called when a player uses an unknown item function.
function NEXUS:PlayerUseUnknownItemFunction(player, itemTable, itemFunction) end;

-- Called when a player has an unknown attribute.
function NEXUS:PlayerHasUnknownAttribute(player, attributes, attribute, amount, progress) end;

-- Called when a player's character table should be adjusted.
function NEXUS:PlayerAdjustCharacterTable(player, character)
	if ( nexus.faction.stored[character.faction] ) then
		if ( nexus.faction.stored[character.faction].whitelist
		and !nexus.player.IsWhitelisted(player, character.faction) ) then
			character.data["banned"] = true;
		end;
	else
		return true;
	end;
end;

-- Called when a player's character screen info should be adjusted.
function NEXUS:PlayerAdjustCharacterScreenInfo(player, character, info) end;

-- Called when a player's prop cost info should be adjusted.
function NEXUS:PlayerAdjustPropCostInfo(player, entity, info) end;

-- Called when a player's death info should be adjusted.
function NEXUS:PlayerAdjustDeathInfo(player, info) end;

-- Called when debug info should be adjusted.
function NEXUS:DebugAdjustInfo(info) end;

-- Called when chat box info should be adjusted.
function NEXUS:ChatBoxAdjustInfo(info) end;

-- Called when a chat box message has been added.
function NEXUS:ChatBoxMessageAdded(info) end;

-- Called when a player's radio text should be adjusted.
function NEXUS:PlayerAdjustRadioInfo(player, info) end;

-- Called when a player should gain a frag.
function NEXUS:PlayerCanGainFrag(player, victim) return true; end;

-- Called when a player's model should be set.
function NEXUS:PlayerSetModel(player)
	nexus.player.SetDefaultModel(player);
	nexus.player.SetDefaultSkin(player);
end;

-- Called just after a player spawns.
function NEXUS:PostPlayerSpawn(player, lightSpawn, changeClass, firstSpawn)
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
					nexus.attributes.Boost(player, k2, k, v2.amount, v2.duration);
				end;
			end;
		end;
	else
		player:SetCharacterData("attributeboosts", nil);
		player:SetCharacterData("health", nil);
		player:SetCharacterData("armor", nil);
	end;
end;

-- Called when a player spawns.
function NEXUS:PlayerSpawn(player)
	if ( player:HasInitialized() ) then
		player:ShouldDropWeapon(false);
		
		if (!player.lightSpawn) then
			nexus.player.SetWeaponRaised(player, false);
			nexus.player.SetRagdollState(player, RAGDOLL_RESET);
			nexus.player.SetAction(player, false);
			nexus.player.SetDrunk(player, false);
			
			nexus.attributes.ClearBoosts(player);
			
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
			
			player:SetCrouchedWalkSpeed( nexus.config.Get("crouched_speed"):Get() );
			player:SetWalkSpeed( nexus.config.Get("walk_speed"):Get() );
			player:SetJumpPower( nexus.config.Get("jump_power"):Get() );
			player:SetRunSpeed( nexus.config.Get("run_speed"):Get() );
			
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
		
		nexus.mount.Call("PostPlayerSpawn", player, player.lightSpawn, player.changeClass, player.firstSpawn);
		
		nexus.player.SetRecognises(player, player, RECOGNISE_TOTAL);
		
		player.changeClass = false;
		player.lightSpawn = false;
	else
		player:KillSilent();
	end;
end;

-- Called when a player should take damage.
function NEXUS:PlayerShouldTakeDamage(player, attacker, inflictor, damageInfo)
	return true;
end;

-- Called when a player is attacked by a trace.
function NEXUS:PlayerTraceAttack(player, damageInfo, direction, trace)
	player.lastHitGroup = trace.HitGroup;
	
	return false;
end;

-- Called just before a player dies.
function NEXUS:DoPlayerDeath(player, attacker, damageInfo)
	nexus.player.DropWeapons(player, attacker);
	nexus.player.SetAction(player, false);
	nexus.player.SetDrunk(player, false);
	
	local deathSound = nexus.mount.Call( "PlayerPlayDeathSound", player, nexus.player.GetGender(player) );
	local decayTime = nexus.config.Get("body_decay_time"):Get();

	if (decayTime > 0) then
		nexus.player.SetRagdollState( player, RAGDOLL_KNOCKEDOUT, nil, decayTime, self:ConvertForce(damageInfo:GetDamageForce() * 32) );
	else
		nexus.player.SetRagdollState( player, RAGDOLL_KNOCKEDOUT, nil, 600, self:ConvertForce(damageInfo:GetDamageForce() * 32) );
	end;
	
	if ( nexus.mount.Call("PlayerCanDeathClearRecognisedNames", player, attacker, damageInfo) ) then
		nexus.player.ClearRecognisedNames(player);
	end;
	
	if ( nexus.mount.Call("PlayerCanDeathClearName", player, attacker, damageInfo) ) then
		nexus.player.ClearName(player);
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
			if ( nexus.mount.Call("PlayerCanGainFrag", attacker, player) ) then
				attacker:AddFrags(1);
			end;
		end;
	end;
end;

-- Called when a player dies.
function NEXUS:PlayerDeath(player, inflictor, attacker, damageInfo)
	self:CalculateSpawnTime(player, inflictor, attacker, damageInfo);
	
	if ( player:GetRagdollEntity() ) then
		local ragdoll = player:GetRagdollEntity();
		
		if (inflictor:GetClass() == "prop_combine_ball") then
			if (damageInfo) then
				nexus.entity.Disintegrate(player:GetRagdollEntity(), 3, damageInfo:GetDamageForce() * 32);
			else
				nexus.entity.Disintegrate(player:GetRagdollEntity(), 3);
			end;
		end;
	end;
	
	if ( attacker:IsPlayer() ) then
		if ( IsValid( attacker:GetActiveWeapon() ) ) then
			self:PrintDebug(attacker:Name().." killed "..player:Name().." with "..nexus.player.GetWeaponClass(attacker)..".");
		else
			self:PrintDebug(attacker:Name().." killed "..player:Name()..".");
		end;
	else
		self:PrintDebug(attacker:GetClass().." killed "..player:Name()..".");
	end;
end;

-- Called when a player's weapons should be given.
function NEXUS:PlayerLoadout(player)
	local weapons = nexus.class.Query(player:Team(), "weapons");
	local ammo = nexus.class.Query(player:Team(), "ammo");
	
	player.spawnWeapons = {};
	player.spawnAmmo = {};
	
	if ( nexus.player.HasFlags(player, "t") ) then
		nexus.player.GiveSpawnWeapon(player, "gmod_tool");
	end
	
	if ( nexus.player.HasFlags(player, "p") ) then
		nexus.player.GiveSpawnWeapon(player, "weapon_physgun");
	end
	
	nexus.player.GiveSpawnWeapon(player, "weapon_physcannon");
	nexus.player.GiveSpawnWeapon(player, "nx_hands");
	nexus.player.GiveSpawnWeapon(player, "nx_keys");
	
	if (weapons) then
		for k, v in ipairs(weapons) do
			if ( !nexus.player.GiveSpawnItemWeapon(player, v) ) then
				player:Give(v);
			end;
		end;
	end;
	
	if (ammo) then
		for k, v in pairs(ammo) do
			nexus.player.GiveSpawnAmmo(player, k, v);
		end;
	end;
	
	nexus.mount.Call("PlayerGiveWeapons", player);
	
	player:SelectWeapon("nx_hands");
end

-- Called when the server shuts down.
function NEXUS:ShutDown()
	self.ShuttingDown = true;
end;

-- Called when a player presses F1.
function NEXUS:ShowHelp(player)
	umsg.Start("nx_MenuToggle", player);
	umsg.End();
end;

-- Called when a player presses F2.
function NEXUS:ShowTeam(player)
	if ( !nexus.player.IsNoClipping(player) ) then
		local doRecogniseMenu = true;
		local entity = player:GetEyeTraceNoCursor().Entity;
		
		if ( IsValid(entity) and nexus.entity.IsDoor(entity) ) then
			if (entity:GetPos():Distance( player:GetShootPos() ) <= 192) then
				if ( nexus.mount.Call("PlayerCanViewDoor", player, entity) ) then
					if ( nexus.mount.Call("PlayerUse", player, entity) ) then
						local owner = nexus.entity.GetOwner(entity);
						
						if (owner) then
							if ( nexus.player.HasDoorAccess(player, entity, DOOR_ACCESS_COMPLETE) ) then
								local data = {
									sharedAccess = nexus.entity.DoorHasSharedAccess(entity),
									sharedText = nexus.entity.DoorHasSharedText(entity),
									unsellable = nexus.entity.IsDoorUnsellable(entity),
									accessList = {},
									isParent = nexus.entity.IsDoorParent(entity),
									entity = entity,
									owner = owner
								};
								
								for k, v in ipairs( g_Player.GetAll() ) do
									if (v != player and v != owner) then
										if ( nexus.player.HasDoorAccess(v, entity, DOOR_ACCESS_COMPLETE) ) then
											data.accessList[v] = DOOR_ACCESS_COMPLETE;
										elseif ( nexus.player.HasDoorAccess(v, entity, DOOR_ACCESS_BASIC) ) then
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
		
		if ( nexus.config.Get("recognise_system"):Get() ) then
			if (doRecogniseMenu) then
				umsg.Start("nx_RecogniseMenu", player);
				umsg.End();
			end;
		end;
	end;
end;

NEXUS:HookDataStream("RecogniseOption", function(player, data)
	if ( nexus.config.Get("recognise_system"):Get() ) then
		if (type(data) == "string") then
			local talkRadius = nexus.config.Get("talk_radius"):Get();
			local playSound = false;
			local position = player:GetPos();
			
			for k, v in ipairs( g_Player.GetAll() ) do
				if (v:HasInitialized() and player != v) then
					if ( !nexus.player.IsNoClipping(v) ) then
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
							nexus.player.SetRecognises(v, player, RECOGNISE_SAVE);
							
							if (!playSound) then
								playSound = true;
							end;
						end;
					end;
				end;
			end;
			
			if (playSound) then
				nexus.player.PlaySound(player, "buttons/button17.wav");
			end;
		end;
	end;
end);

-- Called when a player selects a custom character option.
function NEXUS:PlayerSelectCustomCharacterOption(player, action, character) end;

-- Called when a player takes damage.
function NEXUS:PlayerTakeDamage(player, inflictor, attacker, hitGroup, damageInfo) end;

-- Called when an entity takes damage.
function NEXUS:EntityTakeDamage(entity, inflictor, attacker, amount, damageInfo)
	if ( nexus.config.Get("prop_kill_protection"):Get() ) then
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
		local isPlayerRagdoll = nexus.entity.IsPlayerRagdoll(entity);
		local player = nexus.entity.GetPlayer(entity);
		
		if ( player and (entity:IsPlayer() or isPlayerRagdoll) ) then
			if ( damageInfo:IsFallDamage() or nexus.config.Get("damage_view_punch"):Get() ) then
				player:ViewPunch( Angle( math.random(amount, amount), math.random(amount, amount), math.random(amount, amount) ) );
			end;
			
			if ( player:Alive() ) then
				if ( attacker:IsPlayer() ) then
					self:PrintDebug(player:Name().." took damage from "..attacker:Name().." with "..nexus.player.GetWeaponClass(attacker, "an unknown weapon")..".");
				else
					self:PrintDebug(player:Name().." took damage from "..attacker:GetClass()..".");
				end;
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
							local noMessage = nexus.mount.Call("PlayerTakeDamage", player, inflictor, attacker, lastHitGroup, damageInfo);
							local sound = nexus.mount.Call("PlayerPlayPainSound", player, nexus.player.GetGender(player), damageInfo, lastHitGroup);
							
							self:CreateBloodEffects( damageInfo:GetDamagePosition(), 1, player, damageInfo:GetDamageForce() );
							
							if (sound and !noMessage) then
								player:EmitSound("physics/flesh/flesh_impact_bullet"..math.random(1, 5)..".wav", 150);
								
								timer.Simple(FrameTime() * 25, function()
									if ( IsValid(player) ) then
										player:EmitSound(sound);
									end;
								end);
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
				
				if (nexus.mount.Call("PlayerRagdollCanTakeDamage", player, entity, inflictor, attacker, hitGroup, damageInfo)
				and damageInfo:GetDamage() > 0) then
					if ( !attacker:IsPlayer() ) then
						if (attacker:GetClass() == "prop_ragdoll" or nexus.entity.IsDoor(attacker)
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
						local noMessage = nexus.mount.Call("PlayerTakeDamage", player, inflictor, attacker, hitGroup, damageInfo);
						local sound = nexus.mount.Call("PlayerPlayPainSound", player, nexus.player.GetGender(player), damageInfo, hitGroup);
						
						if (sound and !noMessage) then
							entity:EmitSound("physics/flesh/flesh_impact_bullet"..math.random(1, 5)..".wav", 320, 150);
							
							timer.Simple(FrameTime() * 25, function()
								if ( IsValid(entity) ) then
									entity:EmitSound(sound);
								end;
							end);
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
					nexus.entity.Disintegrate( entity, 3, damageInfo:GetDamageForce() );
					
					entity.disintegrating = true;
				end;
			end;
		elseif ( entity:IsNPC() ) then
			if (attacker:IsPlayer() and IsValid( attacker:GetActiveWeapon() )
			and nexus.player.GetWeaponClass(attacker) == "weapon_crowbar") then
				damageInfo:ScaleDamage(0.25);
			end;
		end;
	end;
end;

-- Called when the death sound for a player should be played.
function NEXUS:PlayerDeathSound(player) return true; end;

-- Called when a player attempts to spawn a SWEP.
function NEXUS:PlayerSpawnSWEP(player, class, weapon)
	if ( !player:IsSuperAdmin() ) then
		return false;
	else
		return true;
	end;
end;

-- Called when a player is given a SWEP.
function NEXUS:PlayerGiveSWEP(player, class, weapon)
	if ( !player:IsSuperAdmin() ) then
		return false;
	else
		return true;
	end;
end;

-- Called when attempts to spawn a SENT.
function NEXUS:PlayerSpawnSENT(player, class)
	if ( !player:IsSuperAdmin() ) then
		return false;
	else
		return true;
	end;
end;

-- Called when a player presses a key.
function NEXUS:KeyPress(player, key)
	if (key == IN_USE) then
		local trace = player:GetEyeTraceNoCursor();
		
		if ( IsValid(trace.Entity) ) then
			if (trace.HitPos:Distance( player:GetShootPos() ) <= 192) then
				if ( nexus.mount.Call("PlayerUse", player, trace.Entity) ) then
					if ( nexus.entity.IsDoor(trace.Entity) and !trace.Entity:HasSpawnFlags(256)
					and !trace.Entity:HasSpawnFlags(8192) and !trace.Entity:HasSpawnFlags(32768) ) then
						if ( nexus.mount.Call("PlayerCanUseDoor", player, trace.Entity) ) then
							nexus.mount.Call("PlayerUseDoor", player, trace.Entity);
							
							nexus.entity.OpenDoor( trace.Entity, 0, nil, nil, player:GetPos() );
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
			if ( player:GetSharedVar("sh_Jogging") ) then
				player:SetSharedVar("sh_Jogging", false);
			else
				player:SetSharedVar("sh_Jogging", true);
			end;
		elseif ( velocity == 0 and player:KeyDown(IN_SPEED) ) then
			if ( player:Crouching() ) then
				player:RunCommand("-duck");
			else
				player:RunCommand("+duck");
			end;
		end;
	elseif (key == IN_RELOAD) then
		player.reloadHoldTime = CurTime() + 1;
	end;
end;

-- Called when a player releases a key.
function NEXUS:KeyRelease(player, key)
	if (key == IN_RELOAD and player.reloadHoldTime) then
		player.reloadHoldTime = nil;
	end;
end;

NEXUS:HookDataStream("Door", function(player, data)
	if ( IsValid( data[1] ) and player:GetEyeTraceNoCursor().Entity == data[1] ) then
		if (data[1]:GetPos():Distance( player:GetPos() ) <= 192) then
			if (data[2] == "Purchase") then
				if ( !nexus.entity.GetOwner( data[1] ) ) then
					if ( hook.Call( "PlayerCanOwnDoor", NEXUS, player, data[1] ) ) then
						local doors = nexus.player.GetDoorCount(player);
						
						if ( doors == nexus.config.Get("max_doors"):Get() ) then
							nexus.player.Notify(player, "You cannot purchase another door!");
						else
							local doorCost = nexus.config.Get("door_cost"):Get();
							
							if ( doorCost == 0 or nexus.player.CanAfford(player, doorCost) ) then
								local doorName = nexus.entity.GetDoorName( data[1] );
								
								if (doorName == "false" or doorName == "hidden" or doorName == "") then
									doorName = "Door";
								end;
								
								if (doorCost > 0) then
									nexus.player.GiveCash(player, -doorCost, doorName);
								end;
								
								nexus.player.GiveDoor( player, data[1] );
							else
								local amount = doorCost - nexus.player.GetCash(player);
								
								nexus.player.Notify(player, "You need another "..FORMAT_CASH(amount, nil, true).."!");
							end;
						end;
					end;
				end;
			elseif (data[2] == "Access") then
				if ( nexus.player.HasDoorAccess(player, data[1], DOOR_ACCESS_COMPLETE) ) then
					if ( IsValid( data[3] ) and data[3] != player and data[3] != nexus.entity.GetOwner( data[1] ) ) then
						if (data[4] == DOOR_ACCESS_COMPLETE) then
							if ( nexus.player.HasDoorAccess(data[3], data[1], DOOR_ACCESS_COMPLETE) ) then
								nexus.player.GiveDoorAccess(data[3], data[1], DOOR_ACCESS_BASIC);
							else
								nexus.player.GiveDoorAccess(data[3], data[1], DOOR_ACCESS_COMPLETE);
							end;
						elseif (data[4] == DOOR_ACCESS_BASIC) then
							if ( nexus.player.HasDoorAccess(data[3], data[1], DOOR_ACCESS_BASIC) ) then
								nexus.player.TakeDoorAccess( data[3], data[1] );
							else
								nexus.player.GiveDoorAccess(data[3], data[1], DOOR_ACCESS_BASIC);
							end;
						end;
						
						if ( nexus.player.HasDoorAccess(data[3], data[1], DOOR_ACCESS_COMPLETE) ) then
							NEXUS:StartDataStream( player, "DoorAccess", {data[3], DOOR_ACCESS_COMPLETE} );
						elseif ( nexus.player.HasDoorAccess(data[3], data[1], DOOR_ACCESS_BASIC) ) then
							NEXUS:StartDataStream( player, "DoorAccess", {data[3], DOOR_ACCESS_BASIC} );
						else
							NEXUS:StartDataStream( player, "DoorAccess", { data[3] } );
						end;
					end;
				end;
			elseif (data[2] == "Unshare") then
				if ( nexus.entity.IsDoorParent( data[1] ) ) then
					if (data[3] == "Text") then
						NEXUS:StartDataStream(player, "SetSharedText", false);
						
						data[1].sharedText = nil;
					else
						NEXUS:StartDataStream(player, "SetSharedAccess", false);
						
						data[1].sharedAccess = nil;
					end;
				end;
			elseif (data[2] == "Share") then
				if ( nexus.entity.IsDoorParent( data[1] ) ) then
					if (data[3] == "Text") then
						NEXUS:StartDataStream(player, "SetSharedText", true);
						
						data[1].sharedText = true;
					else
						NEXUS:StartDataStream(player, "SetSharedAccess", true);
						
						data[1].sharedAccess = true;
					end;
				end;
			elseif (data[2] == "Text" and data[3] != "") then
				if ( nexus.player.HasDoorAccess(player, data[1], DOOR_ACCESS_COMPLETE) ) then
					if ( !string.find(string.gsub(string.lower( data[3] ), "%s", ""), "thisdoorcanbepurchased")
					and string.find(data[3], "%w") ) then
						nexus.entity.SetDoorText( data[1], string.sub(data[3], 1, 32) );
					end;
				end;
			elseif (data[2] == "Sell") then
				if (nexus.entity.GetOwner( data[1] ) == player) then
					if ( !nexus.entity.IsDoorUnsellable( data[1] ) ) then
						nexus.player.TakeDoor( player, data[1] );
					end;
				end;
			end;
		end;
	end;
end);

NEXUS:HookDataStream("DataStreamInfoSent", function(player, data)
	if (!player.dataStreamInfoSent) then
		nexus.mount.Call("PlayerDataStreamInfoSent", player);
		
		timer.Simple(FrameTime() * 32, function()
			if ( IsValid(player) ) then
				umsg.Start("nx_DataStreamed", player);
				umsg.End();
			end;
		end);
		
		player.dataStreamInfoSent = true;
	end;
end);

NEXUS:HookDataStream("LocalPlayerCreated", function(player, data)
	if ( IsValid(player) and !player:HasConfigInitialized() ) then
		NEXUS:CreateTimer("Send Config: "..player:UniqueID(), FrameTime() * 64, 1, function()
			if ( IsValid(player) ) then
				nexus.config.Send(player);
			end;
		end);
	end;
end);

NEXUS:HookDataStream("UnequipItem", function(player, data)
	local arguments = nil;
	local uniqueID = data;
	
	if (type(data) == "table") then
		arguments = data[2];
		uniqueID = data[1];
	end;
	
	if (type(uniqueID) == "string") then
		if ( player:Alive() and !player:IsRagdolled() ) then
			local itemTable = nexus.item.Get(uniqueID);
			
			if (itemTable and itemTable.OnPlayerUnequipped and itemTable.HasPlayerEquipped) then
				if ( itemTable:HasPlayerEquipped(player, arguments) ) then
					itemTable:OnPlayerUnequipped(player, arguments);
					
					player:RebuildInventory();
				end;
			end;
		end;
	end;
end);

NEXUS:HookDataStream("GetTargetRecognises", function(player, data)
	if ( ValidEntity(data) and data:IsPlayer() ) then
		player:SetSharedVar( "sh_TargetRecognises", nexus.player.DoesRecognise(data, player) );
	end;
end);

NEXUS:HookDataStream("EntityMenuOption", function(player, data)
	local entity = data[1];
	local option = data[2];
	local shootPos = player:GetShootPos();
	local arguments = data[3];
	
	if (IsValid(entity) and type(option) == "string") then
		if (entity:NearestPoint(shootPos):Distance(shootPos) <= 80) then
			if ( nexus.mount.Call("PlayerUse", player, entity) ) then
				nexus.mount.Call("EntityHandleMenuOption", player, entity, option, arguments);
			end;
		end;
	end;
end);

NEXUS:HookDataStream("CreateCharacter", function(player, data)
	if (!player.creatingCharacter) then
		local minimumPhysDesc = nexus.config.Get("minimum_physdesc"):Get();
		local attributesTable = nexus.attribute.GetAll();
		local factionTable = nexus.faction.Get(data.faction);
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
				local maximumPoints = nexus.config.Get("default_attribute_points"):Get();
				local pointsSpent = 0;
				
				if (factionTable.attributePointsScale) then
					maximumPoints = math.Round(maximumPoints * factionTable.attributePointsScale);
				end;
				
				if (factionTable.maximumAttributePoints) then
					maximumPoints = factionTable.maximumAttributePoints;
				end;
				
				for k, v in pairs(data.attributes) do
					local attributeTable = nexus.attribute.Get(k);
					
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
					return nexus.player.CreationError(player, "You have chosen more "..nexus.schema.GetOption("name_attribute", true).." points than you can afford to spend!");
				end;
			elseif (attributes) then
				return nexus.player.CreationError(player, "You did not choose any "..nexus.schema.GetOption("name_attributes", true).." or the ones that you did are not valid!");
			end;
			
			if (!factionTable.GetName) then
				if (!factionTable.useFullName) then
					if (data.forename and data.surname) then
						data.forename = string.gsub(data.forename, "^.", string.upper);
						data.surname = string.gsub(data.surname, "^.", string.upper);
						
						if ( string.find(data.forename, "[%p%s%d]") or string.find(data.surname, "[%p%s%d]") ) then
							return nexus.player.CreationError(player, "Your forename and surname must not contain punctuation, spaces or digits!");
						end;
						
						if ( !string.find(data.forename, "[aeiou]") or !string.find(data.surname, "[aeiou]") ) then
							return nexus.player.CreationError(player, "Your forename and surname must both contain at least one vowel!");
						end;
						
						if ( string.len(data.forename) < 2 or string.len(data.surname) < 2) then
							return nexus.player.CreationError(player, "Your forename and surname must both be at least 2 characters long!");
						end;
						
						if ( string.len(data.forename) > 16 or string.len(data.surname) > 16) then
							return nexus.player.CreationError(player, "Your forename and surname must not be greater than 16 characters long!");
						end;
					else
						return nexus.player.CreationError(player, "You did not choose a name, or the name that you chose is not valid!");
					end;
				elseif (!data.fullName or data.fullName == "") then
					return nexus.player.CreationError(player, "You did not choose a name, or the name that you chose is not valid!");
				end;
			end;
			
			if (nexus.command.Get("CharPhysDesc") != nil) then
				if (type(data.physDesc) != "string") then
					return nexus.player.CreationError(player, "You did not enter a physical description!");
				elseif (string.len(data.physDesc) < minimumPhysDesc) then
					return nexus.player.CreationError(player, "The physical description must be at least "..minimumPhysDesc.." characters long!");
				end;
				
				info.data["physdesc"] = NEXUS:ModifyPhysDesc(data.physDesc);
			end;
			
			if (!factionTable.GetModel and !info.model) then
				return nexus.player.CreationError(player, "You did not choose a model, or the model that you chose is not valid!");
			end;
			
			if ( !nexus.faction.IsGenderValid(info.faction, info.gender) ) then
				return nexus.player.CreationError(player, "You did not choose a gender, or the gender that you chose is not valid!");
			end;
			
			if ( factionTable.whitelist and !nexus.player.IsWhitelisted(player, info.faction) ) then
				return nexus.player.CreationError(player, "You are not on the "..info.faction.." whitelist!");
			elseif ( nexus.faction.IsModelValid(factionTable.name, info.gender, info.model) or (factionTable.GetModel and !info.model) ) then
				local charactersTable = nexus.config.Get("mysql_characters_table"):Get();
				local schemaFolder = NEXUS:GetSchemaFolder();
				local characterID = nil;
				local characters = player:GetCharacters();
				
				if ( nexus.faction.HasReachedMaximum(player, factionTable.name) ) then
					return nexus.player.CreationError(player, "You cannot create any more characters in this faction.");
				end;
				
				for i = 1, nexus.player.GetMaximumCharacters(player) do
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
							return nexus.player.CreationError(player, fault or "There was an error creating this character!");
						end;
					end;
					
					for k, v in pairs(characters) do
						if (v.name == info.name) then
							return nexus.player.CreationError(player, "You already have a character with the name '"..info.name.."'!");
						end;
					end;
					
					local fault = nexus.mount.Call("PlayerAdjustCharacterCreationInfo", player, info, data);
					
					if (fault == false or type(fault) == "string") then
						return nexus.player.CreationError(player, fault or "There was an error creating this character!");
					end;
					
					tmysql.query("SELECT * FROM "..charactersTable.." WHERE _Schema = \""..schemaFolder.."\" AND _Name = \""..info.name.."\"", function(result)
						if ( IsValid(player) ) then
							if (result and type(result) == "table" and #result > 0) then
								nexus.player.CreationError(player, "A character with the name '"..info.name.."' already exists!");
								
								player.creatingCharacter = nil;
							else
								nexus.player.LoadCharacter( player, characterID, {
									attributes = info.attributes,
									faction = info.faction,
									gender = info.gender,
									model = info.model,
									name = info.name,
									data = info.data
								}, function()
									NEXUS:PrintDebug(player:SteamName().." created a "..info.faction.." character with the name '"..info.name.."'.");
									
									umsg.Start("nx_CharacterFinish", player)
										umsg.Bool(true);
									umsg.End();
									
									player.creatingCharacter = nil;
								end);
							end;
						end;
					end, 1);
					
					player.creatingCharacter = true;
				else
					return nexus.player.CreationError(player, "You cannot create any more characters!");
				end;
			else
				return nexus.player.CreationError(player, "You did not choose a model, or the model that you chose is not valid!");
			end;
		else
			return nexus.player.CreationError(player, "You did not choose a faction, or the faction that you chose is not valid!");
		end;
	end;
end);

NEXUS:HookDataStream("InteractCharacter", function(player, data)
	local characterID = data.characterID;
	local action = data.action;
	
	if (characterID and action) then
		local character = player:GetCharacters()[characterID];
		
		if (character) then
			local fault = nexus.mount.Call("PlayerCanInteractCharacter", player, action, character);
			
			if (fault == false or type(fault) == "string") then
				return nexus.player.CreationError(fault or "You cannot interact with this character!");
			elseif (action == "delete") then
				local success, fault = nexus.player.DeleteCharacter(player, characterID);
				
				if (!success) then
					nexus.player.CreationError(player, fault);
				end;
			elseif (action == "use") then
				local success, fault = nexus.player.UseCharacter(player, characterID);
				
				if (!success) then
					nexus.player.CreationError(player, fault);
				end;
			else
				nexus.mount.Call("PlayerSelectCustomCharacterOption", player, action, character);
			end;
		end;
	end;
end);

NEXUS:HookDataStream("QuizAnswer", function(player, data)
	if (!player.quizAnswers) then
		player.quizAnswers = {};
	end;
	
	local question = data[1];
	local answer = data[2];
	
	if ( nexus.quiz.GetQuestion(question) ) then
		player.quizAnswers[question] = answer;
	end;
end);

NEXUS:HookDataStream("QuizCompleted", function(player, data)
	if ( player.quizAnswers and !nexus.quiz.GetCompleted(player) ) then
		local questionsAmount = nexus.quiz.GetQuestionsAmount();
		local correctAnswers = 0;
		local quizQuestions = nexus.quiz.GetQuestions();
		
		for k, v in pairs(quizQuestions) do
			if ( player.quizAnswers[k] ) then
				if ( nexus.quiz.IsAnswerCorrect( k, player.quizAnswers[k] ) ) then
					correctAnswers = correctAnswers + 1;
				end;
			end;
		end;
		
		if ( correctAnswers < math.Round( questionsAmount * (nexus.quiz.GetPercentage() / 100) ) ) then
			nexus.quiz.CallKickCallback(player, correctAnswers);
		else
			nexus.quiz.SetCompleted(player, true);
		end;
	end;
end);

NEXUS:HookDataStream("GetQuizStatus", function(player, data)
	if ( !nexus.quiz.GetEnabled() or nexus.quiz.GetCompleted(player) ) then
		umsg.Start("nx_QuizCompleted", player);
			umsg.Bool(true);
		umsg.End();
	else
		umsg.Start("nx_QuizCompleted", player);
			umsg.Bool(false);
		umsg.End();
	end;
end);

local playerMeta = FindMetaTable("Player");
local entityMeta = FindMetaTable("Entity");

playerMeta.NexusSetCrouchedWalkSpeed = playerMeta.SetCrouchedWalkSpeed;
playerMeta.NexusLastHitGroup = playerMeta.LastHitGroup;
playerMeta.NexusSetJumpPower = playerMeta.SetJumpPower;
playerMeta.NexusSetWalkSpeed = playerMeta.SetWalkSpeed;
playerMeta.NexusStripWeapons = playerMeta.StripWeapons;
playerMeta.NexusSetRunSpeed = playerMeta.SetRunSpeed;
entityMeta.NexusSetMaterial = entityMeta.SetMaterial;
playerMeta.NexusStripWeapon = playerMeta.StripWeapon;
playerMeta.NexusGodDisable = playerMeta.GodDisable;
entityMeta.NexusExtinguish = entityMeta.Extinguish;
entityMeta.NexusWaterLevel = entityMeta.WaterLevel;
playerMeta.NexusGodEnable = playerMeta.GodEnable;
entityMeta.NexusSetHealth = entityMeta.SetHealth;
entityMeta.NexusSetColor = entityMeta.SetColor;
entityMeta.NexusIsOnFire = entityMeta.IsOnFire;
entityMeta.NexusSetModel = entityMeta.SetModel;
playerMeta.NexusSetArmor = playerMeta.SetArmor;
entityMeta.NexusSetSkin = entityMeta.SetSkin;
entityMeta.NexusAlive = playerMeta.Alive;
playerMeta.NexusGive = playerMeta.Give;
playerMeta.SteamName = playerMeta.Name;

-- A function to get a player's name.
function playerMeta:Name()
	return self:QueryCharacter( "name", self:SteamName() );
end;

-- A function to get whether a player is alive.
function playerMeta:Alive()
	if (!self.fakingDeath) then
		return self:NexusAlive();
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
	nexus.player.SaveCharacter(self);
end;

-- A function to give a player an item weapon.
function playerMeta:GiveItemWeapon(item)
	nexus.player.GiveItemWeapon(self, item);
end;

-- A function to give a weapon to a player.
function playerMeta:Give(class, uniqueID, forceReturn)
	if ( !nexus.mount.Call("PlayerCanBeGivenWeapon", self, class, uniqueID, forceReturn) ) then
		return;
	end;
	
	local itemTable = nexus.item.GetWeapon(class, uniqueID);
	local teamIndex = self:Team();
	
	if (self:IsRagdolled() and !forceReturn) then
		local ragdollWeapons = self:GetRagdollWeapons();
		local spawnWeapon = nexus.player.GetSpawnWeapon(self, class);
		local canHolster;
		
		if ( itemTable and nexus.mount.Call("PlayerCanHolsterWeapon", self, itemTable, true, true) ) then
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
			self:NexusGive(class);
		self.forceGive = nil;
		
		local weapon = self:GetWeapon(class);
		
		if ( IsValid(weapon) ) then
			if (itemTable) then
				nexus.player.StripDefaultAmmo(self, weapon, itemTable);
				nexus.player.RestorePrimaryAmmo(self, weapon);
				nexus.player.RestoreSecondaryAmmo(self, weapon);
			end;
			
			if (uniqueID and uniqueID != "") then
				weapon:SetNetworkedString("sh_UniqueID", uniqueID);
			end;
		else
			return true;
		end;
	end;
	
	nexus.mount.Call("PlayerGivenWeapon", self, class, uniqueID, forceReturn);
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
	
	self:NexusSetSkin(skin);
end;

-- A function to set an entity's model.
function entityMeta:SetModel(model)
	if ( self:IsPlayer() and self:IsRagdolled() ) then
		self:GetRagdollEntity():SetModel(model);
	end;
	
	self:NexusSetModel(model);
	nexus.mount.Call("PlayerModelChanged", self, model);
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
	return nexus.entity.IsMapEntity(self);
end;

-- A function to get an entity's start position.
function entityMeta:GetStartPosition()
	return nexus.entity.GetStartPosition(self);
end;

-- A function to set an entity's material.
function entityMeta:SetMaterial(material)
	if ( self:IsPlayer() and self:IsRagdolled() ) then
		self:GetRagdollEntity():SetMaterial(material);
	end;
	
	self:NexusSetMaterial(material);
end;

-- A function to set an entity's color.
function entityMeta:SetColor(r, g, b, a)
	if ( self:IsPlayer() and self:IsRagdolled() ) then
		self:GetRagdollEntity():SetColor(r, g, b, a);
	end;
	
	self:NexusSetColor(r, g, b, a);
end;

-- A function to set a player's armor.
function playerMeta:SetArmor(armor)
	nexus.mount.Call("PlayerArmorSet", self, armor);
	
	self:NexusSetArmor(armor);
end;

-- A function to set a player's health.
function playerMeta:SetHealth(health)
	nexus.mount.Call("PlayerHealthSet", self, health);
	
	self:NexusSetHealth(health);
end;

-- A function to get whether a player is running.
function playerMeta:IsRunning()
	if ( self:Alive() and !self:IsRagdolled() and !self:InVehicle() and !self:Crouching() ) then
		local sprintSpeed = self:GetNetworkedFloat("SprintSpeed");
		local walkSpeed = self:GetNetworkedFloat("WalkSpeed");
		local velocity = self:GetVelocity():Length();
		
		if (velocity >= math.max(sprintSpeed - 25, 25)
		and sprintSpeed > walkSpeed) then
			return true;
		end;
	end;
end;

-- A function to get whether a player is jogging.
function playerMeta:IsJogging(testSpeed)
	if ( !self:IsRunning() and (self:GetSharedVar("sh_Jogging") or testSpeed) ) then
		if ( self:Alive() and !self:IsRagdolled() and !self:InVehicle() and !self:Crouching() ) then
			local walkSpeed = self:GetNetworkedFloat("WalkSpeed");
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
		self:NexusStripWeapon(weaponClass);
	end;
end;

-- A function to handle a player's attribute progress.
function playerMeta:HandleAttributeProgress(curTime)
	if (self.attributeProgressTime and curTime >= self.attributeProgressTime) then
		self.attributeProgressTime = curTime + 30;
		
		for k, v in pairs(self.attributeProgress) do
			local attributeTable = nexus.attribute.Get(k);
			
			if (attributeTable) then
				umsg.Start("nx_AttributeProgress", self);
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
		self:NexusStripWeapons();
	end;
end;

-- A function to enable God for a player.
function playerMeta:GodEnable()
	self.godMode = true; self:NexusGodEnable();
end;

-- A function to disable God for a player.
function playerMeta:GodDisable()
	self.godMode = nil; self:NexusGodDisable();
end;

-- A function to get whether a player has God mode enabled.
function playerMeta:IsInGodMode()
	return self.godMode;
end;

-- A function to update whether a player's weapon is raised.
function playerMeta:UpdateWeaponRaised()
	nexus.player.UpdateWeaponRaised(self);
end;

-- A function to get a player's water level.
function playerMeta:WaterLevel()
	if ( self:IsRagdolled() ) then
		return self:GetRagdollEntity():WaterLevel();
	else
		return self:NexusWaterLevel();
	end;
end;

-- A function to get whether a player is on fire.
function playerMeta:IsOnFire()
	if ( self:IsRagdolled() ) then
		return self:GetRagdollEntity():IsOnFire();
	else
		return self:NexusIsOnFire();
	end;
end;

-- A function to extinguish a player.
function playerMeta:Extinguish()
	if ( self:IsRagdolled() ) then
		return self:GetRagdollEntity():Extinguish();
	else
		return self:NexusExtinguish();
	end;
end;

-- A function to get whether a player is using their hands.
function playerMeta:IsUsingHands()
	return nexus.player.GetWeaponClass(self) == "nx_hands";
end;

-- A function to get whether a player is using their hands.
function playerMeta:IsUsingKeys()
	return nexus.player.GetWeaponClass(self) == "nx_keys";
end;

-- A function to get a player's wages.
function playerMeta:GetWages()
	return nexus.player.GetWages(self);
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
	return nexus.player.IsRagdolled(self, exception, entityless);
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
					GetNetChannel(self):Shutdown(isKicked);
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
	NEXUS:AddBan(self:SteamID(), duration * 60, reason);
end;

-- A function to get a player's character table.
function playerMeta:GetCharacter() return nexus.player.GetCharacter(self); end;

-- A function to get a player's storage table.
function playerMeta:GetStorageTable() return nexus.player.GetStorageTable(self); end;
 
-- A function to get a player's ragdoll table.
function playerMeta:GetRagdollTable() return nexus.player.GetRagdollTable(self); end;

-- A function to get a player's ragdoll state.
function playerMeta:GetRagdollState() return nexus.player.GetRagdollState(self); end;

-- A function to get a player's storage entity.
function playerMeta:GetStorageEntity() return nexus.player.GetStorageEntity(self); end;

-- A function to get a player's ragdoll entity.
function playerMeta:GetRagdollEntity() return nexus.player.GetRagdollEntity(self); end;

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
	self:SetSharedVar("sh_MaxArmor", armor);
end;

-- A function to get a player's maximum armor.
function playerMeta:GetMaxArmor(armor)
	local maxArmor = self:GetSharedVar("sh_MaxArmor");
	
	if (maxArmor > 0) then
		return maxArmor;
	else
		return 100;
	end;
end;

-- A function to set a player's maximum health.
function playerMeta:SetMaxHealth(health)
	self:SetSharedVar("sh_MaxHealth", health);
end;

-- A function to get a player's maximum health.
function playerMeta:GetMaxHealth(health)
	local maxHealth = self:GetSharedVar("sh_MaxHealth");
	
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
	return self.lastHitGroup or self:NexusLastHitGroup();
end;

-- A function to get whether an entity is being held.
function entityMeta:IsBeingHeld()
	if ( IsValid(self) ) then
		return nexus.mount.Call("GetEntityBeingHeld", self);
	end;
end;

-- A function to run a command on a player.
function playerMeta:RunCommand(...)
	NEXUS:StartDataStream( self, "RunCommand", {...} );
end;

-- A function to get a player's wages name.
function playerMeta:GetWagesName()
	return nexus.player.GetWagesName(self);
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
				NEXUS:CreateTimer("Forced Animation: "..self:UniqueID(), delay, 1, function()
					if ( IsValid(self) ) then
						local forcedAnimation = self:GetForcedAnimation();
						
						if (forcedAnimation) then
							self:SetForcedAnimation(false);
						end;
					end;
				end);
			else
				NEXUS:DestroyTimer( "Forced Animation: "..self:UniqueID() );
			end;
			
			self:SetSharedVar("sh_ForcedAnim", sequence);
			callFinish = true;
		end;
	else
		callFinish = true;
		self:SetSharedVar("sh_ForcedAnim", 0);
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
	
	if ( !NEXUS.TempPlayerData[uniqueID] ) then
		NEXUS.TempPlayerData[uniqueID] = {};
	end;
	
	return NEXUS.TempPlayerData[uniqueID];
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
	return nexus.inventory.HasItem(self, item, anywhere);
end;

-- A function to get a player's attribute boosts.
function playerMeta:GetAttributeBoosts()
	return self.attributeBoosts;
end;

-- A function to rebuild a player's inventory.
function playerMeta:RebuildInventory()
	nexus.inventory.Rebuild(self);
end;

-- A function to update a player's inventory.
function playerMeta:UpdateInventory(item, amount, force, noMessage)
	return nexus.inventory.Update(self, item, amount, force, noMessage);
end;

-- A function to update a player's attribute.
function playerMeta:UpdateAttribute(attribute, amount)
	return nexus.attributes.Update(self, attribute, amount);
end;

-- A function to progress a player's attribute.
function playerMeta:ProgressAttribute(attribute, amount, gradual)
	return nexus.attributes.Progress(self, attribute, amount, gradual);
end;

-- A function to boost a player's attribute.
function playerMeta:BoostAttribute(identifier, attribute, amount, duration)
	return nexus.attributes.Boost(self, identifier, attribute, amount, duration);
end;

-- A function to get whether a boost is active for a player.
function playerMeta:IsBoostActive(identifier, attribute, amount, duration)
	return nexus.attributes.IsBoostActive(self, identifier, attribute, amount, duration);
end;

-- A function to get a player's characters.
function playerMeta:GetCharacters()
	return self.characters;
end;

-- A function to set a player's run speed.
function playerMeta:SetRunSpeed(speed, nexus)
	if (!nexus) then self.runSpeed = speed; end;
	
	self:NexusSetRunSpeed(speed);
end;

-- A function to set a player's walk speed.
function playerMeta:SetWalkSpeed(speed, nexus)
	if (!nexus) then self.walkSpeed = speed; end;
	
	self:NexusSetWalkSpeed(speed);
end;

-- A function to set a player's jump power.
function playerMeta:SetJumpPower(power, nexus)
	if (!nexus) then self.jumpPower = power; end;
	
	self:NexusSetJumpPower(power);
end;

-- A function to set a player's crouched walk speed.
function playerMeta:SetCrouchedWalkSpeed(speed, nexus)
	if (!nexus) then self.crouchedSpeed = speed; end;
	
	self:NexusSetCrouchedWalkSpeed(speed);
end;

-- A function to get whether a player has initialized.
function playerMeta:HasInitialized()
	return self.initialized;
end;

-- A function to query a player's character table.
function playerMeta:QueryCharacter(key, default)
	if ( self:GetCharacter() ) then
		return nexus.player.Query(self, key, default);
	else
		return default;
	end;
end;

-- A function to get a player's shared variable.
function entityMeta:GetSharedVar(key)
	if ( self:IsPlayer() ) then
		return nexus.player.GetSharedVar(self, key);
	else
		return nexus.entity.GetSharedVar(self, key);
	end;
end;

-- A function to set a shared variable for a player.
function entityMeta:SetSharedVar(key, value)
	if ( self:IsPlayer() ) then
		nexus.player.SetSharedVar(self, key, value);
	else
		nexus.entity.SetSharedVar(self, key, value);
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

-- A function to get the entity a player is holding.
function playerMeta:GetHoldingEntity()
	return self.isHoldingEntity;
end;

playerMeta.GetName = playerMeta.Name;
playerMeta.Nick = playerMeta.Name;

nexus.mount.Call("NexusCoreLoaded");