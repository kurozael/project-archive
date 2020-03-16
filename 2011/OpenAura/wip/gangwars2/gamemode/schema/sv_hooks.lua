--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local JETPACK_SOUNDS = {};
local JETPACK_SOUND = Sound("PhysicsCannister.ThrusterLoop");

-- Called when a player attempts to use a lowered weapon.
function openAura.schema:PlayerCanUseLoweredWeapon(player, weapon, secondary)
	if ( secondary and (weapon.SilenceTime or weapon.PistolBurst) ) then
		return true;
	end;
end;

-- Called when the OpenAura schema has loaded.
function openAura.schema:OpenAuraSchemaLoaded()
	self.gangResources = {
		FACTION_MAFIA = 0,
		FACTION_YAKUZA = 0,
		FACTION_QAEDA = 0,
		FACTION_KINGS = 0
	};
end;

-- Called when a player's cash has been updated.
function openAura.schema:PlayerCashUpdated(player, amount, reason, noMessage)
	if (amount > 0 and !noMessage) then
		openAura.player:PlaySound(player, "npc/combine_soldier/gear1.wav");
	end;
end;

-- Called when a player attempts to own a door.
function openAura.schema:PlayerCanOwnDoor(player, door)
	return false;
end;

-- Called when a player attempts to view a door.
function openAura.schema:PlayerCanViewDoor(player, door)
	return false;
end;

-- Called when a player attempts to fire a weapon.
function openAura.schema:PlayerCanFireWeapon(player, raised, weapon, secondary)
	if ( player:IsRunning() ) then
		return false;
	end;
end;

-- Called to get whether a player's weapon is raised.
function openAura.schema:GetPlayerWeaponRaised(player, class, weapon)
	if ( player:IsRunning() ) then
		return false;
	end;
end;

-- Called each tick.
function openAura.schema:Tick()
	local curTime = CurTime();
	
	if (!self.nextCleanDecals or curTime >= self.nextCleanDecals) then
		self.nextCleanDecals = curTime + 60;
		
		for k, v in ipairs( _player.GetAll() ) do
			v:RunCommand("r_cleardecals");
		end;
	end;
	
	if (!self.nextCleanSounds or curTime >= self.nextCleanSounds) then
		self.nextCleanSounds = curTime + 2;
		
		for k, v in pairs(JETPACK_SOUNDS) do
			if ( !IsValid(k) ) then
				JETPACK_SOUNDS[k] = nil;
				v:Stop();
			end;
		end;
	end;
end;

-- Called when a player's weapons should be given.
function openAura.schema:PlayerGiveWeapons(player)
	local weapons = self:GetWeapons(player);
	
	if (weapons) then
		for k, v in ipairs(weapons) do
			if (type(v) == "string") then
				openAura.player:GiveSpawnWeapon(player, v);
				
				if (k == 1) then
					player:SelectWeapon(v);
				end;
			else
				openAura.player:GiveSpawnWeapon( player, v[1] );
				openAura.player:GiveSpawnAmmo( player, v[2], v[3] );
				
				if (k == 1) then
					player:SelectWeapon( v[1] );
				end;
			end;
		end;
	end;
end;

-- Called when a player attempts to spawn a prop.
function openAura.schema:PlayerSpawnProp(player, model)
	model = string.Replace(model, "\\", "/");
	model = string.Replace(model, "//", "/");
	model = string.lower(model);
	
	if ( string.find(model, "fence") ) then
		openAura.player:Notify(player, "You cannot spawn fence props!");
		
		return false;
	end;
end;

-- Called when a player's character has initialized.
function openAura.schema:PlayerCharacterInitialized(player)
	umsg.Start("aura_AchievementsClear", player);
	umsg.End();
	
	umsg.Start("aura_UpgradesClear", player);
	umsg.End();
	
	for k, v in pairs( player:GetCharacterData("achievements") ) do
		local achievementTable = openAura.achievement:Get(k);
		
		if (achievementTable) then
			umsg.Start("aura_AchievementsProgress", player);
				umsg.Long(achievementTable.index);
				umsg.Short(v);
			umsg.End();
		end;
	end;
	
	for k, v in pairs( player:GetCharacterData("upgrades") ) do
		local upgradeTable = openAura.upgrade:Get(k);
		
		if (upgradeTable) then
			umsg.Start("aura_UpgradesGive", player);
				umsg.Long(upgradeTable.index);
			umsg.End();
		end;
	end;
end;

-- Called when an entity's menu option should be handled.
function openAura.schema:EntityHandleMenuOption(player, entity, option, arguments)
	if (arguments == "aura_corpseRevive") then
		local entityPlayer = openAura.entity:GetPlayer(entity);
		local curTime = CurTime();
		
		if ( entityPlayer and !entityPlayer:Alive() ) then
			if (!entityPlayer.nextCanBeRevived or curTime >= entityPlayer.nextCanBeRevived) then
				entityPlayer.nextCanBeRevived = curTime + 60;
				
				local position = openAura.entity:GetPelvisPosition(entity);
				local health = math.Clamp(player:Health() / 2, 1, 100);
				
				entityPlayer:Spawn();
				player:SetHealth(player:Health() - health);
				entityPlayer:SetHealth(health);
				player:EmitSound("ambient/energy/whiteflash.wav");
				
				local effectData = EffectData();
					effectData:SetStart(position);
					effectData:SetOrigin(position);
					effectData:SetScale(32);
				util.Effect("GlassImpact", effectData, true, true);
				
				umsg.Start("aura_Flashed", entityPlayer);
				umsg.End();
				
				openAura.player:SetSafePosition(entityPlayer, position);
				
				if ( ValidEntity(entity) ) then
					entity:Remove();
				end;
			else
				openAura.player:Notify(player, "This character cannot be revived yet!");
			end;
		end;
	end;
end;

-- Called when a player spawns an object.
function openAura.schema:PlayerSpawnObject(player)
	-- only builders.
end;

-- Called when a player attempts to use an entity in a vehicle.
function openAura.schema:PlayerCanUseEntityInVehicle(player, entity, vehicle)
	if ( entity:IsPlayer() or openAura.entity:IsPlayerRagdoll(entity) ) then
		return true;
	end;
end;

-- Called when a player attempts to use a tool.
function openAura.schema:CanTool(player, trace, tool)
	if ( !openAura.player:HasFlags(player, "w") ) then
		if (string.sub(tool, 1, 5) == "wire_" or string.sub(tool, 1, 6) == "wire2_") then
			player:RunCommand("gmod_toolmode \"\"");
			
			return false;
		end;
	end;
end;

-- Called when a player's character data should be restored.
function openAura.schema:PlayerRestoreCharacterData(player, data)
	if ( !data["achievements"] ) then data["achievements"] = {}; end;
	if ( !data["upgrades"] ) then data["upgrades"] = {}; end;
	if ( !data["stamina"] ) then data["stamina"] = 100; end;
	if ( !data["reqexp"] ) then data["reqexp"] = 100; end;
	if ( !data["curexp"] ) then data["curexp"] = 0; end;
	if ( !data["level"] ) then data["level"] = 1; end;
	if ( !data["title"] ) then data["title"] = ""; end;
end;

-- Called just before a player dies.
function openAura.schema:DoPlayerDeath(player, attacker, damageInfo)
	if ( attacker:IsPlayer() ) then
		player:SpectateEntity(attacker);
		player:Spectate(OBS_MODE_FREEZECAM);
		
		self:GiveEXP(attacker, self:GetLevel(player) * 10);
		
		umsg.Start("aura_Killed", attacker);
			umsg.Entity(player);
		umsg.End();
	end;
end;


-- Called after a player dies.
function openAura.schema:PostPlayerDeath(player)
	if (player:GetObserverMode() == OBS_MODE_NONE) then
		player:Spectate(OBS_MODE_DEATHCAM);
	end;
end;

-- Called when a player's shared variables should be set.
function openAura.schema:PlayerSetSharedVars(player, curTime)
	player:SetSharedVar( "stamina", player:GetCharacterData("stamina") );
	player:SetSharedVar( "reqEXP", player:GetCharacterData("reqexp") );
	player:SetSharedVar( "curEXP", player:GetCharacterData("curexp") );
	player:SetSharedVar( "title", player:GetCharacterData("title") );
	player:SetSharedVar( "level", player:GetCharacterData("level") );
end;

-- Called when a player has been unragdolled.
function openAura.schema:PlayerUnragdolled(player, state, ragdoll)
	openAura.player:SetAction(player, "die", false);
end;

-- Called when a player has been ragdolled.
function openAura.schema:PlayerRagdolled(player, state, ragdoll)
	openAura.player:SetAction(player, "die", false);
end;

-- Called when a player moves.
function openAura.schema:Move(player, moveData)
	local isJetpacking = false;
	local isOnGround = player:IsOnGround() or ( player:GetGroundEntity() == GetWorldEntity() );
	-- todo: jetpack items.
	if ( player:Alive() and !player:IsRagdolled() and false ) then
		local currentVelocity = moveData:GetVelocity();
		local isHoldingSprint = player:KeyDown(IN_SPEED);
		local isHoldingJump = player:KeyDown(IN_JUMP);
		
		if (isHoldingJump and isHoldingSprint) then
			if (!isOnGround) then
				moveData:SetVelocity(player:GetAimVector() * 384);
				player.wasJetpacking = true;
				
				isJetpacking = true;
			end;
		elseif (isHoldingJump and player.wasJetpacking) then
			if (!isOnGround) then
				moveData:SetVelocity( Vector(currentVelocity.x, currentVelocity.y, 0) );
				isJetpacking = true;
			end;
		end;
	end;
	
	player.isJetpacking = isJetpacking;
	player:SetSharedVar("jetpack", player.isJetpacking);
	
	if (isOnGround) then
		player.wasJetpacking = false;
	end;
end;

-- Called at an interval while a player is connected.
function openAura.schema:PlayerThink(player, curTime, infoTable)
	local regeneration = 0;
	local armor = player:Armor();
	
	if (player.isJetpacking) then
		if ( !JETPACK_SOUNDS[player] ) then
			JETPACK_SOUNDS[player] = CreateSound(player, JETPACK_SOUND);
			JETPACK_SOUNDS[player]:PlayEx(0.5, 100);
		end;
	elseif ( JETPACK_SOUNDS[player] ) then
		JETPACK_SOUNDS[player]:Stop();
		JETPACK_SOUNDS[player] = nil;
	end;
	
	local thermalVision = player:GetWeapon("aura_thermalvision");
	local stealthCamo = player:GetWeapon("aura_stealthcamo");
	local isRagdolled = player:IsRagdolled();
	local isAlive = player:Alive();
	
	if (ValidEntity(thermalVision) and thermalVision:IsActivated() and isAlive and !isRagdolled) then
		if (player:GetCharacterData("stamina") > 5) then
			player:SetSharedVar("thermal", true);
		else
			player:EmitSound("items/nvg_off.wav");
			thermalVision:SetActivated(false);
		end;
	else
		player:SetSharedVar("thermal", false);
	end;
	
	if (ValidEntity(stealthCamo) and stealthCamo:IsActivated() and isAlive and !isRagdolled) then
		if (!player.lastMaterial) then
			player.lastMaterial = player:GetMaterial();
		end;
		
		if (!player.lastColor) then
			player.lastColor = { player:GetColor() };
		end;
		
		player:SetMaterial("sprites/heatwave");
		player:SetColor(255, 255, 255, 0);
	elseif (player.lastMaterial and player.lastColor) then
		player:SetMaterial(player.lastMaterial);
		player:SetColor( unpack(player.lastColor) );
		
		player.lastMaterial = nil;
		player.lastColor = nil;
	end;
	
	if ( player:IsRunning() ) then
		player:SetCharacterData( "stamina", math.Clamp(player:GetCharacterData("stamina") - 1, 0, 100) );
	elseif (player:GetVelocity():Length() == 0) then
		if ( player:Crouching() ) then
			regeneration = 1;
		else
			regeneration = 0.5;
		end;
	else
		regeneration = 0.25;
	end;
	
	if (regeneration > 0) then
		player:SetCharacterData( "stamina", math.Clamp(player:GetCharacterData("stamina") + regeneration, 0, 100) );
	end;
	
	local newRunSpeed = infoTable.runSpeed * 2;
	local diffRunSpeed = newRunSpeed - infoTable.walkSpeed;
	
	infoTable.runSpeed = newRunSpeed - ( diffRunSpeed - ( (diffRunSpeed / 100) * player:GetCharacterData("stamina") ) );
end;

-- Called when a player attempts to use an entity.
function openAura.schema:PlayerUse(player, entity)
	if (entity.canNotBeOpened) then
		return false;
	end;
	
	if (entity:GetClass() == "prop_door_rotating") then
		if ( player:IsRunning() and player:Alive() and !player:IsRagdolled() ) then
			self:BustDownDoor(player, entity);
			
			umsg.Start("aura_OverrideThirdPerson", player);
				umsg.Short(3);
			umsg.End();
			
			return false;
		end;
	end;
end;

-- Called when chat box info should be adjusted.
function openAura.schema:ChatBoxAdjustInfo(info)
	if ( IsValid(info.speaker) and info.speaker:HasInitialized() ) then
		if (info.class != "ooc" and info.class != "looc") then
			if ( IsValid(info.speaker) and info.speaker:HasInitialized() ) then
				if (string.sub(info.text, 1, 1) == "?") then
					info.text = string.sub(info.text, 2);
					info.data.anon = true;
				end;
			end;
		end;
	end;
end;

-- Called when a player attempts to destroy generator.
function openAura.schema:PlayerCanDestroyGenerator(player, entity, generator)
	local owner = entity:GetPlayer();
	
	if ( IsValid(owner) and openAura.player:GetFaction(owner) == openAura.player:GetFaction(player) ) then
		return false;
	end;
end;

-- Called when a player destroys generator.
function openAura.schema:PlayerDestroyGenerator(player, entity, generator)
	openAura.player:GiveCash( player, generator.cash / 2, "destroying a "..string.lower(generator.name) );
end;

-- Called when a player dies.
function openAura.schema:PlayerDeath(player, inflictor, attacker, damageInfo)
	if ( attacker:IsPlayer() ) then
		local weapon = attacker:GetActiveWeapon();
		
		if ( IsValid(weapon) ) then
			umsg.Start("aura_Death", player);
				umsg.Entity(weapon);
				umsg.Entity(attacker);
			umsg.End();
		else
			umsg.Start("aura_Death", player);
				umsg.Entity(attacker);
			umsg.End();
		end;
	else
		umsg.Start("aura_Death", player);
			umsg.Entity(attacker);
		umsg.End();
	end;
end;

-- Called just after a player spawns.
function openAura.schema:PostPlayerSpawn(player, lightSpawn, changeClass, firstSpawn)
	if (!lightSpawn) then
		player:SetCharacterData("stamina", 100);
		
		umsg.Start("aura_ClearEffects", player);
		umsg.End();
	end;
end;

-- Called when a player's footstep sound should be played.
function openAura.schema:PlayerFootstep(player, position, foot, sound, volume, recipientFilter)
	if ( player:IsRunning() or player:IsJogging() ) then
		local runSounds = {
			"npc/metropolice/gear1.wav",
			"npc/metropolice/gear2.wav",
			"npc/metropolice/gear3.wav",
			"npc/metropolice/gear4.wav",
			"npc/metropolice/gear5.wav",
			"npc/metropolice/gear6.wav"
		};
		
		sound = runSounds[ math.random(1, #runSounds) ];
	end;
	
	player:EmitSound(sound);
	
	return true;
end;

-- Called when a player takes damage.
function openAura.schema:PlayerTakeDamage(player, inflictor, attacker, hitGroup, damageInfo)
	local curTime = CurTime();
	
	if ( damageInfo:IsBulletDamage() ) then
		if (player:Armor() > 0) then
			umsg.Start("aura_ShotEffect", player);
				umsg.Float(0.25);
			umsg.End();
		else
			umsg.Start("aura_ShotEffect", player);
				umsg.Float(0.5);
			umsg.End();
		end;
	end;
	
	if (player:Health() <= 10 and math.random() <= 0.75) then
		if (openAura.player:GetAction(player) != "die") then
			openAura.player:SetRagdollState( player, RAGDOLL_FALLENOVER, nil, nil, openAura:ConvertForce(damageInfo:GetDamageForce() * 32) );
			
			local duration = 60;
			
			openAura.player:SetAction(player, "die", duration, 1, function()
				if ( IsValid(player) and player:Alive() ) then
					player:TakeDamage(player:Health() * 2, attacker, inflictor);
				end;
			end);
		end;
	end;
	
	if ( attacker:IsPlayer() ) then
		umsg.Start("aura_TakeDmg", player);
			umsg.Entity(attacker);
			umsg.Short( damageInfo:GetDamage() );
		umsg.End();
		
		umsg.Start("aura_DealDmg", attacker);
			umsg.Entity(player);
			umsg.Short( damageInfo:GetDamage() );
		umsg.End();
	end;
end;

-- A function to scale damage by hit group.
function openAura.schema:PlayerScaleDamageByHitGroup(player, attacker, hitGroup, damageInfo, baseDamage)
	if (attacker:GetClass() == "entityflame") then
		if (!player.nextTakeBurnDamage or curTime >= player.nextTakeBurnDamage) then
			player.nextTakeBurnDamage = curTime + 0.1;
			
			damageInfo:SetDamage(1);
		else
			damageInfo:SetDamage(0);
		end;
	end;
end;

-- Called when an entity takes damage.
function openAura.schema:EntityTakeDamage(entity, inflictor, attacker, amount, damageInfo)
	if ( attacker:IsPlayer() ) then
		if (entity:GetClass() == "prop_physics") then
			if ( damageInfo:IsBulletDamage() ) then
				damageInfo:ScaleDamage(0.5);
			end;
			
			local boundingRadius = entity:BoundingRadius() * 12;
			entity.health = entity.health or boundingRadius;
			entity.health = math.max(entity.health - damageInfo:GetDamage(), 0);
			
			local blackness = (255 / boundingRadius) * entity.health;
			entity:SetColor(blackness, blackness, blackness, 255);
			
			if (entity.health == 0 and !entity.isDead) then
				openAura.entity:Decay(entity, 5);
				
				entity:SetCollisionGroup(COLLISION_GROUP_WEAPON);
				entity:Ignite(5, 0);
				entity.isDead = true;
			end;
		end;
	end;
end;