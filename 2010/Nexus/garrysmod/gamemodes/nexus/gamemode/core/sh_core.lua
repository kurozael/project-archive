--[[
Name: "sh_core.lua".
Product: "nexus".
--]]

NEXUS.Timers = {};
NEXUS.DataStreamHooks = {};
NEXUS.GlobalSharedVars = {};

function ScaleToWideScreen(size)
	return math.min(math.max( ScreenScale(size / 2.62467192), math.min(size, 14) ), size);
end;

-- A function to hook a data stream.
function NEXUS:HookDataStream(name, Callback)
	self.DataStreamHooks[name] = Callback;
end;

-- A function to get the schema folder.
function NEXUS:GetSchemaFolder()
	local folder = string.gsub(self.SchemaFolder, "gamemodes/", "");
	
	if (folder) then
		return folder;
	end;
end;

-- A function to get the nexus folder.
function NEXUS:GetNexusFolder()
	local folder = string.gsub(self.NexusFolder, "gamemodes/", "");
	
	if (folder) then
		return folder;
	end;
end;

-- A function to save schema data.
function NEXUS:SaveSchemaData(fileName, data)
	g_File.Write( "nexus/schemas/"..self:GetSchemaFolder().."/"..fileName..".txt", glon.encode(data) );
end;

-- A function to delete schema data.
function NEXUS:DeleteSchemaData(fileName)
	g_File.Delete("nexus/schemas/"..self:GetSchemaFolder().."/"..fileName..".txt");
end;

-- A function to check if schema data exists.
function NEXUS:SchemaDataExists(fileName)
	return g_File.Exists("nexus/schemas/"..self:GetSchemaFolder().."/"..fileName..".txt");
end;

-- A function to restore schema data.
function NEXUS:RestoreSchemaData(fileName, default)
	if ( self:SchemaDataExists(fileName) ) then
		local data = g_File.Read("nexus/schemas/"..self:GetSchemaFolder().."/"..fileName..".txt");
		
		if (data) then
			local success, value = pcall(glon.decode, data);
			
			if (success and value != nil) then
				return value;
			else
				local success, value = pcall(Json.Decode, data);
				
				if (success and value != nil) then
					return value;
				end;
			end;
		end;
	end;
	
	if (default != nil) then
		return default;
	else
		return {};
	end;
end;

-- A function to save nexus data.
function NEXUS:SaveNexusData(fileName, data)
	g_File.Write( "nexus/"..fileName..".txt", glon.encode(data) );
end;

-- A function to check if nexus data exists.
function NEXUS:NexusDataExists(fileName)
	return g_File.Exists("nexus/"..fileName..".txt");
end;

-- A function to delete nexus data.
function NEXUS:DeleteNexusData(fileName)
	g_File.Delete("nexus/"..fileName..".txt");
end;

-- A function to convert a string to a boolean.
function NEXUS:ToBool(text)
	if (text == "true" or text == "yes" or text == "1") then
		return true;
	else
		return false;
	end;
end;

-- A function to split a string.
function NEXUS:SplitString(text, interval)
	local length = string.len(text);
	local base = {};
	local i = 0;
	
	while (i * interval < length) do
		base[i + 1] = string.sub(text, i * interval + 1, (i + 1) * interval);
		
		i = i + 1;
	end;
	
	return base;
end;

-- Called when the player's jumping animation should be handled.
function NEXUS:HandlePlayerJumping(player)
	local model = player:GetModel();
	local animationTable = nexus.animation.GetTable(model);
	
	if (!player.m_bJumping and !player:OnGround() and player:WaterLevel() <= 0) then
		player.m_bJumping = true;
		player.m_bFirstJumpFrame = false;
		player.m_flJumpStartTime = 0;
	end
	
	if (player.m_bJumping) then
		if (player.m_bFirstJumpFrame) then
			player.m_bFirstJumpFrame = false;
			player:AnimRestartMainSequence();
		end;
		
		if (player:WaterLevel() >= 2) then
			player.m_bJumping = false;
			player:AnimRestartMainSequence();
		elseif (CurTime() - player.m_flJumpStartTime > 0.2) then
			if ( player:OnGround() ) then
				player.m_bJumping = false;
				player:AnimRestartMainSequence();
			end
		end
		
		if (player.m_bJumping) then
			player.CalcIdeal = animationTable["jump"];
			
			return true;
		end;
	end;
	
	return false;
end;

-- Called when the player's ducking animation should be handled.
function NEXUS:HandlePlayerDucking(player, velocity)
	if (player:Crouching()) then
		local model = player:GetModel();
		local weapon = player:GetActiveWeapon();
		local raised = nexus.player.GetWeaponRaised(player, true);
		local velLength = velocity:Length2D();
		local animationTable = nexus.animation.GetTable(model);
		local animationAct = "crouch";
		local weaponHoldType = "pistol";
		
		if ( IsValid(weapon) ) then
			weaponHoldType = nexus.animation.GetWeaponHoldType(player, weapon);
		
			if (weaponHoldType) then
				animationAct = animationAct.."_"..weaponHoldType;
			end;
		end;
		
		if (raised) then
			animationAct = animationAct.."_aim";
		end;
		
		if (velLength > 0.5) then
			animationAct = animationAct.."_walk";
		else
			animationAct = animationAct.."_idle";
		end;

		player.CalcIdeal = animationTable[animationAct];
		
		return true;
	end;
	
	return false;
end;

-- Called when the player's swimming animation should be handled.
function NEXUS:HandlePlayerSwimming(player)
	if (player:WaterLevel() >= 2) then
		if (player.m_bFirstSwimFrame) then
			player:AnimRestartMainSequence();
			player.m_bFirstSwimFrame = false;
		end;
		
		player.m_bInSwim = true;
	else
		player.m_bInSwim = false;
		
		if (!player.m_bFirstSwimFrame) then
			player.m_bFirstSwimFrame = true;
		end;
	end;
	
	return false;
end;

-- Called when the player's driving animation should be handled.
function NEXUS:HandlePlayerDriving(player)
	if ( player:InVehicle() ) then
		local model = player:GetModel();
		local animationTable = nexus.animation.GetTable(model);

		player.CalcIdeal = animationTable["sit"];
		
		return true;
	end;
	
	return false;
end;

-- Called when a player's animation is updated.
function NEXUS:UpdateAnimation(player, velocity, maxSeqGroundSpeed)	
	local velLength = velocity:Length2D();
	local rate = 1.0;
	
	if (velLength > 0.5) then
		rate = ( ( velLength * 0.8 ) / maxSeqGroundSpeed );
	end
	
	player.playbackRate = math.Clamp(rate, 0, 1.5);
	player:SetPlaybackRate(player.playbackRate);
end;

-- Called when the main activity should be calculated.
function NEXUS:CalcMainActivity(player, velocity)
	local model = player:GetModel();
	
	if ( string.find(model, "/player/") ) then
		return self.BaseClass:CalcMainActivity(player, velocity);
	end;
	
	local weapon = player:GetActiveWeapon();
	local raised = nexus.player.GetWeaponRaised(player, true);
	local animationAct = "stand";
	local weaponHoldType = "pistol";
	local animationTable = nexus.animation.GetTable(model);
	local forcedAnimation = player:GetForcedAnimation();

	if ( IsValid(weapon) ) then
		weaponHoldType = nexus.animation.GetWeaponHoldType(player, weapon);
	
		if (weaponHoldType) then
			animationAct = animationAct.."_"..weaponHoldType;
		end;
	end;
	
	if (raised) then
		animationAct = animationAct.."_aim";
	end;
	
	player.CalcIdeal = animationTable[animationAct.."_idle"];
	player.CalcSeqOverride = -1;
	
	if ( !self:HandlePlayerDriving(player)
	and !self:HandlePlayerJumping(player)
	and !self:HandlePlayerDucking(player, velocity)
	and !self:HandlePlayerSwimming(player) ) then
		local velLength = velocity:Length2D();
		
		if ( player:IsRunning() or player:IsJogging() ) then
			player.CalcIdeal = animationTable[animationAct.."_run"];
		elseif (velLength > 0.5) then
			player.CalcIdeal = animationTable[animationAct.."_walk"];
		end;
	end;
	
	if (forcedAnimation) then
		player.CalcSeqOverride = forcedAnimation.animation;
		
		if (forcedAnimation.onAnimate) then
			forcedAnimation.onAnimate(player);
			forcedAnimation.onAnimate = nil;
		end;
	end;
	
	if (type(player.CalcSeqOverride) == "string") then
		player.CalcSeqOverride = player:LookupSequence(player.CalcSeqOverride);
	end;
	
	if (type(player.CalcIdeal) == "string") then
		player.CalcIdeal = player:LookupSequence(player.CalcIdeal);
	end;
	
	return player.CalcIdeal, player.CalcSeqOverride;
end;

local IdleActivity = ACT_HL2MP_IDLE;
local IdleActivityTranslate = {
	ACT_MP_ATTACK_CROUCH_PRIMARYFIRE = IdleActivity + 5,
	ACT_MP_ATTACK_STAND_PRIMARYFIRE = IdleActivity + 5,
	ACT_MP_RELOAD_CROUCH = IdleActivity + 6,
	ACT_MP_RELOAD_STAND = IdleActivity + 6,
	ACT_MP_CROUCH_IDLE = IdleActivity + 3,
	ACT_MP_STAND_IDLE = IdleActivity,
	ACT_MP_CROUCHWALK = IdleActivity + 4,
	ACT_MP_JUMP = ACT_HL2MP_JUMP_SLAM,
	ACT_MP_WALK = IdleActivity + 1,
	ACT_MP_RUN = IdleActivity + 2,
};
	
-- Called when a player's activity is supposed to be translated.
function NEXUS:TranslateActivity(player, act)
	local model = player:GetModel();
	local raised = nexus.player.GetWeaponRaised(player, true);
	
	if ( string.find(model, "/player/") ) then
		local newAct = player:TranslateWeaponActivity(act);
		
		if (!raised or act == newAct) then
			return IdleActivityTranslate[act];
		else
			return newAct;
		end;
	end;
	
	return act;
end;

-- Called when the animation event is supposed to be done.
function NEXUS:DoAnimationEvent(player, event, data)
	local model = player:GetModel();
	
	if ( string.find(model, "/player/") ) then
		return self.BaseClass:DoAnimationEvent(player, event, data);
	end;
	
	local weapon = player:GetActiveWeapon();
	local animationAct = "pistol";
	local animationTable = nexus.animation.GetTable(model);
	
	if ( IsValid(weapon) ) then
		weaponHoldType = nexus.animation.GetWeaponHoldType(player, weapon);
	
		if (weaponHoldType) then
			animationAct = weaponHoldType;
		end;
	end;
	
	if (event == PLAYERANIMEVENT_ATTACK_PRIMARY) then
		local gestureSequence = animationTable[animationAct.."_attack"];

		if ( player:Crouching() ) then
			player:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, gestureSequence);
		else
			player:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, gestureSequence);
		end;
		
		return ACT_VM_PRIMARYATTACK;
	elseif (event == PLAYERANIMEVENT_RELOAD) then
		local gestureSequence = animationTable[animationAct.."_reload"];

		if ( player:Crouching() ) then
			player:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, gestureSequence);
		else
			player:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, gestureSequence);
		end;
		
		return ACT_INVALID;
	elseif event == PLAYERANIMEVENT_JUMP then
		player.m_bJumping = true;
		player.m_bFirstJumpFrame = true;
		player.m_flJumpStartTime = CurTime();
		
		player:AnimRestartMainSequence();
		
		return ACT_INVALID;
	elseif (event == PLAYERANIMEVENT_CANCEL_RELOAD) then
		player:AnimResetGestureSlot(GESTURE_SLOT_ATTACK_AND_RELOAD);
		
		return ACT_INVALID;
	end;

	return nil;
end;

if (SERVER) then
	NEXUS.Entities = {};
	NEXUS.TempPlayerData = {};
	NEXUS.HitGroupBonesCache = {
		{"ValveBiped.Bip01_R_UpperArm", HITGROUP_RIGHTARM},
		{"ValveBiped.Bip01_R_Forearm", HITGROUP_RIGHTARM},
		{"ValveBiped.Bip01_L_UpperArm", HITGROUP_LEFTARM},
		{"ValveBiped.Bip01_L_Forearm", HITGROUP_LEFTARM},
		{"ValveBiped.Bip01_R_Thigh", HITGROUP_RIGHTLEG},
		{"ValveBiped.Bip01_R_Calf", HITGROUP_RIGHTLEG},
		{"ValveBiped.Bip01_R_Foot", HITGROUP_RIGHTLEG},
		{"ValveBiped.Bip01_R_Hand", HITGROUP_RIGHTARM},
		{"ValveBiped.Bip01_L_Thigh", HITGROUP_LEFTLEG},
		{"ValveBiped.Bip01_L_Calf", HITGROUP_LEFTLEG},
		{"ValveBiped.Bip01_L_Foot", HITGROUP_LEFTLEG},
		{"ValveBiped.Bip01_L_Hand", HITGROUP_LEFTARM},
		{"ValveBiped.Bip01_Spine2", HITGROUP_CHEST},
		{"ValveBiped.Bip01_Spine1", HITGROUP_CHEST},
		{"ValveBiped.Bip01_Pelvis", HITGROUP_GEAR},
		{"ValveBiped.Bip01_Head1", HITGROUP_HEAD},
		{"ValveBiped.Bip01_Neck1", HITGROUP_HEAD}
	};
	NEXUS.MeleeTranslation = {
		[ACT_HL2MP_GESTURE_RANGE_ATTACK] = ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE2,
		[ACT_HL2MP_GESTURE_RELOAD] = ACT_HL2MP_GESTURE_RELOAD_MELEE2,
		[ACT_HL2MP_WALK_CROUCH] = ACT_HL2MP_WALK_CROUCH_MELEE2,
		[ACT_HL2MP_IDLE_CROUCH] = ACT_HL2MP_IDLE_CROUCH_MELEE2,
		[ACT_RANGE_ATTACK1] = ACT_RANGE_ATTACK1_MELEE2,
		[ACT_HL2MP_IDLE] = ACT_HL2MP_IDLE_MELEE2,
		[ACT_HL2MP_WALK] = ACT_HL2MP_WALK_MELEE2,
		[ACT_HL2MP_JUMP] = ACT_HL2MP_JUMP_MELEE2,
		[ACT_HL2MP_RUN] = ACT_HL2MP_RUN_MELEE2
	};
	
	-- A function to load the bans.
	function NEXUS:LoadBans()
		self.BanList = self:RestoreNexusData("bans");
		
		local unixTime = os.time();
		
		for k, v in pairs(self.BanList) do
			if (type(v) == "table") then
				if (v.unbanTime > 0 and unixTime >= v.unbanTime) then
					self:RemoveBan(k, true);
				elseif (!v.steamName) then
					self:RemoveBan(k, true);
					self:AddBan( k, math.max(v.unbanTime  - unixTime, 0) );
				end;
			elseif (v > 0 and unixTime >= v) then
				self:RemoveBan(k, true);
			elseif (v == 0) then
				self:RemoveBan(k, true);
				self:AddBan(k, 0);
			else
				self:RemoveBan(k, true);
				self:AddBan(k, v - unixTime);
			end;
		end;
		
		self:SaveNexusData("bans", self.BanList);
	end;
	
	-- A function to add a ban.
	function NEXUS:AddBan(identifier, duration, reason, Callback, saveless)
		local steamName = nil;
		local playerGet = nexus.player.Get(identifier);
		
		if (identifier) then
			identifier = string.upper(identifier);
		end;
		
		for k, v in ipairs( g_Player.GetAll() ) do
			if (v:SteamID() == identifier or v:IPAddress() == identifier
			or playerGet == v) then
				nexus.mount.Call("PlayerBanned", v, duration, reason);
				
				v:Kick(reason); steamName = v:SteamName();
			end;
		end;
		
		if (!reason) then
			reason = "Banned for an unspecified reason.";
		end;
		
		if (!steamName) then
			local playersTable = nexus.config.Get("mysql_players_table"):Get();
			local newIdentifier = tmysql.escape(identifier);
			
			if ( string.find(identifier, "STEAM") ) then
				tmysql.query("SELECT * FROM "..playersTable.." WHERE _SteamID = \""..newIdentifier.."\"", function(result)
					local steamName = identifier;
					
					if (result and type(result) == "table" and #result > 0) then
						steamName = result[1]._SteamName;
					end;
					
					if (duration == 0) then
						self.BanList[identifier] = {
							unbanTime = 0,
							steamName = steamName,
							duration = duration,
							reason = reason
						};
					else
						self.BanList[identifier] = {
							unbanTime = os.time() + duration,
							steamName = steamName,
							duration = duration,
							reason = reason
						};
					end;
					
					if (!saveless) then
						self:SaveNexusData("bans", self.BanList);
					end;
					
					if (Callback) then
						Callback(steamName, duration, reason);
					end;
				end, 1);
			elseif ( string.find(identifier, "%d+%.%d+%.%d+%.%d+") ) then
				tmysql.query("SELECT * FROM "..playersTable.." WHERE _IPAddress = \""..newIdentifier.."\"", function(result)
					local steamName = identifier;
					
					if (result and type(result) == "table" and #result > 0) then
						steamName = result[1]._SteamName;
					end;
					
					if (duration == 0) then
						self.BanList[identifier] = {
							unbanTime = 0,
							steamName = steamName,
							duration = duration,
							reason = reason
						};
					else
						self.BanList[identifier] = {
							unbanTime = os.time() + duration,
							steamName = steamName,
							duration = duration,
							reason = reason
						};
					end;
					
					if (!saveless) then
						self:SaveNexusData("bans", self.BanList);
					end;
					
					if (Callback) then
						Callback(steamName, duration, reason);
					end;
				end, 1);
			elseif (Callback) then
				Callback();
			end;
		else
			if (duration == 0) then
				self.BanList[identifier] = {
					unbanTime = 0,
					steamName = steamName,
					duration = duration,
					reason = reason
				};
			else
				self.BanList[identifier] = {
					unbanTime = os.time() + duration,
					steamName = steamName,
					duration = duration,
					reason = reason
				};
			end;
			
			if (!saveless) then
				self:SaveNexusData("bans", self.BanList);
			end;
			
			if (Callback) then
				Callback(steamName, duration, reason);
			end;
		end;
	end;
	
	-- A function to remove a ban.
	function NEXUS:RemoveBan(identifier, saveless)
		if ( self.BanList[identifier] ) then
			self.BanList[identifier] = nil;
			
			if (!saveless) then
				self:SaveNexusData("bans", self.BanList);
			end;
		end;
	end;
	
	-- A function to start a data stream.
	function NEXUS:StartDataStream(player, name, data)
		if (type(player) != "table") then
			if (!player) then
				player = g_Player.GetAll();
			else
				player = {player};
			end;
		end;
		
		local encodedData = glon.encode(data);
		local splitTable = self:SplitString(encodedData, 128);
		local players = RecipientFilter();
		
		for k, v in pairs(player) do
			if (type(v) == "Player") then
				players:AddPlayer(v);
			elseif (type(k) == "Player") then
				players:AddPlayer(k);
			end;
		end;
		
		if (#splitTable > 0) then
			umsg.Start("nx_dsStart", players);
				umsg.String(name);
				umsg.String( splitTable[1] );
				umsg.Short(#splitTable);
			umsg.End();
			
			if (#splitTable > 1) then
				for k, v in ipairs(splitTable) do
					if (k > 1) then
						umsg.Start("nx_dsData", players);
							umsg.String(v);
							umsg.Short(k);
						umsg.End();
					end;
				end;
			end;
		end;
	end;

	-- A function to convert a force.
	function NEXUS:ConvertForce(force, limit)
		local forceLength = force:Length();
		
		if (forceLength == 0) then
			return Vector(0, 0, 0);
		end;
		
		if (!limit) then
			limit = 800;
		end;
		
		if (forceLength > limit) then
			return force / (forceLength / limit);
		else
			return force;
		end;
	end;
	
	-- A function to restore nexus data.
	function NEXUS:RestoreNexusData(fileName, default)
		if ( self:NexusDataExists(fileName) ) then
			local data = g_File.Read("nexus/"..fileName..".txt");
			
			if (data) then
				local success, value = pcall(glon.decode, data);
				
				if (success and value != nil) then
					return value;
				else
					local success, value = pcall(Json.Decode, data);
					
					if (success and value != nil) then
						return value;
					end;
				end;
			end;
		end;
		
		if (default != nil) then
			return default;
		else
			return {};
		end;
	end;
	
	-- A function to save a player's attribute boosts.
	function NEXUS:SavePlayerAttributeBoosts(player, data)
		local attributeBoosts = player:GetAttributeBoosts();
		local curTime = CurTime();
		
		if ( data["attributeboosts"] ) then
			data["attributeboosts"] = nil;
		end;
		
		if (table.Count(attributeBoosts) > 0) then
			data["attributeboosts"] = {};
			
			for k, v in pairs(attributeBoosts) do
				data["attributeboosts"][k] = {};
				
				for k2, v2 in pairs(v) do
					if (v2.duration) then
						if (curTime < v2.endTime) then
							data["attributeboosts"][k][k2] = {
								duration = math.ceil(v2.endTime - curTime),
								amount = v2.amount
							};
						end;
					else
						data["attributeboosts"][k][k2] = {
							amount = v2.amount
						};
					end;
				end;
			end;
		end;
	end;
	
	-- A function to calculate a player's spawn time.
	function NEXUS:CalculateSpawnTime(player, inflictor, attacker, damageInfo)
		local info = {
			attacker = attacker,
			inflictor = inflictor,
			spawnTime = nexus.config.Get("spawn_time"):Get(),
			damageInfo = damageInfo
		};

		nexus.mount.Call("PlayerAdjustDeathInfo", player, info);

		if (info.spawnTime and info.spawnTime > 0) then
			nexus.player.SetAction(player, "spawn", info.spawnTime, 3);
		end;
	end;
	
	-- A function to create a decal.
	function NEXUS:CreateDecal(texture, position, temporary)
		local decal = ents.Create("infodecal");
		
		if (temporary) then
			decal:SetKeyValue("LowPriority", "true");
		end;
		
		decal:SetKeyValue("Texture", texture);
		decal:SetPos(position);
		decal:Spawn();
		decal:Fire("activate");
		
		return decal;
	end;
	
	-- A function to handle a player's weapon fire delay.
	function NEXUS:HandleWeaponFireDelay(player, raised, weapon, curTime)
		local delaySecondaryFire = nil;
		local delayPrimaryFire = nil;
		
		if ( !nexus.mount.Call("PlayerCanFireWeapon", player, raised, weapon, true) ) then
			delaySecondaryFire = curTime + 60;
		end;
		
		if ( !nexus.mount.Call("PlayerCanFireWeapon", player, raised, weapon) ) then
			delayPrimaryFire = curTime + 60;
		end;
		
		if (delaySecondaryFire == nil and weapon.secondaryFireDelayed) then
			weapon:SetNextSecondaryFire(weapon.secondaryFireDelayed);
			weapon.secondaryFireDelayed = nil;
		end;
		
		if (delayPrimaryFire == nil and weapon.primaryFireDelayed) then
			weapon:SetNextPrimaryFire(weapon.primaryFireDelayed);
			weapon.primaryFireDelayed = nil;
		end;
		
		if (delaySecondaryFire) then
			if (!weapon.secondaryFireDelayed) then
				weapon.secondaryFireDelayed = weapon:GetNextSecondaryFire();
			end;
			
			weapon:SetNextSecondaryFire(delaySecondaryFire);
		end;
		
		if (delayPrimaryFire) then
			if (!weapon.primaryFireDelayed) then
				weapon.primaryFireDelayed = weapon:GetNextPrimaryFire();
			end;
			
			weapon:SetNextPrimaryFire(delayPrimaryFire);
		end;
	end;
	
	-- A function to scale damage by hit group.
	function NEXUS:ScaleDamageByHitGroup(player, attacker, hitGroup, damageInfo, baseDamage)
		if ( !damageInfo:IsFallDamage() and !damageInfo:IsDamageType(DMG_CRUSH) ) then
			if (hitGroup == HITGROUP_HEAD) then
				damageInfo:ScaleDamage( nexus.config.Get("scale_head_dmg"):Get() );
			elseif (hitGroup == HITGROUP_CHEST or hitGroup == HITGROUP_GENERIC) then
				damageInfo:ScaleDamage( nexus.config.Get("scale_chest_dmg"):Get() );
			elseif (hitGroup == HITGROUP_LEFTARM or hitGroup == HITGROUP_RIGHTARM or hitGroup == HITGROUP_LEFTLEG
			or hitGroup == HITGROUP_RIGHTLEG or hitGroup == HITGROUP_GEAR) then
				damageInfo:ScaleDamage( nexus.config.Get("scale_limb_dmg"):Get() );
			end;
		end;
		
		nexus.mount.Call("PlayerScaleDamageByHitGroup", player, attacker, hitGroup, damageInfo, baseDamage);
	end;
	
	-- A function to calculate player damage.
	function NEXUS:CalculatePlayerDamage(player, hitGroup, damageInfo)
		local damageIsValid = damageInfo:IsBulletDamage() or damageInfo:IsDamageType(DMG_CLUB) or damageInfo:IsDamageType(DMG_SLASH);
		local hitGroupIsValid = true;
		
		if ( nexus.config.Get("armor_chest_only"):Get() ) then
			if (hitGroup != HITGROUP_CHEST and hitGroup != HITGROUP_GENERIC) then
				hitGroupIsValid = nil;
			end;
		end;
		
		if (player:Armor() > 0 and damageIsValid and hitGroupIsValid) then
			local armor = player:Armor() - damageInfo:GetDamage();
			
			if (armor < 0) then
				player:SetHealth( math.max(player:Health() - math.abs(armor), 1) );
				player:SetArmor( math.max(armor, 0) );
			else
				player:SetArmor( math.max(armor, 0) );
			end;
		else
			player:SetHealth( math.max(player:Health() - damageInfo:GetDamage(), 1) );
		end;
	end;
	
	-- A function to get a ragdoll's hit bone.
	function NEXUS:GetRagdollHitBone(entity, position, default, minimum)
		local closest = {};
		
		for k, v in ipairs(self.HitGroupBonesCache) do
			local bone = entity:LookupBone( v[1] );
			
			if (bone) then
				local bonePosition = entity:GetBonePosition(bone);
				
				if (bonePosition) then
					local distance = bonePosition:Distance(position);
					
					if ( !closest[1] or distance < closest[1] ) then
						if (!minimum or distance <= minimum) then
							closest[1] = distance;
							closest[2] = bone;
						end;
					end;
				end;
			end;
		end;
		
		if ( closest[2] ) then
			return closest[2];
		else
			return default;
		end;
	end;
	
	-- A function to get a ragdoll's hit group.
	function NEXUS:GetRagdollHitGroup(entity, position)
		local closest = {nil, HITGROUP_GENERIC};
		
		for k, v in ipairs(self.HitGroupBonesCache) do
			local bone = entity:LookupBone( v[1] );
			
			if (bone) then
				local bonePosition = entity:GetBonePosition(bone);
				
				if (position) then
					local distance = bonePosition:Distance(position);
					
					if ( !closest[1] or distance < closest[1] ) then
						closest[1] = distance;
						closest[2] = v[2];
					end;
				end;
			end;
		end;
		
		return closest[2];
	end;

	-- A function to create blood effects at a position.
	function NEXUS:CreateBloodEffects(position, decals, entity, force)
		if (!force) then
			force = VectorRand() * 80;
		end;
		
		local effectData = EffectData();
			effectData:SetOrigin(position);
			effectData:SetNormal(force);
			effectData:SetScale(0.5);
		util.Effect("nx_bloodsmoke", effectData, true, true);
		
		local effectData = EffectData();
			effectData:SetOrigin(position);
			effectData:SetEntity(entity);
			effectData:SetStart(position);
			effectData:SetScale(0.5);
		util.Effect("BloodImpact", effectData, true, true);
		
		for i = 1, decals do
			local trace = {};
				trace.start = position;
				trace.endpos = trace.start;
				trace.filter = entity;
			trace = util.TraceLine(trace);
			
			util.Decal("Blood", trace.HitPos + trace.HitNormal, trace.HitPos - trace.HitNormal);
		end;
	end;
	
	-- A function to do the entity take damage hook.
	function NEXUS:DoEntityTakeDamageHook(gamemode, arguments)
		if ( arguments[4] != arguments[5]:GetDamage() ) then
			arguments[4] = arguments[5]:GetDamage();
		end;
		
		local player = nexus.entity.GetPlayer( arguments[1] );
		
		if (player) then
			local ragdoll = player:GetRagdollEntity();
			
			if ( !hook.Call( "PlayerShouldTakeDamage", gamemode, player, arguments[3], arguments[2], arguments[5] ) or player:IsInGodMode() ) then
				arguments[5]:SetDamage(0);
				
				return true;
			end;
			
			if (ragdoll and arguments[1] != ragdoll) then
				hook.Call( "EntityTakeDamage", gamemode, ragdoll, arguments[2], arguments[3], arguments[4], arguments[5] );
				
				arguments[5]:SetDamage(0);
				
				return true;
			elseif (arguments[1] == ragdoll) then
				local physicsObject = arguments[1]:GetPhysicsObject();
				
				if ( IsValid(physicsObject) ) then
					local velocity = physicsObject:GetVelocity():Length();
					local curTime = CurTime();
					
					if ( arguments[5]:IsDamageType(DMG_CRUSH) ) then
						if (arguments[1].nextFallDamage and curTime < arguments[1].nextFallDamage) then
							arguments[5]:SetDamage(0);
							
							return true;
						end;
						
						arguments[4] = hook.Call("GetFallDamage", gamemode, player, velocity);
						arguments[1].nextFallDamage = curTime + 1;
						arguments[5]:SetDamage( arguments[4] )
					end;
				end;
			end;
		end;
	end;
	
	-- A function to perform the date and time think.
	function NEXUS:PerformDateTimeThink()
		local defaultDays = nexus.schema.GetOption("default_days");
		local minute = nexus.time.GetMinute();
		local month = nexus.date.GetMonth();
		local year = nexus.date.GetYear();
		local hour = nexus.time.GetHour();
		local day = nexus.time.GetDay();
		
		nexus.time.minute = nexus.time.GetMinute() + 1;
		
		if (nexus.time.GetMinute() == 60) then
			nexus.time.minute = 0;
			nexus.time.hour = nexus.time.GetHour() + 1;
			
			if (nexus.time.GetHour() == 24) then
				nexus.time.hour = 0;
				nexus.time.day = nexus.time.GetDay() + 1;
				nexus.date.day = nexus.date.GetDay() + 1;
				
				if (nexus.time.GetDay() == #defaultDays + 1) then
					nexus.time.day = 1;
				end;
				
				if (nexus.date.GetDay() == 31) then
					nexus.date.day = 1;
					nexus.date.month = nexus.date.GetMonth() + 1;
					
					if (nexus.date.GetMonth() == 13) then
						nexus.date.month = 1;
						nexus.date.year = nexus.date.GetYear() + 1;
					end;
				end;
			end;
		end;
		
		if (nexus.time.GetMinute() != minute) then
			nexus.mount.Call("TimePassed", TIME_MINUTE);
		end;
		
		if (nexus.time.GetHour() != hour) then
			nexus.mount.Call("TimePassed", TIME_HOUR);
		end;
		
		if (nexus.time.GetDay() != day) then
			nexus.mount.Call("TimePassed", TIME_DAY);
		end;
		
		if (nexus.date.GetMonth() != month) then
			nexus.mount.Call("TimePassed", TIME_MONTH);
		end;
		
		if (nexus.date.GetYear() != year) then
			nexus.mount.Call("TimePassed", TIME_YEAR);
		end;
		
		local month = self:ZeroNumberToDigits(nexus.date.GetMonth(), 2);
		local day = self:ZeroNumberToDigits(nexus.date.GetDay(), 2);
		
		self:SetSharedVar( "sh_Minute", nexus.time.GetMinute() );
		self:SetSharedVar( "sh_Hour", nexus.time.GetHour() );
		self:SetSharedVar( "sh_Date", day.."/"..month.."/"..nexus.date.GetYear() );
		self:SetSharedVar( "sh_Day", nexus.time.GetDay() );
	end;
	
	-- A function to create a ConVar.
	function NEXUS:CreateConVar(name, value, flags, Callback)
		local conVar = CreateConVar(name, value, flags or FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE);
		
		cvars.AddChangeCallback(name, function(conVar, previousValue, newValue)
			nexus.mount.Call("NexusConVarChanged", conVar, previousValue, newValue);
			
			if (Callback) then
				Callback(conVar, previousValue, newValue);
			end;
		end);
		
		return conVar;
	end;
	
	-- A function to check if the server is shutting down.
	function NEXUS:IsShuttingDown()
		return self.ShuttingDown;
	end;
	
	-- A function to distribute wages cash.
	function NEXUS:DistributeWagesCash()
		for k, v in ipairs( g_Player.GetAll() ) do
			if ( v:HasInitialized() and v:Alive() ) then
				local wages = v:GetWages();
				
				if ( nexus.mount.Call("PlayerCanEarnWagesCash", v, wages) ) then
					if (wages > 0) then
						if ( nexus.mount.Call("PlayerGiveWagesCash", v, wages, v:GetWagesName() ) ) then
							nexus.player.GiveCash( v, wages, v:GetWagesName() );
						end;
					end;
					
					nexus.mount.Call("PlayerEarnWagesCash", v, wages);
				end;
			end;
		end;
	end;
	
	-- A function to distribute generator cash.
	function NEXUS:DistributeGeneratorCash()
		local generatorEntities = {};
		
		for k, v in pairs(nexus.generator.stored) do
			table.Add( generatorEntities, ents.FindByClass(k) );
		end;
		
		for k, v in pairs(generatorEntities) do
			local generator = nexus.generator.Get( v:GetClass() );
			local player = v:GetPlayer();
			
			if ( IsValid(player) ) then
				if (v:GetPower() != 0) then
					local info = {
						generator = generator,
						entity = v,
						cash = generator.cash,
						name = "Generator"
					};
					
					v:SetSharedVar( "sh_Power", math.max(v:GetPower() - 1, 0) );
					
					nexus.mount.Call("PlayerAdjustEarnGeneratorInfo", player, info);
					
					if ( nexus.mount.Call("PlayerCanEarnGeneratorCash", player, info, info.cash) ) then
						if (v.OnEarned) then
							local result = v:OnEarned(player, info.cash);
							
							if (type(result) == "number") then
								info.cash = result;
							end;
							
							if (result != false) then
								if (result != true) then
									nexus.player.GiveCash(k, info.cash, info.name);
								end;
								
								nexus.mount.Call("PlayerEarnGeneratorCash", player, info, info.cash);
							end;
						else
							nexus.player.GiveCash(k, info.cash, info.name);
							
							nexus.mount.Call("PlayerEarnGeneratorCash", player, info, info.cash);
						end;
					end;
				end;
			end;
		end;
	end;
	
	-- A function to include the schema.
	function NEXUS:IncludeSchema()
		local schemaFolder = self:GetSchemaFolder();
		
		if (schemaFolder and type(schemaFolder) == "string") then
			nexus.config.Load(nil, true);
				nexus.mount.Include(schemaFolder.."/gamemode/schema", true);
			nexus.config.Load();
		end;
	end;
	
	-- A function to print a debug message.
	function NEXUS:PrintDebug(text, private)
		if (NX_CONVAR_DEBUG:GetInt() == 1) then
			local listeners = {};
			
			for k, v in ipairs( g_Player.GetAll() ) do
				if (v:HasInitialized() and v:GetInfoNum("nx_showlog", 0) == 1) then
					if ( nexus.player.IsAdmin(v) ) then
						listeners[#listeners + 1] = v;
					end;
				end;
			end;
			
			local info = {
				text = text,
				private = private,
				listeners = listeners
			};
			
			nexus.mount.Call("DebugAdjustInfo", info);
			
			for k, v in pairs(listeners) do
				if ( info.private or !v:IsListenServerHost() ) then
					v:PrintMessage(2, info.text);
				end;
			end;
			
			if (!info.private) then
				NEXUS:Log(info.text);
			end;
		end;
	end;
	
	-- A function to log an action.
	function NEXUS:Log(action)
		if (NX_CONVAR_LOG:GetInt() == 1) then
			ServerLog(action.."\n");
			
			print(action);
		end;
	end;
else
	NEXUS.SpawnIconMaterial = Material("vgui/spawnmenu/hover");
	NEXUS.ProgressBarColor = Color(50, 100, 150, 200);
	NEXUS.GradientTexture = surface.GetTextureID("gui/gradient_up");
	NEXUS.TargetPlayerText = { text = {} };
	NEXUS.BackgroundBlurs = {};
	NEXUS.RecognisedNames = {};
	NEXUS.PlayerInfoText = { text = {}, width = 0, subText = {} };
	NEXUS.NexusSplash = Material("nexus/nexusthree");
	NEXUS.ColorModify = {};
	NEXUS.Cinematics = {};
	NEXUS.ScreenBlur = Material("pp/blurscreen");
	NEXUS.MenuItems = { items = {} };
	NEXUS.AmmoCount = {};
	NEXUS.ESPInfo = {};
	NEXUS.Hints = {};
	NEXUS.Bars = { x = 0, y = 0, width = 0, height = 0, bars = {} };

	-- A function to get some a menu item.
	function NEXUS.MenuItems:Get(text)
		for k, v in pairs(self.items) do
			if (v.text == text) then
				return v;
			end;
		end;
	end;
	
	-- A function to add a menu item.
	function NEXUS.MenuItems:Add(text, panel, tip)
		self.items[#self.items + 1] = {text = text, panel = panel, tip = tip};
	end;

	-- A function to destroy a menu item.
	function NEXUS.MenuItems:Destroy(text)
		for k, v in pairs(self.items) do
			if (v.text == text) then
				table.remove(self.items, k);
			end;
		end;
	end;
	
	-- A function to add some target player text.
	function NEXUS.TargetPlayerText:Add(uniqueID, text, color)
		self.text[#self.text + 1] = {
			uniqueID = uniqueID,
			color = color,
			text = text
		};
	end;
	
	-- A function to get some target player text.
	function NEXUS.TargetPlayerText:Get(uniqueID)
		for k, v in pairs(self.text) do
			if (v.uniqueID == uniqueID) then
				return v;
			end;
		end;
	end;

	-- A function to destroy some target player text.
	function NEXUS.TargetPlayerText:Destroy(uniqueID)
		for k, v in pairs(self.text) do
			if (v.uniqueID == uniqueID) then
				table.remove(self.text, k);
			end;
		end;
	end;
	
	-- A function to get whether any player info text exists.
	function NEXUS.PlayerInfoText:DoesAnyExist()
		return (#self.text > 0 or #self.subText > 0);
	end;

	-- A function to add some player info text.
	function NEXUS.PlayerInfoText:Add(uniqueID, text)
		if (text) then
			self.text[#self.text + 1] = {
				uniqueID = uniqueID,
				text = text
			};
		end;
	end;
	
	-- A function to get some player info text.
	function NEXUS.PlayerInfoText:Get(uniqueID)
		
		for k, v in pairs(self.text) do
			if (v.uniqueID == uniqueID) then
				return v;
			end;
		end;
	end;

	-- A function to add some sub player info text.
	function NEXUS.PlayerInfoText:AddSub(uniqueID, text, priority)
		if (text) then
			self.subText[#self.subText + 1] = {
				priority = priority or 0,
				uniqueID = uniqueID,
				text = text
			};
		end;
	end;
	
	-- A function to get some sub player info text.
	function NEXUS.PlayerInfoText:GetSub(uniqueID)
		
		for k, v in pairs(self.subText) do
			if (v.uniqueID == uniqueID) then
				return v;
			end;
		end;
	end;

	-- A function to destroy some player info text.
	function NEXUS.PlayerInfoText:Destroy(uniqueID)
		
		for k, v in pairs(self.text) do
			if (v.uniqueID == uniqueID) then
				table.remove(self.text, k);
			end;
		end;
	end;

	-- A function to destroy some sub player info text.
	function NEXUS.PlayerInfoText:DestroySub(uniqueID)
		
		for k, v in pairs(self.subText) do
			if (v.uniqueID == uniqueID) then
				table.remove(self.subText, k);
			end;
		end;
	end;

	-- A function to get a top bar.
	function NEXUS.Bars:Get(uniqueID)
		for k, v in pairs(self.bars) do
			if (v.uniqueID == uniqueID) then return v; end;
		end;
	end;
	
	-- A function to add a top bar.
	function NEXUS.Bars:Add(uniqueID, color, text, value, maximum, flash, priority)
		self.bars[#self.bars + 1] = {
			uniqueID = uniqueID,
			priority = priority or 0,
			maximum = maximum,
			color = color,
			class = class,
			value = value,
			flash = flash,
			text = text,
		};
	end;

	-- A function to destroy a top bar.
	function NEXUS.Bars:Destroy(uniqueID)
		for k, v in pairs(self.bars) do
			if (v.uniqueID == uniqueID) then
				table.remove(self.bars, k);
			end;
		end;
	end;
	
	-- A function to create a client ConVar.
	function NEXUS:CreateClientConVar(name, value, save, userData, Callback)
		local conVar = CreateClientConVar(name, value, save, userData);
		
		cvars.AddChangeCallback(name, function(conVar, previousValue, newValue)
			nexus.mount.Call("NexusConVarChanged", conVar, previousValue, newValue);
			
			if (Callback) then
				Callback(conVar, previousValue, newValue);
			end;
		end);
		
		return conVar;
	end;
	
	-- A function to get the size of text.
	function NEXUS:GetTextSize(font, text)
		local defaultWidth, defaultHeight = self:GetCachedTextSize(font, "U");
		local height = defaultHeight;
		local width = 0;
		
		for i = 1, string.len(text) do
			local textWidth, textHeight = self:GetCachedTextSize( font, string.sub(text, i, i) );
			
			if (textWidth == 0) then
				textWidth = defaultWidth;
			end;
			
			if (textHeight > height) then
				height = textHeight;
			end;
			
			width = width + textWidth;
		end;
		
		return width, height;
	end;
	
	-- A function to calculate alpha from a distance.
	function NEXUS:CalculateAlphaFromDistance(maximum, start, finish)
		if (type(start) == "Player") then
			start = start:GetShootPos();
		elseif (type(start) == "Entity") then
			start = start:GetPos();
		end;
		
		if (type(finish) == "Player") then
			finish = finish:GetShootPos();
		elseif (type(finish) == "Entity") then
			finish = finish:GetPos();
		end;
		
		return math.Clamp(255 - ( (255 / maximum) * ( start:Distance(finish) ) ), 0, 255);
	end;
	
	-- A function to wrap text into a table.
	function NEXUS:WrapText(text, font, width, baseTable)
		if (width <= 0 or !text or text == "") then
			return;
		end;
		
		if (self:GetTextSize(font, text) > width) then
			local length = 0;
			local exploded = {};
			local seperator = "";
			
			if ( string.find(text, " ") ) then	
				exploded = NEXUS:ExplodeString(" ", text);
				seperator = " ";
			else
				exploded = string.ToTable(text);
				seperator = "";
			end;
			
			local i = 1;
			
			while (length < width) do
				if ( !exploded[i] ) then
					break;
				end;
				
				length = self:GetTextSize( font, table.concat(exploded, seperator, 1, i) );
				
				i = i + 1;
			end;
			
			baseTable[#baseTable + 1] = table.concat(exploded, seperator, 1, i - 2);
			
			text = table.concat(exploded, seperator, i - 1);
			
			if (self:GetTextSize(font, text) > width) then
				self:WrapText(text, font, width, baseTable);
			else
				baseTable[#baseTable + 1] = text;
			end;
		else
			baseTable[#baseTable + 1] = text;
		end;
	end;
	
	-- A function to handle an entity's menu.
	function NEXUS:HandleEntityMenu(entity)
		local options = {};
		local menu;
		
		nexus.mount.Call("GetEntityMenuOptions", entity, options);
		
		if (table.Count(options) > 0) then
			menu = NEXUS:AddMenuFromData(nil, options, function(menu, option, arguments)
				menu:AddOption(option, function()
					nexus.entity.ForceMenuOption(entity, option, arguments);
					
					timer.Simple(FrameTime() * 0.5, function()
						self:RemoveActiveToolTip();
					end);
				end);
				
				local panel = menu.Panels[#menu.Panels];
				
				if ( IsValid(panel) ) then
					if (type(arguments) == "table") then
						if (arguments.order) then
							menu.Panels[#menu.Panels] = nil;
							
							table.insert(menu.Panels, 1, panel);
						end;
						
						if (arguments.toolTip) then
							panel:SetToolTip(arguments.toolTip);
						end;
					end;
				end;
			end);
			
			return menu;
		end;
	end;
	
	-- A function to add a menu from data.
	function NEXUS:AddMenuFromData(menu, data, Callback)
		local options = {};
		local created;
		
		if (!menu) then
			created = true; menu = DermaMenu();
		end;
		
		for k, v in pairs(data) do
			options[#options + 1] = {k, v};
		end;
		
		table.sort(options, function(a, b)
			return a[1] < b[1];
		end);
		
		for k, v in pairs(options) do
			if (type( v[2] ) == "table" and !v[2].arguments) then
				if (table.Count( v[2] ) > 0) then
					self:AddMenuFromData(menu:AddSubMenu( v[1] ), v[2], Callback);
				end;
			elseif (type( v[2] ) == "function") then
				menu:AddOption( v[1], v[2] );
			elseif (Callback) then
				Callback( menu, v[1], v[2] );
			end;
		end;
		
		if (created) then
			if (#options > 0) then
				menu:Open();
			else
				menu:Remove();
			end;
			
			return menu;
		end;
	end;
	
	-- A function to adjust the width of text.
	function NEXUS:AdjustMaximumWidth(font, text, width, addition, extra)
		local textString = tostring( string.Replace(text, "&", "U") );
		local textWidth = self:GetCachedTextSize(font, textString) + (extra or 0);
		
		if (textWidth > width) then
			width = textWidth + (addition or 0);
		end;
		
		return width;
	end;
	
	-- A function to add a top hint.
	function NEXUS:AddTopHint(text, delay, color, noSound)
		local colorWhite = nexus.schema.GetColor("white");
		
		for k, v in ipairs(self.Hints) do
			if (v.text == text) then
				return;
			end;
		end;
		
		if (table.Count(self.Hints) == 10) then
			table.remove(self.Hints, 10);
		end;
		
		if (!noSound) then
			surface.PlaySound("buttons/button15.wav");
		end;
		
		table.insert( self.Hints, {
			targetAlpha = 255,
			alphaSpeed = 64,
			color = color or colorWhite,
			delay = delay,
			alpha = 0,
			text = text
		} );
	end;
	
	-- A function to calculate the top hints.
	function NEXUS:CalculateHints()
		local frameTime = FrameTime();
		local curTime = UnPredictedCurTime();
		
		for k, v in pairs(self.Hints) do
			if (!v.nextChangeTarget or curTime >= v.nextChangeTarget) then
				v.alpha = math.Approach(v.alpha, v.targetAlpha, v.alphaSpeed * frameTime);
				
				if (v.alpha == v.targetAlpha) then
					if (v.targetAlpha == 0) then
						table.remove(self.Hints, k);
					else
						v.nextChangeTarget = curTime + v.delay;
						v.targetAlpha = 0;
						v.alphaSpeed = 16;
					end;
				end;
			end;
		end;
	end;
	
	-- A function to draw the date and time.
	function NEXUS:DrawDateTime()
		local colorWhite = nexus.schema.GetColor("white");
		local info = {
			width = ScrW() * 0.1,
			x = 8,
			y = 8
		};
		
		if ( nexus.mount.Call("PlayerCanSeeDateTime") ) then
			local dateTimeFont = nexus.schema.GetFont("date_time_text");
			local dateString = nexus.date.GetString();
			local timeString = nexus.time.GetString();
			local dayName = nexus.time.GetDayName();
			local text = string.upper(dateString..". "..dayName..", "..timeString..".");
			
			self:OverrideMainFont(dateTimeFont);
				info.y = self:DrawInfo(text, info.x, info.y, colorWhite, 255, true);
			self:OverrideMainFont(false);
			
			local textWidth, textHeight = NEXUS:GetCachedTextSize(dateTimeFont, text);
			
			if (textWidth and textHeight) then
				info.width = textWidth;
			end;
		end;
		
		self:DrawBars(info);
			nexus.mount.Call("NexusDateTimeDrawn", info);
	end;

	-- A function to draw the top hints.
	function NEXUS:DrawHints()
		local x = ScrW();
		local y = 8;
		
		if ( nexus.mount.Call("PlayerCanSeeHints") ) then
			for k, v in pairs(self.Hints) do
				self:OverrideMainFont( nexus.schema.GetFont("hints_text") );
					y = self:DrawInfo(string.upper(v.text), x, y, v.color, v.alpha, true, function(x, y, width, height)
						return x - width - 8, y;
					end);
				self:OverrideMainFont(false);
			end;
		end;
	end;

	-- A function to draw the top bars.
	function NEXUS:DrawBars(info)
		local barTextFont = nexus.schema.GetFont("bar_text");
		
		self.Bars.width = info.width;
		self.Bars.height = 12;
		self.Bars.x = info.x;
		self.Bars.y = info.y;
		
		nexus.schema.SetFont( "bar_text", nexus.schema.GetFont("auto_bar_text") );
			if ( nexus.mount.Call("PlayerCanSeeBars") ) then
				for k, v in ipairs(self.Bars.bars) do
					self.Bars.y = self:DrawBar(self.Bars.x, self.Bars.y, self.Bars.width, self.Bars.height, v.color, v.text, v.value, v.maximum, v.flash) + (self.Bars.height + 2);
				end;
			end;
		nexus.schema.SetFont("bar_text", barTextFont);
		
		info.y = self.Bars.y;
	end;
	
	-- A function to get the ESP info.
	function NEXUS:GetESPInfo()
		return self.ESPInfo;
	end;
	
	-- A function to draw the admin ESP.
	function NEXUS:DrawAdminESP()
		local colorWhite = nexus.schema.GetColor("white");
		local curTime = UnPredictedCurTime();
		
		if (!self.NextGetESPInfo) then
			self.NextGetESPInfo = curTime + 1;
		end;
		
		if (curTime >= self.NextGetESPInfo) then
			self.NextGetESPInfo = curTime + 1;
			self.ESPInfo = {};
			
			nexus.mount.Call("GetAdminESPInfo", self.ESPInfo);
		end;
		
		for k, v in pairs(self.ESPInfo) do
			local position = v.position:ToScreen();
			
			if (position) then
				self:DrawSimpleText(v.text, position.x, position.y, v.color or colorWhite, 1, 1);
			end;
		end;
	end;

	-- A function to draw a bar with a value and a maximum.
	function NEXUS:DrawBar(x, y, width, height, color, text, value, maximum, flash, barInfo)
		local backgroundColor = nexus.schema.GetColor("background");
		local progressWidth = math.Clamp( ( (width - 2) / maximum ) * value, 0, width - 2 );
		local colorWhite = nexus.schema.GetColor("white");
		local newBarInfo = {
			progressWidth = progressWidth,
			drawBackground = true,
			drawGradient = true,
			drawProgress = true,
			cornerSize = 4,
			maximum = maximum,
			height = height,
			width = width,
			color = color,
			value = value,
			flash = flash,
			text = text,
			x = x,
			y = y
		};
		
		if (barInfo) then
			for k, v in pairs(newBarInfo) do
				if ( !barInfo[k] ) then
					barInfo[k] = v;
				end;
			end;
		else
			barInfo = newBarInfo;
		end;
		
		if ( !nexus.mount.Call("PreDrawBar", barInfo) ) then
			if (barInfo.drawBackground) then
				draw.RoundedBox(barInfo.cornerSize, barInfo.x, barInfo.y, barInfo.width, barInfo.height, backgroundColor);
			end;
			
			if (barInfo.drawProgress) then
				draw.RoundedBox(0, barInfo.x + 1, barInfo.y + 1, barInfo.progressWidth, barInfo.height - 2, barInfo.color);
			end;
			
			if (barInfo.flash) then
				local alpha = math.Clamp(math.abs(math.sin( UnPredictedCurTime() ) * 50), 0, 50);
				
				if (alpha > 0) then
					draw.RoundedBox( 0, barInfo.x + 2, barInfo.y + 2, barInfo.width - 4, barInfo.height - 4, Color(colorWhite.r, colorWhite.g, colorWhite.b, alpha) );
				end;
			end;
		end;
		
		if ( !nexus.mount.Call("PostDrawBar", barInfo) ) then
			if (barInfo.text and barInfo.text != "") then
				self:OverrideMainFont( nexus.schema.GetFont("bar_text") );
					self:DrawSimpleText(barInfo.text, barInfo.x + (barInfo.width / 2), barInfo.y + (barInfo.height / 2), Color(colorWhite.r, colorWhite.g, colorWhite.b, alpha), 1, 1);
				self:OverrideMainFont(false);
			end;
		end;
		
		if (barInfo.drawGradient) then
			surface.SetDrawColor(100, 100, 100, 100);
			surface.SetTexture(self.GradientTexture);
			surface.DrawTexturedRect(barInfo.x + 2, barInfo.y + 2, barInfo.width - 4, barInfo.height - 4);
		end;
		
		return barInfo.y;
	end;
	
	-- A function to set the recognise menu.
	function NEXUS:SetRecogniseMenu(menu)
		self.RecogniseMenu = menu;
	end;
	
	-- A function to get the recognise menu.
	function NEXUS:GetRecogniseMenu(menu)
		return self.RecogniseMenu;
	end;
	
	-- A function to override the main font.
	function NEXUS:OverrideMainFont(font)
		if (font) then
			if (!self.PreviousMainFont) then
				self.PreviousMainFont = nexus.schema.GetFont("main_text");
			end;
			
			nexus.schema.SetFont("main_text", font);
		elseif (self.PreviousMainFont) then
			nexus.schema.SetFont("main_text", self.PreviousMainFont)
		end;
	end;

	-- A function to get the screen's center.
	function NEXUS:GetScreenCenter()
		return ScrW() / 2, (ScrH() / 2) + 32;
	end;
	
	-- A function to draw some simple text.
	function NEXUS:DrawSimpleText(text, x, y, color, alignX, alignY, shadowless, shadowDepth)
		local mainTextFont = nexus.schema.GetFont("main_text");
		local realX = math.Round(x);
		local realY = math.Round(y);
		
		if (!shadowless) then
			local outlineColor = Color( 25, 25, 25, math.min(225, color.a) );
			local depth = shadowDepth or 1;
			
			draw.SimpleText(text, mainTextFont, realX + -depth, realY + -depth, outlineColor, alignX, alignY);
			draw.SimpleText(text, mainTextFont, realX + -depth, realY + depth, outlineColor, alignX, alignY);
			draw.SimpleText(text, mainTextFont, realX + depth, realY + -depth, outlineColor, alignX, alignY);
			draw.SimpleText(text, mainTextFont, realX + depth, realY + depth, outlineColor, alignX, alignY);
		end;
		
		local width, height = draw.SimpleText(text, mainTextFont, realX, realY, color, alignX, alignY);
		
		if (width and height) then
			if (height == 0) then
				height = draw.GetFontHeight(mainTextFont);
			end;
			
			return realY + height + 2;
		else
			return realY;
		end;
	end;
	
	-- A function to get the black fade alpha.
	function NEXUS:GetBlackFadeAlpha()
		return self.BlackFadeIn or self.BlackFadeOut or 0;
	end;
	
	-- A function to get whether the screen is faded black.
	function NEXUS:IsScreenFadedBlack()
		return (self.BlackFadeIn == 255);
	end;
	
	-- A function to get a cached text size.
	function NEXUS:GetCachedTextSize(font, text)
		if (!self.CachedTextSizes) then
			self.CachedTextSizes = {};
		end;
		
		if ( !self.CachedTextSizes[font] ) then
			self.CachedTextSizes[font] = {};
		end;
		
		if ( !self.CachedTextSizes[font][text] ) then
			surface.SetFont(font);
			
			self.CachedTextSizes[font][text] = { surface.GetTextSize(text) };
		end;
		
		return unpack( self.CachedTextSizes[font][text] );
	end;
	
	-- A function to draw information at a position.
	function NEXUS:DrawInfo(text, x, y, color, alpha, alignLeft, Callback, shadowDepth)
		local mainTextFont = nexus.schema.GetFont("main_text");
		local width, height = self:GetCachedTextSize(mainTextFont, text);
		
		if (width and height) then
			if (!alignLeft) then
				x = x - (width / 2);
			end;
			
			if (Callback) then
				x, y = Callback(x, y, width, height);
			end;
		
			return self:DrawSimpleText(text, x, y, Color(color.r, color.g, color.b, alpha or color.a), nil, nil, nil, shadowDepth);
		end;
	end;
	
	-- A function to get the player info box.
	function NEXUS:GetPlayerInfoBox()
		return self.PlayerInfoBox;
	end;

	-- A function to draw the local player's information.
	function NEXUS:DrawPlayerInfo()
		if ( nexus.mount.Call("PlayerCanSeePlayerInfo") ) then
			local backgroundColor = nexus.schema.GetColor("background");
			local subInformation = self.PlayerInfoText.subText;
			local information = self.PlayerInfoText.text;
			local colorWhite = nexus.schema.GetColor("white");
			local textWidth, textHeight = self:GetCachedTextSize(nexus.schema.GetFont("player_info_text"), "U");
			local width = self.PlayerInfoText.width;
			
			if (#information > 0 or #subInformation > 0) then
				local height = (textHeight * #information) + ( (textHeight + 4) * #subInformation );
				local scrW = ScrW();
				local scrH = ScrH();
				
				if (#information > 0) then
					height = height + 8;
				end;
				
				local y = scrH - height - (scrH * 0.05);
				local x = scrW * 0.05;
				
				local boxInfo = {
					subInformation = subInformation,
					drawBackground = true,
					drawGradient = true,
					information = information,
					textHeight = textHeight,
					cornerSize = 4,
					textWidth = textWidth,
					height = height,
					width = width,
					x = x,
					y = y
				};
				
				if ( !nexus.mount.Call("PreDrawPlayerInfo", boxInfo, information, subInformation) ) then
					self:OverrideMainFont( nexus.schema.GetFont("player_info_text") );
						for k, v in ipairs(subInformation) do
							x, y = self:DrawPlayerInfoSubBox(v.text, x, y, width, boxInfo);
						end;
						
						if (#information > 0) then
							if (boxInfo.drawBackground) then
								draw.RoundedBox(boxInfo.cornerSize, x, y, width, height - ( (textHeight + 4) * #subInformation ), backgroundColor);
							end;
						end;
						
						if (#information > 0) then
							x = x + 8
							y = y + 4;
						end;
							
						for k, v in ipairs(information) do
							self:DrawInfo(v.text, x, y - 1, colorWhite, 255, true);
							
							y = y + textHeight;
						end;
					self:OverrideMainFont(false);
				end;
				
				nexus.mount.Call("PostDrawPlayerInfo", boxInfo, information, subInformation);
				
				if (boxInfo.drawGradient) then
					surface.SetDrawColor(255, 255, 255, 5);
					surface.SetTexture(self.GradientTexture);
					surface.DrawTexturedRect(boxInfo.x + 2, boxInfo.y + 2, boxInfo.width - 4, boxInfo.height - 4);
				end;
				
				return boxInfo;
			end;
		end;
	end;
	
	-- A function to get the ragdoll eye angles.
	function NEXUS:GetRagdollEyeAngles()
		if (!self.RagdollEyeAngles) then
			self.RagdollEyeAngles = Angle(0, 0, 0);
		end;
		
		return self.RagdollEyeAngles;
	end;
	
	-- A function to draw a rounded gradient.
	function NEXUS:DrawRoundedGradient(cornerSize, x, y, width, height, color)
		local gradientAlpha = math.min(color.a, 100);
		
		draw.RoundedBox(cornerSize, x, y, width, height, color);
		
		if (x + 2 < x + width and y + 2 < y + height) then
			surface.SetDrawColor(gradientAlpha, gradientAlpha, gradientAlpha, gradientAlpha);
			surface.SetTexture(self.GradientTexture);
			surface.DrawTexturedRect(x + 2, y + 2, width - 4, height - 4);
		end;
	end;

	-- A function to draw a player information sub box.
	function NEXUS:DrawPlayerInfoSubBox(text, x, y, width, boxInfo)
		local backgroundColor = nexus.schema.GetColor("background");
		local colorWhite = nexus.schema.GetColor("white");
		
		if (!boxInfo or boxInfo.drawBackground) then
			draw.RoundedBox( 4, x, y, width, boxInfo.textHeight + 2, backgroundColor );
		end;
		
		self:DrawInfo(text, x + 8, y + 1, colorWhite, 255, true);
		
		if (boxInfo) then
			return x, y + boxInfo.textHeight + 4;
		else
			return x, y + 20;
		end;
	end;
	
	-- A function to create a colored spawn icon.
	function NEXUS:CreateColoredSpawnIcon(parent)
		local spawnIcon = vgui.Create("SpawnIcon", parent);
		
		-- A function to set the spawn icon's color.
		function spawnIcon.SetColor(spawnIcon, color)
			spawnIcon.Color = color;
		end;
		
		-- Called after the spawn icon has been hovered over.
		function spawnIcon.PaintOverHovered(spawnIcon)
			surface.SetDrawColor(255, 255, 255, 255);
			surface.SetMaterial(self.SpawnIconMaterial);
			
			spawnIcon:DrawTexturedRect();
		end;
		
		-- Called after the spawn icon's children are painted.
		function spawnIcon.PaintOver(spawnIcon)
			if (spawnIcon.Color) then
				self.SpawnIconMaterial:SetMaterialVector( "$color", Vector(spawnIcon.Color.r / 255, spawnIcon.Color.g / 255, spawnIcon.Color.b / 255) );
					surface.SetDrawColor(spawnIcon.Color.r, spawnIcon.Color.g, spawnIcon.Color.b, spawnIcon.Color.a);
					surface.SetMaterial(self.SpawnIconMaterial);
					
					spawnIcon:DrawTexturedRect();
				self.SpawnIconMaterial:SetMaterialVector( "$color", Vector(1, 1, 1) );
			end;
		end;
		
		return spawnIcon;
	end;

	-- A function to draw the armor bar.
	function NEXUS:DrawArmorBar()
		local armor = math.Clamp( g_LocalPlayer:Armor(), 0, g_LocalPlayer:GetMaxArmor() );
		
		if (armor > 0) then
			self.Bars:Add("ARMOR", Color(139, 174, 179, 255), "", armor, g_LocalPlayer:GetMaxArmor(), armor < 10, 1);
		end;
	end;

	-- A function to draw the health bar.
	function NEXUS:DrawHealthBar()
		local health = math.Clamp( g_LocalPlayer:Health(), 0, g_LocalPlayer:GetMaxHealth() );
		
		if (health > 0) then
			self.Bars:Add("HEALTH", Color(179, 46, 49, 255), "", health, g_LocalPlayer:GetMaxHealth(), health < 10, 2);
		end;
	end;
	
	-- A function to remove the active tool tip.
	function NEXUS:RemoveActiveToolTip()
		ChangeTooltip();
	end;
	
	-- A function to close active Derma menus.
	function NEXUS:CloseActiveDermaMenus()
		CloseDermaMenus();
	end;
	
	-- A function to register a background blur.
	function NEXUS:RegisterBackgroundBlur(panel, createTime)
		self.BackgroundBlurs[panel] = createTime;
	end;
	
	-- A function to remove a background blur.
	function NEXUS:RemoveBackgroundBlur(panel)
		self.BackgroundBlurs[panel] = nil;
	end;
	
	-- A function to draw the background blurs.
	function NEXUS:DrawBackgroundBlurs()
		local sysTime = SysTime();
		local scrH = ScrH();
		local scrW = ScrW();
		
		for k, v in pairs(self.BackgroundBlurs) do
			if ( type(k) == "string" or ( IsValid(k) and k:IsVisible() ) ) then
				local fraction = math.Clamp( (sysTime - v) / 1, 0, 1 );
				local x, y = 0, 0;
				
				surface.SetMaterial(self.ScreenBlur);
				surface.SetDrawColor(255, 255, 255, 255);
				
				for i = 0.33, 1, 0.33 do
					self.ScreenBlur:SetMaterialFloat("$blur", fraction * 5 * i);
					
					if (render) then
						render.UpdateScreenEffectTexture();
					end;
					
					surface.DrawTexturedRect(x, y, scrW, scrH);
				end;
				
				surface.SetDrawColor(10, 10, 10, 200 * fraction);
				surface.DrawRect(x, y, scrW, scrH);
			end;
		end;
	end;
	
	-- A function to add some cinematic text.
	function NEXUS:AddCinematicText(text, color, hangTime)
		local colorWhite = nexus.schema.GetColor("white");
		
		self.Cinematics[#self.Cinematics + 1] = {
			hangTime = hangTime or 3,
			color = color or colorWhite,
			text = text,
			add = 0
		};
	end;
	
	-- A function to add a notice.
	function NEXUS:AddNotify(text, class, length)
		if (class != NOTIFY_HINT or string.sub(text, 1, 6) != "#Hint_") then
			self.BaseClass:AddNotify(text, class, length);
		end;
	end;
	
	-- A function to get whether the local player is using the tool gun.
	function NEXUS:IsUsingTool()
		if (IsValid( g_LocalPlayer:GetActiveWeapon() )
		and g_LocalPlayer:GetActiveWeapon():GetClass() == "gmod_tool") then
			return true;
		else
			return false;
		end;
	end;

	-- A function to get whether the local player is using the camera.
	function NEXUS:IsUsingCamera()
		if (IsValid( g_LocalPlayer:GetActiveWeapon() )
		and g_LocalPlayer:GetActiveWeapon():GetClass() == "gmod_camera") then
			return true;
		else
			return false;
		end;
	end;
	
	-- A function to get the target ID data.
	function NEXUS:GetTargetIDData()
		return self.TargetIDData;
	end;
	
	-- A function to calculate the screen fading.
	function NEXUS:CalculateScreenFading()
		if ( nexus.mount.Call("ShouldPlayerScreenFadeBlack") ) then
			if (!self.BlackFadeIn) then
				if (self.BlackFadeOut) then
					self.BlackFadeIn = self.BlackFadeOut;
				else
					self.BlackFadeIn = 0;
				end;
			end;
			
			self.BlackFadeIn = math.Clamp(self.BlackFadeIn + (FrameTime() * 20), 0, 255);
			self.BlackFadeOut = nil;
			
			self:DrawRoundedGradient( 0, 0, 0, ScrW(), ScrH(), Color(0, 0, 0, self.BlackFadeIn) );
		else
			if (self.BlackFadeIn) then
				self.BlackFadeOut = self.BlackFadeIn;
			end;
			
			self.BlackFadeIn = nil;
			
			if (self.BlackFadeOut) then
				self.BlackFadeOut = math.Clamp(self.BlackFadeOut - (FrameTime() * 40), 0, 255);
				
				self:DrawRoundedGradient( 0, 0, 0, ScrW(), ScrH(), Color(0, 0, 0, self.BlackFadeOut) );
				
				if (self.BlackFadeOut == 0) then
					self.BlackFadeOut = nil;
				end;
			end;
		end;
	end;
	
	-- A function to draw a cinematic.
	function NEXUS:DrawCinematic(cinematic, curTime)
		local maxBarLength = ScrH() / 13;
		local font = nexus.schema.GetFont("cinematic_text");
		
		if (cinematic.goBack and curTime > cinematic.goBack) then
			cinematic.add = math.Clamp(cinematic.add - 2, 0, maxBarLength);
			
			if (cinematic.add == 0) then
				table.remove(self.Cinematics, 1);
				
				cinematic = nil;
			end;
		else
			cinematic.add = math.Clamp(cinematic.add + 1, 0, maxBarLength);
			
			if (cinematic.add == maxBarLength and !cinematic.goBack) then
				cinematic.goBack = curTime + cinematic.hangTime;
			end;
		end;
		
		if (cinematic) then
			draw.RoundedBox( 0, 0, -maxBarLength + cinematic.add, ScrW(), maxBarLength, Color(0, 0, 0, 255) );
			draw.RoundedBox( 0, 0, ScrH() - cinematic.add, ScrW(), maxBarLength, Color(0, 0, 0, 255) );
			
			draw.SimpleText(cinematic.text, font, ScrW() / 2, (ScrH() - cinematic.add) + (maxBarLength / 2), cinematic.color, 1, 1);
		end
	end;
	
	-- A function to draw the cinematic introduction.
	function NEXUS:DrawCinematicIntro(curTime)
		local cinematicInfo = nexus.mount.Call("GetCinematicIntroInfo");
		local colorWhite = nexus.schema.GetColor("white");
		
		if (cinematicInfo) then
			if (self.CinematicScreenAlpha and self.CinematicScreenTarget) then
				self.CinematicScreenAlpha = math.Approach(self.CinematicScreenAlpha, self.CinematicScreenTarget, 2);
				
				if (self.CinematicScreenAlpha == self.CinematicScreenTarget) then
					if (self.CinematicScreenTarget == 255) then
						if (!self.CinematicScreenGoBack) then
							self.CinematicScreenGoBack = curTime + 3;
						end;
					else
						self.CinematicScreenDone = true;
					end;
				end;
				
				if (self.CinematicScreenGoBack and curTime >= self.CinematicScreenGoBack) then
					self.CinematicScreenGoBack = nil;
					self.CinematicScreenTarget = 0;
				end;
				
				if (!self.CinematicScreenDone and cinematicInfo.credits) then
					local alpha = math.Clamp(self.CinematicScreenAlpha, 0, 255);
					
					self:OverrideMainFont( nexus.schema.GetFont("intro_text_tiny") );
						self:DrawSimpleText( cinematicInfo.credits, ScrW() / 8, ScrH() * 0.75, Color(colorWhite.r, colorWhite.g, colorWhite.b, alpha) );
					self:OverrideMainFont(false);
				end;
			else
				self.CinematicScreenAlpha = 0;
				self.CinematicScreenTarget = 255;
			end;
			
			self:DrawCinematicIntroBars();
		end;
	end;
	
	-- A function to draw the cinematic introduction bars.
	function NEXUS:DrawCinematicIntroBars()
		local maxBarLength = ScrH() / 13;
		
		if (self.CinematicScreenTarget and self.CinematicScreenTarget == 0) then
			if (self.CinematicScreenBarLength != 0) then
				self.CinematicScreenBarLength = math.Clamp( (maxBarLength / 255) * self.CinematicScreenAlpha, 0, maxBarLength );
			end;
		end;
		
		if (!self.CinematicScreenBarLength or self.CinematicScreenBarLength > 0) then
			local cinematicScreenBarLength = self.CinematicScreenBarLength or maxBarLength;
			
			draw.RoundedBox( 0, 0, 0, ScrW(), cinematicScreenBarLength, Color(0, 0, 0, 255) );
			draw.RoundedBox( 0, 0, ScrH() - cinematicScreenBarLength, ScrW(), maxBarLength, Color(0, 0, 0, 255) );
		end;
	end;
	
	-- A function to draw some door text.
	function NEXUS:DrawDoorText(entity, eyePos, eyeAngles, font, color)
		local r, g, b, a = entity:GetColor();
		
		if ( a > 0 and !entity:IsEffectActive(EF_NODRAW) ) then
			local doorData = nexus.entity.CalculateDoorTextPosition(entity);
			
			if (!doorData.hitWorld) then
				local frontY = -26;
				local backY = -26;
				local alpha = self:CalculateAlphaFromDistance( 256, eyePos, entity:GetPos() );
				
				if (alpha > 0) then
					local owner = nexus.entity.GetOwner(entity);
					local name = nexus.mount.Call("GetDoorInfo", entity, DOOR_INFO_NAME);
					local text = nexus.mount.Call("GetDoorInfo", entity, DOOR_INFO_TEXT);
					
					if (name or text) then
						local nameWidth = self:GetCachedTextSize(font, name or "");
						local textWidth = self:GetCachedTextSize(font, text or "");
						local longWidth = nameWidth;
						
						if (textWidth > longWidth) then
							longWidth = textWidth;
						end;
						
						local scale = math.abs( (doorData.width * 0.75) / longWidth );
						local nameScale = math.min(scale, 0.05);
						local textScale = math.min(scale, 0.03);
						
						if (name) then
							cam.Start3D2D(doorData.position, doorData.angles, nameScale);
								self:OverrideMainFont(font);
									frontY = self:DrawInfo(name, 0, frontY, color, alpha, nil, nil, 3);
								self:OverrideMainFont(false);
							cam.End3D2D();
							
							cam.Start3D2D(doorData.positionBack, doorData.anglesBack, nameScale);
								self:OverrideMainFont(font);
									backY = self:DrawInfo(name, 0, backY, color, alpha, nil, nil, 3);
								self:OverrideMainFont(false);
							cam.End3D2D();
						end;
						
						if (text) then
							cam.Start3D2D(doorData.position, doorData.angles, textScale);
								self:OverrideMainFont(font);
									frontY = self:DrawInfo(text, 0, frontY, color, alpha, nil, nil, 3);
								self:OverrideMainFont(false);
							cam.End3D2D();
							
							cam.Start3D2D(doorData.positionBack, doorData.anglesBack, textScale);
								self:OverrideMainFont(font);
									backY = self:DrawInfo(text, 0, backY, color, alpha, nil, nil, 3);
								self:OverrideMainFont(false);
							cam.End3D2D();
						end;
					end;
				end;
			end;
		end;
	end;
	
	-- A function to get whether the local player's character screen is open.
	function NEXUS:IsCharacterScreenOpen(isVisible)
		if ( nexus.character.IsPanelOpen() ) then
			local panel = nexus.character.GetPanel();
			
			if (isVisible) then
				if (panel) then
					return panel:IsVisible();
				end;
			else
				return panel != nil;
			end;
		end;
	end;
	
	-- A function to run a nexus command.
	function NEXUS:RunCommand(command, ...)
		RunConsoleCommand("nx", command, ...);
	end;
	
	-- A function to get whether the local player is choosing a character.
	function NEXUS:IsChoosingCharacter()
		if ( nexus.character.GetPanel() ) then
			return nexus.character.IsPanelOpen();
		else
			return true;
		end;
	end;
	
	-- A function to include the schema.
	function NEXUS:IncludeSchema()
		local schemaFolder = self:GetSchemaFolder();
		
		if (schemaFolder and type(schemaFolder) == "string") then
			nexus.mount.Include(schemaFolder.."/gamemode/schema", true);
		end;
	end;
	
	-- A function to start a data stream.
	function NEXUS:StartDataStream(name, data)
		local encodedData = glon.encode(data);
		local splitTable = self:SplitString(string.gsub(string.gsub(encodedData, "\\", "\\\\"), "\n", "\\n"), 128);
		
		if (#splitTable > 0) then
			RunConsoleCommand( "nx_dsStart", name, tostring(#splitTable) );
			
			for k, v in ipairs(splitTable) do
				RunConsoleCommand( "nx_dsData", v, tostring(k) );
			end;
		end;
	end;
end;

-- A function to explode a string by tags.
function NEXUS:ExplodeByTags(text, seperator, open, close, hide)
	local results = {};
	local current = "";
	local tag = nil;
	-- local i;
	
	for i = 1, string.len(text) do
		local character = string.sub(text, i, i);
		
		if (!tag) then
			if (character == open) then
				if (!hide) then
					current = current..character;
				end;
				
				tag = true;
			elseif (character == seperator) then
				results[#results + 1] = current; current = "";
			else
				current = current..character;
			end;
		else
			if (character == close) then
				if (!hide) then
					current = current..character;
				end;
				
				tag = nil;
			else
				current = current..character;
			end;
		end;
	end;
	
	if (current != "") then
		results[#results + 1] = current;
	end;
	
	return results;
end;

-- A function to modify a physical description.
function NEXUS:ModifyPhysDesc(description)
	if (string.len(description) <= 128) then
		if ( !string.find(string.sub(description, -2), "%p") ) then
			return description..".";
		else
			return description;
		end;
	else
		return string.sub(description, 1, 125).."...";
	end;
end;

-- A function to explode a string.
function NEXUS:ExplodeString(seperator, text)
	local exploded = {};
	
	for value in string.gmatch(text, "([^"..seperator.."]+)") do
		exploded[#exploded + 1] = value;
	end;
	
	return exploded;
end;

-- A function to create a new meta table.
function NEXUS:NewMetaTable(base)
	local object = {};
	
	setmetatable(object, base);
	
	base.__index = base;
	
	return object;
end;

-- A function to set whether a string should be in camel case.
function NEXUS:SetCamelCase(text, camelCase)
	if (camelCase) then
		return string.gsub(text, "^.", string.lower);
	else
		return string.gsub(text, "^.", string.upper);
	end;
end;

-- A function to include files in a directory.
function NEXUS:IncludeDirectory(directory)
	if (string.sub(directory, -1) != "/") then
		directory = directory.."/";
	end;
	
	for k, v in pairs( g_File.FindInLua(directory.."*.lua") ) do
		NEXUS:IncludePrefixed(directory..v);
	end;
end;

-- A function to include a prefixed g_File.
function NEXUS:IncludePrefixed(fileName)
	if (string.find(fileName, "sv_") and !SERVER) then
		return;
	end;
	
	if (string.find(fileName, "sh_") and SERVER) then
		AddCSLuaFile(fileName);
	elseif (string.find(fileName, "cl_") and SERVER) then
		AddCSLuaFile(fileName);
		
		return;
	end;
	
	include(fileName);
end;

-- A function to include mounts in a directory.
function NEXUS:IncludeMounts(directory)
	if (string.sub(directory, -1) != "/") then
		directory = directory.."/";
	end;
	
	for k, v in pairs( g_File.FindInLua(directory.."*") ) do
		if (v != ".." and v != ".") then
			if (CLIENT) then
				if ( g_File.IsDir("../lua_temp/"..directory..v) ) then
					nexus.mount.Include(directory..v);
				end;
			elseif ( g_File.IsDir("../gamemodes/"..directory..v) ) then
				nexus.mount.Include(directory..v);
			end;
		end;
	end;
	
	return true;
end;

-- A function to perform the timer think.
function NEXUS:CallTimerThink(curTime)
	for k, v in pairs(self.Timers) do
		if (!v.paused) then
			if (curTime >= v.nextCall) then
				local success, value = pcall( v.Callback, unpack(v.arguments) );
				
				if (!success) then
					ErrorNoHalt("nexus | '"..tostring(k).."' timer has failed: "..tostring(value)..".\n");
				end;
				
				v.nextCall = curTime + v.delay;
				v.calls = v.calls + 1;
				
				if (v.calls == v.repetitions) then
					self.Timers[k] = nil;
				end;
			end;
		end;
	end;
end;

-- A function to get whether a timer exists.
function NEXUS:TimerExists(name)
	return self.Timers[name];
end;

-- A function to start a timer.
function NEXUS:StartTimer(name)
	if (self.Timers[name] and self.Timers[name].paused) then
		self.Timers[name].nextCall = CurTime() + self.Timers[name].timeLeft;
		self.Timers[name].paused = nil;
	end;
end;

-- A function to pause a timer.
function NEXUS:PauseTimer(name)
	if (self.Timers[name] and !self.Timers[name].paused) then
		self.Timers[name].timeLeft = self.Timers[name].nextCall - CurTime();
		self.Timers[name].paused = true;
	end;
end;


-- A function to destroy a timer.
function NEXUS:DestroyTimer(name)
	self.Timers[name] = nil;
end;

-- A function to create a timer.
function NEXUS:CreateTimer(name, delay, repetitions, Callback, ...)
	self.Timers[name] = {
		calls = 0,
		delay = delay,
		nextCall = CurTime() + delay,
		Callback = Callback,
		arguments = {...},
		repetitions = repetitions
	};
end;

-- A function to get whether a player has access to an object.
function NEXUS:HasObjectAccess(player, object)
	local faction = nil;
	local access = nil;
	
	if (SERVER) then
		faction = player:QueryCharacter("faction");
	else
		faction = nexus.player.GetFaction(player);
	end;
	
	if (object.access) then
		if ( nexus.player.HasAnyFlags(player, object.access) ) then
			access = true;
		end;
	end;
	
	if (object.factions) then
		if ( table.HasValue(object.factions, faction) ) then
			access = true;
		end;
	end;
	
	if (object.classes) then
		local team = player:Team();
		local class = nexus.class.Get(team);
		
		if (class) then
			if ( table.HasValue(object.classes, team) or table.HasValue(object.classes, class.name) ) then
				access = true;
			end;
		end;
	end;
	
	if (!object.access and !object.factions and !object.classes) then
		access = true;
	end;
	
	if (object.blacklist) then
		local team = player:Team();
		local class = nexus.class.Get(team);
		
		if ( table.HasValue(object.blacklist, faction) ) then
			access = nil;
		elseif (class) then
			if ( table.HasValue(object.blacklist, team) or table.HasValue(object.blacklist, class.name) ) then
				access = nil;
			end;
		else
			for k, v in ipairs(object.blacklist) do
				if (type(v) == "string") then
					if ( nexus.player.HasAnyFlags(player, v) ) then
						access = nil;
						
						break;
					end;
				end;
			end;
		end;
	end;
	
	if (object.HasObjectAccess) then
		return object:HasObjectAccess(player);
	end;
	
	return access;
end;

-- A function to derive from Sandbox.
function NEXUS:DeriveFromSandbox()
	DeriveGamemode("Sandbox");

	if (!NEXUS.IsSandboxDerived) then
		GM = {Folder = "gamemodes/sandbox"};
		
		if (CLIENT) then
			include("sandbox/gamemode/cl_init.lua");
		else
			include("sandbox/gamemode/init.lua");
		end;
		
		local sandboxGamemode = GM;
		local baseGamemode = gamemode.Get("base");
		
		if (sandboxGamemode and baseGamemode) then
			table.Inherit(sandboxGamemode, baseGamemode);
			table.Inherit(NEXUS, sandboxGamemode);
			
			timer.Simple(FrameTime() * 0.5, function()
				NEXUS.BaseClass = sandboxGamemode;
			end);
			
			GM = NEXUS;
		end;
	end;
end;

-- A function to get the sorted commands.
function NEXUS:GetSortedCommands()
	local commands = {};
	local source = nexus.command.stored;
	
	for k, v in pairs(source) do
		commands[#commands + 1] = k;
	end;
	
	table.sort(commands, function(a, b)
		return a < b;
	end);
	
	return commands;
end;

-- A function to zero a number to an amount of digits.
function NEXUS:ZeroNumberToDigits(number, digits)
	return string.rep( "0", math.Clamp(digits - string.len( tostring(number) ), 0, digits) )..number;
end;

-- A function to get a short CRC from a value.
function NEXUS:GetShortCRC(value)
	return math.ceil(util.CRC(value) / 100000);
end;

-- A function to validate a table's keys.
function NEXUS:ValidateTableKeys(base)
	for i = 1, #base do
		if ( !base[i] ) then
			table.remove(base, i);
		end;
	end;
end;

-- A function to get the map's physics entities.
function NEXUS:GetPhysicsEntities()
	local entities = {};
	
	for k, v in ipairs( ents.FindByClass("prop_physics_multiplayer") ) do
		if ( IsValid(v) ) then
			entities[#entities + 1] = v;
		end;
	end;
	
	for k, v in ipairs( ents.FindByClass("prop_physics") ) do
		if ( IsValid(v) ) then
			entities[#entities + 1] = v;
		end;
	end;
	
	return entities;
end;

-- A function to create a multicall table (by Deco Da Man).
function NEXUS:CreateMulticallTable(base, object)
	local metaTable = getmetatable(base) or {};
	
	-- Called when an index is needed.
	function metaTable.__index(base, key)
		return function(base, ...)
			for k, v in pairs(base) do
				object[key](v, ...);
			end;
		end
	end
	
	setmetatable(base, metaTable);
	
	return base;
end;

-- A function to check if the shared variables have initialized.
function NEXUS:SharedVarsHaveInitialized()
	local worldEntity = GetWorldEntity();
	
	if ( worldEntity and worldEntity.IsWorld and worldEntity:IsWorld() ) then
		return true;
	end;
end;

-- A function to convert a user message class.
function NEXUS:ConvertUserMessageClass(class)
	local convertTable = {
		[NWTYPE_STRING] = "String",
		[NWTYPE_ENTITY] = "Entity",
		[NWTYPE_VECTOR] = "Vector",
		[NWTYPE_NUMBER] = "Long",
		[NWTYPE_ANGLE] = "Angle",
		[NWTYPE_FLOAT] = "Float",
		[NWTYPE_BOOL] = "Bool"
	};
	
	return convertTable[class];
end;

-- A function to get a default networked value.
function NEXUS:GetDefaultNetworkedValue(class)
	local convertTable = {
		[NWTYPE_STRING] = "",
		[NWTYPE_ENTITY] = NULL,
		[NWTYPE_VECTOR] = Vector(0, 0, 0),
		[NWTYPE_NUMBER] = 0,
		[NWTYPE_ANGLE] = Angle(0, 0, 0),
		[NWTYPE_FLOAT] = 0.0,
		[NWTYPE_BOOL] = false
	};
	
	return convertTable[class];
end;

-- A function to convert a networked class.
function NEXUS:ConvertNetworkedClass(class)
	local convertTable = {
		[NWTYPE_STRING] = "String",
		[NWTYPE_ENTITY] = "Entity",
		[NWTYPE_VECTOR] = "Vector",
		[NWTYPE_NUMBER] = "Int",
		[NWTYPE_ANGLE] = "Angle",
		[NWTYPE_FLOAT] = "Float",
		[NWTYPE_BOOL] = "Bool"
	};
	
	return convertTable[class];
end;

-- A function to get the default class value.
function NEXUS:GetDefaultClassValue(class)
	local convertTable = {
		["String"] = "",
		["Entity"] = NULL,
		["Vector"] = Vector(0, 0, 0),
		["Int"] = 0,
		["Angle"] = Angle(0, 0, 0),
		["Float"] = 0.0,
		["Bool"] = false
	};
	
	return convertTable[class];
end;

-- A function to set a shared variable.
function NEXUS:SetSharedVar(key, value)
	local entity = GetWorldEntity();
	
	if ( entity.sharedVars and entity.sharedVars[key] ) then
		local class = self:ConvertNetworkedClass( entity.sharedVars[key] );
		
		if (class) then
			if (value == nil) then
				value = NEXUS:GetDefaultClassValue(class);
			end;
			
			entity["SetNetworked"..class](entity, key, value);
		else
			entity:SetNetworkedVar(key, value);
		end;
	else
		entity:SetNetworkedVar(key, value);
	end;
end;

-- A function to get a shared variable.
function NEXUS:GetSharedVar(key)
	local entity = GetWorldEntity();
	
	if ( entity.sharedVars and entity.sharedVars[key] ) then
		local class = self:ConvertNetworkedClass( entity.sharedVars[key] );
		
		if (class) then
			return entity["GetNetworked"..class](entity, key);
		else
			return entity:GetNetworkedVar(key);
		end;
	else
		return entity:GetNetworkedVar(key);
	end;
end;

-- A function to register a global shared variable.
function NEXUS:RegisterGlobalSharedVar(name, class)
	self.GlobalSharedVars[#self.GlobalSharedVars + 1] = {name, class};
end;

-- A function to create fake damage info.
function NEXUS:FakeDamageInfo(damage, inflictor, attacker, position, damageType, damageForce)
	local damageInfo = DamageInfo();
	local realDamage = math.ceil( math.max(damage, 0) );
	
	damageInfo:SetDamagePosition(position);
	damageInfo:SetDamageForce(Vector() * damageForce);
	damageInfo:SetDamageType(damageType);
	damageInfo:SetInflictor(inflictor);
	damageInfo:SetAttacker(attacker);
	damageInfo:SetDamage(realDamage);
	
	return damageInfo;
end;

-- A function to unpack a color.
function NEXUS:UnpackColor(color)
	return color.r, color.g, color.b, color.a;
end;

-- A function to parse data in text.
function NEXUS:ParseData(text)
	local classes = {"%^", "%!"};
	
	for k, v in ipairs(classes) do
		for key in string.gmatch(text, v.."(.-)"..v) do
			local lower = false;
			local amount;
			
			if (string.sub(key, 1, 1) == "(" and string.sub(key, -1) == ")") then
				lower = true;
				amount = tonumber( string.sub(key, 2, -2) );
			else
				amount = tonumber(key);
			end;
			
			if (amount) then
				text = string.gsub( text, v..string.gsub(key, "([%(%)])", "%%%1")..v, tostring( FORMAT_CASH(amount, k == 2, lower) ) );
			end;
		end;
	end;
	
	for k in string.gmatch(text, "%*(.-)%*") do
		k = string.gsub(k, "[%(%)]", "");
		
		if (k != "") then
			text = string.gsub( text, "%*%("..k.."%)%*", tostring( nexus.schema.GetOption(k, true) ) );
			text = string.gsub( text, "%*"..k.."%*", tostring( nexus.schema.GetOption(k) ) );
		end;
	end;
	
	return nexus.config.Parse(text);
end;