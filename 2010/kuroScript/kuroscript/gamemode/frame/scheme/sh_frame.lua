--[[
Name: "sh_frame.lua".
Product: "kuroScript".
--]]

kuroScript.frame.Timers = {};

-- Check if a statement is true.
if (SERVER) then
	kuroScript.frame.Entities = {};
	kuroScript.frame.TempPlayerData = {};
	kuroScript.frame.HitGroupBonesCache = {
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
	kuroScript.frame.MeleeTranslation = {
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
	function kuroScript.frame:LoadBans()
		self.BanList = self:RestoreKuroScriptData("bans");
		
		-- Set some information.
		local unixTime = os.time();
		local k, v;
		
		-- Loop through each value in a table.
		for k, v in pairs(self.BanList) do
			if (v > 0 and unixTime >= v) then
				self:RemoveBan(k, true);
			end;
		end;
		
		-- Save some kuroScript data.
		self:SaveKuroScriptData("bans", self.BanList);
	end;
	
	-- A function to add a ban.
	function kuroScript.frame:AddBan(identifier, duration, reason)
		local k, v;
		
		-- Loop through each value in a table.
		for k, v in ipairs( g_Player.GetAll() ) do
			if (v:SteamID() == identifier or v:IPAddress() == identifier) then
				hook.Call("PlayerBanned", self, v, duration, reason);
				
				-- Kick the player.
				v:Kick(reason or "N/A");
				
				-- Set some information.
				v._Kicked = true;
			end;
		end;
		
		-- Check if a statement is true.
		if (duration == 0) then
			self.BanList[identifier] = 0;
		else
			self.BanList[identifier] = os.time() + duration;
		end;
		
		-- Save some kuroScript data.
		self:SaveKuroScriptData("bans", self.BanList);
	end;
	
	-- A function to remove a ban.
	function kuroScript.frame:RemoveBan(identifier, saveless)
		if ( self.BanList[identifier] ) then
			self.BanList[identifier] = nil;
			
			-- Check if a statement is true.
			if (!saveless) then
				self:SaveKuroScriptData("bans", self.BanList);
			end;
		end;
	end;
	
	-- A function to save game data.
	function kuroScript.frame:SaveGameData(file, data)
		g_File.Write( "kuroscript/games/"..GAME_FOLDER.."/"..file..".txt", glon.encode(data) );
	end;
	
	-- A function to delete game data.
	function kuroScript.frame:DeleteGameData(file)
		g_File.Delete("kuroscript/games/"..GAME_FOLDER.."/"..file..".txt");
	end;

	-- A function to check if game data exists.
	function kuroScript.frame:GameDataExists(file)
		return g_File.Exists("kuroscript/games/"..GAME_FOLDER.."/"..file..".txt");
	end;

	-- A function to restore game data.
	function kuroScript.frame:RestoreGameData(file, default)
		if ( self:GameDataExists(file) ) then
			local data = g_File.Read("kuroscript/games/"..GAME_FOLDER.."/"..file..".txt");
			
			-- Check if a statement is true.
			if (data) then
				local success, value = pcall(glon.decode, data);
				
				-- Check if a statement is true.
				if (success and value != nil) then
					return value;
				else
					local success, value = pcall(Json.Decode, data);
					
					-- Check if a statement is true.
					if (success and value != nil) then
						return value;
					end;
				end;
			end;
		end;
		
		-- Check if a statement is true.
		if (default != nil) then
			return default;
		else
			return {};
		end;
	end;
	
	-- A function to save kuroScript data.
	function kuroScript.frame:SaveKuroScriptData(file, data)
		g_File.Write( "kuroscript/"..file..".txt", glon.encode(data) );
	end;

	-- A function to check if kuroScript data exists.
	function kuroScript.frame:KuroScriptDataExists(file)
		return g_File.Exists("kuroscript/"..file..".txt");
	end;
	
	-- A function to delete kuroScript data.
	function kuroScript.frame:DeleteKuroScriptData(file)
		g_File.Delete("kuroscript/"..file..".txt");
	end;

	-- A function to restore kuroScript data.
	function kuroScript.frame:RestoreKuroScriptData(file, default)
		if ( self:KuroScriptDataExists(file) ) then
			local data = g_File.Read("kuroscript/"..file..".txt");
			
			-- Check if a statement is true.
			if (data) then
				local success, value = pcall(glon.decode, data);
				
				-- Check if a statement is true.
				if (success and value != nil) then
					return value;
				else
					local success, value = pcall(Json.Decode, data);
					
					-- Check if a statement is true.
					if (success and value != nil) then
						return value;
					end;
				end;
			end;
		end;
		
		-- Check if a statement is true.
		if (default != nil) then
			return default;
		else
			return {};
		end;
	end;
	
	-- A function to calculate a player's spawn time.
	function kuroScript.frame:CalculateSpawnTime(player, inflictor, attacker, damageInfo)
		local info = {
			attacker = attacker,
			inflictor = inflictor,
			spawnTime = kuroScript.config.Get("spawn_time"):Get(),
			damageInfo = damageInfo
		};

		-- Call a gamemode hook.
		hook.Call("PlayerAdjustDeathInfo", self, player, info);

		-- Check if a statement is true.
		if (info.spawnTime and info.spawnTime > 0) then
			kuroScript.player.SetAction(player, "spawn", info.spawnTime, 3);
		end;
	end;
	
	-- A function to create a decal.
	function kuroScript.frame:CreateDecal(texture, position, temporary)
		local decal = ents.Create("infodecal");
		
		-- Check if a statement is true.
		if (temporary) then
			decal:SetKeyValue("LowPriority", "true");
		end;
		
		-- Set some information.
		decal:SetKeyValue("Texture", texture);
		decal:SetPos(position);
		decal:Spawn();
		decal:Fire("activate");
		
		-- Return the decal.
		return decal;
	end;
	
	-- A function to handle a player's weapon fire delay.
	function kuroScript.frame:HandleWeaponFireDelay(player, raised, weapon, curTime, weaponWasRaised)
		local delaySecondaryFire = nil;
		local delayPrimaryFire = nil;
		local k, v;
		
		-- Check if a statement is true.
		if ( kuroScript.config.Get("raised_weapon_system"):Get() ) then
			if ( !raised or (raised and !weaponWasRaised) ) then
				if ( raised or !hook.Call("PlayerCanUseLoweredWeapon", self, player, weapon, true) ) then
					delaySecondaryFire = 1;
				end;
				
				-- Check if a statement is true.
				if ( raised or !hook.Call("PlayerCanUseLoweredWeapon", self, player, weapon) ) then
					delayPrimaryFire = 1;
				end;
			end;
		elseif (weaponWasRaised) then
			delaySecondaryFire = 1;
			delayPrimaryFire = 1;
		end;
		
		-- Check if a statement is true.
		if (delaySecondaryFire) then
			if (raised) then
				delaySecondaryFire = 0;
			end;
			
			-- Set some information.
			weapon:SetNextSecondaryFire(curTime + delaySecondaryFire);
		end;
		
		-- Check if a statement is true.
		if (delayPrimaryFire) then
			if (raised) then
				delayPrimaryFire = 0;
			end;
			
			-- Set some information.
			weapon:SetNextPrimaryFire(curTime + delayPrimaryFire);
		end;
	end;
	
	-- A function to scale damage by hit group.
	function kuroScript.frame:ScaleDamageByHitGroup(player, attacker, hitGroup, damageInfo, baseDamage)
		if (hitGroup == HITGROUP_HEAD) then
			damageInfo:ScaleDamage( kuroScript.config.Get("scale_head_dmg"):Get() );
		elseif (hitGroup == HITGROUP_CHEST or hitGroup == HITGROUP_GENERIC) then
			damageInfo:ScaleDamage( kuroScript.config.Get("scale_chest_dmg"):Get() );
		elseif (hitGroup == HITGROUP_LEFTARM or hitGroup == HITGROUP_RIGHTARM or hitGroup == HITGROUP_LEFTLEG
		or hitGroup == HITGROUP_RIGHTLEG or hitGroup == HITGROUP_GEAR) then
			damageInfo:ScaleDamage( kuroScript.config.Get("scale_limb_dmg"):Get() );
		end;
		
		-- Call a gamemode hook.
		hook.Call("PlayerScaleDamageByHitGroup", self, player, attacker, hitGroup, damageInfo, baseDamage);
	end;
	
	-- A function to calculate player damage.
	function kuroScript.frame:CalculatePlayerDamage(player, hitGroup, damageInfo)
		local damageIsValid = damageInfo:IsBulletDamage() or damageInfo:IsDamageType(DMG_CLUB) or damageInfo:IsDamageType(DMG_SLASH);
		
		-- Check if a statement is true.
		if (player:Armor() > 0 and damageIsValid) then
			local armor = player:Armor() - damageInfo:GetDamage();
			
			-- Check if a statement is true.
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
	function kuroScript.frame:GetRagdollHitBone(entity, position)
		local closest = {};
		local k, v;
		
		-- Loop through each value in a table.
		for k, v in ipairs(self.HitGroupBonesCache) do
			local bone = entity:LookupBone( v[1] );
			
			-- Check if a statement is true.
			if (bone) then
				local bonePosition = entity:GetBonePosition(bone);
				
				-- Check if a statement is true.
				if (bonePosition) then
					local distance = bonePosition:Distance(position);
					
					-- Check if a statement is true.
					if ( !closest[1] or distance < closest[1] ) then
						closest[1] = distance;
						closest[2] = bone;
					end;
				end;
			end;
		end;
		
		-- Return the closest bone.
		return closest[2];
	end;
	
	-- A function to get a ragdoll's hit group.
	function kuroScript.frame:GetRagdollHitGroup(entity, position)
		local closest = {nil, HITGROUP_GENERIC};
		local k, v;
		
		-- Loop through each value in a table.
		for k, v in ipairs(self.HitGroupBonesCache) do
			local bone = entity:LookupBone( v[1] );
			
			-- Check if a statement is true.
			if (bone) then
				local bonePosition = entity:GetBonePosition(bone);
				
				-- Check if a statement is true.
				if (position) then
					local distance = bonePosition:Distance(position);
					
					-- Check if a statement is true.
					if ( !closest[1] or distance < closest[1] ) then
						closest[1] = distance;
						closest[2] = v[2];
					end;
				end;
			end;
		end;
		
		-- Return the closest hit group.
		return closest[2];
	end;

	-- A function to create blood effects at a position.
	function kuroScript.frame:CreateBloodEffects(position, decals, entity, force)
		local effectData = EffectData();
			effectData:SetOrigin(position);
			effectData:SetScale(24);
		util.Effect("BloodImpact", effectData, true, true);
		
		-- Loop through a range of numbers.
		for i = 1, decals do
			local trace = {};
			
			-- Set some information.
			trace.start = position;
			trace.endpos = trace.start + ( (force or VectorRand() * 64) + (VectorRand() * 16) * 64 );
			trace.filter = entity;
			
			-- Set some information.
			trace = util.TraceLine(trace);
			
			-- Draw a decak,
			util.Decal("Blood", trace.HitPos + trace.HitNormal, trace.HitPos - trace.HitNormal);
		end;
		
		-- Check if a statement is true.
		if ( ValidEntity(entity) ) then
			local trace = {};
			
			-- Set some information.
			trace.start = position;
			trace.endpos = position;
			
			-- Set some information.
			trace = util.TraceLine(trace);
			
			-- Draw a blood decal at the hit position.
			util.Decal("Blood", trace.HitPos + trace.HitNormal, trace.HitPos - trace.HitNormal);
		end;
	end;
	
	-- A function to do the entity take damage hook.
	function kuroScript.frame:DoEntityTakeDamageHook(gamemode, arguments)
		if ( arguments[5]:IsDamageType(DMG_CRUSH) ) then
			arguments[5]:ScaleDamage(0.5);
		end;
		
		-- Check if a statement is true.
		if ( arguments[4] != arguments[5]:GetDamage() ) then
			arguments[4] = arguments[5]:GetDamage();
		end;
		
		-- Set some information.
		local player = kuroScript.entity.GetPlayer( arguments[1] );
		
		-- Check if a statement is true.
		if (player) then
			local ragdoll = player:GetRagdollEntity();
			
			-- Check if a statement is true.
			if (!hook.Call( "PlayerShouldTakeDamage", gamemode, player, arguments[3], arguments[2], arguments[5] ) or player._GodMode) then
				arguments[5]:SetDamage(0);
				
				-- Return to break the function.
				return true;
			end;
			
			-- Check if a statement is true.
			if (ragdoll and arguments[1] != ragdoll) then
				hook.Call( "EntityTakeDamage", gamemode, ragdoll, arguments[2], arguments[3], arguments[4], arguments[5] );
				
				-- Set some information.
				arguments[5]:SetDamage(0);
				
				-- Return to break the function.
				return true;
			elseif (arguments[1] == ragdoll) then
				local physicsObject = arguments[1]:GetPhysicsObject();
				
				-- Check if a statement is true.
				if ( ValidEntity(physicsObject) ) then
					local velocity = physicsObject:GetVelocity():Length();
					
					-- Check if a statement is true.
					if ( arguments[5]:IsDamageType(DMG_CRUSH) ) then
						arguments[4] = hook.Call("GetFallDamage", gamemode, player, velocity);
						arguments[5]:SetDamage( arguments[4] )
					end;
				end;
			end;
		end;
	end;
	
	-- A function to perform the date and time think.
	function kuroScript.frame:PerformDateTimeThink()
		local minute = kuroScript.time.minute;
		local month = kuroScript.date.month;
		local year = kuroScript.date.year;
		local hour = kuroScript.time.hour;
		local day = kuroScript.time.day;
		
		-- Set some information.
		kuroScript.time.minute = kuroScript.time.minute + 1;
		
		-- Check if a statement is true.
		if (kuroScript.time.minute == 60) then
			kuroScript.time.minute = 0;
			kuroScript.time.hour = kuroScript.time.hour + 1;
			
			-- Check if a statement is true.
			if (kuroScript.time.hour == 24) then
				kuroScript.time.hour = 0;
				kuroScript.time.day = kuroScript.time.day + 1;
				kuroScript.date.day = kuroScript.date.day + 1;
				
				-- Check if a statement is true.
				if (kuroScript.time.day == #DEFAULT_DAYS + 1) then
					kuroScript.time.day = 1;
				end;
				
				-- Check if a statement is true.
				if (kuroScript.date.day == 31) then
					kuroScript.date.day = 1;
					kuroScript.date.month = kuroScript.date.month + 1;
					
					-- Check if a statement is true.
					if (kuroScript.date.month == 13) then
						kuroScript.date.month = 1;
						kuroScript.date.year = kuroScript.date.year + 1;
					end;
				end;
			end;
		end;
		
		-- Check if a statement is true.
		if (kuroScript.time.minute != minute) then hook.Call("TimePassed", self, TIME_MINUTE); end;
		if (kuroScript.time.hour != hour) then hook.Call("TimePassed", self, TIME_HOUR); end;
		if (kuroScript.time.day != day) then hook.Call("TimePassed", self, TIME_DAY); end;
		
		-- Check if a statement is true.
		if (kuroScript.date.month != month) then hook.Call("TimePassed", self, TIME_MONTH); end;
		if (kuroScript.date.year != year) then hook.Call("TimePassed", self, TIME_YEAR); end;
		
		-- Set some information.
		local month = self:ZeroNumberToDigits(kuroScript.date.month, 2);
		local day = self:ZeroNumberToDigits(kuroScript.date.day, 2);
		
		-- Set some global information.
		self:SetSharedVar("ks_Date", day.."/"..month.."/"..kuroScript.date.year);
		self:SetSharedVar("ks_Minute", kuroScript.time.minute);
		self:SetSharedVar("ks_Hour", kuroScript.time.hour);
		self:SetSharedVar("ks_Day", kuroScript.time.day);
	end;
	
	-- A function to create a ConVar.
	function kuroScript.frame:CreateConVar(name, value, flags, callback)
		local conVar = CreateConVar(name, value, flags or FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE);
		
		-- Add a ConVar change callback.
		cvars.AddChangeCallback(name, function(conVar, previousValue, newValue)
			hook.Call("KuroScriptConVarChanged", kuroScript.frame, conVar, previousValue, newValue);
			
			-- Check if a statement is true.
			if (callback) then
				callback(conVar, previousValue, newValue);
			end;
		end);
		
		-- Return the ConVar.
		return conVar;
	end;
	
	-- A function to set a shared variable.
	function kuroScript.frame:SetSharedVar(key, value)
		if (!NWTYPE_STRING) then
			GetWorldEntity():SetNetworkedVar(key, value);
		else
			GetWorldEntity()[key] = value;
		end;
	end;
	
	-- A function to check if the server is shutting down.
	function kuroScript.frame:IsShuttingDown()
		return self.ShuttingDown;
	end;
	
	-- A function to distribute wages currency.
	function kuroScript.frame:DistributeWagesCurrency()
		local k, v;
		
		-- Loop through each value in a table.
		for k, v in ipairs( g_Player.GetAll() ) do
			if ( v:HasInitialized() and v:Alive() ) then
				local wages = v:GetWages();
				
				-- Check if a statement is true.
				if ( hook.Call("PlayerCanEarnWagesCurrency", self, v, wages) ) then
					if (wages > 0) then
						kuroScript.player.GiveCurrency( v, wages, v:GetWagesName() );
					end;
					
					-- Call a gamemode hook.
					hook.Call("PlayerEarnWagesCurrency", kuroScript.frame, v, wages);
				end;
			end;
		end;
	end;
	
	-- A function to distribute contraband currency.
	function kuroScript.frame:DistributeContrabandCurrency()
		local contrabandEntities = {};
		local players = {};
		local k, v;
		
		-- Loop through each value in a table.
		for k, v in pairs(kuroScript.contraband.stored) do
			table.Add( contrabandEntities, ents.FindByClass(k) );
		end;
		
		-- Loop through each value in a table.
		for k, v in pairs(contrabandEntities) do
			local contraband = kuroScript.contraband.Get( v:GetClass() );
			local player = v:GetPlayer();
			
			-- Check if a statement is true.
			if ( ValidEntity(player) ) then
				if ( !players[player] ) then
					players[player] = 0;
				end;
				
				-- Check if a statement is true.
				if (player:Alive() and v:GetSharedVar("ks_Power") != 0) then
					players[player] = players[player] + contraband.currency;
				end;
				
				-- Set some information.
				v:SetSharedVar( "ks_Power", math.max(v:GetSharedVar("ks_Power") - 1, 0) );
			end;
		end;
		
		-- Loop through each value in a table.
		for k, v in pairs(players) do
			local info = {
				currency = v,
				name = "Contraband"
			};
			
			-- Call a gamemode hook.
			hook.Call("PlayerAdjustEarnedContrabandInfo", kuroScript.frame, k, info);
			
			-- Call a gamemode hook.
			if ( hook.Call("PlayerCanEarnContrabandCurrency", kuroScript.frame, k, info.currency) ) then
				if (info.currency > 0) then
					kuroScript.player.GiveCurrency(k, info.currency, info.name);
				end;
				
				-- Call a gamemode hook.
				hook.Call("PlayerEarnContrabandCurrency", kuroScript.frame, k, info.currency);
			end;
		end;
	end;
	
	-- A function to include the game mount.
	function kuroScript.frame:IncludeGameMount()
		kuroScript.config.Load(nil, true);
		
		-- Check if a statement is true.
		if (GAME_FOLDER and type(GAME_FOLDER) == "string") then
			if (GAME_FOLDER == "kuroscript") then
				kuroScript.mount.Include(GAME_FOLDER.."/gamemode/game", true);
			else
				kuroScript.mount.Include(GAME_FOLDER.."/gamemount", true);
			end;
			
			-- Load the game config.
			kuroScript.config.Load();
		end;
	end;
	
	-- A function to print a debug message.
	function kuroScript.frame:PrintDebug(text, private)
		if (KS_CONVAR_DEBUG:GetInt() == 1) then
			local listeners = {};
			local k, v;
			
			-- Loop through each value in a table.
			for k, v in ipairs( g_Player.GetAll() ) do
				if (v:HasInitialized() and v:GetInfoNum("ks_showkuroscriptlog", 0) == 1) then
					if ( v:IsAdmin() or v:IsUserGroup("operator") ) then
						listeners[#listeners + 1] = v;
					end;
				end;
			end;
			
			-- Set some information.
			local info = {
				text = text,
				private = private,
				listeners = listeners
			};
			
			-- Call a gamemode hook.
			hook.Call("DebugAdjustInfo", self, info);
			
			-- Loop through each value in a table.
			for k, v in pairs(listeners) do
				v:PrintMessage(2, info.text);
			end;
			
			-- Check if a statement is true.
			if (!info.private) then
				kuroScript.frame:Log(info.text);
			end;
		end;
	end;
	
	-- A function to log an action.
	function kuroScript.frame:Log(action)
		if (KS_CONVAR_LOG:GetInt() == 1) then
			ServerLog(action.."\n");
			
			-- Print the action.
			print(action);
		end;
	end;
else
	kuroScript.frame.PropertySheetTabs = { tabs = {} };
	kuroScript.frame.ProgressBarColor = Color(50, 100, 150, 200);
	kuroScript.frame.TargetPlayerText = { text = {} };
	kuroScript.frame.PlayerInfoText = { text = {}, width = {}, subText = {} };
	kuroScript.frame.ColorModify = {};
	kuroScript.frame.Cinematics = {};
	kuroScript.frame.KnownNames = {};
	kuroScript.frame.AmmoCount = {};
	kuroScript.frame.TopBars = { x = 0, y = 0, width = 0, height = 0, bars = {} };
	kuroScript.frame.TopText = { x = 0, y = 0, text = {} };
	kuroScript.frame.Alerts = {};

	-- A function to get some a property sheet tab.
	function kuroScript.frame.PropertySheetTabs:Get(text)
		for k, v in pairs(self.tabs) do
			if (v.text == text) then
				return v;
			end;
		end;
	end;
	
	-- A function to add a property sheet tab.
	function kuroScript.frame.PropertySheetTabs:Add(text, panel, icon, tip)
		self.tabs[#self.tabs + 1] = {text = text, panel = panel, icon = icon, tip = tip};
	end;

	-- A function to destroy a property sheet tab.
	function kuroScript.frame.PropertySheetTabs:Destroy(text)
		for k, v in pairs(self.tabs) do
			if (v.text == text) then
				table.remove(self.tabs, k);
			end;
		end;
	end;
	
	-- A function to add some target player text.
	function kuroScript.frame.TargetPlayerText:Add(uniqueID, text, color)
		self.text[#self.text + 1] = {uniqueID = uniqueID, text = text, color = color};
	end;
	
	-- A function to get some target player text.
	function kuroScript.frame.TargetPlayerText:Get(uniqueID)
		for k, v in pairs(self.text) do
			if (v.uniqueID == uniqueID) then return v; end;
		end;
	end;

	-- A function to destroy some target player text.
	function kuroScript.frame.TargetPlayerText:Destroy(uniqueID)
		for k, v in pairs(self.text) do
			if (v.uniqueID == uniqueID) then
				table.remove(self.text, k);
			end;
		end;
	end;

	-- A function to add some player info text.
	function kuroScript.frame.PlayerInfoText:Add(uniqueID, text, icon, alignment)
		if ( !alignment or !self.text[alignment] ) then
			alignment = ALIGN_LEFT;
		end;
		
		-- Set some information.
		self.text[alignment][#self.text[alignment] + 1] = {
			uniqueID = uniqueID,
			text = text,
			icon = icon
		};
	end;
	
	-- A function to get some player info text.
	function kuroScript.frame.PlayerInfoText:Get(uniqueID, alignment)
		local k, v;
		
		-- Check if a statement is true.
		if ( !alignment or !self.text[alignment] ) then
			alignment = ALIGN_LEFT;
		end;
		
		-- Loop through each value in a table.
		for k, v in pairs( self.text[alignment] ) do
			if (v.uniqueID == uniqueID) then
				return v;
			end;
		end;
	end;

	-- A function to add some sub player info text.
	function kuroScript.frame.PlayerInfoText:AddSub(uniqueID, text, alignment)
		if ( !alignment or !self.subText[alignment] ) then
			alignment = ALIGN_LEFT;
		end;
		
		-- Set some information.
		self.subText[alignment][#self.subText[alignment] + 1] = {
			uniqueID = uniqueID,
			text = text
		};
	end;
	
	-- A function to get some sub player info text.
	function kuroScript.frame.PlayerInfoText:GetSub(uniqueID, alignment)
		local k, v;
		
		-- Check if a statement is true.
		if ( !alignment or !self.subText[alignment] ) then
			alignment = ALIGN_LEFT;
		end;
		
		-- Loop through each value in a table.
		for k, v in pairs( self.subText[alignment] ) do
			if (v.uniqueID == uniqueID) then return v; end;
		end;
	end;

	-- A function to destroy some player info text.
	function kuroScript.frame.PlayerInfoText:Destroy(uniqueID, alignment)
		local k, v;
		
		-- Check if a statement is true.
		if ( !alignment or !self.text[alignment] ) then
			alignment = ALIGN_LEFT;
		end;
		
		-- Loop through each value in a table.
		for k, v in pairs( self.text[alignment] ) do
			if (v.uniqueID == uniqueID) then
				table.remove(self.text[alignment], k);
			end;
		end;
	end;

	-- A function to destroy some sub player info text.
	function kuroScript.frame.PlayerInfoText:DestroySub(uniqueID, alignment)
		local k, v;
		
		-- Check if a statement is true.
		if ( !alignment or !self.subText[alignment] ) then
			alignment = ALIGN_LEFT;
		end;
		
		-- Loop through each value in a table.
		for k, v in pairs( self.subText[alignment] ) do
			if (v.uniqueID == uniqueID) then
				table.remove(self.subText[alignment], k);
			end;
		end;
	end;

	-- A function to get a top bar.
	function kuroScript.frame.TopBars:Get(uniqueID)
		for k, v in pairs(self.bars) do
			if (v.uniqueID == uniqueID) then return v; end;
		end;
	end;
	
	-- A function to add a top bar.
	function kuroScript.frame.TopBars:Add(class, uniqueID, text, value, maximum, flash)
		local color = nil;
		
		-- Check the class of the top bar.
		if (class == "+") then
			local drain = 200 - ( (200 / maximum) * value );
			
			-- Set some information.
			color = Color(drain, 200 - drain, 50, 200);
		elseif (class == "-") then
			local drain = (200 / maximum) * value;
			
			-- Set some information.
			color = Color(drain, 200 - drain, 50, 200);
		end;
		
		-- Set some information.
		self.bars[#self.bars + 1] = {
			uniqueID = uniqueID,
			maximum = maximum,
			color = color,
			class = class,
			value = value,
			flash = flash,
			text = text,
		};
	end;

	-- A function to destroy a top bar.
	function kuroScript.frame.TopBars:Destroy(uniqueID)
		for k, v in pairs(self.bars) do
			if (v.uniqueID == uniqueID) then
				table.remove(self.bars, k);
			end;
		end;
	end;
	
	-- A function to get some top text.
	function kuroScript.frame.TopText:Get(uniqueID)
		for k, v in pairs(self.text) do
			if (v.uniqueID == uniqueID) then
				return v;
			end;
		end;
	end;

	-- A function to add some top text.
	function kuroScript.frame.TopText:Add(uniqueID, class, text)
		self.text[#self.text + 1] = {uniqueID = uniqueID, class = class, text = text};
	end;

	-- A function to destroy a top text.
	function kuroScript.frame.TopText:Destroy(uniqueID)
		for k, v in pairs(self.text) do
			if (v.uniqueID == uniqueID) then
				table.remove(self.text, k);
			end;
		end;
	end;
	
	-- A function to create a client ConVar.
	function kuroScript.frame:CreateClientConVar(name, value, save, userData, callback)
		local conVar = CreateClientConVar(name, value, save, userData);
		
		-- Add a ConVar change callback.
		cvars.AddChangeCallback(name, function(conVar, previousValue, newValue)
			hook.Call("KuroScriptConVarChanged", kuroScript.frame, conVar, previousValue, newValue);
			
			-- Check if a statement is true.
			if (callback) then
				callback(conVar, previousValue, newValue);
			end;
		end);
		
		-- Return the ConVar.
		return conVar;
	end;
	
	-- A function to get the size of text.
	function kuroScript.frame:GetTextSize(font, text)
		surface.SetFont(font);
		
		-- Set some information.
		local defaultWidth, defaultHeight = surface.GetTextSize("U");
		local width, height = 0, 0;
		local k, v;
		local i;
		
		-- Loop through a range of values.
		for i = 1, string.len(text) do
			local textWidth, textHeight = surface.GetTextSize( string.sub(text, i, i) );
			
			-- Check if a statement is true.
			if (textWidth == 0) then textWidth = defaultWidth; end;
			if (textHeight == 0) then textHeight = defaultHeight; end;
			
			-- Set some information.
			width = width + textWidth;
			height = height + textHeight;
		end;
		
		-- Return the size of the text.
		return width, height;
	end;
	
	-- A function to calculate alpha from a distance.
	function kuroScript.frame:CalculateAlphaFromDistance(maximum, start, finish)
		if (type(start) == "Player") then
			start = start:GetShootPos();
		elseif (type(start) == "Entity") then
			start = start:GetPos();
		end;
		
		-- Check if a statement is true.
		if (type(finish) == "Player") then
			finish = finish:GetShootPos();
		elseif (type(finish) == "Entity") then
			finish = finish:GetPos();
		end;
		
		-- Return the alpha.
		return math.Clamp(255 - ( (255 / maximum) * ( start:Distance(finish) ) ), 0, 255);
	end;
	
	-- A function to wrap text into a table.
	function kuroScript.frame:WrapText(text, font, width, overhead, returnTable)
		if (width <= 0 or !text or text == "") then return; end;
		
		-- Set some information.
		local originalWidth = width; width = width - (overhead or 0);
		
		-- Check if a statement is true.
		if (self:GetTextSize(font, text) > width) then
			local length = 0;
			local exploded = {};
			local seperator = "";
			
			-- Check if a statement is true.
			if ( string.find(text, " ") ) then	
				exploded = kuroScript.frame:ExplodeString(" ", text);
				seperator = " ";
			else
				exploded = string.ToTable(text);
				seperator = "";
			end;
			
			-- Set some information.
			local i = 1;
			
			-- Keep looping while a statement is true.
			while (length < width) do
				local block = table.concat(exploded, seperator, 1, i);
				
				-- Set some information.
				length = self:GetTextSize(font, block);
				
				-- Set some information.
				i = i + 1;
			end;
			
			-- Set some information.
			returnTable[#returnTable + 1] =  table.concat(exploded, seperator, 1, i - 2);
			
			-- Set some information.
			text = table.concat(exploded, seperator, i - 1);
			
			-- Check if a statement is true.
			if (self:GetTextSize(font, text) > originalWidth) then
				self:WrapText(text, font, originalWidth, nil, returnTable);
			else
				returnTable[#returnTable + 1] = text;
			end;
		else
			returnTable[#returnTable + 1] = text;
		end;
	end;
	
	-- A function to add a menu from data.
	function kuroScript.frame:AddMenuFromData(menu, data, callback)
		local options = {};
		local created;
		local k, v;
		
		-- Check if a statement is true.
		if (!menu) then
			created = true; menu = DermaMenu();
		end;
		
		-- Loop through each value in a table.
		for k, v in pairs(data) do
			options[#options + 1] = {k, v};
		end;
		
		-- Sort the new options.
		table.sort(options, function(a, b) return a[1] < b[1]; end);
		
		-- Loop through each value in a table.
		for k, v in pairs(options) do
			if (type( v[2] ) == "function") then
				menu:AddOption( v[1], v[2] );
			elseif (type( v[2] ) == "table") then
				if (table.Count( v[2] ) > 0) then
					self:AddMenuFromData(menu:AddSubMenu( v[1] ), v[2], callback);
				end;
			elseif (callback) then
				callback( menu, v[1], v[2] );
			end;
		end;
		
		-- Check if a statement is true.
		if (created) then
			if (#options > 0) then
				menu:Open();
				
				-- Register the Derma menu for close.
				RegisterDermaMenuForClose(menu);
			else
				menu:Remove();
			end;
			
			-- Return the menu.
			return menu;
		end;
	end;
	
	-- A function to adjust the width of text.
	function kuroScript.frame:AdjustMaximumWidth(font, text, width, addition, extra)
		surface.SetFont(font);
		
		-- Set some information.
		local textWidth = surface.GetTextSize( tostring( string.Replace(text, "&", "U") ) ) + (extra or 0);
		
		-- Check if a statement is true.
		if (textWidth > width) then width = textWidth + (addition or 0); end;
		
		-- Return the new width.
		return width;
	end;

	-- A function to draw the alerts.
	function kuroScript.frame:DrawAlerts()
		local scrW = ScrW();
		local scrH = ScrH();
		local k, v;
		
		-- Loop through each value in a table.
		for k, v in pairs(self.Alerts) do
			v.alpha = math.Clamp(v.alpha - 1, 0, 255); v.add = v.add + 1;
			
			-- Check if a statement is true.
			if ( self.Alerts[k - 1] ) then
				if ( (scrH - 64 - v.add) < ( (scrH - 64 - self.Alerts[k - 1].add) + 24 ) ) then
					v.add = v.add - 24;
				end;
			end;
			
			-- Draw some information.
			self:DrawInfo(v.text, scrW, scrH - (scrH / 6) - v.add, v.color, v.alpha, true, function(x, y, width, height)
				return x - width - 8, y - height - 8;
			end);
			
			-- Check if a statement is true.
			if (v.alpha == 0) then
				self.Alerts[k] = nil;
			end;
		end;
	end;

	-- A function to draw the top text.
	function kuroScript.frame:DrawTopText()
		self.TopText.x = ScrW();
		self.TopText.y = 8;
		
		-- Check if a statement is true.
		if ( hook.Call("PlayerCanSeeTopText", self) ) then
			local k, v;
			
			-- Loop through each value in a table.
			for k, v in ipairs(self.TopText.text) do
				if (v.class == "+") then
					self.TopText.y = self:DrawInfo(v.text, self.TopText.x, self.TopText.y, Color(75, 150, 50, 255), 255, true, function(x, y, width, height)
						return x - width - 8, y;
					end);
				elseif (v.class == "-") then
					self.TopText.y = self:DrawInfo(v.text, self.TopText.x, self.TopText.y, Color(150, 50, 50, 255), 255, true, function(x, y, width, height)
						return x - width - 8, y;
					end);
				end;
			end;
		end;
	end;

	-- A function to draw the top bars.
	function kuroScript.frame:DrawTopBars()
		self.TopBars.x = 8;
		self.TopBars.y = 8;
		self.TopBars.width = ScrW() / 4;
		self.TopBars.height = 14;
		
		-- Check if a statement is true.
		if ( hook.Call("PlayerCanSeeTopBars", self) ) then
			local k, v;
			
			-- Loop through each value in a table.
			for k, v in ipairs(self.TopBars.bars) do
				self:DrawBar(self.TopBars.x, self.TopBars.y, self.TopBars.width, self.TopBars.height, v.color, v.text, v.value, v.maximum, v.flash, self.TopBars);
			end;
		end;
	end;

	-- A function to draw a bar with a value and a maximum.
	function kuroScript.frame:DrawBar(x, y, width, height, color, text, value, maximum, flash, bars)
		draw.RoundedBox(2, x, y, width, height, COLOR_BACKGROUND);
		draw.RoundedBox(0, x + 1, y + 1, width - 2, height - 2, COLOR_FOREGROUND);
		draw.RoundedBox(0, x + 1, y + 1, math.Clamp( ( (width - 2) / maximum ) * value, 0, width - 2 ), height - 2, color);
		
		-- Check if a statement is true.
		if (flash) then
			local alpha = math.Clamp(math.abs(math.sin( UnPredictedCurTime() ) * 50), 0, 50);
			
			-- Draw the flashing bar.
			draw.RoundedBox( 0, x + 2, y + 2, width - 4, height - 4, Color(255, 255, 255, alpha) );
		end;
		
		-- Set some information.
		x = x + (width / 2);
		y = y + (height / 2);
		
		-- Draw some simple text.
		self:DrawSimpleText(text, x, y, COLOR_WHITE, 1, 1);
		
		-- Check if a statement is true.
		if (bars) then
			bars.y = (bars.y + height) + 2;
		else
			return y + (height / 2) + 2;
		end;
	end;
	
	-- A function to override the main font.
	function kuroScript.frame:OverrideMainFont(font)
		if (!font and self.PreviousMainFont) then
			FONT_MAIN_TEXT = self.PreviousMainFont;
		elseif (font) then
			if (!self.PreviousMainFont) then
				self.PreviousMainFont = FONT_MAIN_TEXT;
			end;
			
			-- Set some information.
			FONT_MAIN_TEXT = font;
		end
	end;

	-- A function to get the bounce of the screen's center.
	function kuroScript.frame:GetScreenCenterBounce(bounce)
		return ScrW() / 2, (ScrH() / 2) + 32 + ( math.sin( UnPredictedCurTime() ) * (bounce or 8) );
	end;
	
	-- A function to draw some simple text.
	function kuroScript.frame:DrawSimpleText(text, x, y, color, alignX, alignY, shadowless)
		x = math.Round(x);
		y = math.Round(y);
		
		-- Check if a statement is true.
		if (!shadowless) then
			local outlineColor = Color( 0, 0, 0, math.min(200, color.a) );
			
			-- Draw some simple text.
			draw.SimpleText(text, FONT_MAIN_TEXT, x + -1, y + -1, outlineColor, alignX, alignY);
			draw.SimpleText(text, FONT_MAIN_TEXT, x + -1, y + 1, outlineColor, alignX, alignY);
			draw.SimpleText(text, FONT_MAIN_TEXT, x + 1, y + -1, outlineColor, alignX, alignY);
			draw.SimpleText(text, FONT_MAIN_TEXT, x + 1, y + 1, outlineColor, alignX, alignY);
		end;
		
		-- Set some information.
		local width, height = draw.SimpleText(text, FONT_MAIN_TEXT, x, y, color, alignX, alignY);
		
		-- Check if a statement is true.
		if (height == 0) then
			height = draw.GetFontHeight(FONT_MAIN_TEXT);
		end;
		
		-- Return the y position.
		return y + height + 2;
	end;
	
	-- A function to get whether the screen is faded black.
	function kuroScript.frame:IsScreenFadedBlack()
		return (self.BlackFadeIn == 255);
	end;
	
	-- A function to draw information at a position.
	function kuroScript.frame:DrawInfo(text, x, y, color, alpha, left, callback)
		surface.SetFont(FONT_MAIN_TEXT);
		
		-- Set some information.
		local width, height = surface.GetTextSize(text);
		
		-- Check if a statement is true.
		if (!left) then x = x - (width / 2); end;
		if (callback) then x, y = callback(x, y, width, height); end;
		
		-- Draw some simple text.
		return self:DrawSimpleText( text, x, y, Color(color.r, color.g, color.b, alpha or color.a) );
	end;

	-- A function to get the day from an index.
	function kuroScript.frame:GetDayFromIndex(index)
		return DEFAULT_DAYS[index] or "Unknown";
	end;
	
	-- A function to get a time string from an hour and minute.
	function kuroScript.frame:GetTimeString(hour, minute)
		if (KS_CONVAR_TWELVEHOURCLOCK:GetInt() == 1) then
			hour = tonumber(hour);
			
			-- Check if a statement is true.
			if (hour >= 12) then
				if (hour > 12) then hour = hour - 12; end;
				
				-- Return the time string.
				return self:ZeroNumberToDigits(hour, 2)..":"..minute.."pm";
			else
				return self:ZeroNumberToDigits(hour, 2)..":"..minute.."am";
			end;
		else
			return hour..":"..minute;
		end;
	end;
	
	-- A function to get the date information.
	function kuroScript.frame:GetDateInfo()
		local minute = self:GetSharedVar("ks_Minute");
		local hour = self:GetSharedVar("ks_Hour");
		local day = self:GetDayFromIndex( self:GetSharedVar("ks_Day") );
		
		-- Set some information.
		minute = self:ZeroNumberToDigits(minute, 2);
		hour = self:ZeroNumberToDigits(hour, 2);
		
		-- Return the date information.
		return day, hour, minute;
	end;

	-- A function to draw the local player's aligned information.
	function kuroScript.frame:DrawPlayerInfoAligned(alignment)
		if ( hook.Call("PlayerCanSeePlayerInfo", self, alignment) ) then
			local subInformation = self.PlayerInfoText.subText[alignment] or {};
			local information = self.PlayerInfoText.text[alignment] or {};
			local width = self.PlayerInfoText.width[alignment] or 0;
			local k, v;
			
			-- Check if a statement is true.
			if (#information > 0 or #subInformation > 0) then
				local height = (16 * #information) + (16 * #subInformation) + 10;
				local scrW = ScrW();
				local scrH = ScrH();
				local x = scrW - width - 8;
				local y = scrH - height - 8;
				
				-- Check if a statement is true.
				if (alignment == ALIGN_LEFT) then x = 8; end;
				
				-- Set some information.
				local box = {x = x, y = y, width = width, height = height};
				
				-- Loop through each value in a table.
				for k, v in ipairs(subInformation) do
					x, y = self:DrawPlayerInfoSubBox(v.text, x, y, width);
				end;
				
				-- Check if a statement is true.
				if (#information > 0) then
					draw.RoundedBox(2, x, y, width, height - (16 * #subInformation), COLOR_BACKGROUND);
					draw.RoundedBox(2, x + 2, y + 2, width - 4, height - (16 * #subInformation) - 4, COLOR_FOREGROUND);
				end;
				
				-- Set some information.
				x = x + 8; y = y + 6;
				
				-- Draw the information on the box.
				for k, v in ipairs(information) do
					if (v.icon) then
						self:DrawInfo(v.text, x + 24, y - 1, COLOR_WHITE, 255, true);
						
						-- Set some information.
						surface.SetTexture( surface.GetTextureID(v.icon) );
						surface.SetDrawColor(255, 255, 255, 255);
						surface.DrawTexturedRect(x, y - 1, 16, 16);
					else
						self:DrawInfo(v.text, x, y - 1, COLOR_WHITE, 255, true);
					end;
					
					-- Set some information.
					y = y + 16;
				end;
				
				-- Return the box.
				return box;
			end;
		end;
	end;

	-- A function to draw the local player's information.
	function kuroScript.frame:DrawPlayerInfo()
		local rightBox = self:DrawPlayerInfoAligned(ALIGN_RIGHT);
		local leftBox = self:DrawPlayerInfoAligned(ALIGN_LEFT);
		
		-- Return the right and left boxes.
		return rightBox, leftBox;
	end;
	
	-- A function to get the ragdoll eye angles.
	function kuroScript.frame:GetRagdollEyeAngles()
		if (!self.RagdollEyeAngles) then
			self.RagdollEyeAngles = Angle(0, 0, 0);
		end;
		
		-- Return the ragdoll eye angles.
		return self.RagdollEyeAngles;
	end;

	-- A function to draw a player information sub box.
	function kuroScript.frame:DrawPlayerInfoSubBox(text, x, y, width)
		draw.RoundedBox( 2, x, y, width, 20, COLOR_BACKGROUND );
		draw.RoundedBox( 2, x + 2, y + 2, width - 4, 14, COLOR_FOREGROUND );
		
		-- Draw some information.
		self:DrawInfo(text, x + (width / 2), y + 1, COLOR_WHITE, 255);
		
		-- Return x and y position.
		return x, y + 16;
	end;

	-- A function to draw the armor bar.
	function kuroScript.frame:DrawArmorBar()
		local armor = math.Clamp( g_LocalPlayer:Armor(), 0, g_LocalPlayer:GetMaxArmor() );
		
		-- Set some information.
		self.TopBars:Add( "+", "ARMOR", "Armor", armor, g_LocalPlayer:GetMaxArmor() );
	end;

	-- A function to draw the health bar.
	function kuroScript.frame:DrawHealthBar()
		local health = math.Clamp( g_LocalPlayer:Health(), 0, g_LocalPlayer:GetMaxHealth() );
		
		-- Set some information.
		self.TopBars:Add( "+", "HEALTH", "Health", health, g_LocalPlayer:GetMaxHealth() );
	end;
	
	-- A function to draw the secondary ammo bar.
	function kuroScript.frame:DrawSecondaryAmmoBar()
		local weapon = g_LocalPlayer:GetActiveWeapon();
		
		-- Check if a statement is true.
		if ( ValidEntity(weapon) ) then
			local class = weapon:GetClass();
			
			-- Check if a statement is true.
			if ( !self.AmmoCount[class.."_secondary"] ) then
				self.AmmoCount[class.."_secondary"] = weapon:Clip2();
			end;
			
			-- Check if a statement is true.
			if ( weapon:Clip2() > self.AmmoCount[class.."_secondary"] ) then
				self.AmmoCount[class.."_secondary"] = weapon:Clip2();
			end;
			
			--Get some information.
			local clipTwo = weapon:Clip2();
			local clipAmount = g_LocalPlayer:GetAmmoCount( weapon:GetSecondaryAmmoType() );
			local clipMaximum = self.AmmoCount[class.."_secondary"];
			
			-- Check the weapon needs ammo.
			if (!weapon.Secondary or !weapon.Secondary.ClipSize or weapon.Secondary.ClipSize > 0) then
				if (clipTwo >= 0 and clipMaximum > 0) then
					if (clipTwo == 0 and clipAmount > 0) then
						self.TopBars:Add("+", "SECONDARY_AMMO", "Secondary Ammo (Reload)", 0, 100);
					else
						self.TopBars:Add("+", "SECONDARY_AMMO", "Secondary Ammo ("..clipAmount..")", clipTwo, clipMaximum);
					end;
				elseif (clipAmount > 0) then
					if (clipTwo == -1) then
						self.TopBars:Add("-", "SECONDARY_AMMO", "Secondary Ammo ("..clipAmount..")", 100, 100);
					else
						self.TopBars:Add("-", "SECONDARY_AMMO", "Secondary Ammo (Reload)", 0, 100);
					end;
				end;
			end;
		end;
	end;

	-- A function to draw the primary ammo bar.
	function kuroScript.frame:DrawPrimaryAmmoBar()
		local weapon = g_LocalPlayer:GetActiveWeapon();
		
		-- Check if a statement is true.
		if ( ValidEntity(weapon) ) then
			local class = weapon:GetClass();
			
			-- Check if a statement is true.
			if ( !self.AmmoCount[class.."_primary"] ) then
				self.AmmoCount[class.."_primary"] = weapon:Clip1();
			end;
			
			-- Check if a statement is true.
			if ( weapon:Clip1() > self.AmmoCount[class.."_primary"] ) then
				self.AmmoCount[class.."_primary"] = weapon:Clip1();
			end;
			
			-- Set some information.
			local clipOne = weapon:Clip1();
			local clipAmount = g_LocalPlayer:GetAmmoCount( weapon:GetPrimaryAmmoType() );
			local clipMaximum = self.AmmoCount[class.."_primary"];
			
			-- Check the weapon needs ammo.
			if (!weapon.Primary or !weapon.Primary.ClipSize or weapon.Primary.ClipSize > 0) then
				if (clipOne >= 0 and clipMaximum > 0) then
					if (clipOne == 0 and clipAmount > 0) then
						self.TopBars:Add("+", "PRIMARY_AMMO", "Primary Ammo (Reload)", 0, 100);
					else
						self.TopBars:Add("+", "PRIMARY_AMMO", "Primary Ammo ("..clipAmount..")", clipOne, clipMaximum);
					end;
				elseif (clipAmount > 0) then
					if (clipOne == -1) then
						self.TopBars:Add("-", "PRIMARY_AMMO", "Primary Ammo ("..clipAmount..")", 100, 100);
					else
						self.TopBars:Add("-", "PRIMARY_AMMO", "Primary Ammo (Reload)", 0, 100);
					end;
				end;
			end;
		end;
	end;
	
	-- A function to add some cinematic text.
	function kuroScript.frame:AddCinematicText(text, color, hangTime)
		self.Cinematics[#self.Cinematics + 1] = {
			hangTime = hangTime or 3,
			color = color or Color(255, 255, 255, 255),
			text = text,
			add = 0
		};
	end;
	
	-- A function to add a notice.
	function kuroScript.frame:AddNotify(text, class, length)
		if (class != NOTIFY_HINT or string.sub(text, 1, 6) != "#Hint_") then
			self.BaseClass:AddNotify(text, class, length);
		end;
	end;
	
	-- A function to add an alert.
	function kuroScript.frame:AddAlert(text, color)
		local alert = {
			color = color,
			alpha = 255,
			text = text,
			add = 1
		};
		
		-- Play a sound.
		surface.PlaySound("buttons/button15.wav");
		
		-- Set some information.
		self.Alerts[#self.Alerts + 1] = alert;
		
		-- Print the alert.
		print(alert.text);
	end;
	
	-- A function to calculate the screen fading.
	function kuroScript.frame:CalculateScreenFading()
		if ( hook.Call("ShouldPlayerScreenFadeBlack", self) ) then
			if (!self.BlackFadeIn) then
				if (self.BlackFadeOut) then
					self.BlackFadeIn = self.BlackFadeOut;
				else
					self.BlackFadeIn = 0;
				end;
			end;
			
			-- Set some information.
			self.BlackFadeIn = math.Clamp(self.BlackFadeIn + (FrameTime() * 50), 0, 255);
			self.BlackFadeOut = nil;
			
			-- Draw a rounded box.
			draw.RoundedBox( 0, 0, 0, ScrW(), ScrH(), Color(0, 0, 0, self.BlackFadeIn) );
		else
			if (self.BlackFadeIn) then
				self.BlackFadeOut = self.BlackFadeIn;
			end;
			
			-- Set some information.
			self.BlackFadeIn = nil;
			
			-- Check if a statement is true.
			if (self.BlackFadeOut) then
				self.BlackFadeOut = math.Clamp(self.BlackFadeOut - (FrameTime() * 100), 0, 255);
				
				-- Draw a rounded box.
				draw.RoundedBox( 0, 0, 0, ScrW(), ScrH(), Color(0, 0, 0, self.BlackFadeOut) );
				
				-- Check if a statement is true.
				if (self.BlackFadeOut == 0) then
					self.BlackFadeOut = nil;
				end;
			end;
		end;
	end;
	
	-- A function to draw a cinematic.
	function kuroScript.frame:DrawCinematic(cinematic, curTime)
		local maxBarLength = ScrH() / 13;
		
		-- Check if a statement is true.
		if (cinematic.goBack and curTime > cinematic.goBack) then
			cinematic.add = math.Clamp(cinematic.add - 2, 0, maxBarLength);
			
			-- Check if a statement is true.
			if (cinematic.add == 0) then
				table.remove(self.Cinematics, 1);
				
				-- Set some information.
				cinematic = nil;
			end;
		else
			cinematic.add = math.Clamp(cinematic.add + 1, 0, maxBarLength);
			
			-- Check if a statement is true.
			if (cinematic.add == maxBarLength and !cinematic.goBack) then
				cinematic.goBack = curTime + cinematic.hangTime;
			end;
		end;
		
		-- Check if a statement is true.
		if (cinematic) then
			draw.RoundedBox( 0, 0, -maxBarLength + cinematic.add, ScrW(), maxBarLength, Color(0, 0, 0, 255) );
			draw.RoundedBox( 0, 0, ScrH() - cinematic.add, ScrW(), maxBarLength, Color(0, 0, 0, 255) );
			
			-- Draw some simple text.
			draw.SimpleText(cinematic.text, FONT_CINEMATIC_TEXT, ScrW() / 2, (ScrH() - cinematic.add) + (maxBarLength / 2), cinematic.color, 1, 1);
		end
	end;
	
	-- A function to draw the cinematic introduction.
	function kuroScript.frame:DrawCinematicIntro(curTime)
		local cinematicInfo = hook.Call("GetCinematicIntroInfo", self);
		
		-- Check if a statement is true.
		if (self.CinematicScreenAlpha and self.CinematicScreenTarget) then
			self.CinematicScreenAlpha = math.Approach(self.CinematicScreenAlpha, self.CinematicScreenTarget, 2);
			
			-- Check if a statement is true.
			if (self.CinematicScreenAlpha == self.CinematicScreenTarget) then
				if (self.CinematicScreenTarget == 255) then
					if (!self.CinematicScreenGoBack) then
						self.CinematicScreenGoBack = curTime + 3;
					end;
				else
					self.CinematicScreenDone = true;
				end;
			end;
			
			-- Check if a statement is true.
			if (self.CinematicScreenGoBack and curTime >= self.CinematicScreenGoBack) then
				self.CinematicScreenGoBack = nil;
				self.CinematicScreenTarget = 0;
			end;
			
			-- Check if a statement is true.
			if (!self.CinematicScreenDone and cinematicInfo.credits) then
				local alpha = math.Clamp(self.CinematicScreenAlpha, 0, 255);
				
				-- Draw some simple text.
				self:DrawSimpleText(cinematicInfo.credits, ScrW() / 4, ScrH() * 0.75, Color(255, 255, 255, alpha), 1, 1);
			end;
		else
			self.CinematicScreenAlpha = 0;
			self.CinematicScreenTarget = 255;
		end;
		
		-- Draw the cinematic introduction bars.
		self:DrawCinematicIntroBars();
	end;
	
	-- A function to draw the cinematic introduction bars.
	function kuroScript.frame:DrawCinematicIntroBars()
		local maxBarLength = ScrH() / 13;
		
		-- Check if a statement is true.
		if (self.CinematicScreenTarget and self.CinematicScreenTarget == 0) then
			if (self.CinematicScreenBarLength != 0) then
				self.CinematicScreenBarLength = math.Clamp( (maxBarLength / 255) * self.CinematicScreenAlpha, 0, maxBarLength );
			end;
		end;
		
		-- Check if a statement is true.
		if (!self.CinematicScreenBarLength or self.CinematicScreenBarLength > 0) then
			local cinematicScreenBarLength = self.CinematicScreenBarLength or maxBarLength;
			
			-- Draw some rounded boxes.
			draw.RoundedBox( 0, 0, 0, ScrW(), cinematicScreenBarLength, Color(0, 0, 0, 255) );
			draw.RoundedBox( 0, 0, ScrH() - cinematicScreenBarLength, ScrW(), maxBarLength, Color(0, 0, 0, 255) );
		end;
	end;
	
	-- A function to get whether the local player's character screen is open.
	function kuroScript.frame:IsCharacterScreenOpen()
		if (kuroScript.character.open) then
			return kuroScript.character.panel and kuroScript.character.panel:IsValid();
		end;
	end;
	
	-- A function to get whether the local player is choosing a character.
	function kuroScript.frame:IsChoosingCharacter()
		if ( !kuroScript.character.panel or !kuroScript.character.panel:IsValid() ) then
			return true;
		else
			return kuroScript.character.open;
		end;
	end;
	
	-- A function to get the character fault.
	function kuroScript.frame:GetCharacterFault()
		return kuroScript.character.fault;
	end;
	
	-- A function to include the game mount.
	function kuroScript.frame:IncludeGameMount()
		if (GAME_FOLDER and type(GAME_FOLDER) == "string") then
			if (GAME_FOLDER == "kuroscript") then
				kuroScript.mount.Include(GAME_FOLDER.."/gamemode/game", true);
			else
				kuroScript.mount.Include(GAME_FOLDER.."/gamemount", true);
			end;
		end;
	end;

	-- A function to draw the ammo bars.
	function kuroScript.frame:DrawAmmoBars()
		self:DrawPrimaryAmmoBar();
		self:DrawSecondaryAmmoBar();
	end;
end;

-- A function to explode a string by tags.
function kuroScript.frame:ExplodeByTags(text, seperator, open, close, hide)
	local results = {};
	local current = "";
	local tag = nil;
	local i;
	
	-- Loop through each value in a table.
	for i = 1, string.len(text) do
		local character = string.sub(text, i, i);
		
		-- Check if a statement is true.
		if (!tag) then
			if (character == open) then
				if (!hide) then
					current = current..character;
				end;
				
				-- Set some information.
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
				
				-- Set some information.
				tag = nil;
			else
				current = current..character;
			end;
		end;
	end;
	
	-- Check if a statement is true.
	if (current != "") then
		results[#results + 1] = current;
	end;
	
	-- Return the results.
	return results;
end;

-- A function to modify details.
function kuroScript.frame:ModifyDetails(text)
	local pattern = "(.)[;%-%+%.|:,/\\](.)";
	local details = string.gsub(text, pattern, "%1|%2");
	
	-- Set some information.
	details = string.gsub(details, "[%s_]+(.)", string.upper);
	details = string.gsub(details, "Freeman", "Faggot");
	details = string.gsub(details, "^|+", "");
	details = string.gsub(details, "|+$", "");
	details = string.gsub(details, "^(.)", string.upper);
	details = string.gsub(details, "|.", string.upper);
	
	-- Return the modified details.
	return string.sub(details, 1, 48);
end;

-- A function to explode a string.
function kuroScript.frame:ExplodeString(seperator, text)
	local exploded = {};
	
	-- Loop through each value in a table.
	for value in string.gmatch(text, "([^"..seperator.."]+)") do
		exploded[#exploded + 1] = value;
	end;
	
	-- Return the exploded table.
	return exploded;
end;

-- A function to create a new meta table.
function kuroScript.frame:NewMetaTable(base)
	local object = {};
	
	-- Set some information.
	setmetatable(object, base);
	
	-- Set some information.
	base.__index = base;
	
	-- Return the new object.
	return object;
end;

-- A function to set whether a string should be in camel case.
function kuroScript.frame:SetCamelCase(text, camelCase)
	if (camelCase) then
		return string.gsub(text, "^.", string.lower);
	else
		return string.gsub(text, "^.", string.upper);
	end;
end;

-- A function to include files in a directory.
function kuroScript.frame:IncludeDirectory(directory)
	local k, v;
	
	-- Check if a statement is true.
	if (string.sub(directory, -1) != "/") then
		directory = directory.."/";
	end;
	
	-- Loop through each value in a table.
	for k, v in pairs( file.FindInLua(directory.."*.lua") ) do
		kuroScript.frame:IncludePrefixed(directory..v);
	end;
end;

-- A function to include a prefixed file.
function kuroScript.frame:IncludePrefixed(file)
	if (string.find(file, "sv_") and !SERVER) then
		return;
	end;
	
	-- Check if a statement is true.
	if (string.find(file, "sh_") and SERVER) then
		AddCSLuaFile(file);
	elseif (string.find(file, "cl_") and SERVER) then
		AddCSLuaFile(file);
		
		-- Return to break the function.
		return;
	end;
	
	-- Include the file.
	include(file);
end;

-- A function to include mounts in a directory.
function kuroScript.frame:IncludeMounts(directory)
	local k, v;
	
	-- Check if a statement is true.
	if (string.sub(directory, -1) != "/") then
		directory = directory.."/";
	end;
	
	-- Loop through each value in a table.
	for k, v in pairs( file.FindInLua(directory.."*") ) do
		if (v != "." and v != "..") then
			kuroScript.mount.Include(directory..v);
		end;
	end;
end;

-- A function to perform the timer think.
function kuroScript.frame:CallTimerThink(curTime)
	local k, v;
	
	-- Loop through each value in a table.
	for k, v in pairs(self.Timers) do
		if (!v.paused) then
			if (curTime >= v.nextCall) then
				local success, value = pcall( v.callback, unpack(v.arguments) );
				
				-- Check if a statement is true.
				if (!success) then
					ErrorNoHalt("kuroScript | '"..tostring(k).."' timer has failed: "..tostring(value)..".\n");
				end;
				
				-- Set some information.
				v.nextCall = curTime + v.delay;
				v.calls = v.calls + 1;
				
				-- Check if a statement is true.
				if (v.calls == v.repetitions) then
					self.Timers[k] = nil;
				end;
			end;
		end;
	end;
end;

-- A function to start a timer.
function kuroScript.frame:StartTimer(name)
	if (self.Timers[name] and self.Timers[name].paused) then
		self.Timers[name].nextCall = CurTime() + self.Timers[name].timeLeft;
		self.Timers[name].paused = nil;
	end;
end;

-- A function to pause a timer.
function kuroScript.frame:PauseTimer(name)
	if (self.Timers[name] and !self.Timers[name].paused) then
		self.Timers[name].timeLeft = self.Timers[name].nextCall - CurTime();
		self.Timers[name].paused = true;
	end;
end;


-- A function to destroy a timer.
function kuroScript.frame:DestroyTimer(name)
	self.Timers[name] = nil;
end;

-- A function to create a timer.
function kuroScript.frame:CreateTimer(name, delay, repetitions, callback, ...)
	self.Timers[name] = {
		calls = 0,
		delay = delay,
		nextCall = CurTime() + delay,
		callback = callback,
		arguments = {...},
		repetitions = repetitions
	};
end;

-- A function to get whether a player has access to an object.
function kuroScript.frame:HasObjectAccess(player, object)
	local access = nil;
	local class = nil;
	
	-- Check if a statement is true.
	if (SERVER) then
		class = player:QueryCharacter("class");
	else
		class = kuroScript.player.GetClass(player);
	end;
	
	-- Check if a statement is true.
	if (object.access) then
		if ( kuroScript.player.HasAnyAccess(player, object.access) ) then
			access = true;
		end;
	end;
	
	-- Check if a statement is true.
	if (object.classes) then
		if ( table.HasValue(object.classes, class) ) then
			access = true;
		end;
	end;
	
	-- Check if a statement is true.
	if (object.vocations) then
		local team = player:Team();
		local vocation = kuroScript.vocation.Get(team);
		
		-- Check if a statement is true.
		if (vocation) then
			if ( table.HasValue(object.vocations, team) or table.HasValue(object.vocations, vocation.name) ) then
				access = true;
			end;
		end;
	end;
	
	-- Check if a statement is true.
	if (!object.access and !object.classes and !object.vocations) then
		access = true;
	end;
	
	-- Check if a statement is true.
	if (object.blacklist) then
		local team = player:Team();
		local vocation = kuroScript.vocation.Get(team);
		
		-- Check if a statement is true.
		if ( table.HasValue(object.blacklist, class) ) then
			access = nil;
		elseif (vocation) then
			if ( table.HasValue(object.blacklist, team) or table.HasValue(object.blacklist, vocation.name) ) then
				access = nil;
			end;
		else
			local k, v;
			
			-- Loop through each value in a table.
			for k, v in ipairs(object.blacklist) do
				if (type(v) == "string") then
					if ( kuroScript.player.HasAnyAccess(player, v) ) then
						access = nil; break;
					end;
				end;
			end;
		end;
	end;
	
	-- Return the access.
	return access;
end;

-- A function to derive from Sandbox.
function kuroScript.frame:DeriveFromSandbox()
	DeriveGamemode("Sandbox");

	-- Check if a statement is true.
	if (!kuroScript.frame.IsSandboxDerived) then
		GM = {Folder = "gamemodes/sandbox"};
		
		-- Check if a statement is true.
		if (CLIENT) then
			include("sandbox/gamemode/cl_init.lua");
		else
			include("sandbox/gamemode/init.lua");
		end;
		
		-- Set some information.
		local sandboxGamemode = GM;
		local baseGamemode = gamemode.Get("base");
		
		-- Check if a statement is true.
		if (sandboxGamemode and baseGamemode) then
			table.Inherit(sandboxGamemode, baseGamemode);
			table.Inherit(kuroScript.frame, sandboxGamemode);
			
			-- Set some information.
			timer.Simple(FrameTime() * 0.5, function()
				kuroScript.frame.BaseClass = sandboxGamemode;
			end);
			
			-- Set some information.
			GM = kuroScript.frame;
		end;
	end;
end;

-- A function to get the sorted commands.
function kuroScript.frame:GetSortedCommands()
	local commands = {};
	local source = kuroScript.command.stored;
	local k, v;
	
	-- Loop through each value in a table.
	for k, v in pairs(source) do
		commands[#commands + 1] = k;
	end;
	
	-- Sort the commands.
	table.sort(commands, function(a, b)
		return a < b;
	end);
	
	-- Return the commands.
	return commands;
end;

-- A function to zero a number to an amount of digits.
function kuroScript.frame:ZeroNumberToDigits(number, digits)
	return string.rep( "0", math.Clamp(digits - string.len( tostring(number) ), 0, digits) )..number;
end;

-- A function to get a short CRC from a value.
function kuroScript.frame:GetShortCRC(value)
	return math.ceil(util.CRC(value) / 100000);
end;

-- A function to validate a table's keys.
function kuroScript.frame:ValidateTableKeys(base)
	for i = 1, #base do
		if ( !base[i] ) then
			table.remove(base, i);
		end;
	end;
end;

-- A function to get the kuroScript folder.
function kuroScript.frame:GetFolder()
	return string.gsub(self.Folder, "gamemodes/", "").."/gamemode";
end;

-- A function to get the map's physics entities.
function kuroScript.frame:GetPhysicsEntities()
	local entities = {};
	local k, v;
	
	-- Loop through each value in a table.
	for k, v in ipairs( ents.FindByClass("prop_physics_multiplayer") ) do
		if ( ValidEntity(v) ) then
			entities[#entities + 1] = v;
		end;
	end;
	
	-- Loop through each value in a table.
	for k, v in ipairs( ents.FindByClass("prop_physics") ) do
		if ( ValidEntity(v) ) then
			entities[#entities + 1] = v;
		end;
	end;
	
	-- Return the entities.
	return entities;
end;

-- A function to create a multicall table (by Deco Da Man).
function kuroScript.frame:CreateMulticallTable(base, object)
	local metaTable = getmetatable(base) or {};
	
	-- Called when an index is needed.
	function metaTable.__index(base, key)
		return function(base, ...)
			local k, v;
			
			-- Loop through each value in a table.
			for k, v in pairs(base) do
				object[key](v, ...);
			end;
		end
	end
	
	-- Set some information.
	setmetatable(base, metaTable);
	
	-- Return the multicall table.
	return base;
end;

-- A function to check if the shared variables have initialized.
function kuroScript.frame:SharedVarsHaveInitialized()
	local worldEntity = GetWorldEntity();
	
	-- Check if a statement is true.
	if ( worldEntity and worldEntity.IsWorld and worldEntity:IsWorld() ) then
		return true;
	end;
end;

-- A function to get a shared variable.
function kuroScript.frame:GetSharedVar(key)
	if (!NWTYPE_STRING) then
		return GetWorldEntity():GetNetworkedVar(key);
	else
		return GetWorldEntity()[key];
	end;
end;

-- A function to create fake damage info.
function kuroScript.frame:FakeDamageInfo(damage, inflictor, attacker, ammoType, position, damageType, damageForce)
	local damageInfo = DamageInfo();
	
	-- Set some information.
	damageInfo:SetDamageForce(Vector() * damageForce);
	damageInfo:SetAttacker(attacker);
	damageInfo:SetInflictor(inflictor);
	damageInfo:SetDamage(damage)
	
	-- Return the damage info.
	return damageInfo;
end;

-- A function to parse data in text.
function kuroScript.frame:ParseData(text)
	local classes = {"%^", "%!"};
	local k, v;
	local key;
	
	-- Loop through each value in a table.
	for k, v in ipairs(classes) do
		for key in string.gmatch(text, v.."(.-)"..v) do
			local lower = false;
			local amount;
			
			-- Check if a statement is true.
			if (string.sub(key, 1, 1) == "(" and string.sub(key, -1) == ")") then
				lower = true;
				amount = tonumber( string.sub(key, 2, -2) );
			else
				amount = tonumber(key);
			end;
			
			-- Check if a statement is true.
			if (amount) then
				text = string.gsub( text, v..string.gsub(key, "([%(%)])", "%%%1")..v, tostring( FORMAT_CURRENCY(amount, k == 2, lower) ) );
			end;
		end;
	end;
	
	-- Loop through each value in a table.
	for key in string.gmatch(text, "%*(.-)%*") do
		local exploded = kuroScript.frame:ExplodeString("%.", key);
		local value = _G;
		
		-- Loop through each table in a value.
		for k, v in ipairs(exploded) do
			if ( type(value) == "table" and value[v] ) then
				value = value[v];
			else
				break;
			end;
		end;
		
		-- Check if a statement is true.
		if (value != _G) then
			text = string.gsub( text, "%*"..key.."%*", tostring(value) );
		end;
	end;
	
	-- Return the text.
	return kuroScript.config.Parse(text);
end;