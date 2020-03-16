--[[
Name: "sv_autorun.lua".
Product: "kuroScript".
--]]

resource.AddFile("materials/gui/silkicons/newspaper.vtf");
resource.AddFile("materials/gui/silkicons/newspaper.vmt");

-- Include a file.
include("sh_autorun.lua");

-- Include some client side Lua files.
AddCSLuaFile("scheme/sh_enums.lua");
AddCSLuaFile("scheme/sh_frame.lua");
AddCSLuaFile("sh_autorun.lua");
AddCSLuaFile("cl_autorun.lua");

-- Set some information.
local g_Player = g_Player;
local g_Team = g_Team;
local g_File = g_File;

-- Set some information.
local CurTime = CurTime;
local hook = hook;

-- Set some information.
datastream.KuroScriptStreamToClients = datastream.StreamToClients;

-- Set some information.
_R["CRecipientFilter"].IsValid = function()
	return true;
end;

-- A function to start a data stream.
function datastream.StreamToClients(recipientFilter, handler, data, callback)
	if (string.sub(handler, 1, 3) == "ks_") then
		umsg.PoolString(handler);
	end;
	
	-- Return the unique ID.
	return datastream.KuroScriptStreamToClients(recipientFilter, handler, data, callback);
end;

-- Set some information.
hook.KuroScriptCall = hook.Call;

-- A function to call a hook.
function hook.Call(name, gamemode, ...)
	local arguments = {...};
	local k, v;
	
	-- Check if a statement is true.
	if (!gamemode) then
		gamemode = kuroScript.frame;
	end;
	
	-- Check if a statement is true.
	if (name == "EntityTakeDamage") then
		if ( kuroScript.frame:DoEntityTakeDamageHook(gamemode, arguments) ) then
			return;
		end;
	elseif (name == "PlayerSay") then
		arguments[2] = string.Replace(arguments[2], "~", "\"");
	end;
	
	-- Set some information.
	local value = kuroScript.mount.CallCachedHook(name, arguments);
	
	-- Check if a statement is true.
	if (value == nil) then
		return hook.KuroScriptCall( name, gamemode, unpack(arguments) );
	else
		return value;
	end;
end;

-- Set some information.
player.KuroScriptGetAll = player.GetAll;

-- A function to get all players.
function player.GetAll()
	return kuroScript.frame:CreateMulticallTable(player.KuroScriptGetAll(), _R.Player);
end;

-- Set some information.
ents.KuroScriptGetAll = ents.GetAll;

-- A function to get all entities.
function ents.GetAll()
	return kuroScript.frame:CreateMulticallTable(ents.KuroScriptGetAll(), _R.Entity);
end;

-- Called when the server initializes.
function kuroScript.frame:Initialize()
	local username = kuroScript.config.Get("mysql_username"):Get();
	local password = kuroScript.config.Get("mysql_password"):Get();
	local database = kuroScript.config.Get("mysql_database"):Get();
	local host = kuroScript.config.Get("mysql_host"):Get();
	local k, v;
	
	-- Initialize the MySQL connection.
	tmysql.initialize(host, username, password, database, 3306, 6, 5);
	
	-- Check if a statement is true.
	if (GetConVarNumber("gmod_datastream_iterations") <= 1) then
		RunConsoleCommand("gmod_datastream_iterations", "2");
	end;
	
	-- Set some information.
	kuroScript.config.initialized = true;
	
	-- Seed the random.
	math.randomseed( os.time() );
	
	-- Set some information.
	kuroScript.time = table.Copy(DEFAULT_TIME);
	kuroScript.date = table.Copy(DEFAULT_DATE);
	
	-- Set some information.
	KS_CONVAR_DEPARTURE = self:CreateConVar("ks_departure", 1);
	KS_CONVAR_ARRIVAL = self:CreateConVar("ks_arrival", 1);
	KS_CONVAR_DEBUG = self:CreateConVar("ks_debug", 1);
	KS_CONVAR_LOG = self:CreateConVar("ks_log", 1)
	
	-- Merge some information.
	table.Merge( kuroScript.time, self:RestoreGameData("time") );
	table.Merge( kuroScript.date, self:RestoreGameData("date") );
	
	-- Loop through each value in a table.
	for k, v in pairs(kuroScript.config.stored) do
		hook.Call("KuroScriptConfigInitialized", self, k, v.value);
	end;
	
	-- Call a gamemode hook.
	hook.Call("KuroScriptInitialized", self);
	
	-- Load the bans.
	self:LoadBans();
end;

-- Called when kuroScript has initialized.
function kuroScript.frame:KuroScriptInitialized() end;

-- Called when a player is banned.
function kuroScript.frame:PlayerBanned(player, duration, reason) end;

-- Called when a player's inventory string is needed.
function kuroScript.frame:PlayerGetInventoryString(player, character, inventory) end;

-- Called when a player's unlock info is needed.
function kuroScript.frame:PlayerGetUnlockInfo(player, entity)
	if ( kuroScript.entity.IsDoor(entity) ) then
		return {
			duration = kuroScript.config.Get("unlock_time"):Get(),
			Callback = function(player, entity)
				entity:Fire("unlock", "", 0);
			end
		};
	end;
end;

-- Called when a player's lock info is needed.
function kuroScript.frame:PlayerGetLockInfo(player, entity)
	if ( kuroScript.entity.IsDoor(entity) ) then
		return {
			duration = kuroScript.config.Get("lock_time"):Get(),
			Callback = function(player, entity)
				entity:Fire("lock", "", 0);
			end
		};
	end;
end;

-- Called when data should be saved.
function kuroScript.frame:SaveData()
	local savePhysicsPositions = kuroScript.config.Get("save_physics_positions"):Get();
	local k, v;
	
	-- Loop through each value in a table.
	for k, v in ipairs( g_Player.GetAll() ) do
		if ( v:HasInitialized() ) then
			kuroScript.player.SaveCharacter(v);
		end;
	end;
	
	-- Check if a statement is true.
	if (savePhysicsPositions and self.PhysicsPositions) then
		local physicsPositions = {};
		local map = string.lower( game.GetMap() );
		
		-- Loop through each value in a table.
		for k, v in pairs(self.PhysicsPositions) do
			if ( ValidEntity(v.entity) ) then
				physicsPositions[k] = {
					position = v.entity:GetPos(),
					angles = v.entity:GetAngles()
				};
				
				-- Set some information.
				local physicsObject = v.entity:GetPhysicsObject();
				
				-- Check if a statement is true.
				if ( ValidEntity(physicsObject) and physicsObject:IsMoveable() ) then
					physicsPositions[k].frozen = true;
				end;
			end;
		end;
		
		-- Save some game data.
		self:SaveGameData("physics/"..map, physicsPositions);
	end;
	
	-- Save some game data.
	self:SaveGameData("time", kuroScript.time);
	self:SaveGameData("date", kuroScript.date);
end;

-- Called when a player attempts to use a lowered weapon.
function kuroScript.frame:PlayerCanUseLoweredWeapon(player, weapon, secondary)
	if (secondary) then
		return weapon.NeverRaised or (weapon.Secondary and weapon.Secondary.NeverRaised);
	else
		return weapon.NeverRaised or (weapon.Primary and weapon.Primary.NeverRaised);
	end;
end;

-- Called when a player's known names have been cleared.
function kuroScript.frame:PlayerKnownNamesCleared(player, status, simple) end;

-- Called when a player's name has been cleared.
function kuroScript.frame:PlayerNameCleared(player, status, simple) end;

-- Called when an offline player has been given property.
function kuroScript.frame:PlayerPropertyGivenOffline(key, uniqueID, entity, networked, removeDelay) end;

-- Called when an offline player has had property taken.
function kuroScript.frame:PlayerPropertyTakenOffline(key, uniqueID, entity) end;

-- Called when a player has been given property.
function kuroScript.frame:PlayerPropertyGiven(player, entity, networked, removeDelay) end;

-- Called when a player has had property taken.
function kuroScript.frame:PlayerPropertyTaken(player, entity) end;

-- Called when a player's visibility should be set up.
function kuroScript.frame:SetupPlayerVisibility(player)
	local ragdollEntity = player:GetRagdollEntity();
	local k, v;
	
	-- Check if a statement is true.
	if (ragdollEntity) then
		AddOriginToPVS( ragdollEntity:GetPos() );
	end;
end;

-- Called when a player has been given access.
function kuroScript.frame:PlayerAccessGiven(player, access)
	if ( string.find(access, "p") and player:Alive() ) then
		kuroScript.player.GiveSpawnWeapon(player, "weapon_physgun");
	end;
	
	-- Check if a statement is true.
	if ( string.find(access, "t") and player:Alive() ) then
		kuroScript.player.GiveSpawnWeapon(player, "gmod_tool");
	end;
	
	-- Set some information.
	player:SetSharedVar( "ks_Access", player:QueryCharacter("access") );
end;

-- Called when a player has had access taken.
function kuroScript.frame:PlayerAccessTaken(player, access)
	if ( string.find(access, "p") and player:Alive() ) then
		if ( !kuroScript.player.HasAccess(player, "p") ) then
			kuroScript.player.TakeSpawnWeapon(player, "weapon_physgun");
		end;
	end;
	
	-- Check if a statement is true.
	if ( string.find(access, "t") and player:Alive() ) then
		if ( !kuroScript.player.HasAccess(player, "t") ) then
			kuroScript.player.TakeSpawnWeapon(player, "gmod_tool");
		end;
	end;
	
	-- Set some information.
	player:SetSharedVar( "ks_Access", player:QueryCharacter("access") );
end;

-- Called when the game description is needed.
function kuroScript.frame:GetGameDescription()
	if (kuroScript.game) then
		return self.Name.." | "..kuroScript.game.name;
	else
		return self.Name;
	end;
end;

-- Called when a player's default skin is needed.
function kuroScript.frame:GetPlayerDefaultSkin(player)
	local model = kuroScript.vocation.GetModelByGender( player:Team(), player:QueryCharacter("gender") );
	
	-- Check if a statement is true.
	if (model and type(model) == "table") then
		return model[2];
	else
		return 0;
	end;
end;

-- Called when a player's default model is needed.
function kuroScript.frame:GetPlayerDefaultModel(player)
	local model = kuroScript.vocation.GetModelByGender( player:Team(), player:QueryCharacter("gender") );
	
	-- Check if a statement is true.
	if (model) then
		if (type(model) == "table") then
			return model[1];
		else
			return model;
		end;
	else
		return player:QueryCharacter("model");
	end;
end;

-- Called when a player's default attributes are needed.
function kuroScript.frame:GetPlayerDefaultAttributes(player, character, attributes) end;

-- Called when a player's default inventory is needed.
function kuroScript.frame:GetPlayerDefaultInventory(player, character, inventory) end;

-- Called to get whether a player's weapon is raised.
function kuroScript.frame:GetPlayerWeaponRaised(player, class, weapon)
	if (class == "weapon_physgun" or class == "weapon_physcannon" or class == "gmod_tool") then
		return true;
	end;
	
	-- Check if a statement is true.
	if ( weapon:GetNetworkedBool("Ironsights") ) then
		return true;
	end;
	
	-- Check if a statement is true.
	if (weapon:GetNetworkedInt("Zoom") != 0) then
		return true;
	end;
	
	-- Check if a statement is true.
	if ( weapon:GetNetworkedBool("Scope") ) then
		return true;
	end;
	
	-- Check if a statement is true.
	if (player._ToggleWeaponRaised == class) then
		return true;
	else
		player._ToggleWeaponRaised = nil;
	end;
	
	-- Check if a statement is true.
	if (player._AutoWeaponRaised == class) then
		return true;
	else
		player._AutoWeaponRaised = nil;
	end;
end;

-- Called when a player's attribute has been updated.
function kuroScript.frame:PlayerAttributeUpdated(player, attributeTable, amount) end;

-- Called when a player's inventory item has been updated.
function kuroScript.frame:PlayerInventoryItemUpdated(player, itemTable, amount, force)
	kuroScript.player.UpdateStorageForPlayer(player, itemTable.uniqueID);
end;

-- Called when a player's currency has been updated.
function kuroScript.frame:PlayerCurrencyUpdated(player, amount, reason, silent)
	kuroScript.player.UpdateStorageForPlayer(player);
end;

-- A function to scale damage by hit group.
function kuroScript.frame:PlayerScaleDamageByHitGroup(player, attacker, hitGroup, damageInfo, baseDamage) end;

-- Called when a player switches their flashlight on or off.
function kuroScript.frame:PlayerSwitchFlashlight(player, on)
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
function kuroScript.frame:TimePassed(quantity) end;

-- Called when kuroScript config has initialized.
function kuroScript.frame:KuroScriptConfigInitialized(key, value)
	if (key == "local_voice") then
		if (value) then
			game.ConsoleCommand("sv_alltalk 0\n");
		end;
	elseif (key == "anonymous_system") then
		if (!value) then
			kuroScript.command.SetHidden("whispername", true);
			kuroScript.command.SetHidden("yellname", true);
			kuroScript.command.SetHidden("givename", true);
		end;
	elseif (key == "raised_weapon_system") then
		if (!value) then
			kuroScript.command.SetHidden("toggleraised", true);
		end;
	end;
end;

-- Called when a kuroScript ConVar has changed.
function kuroScript.frame:KuroScriptConVarChanged(name, previousValue, newValue)
	if (name == "local_voice" and newValue) then
		game.ConsoleCommand("sv_alltalk 0\n");
	end;
end;

-- Called when kuroScript config has changed.
function kuroScript.frame:KuroScriptConfigChanged(key, data, previousValue, newValue)
	local k, v;
	
	-- Check if a statement is true.
	if (key == "raised_weapon_system") then
		if (newValue) then
			kuroScript.command.SetHidden("toggleraised", false);
		else
			kuroScript.command.SetHidden("toggleraised", true);
		end;
	elseif (key == "anonymous_system") then
		if (newValue) then
			kuroScript.command.SetHidden("whispername", false);
			kuroScript.command.SetHidden("yellname", false);
			kuroScript.command.SetHidden("givename", false);
		else
			kuroScript.command.SetHidden("whispername", true);
			kuroScript.command.SetHidden("yellname", true);
			kuroScript.command.SetHidden("givename", true);
		end;
	elseif (key == "default_access") then
		local k, v;
		
		-- Loop through each value in a table.
		for k, v in ipairs( g_Player.GetAll() ) do
			if ( v:HasInitialized() and v:Alive() ) then
				if ( string.find(previousValue, "p") ) then
					if ( !string.find(newValue, "p") ) then
						if ( !kuroScript.player.HasAccess(v, "p") ) then
							kuroScript.player.TakeSpawnWeapon(v, "weapon_physgun");
						end;
					end;
				elseif ( !string.find(previousValue, "p") ) then
					if ( string.find(newValue, "p") ) then
						kuroScript.player.GiveSpawnWeapon(v, "weapon_physgun");
					end;
				end;
				
				-- Check if a statement is true.
				if ( string.find(previousValue, "t") ) then
					if ( !string.find(newValue, "t") ) then
						if ( !kuroScript.player.HasAccess(v, "t") ) then
							kuroScript.player.TakeSpawnWeapon(v, "gmod_tool");
						end;
					end;
				elseif ( !string.find(previousValue, "t") ) then
					if ( string.find(newValue, "t") ) then
						kuroScript.player.GiveSpawnWeapon(v, "gmod_tool");
					end;
				end;
			end;
		end;
	elseif (key == "crouched_speed") then
		g_Player.GetAll():SetCrouchedWalkSpeed(newValue);
	elseif (key == "ooc_interval") then
		local k, v;
		
		-- Loop through each value in a table.
		for k, v in ipairs( g_Player.GetAll() ) do
			v._NextTalkOOC = nil;
		end;
	elseif (key == "jump_power") then
		g_Player.GetAll():SetJumpPower(newValue);
	elseif (key == "walk_speed") then
		g_Player.GetAll():SetWalkSpeed(newValue);
	elseif (key == "run_speed") then
		g_Player.GetAll():SetRunSpeed(newValue);
	end;
end;

-- Called when a player's name has changed.
function kuroScript.frame:PlayerNameChanged(player, previousName, newName) end;

-- Called when a player's password should be authenticated.
function kuroScript.frame:PlayerPasswordAuth(name, password, steamID, address)
	return true;
end;

-- Called when a player attempts to sprays their tag.
function kuroScript.frame:PlayerSpray(player)
	if ( !player:Alive() or player:IsRagdolled() ) then
		return true;
	else
		return kuroScript.config.Get("disable_sprays"):Get();
	end;
end;

-- Called when a player attempts to use an entity.
function kuroScript.frame:PlayerUse(player, entity)
	if ( player:IsRagdolled(RAGDOLL_FALLENOVER) ) then
		return false;
	else
		return true;
	end;
end;

-- Called when a player's move data is set up.
function kuroScript.frame:SetupMove(player, moveData)
	if ( player:Alive() and !player:IsRagdolled() ) then
		local frameTime = FrameTime();
		local curTime = CurTime();
		local drunk = kuroScript.player.GetDrunk(player);
		
		-- Check if a statement is true.
		if (drunk and player._DrunkSwerve) then
			player._DrunkSwerve = math.Clamp( player._DrunkSwerve + frameTime, 0, math.min(drunk * 2, 16) );
			
			-- Set player's move angles.
			moveData:SetMoveAngles( moveData:GetMoveAngles() + Angle(0, math.cos(curTime) * player._DrunkSwerve, 0) );
		elseif (player._DrunkSwerve and player._DrunkSwerve > 1) then
			player._DrunkSwerve = math.max(player._DrunkSwerve - frameTime, 0);
			
			-- Set player's move angles.
			moveData:SetMoveAngles( moveData:GetMoveAngles() + Angle(0, math.cos(curTime) * player._DrunkSwerve, 0) );
		else
			player._DrunkSwerve = 1;
		end;
	end;
end;

-- Called when a player throws a punch.
function kuroScript.frame:PlayerPunchThrown(player) end;

-- Called when a player knocks on a door.
function kuroScript.frame:PlayerKnockOnDoor(player, door) end;

-- Called when a player attempts to knock on a door.
function kuroScript.frame:PlayerCanKnockOnDoor(player, door) return true; end;

-- Called when a player punches an entity.
function kuroScript.frame:PlayerPunchEntity(player, entity) end;

-- Called when a player orders an item shipment.
function kuroScript.frame:PlayerOrderShipment(player, itemTable, entity) end;

-- Called when a player holsters a weapon.
function kuroScript.frame:PlayerHolsterWeapon(player, itemTable, forced)
	if (itemTable.OnHolster) then
		itemTable:OnHolster(player, forced);
	end;
end;

-- Called when a player attempts to save a known name.
function kuroScript.frame:PlayerCanSaveKnownName(player, target)
	if (player != target) then return true; end;
end;

-- Called when a player attempts to restore a known name.
function kuroScript.frame:PlayerCanRestoreKnownName(player, target)
	if (player != target) then return true; end;
end;

-- Called when a player attempts to show their arrival.
function kuroScript.frame:PlayerCanShowArrival(player) return true; end;

-- Called when a player attempts to show their departure.
function kuroScript.frame:PlayerCanShowDeparture(player)
	if ( !player:GetCharacterData("banned") ) then return true; end;
end;

-- Called when a player attempts to order an item shipment.
function kuroScript.frame:PlayerCanOrderShipment(player, itemTable)
	return true;
end;

-- Called when a player attempts to get up.
function kuroScript.frame:PlayerCanGetUp(player) return true; end;

-- Called when a player knocks out a player with a punch.
function kuroScript.frame:PlayerPunchKnockout(player, target) end;

-- Called when a player attempts to throw a punch.
function kuroScript.frame:PlayerCanThrowPunch(player) return true; end;

-- Called when a player attempts to punch an entity.
function kuroScript.frame:PlayerCanPunchEntity(player, entity) return true; end;

-- Called when a player attempts to knock a player out with a punch.
function kuroScript.frame:PlayerCanPunchKnockout(player, target) return true; end;

-- Called when a player attempts to bypass the class limit.
function kuroScript.frame:PlayerCanBypassClassLimit(player, character) return false; end;

-- Called when a player attempts to bypass the vocation limit.
function kuroScript.frame:PlayerCanBypassVocationLimit(player, vocation) return false; end;

-- Called when a player's pain sound should be played.
function kuroScript.frame:PlayerPlayPainSound(player, gender, damageInfo, hitGroup)
	if (damageInfo:GetDamage() >= 5 and math.random() <= 0.5 and hitGroup) then
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
	
	-- Return the pain sound.
	return "vo/npc/"..gender.."01/pain0"..math.random(1, 9)..".wav";
end;

-- Called when a player attempts to be given a weapon.
function kuroScript.frame:PlayerCanBeGivenWeapon(player, class, uniqueID, forceReturn)
	return true;
end;

-- Called when a player attempts to create a character.
function kuroScript.frame:PlayerCanCreateCharacter(player, character, characterID)
	if ( kuroScript.quiz.GetEnabled() and !kuroScript.quiz.GetCompleted(player) ) then
		return false, "You have not completed the quiz";
	else
		return true;
	end;
end;

-- Called when a player attempts to interact with a character.
function kuroScript.frame:PlayerCanInteractCharacter(player, action, character)
	if ( kuroScript.quiz.GetEnabled() and !kuroScript.quiz.GetCompleted(player) ) then
		return false, "You have not completed the quiz";
	else
		return true;
	end;
end;

-- Called when a player's fall damage is needed.
function kuroScript.frame:GetFallDamage(player, velocity)
	local damage = (math.max( (velocity - 448) * 0.225225225, 0 ) * 2) * kuroScript.config.Get("scale_fall_damage"):Get();
	
	-- Check if a statement is true.
	if ( player:IsRagdolled() ) then
		return damage * 1.5;
	else
		return damage;
	end;
end;

-- Called when a player's death sound should be played.
function kuroScript.frame:PlayerPlayDeathSound(player, gender)
	return "vo/npc/"..string.lower(gender).."01/pain0"..math.random(1, 9)..".wav";
end;

-- Called when a player's character data should be restored.
function kuroScript.frame:PlayerRestoreCharacterData(player, data)
	if ( data["details"] ) then
		data["details"] = self:ModifyDetails( data["details"] );
	end;
end;

-- Called when a player's character data should be saved.
function kuroScript.frame:PlayerSaveCharacterData(player, data)
	data["health"] = player:Health();
	data["armor"] = player:Armor();
	
	-- Check if a statement is true.
	if (data["health"] <= 1) then
		data["health"] = nil;
	end;
	
	-- Check if a statement is true.
	if (data["armor"] <= 1) then
		data["armor"] = nil;
	end;
end;

-- Called when a player's data should be saved.
function kuroScript.frame:PlayerSaveData(player, data)
	if (data["whitelisted"] and #data["whitelisted"] == 0) then
		data["whitelisted"] = nil;
	end;
end;

-- Called when a player's storage should close.
function kuroScript.frame:PlayerStorageShouldClose(player, storage)
	local entity = player:GetStorageEntity();
	
	-- Check if a statement is true.
	if ( player:IsRagdolled() or !player:Alive() or !entity or (storage.distance and player:GetShootPos():Distance( entity:GetPos() ) > storage.distance) ) then
		return true;
	end;
end;

-- Called when a player attempts to pickup a weapon.
function kuroScript.frame:PlayerCanPickupWeapon(player, weapon)
	if ( player._ForceGive or ( player:GetEyeTraceNoCursor().Entity == weapon and player:KeyDown(IN_USE) ) ) then
		return true;
	else
		return false;
	end;
end;

-- Called each tick.
function kuroScript.frame:Tick()
	if (self.ShouldTick) then
		local sysTime = SysTime();
		local curTime = CurTime();
		
		-- Check if a statement is true.
		if (!self.NextHint or curTime >= self.NextHint) then
			kuroScript.hint.Distribute();
			
			-- Set some information.
			self.NextHint = curTime + kuroScript.config.Get("hint_interval"):Get();
		end;
		
		-- Check if a statement is true.
		if (!self.NextWagesTime or curTime >= self.NextWagesTime) then
			self:DistributeWagesCurrency();
			
			-- Set some information.
			self.NextWagesTime = curTime + kuroScript.config.Get("wages_interval"):Get();
		end;
		
		-- Check if a statement is true.
		if (!self.NextContrabandTime or curTime >= self.NextContrabandTime) then
			self:DistributeContrabandCurrency();
			
			-- Set some information.
			self.NextContrabandTime = curTime + kuroScript.config.Get("contraband_interval"):Get();
		end;
		
		-- Check if a statement is true.
		if (!self.NextDateTimeThink or sysTime >= self.NextDateTimeThink) then
			self:PerformDateTimeThink();
			
			-- Set some information.
			self.NextDateTimeThink = sysTime + kuroScript.config.Get("minute_time"):Get();
		end;
		
		-- Check if a statement is true.
		if (!self.NextPlayerThink or curTime >= self.NextPlayerThink) then
			if (!self.NextSetSharedVars) then
				self.NextSetSharedVars = curTime;
			end;
			
			-- Set some information.
			local setSharedVars = (curTime >= self.NextSetSharedVars);
			local infoTable = {};
			
			-- Loop through each value in a table.
			for k, v in ipairs( g_Player.GetAll() ) do
				if ( v:HasInitialized() ) then
					kuroScript.player.CallThinkHook(v, setSharedVars, infoTable, curTime);
				end;
			end;
			
			-- Check if a statement is true.
			if (curTime >= self.NextSetSharedVars) then
				self.NextSetSharedVars = curTime + 3;
			end;
			
			-- Set some information.
			self.NextPlayerThink = curTime + 0.5;
		end;
		
		-- Check if a statement is true.
		if (!self.NextSaveData or sysTime >= self.NextSaveData) then
			hook.Call("PreSaveData", self);
				hook.Call("SaveData", self);
			hook.Call("PostSaveData", self);
			
			-- Set some information.
			self.NextSaveData = sysTime + kuroScript.config.Get("save_data_interval"):Get();
		end;
		
		-- Check if a statement is true.
		if (!self.NextCheckEmpty or sysTime >= self.NextCheckEmpty) then
			if (kuroScript.config.Get("auto_remove_entities"):Get() > 0) then
				if (#g_Player.GetAll() > 0) then
					self.NextAutoRemove = nil;
				elseif (!self.NextAutoRemove) then
					self.NextAutoRemove = sysTime + kuroScript.config.Get("auto_remove_entities"):Get();
				elseif (sysTime >= self.NextAutoRemove) then
					ents.GetAll():AutoRemove();
					
					-- Set some information.
					self.NextAutoRemove = nil;
				end;
			end;
			
			-- Set some information.
			self.NextCheckEmpty = sysTime + 60;
		end;
	end;
end;

-- Called each frame.
function kuroScript.frame:Think()
	self:CallTimerThink( CurTime() );
end;

-- Called when a player's shared variables should be set.
function kuroScript.frame:PlayerSetSharedVars(player, curTime)
	local r, g, b, a = player:GetColor();
	local drunk = kuroScript.player.GetDrunk(player);
	
	-- Set some information.
	player:SetSharedVar( "ks_Currency", player:QueryCharacter("currency") );
	player:SetSharedVar( "ks_Details", player:GetCharacterData("details") );
	player:SetSharedVar( "ks_Access", player:QueryCharacter("access") );
	player:SetSharedVar( "ks_Model", kuroScript.player.GetDefaultModel(player) );
	player:SetSharedVar( "ks_Name", player:QueryCharacter("name") );
	player:SetSharedVar( "ks_Skin", kuroScript.player.GetDefaultSkin(player) );
	
	-- Check if a statement is true.
	if (r == 255 and g == 0 and b == 0 and a == 0) then
		player:SetColor(255, 255, 255, 255);
	end;
	
	-- Check if a statement is true.
	if (drunk) then
		player:SetSharedVar("ks_Drunk", drunk);
	else
		player:SetSharedVar("ks_Drunk", 0);
	end;
end;

-- Called at an interval while a player is connected.
function kuroScript.frame:PlayerThink(player, curTime, infoTable)
	local storageTable = player:GetStorageTable();
	local isAdmin = player:IsAdmin();
	local k, v;
	
	-- Check if a statement is true.
	if ( player:IsRagdolled() ) then
		player:SetMoveType(MOVETYPE_OBSERVER);
	elseif ( player:Alive() ) then
		if (!player._NextCheckEmpty or curTime >= player._NextCheckEmpty) then
			kuroScript.player.PreserveAmmo(player, true);
			
			-- Set some information.
			player._NextCheckEmpty = curTime + 2;
		else
			kuroScript.player.PreserveAmmo(player);
		end;
	end;
	
	-- Check if a statement is true.
	if (storageTable) then
		if ( storageTable.ShouldClose and storageTable.ShouldClose(player, storageTable) ) then
			kuroScript.player.CloseStorage(player);
		elseif (hook.Call( "PlayerStorageShouldClose", self, player, storageTable) ) then
			kuroScript.player.CloseStorage(player);
		end;
	end;
	
	-- Check if a statement is true.
	if (!isAdmin) then
		if (kuroScript.player.GetWeaponClass(player) == "weapon_physgun") then
			local physgunPickupDistance = kuroScript.config.Get("physgun_pickup_distance"):Get();
			local entity = player:GetHoldingEntity();
			
			-- Check if a statement is true.
			if ( ValidEntity(entity) ) then
				local physicsObject = entity:GetPhysicsObject();
				
				-- Check if a statement is true.
				if (physgunPickupDistance > 0) then
					if (player:GetShootPos():Distance( entity:GetPos() ) > physgunPickupDistance) then
						player:RunCommand("-attack");
						
						-- Drop the entity if it is held.
						DropEntityIfHeld(entity);
					end;
				end;
				
				-- Check if a statement is true.
				if ( ValidEntity(physicsObject) ) then
					if (physicsObject:GetVelocity():Length() >= 512) then
						player:RunCommand("-attack");
						
						-- Drop the entity if it is held.
						DropEntityIfHeld(entity);
					end;
				end;
				
				-- Check if a statement is true.
				if ( kuroScript.entity.IsChairEntity(entity) ) then
					local entities = ents.FindInSphere(entity:GetPos(), 256);
					local k, v;
					
					-- Loop through each value in a table.
					for k, v in ipairs(entities) do
						if ( kuroScript.entity.IsDoor(v) ) then
							if ( ValidEntity(physicsObject) ) then
								physicsObject:SetVelocity(physicsObject:GetVelocity() * -1);
							end;
							
							-- Run a console command on the player.
							player:RunCommand("-attack");
							
							-- Drop the entity if it is held.
							DropEntityIfHeld(entity);
							
							-- Break the loop.
							break;
						end;
					end;
				end;
			end;
		end;
	end;
	
	-- Check if a statement is true.
	if (player._Drunk) then
		for k, v in pairs(player._Drunk) do
			if (curTime >= v) then
				table.remove(player._Drunk, k);
			end;
		end;
	end;
	
	-- Set some information.
	player:SetSharedVar( "ks_InventoryWeight", math.ceil(infoTable.inventoryWeight) );
	player:SetSharedVar( "ks_Wages", math.ceil(infoTable.wages) );
	
	-- Check if a statement is true.
	if (infoTable.running == false) then
		infoTable.runSpeed = infoTable.walkSpeed;
	end;
	
	-- Check if a statement is true.
	if (infoTable.jogging) then
		infoTable.walkSpeed = infoTable.walkSpeed * 1.75;
	end;
	
	-- Set some information.
	player:SetCrouchedWalkSpeed(math.max(infoTable.crouchedSpeed, 0), true);
	player:SetWalkSpeed(math.max(infoTable.walkSpeed, 0), true);
	player:SetJumpPower(math.max(infoTable.jumpPower, 0), true);
	player:SetRunSpeed(math.max(infoTable.runSpeed, 0), true);
end;

-- Called when a player uses an item.
function kuroScript.frame:PlayerUseItem(player, itemTable) end;

-- Called when a player drops an item.
function kuroScript.frame:PlayerDropItem(player, itemTable, position) end;

-- Called when a player destroys an item.
function kuroScript.frame:PlayerDestroyItem(player, itemTable) end;

-- Called when a player drops a weapon.
function kuroScript.frame:PlayerDropWeapon(player, itemTable) end;

-- Called when a player charges contraband.
function kuroScript.frame:PlayerChargeContraband(player, entity, contraband) end;

-- Called when a player destroys contraband.
function kuroScript.frame:PlayerDestroyContraband(player, entity, contraband) end;

-- Called when a player's data should be restored.
function kuroScript.frame:PlayerRestoreData(player, data)
	if ( !data["givenamehint"] ) then
		data["givenamehint"] = 0;
	end;
	
	-- Check if a statement is true.
	if ( !data["whitelisted"] ) then
		data["whitelisted"] = {};
	end;
end;

-- Called when a player's temporary info should be saved.
function kuroScript.frame:PlayerSaveTempData(player, tempData) end;

-- Called when a player's temporary info should be restored.
function kuroScript.frame:PlayerRestoreTempData(player, tempData) end;

-- Called when a player selects a custom character option.
function kuroScript.frame:PlayerSelectCharacterOption(player, character, option) end;

-- Called when a player attempts to see another player's status.
function kuroScript.frame:PlayerCanSeeStatus(player, target)
	return "# "..target:UserID().." | "..target:Name().." | "..target:SteamName().." | "..target:SteamID().." | "..target:IPAddress();
end;

-- Called when a player attempts to see a player's chat.
function kuroScript.frame:PlayerCanSeePlayersChat(text, teamOnly, listener, speaker)
	return true;
end;

-- Called when a player attempts to hear another player's voice.
function kuroScript.frame:PlayerCanHearPlayersVoice(listener, speaker)
	if ( kuroScript.config.Get("local_voice"):Get() ) then
		if ( listener:IsRagdolled(RAGDOLL_FALLENOVER) or !listener:Alive() ) then
			return false;
		elseif ( speaker:IsRagdolled(RAGDOLL_FALLENOVER) or !speaker:Alive() ) then
			return false;
		elseif ( listener:GetPos():Distance( speaker:GetPos() ) > kuroScript.config.Get("talk_radius"):Get() ) then
			return false;
		end;
	end;
	
	-- Return true to break the function.
	return true;
end;

-- Called when a player attempts to delete a character.
function kuroScript.frame:PlayerCanDeleteCharacter(player, character)
	if ( character._Currency < kuroScript.config.Get("default_currency"):Get() ) then
		if ( !character._Data["banned"] ) then
			return "You cannot delete characters with less than $"..FORMAT_CURRENCY(kuroScript.config.Get("default_currency"):Get(), nil, true)..".";
		end;
	end;
end;

-- Called when a player attempts to use a character.
function kuroScript.frame:PlayerCanUseCharacter(player, character)
	if ( character._Data["banned"] ) then
		return character._Name.." is banned and cannot be used!";
	end;
end;

-- Called when a player's weapons should be given.
function kuroScript.frame:PlayerGiveWeapons(player) end;

-- Called when a player deletes a character.
function kuroScript.frame:PlayerDeleteCharacter(player, character) end;

-- Called when a player's armor is set.
function kuroScript.frame:PlayerArmorSet(player, armor)
	if ( player:IsRagdolled() ) then
		player:GetRagdollTable().armor = armor;
	end;
end;

-- Called when a player's health is set.
function kuroScript.frame:PlayerHealthSet(player, health)
	if ( player:IsRagdolled() ) then
		player:GetRagdollTable().health = health;
	end;
end;

-- Called when a player attempts to own a door.
function kuroScript.frame:PlayerCanOwnDoor(player, door)
	if ( kuroScript.entity.IsDoorUnownable(door) ) then
		return false;
	else
		return true;
	end;
end;

-- Called when a player attempts to view a door.
function kuroScript.frame:PlayerCanViewDoor(player, door)
	if ( kuroScript.entity.IsDoorUnownable(door) ) then
		return false;
	end;
	
	-- Return true to break the function.
	return true;
end;

-- Called when a player attempts to holster a weapon.
function kuroScript.frame:PlayerCanHolsterWeapon(player, itemTable, silent, forced)
	if ( kuroScript.player.GetSpawnWeapon(player, itemTable.weaponClass) ) then
		if (!silent) then kuroScript.player.Notify(player, "You cannot holster this weapon!"); end;
		
		-- Return false to break the function.
		return false;
	elseif (itemTable.CanHolster) then
		return itemTable:CanHolster(player, silent, forced);
	else
		return true;
	end;
end;

-- Called when a player attempts to drop a weapon.
function kuroScript.frame:PlayerCanDropWeapon(player, attacker, itemTable, silent)
	if ( kuroScript.player.GetSpawnWeapon(player, itemTable.weaponClass) ) then
		if (!silent) then
			kuroScript.player.Notify(player, "You cannot drop this weapon!");
		end;
		
		-- Return false to break the function.
		return false;
	else
		return true;
	end;
end;

-- Called when a player attempts to use an item.
function kuroScript.frame:PlayerCanUseItem(player, itemTable, silent)
	if ( itemTable.weaponClass and kuroScript.player.GetSpawnWeapon(player, itemTable.weaponClass) ) then
		if (!silent) then kuroScript.player.Notify(player, "You cannot use this weapon!"); end;
		
		-- Return false to break the function.
		return false;
	else
		return true;
	end;
end;

-- Called when a player attempts to drop an item.
function kuroScript.frame:PlayerCanDropItem(player, itemTable, silent) return true; end;

-- Called when a player attempts to destroy an item.
function kuroScript.frame:PlayerCanDestroyItem(player, itemTable, silent) return true; end;

-- Called when a player attempts to destroy contraband.
function kuroScript.frame:PlayerCanDestroyContraband(player, entity, contraband) return true; end;

-- Called when a player attempts to knockout a player.
function kuroScript.frame:PlayerCanKnockout(player, target) return true; end;

-- Called when a player attempts to use the radio.
function kuroScript.frame:PlayerCanRadio(player, text, listeners, eavesdroppers) return true; end;

-- Called when death attempts to clear a player's name.
function kuroScript.frame:PlayerCanDeathClearName(player, attacker, damageInfo) return true; end;

-- Called when death attempts to clear a player's known names.
function kuroScript.frame:PlayerCanDeathClearKnownNames(player, attacker, damageInfo) return true; end;

-- Called when a player's ragdoll attempts to take damage.
function kuroScript.frame:PlayerRagdollCanTakeDamage(player, ragdoll, inflictor, attacker, hitGroup, damageInfo)
	local immunity = player:GetRagdollTable().immunity;
	
	-- Check if a statement is true.
	if (immunity and CurTime() <= immunity) then
		local velocity = 0;
		
		-- Loop through a range of values.
		for i = 1, ragdoll:GetPhysicsObjectCount() do
			local physicsObject = ragdoll:GetPhysicsObjectNum(i);
			
			-- Check if a statement is true.
			if ( ValidEntity(physicsObject) ) then
				if (physicsObject:GetVelocity():Length() > velocity) then
					velocity = physicsObject:GetVelocity():Length();
				end;
			end;
		end;
		
		-- Check if a statement is true.
		if (velocity <= 25) then
			return false;
		else
			return true;
		end;
	else
		return true;
	end;
end;

-- Called when a player has been authenticated.
function kuroScript.frame:PlayerAuthed(player, steamID)
	local duration = self.BanList[ player:IPAddress() ] or self.BanList[steamID];
	
	-- Check if a statement is true.
	if (duration) then
		local unixTime = os.time();
		local timeLeft = duration - unixTime;
		local hoursLeft = math.max(timeLeft / 3600, 0);
		local minutesLeft = math.max(timeLeft / 60, 0);
		
		-- Check if a statement is true.
		if (duration > 0 and unixTime < duration) then
			local bannedMessage = kuroScript.config.Get("banned_message"):Get();
			
			-- Check if a statement is true.
			if (hoursLeft >= 1) then
				hoursLeft = tostring(hoursLeft);
				
				-- Set some information.
				bannedMessage = string.gsub(bannedMessage, "!t", hoursLeft);
				bannedMessage = string.gsub(bannedMessage, "!f", "hour(s)");
			elseif (minutesLeft >= 1) then
				minutesLeft = tostring(minutesLeft);
				
				-- Set some information.
				bannedMessage = string.gsub(bannedMessage, "!t", minutesLeft);
				bannedMessage = string.gsub(bannedMessage, "!f", "minutes(s)");
			else
				timeLeft = tostring(timeLeft);
				
				-- Set some information.
				bannedMessage = string.gsub(bannedMessage, "!t", timeLeft);
				bannedMessage = string.gsub(bannedMessage, "!f", "second(s)");
			end;
			
			-- Kick the player.
			player:Kick(bannedMessage);
		elseif (duration == 0) then
			player:Kick("You are permanently banned.");
		else
			self:RemoveBan(ipAddress);
			self:RemoveBan(steamID);
		end;
	end;
end;

-- Called when the player attempts to be ragdolled.
function kuroScript.frame:PlayerCanRagdoll(player, state, delay, decay, ragdoll)
	return true;
end;

-- Called when the player attempts to be unragdolled.
function kuroScript.frame:PlayerCanUnragdoll(player, state, ragdoll)
	return true;
end;

-- Called when a player has been ragdolled.
function kuroScript.frame:PlayerRagdolled(player, state, ragdoll)
	player:SetSharedVar("ks_FallenOver", false);
end;

-- Called when a player has been unragdolled.
function kuroScript.frame:PlayerUnragdolled(player, state, ragdoll)
	player:SetSharedVar("ks_FallenOver", false);
end;

-- Called to check if a player does have an access flag.
function kuroScript.frame:PlayerDoesHaveAccessFlag(player, flag)
	if ( string.find(kuroScript.config.Get("default_access"):Get(), flag) ) then
		return true;
	end;
end;

-- Called to check if a player does have door access.
function kuroScript.frame:PlayerDoesHaveDoorAccess(player, door, access, simple)
	if (kuroScript.entity.GetOwner(door) == player) then
		return true;
	else
		local key = player:QueryCharacter("key");
		
		-- Check if a statement is true.
		if ( door._AccessList and door._AccessList[key] ) then
			if (simple) then
				return door._AccessList[key] == access;
			else
				return door._AccessList[key] >= access;
			end;
		end;
	end;
	
	-- Return false to break the function.
	return false;
end;

-- Called to check if a player does know another player.
function kuroScript.frame:PlayerDoesKnowPlayer(player, target, status, simple, default)
	return default;
end;

-- Called to check if a player does have an item.
function kuroScript.frame:PlayerDoesHaveItem(player, itemTable) return false; end;

-- Called when a player attempts to lock an entity.
function kuroScript.frame:PlayerCanLockEntity(player, entity)
	if ( kuroScript.entity.IsDoor(entity) ) then
		return kuroScript.player.HasDoorAccess(player, entity);
	else
		return true;
	end;
end;

-- Called when a player attempts to unlock an entity.
function kuroScript.frame:PlayerCanUnlockEntity(player, entity)
	if ( kuroScript.entity.IsDoor(entity) ) then
		return kuroScript.player.HasDoorAccess(player, entity);
	else
		return true;
	end;
end;

-- Called when a player attempts to use a door.
function kuroScript.frame:PlayerCanUseDoor(player, door)
	if ( kuroScript.entity.GetOwner(door) and !kuroScript.player.HasDoorAccess(player, door) ) then
		return false;
	end;
	
	-- Check if a statement is true.
	if ( kuroScript.entity.IsDoorHidden(door) ) then
		return false;
	end;
	
	-- Return true to break the function.
	return true;
end;

-- Called when a player uses a door.
function kuroScript.frame:PlayerUseDoor(player, door) end;

-- Called when a player attempts to use an entity in a vehicle.
function kuroScript.frame:PlayerCanUseEntityInVehicle(player, entity, vehicle)
	if ( entity.UsableInVehicle or kuroScript.entity.IsDoor(entity) ) then
		return true;
	end;
end;

-- Called when a player's ragdoll attempts to decay.
function kuroScript.frame:PlayerCanRagdollDecay(player, ragdoll, seconds)
	return true;
end;

-- Called when a player attempts to exit a vehicle.
function kuroScript.frame:CanExitVehicle(vehicle, player)
	if ( ValidEntity(player) and player:IsPlayer() ) then
		local trace = player:GetEyeTraceNoCursor();
		
		-- Check if a statement is true.
		if ( ValidEntity(trace.Entity) and !trace.Entity:IsVehicle() ) then
			if ( hook.Call("PlayerCanUseEntityInVehicle", self, player, trace.Entity, vehicle) ) then
				return false;
			end;
		end;
	end;
	
	-- Check if a statement is true.
	if ( kuroScript.entity.IsChairEntity(vehicle) and !ValidEntity( vehicle:GetParent() ) ) then
		local trace = player:GetEyeTraceNoCursor();
		
		-- Check if a statement is true.
		if (trace.HitPos:Distance( player:GetShootPos() ) <= 192) then
			trace = {
				start = trace.HitPos,
				endpos = trace.HitPos - Vector(0, 0, 1024),
				filter = {player, vehicle}
			};
			
			-- Set some information.
			player._ExitVehicle = util.TraceLine(trace).HitPos;
			
			-- Set some information.
			player:SetMoveType(MOVETYPE_NOCLIP);
		else
			return false;
		end;
	end;
	
	-- Return true to break the function.
	return true;
end;

-- Called when a player leaves a vehicle.
function kuroScript.frame:PlayerLeaveVehicle(player, vehicle)
	timer.Simple(FrameTime() * 0.5, function()
		if ( ValidEntity(player) and !player:InVehicle() ) then
			if ( ValidEntity(vehicle) ) then
				if ( kuroScript.entity.IsChairEntity(vehicle) ) then
					local position = player._ExitVehicle or vehicle:GetPos();
					local targetPosition = kuroScript.player.GetSafePosition(player, position, vehicle);
					
					-- Check if a statement is true.
					if (targetPosition) then
						player:SetMoveType(MOVETYPE_NOCLIP);
						player:SetPos(targetPosition);
					end;
					
					-- Set some information.
					player:SetMoveType(MOVETYPE_WALK);
					
					-- Set some information.
					player._ExitVehicle = nil;
				end;
			end;
		end;
	end);
end;

-- Called when a player enters a vehicle.
function kuroScript.frame:PlayerEnteredVehicle(player, vehicle, role)
	timer.Simple(FrameTime() * 0.5, function()
		if ( ValidEntity(player) ) then
			player:SetCollisionGroup(COLLISION_GROUP_PLAYER);
		end;
	end);
end;

-- Called when a player attempts to change vocation.
function kuroScript.frame:PlayerCanChangeVocation(player, vocation)
	local curTime = CurTime();
	
	-- Check if a statement is true.
	if (player._NextChangeVocation and curTime < player._NextChangeVocation) then
		kuroScript.player.Notify(player, "You cannot change vocation for another "..math.ceil(player._NextChangeVocation - curTime).." second(s)!");
		
		-- Return false to break the function.
		return false;
	else
		return true;
	end;
end;

-- Called when a player attempts to earn contraband currency.
function kuroScript.frame:PlayerCanEarnContrabandCurrency(player, currency) return true; end;

-- Called when a player earns contraband currency.
function kuroScript.frame:PlayerEarnContrabandCurrency(player, currency) end;

-- Called when a player attempts to earn wages currency.
function kuroScript.frame:PlayerCanEarnWagesCurrency(player, currency) return true; end;

-- Called when a player earns wages currency.
function kuroScript.frame:PlayerEarnWagesCurrency(player, currency) end;

-- Called when kuroScript has loaded all of the entities.
function kuroScript.frame:KuroScriptInitPostEntity() end;

-- Called when the map has loaded all the entities.
function kuroScript.frame:InitPostEntity()
	local savePhysicsPositions = kuroScript.config.Get("save_physics_positions"):Get();
	local replaceChairEntities = kuroScript.config.Get("replace_chair_entities"):Get();
	local map = string.lower( game.GetMap() );
	local k, v;
	
	-- Loop through each value in a table.
	for k, v in ipairs( ents.GetAll() ) do
		if ( ValidEntity(v) and v:GetModel() ) then
			if ( kuroScript.entity.IsPhysicsEntity(v) ) then
				local position = tostring( v:GetPos() );
				
				-- Check if a statement is true.
				if (savePhysicsPositions) then
					if (!self.PhysicsPositions) then
						self.PhysicsPositions = self:RestoreGameData("physics/"..map);
					end;
					
					-- Check if a statement is true.
					if ( self.PhysicsPositions[position] ) then
						v:SetPos(self.PhysicsPositions[position].position);
						v:SetAngles(self.PhysicsPositions[position].angles);
					else
						self.PhysicsPositions[position] = {
							position = v:GetPos(),
							angles = v:GetAngles()
						};
					end;
				end;
				
				-- Check if a statement is true.
				if ( replaceChairEntities and kuroScript.entity.IsChairEntity(v) ) then
					local entity = ents.Create("prop_vehicle_prisoner_pod");
					
					-- Set some information.
					entity:SetModel( v:GetModel() );
					entity:SetSkin( v:GetSkin() );
					
					-- Check if a statement is true.
					if ( kuroScript.entity.SetChairAnimations(entity) ) then
						entity:SetAngles( v:GetAngles() );
						entity:SetPos( v:GetPos() );
						entity:Spawn();
						
						-- Check if a statement is true.
						if ( ValidEntity(entity) ) then
							v:Remove(); v = entity;
						end;
					else
						entity:Remove();
					end;
				end;
				
				-- Check if a statement is true.
				if ( self.PhysicsPositions[position] ) then
					local physicsObject = v:GetPhysicsObject();
					
					-- Set some information.
					self.PhysicsPositions[position].entity = v;
					
					-- Check if a statement is true.
					if ( ValidEntity(physicsObject) ) then
						if (self.PhysicsPositions[position].frozen) then
							physicsObject:EnableMotion(false);
						elseif ( !physicsObject:IsMoveable() ) then
							self.PhysicsPositions[position].frozen = true;
						end;
					end;
				end;
			end;
			
			-- Check if a statement is true.
			kuroScript.entity.SetMapEntity(v, true);
			kuroScript.entity.SetStartAngles( v, v:GetAngles() );
			kuroScript.entity.SetStartPosition( v, v:GetPos() );
			
			-- Check if a statement is true.
			if ( kuroScript.entity.SetChairAnimations(v) ) then
				v:SetCollisionGroup(COLLISION_GROUP_WEAPON);
				
				-- Set some information.
				local physicsObject = v:GetPhysicsObject();
				
				-- Check if a statement is true.
				if ( ValidEntity(physicsObject) ) then
					physicsObject:EnableMotion(false);
				end;
			end;
		end;
	end;
	
	-- Set some information.
	self:CreateTimer("kuroScriptInitPostEntity", FrameTime() * 0.5, 1, function()
		hook.Call("KuroScriptInitPostEntity", self);
		
		-- Set some information.
		self.ShouldTick = true;
	end);
end;

-- Called when a player attempts to say something in-character.
function kuroScript.frame:PlayerCanSayIC(player, text)
	if ( ( !player:Alive() or player:IsRagdolled(RAGDOLL_FALLENOVER) ) and !kuroScript.player.GetDeathCode(player, true) ) then
		kuroScript.player.Notify(player, "You cannot do that in this state!");
		
		-- Return false to break the function.
		return false;
	else
		return true;
	end;
end;

-- Called when a player attempts to say something out-of-character.
function kuroScript.frame:PlayerCanSayOOC(player, text) return true; end;

-- Called when a player attempts to say something locally out-of-character.
function kuroScript.frame:PlayerCanSayLOOC(player, text) return true; end;

-- Called when attempts to use a command.
function kuroScript.frame:PlayerCanUseCommand(player, command, arguments) return true; end;

-- Called when a player says something.
function kuroScript.frame:PlayerSay(player, text, public)
	text = string.Replace(text, " ' ", "'");
	text = string.Replace(text, " : ", ":");
	
	-- Set some information.
	local prefix = kuroScript.config.Get("command_prefix"):Get();
	local curTime = CurTime();
	
	-- Check if a statement is true.
	if (string.sub(text, 1, 2) == "//") then
		if (string.Trim( string.sub(text, 3) ) != "") then
			if ( hook.Call("PlayerCanSayOOC", kuroScript.frame, player, text) ) then
				if (!player._NextTalkOOC or curTime > player._NextTalkOOC) then
					kuroScript.frame:Log( "(OOC) "..player:Name()..": "..string.Trim( string.sub(text, 3) ) );
					
					-- Add a chat box message.
					kuroScript.chatBox.Add( nil, player, "ooc", string.Trim( string.sub(text, 3) ) );
					
					-- Set some information.
					player._NextTalkOOC = curTime + kuroScript.config.Get("ooc_interval"):Get();
				else
					kuroScript.player.Notify(player, "You cannot cannot talk out-of-character for another "..math.ceil( player._NextTalkOOC - CurTime() ).." second(s)!");
					
					-- Return a string to break the function.
					return "";
				end;
			end;
		end;
	elseif (string.sub(text, 1, 3) == ".//") then
		if (string.Trim( string.sub(text, 4) ) != "") then
			if ( hook.Call("PlayerCanSayLOOC", kuroScript.frame, player, text) ) then
				kuroScript.chatBox.AddInRadius( player, "looc", string.Trim( string.sub(text, 4) ), player:GetPos(), kuroScript.config.Get("talk_radius"):Get() );
			end;
		end;
	elseif (string.sub(text, 1, 1) == prefix) then
		local prefixLength = string.len(prefix);
		local arguments = self:ExplodeByTags(text, " ", "\"", "\"", true);
		local command = string.sub(arguments[1], prefixLength + 1);
		
		-- Check if a statement is true.
		if (kuroScript.command.stored[command] and kuroScript.command.stored[command].arguments < 2
		and !kuroScript.command.stored[command].optionalArguments) then
			text = string.sub(text, string.len(command) + prefixLength + 2);
			
			-- Check if a statement is true.
			if (text != "") then
				arguments = {command, text};
			else
				arguments = {command};
			end;
		else
			arguments[1] = command;
		end;
		
		-- Run a console command on the player.
		kuroScript.command.ConsoleCommand(player, "ks", arguments);
	elseif ( hook.Call("PlayerCanSayIC", kuroScript.frame, player, text) ) then	
		kuroScript.chatBox.AddInRadius( player, "ic", text, player:GetPos(), kuroScript.config.Get("talk_radius"):Get() );
		
		-- Check if a statement is true.
		if ( kuroScript.player.GetDeathCode(player, true) ) then
			kuroScript.player.UseDeathCode( player, nil, {text} );
		end;
	end;
	
	-- Check if a statement is true.
	if ( kuroScript.player.GetDeathCode(player) ) then
		kuroScript.player.TakeDeathCode(player);
	end;
	
	-- Return a string to break the function.
	return "";
end;

-- Called when a player attempts to suicide.
function kuroScript.frame:CanPlayerSuicide(player) return false; end;

-- Called when a player attempts to punt an entity with the gravity gun.
function kuroScript.frame:GravGunPunt(player, entity)
	return kuroScript.config.Get("enable_gravgun_punt"):Get();
end;

-- Called when a player picks up an entity with the gravity gun.
function kuroScript.frame:GravGunOnPickedUp(player, entity)
	if (entity._DamageImmunity) then
		entity._DamageImmunity = nil;
	end;
end;

-- Called when a player attempts to pickup an entity with the gravity gun.
function kuroScript.frame:GravGunPickupAllowed(player, entity)
	if ( ValidEntity(entity) ) then
		if ( !player:IsAdmin() and !kuroScript.entity.IsInteractable(entity) ) then
			return false;
		else
			return self.BaseClass:GravGunPickupAllowed(player, entity);
		end;
	else
		return false;
	end;
end;

-- Called when a player picks up an entity with the gravity gun.
function kuroScript.frame:GravGunOnPickedUp(player, entity)
	player._IsHoldingEntity = entity;
	entity._IsBeingHeld = player;
end;

-- Called when a player drops an entity with the gravity gun.
function kuroScript.frame:GravGunOnDropped(player, entity)
	player._IsHoldingEntity = nil;
	entity._IsBeingHeld = nil;
end;

-- Called when a player attempts to unfreeze an entity.
function kuroScript.frame:CanPlayerUnfreeze(player, entity, physicsObject)
	if ( kuroScript.config.Get("enable_prop_protection"):Get() ) then
		local ownerKey = entity:GetOwnerKey();
		
		-- Check if a statement is true.
		if (ownerKey and player:QueryCharacter("key") != ownerKey) then
			if ( !player:IsAdmin() ) then
				return false;
			end;
		end;
	end;
	
	-- Check if a statement is true.
	if ( !player:IsAdmin() and !kuroScript.entity.IsInteractable(entity) ) then
		return false;
	end;
	
	-- Check if a statement is true.
	if ( entity:IsVehicle() ) then
		if ( ValidEntity( entity:GetDriver() ) ) then
			return false;
		end;
	end;
	
	-- Return true to break the function.
	return true;
end;

-- Called when a player attempts to freeze an entity with the physics gun.
function kuroScript.frame:OnPhysgunFreeze(weapon, physicsObject, entity, player)
	local isAdmin = player:IsAdmin();
	
	-- Check if a statement is true.
	if (kuroScript.config.Get("enable_prop_protection"):Get() and !isAdmin) then
		local ownerKey = entity:GetOwnerKey();
		
		-- Check if a statement is true.
		if (ownerKey and player:QueryCharacter("key") != ownerKey) then
			return false;
		end;
	end;
	
	-- Check if a statement is true.
	if ( !isAdmin and kuroScript.entity.IsChairEntity(entity) ) then
		local entities = ents.FindInSphere(entity:GetPos(), 64);
		local k, v;
		
		-- Loop through each value in a table.
		for k, v in ipairs(entities) do
			if ( kuroScript.entity.IsDoor(v) ) then
				return false;
			end;
		end;
	end;
	
	-- Check if a statement is true.
	if ( !isAdmin and !kuroScript.entity.IsInteractable(entity) ) then
		return false;
	else
		return self.BaseClass:OnPhysgunFreeze(weapon, physicsObject, entity, player);
	end;
end;

-- Called when a player attempts to pickup an entity with the physics gun.
function kuroScript.frame:PhysgunPickup(player, entity)
	local isAdmin = player:IsAdmin();
	
	-- Check if a statement is true.
	if ( !isAdmin and !kuroScript.entity.IsInteractable(entity) ) then
		return false;
	end;
	
	-- Check if a statement is true.
	if ( !isAdmin and kuroScript.entity.IsPlayerRagdoll(entity) ) then
		return false;
	end;
	
	-- Set some information.
	local physgunPickupDistance = kuroScript.config.Get("physgun_pickup_distance"):Get();
	local canPickup = self.BaseClass:PhysgunPickup(player, entity);
	
	-- Check if a statement is true.
	if (kuroScript.entity.IsChairEntity(entity) and !isAdmin) then
		local entities = ents.FindInSphere(entity:GetPos(), 256);
		local k, v;
		
		-- Loop through each value in a table.
		for k, v in ipairs(entities) do
			if ( kuroScript.entity.IsDoor(v) ) then
				return false;
			end;
		end;
	end;
	
	-- Check if a statement is true.
	if (physgunPickupDistance > 0 and !isAdmin) then
		if (player:GetShootPos():Distance( entity:GetPos() ) > physgunPickupDistance) then
			return false;
		end;
	elseif (isAdmin) then
		canPickup = true;
	end;
	
	-- Check if a statement is true.
	if (kuroScript.config.Get("enable_prop_protection"):Get() and !isAdmin) then
		local physicsObject = entity:GetPhysicsObject();
		
		-- Check if a statement is true.
		if ( !ValidEntity(physicsObject) or !physicsObject:IsMoveable() ) then
			local ownerKey = entity:GetOwnerKey();
			
			-- Check if a statement is true.
			if (ownerKey and player:QueryCharacter("key") != ownerKey) then
				canPickup = false;
			end;
		end;
	end;
	
	-- Check if a statement is true.
	if ( entity:IsPlayer() and entity:InVehicle() ) then
		canPickup = false;
	end;
	
	-- Check if a statement is true.
	if (canPickup) then
		player._IsHoldingEntity = entity;
		entity._IsBeingHeld = player;
		
		-- Check if a statement is true.
		if ( entity:IsPlayer() ) then
			entity._MoveType = entity:GetMoveType();
			
			-- Set the entity's move type.
			entity:SetMoveType(MOVETYPE_NOCLIP);
		end;
		
		-- Return true to break the function.
		return true;
	else
		return false;
	end;
end;

-- Called when a player attempts to drop an entity with the physics gun.
function kuroScript.frame:PhysgunDrop(player, entity)
	if ( entity:IsPlayer() ) then
		entity:SetMoveType(entity._MoveType or MOVETYPE_WALK);
		
		-- Set some information.
		entity._MoveType = nil;
	end;
	
	-- Set some information.
	player._IsHoldingEntity = nil;
	entity._IsBeingHeld = nil;
end;

-- Called when a player attempts to spawn an NPC.
function kuroScript.frame:PlayerSpawnNPC(player, model)
	if ( !kuroScript.player.HasAccess(player, "n") ) then return false; end;
	
	-- Check if a statement is true.
	if ( !player:Alive() or player:IsRagdolled() ) then
		kuroScript.player.Notify(player, "You cannot do that in this state!");
		
		-- Return false to break the function.
		return false;
	end;
	
	-- Check if a statement is true.
	if ( !player:IsAdmin() ) then
		return false;
	else
		return true;
	end;
end;

-- Called when an NPC has been killed.
function kuroScript.frame:OnNPCKilled(entity, attacker, inflictor) end;

-- Called to get whether an entity is being held.
function kuroScript.frame:GetEntityBeingHeld(entity)
	return entity._IsBeingHeld or entity:IsPlayerHolding();
end;

-- Called when an entity is removed.
function kuroScript.frame:EntityRemoved(entity)
	if ( ValidEntity(entity) ) then
		if (entity._GiveRefund) then
			if ( CurTime() <= entity._GiveRefund[1] ) then
				if ( ValidEntity( entity._GiveRefund[2] ) ) then
					kuroScript.player.GiveCurrency(entity._GiveRefund[2], entity._GiveRefund[3], "Prop Refund");
				end;
			end;
		end;
		
		-- Set some information.
		kuroScript.player.property[ entity:EntIndex() ] = nil;
	end;
end;

-- Called when an entity attempts to be auto-removed.
function kuroScript.frame:EntityCanAutoRemove(entity)
	local class = entity:GetClass();
	
	-- Check if a statement is true.
	if (string.find(class, "ks_") or class == "phys_constraintsystem") then
		return false;
	else
		return true;
	end;
end;

-- Called when a player has spawned a prop.
function kuroScript.frame:PlayerSpawnedProp(player, model, entity)
	if ( ValidEntity(entity) ) then
		local maximumPropSize = kuroScript.config.Get("max_prop_size"):Get();
		
		-- Check if a statement is true.
		if ( kuroScript.config.Get("prop_cost"):Get() ) then
			local cost = math.Round( math.max( (entity:BoundingRadius() / 100) * kuroScript.config.Get("scale_prop_cost"):Get(), 1 ) );
			local info = {cost = cost, name = "Prop"};
			
			-- Call a gamemode hook.
			hook.Call("PlayerAdjustPropCostInfo", self, player, entity, info);
			
			-- Check if a statement is true.
			if ( kuroScript.player.CanAfford(player, info.cost) ) then
				kuroScript.player.GiveCurrency(player, -info.cost, info.name);
				
				-- Set some information.
				entity._GiveRefund = {CurTime() + 10, player, info.cost};
			else
				kuroScript.player.Notify(player, "You need another "..FORMAT_CURRENCY(info.cost - player:QueryCharacter("currency"), nil, true).."!");
				
				-- Remove the entity.
				entity:Remove();
				
				-- Return to break the function.
				return;
			end;
		end;
		
		-- Check if a statement is true.
		if ( maximumPropSize > 0 and !player:IsAdmin() ) then
			local boundingRadius = entity:BoundingRadius();
			
			-- Check if a statement is true.
			if (boundingRadius > maximumPropSize) then
				kuroScript.player.Notify(player, "This prop is "..(boundingRadius - maximumPropSize).." units too big!");
				
				-- Remove the entity.
				entity:Remove();
				
				-- Return to break the function.
				return;
			end;
		end;
		
		-- Set some information.
		entity:SetOwnerKey( player:QueryCharacter("key") );
		
		-- Call the base class function.
		self.BaseClass:PlayerSpawnedProp(player, model, entity);
		
		-- Check if a statement is true.
		if ( ValidEntity(entity) ) then
			self:PrintDebug(player:Name().." spawned "..tostring(model).." ("..tostring(entity)..").");
			
			-- Set some information.
			entity._DamageImmunity = CurTime() + 10;
		end;
	end;
end;

-- Called when a player attempts to spawn a prop.
function kuroScript.frame:PlayerSpawnProp(player, model)
	if ( !kuroScript.player.HasAccess(player, "e") ) then return false; end;
	
	-- Check if a statement is true.
	if ( !player:Alive() or player:IsRagdolled() ) then
		kuroScript.player.Notify(player, "You cannot do that in this state!");
		
		-- Return false to break the function.
		return false;
	end;
	
	-- Check if a statement is true.
	if ( player:IsAdmin() ) then
		return true;
	end;
	
	-- Return the base class function.
	return self.BaseClass:PlayerSpawnProp(player, model);
end;

-- Called when a player attempts to spawn a ragdoll.
function kuroScript.frame:PlayerSpawnRagdoll(player, model)
	if ( !kuroScript.player.HasAccess(player, "r") ) then return false; end;
	
	-- Check if a statement is true.
	if ( !player:Alive() or player:IsRagdolled() ) then
		kuroScript.player.Notify(player, "You cannot do that in this state!");
		
		-- Return false to break the function.
		return false;
	end;
	
	-- Check if a statement is true.
	if ( !player:IsAdmin() ) then
		return false;
	else
		return true;
	end;
end;

-- Called when a player attempts to spawn an effect.
function kuroScript.frame:PlayerSpawnEffect(player, model)
	if ( !player:Alive() or player:IsRagdolled() ) then
		kuroScript.player.Notify(player, "You cannot do that in this state!");
		
		-- Return false to break the function.
		return false;
	end;
	
	-- Check if a statement is true.
	if ( !player:IsAdmin() ) then
		return false;
	else
		return true;
	end;
end;

-- Called when a player attempts to spawn a vehicle.
function kuroScript.frame:PlayerSpawnVehicle(player, model)
	if ( !string.find(model, "chair") and !string.find(model, "seat") ) then
		if ( !kuroScript.player.HasAccess(player, "C") ) then
			return false;
		end;
	elseif ( !kuroScript.player.HasAccess(player, "c") ) then
		return false;
	end;
	
	-- Check if a statement is true.
	if ( !player:Alive() or player:IsRagdolled() ) then
		kuroScript.player.Notify(player, "You cannot do that in this state!");
		
		-- Return false to break the function.
		return false;
	end;
	
	-- Check if a statement is true.
	if ( player:IsAdmin() ) then
		return true;
	end;
	
	-- Return the base class function.
	return self.BaseClass:PlayerSpawnVehicle(player, model);
end;

-- Called when a player attempts to use a tool.
function kuroScript.frame:CanTool(player, trace, tool)
	local isAdmin = player:IsAdmin();
	
	-- Check if a statement is true.
	if ( ValidEntity(trace.Entity) ) then
		local characterKey = player:QueryCharacter("key");
		local propProtection = kuroScript.config.Get("enable_prop_protection"):Get();
		
		-- Check if a statement is true.
		if ( !isAdmin and !kuroScript.entity.IsInteractable(trace.Entity) ) then
			return false;
		end;
		
		-- Check if a statement is true.
		if ( !isAdmin and kuroScript.entity.IsPlayerRagdoll(trace.Entity) ) then
			return false;
		end;
		
		-- Check if a statement is true.
		if (propProtection and !isAdmin) then
			local ownerKey = trace.Entity:GetOwnerKey();
			
			-- Check if a statement is true.
			if (ownerKey and characterKey != ownerKey) then
				return false;
			end;
		end;
		
		-- Check if a statement is true.
		if (!isAdmin) then
			if (tool == "nail") then
				local newTrace = {};
				
				-- Set some information.
				newTrace.start = trace.HitPos;
				newTrace.endpos = trace.HitPos + player:GetAimVector() * 16;
				newTrace.filter = {player, trace.Entity};
				
				-- Perform the trace line.
				newTrace = util.TraceLine(newTrace);
				
				-- Check if a statement is true.
				if ( ValidEntity(newTrace.Entity) ) then
					if ( !kuroScript.entity.IsInteractable(newTrace.Entity) or kuroScript.entity.IsPlayerRagdoll(newTrace.Entity) ) then
						return false;
					end;
					
					-- Check if a statement is true.
					if (propProtection) then
						local ownerKey = newTrace.Entity:GetOwnerKey();
						
						-- Check if a statement is true.
						if (ownerKey and characterKey != ownerKey) then
							return false;
						end;
					end;
				end;
			elseif ( tool == "remover" and player:KeyDown(IN_ATTACK2) and !player:KeyDownLast(IN_ATTACK2) ) then
				if ( !trace.Entity:IsMapEntity() ) then
					local entities = constraint.GetAllConstrainedEntities(trace.Entity);
					
					-- Loop through each value in a table.
					for k, v in pairs(entities) do
						if ( v:IsMapEntity() or kuroScript.entity.IsPlayerRagdoll(v) ) then
							return false;
						end;
						
						-- Check if a statement is true.
						if (propProtection) then
							local ownerKey = v:GetOwnerKey();
							
							-- Check if a statement is true.
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
	
	-- Print a debug message.
	self:PrintDebug(player:Name().." used the "..tostring(tool).." tool.");
	
	-- Check if a statement is true.
	if (!isAdmin) then
		return self.BaseClass:CanTool(player, trace, tool);
	else
		return true;
	end;
end;

-- Called when a player attempts to NoClip.
function kuroScript.frame:PlayerNoClip(player)
	if ( player:IsRagdolled() ) then
		return false;
	elseif ( player:IsSuperAdmin() ) then
		return true;
	else
		return false;
	end;
end;

-- Called when the player has initialized.
function kuroScript.frame:PlayerInitialized(player)
	local default = {};
	local k, v;
	
	-- Check if a statement is true.
	if ( !kuroScript.vocation.Get( player:Team() ) ) then
		for k, v in pairs(kuroScript.vocation.stored) do
			if ( v.class == player:QueryCharacter("class") ) then
				if (v.default) then
					default[#default + 1] = v.index;
				end;
			end;
		end;
		
		-- Check if a statement is true.
		if (#default > 0) then
			local vocation = default[ math.random(1, #default) ];
			
			-- Check if a statement is true.
			if (vocation) then
				kuroScript.vocation.Set(player, vocation);
			end;
		else
			for k, v in pairs(kuroScript.vocation.stored) do
				if ( v.class == player:QueryCharacter("class") ) then
					kuroScript.vocation.Set(player, v.index);
					
					-- Return to break the function.
					return;
				end;
			end;
		end;
	end;
end;

-- Called when a player has used their death code.
function kuroScript.frame:PlayerDeathCodeUsed(player, command, arguments) end;

-- Called when a player has created a character.
function kuroScript.frame:PlayerCharacterCreated(player, character) end;

-- Called when a player's character has loaded.
function kuroScript.frame:PlayerCharacterLoaded(player)
	kuroScript.player.PrintArrivalMessage(player);
	
	-- Set some information.
	player:SetSharedVar( "ks_InventoryWeight", kuroScript.config.Get("default_inv_weight"):Get() );
	
	-- Set some information.
	player._CharacterLoadedTime = CurTime();
	player._AttributeBoosts = {};
	player._ChangeVocation = false;
	player._CrouchedSpeed = kuroScript.config.Get("crouched_speed"):Get();
	player._RagdollTable = {};
	player._SpawnWeapons = {};
	player._Initialized = true;
	player._FirstSpawn = true;
	player._LightSpawn = false;
	player._SpawnAmmo = {};
	player._JumpPower = kuroScript.config.Get("jump_power"):Get();
	player._WalkSpeed = kuroScript.config.Get("walk_speed"):Get();
	player._RunSpeed = kuroScript.config.Get("run_speed"):Get();
	
	-- Call a gamemode hook.
	hook.Call( "PlayerRestoreCharacterData", kuroScript.frame, player, player:QueryCharacter("data") );
	hook.Call( "PlayerRestoreTempData", kuroScript.frame, player, player:CreateTempData() );
	
	-- Start a user message.
	umsg.Start("ks_CharacterClose", player);
	umsg.End();
	
	-- Call a gamemode hook.
	hook.Call("PlayerInitialized", kuroScript.frame, player);
	
	-- Set some information.
	timer.Simple(1, function()
		if ( ValidEntity(player) ) then
			player:UnLock();
			
			-- Set some information.
			player._FirstSpawn = false;
			
			-- Set some information.
			kuroScript.player.SetInitialized(player, true);
			kuroScript.player.ReturnProperty(player);
			kuroScript.player.RestoreKnownNames(player);
		end;
	end);
	
	-- Lock the player.
	player:Lock();
end;

-- Called when a player's property should be restored.
function kuroScript.frame:PlayerReturnProperty(player) end;

-- Called when config has initialized for a player.
function kuroScript.frame:PlayerConfigInitialized(player)
	local charactersTable = kuroScript.config.Get("mysql_characters_table"):Get();
	local game = GAME_FOLDER;
	local k2, v2;
	local k, v;
	
	-- Check if a statement is true.
	if (table.Count(kuroScript.class.stored) > 0) then
		kuroScript.player.LoadData(player, function()
			local whitelisted = player:GetData("whitelisted");
			
			-- Start a user message.
			umsg.Start("ks_CharacterMenu", player)
				umsg.Bool(false);
			umsg.End();
			
			-- Loop through each value in a table.
			for k, v in pairs(whitelisted) do
				if ( !kuroScript.class.stored[v] ) then
					whitelisted[k] = nil;
				else
					umsg.Start("ks_CharacterWhitelist", player)
						umsg.String(v);
					umsg.End();
				end;
			end;
			
			-- Set some information.
			kuroScript.player.GetCharacters(player, function(characters)
				if (characters) then
					for k, v in pairs(characters) do
						kuroScript.player.ConvertCharacterMySQL(v);
						
						-- Set some information.
						player._Characters[v._CharacterID] = {};
						
						-- Loop through each value in a table.
						for k2, v2 in pairs(v._Inventory) do
							if ( !kuroScript.item.stored[k2] ) then
								hook.Call("PlayerHasUnknownInventoryItem", self, player, v._Inventory, k2, v2);
								
								-- Set some information.
								v._Inventory[k2] = nil;
							end;
						end;
						
						-- Loop through each value in a table.
						for k2, v2 in pairs(v._Attributes) do
							if ( !kuroScript.attribute.stored[k2] ) then
								hook.Call("PlayerHasUnknownAttribute", self, player, v._Attributes, k2, v2.amount, v2.progress);
								
								-- Set some information.
								v._Attributes[k2] = nil;
							end;
						end;
						
						-- Loop through each value in a table.
						for k2, v2 in pairs(v) do
							if (k2 != "_SteamName") then
								player._Characters[v._CharacterID][k2] = v2;
							else
								player._Characters[v._CharacterID][k2] = player:SteamName();
							end;
						end;
					end;
					
					-- Loop through each value in a table.
					for k, v in pairs(player._Characters) do
						local delete = hook.Call("PlayerAdjustCharacter", self, player, v);
						
						-- Check if a statement is true.
						if (!delete) then
							kuroScript.player.CharacterScreenAdd(player, v);
						else
							tmysql.query("DELETE FROM "..charactersTable.." WHERE _Game = \""..game.."\" AND _SteamID = \""..player:SteamID().."\" AND _CharacterID = "..k);
							
							-- Call a gamemode hook.
							hook.Call("PlayerDeleteCharacter", kuroScript.frame, player, v);
							
							-- Set some information.
							player._Characters[k] = nil;
						end;
					end;
				end;
				
				-- Start a data stream.
				datastream.StreamToClients( {player}, "ks_CharacterMenu", true );
			end);
		end);
	end;
end;

-- Called when a player initially spawns.
function kuroScript.frame:PlayerInitialSpawn(player)
	player._Characters = {};
	
	-- Check if a statement is true.
	if ( ValidEntity(player) ) then
		player:KillSilent();
		
		-- Send the config to the player.
		kuroScript.config.Send(player);
	end;
end;

-- Called each frame that a player is dead.
function kuroScript.frame:PlayerDeathThink(player)
	local action = kuroScript.player.GetAction(player);
	
	-- Check if a statement is true.
	if ( !player:HasInitialized() ) then
		return true;
	end;
	
	-- Check if a statement is true.
	if (action == "spawn") then
		return true;
	else
		player:Spawn();
	end;
end;

-- Called when a player has used their radio.
function kuroScript.frame:PlayerRadioUsed(player, text, listeners, eavesdroppers) end;

-- Called when a player's earned contraband info should be adjusted.
function kuroScript.frame:PlayerAdjustEarnedContrabandInfo(player, info) end;

-- Called when a player's order item should be adjusted.
function kuroScript.frame:PlayerAdjustOrderItemTable(player, itemTable) end;

-- Called when a player's next punch info should be adjusted.
function kuroScript.frame:PlayerAdjustNextPunchInfo(player, info) end;

-- Called when a player's assemble weapon info should be adjusted.
function kuroScript.frame:PlayerAdjustAssembleWeaponInfo(player, info) end;

-- Called when a player's holster weapon info should be adjusted.
function kuroScript.frame:PlayerAdjustHolsterWeaponInfo(player, info) end;

-- Called when a player has an unknown inventory item.
function kuroScript.frame:PlayerHasUnknownInventoryItem(player, inventory, item, amount) end;

-- Called when a player has an unknown attribute.
function kuroScript.frame:PlayerHasUnknownAttribute(player, attributes, attribute, amount, progress) end;

-- Called when a player's character should be adjusted.
function kuroScript.frame:PlayerAdjustCharacter(player, character)
	if ( kuroScript.class.stored[character._Class] ) then
		if ( kuroScript.class.stored[character._Class].whitelist and !kuroScript.player.IsWhitelisted(player, character._Class) ) then
			character._Data["banned"] = true;
		end;
	else
		return true;
	end;
end;

-- Called when a player's character screen info should be adjusted.
function kuroScript.frame:PlayerAdjustCharacterScreenInfo(player, character, info) end;

-- Called when a player's prop cost info should be adjusted.
function kuroScript.frame:PlayerAdjustPropCostInfo(player, entity, info) end;

-- Called when a player's death info should be adjusted.
function kuroScript.frame:PlayerAdjustDeathInfo(player, info) end;

-- Called when debug info should be adjusted.
function kuroScript.frame:DebugAdjustInfo(info) end;

-- Called when chat box info should be adjusted.
function kuroScript.frame:ChatBoxAdjustInfo(info) end;

-- Called when a chat box message has been added.
function kuroScript.frame:ChatBoxMessageAdded(info) end;

-- Called when a player's radio text should be adjusted.
function kuroScript.frame:PlayerAdjustRadioInfo(player, info) end;

-- Called when a player should gain a frag.
function kuroScript.frame:PlayerCanGainFrag(player, victim) return true; end;

-- Called when a player's model should be set.
function kuroScript.frame:PlayerSetModel(player)
	kuroScript.player.SetDefaultModel(player);
	kuroScript.player.SetDefaultSkin(player);
end;

-- Called just after a player spawns.
function kuroScript.frame:PostPlayerSpawn(player, lightSpawn, changeVocation, firstSpawn)
	if (firstSpawn) then
		local health = player:GetCharacterData("health");
		local armor = player:GetCharacterData("armor");
		
		-- Check if a statement is true.
		if (health and health > 1) then
			player:SetHealth(health);
		end;
		
		-- Check if a statement is true.
		if (armor and armor > 1) then
			player:SetArmor(armor);
		end;
	else
		player:SetCharacterData("health", nil);
		player:SetCharacterData("armor", nil);
	end;
	
	-- Check if a statement is true.
	if (changeVocation and !firstSpawn) then
		player._NextChangeVocation = CurTime() + kuroScript.config.Get("change_vocation_interval"):Get();
	end;
end;

-- Called when a player spawns.
function kuroScript.frame:PlayerSpawn(player)
	if ( player:HasInitialized() ) then
		player:ShouldDropWeapon(false);
		
		-- Check if a statement is true.
		if (!player._LightSpawn) then
			kuroScript.player.SetWeaponRaised(player, false);
			kuroScript.player.SetRagdollState(player, RAGDOLL_RESET);
			kuroScript.player.SetAction(player, false);
			kuroScript.player.SetDrunk(player, false);
			
			-- Clear the player's attribute boosts.
			kuroScript.attributes.ClearBoosts(player);
			
			-- Set some information.
			self:PlayerSetModel(player);
			self:PlayerLoadout(player);
			
			-- Set some information.
			player:SetForcedAnimation(false);
			player:SetCollisionGroup(COLLISION_GROUP_PLAYER);
			player:SetMaxHealth(100);
			player:SetMaxArmor(100);
			player:SetMaterial("");
			player:SetMoveType(MOVETYPE_WALK);
			player:Extinguish();
			player:UnSpectate();
			player:GodDisable();
			player:Flashlight(false);
			player:RunCommand("-duck");
			player:SetColor(255, 255, 255, 255);
			
			-- Set some information.
			player:SetCrouchedWalkSpeed( kuroScript.config.Get("crouched_speed"):Get() );
			player:SetWalkSpeed( kuroScript.config.Get("walk_speed"):Get() );
			player:SetJumpPower( kuroScript.config.Get("jump_power"):Get() );
			player:SetRunSpeed( kuroScript.config.Get("run_speed"):Get() );
			
			-- Check if a statement is true.
			if (player._FirstSpawn) then
				local ammo = player:QueryCharacter("ammo");
				local k, v;
				
				-- Loop through each value in a table.
				for k, v in pairs(ammo) do
					if ( !string.find(k, "p_") and !string.find(k, "s_") ) then
						player:GiveAmmo(v, k); ammo[k] = nil;
					end;
				end;
			else
				player:UnLock();
			end;
		end;
		
		-- Check if a statement is true.
		if (player._LightSpawn and player._LightSpawnCallback) then
			player._LightSpawnCallback(player, true);
			player._LightSpawnCallback = nil;
		end;
		
		-- Call a gamemode hook.
		hook.Call("PostPlayerSpawn", self, player, player._LightSpawn, player._ChangeVocation, player._FirstSpawn);
		
		-- Set some information.
		kuroScript.player.SetPlayerKnown(player, player, KNOWN_TOTAL);
		
		-- Set some information.
		player._ChangeVocation = false;
		player._LightSpawn = false;
	else
		player:KillSilent();
	end;
end;

-- Called when a player should take damage.
function kuroScript.frame:PlayerShouldTakeDamage(player, attacker, inflictor, damageInfo)
	if ( !kuroScript.config.Get("enable_prop_killing"):Get() ) then
		return true;
	elseif ( ValidEntity(inflictor) and inflictor:IsBeingHeld() ) then
		return false;
	elseif ( attacker:IsBeingHeld() ) then
		return true;
	end;
end;

-- Called when a player is attacked by a trace.
function kuroScript.frame:PlayerTraceAttack(player, damageInfo, direction, trace)
	player._LastHitGroup = trace.HitGroup;
	
	-- Return false to break the function.
	return false;
end;

-- Called just before a player dies.
function kuroScript.frame:DoPlayerDeath(player, attacker, damageInfo)
	kuroScript.player.DropWeapons(player, attacker);
	kuroScript.player.SetAction(player, false);
	kuroScript.player.SetDrunk(player, false);
	
	-- Set some information.
	local decayTime = kuroScript.config.Get("body_decay_time"):Get();
	
	-- Check if a statement is true.
	if (decayTime > 0) then
		kuroScript.player.SetRagdollState(player, RAGDOLL_KNOCKEDOUT, nil, decayTime, damageInfo:GetDamageForce() / 32);
	else
		kuroScript.player.SetRagdollState(player, RAGDOLL_KNOCKEDOUT, nil, 600, damageInfo:GetDamageForce() / 32);
	end;
	
	-- Check if a statement is true.
	if ( hook.Call("PlayerCanDeathClearKnownNames", self, player, attacker, damageInfo) ) then
		kuroScript.player.ClearKnownNames(player);
	end;
	
	-- Check if a statement is true.
	if ( hook.Call("PlayerCanDeathClearName", self, player, attacker, damageInfo) ) then
		kuroScript.player.ClearName(player);
	end;
	
	-- Emit a sound from the player.
	player:EmitSound( hook.Call( "PlayerPlayDeathSound", kuroScript.frame, player, player:QueryCharacter("gender") ) );
	
	-- Set some information.
	player._SpawnAmmo = {};
	
	-- Set some information.
	player:SetForcedAnimation(false);
	player:SetCharacterData("ammo", {}, true);
	player:StripWeapons();
	player:Extinguish();
	player:StripAmmo();
	player:AddDeaths(1);
	player:UnLock();
	
	-- Check it the attacker is a valid entity and is a player.
	if ( ValidEntity(attacker) and attacker:IsPlayer() ) then
		if (player != attacker) then
			if ( hook.Call("PlayerCanGainFrag", self, attacker, player) ) then
				attacker:AddFrags(1);
			end;
		end;
	end;
end;

-- Called when a player dies.
function kuroScript.frame:PlayerDeath(player, inflictor, attacker, damageInfo)
	self:CalculateSpawnTime(player, inflictor, attacker, damageInfo);
	
	-- Check if a statement is true.
	if ( player:GetRagdollEntity() ) then
		local ragdoll = player:GetRagdollEntity();
		
		-- Check if a statement is true.
		if (inflictor:GetClass() == "prop_combine_ball") then
			if (damageInfo) then
				kuroScript.entity.Disintegrate(player:GetRagdollEntity(), 3, damageInfo:GetDamageForce() / 32);
			else
				kuroScript.entity.Disintegrate(player:GetRagdollEntity(), 3);
			end;
		end;
	end;
	
	-- Check if a statement is true.
	if ( attacker:IsPlayer() ) then
		if ( ValidEntity( attacker:GetActiveWeapon() ) ) then
			self:PrintDebug(attacker:Name().." killed "..player:Name().." with "..kuroScript.player.GetWeaponClass(attacker)..".");
		else
			self:PrintDebug(attacker:Name().." killed "..player:Name()..".");
		end;
	else
		self:PrintDebug(attacker:GetClass().." killed "..player:Name()..".");
	end;
end;

-- Called when a player's weapons should be given.
function kuroScript.frame:PlayerLoadout(player)
	player._SpawnWeapons = {};
	player._SpawnAmmo = {};
	
	-- Check if a statement is true.
	if ( kuroScript.player.HasAccess(player, "t") ) then
		kuroScript.player.GiveSpawnWeapon(player, "gmod_tool");
	end
	
	-- Check if a statement is true.
	if ( kuroScript.player.HasAccess(player, "p") ) then
		kuroScript.player.GiveSpawnWeapon(player, "weapon_physgun");
	end
	
	-- Give the player some spawn weapons.
	kuroScript.player.GiveSpawnWeapon(player, "weapon_physcannon");
	kuroScript.player.GiveSpawnWeapon(player, "ks_hands");
	kuroScript.player.GiveSpawnWeapon(player, "ks_keys");
	
	-- Call a gamemode hook.
	hook.Call("PlayerGiveWeapons", self, player);
	
	-- Select the hands by default.
	player:SelectWeapon("ks_hands");
end

-- Called when the server shuts down.
function kuroScript.frame:ShutDown()
	self.ShuttingDown = true;
end;

-- Called when a player presses F1.
function kuroScript.frame:ShowHelp(player)
	umsg.Start("ks_MenuToggle", player);
	umsg.End();
end;

-- Called when a player presses F2.
function kuroScript.frame:ShowTeam(player)
	local door = player:GetEyeTraceNoCursor().Entity;
	
	-- Check if a statement is true.
	if ( ValidEntity(door) and kuroScript.entity.IsDoor(door) ) then
		if (door:GetPos():Distance( player:GetShootPos() ) <= 192) then
			if ( hook.Call("PlayerCanViewDoor", kuroScript.frame, player, door) ) then
				if ( hook.Call("PlayerUse", kuroScript.frame, player, door) ) then
					local owner = kuroScript.entity.GetOwner(door);
					local k, v;
					
					-- Check if a statement is true.
					if (owner) then
						if ( kuroScript.player.HasDoorAccess(player, door, DOOR_ACCESS_COMPLETE) ) then
							local data = {
								unsellable = kuroScript.entity.IsDoorUnsellable(door),
								accessList = {},
								entity = door,
								owner = owner,
							};
							
							-- Loop through each value in a table.
							for k, v in ipairs( g_Player.GetAll() ) do
								if (v != player and v != owner) then
									if ( kuroScript.player.HasDoorAccess(v, door, DOOR_ACCESS_COMPLETE) ) then
										data.accessList[v] = DOOR_ACCESS_COMPLETE;
									elseif ( kuroScript.player.HasDoorAccess(v, door, DOOR_ACCESS_BASIC) ) then
										data.accessList[v] = DOOR_ACCESS_BASIC;
									end;
								end;
							end;
							
							-- Start a data stream.
							datastream.StreamToClients( {player}, "ks_Door", data );
						end;
					else
						datastream.StreamToClients( {player}, "ks_PurchaseDoor", door );
					end;
				end;
			end;
		end;
	end;
end;

-- Called when a player takes damage.
function kuroScript.frame:PlayerTakeDamage(player, inflictor, attacker, hitGroup, damageInfo)
	if ( !player:IsRagdolled() ) then
		if (damageInfo:IsFallDamage() and damageInfo:GetDamage() >= 10) then
			if ( math.random() <= kuroScript.config.Get("land_fall_over"):Get() ) then
				kuroScript.player.SetRagdollState(player, RAGDOLL_FALLENOVER, 5, nil, damageInfo:GetDamageForce() / 32);
			end;
		end;
	end;
end;

-- Called when an entity takes damage.
function kuroScript.frame:EntityTakeDamage(entity, inflictor, attacker, amount, damageInfo)
	if ( entity:IsPlayer() and entity:InVehicle() and !ValidEntity( entity:GetVehicle():GetParent() ) ) then
		entity._LastHitGroup = self:GetRagdollHitBone( entity, damageInfo:GetDamagePosition() );
		
		-- Check if a statement is true.
		if ( damageInfo:IsBulletDamage() ) then
			if ( ( attacker:IsPlayer() or attacker:IsNPC() ) and attacker != player ) then
				damageInfo:ScaleDamage(5000);
			end;
		end;
	end;
	
	-- Check if a statement is true.
	if (damageInfo:GetDamage() > 0) then
		local isPlayerRagdoll = kuroScript.entity.IsPlayerRagdoll(entity);
		local player = kuroScript.entity.GetPlayer(entity);
		
		-- Check if a statement is true.
		if ( !kuroScript.config.Get("enable_prop_killing"):Get() ) then
			if ( ( attacker._DamageImmunity and attacker._DamageImmunity > CurTime() ) or ( attacker:IsBeingHeld() or inflictor:IsBeingHeld() ) ) then
				if ( player or entity:IsNPC() ) then
					damageInfo:SetDamage(0);
					
					-- Return to break the function.
					return;
				end;
			end;
		end;
		
		-- Check if a statement is true.
		if ( player and (entity:IsPlayer() or isPlayerRagdoll) ) then
			if ( damageInfo:IsFallDamage() or kuroScript.config.Get("damage_view_punch"):Get() ) then
				player:ViewPunch( Angle(math.random(amount, amount), 0, 0) );
			end;
			
			-- Check if a statement is true.
			if ( attacker:IsPlayer() ) then
				self:PrintDebug(player:Name().." took damage from "..attacker:Name().." with "..kuroScript.player.GetWeaponClass(attacker, "an unknown weapon")..".");
			else
				self:PrintDebug(player:Name().." took damage from "..attacker:GetClass()..".");
			end;
			
			-- Check if a statement is true.
			if (!isPlayerRagdoll) then
				if (damageInfo:IsDamageType(DMG_CRUSH) and damageInfo:GetDamage() < 10) then
					damageInfo:SetDamage(0);
				else
					local lastHitGroup = player:LastHitGroup();
					local killed = nil;
					
					-- Check if a statement is true.
					if ( player:InVehicle() and damageInfo:IsExplosionDamage() ) then
						if (!damageInfo:GetDamage() or damageInfo:GetDamage() == 0) then
							damageInfo:SetDamage( player:GetMaxHealth() );
						end;
					end;
					
					-- Scale the damage by hit group and calculate the player damage.
					self:ScaleDamageByHitGroup(player, attacker, lastHitGroup, damageInfo, amount);
					self:CalculatePlayerDamage(player, lastHitGroup, damageInfo);
					
					-- Check if a statement is true.
					if (player:Alive() and player:Health() == 1) then
						player:SetFakingDeath(true);
						
						-- Create some blood effects.
						self:CreateBloodEffects(damageInfo:GetDamagePosition(), 1, player, damageInfo:GetDamageForce() / 8);
						
						-- Call some gamemode hooks.
						hook.Call("DoPlayerDeath", self, player, attacker, damageInfo);
						hook.Call("PlayerDeath", self, player, inflictor, attacker, damageInfo);
						
						-- Set some information.
						player:SetFakingDeath(false, true);
					else
						local silent = hook.Call("PlayerTakeDamage", self, player, inflictor, attacker, lastHitGroup, damageInfo);
						local sound = hook.Call("PlayerPlayPainSound", self, player, player:QueryCharacter("gender"), damageInfo, lastHitGroup);
						
						-- Check if a statement is true.
						if (sound and !silent) then
							player:EmitSound(sound);
						end;
					end;
					
					-- Set some information.
					damageInfo:SetDamage(0);
					
					-- Set some information.
					player._LastHitGroup = nil;
				end;
			elseif (damageInfo:IsDamageType(DMG_CRUSH) and damageInfo:GetDamage() < 10) then
				damageInfo:SetDamage(0);
			else
				local hitGroup = self:GetRagdollHitGroup( entity, damageInfo:GetDamagePosition() );
				local curTime = CurTime();
				local killed = nil;
				
				-- Scale the damage by hit group.
				self:ScaleDamageByHitGroup(player, attacker, hitGroup, damageInfo, amount);
				
				-- Check if a statement is true.
				if ( hook.Call("PlayerRagdollCanTakeDamage", self, player, entity, inflictor, attacker, hitGroup, damageInfo) ) then
					if ( !attacker:IsPlayer() ) then
						if ( attacker == GetWorldEntity() ) then
							if ( damageInfo:IsFallDamage() or damageInfo:IsDamageType(DMG_CRUSH) ) then
								local physicsObject = entity:GetPhysicsObject();
								
								-- Check if a statement is true.
								if (ValidEntity(physicsObject) and physicsObject:GetVelocity():Length() < 5) then
									return;
								elseif ( (entity._NextWorldDamage and entity._NextWorldDamage > curTime) or damageInfo:GetDamage() < 5 ) then
									return;
								end;
								
								-- Set some information.
								entity._NextWorldDamage = curTime + 1;
							end;
						elseif (attacker:GetClass() == "prop_ragdoll" or kuroScript.entity.IsDoor(attacker) or damageInfo:GetDamage() < 5) then
							return;
						end;
					end;
					
					-- Check if a statement is true.
					if (damageInfo:GetDamage() >= 10) then
						self:CreateBloodEffects(damageInfo:GetDamagePosition(), 1, entity, damageInfo:GetDamageForce() / 8);
					end;
					
					-- Calculate the player damage.
					self:CalculatePlayerDamage(player, hitGroup, damageInfo);
					
					-- Check if a statement is true.
					if (player:Alive() and player:Health() == 1) then
						player:SetFakingDeath(true);
						
						-- Set some information.
						player:GetRagdollTable().health = 0;
						player:GetRagdollTable().armor = 0;
						
						-- Call some gamemode hooks.
						hook.Call("DoPlayerDeath", self, player, attacker, damageInfo);
						hook.Call("PlayerDeath", self, player, inflictor, attacker, damageInfo);
						
						-- Set some information.
						player:SetFakingDeath(false, true);
					elseif ( player:Alive() ) then
						local silent = hook.Call("PlayerTakeDamage", self, player, inflictor, attacker, hitGroup, damageInfo);
						local sound = hook.Call("PlayerPlayPainSound", self, player, player:QueryCharacter("gender"), damageInfo);
						
						-- Check if a statement is true.
						if (sound and !silent) then
							entity:EmitSound(sound);
						end;
					end;
					
					-- Set some information.
					damageInfo:SetDamage(0);
				end;
			end;
		elseif (entity:GetClass() == "prop_ragdoll") then
			if (damageInfo:GetDamage() >= 10) then
				if ( !string.find(entity:GetModel(), "matt") and !string.find(entity:GetModel(), "gib") ) then
					local matType = util.QuickTrace( entity:GetPos(), entity:GetPos() ).MatType;
					
					-- Check if a statement is true.
					if (matType == MAT_FLESH or matType == MAT_BLOODYFLESH) then
						self:CreateBloodEffects(damageInfo:GetDamagePosition(), 1, entity, damageInfo:GetDamageForce() / 8);
					end;
				end;
			end;
			
			-- Check if a statement is true.
			if (inflictor:GetClass() == "prop_combine_ball") then
				if (!entity._Disintegrating) then
					kuroScript.entity.Disintegrate(entity, 3, damageInfo:GetDamageForce() / 8);
					
					-- Set some information.
					entity._Disintegrating = true;
				end;
			end;
		elseif ( entity:IsNPC() ) then
			if (attacker:IsPlayer() and ValidEntity( attacker:GetActiveWeapon() )
			and kuroScript.player.GetWeaponClass(attacker) == "weapon_crowbar") then
				damageInfo:ScaleDamage(0.25);
			end;
		end;
	end;
end;

-- Called when the death sound for a player should be played.
function kuroScript.frame:PlayerDeathSound(player) return true; end;

-- Called when a player has disconnected.
function kuroScript.frame:PlayerDisconnected(player)
	if ( player:HasInitialized() ) then
		local uniqueID = player:UniqueID();
		local tempData = player:CreateTempData();
		local key = player:QueryCharacter("key");
		
		-- Close the player's storage.
		kuroScript.player.CloseStorage(player, true)
		kuroScript.player.SetRagdollState(player, RAGDOLL_RESET);
		kuroScript.player.PrintDepartureMessage(player);
		
		-- Loop through each value in a table.
		for k, v in pairs(kuroScript.player.property) do
			if ( ValidEntity(v) and kuroScript.entity.QueryProperty(v, "removeDelay") ) then
				if ( uniqueID == kuroScript.entity.QueryProperty(v, "uniqueID") ) then
					if ( key == kuroScript.entity.QueryProperty(v, "key") ) then
						self:CreateTimer("Remove Delay: "..v:EntIndex(), kuroScript.entity.QueryProperty(v, "removeDelay"), 1, function(entity)
							if ( ValidEntity(entity) ) then
								entity:Remove();
							end;
						end, v);
					end;
				end;
			end;
		end;
		
		-- Save the player's character.
		kuroScript.player.SaveCharacter(player);
		
		-- Check if a statement is true.
		if (tempData) then
			hook.Call("PlayerSaveTempData", kuroScript.frame, player, tempData);
		end;
	end;
end;

-- Called when a player attempts to spawn a SWEP.
function kuroScript.frame:PlayerSpawnSWEP(player, class, weapon)
	if ( !player:IsSuperAdmin() ) then
		return false;
	else
		return true;
	end;
end;

-- Called when a player is given a SWEP.
function kuroScript.frame:PlayerGiveSWEP(player, class, weapon)
	if ( !player:IsSuperAdmin() ) then
		return false;
	else
		return true;
	end;
end;

-- Called when attempts to spawn a SENT.
function kuroScript.frame:PlayerSpawnSENT(player, class)
	if ( !player:IsSuperAdmin() ) then
		return false;
	else
		return true;
	end;
end;

-- Called when a player presses a key.
function kuroScript.frame:KeyPress(player, key)
	if (key == IN_USE) then
		local trace = player:GetEyeTraceNoCursor();
		
		-- Check if a statement is true.
		if ( ValidEntity(trace.Entity) ) then
			if (trace.HitPos:Distance( player:GetShootPos() ) <= 192) then
				if ( hook.Call("PlayerUse", kuroScript.frame, player, trace.Entity) ) then
					if ( kuroScript.entity.IsDoor(trace.Entity) ) then
						if ( hook.Call("PlayerCanUseDoor", kuroScript.frame, player, trace.Entity) ) then
							hook.Call("PlayerUseDoor", kuroScript.frame, player, trace.Entity);
							
							-- Open the door.
							kuroScript.entity.OpenDoor( trace.Entity, 0, nil, nil, player:GetPos() );
						end;
					elseif (trace.Entity.UsableInVehicle) then
						if ( player:InVehicle() ) then
							if (trace.Entity.Use) then
								trace.Entity:Use(player, player);
							end;
						end;
					end;
				end;
			end;
		end;
	elseif (key == IN_WALK) then
		if ( player:GetVelocity():Length() > 0 and !player:KeyDown(IN_SPEED) ) then
			if ( player:GetSharedVar("ks_Jogging") ) then
				player:SetSharedVar("ks_Jogging", false);
			else
				player:SetSharedVar("ks_Jogging", true);
			end;
		elseif ( player:KeyDown(IN_SPEED) ) then
			if ( player:Crouching() ) then
				player:RunCommand("-duck");
			else
				player:RunCommand("+duck");
			end;
		end;
	end;
end;

-- Set some information.
kuroScript.frame.translateAnimationTable = {};
kuroScript.frame.translateAnimationTable[PLAYER_JUMP] = ACT_HL2MP_JUMP;
kuroScript.frame.translateAnimationTable[PLAYER_RELOAD] = ACT_HL2MP_GESTURE_RELOAD;
kuroScript.frame.translateAnimationTable[PLAYER_ATTACK1] = ACT_HL2MP_GESTURE_RANGE_ATTACK;

-- Called when a player model's animation is set.
function kuroScript.frame:SetPlayerModelAnimation(player, animation, crouching, onGround, weapon, raised, speed)
	local act = ACT_HL2MP_IDLE;
	
	-- Check if a statement is true.
	if ( self.translateAnimationTable[animation] ) then
		act = self.translateAnimationTable[animation];
	elseif ( onGround and player:Crouching() ) then
		act = ACT_HL2MP_IDLE_CROUCH;
		
		-- Check if a statement is true.
		if (speed > 0) then
			act = ACT_HL2MP_WALK_CROUCH;
		end;
	elseif ( player:IsRunning() or player:IsJogging() ) then
		act = ACT_HL2MP_RUN;
	elseif (speed > 0) then
		act = ACT_HL2MP_WALK;
	end;
	
	-- Check if a statement is true.
	if (act == ACT_HL2MP_GESTURE_RANGE_ATTACK or act == ACT_HL2MP_GESTURE_RELOAD) then
		kuroScript.player.SetWeaponRaised(player, 3);
		
		-- Restart a player's gesture.
		player:RestartGesture( player:Weapon_TranslateActivity(act) );
		
		-- Check if a statement is true.
		if (act == ACT_HL2MP_GESTURE_RANGE_ATTACK) then
			player:Weapon_SetActivity(player:Weapon_TranslateActivity(ACT_RANGE_ATTACK1), 0);
		end;
	else
		if (!onGround) then
			act = ACT_HL2MP_JUMP;
		end;
		
		-- Check if a statement is true.
		if (raised) then
			act = player:Weapon_TranslateActivity(act);
		end;
		
		-- Set some information.
		local sequence = player:SelectWeightedSequence(act);
		
		-- Check if a statement is true.
		if ( player:InVehicle() ) then
			local vehicle = player:GetVehicle()
			
			-- Check if a statement is true.
			if (vehicle.HandleAnimation) then
				sequence = vehicle:HandleAnimation(player)
				
				-- Check if a statement is true.
				if (!sequence) then return; end;
			else
				local class = vehicle:GetClass();
				
				-- Check if a statement is true.
				if (class == "prop_vehicle_airboat") then
					sequence = player:LookupSequence("drive_airboat");
				elseif (class == "prop_vehicle_jeep") then
					sequence = player:LookupSequence("drive_jeep");
				else 
					sequence = player:LookupSequence("drive_pd");
				end;
			end;
		end;
		
		-- Check if a statement is true.
		if (sequence == -1) then 
			if (act == ACT_HL2MP_JUMP) then
				act = ACT_HL2MP_JUMP_SLAM;
			end;
			
			-- Set some information.
			sequence = player:SelectWeightedSequence(act);
		end
		
		-- Check if a statement is true.
		if (player:GetSequence() == sequence) then
			return;
		end;
		
		-- Set some information.
		player:SetPlaybackRate(1);
		player:ResetSequence(sequence);
		player:SetCycle(0);
	end;
end;

-- Called when a player's animation is set.
function kuroScript.frame:SetPlayerAnimation(player, animation)
	local weaponWasRaised = player:GetSharedVar("ks_WeaponRaised");
	local forcedAnimation = player:GetForcedAnimation();
	local crouching = player:Crouching();
	local onGround = player:OnGround();
	local newWeapon = nil;
	local sequence = 0;
	local curTime = CurTime();
	local raised = kuroScript.player.GetWeaponRaised(player);
	local weapon = player:GetActiveWeapon();
	local speed = player:GetVelocity():Length();
	local model = player:GetModel();
	local act = "";
	
	-- Check if a statement is true.
	if ( ValidEntity(weapon) ) then
		self:HandleWeaponFireDelay(player, raised, weapon, curTime, weaponWasRaised);
	end;
	
	-- Check if a statement is true.
	if (raised) then
		player:SetSharedVar("ks_WeaponRaised", true);
	else
		player:SetSharedVar("ks_WeaponRaised", false);
	end;
	
	-- Check if a statement is true.
	if (player._LastWeapon != weapon) then
		newWeapon = true;
	end;
	
	-- Set some information.
	player._LastWeapon = weapon;
	
	-- Check if a statement is true.
	if ( string.find(model, "/player/") ) then
		return self:SetPlayerModelAnimation(player, animation, crouching, onGround, weapon, raised, speed);
	elseif (forcedAnimation) then
		act = forcedAnimation.animation;
		
		-- Check if a statement is true.
		if (forcedAnimation.onAnimate) then
			forcedAnimation.onAnimate(player);
			forcedAnimation.onAnimate = nil;
		end;
	else
		local animationTable = kuroScript.animation.GetTable(model);
		local weaponHoldType = "pistol";
		
		-- Check if a statement is true.
		if (onGround) then
			if (crouching) then
				act = "crouch";
			else
				act = "stand";
			end;
			
			-- Check if a statement is true.
			if ( ValidEntity(weapon) ) then
				weaponHoldType = kuroScript.animation.GetWeaponHoldType(player, weapon);
				
				-- Check if a statement is true.
				if (weaponHoldType) then
					act = act.."_"..weaponHoldType;
				end;
			end;
			
			-- Check if a statement is true.
			if (raised) then
				act = act.."_aim";
			end;
			
			-- Check if a statement is true.
			if ( player:IsRunning() or player:IsJogging() ) then
				act = act.."_run";
			elseif (speed > 0) then
				act = act.."_walk";
			else
				act = act.."_idle";
			end;
		else
			act = "jump";
		end;
		
		-- Check if a statement is true.
		if( ValidEntity(weapon) and (animation == PLAYER_ATTACK1 or animation == PLAYER_RELOAD) ) then
			kuroScript.player.SetWeaponRaised(player, 3);
			
			-- Check if a statement is true.
			if (animation == PLAYER_RELOAD) then
				local gestureAct = weaponHoldType.."_reload";
				
				-- Check if a statement is true.
				if ( animationTable and animationTable[gestureAct] ) then
					player:RestartGesture( animationTable[gestureAct] );
				end;
			elseif ( string.find(act, "slam") or string.find(act, "blunt") or string.find(act, "grenade") ) then
				local gestureAct = weaponHoldType.."_attack";
				
				-- Check if a statement is true.
				if ( animationTable and animationTable[gestureAct] ) then
					player:RestartGesture( animationTable[gestureAct] );
					player:Weapon_SetActivity(animationTable[gestureAct], 0);
				end;
			end;
			
			-- Return true to break the function.
			return true;
		end;
		
		-- Check if a statement is true.
		if (animationTable) then
			if ( player:InVehicle() and animationTable["sit"] ) then
				act = animationTable["sit"];
			else
				act = animationTable[act];
			end;
		end;
	end;
	
	-- Check if a statement is true.
	if(type(act) == "string") then
		sequence = player:LookupSequence(act);
	else
		sequence = player:SelectWeightedSequence(act);
	end
	
	-- Check if a statement is true.
	if (player:GetSequence() != sequence or newWeapon) then
		player:SetPlaybackRate(1);
		player:ResetSequence(sequence);
		player:SetCycle(0);
	end;
end;

-- Hook a data stream.
datastream.Hook("ks_Door", function(player, handler, uniqueID, rawData, procData)
	if ( ValidEntity( procData[1] ) and player:GetEyeTraceNoCursor().Entity == procData[1] ) then
		if (procData[1]:GetPos():Distance( player:GetPos() ) <= 192) then
			if (procData[2] == "Purchase") then
				if ( !kuroScript.entity.GetOwner( procData[1] ) ) then
					if ( hook.Call( "PlayerCanOwnDoor", kuroScript.frame, player, procData[1] ) ) then
						local doors = kuroScript.player.GetDoorCount(player);
						
						-- Check if a statement is true.
						if ( doors == kuroScript.config.Get("max_doors"):Get() ) then
							kuroScript.player.Notify(player, "You cannot purchase another door!");
						else
							local cost = kuroScript.config.Get("door_cost"):Get();
							
							-- Check if a statement is true.
							if ( kuroScript.player.CanAfford(player, cost) ) then
								kuroScript.player.GiveCurrency(player, -cost, "Door");
								kuroScript.player.GiveDoor( player, procData[1] );
							else
								local amount = cost - player:QueryCharacter("currency");
								
								-- Notify the player.
								kuroScript.player.Notify(player, "You need another "..FORMAT_CURRENCY(amount, nil, true).."!");
							end;
						end;
					end;
				end;
			elseif (procData[2] == "Access") then
				if ( kuroScript.player.HasDoorAccess(player, procData[1], DOOR_ACCESS_COMPLETE) ) then
					if ( ValidEntity( procData[3] ) and procData[3] != player and procData[3] != kuroScript.entity.GetOwner( procData[1] ) ) then
						if (procData[4] == DOOR_ACCESS_COMPLETE) then
							if ( kuroScript.player.HasDoorAccess(procData[3], procData[1], DOOR_ACCESS_COMPLETE) ) then
								kuroScript.player.GiveDoorAccess(procData[3], procData[1], DOOR_ACCESS_BASIC);
							else
								kuroScript.player.GiveDoorAccess(procData[3], procData[1], DOOR_ACCESS_COMPLETE);
							end;
						elseif (procData[4] == DOOR_ACCESS_BASIC) then
							if ( kuroScript.player.HasDoorAccess(procData[3], procData[1], DOOR_ACCESS_BASIC) ) then
								kuroScript.player.TakeDoorAccess( procData[3], procData[1] );
							else
								kuroScript.player.GiveDoorAccess(procData[3], procData[1], DOOR_ACCESS_BASIC);
							end;
						end;
						
						-- Check if a statement is true.
						if ( kuroScript.player.HasDoorAccess(procData[3], procData[1], DOOR_ACCESS_COMPLETE) ) then
							datastream.StreamToClients( {player}, "ks_DoorAccess", {procData[3], DOOR_ACCESS_COMPLETE} );
						elseif ( kuroScript.player.HasDoorAccess(procData[3], procData[1], DOOR_ACCESS_BASIC) ) then
							datastream.StreamToClients( {player}, "ks_DoorAccess", {procData[3], DOOR_ACCESS_BASIC} );
						else
							datastream.StreamToClients( {player}, "ks_DoorAccess", { procData[3] } );
						end;
					end;
				end;
			elseif (procData[2] == "Text") then
				if ( kuroScript.player.HasDoorAccess(player, procData[1], DOOR_ACCESS_COMPLETE) ) then
					if (procData[3] != "") then
						if ( string.find(procData[3], "%w") ) then
							kuroScript.entity.SetDoorText( procData[1], string.sub(procData[3], 1, 32) );
						end;
					end;
				end;
			elseif (procData[2] == "Sell") then
				if (kuroScript.entity.GetOwner( procData[1] ) == player) then
					if ( !kuroScript.entity.IsDoorUnsellable( procData[1] ) ) then
						kuroScript.player.TakeDoor( player, procData[1] );
					end;
				end;
			end;
		end;
	end;
end);

-- Hook a data stream.
datastream.Hook("ks_CreateCharacter", function(player, handler, uniqueID, rawData, procData)
	if (!player._CreatingCharacter) then
		local classTable = kuroScript.class.Get(procData.class);
		
		-- Check if a statement is true.
		if (classTable) then
			procData.class = classTable.name;
			procData.data = {};
			
			-- Check if a statement is true.
			if (!classTable.GetName) then
				if (!classTable.useFullName) then
					if (procData.forename and procData.surname) then
						procData.forename = string.gsub(procData.forename, "^.", string.upper);
						procData.surname = string.gsub(procData.surname, "^.", string.upper);
						
						-- Check if a statement is true.
						if ( string.find(procData.forename, "[%p%s%d]") or string.find(procData.surname, "[%p%s%d]") ) then
							return kuroScript.player.CreationError(player, "Your forename and surname must not contain punctuation, spaces or digits.");
						end;
						
						-- Check if a statement is true.
						if ( !string.find(procData.forename, "[aeiou]") or !string.find(procData.surname, "[aeiou]") ) then
							return kuroScript.player.CreationError(player, "Your forename and surname must both contain at least one vowel!");
						end;
						
						-- Check if a statement is true.
						if ( string.len(procData.forename) < 2 or string.len(procData.surname) < 2) then
							return kuroScript.player.CreationError(player, "Your forename and surname must both be at least 2 characters long!");
						end;
						
						-- Check if a statement is true.
						if ( string.len(procData.forename) > 16 or string.len(procData.surname) > 16) then
							return kuroScript.player.CreationError(player, "Your forename and surname must not be greater than 16 characters long!");
						end;
					else
						return kuroScript.player.CreationError(player, "You did not choose a name, or the name that you chose is not valid!");
					end;
				elseif (!procData.fullName) then
					return kuroScript.player.CreationError(player, "You did not choose a name, or the name that you chose is not valid!");
				end;
			end;
			
			-- Check if a statement is true.
			if (!classTable.GetModel and !procData.model) then
				return kuroScript.player.CreationError(player, "You did not choose a model, or the model that you chose is not valid!");
			end;
			
			-- Check if a statement is true.
			if ( !kuroScript.class.IsGenderValid(procData.class, procData.gender) ) then
				return kuroScript.player.CreationError(player, "You did not choose a gender, or the gender that you chose is not valid!");
			end;
			
			-- Check if a statement is true.
			if ( classTable.whitelist and !kuroScript.player.IsWhitelisted(player, procData.class) ) then
				return kuroScript.player.CreationError(player, "You are not on the "..procData.class.." whitelist!");
			else
				local maximum = kuroScript.player.GetMaximumCharacters(player);
				local gender = string.lower(procData.gender);
				
				-- Check if a statement is true.
				if ( table.HasValue(classTable.models[gender], procData.model) or (classTable.GetModel and !procData.model) ) then
					local charactersTable = kuroScript.config.Get("mysql_characters_table"):Get();
					local characterID;
					local characters = player:GetCharacters();
					local game = GAME_FOLDER;
					local k, v;
					
					-- Loop through each value in a table.
					for i = 1, maximum do
						if ( !characters[i] ) then
							characterID = i; break;
						end;
					end;
					
					-- Check if a statement is true.
					if (characterID) then
						if (classTable.GetName) then
							procData.name = classTable:GetName(player, procData);
						elseif (!classTable.useFullName) then
							procData.name = procData.forename.." "..procData.surname;
						else
							procData.name = procData.fullName;
						end;
						
						-- Check if a statement is true.
						if (classTable.GetModel) then
							procData.model = classTable:GetModel(player, procData);
						end;
						
						-- Check if a statement is true.
						if (classTable.OnCreation) then
							local fault = classTable:OnCreation(player, procData);
							
							-- Check if a statement is true.
							if (fault == false or type(fault) == "string") then
								return kuroScript.player.CreationError(player, fault or "There was an error creating this character!");
							end;
						end;
						
						-- Loop through each value in a table.
						for k, v in pairs(characters) do
							if (v._Name == procData.name) then
								return kuroScript.player.CreationError(player, "You already have a character with the name '"..procData.name.."'!");
							end;
						end;
						
						-- Perform a threaded query.
						tmysql.query("SELECT * FROM "..charactersTable.." WHERE _Game = \""..game.."\" AND _Name = \""..procData.name.."\"", function(result)
							if ( ValidEntity(player) ) then
								if (result and type(result) == "table" and #result > 0) then
									kuroScript.player.CreationError(player, "A character with the name '"..procData.name.."' already exists!");
									
									-- Set some information.
									player._CreatingCharacter = nil;
								else
									kuroScript.player.LoadCharacter( player, characterID, {
										_Gender = procData.gender,
										_Class = procData.class,
										_Model = procData.model,
										_Name = procData.name,
										_Data = procData.data
									}, function()
										kuroScript.frame:PrintDebug(player:SteamName().." created a "..procData.class.." character with the name '"..procData.name.."'.");
										
										-- Start a user message.
										umsg.Start("ks_CharacterFinish", player)
											umsg.Bool(true);
										umsg.End();
										
										-- Set some information.
										player._CreatingCharacter = nil;
									end);
								end;
							end;
						end, 1);
						
						-- Set some information.
						player._CreatingCharacter = true;
					else
						return kuroScript.player.CreationError(player, "You have reached the maximum amount of characters!");
					end;
				else
					return kuroScript.player.CreationError(player, "You did not choose a model, or the model that you chose is not valid!");
				end;
			end;
		else
			return kuroScript.player.CreationError(player, "You did not choose a class, or the class that you chose is not valid!");
		end;
	end;
end);

-- Hook a data stream.
datastream.Hook("ks_InteractCharacter", function(player, handler, uniqueID, rawData, procData)
	if ( !player:HasInitialized() and !player:GetCharacter() ) then
		local characterID = procData.characterID;
		local action = procData.action;
		
		-- Check if a statement is true.
		if (characterID and action) then
			local character = player:GetCharacters()[characterID];
			
			-- Check if a statement is true.
			if (character) then
				local fault = hook.Call("PlayerCanInteractCharacter", kuroScript.frame, player, action, character);
				
				-- Check if a statement is true.
				if (fault == false or type(fault) == "string") then
					return kuroScript.player.CreationError(fault or "You cannot interact with this character!");
				elseif (action == "delete") then
					kuroScript.player.DeleteCharacter(player, characterID);
				elseif (action == "use") then
					kuroScript.player.UseCharacter(player, characterID);
				else
					hook.Call("PlayerSelectCustomCharacterOption", player, action, character);
				end;
			end;
		end;
	end;
end);

-- Hook a data stream.
datastream.Hook("ks_QuizAnswer", function(player, handler, uniqueID, rawData, procData)
	if (!player._QuizAnswers) then
		player._QuizAnswers = {};
	end;
	
	-- Set some information.
	local question = procData[1];
	local answer = procData[2];
	
	-- Check if a statement is true.
	if ( kuroScript.quiz.GetQuestion(question) ) then
		player._QuizAnswers[question] = answer;
	end;
end);

-- Hook a data stream.
datastream.Hook("ks_QuizCompleted", function(player, handler, uniqueID, rawData, procData)
	if ( player._QuizAnswers and !kuroScript.quiz.GetCompleted(player) ) then
		local questionsAmount = kuroScript.quiz.GetQuestionsAmount();
		local correctAnswers = 0;
		local quizQuestions = kuroScript.quiz.GetQuestions();
		local k, v;
		
		-- Loop through each value in a table.
		for k, v in pairs(quizQuestions) do
			if ( player._QuizAnswers[k] ) then
				if ( kuroScript.quiz.IsAnswerCorrect( k, player._QuizAnswers[k] ) ) then
					correctAnswers = correctAnswers + 1;
				end;
			end;
		end;
		
		-- Check if a statement is true.
		if ( correctAnswers < math.Round( questionsAmount * (kuroScript.quiz.GetPercentage() / 100) ) ) then
			kuroScript.quiz.CallKickCallback(player, correctAnswers);
		else
			kuroScript.quiz.SetCompleted(player, true);
		end;
	end;
end);

-- Hook a data stream.
datastream.Hook("ks_GetQuizStatus", function(player, handler, uniqueID, rawData, procData)
	if ( !kuroScript.quiz.GetEnabled() or kuroScript.quiz.GetCompleted(player) ) then
		umsg.Start("ks_QuizCompleted", player);
			umsg.Bool(true);
		umsg.End();
	else
		umsg.Start("ks_QuizCompleted", player);
			umsg.Bool(false);
		umsg.End();
	end;
end);

-- Set some information.
local playerMeta = FindMetaTable("Player");
local entityMeta = FindMetaTable("Entity");

-- Set some information.
playerMeta.KuroScriptSetCrouchedWalkSpeed = playerMeta.SetCrouchedWalkSpeed;
playerMeta.KuroScriptLastHitGroup = playerMeta.LastHitGroup;
playerMeta.KuroScriptSetJumpPower = playerMeta.SetJumpPower;
playerMeta.KuroScriptSetWalkSpeed = playerMeta.SetWalkSpeed;
playerMeta.KuroScriptStripWeapons = playerMeta.StripWeapons;
playerMeta.KuroScriptSetRunSpeed = playerMeta.SetRunSpeed;
entityMeta.KuroScriptSetMaterial = entityMeta.SetMaterial;
playerMeta.KuroScriptStripWeapon = playerMeta.StripWeapon;
playerMeta.KuroScriptGodDisable = playerMeta.GodDisable;
entityMeta.KuroScriptExtinguish = entityMeta.Extinguish;
entityMeta.KuroScriptWaterLevel = entityMeta.WaterLevel;
playerMeta.KuroScriptGodEnable = playerMeta.GodEnable;
entityMeta.KuroScriptSetHealth = entityMeta.SetHealth;
entityMeta.KuroScriptSetColor = entityMeta.SetColor;
entityMeta.KuroScriptIsOnFire = entityMeta.IsOnFire;
entityMeta.KuroScriptSetModel = entityMeta.SetModel;
playerMeta.KuroScriptSetArmor = playerMeta.SetArmor;
entityMeta.KuroScriptSetSkin = entityMeta.SetSkin;
entityMeta.KuroScriptAlive = playerMeta.Alive;
playerMeta.KuroScriptGive = playerMeta.Give;
playerMeta.SteamName = playerMeta.Name;

-- A function to get a player's name.
function playerMeta:Name()
	return self:QueryCharacter( "name", self:SteamName() );
end;

-- A function to get whether a player is alive.
function playerMeta:Alive()
	if (!self._FakingDeath) then
		return self:KuroScriptAlive();
	else
		return false;
	end;
end;

-- A function to set whether a player is faking death.
function playerMeta:SetFakingDeath(fakingDeath, killSilent)
	self._FakingDeath = fakingDeath;
	
	-- Check if a statement is true.
	if (!fakingDeath) then
		if (killSilent) then
			self:KillSilent();
		end;
	end;
end;

-- A function to give a weapon to a player.
function playerMeta:Give(class, uniqueID, forceReturn)
	if ( !hook.Call("PlayerCanBeGivenWeapon", kuroScript.frame, self, class, uniqueID, forceReturn) ) then
		return;
	end;
	
	-- Set some information.
	local itemTable = kuroScript.item.GetWeapon(class, uniqueID);
	local team = self:Team();
	
	-- Check if a statement is true.
	if (self:IsRagdolled() and !forceReturn) then
		local weapons = self:GetRagdollTable().weapons;
		
		-- Check if a statement is true.
		if (weapons) then
			local spawnWeapon = kuroScript.player.GetSpawnWeapon(self, class);
			local holster;
			local k, v;
			
			-- Check if a statement is true.
			if ( itemTable and hook.Call("PlayerCanHolsterWeapon", kuroScript.frame, self, itemTable, true, true) ) then
				holster = true;
			end;
			
			-- Check if a statement is true.
			if (!spawnWeapon) then
				team = nil;
			end;
			
			-- Loop through each value in a table.
			for k, v in pairs(weapons) do
				if (v[1].class == class and v[1].uniqueID == uniqueID) then
					v[2] = holster;
					v[3] = team;
					
					-- Return to break the function.
					return;
				end;
			end;
			
			-- Set some information.
			weapons[#weapons + 1] = { {class = class, uniqueID = uniqueID}, holster, team };
		end;
	elseif ( !self:HasWeapon(class) ) then
		self._NextCheckEmpty = CurTime() + 2;
		
		-- Set some information.
		self._ForceGive = true;
			self:KuroScriptGive(class);
		self._ForceGive = nil;
		
		-- Set some information.
		local weapon = self:GetWeapon(class);
		
		-- Check if a statement is true.
		if ( !ValidEntity(weapon) ) then
			return true;
		else
			if (itemTable) then
				kuroScript.player.StripDefaultAmmo(self, weapon, itemTable);
				kuroScript.player.RestorePrimaryAmmo(self, weapon);
				kuroScript.player.RestoreSecondaryAmmo(self, weapon);
			end;
			
			-- Check if a statement is true.
			if (uniqueID and uniqueID != "") then
				weapon:SetNetworkedString("ks_UniqueID", uniqueID);
			end;
		end;
	end;
end;

-- A function to get a player's data.
function playerMeta:GetData(key, default)
	if (self._Data) then
		if (self._Data[key] != nil) then
			return self._Data[key];
		else
			return default;
		end;
	else
		return default;
	end;
end;

-- A function to set a player's data.
function playerMeta:SetData(key, value)
	if (self._Data) then
		self._Data[key] = value;
	end;
end;

-- A function to set an entity's skin.
function entityMeta:SetSkin(skin)
	if ( self:IsPlayer() and self:IsRagdolled() ) then
		self:GetRagdollEntity():SetSkin(skin);
	end;
	
	-- Set the player's skin.
	self:KuroScriptSetSkin(skin);
end;

-- A function to set an entity's model.
function entityMeta:SetModel(model)
	if ( self:IsPlayer() and self:IsRagdolled() ) then
		self:GetRagdollEntity():SetModel(model);
	end;
	
	-- Set the player's model.
	self:KuroScriptSetModel(model);
end;

-- A function to get an entity's owner key.
function entityMeta:GetOwnerKey()
	return self._OwnerKey;
end;

-- A function to set an entity's owner key.
function entityMeta:SetOwnerKey(key)
	self._OwnerKey = key;
end;

-- A function to auto-remove an entity.
function entityMeta:AutoRemove()
	if ( !self:IsMapEntity() and !self:IsPlayer() ) then
		if ( hook.Call("EntityCanAutoRemove", kuroScript.frame, self) ) then
			self:Remove();
		end;
	end;
end;

-- A function to get whether an entity is a map entity.
function entityMeta:IsMapEntity()
	return kuroScript.entity.IsMapEntity(self);
end;

-- A function to get an entity's start position.
function entityMeta:GetStartPosition()
	return kuroScript.entity.GetStartPosition(self);
end;

-- A function to set an entity's material.
function entityMeta:SetMaterial(material)
	if ( self:IsPlayer() and self:IsRagdolled() ) then
		self:GetRagdollEntity():SetMaterial(material);
	end;
	
	-- Set the player's color.
	self:KuroScriptSetMaterial(material);
end;

-- A function to set an entity's color.
function entityMeta:SetColor(r, g, b, a)
	if ( self:IsPlayer() and self:IsRagdolled() ) then
		self:GetRagdollEntity():SetColor(r, g, b, a);
	end;
	
	-- Set the player's color.
	self:KuroScriptSetColor(r, g, b, a);
end;

-- A function to set a player's armor.
function playerMeta:SetArmor(armor)
	hook.Call("PlayerArmorSet", kuroScript.frame, self, armor);
	
	-- Set some information.
	self:KuroScriptSetArmor(armor);
end;

-- A function to set a player's health.
function playerMeta:SetHealth(health)
	hook.Call("PlayerHealthSet", kuroScript.frame, self, health);
	
	-- Set some information.
	self:KuroScriptSetHealth(health);
end;

-- A function to get whether a player is running.
function playerMeta:IsRunning()
	if ( self:KeyDown(IN_SPEED) ) then
		if ( self:Alive() and !self:IsRagdolled() and !self:InVehicle() and !self:Crouching() ) then
			local sprintSpeed = self:GetNetworkedFloat("SprintSpeed");
			local velocity = self:GetVelocity():Length();
			
			-- Check if a statement is true.
			if (velocity >= math.max(sprintSpeed - 25, 25) and velocity > 0) then
				return true;
			end;
		end;
	end;
end;

-- A function to get whether a player is jogging.
function playerMeta:IsJogging(testSpeed)
	if ( !self:IsRunning() and (self:GetSharedVar("ks_Jogging") or testSpeed) ) then
		if ( self:Alive() and !self:IsRagdolled() and !self:InVehicle() and !self:Crouching() ) then
			local walkSpeed = self:GetNetworkedFloat("WalkSpeed");
			local velocity = self:GetVelocity():Length();
			
			-- Check if a statement is true.
			if (velocity >= math.max(walkSpeed - 25, 25) and velocity > 0) then
				return true;
			end;
		end;
	end;
end;

-- A function to strip a weapon from a player.
function playerMeta:StripWeapon(weapon)
	if ( self:IsRagdolled() ) then
		local weapons = self:GetRagdollTable().weapons;
		local k, v;
		
		-- Loop through each value in a table.
		for k, v in pairs(weapons) do
			if (v[1] == weapon) then weapons[k] = nil; end;
		end;
	else
		self:KuroScriptStripWeapon(weapon);
	end;
end;

-- A function to strip a player's weapons.
function playerMeta:StripWeapons(ragdoll)
	if (self:IsRagdolled() and !ragdoll) then
		self:GetRagdollTable().weapons = {};
	else
		self:KuroScriptStripWeapons();
	end;
end;

-- A function to enable God for a player.
function playerMeta:GodEnable()
	self._GodMode = true; self:KuroScriptGodEnable();
end;

-- A function to disable God for a player.
function playerMeta:GodDisable()
	self._GodMode = nil; self:KuroScriptGodDisable();
end;

-- A function to get a player's water level.
function playerMeta:WaterLevel()
	if ( self:IsRagdolled() ) then
		return self:GetRagdollEntity():WaterLevel();
	else
		return self:KuroScriptWaterLevel();
	end;
end;

-- A function to get whether a player is on fire.
function playerMeta:IsOnFire()
	if ( self:IsRagdolled() ) then
		return self:GetRagdollEntity():IsOnFire();
	else
		return self:KuroScriptIsOnFire();
	end;
end;

-- A function to extinguish a player.
function playerMeta:Extinguish()
	if ( self:IsRagdolled() ) then
		return self:GetRagdollEntity():Extinguish();
	else
		return self:KuroScriptExtinguish();
	end;
end;

-- A function to get whether a player is using their hands.
function playerMeta:IsUsingHands()
	return kuroScript.player.GetWeaponClass(self) == "ks_hands";
end;

-- A function to get whether a player is using their hands.
function playerMeta:IsUsingKeys()
	return kuroScript.player.GetWeaponClass(self) == "ks_keys";
end;

-- A function to get a player's wages.
function playerMeta:GetWages()
	return kuroScript.player.GetWages(self);
end;

-- A function to get a player's community ID.
function playerMeta:CommunityID()
	local x, y, z = string.match(self:SteamID(), "STEAM_(%d+):(%d+):(%d+)");
	
	-- Check if a statement is true.
	if (x and y and z) then
		return (z * 2) + STEAM_COMMUNITY_ID + y;
	else
		return self:SteamID();
	end;
end;

-- A function to get whether a player is ragdolled.
function playerMeta:IsRagdolled(exception, entityless)
	return kuroScript.player.IsRagdolled(self, exception, entityless);
end;

-- A function to get a player's character table.
function playerMeta:GetCharacter() return kuroScript.player.GetCharacter(self); end;

-- A function to get a player's storage table.
function playerMeta:GetStorageTable() return kuroScript.player.GetStorageTable(self); end;
 
-- A function to get a player's ragdoll table.
function playerMeta:GetRagdollTable() return kuroScript.player.GetRagdollTable(self); end;

-- A function to get a player's ragdoll state.
function playerMeta:GetRagdollState() return kuroScript.player.GetRagdollState(self); end;

-- A function to get a player's storage entity.
function playerMeta:GetStorageEntity() return kuroScript.player.GetStorageEntity(self); end;

-- A function to get a player's ragdoll entity.
function playerMeta:GetRagdollEntity() return kuroScript.player.GetRagdollEntity(self); end;

-- A function to set a player's maximum armor.
function playerMeta:SetMaxArmor(armor)
	self:SetSharedVar("ks_MaxArmor", armor);
end;

-- A function to get a player's maximum armor.
function playerMeta:GetMaxArmor(armor)
	local maxArmor = self:GetSharedVar("ks_MaxArmor");
	
	-- Check if a statement is true.
	if (maxArmor > 0) then
		return maxArmor;
	else
		return 100;
	end;
end;

-- A function to set a player's maximum health.
function playerMeta:SetMaxHealth(health)
	self:SetSharedVar("ks_MaxHealth", health);
end;

-- A function to get a player's maximum health.
function playerMeta:GetMaxHealth(health)
	local maxHealth = self:GetSharedVar("ks_MaxHealth");
	
	-- Check if a statement is true.
	if (maxHealth > 0) then
		return maxHealth;
	else
		return 100;
	end;
end;

-- A function to get a player's last hit group.
function playerMeta:LastHitGroup()
	return self._LastHitGroup or self:KuroScriptLastHitGroup();
end;

-- A function to get whether an entity is being held.
function entityMeta:IsBeingHeld()
	return hook.Call("GetEntityBeingHeld", kuroScript.frame, self);
end;

-- A function to run a command on a player.
function playerMeta:RunCommand(...)
	datastream.StreamToClients( {self}, "ks_RunCommand", {...} );
end;

-- A function to get a player's wages name.
function playerMeta:GetWagesName()
	return kuroScript.player.GetWagesName(self);
end;

-- A function to set a player's forced animation.
function playerMeta:SetForcedAnimation(animation, delay, onAnimate, onFinish)
	local forcedAnimation = self:GetForcedAnimation();
	local callFinish;
	local sequence;
	
	-- Check if a statement is true.
	if (animation) then
		if (!forcedAnimation or forcedAnimation.delay != 0) then
			callFinish = true;
			
			-- Check if a statement is true.
			if (type(animation) == "string") then
				sequence = self:LookupSequence(animation);
			else
				sequence = self:SelectWeightedSequence(animation);
			end;
			
			-- Reset the player's sequence.
			self:SetPlaybackRate(1);
			self:ResetSequence(sequence);
			self:SetCycle(0);
			
			-- Set some information.
			self._ForcedAnimation = {
				animation = animation,
				onAnimate = onAnimate,
				onFinish = onFinish,
				delay = delay
			};
			
			-- Check if a statement is true.
			if (delay and delay != 0) then
				kuroScript.frame:CreateTimer("Forced Animation: "..self:UniqueID(), delay, 1, function()
					if ( ValidEntity(self) ) then
						local forcedAnimation = self:GetForcedAnimation();
						
						-- Check if a statement is true.
						if (forcedAnimation) then
							self:SetForcedAnimation(false);
						end;
					end;
				end);
			else
				kuroScript.frame:DestroyTimer( "Forced Animation: "..self:UniqueID() );
			end;
		end;
	else
		callFinish = true;
		
		-- Set some information.
		self._ForcedAnimation = nil;
	end;
	
	-- Check if a statement is true.
	if (callFinish) then
		if (forcedAnimation and forcedAnimation.onFinish) then
			forcedAnimation.onFinish(self);
		end;
	end;
end;

-- A function to get whether a player's config has initialized.
function playerMeta:HasConfigInitialized()
	return self._ConfigInitialized;
end;

-- A function to get a player's forced animation.
function playerMeta:GetForcedAnimation()
	return self._ForcedAnimation;
end;

-- A function to get a player's item entity.
function playerMeta:GetItemEntity()
	if ( ValidEntity(self._ItemEntity) ) then
		return self._ItemEntity;
	end;
end;

-- A function to set a player's item entity.
function playerMeta:SetItemEntity(entity)
	self._ItemEntity = entity;
end;

-- A function to create a player's temporary data.
function playerMeta:CreateTempData()
	local uniqueID = self:UniqueID();
	
	-- Check if a statement is true.
	if ( !kuroScript.frame.TempPlayerData[uniqueID] ) then
		kuroScript.frame.TempPlayerData[uniqueID] = {};
	end;
	
	-- Return the player's temporary data.
	return kuroScript.frame.TempPlayerData[uniqueID];
end;

-- A function to set a player's temporary data.
function playerMeta:SetTempData(key, value)
	local tempData = self:CreateTempData();
	
	-- Check if a statement is true.
	if (tempData) then
		tempData[key] = value;
	end;
end;

-- A function to get a player's temporary data.
function playerMeta:GetTempData(key, default)
	local tempData = self:CreateTempData();
	
	-- Check if a statement is true.
	if (tempData and tempData[key] != nil) then
		return tempData[key];
	else
		return default;
	end;
end;

-- A function to get a player's characters.
function playerMeta:GetCharacters()
	return self._Characters;
end;

-- A function to set a player's run speed.
function playerMeta:SetRunSpeed(speed, kuroScript)
	if (!kuroScript) then self._RunSpeed = speed; end;
	
	-- Set some information.
	self:KuroScriptSetRunSpeed(speed);
end;

-- A function to set a player's walk speed.
function playerMeta:SetWalkSpeed(speed, kuroScript)
	if (!kuroScript) then self._WalkSpeed = speed; end;
	
	-- Set some information.
	self:KuroScriptSetWalkSpeed(speed);
end;

-- A function to set a player's jump power.
function playerMeta:SetJumpPower(power, kuroScript)
	if (!kuroScript) then self._JumpPower = power; end;
	
	-- Set some information.
	self:KuroScriptSetJumpPower(power);
end;

-- A function to set a player's crouched walk speed.
function playerMeta:SetCrouchedWalkSpeed(speed, kuroScript)
	if (!kuroScript) then self._CrouchedSpeed = speed; end;
	
	-- Set some information.
	self:KuroScriptSetCrouchedWalkSpeed(speed);
end;

-- A function to get whether a player has initialized.
function playerMeta:HasInitialized()
	return self._Initialized;
end;

-- A function to query a player's character table.
function playerMeta:QueryCharacter(key, default)
	if ( self:GetCharacter() ) then
		return kuroScript.player.Query(self, key, default);
	else
		return default;
	end;
end;

-- A function to get a player's shared variable.
function entityMeta:GetSharedVar(key)
	if ( self:IsPlayer() ) then
		return kuroScript.player.GetSharedVar(self, key);
	else
		return kuroScript.entity.GetSharedVar(self, key);
	end;
end;

-- A function to set a shared variable for a player.
function entityMeta:SetSharedVar(key, value)
	if ( self:IsPlayer() ) then
		kuroScript.player.SetSharedVar(self, key, value);
	else
		kuroScript.entity.SetSharedVar(self, key, value);
	end;
end;

-- A function to get a player's character data.
function playerMeta:GetCharacterData(key, default)
	if ( self:GetCharacter() ) then
		local data = self:QueryCharacter("data");
		
		-- Check if a statement is true.
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
	
	-- Check if a statement is true.
	if (character) then
		if (base) then
			key = "_"..kuroScript.frame:SetCamelCase(string.gsub(key, "_", ""), false);
			
			-- Check if a statement is true.
			if (character[key] != nil) then
				character[key] = value;
			end;
		else
			character._Data[key] = value;
		end;
	end;
end;

-- A function to get the entity a player is holding.
function playerMeta:GetHoldingEntity()
	return self._IsHoldingEntity;
end;

-- Set some information.
playerMeta.GetName = playerMeta.Name;
playerMeta.Nick = playerMeta.Name;