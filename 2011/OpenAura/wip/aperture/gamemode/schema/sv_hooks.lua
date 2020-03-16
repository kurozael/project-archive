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

-- Called when a player switches their flashlight on or off.
function openAura.schema:PlayerSwitchFlashlight(player, on)
	return false;
end;

-- Called when a player's death info should be adjusted.
function openAura.schema:PlayerAdjustDeathInfo(player, info)
	if ( openAura.augments:Has(player, AUG_REINCARNATION) ) then
		info.spawnTime = info.spawnTime * 0.25;
	end;
end;

-- Called when a player's character has unloaded.
function openAura.schema:PlayerCharacterUnloaded(player)
	local nextDisconnect = 0;
	local curTime = CurTime();
	
	if (player.nextDisconnect) then
		nextDisconnect = player.nextDisconnect;
	end;
	
	if ( player:HasInitialized() ) then
		if (player:GetSharedVar("tied") or curTime < nextDisconnect) then
			self:PlayerDropRandomItems(player, nil, true);
			openAura.player:DropWeapons(player);
		end;
	end;
end;

-- Called when a player attempts to order an item shipment.
function openAura.schema:PlayerCanOrderShipment(player, itemTable)
	if ( itemTable.requiresExplosives and !openAura.augments:Has(player, AUG_EXPLOSIVES) ) then
		openAura.player:Notify(player, "You need the Explosives augment to craft this!");
		
		return false;
	elseif ( itemTable.requiresArmadillo and !openAura.augments:Has(player, AUG_ARMADILLO) ) then
		openAura.player:Notify(player, "You need the Armadillo augment to craft this!");
		
		return false;
	elseif ( itemTable.requiresGunsmith and !openAura.augments:Has(player, AUG_GUNSMITH) ) then
		openAura.player:Notify(player, "You need the Gunsmith augment to craft this!");
		
		return false;
	elseif (itemTable.cost > 120 and itemTable.batch > 1) then
		local craftRequired = math.floor( math.Clamp(itemTable.cost / 150, 0, 50) );
		local crafting = openAura.attributes:Fraction(player, ATB_CRAFTING, 50, 50);
		
		if (crafting < craftRequired) then
			openAura.player:Notify(player, "You need an crafting level of "..( (100 / 50) * craftRequired ).."% to craft this!");
			
			return false;
		end;
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

-- Called when a player uses an unknown item function.
function openAura.schema:PlayerUseUnknownItemFunction(player, itemTable, itemFunction)
	if (itemFunction == "Cash" and itemTable.cost) then
		local useSounds = {"buttons/button5.wav", "buttons/button4.wav"};
		local cashBack = itemTable.cost;
		
		if ( openAura.augments:Has(player, AUG_BLACKMARKET) ) then
			cashBack = cashBack * 0.2;
		elseif ( openAura.augments:Has(player, AUG_CASHBACK) ) then
			cashBack = cashBack * 0.25;
		else
			return;
		end;
		
		player:UpdateInventory(itemTable.uniqueID, -1, true);
		player:EmitSound( useSounds[ math.random(1, #useSounds) ] );
		
		openAura.player:GiveCash(player, cashBack, "cashed an item");
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
	umsg.Start("aura_TrophiesClear", player);
	umsg.End();
	
	umsg.Start("aura_AugmentsClear", player);
	umsg.End();
	
	for k, v in pairs( player:GetCharacterData("trophies") ) do
		local trophyTable = openAura.trophy:Get(k);
		
		if (trophyTable) then
			umsg.Start("aura_TrophiesProgress", player);
				umsg.Long(trophyTable.index);
				umsg.Short(v);
			umsg.End();
		end;
	end;
	
	for k, v in pairs( player:GetCharacterData("augments") ) do
		local augmentTable = openAura.augment:Get(k);
		
		if (augmentTable) then
			umsg.Start("aura_AugmentsGive", player);
				umsg.Long(augmentTable.index);
			umsg.End();
		end;
	end;
	
	if ( !player:GetData("ddm") ) then
		player:SetData("ddm", true);
		openAura.player:GiveCash(player, 1000, "Double Cash Monday!");
	end;
end;

-- Called when a player has been given a weapon.
function openAura.schema:PlayerGivenWeapon(player, class, uniqueID, forceReturn)
	local itemTable = openAura.item:GetWeapon(class, uniqueID);
	
	if (openAura.item:IsWeapon(itemTable) and !itemTable.fakeWeapon) then
		if ( !itemTable:IsMeleeWeapon() and !itemTable:IsThrowableWeapon() ) then
			if (itemTable.weight <= 2) then
				openAura.player:CreateGear(player, "Secondary", itemTable);
			else
				openAura.player:CreateGear(player, "Primary", itemTable);
			end;
		elseif ( itemTable:IsThrowableWeapon() ) then
			openAura.player:CreateGear(player, "Throwable", itemTable);
		else
			openAura.player:CreateGear(player, "Melee", itemTable);
		end;
	end;
end;

-- Called when a player's drop weapon info should be adjusted.
function openAura.schema:PlayerAdjustDropWeaponInfo(player, info)
	if (openAura.player:GetWeaponClass(player) == info.itemTable.weaponClass) then
		info.position = player:GetShootPos();
		info.angles = player:GetAimVector():Angle();
	else
		local gearTable = {
			openAura.player:GetGear(player, "Throwable"),
			openAura.player:GetGear(player, "Secondary"),
			openAura.player:GetGear(player, "Primary"),
			openAura.player:GetGear(player, "Melee")
		};
		
		for k, v in pairs(gearTable) do
			if ( IsValid(v) ) then
				local gearItemTable = v:GetItem();
				
				if (gearItemTable and gearItemTable.weaponClass == info.itemTable.weaponClass) then
					local position, angles = v:GetRealPosition();
					
					if (position and angles) then
						info.position = position;
						info.angles = angles;
						
						break;
					end;
				end;
			end;
		end;
	end;
end;

-- Called when an entity is removed.
function openAura.schema:EntityRemoved(entity)
	if (IsValid(entity) and entity:GetClass() == "prop_ragdoll") then
		if (entity.areBelongings) then
			if (table.Count(entity.inventory) > 0 or entity.cash > 0) then
				local belongings = ents.Create("aura_belongings");
				
				belongings:SetAngles( Angle(0, 0, -90) );
				belongings:SetData(entity.inventory, entity.cash);
				belongings:SetPos( entity:GetPos() + Vector(0, 0, 32) );
				belongings:Spawn();
				
				entity.inventory = nil;
				entity.cash = nil;
			end;
		end;
	end;
end;

-- Called when an entity's menu option should be handled.
function openAura.schema:EntityHandleMenuOption(player, entity, option, arguments)
	local mineTypes = {"aura_firemine", "aura_freezemine", "aura_explomine"};
	
	if ( table.HasValue( mineTypes, entity:GetClass() ) ) then
		if ( arguments == "aura_mineDefuse" and !player:GetSharedVar("tied") ) then
			local defuseTime = openAura.schema:GetDexterityTime(player) * 2;
			
			openAura.player:SetAction(player, "defuse", defuseTime);
			
			openAura.player:EntityConditionTimer(player, entity, entity, defuseTime, 80, function()
				return player:Alive() and !player:IsRagdolled() and !player:GetSharedVar("tied");
			end, function(success)
				openAura.player:SetAction(player, "defuse", false);
				
				if (success) then
					entity:Defuse();
					entity:Remove();
				end;
			end);
		end;
	elseif (entity:GetClass() == "prop_ragdoll") then
		if (arguments == "aura_corpseLoot") then
			if (!entity.inventory) then entity.inventory = {}; end;
			if (!entity.cash) then entity.cash = 0; end;
			
			local entityPlayer = openAura.entity:GetPlayer(entity);
			
			if ( !entityPlayer or !entityPlayer:Alive() ) then
				player:EmitSound("physics/body/body_medium_impact_soft"..math.random(1, 7)..".wav");
				
				openAura.player:OpenStorage( player, {
					name = "Corpse",
					weight = 8,
					entity = entity,
					distance = 192,
					cash = entity.cash,
					inventory = entity.inventory,
					OnTake = function(player, storageTable, itemTable)
						if ( entity.clothesData and itemTable.index == entity.clothesData[1] ) then
							if ( !storageTable.inventory[itemTable.uniqueID] ) then
								entity:SetModel( entity.clothesData[2] );
								entity:SetSkin( entity.clothesData[3] );
							end;
						end;
					end,
					OnGiveCash = function(player, storageTable, cash)
						entity.cash = storageTable.cash;
					end,
					OnTakeCash = function(player, storageTable, cash)
						entity.cash = storageTable.cash;
						
						if (cash >= 1500) then
							openAura.trophies:Progress(player, TRO_RANSACKED);
						end;
					end
				} );
			end;
		elseif (arguments == "aura_corpseMutilate") then
			if ( openAura.augments:Has(player, AUG_MUTILATOR) ) then
				local entityPlayer = openAura.entity:GetPlayer(entity);
				local trace = player:GetEyeTraceNoCursor();
				
				if ( !entityPlayer or !entityPlayer:Alive() ) then
					if (!entity.mutilated or entity.mutilated < 3) then
						entity.mutilated = (entity.mutilated or 0) + 1;
							player:SetHealth( math.Clamp( player:Health() + 5, 0, player:GetMaxHealth() ) );
							player:EmitSound("npc/barnacle/barnacle_crunch"..math.random(2, 3)..".wav");
						openAura:CreateBloodEffects(entity:NearestPoint(trace.HitPos), 1, entity);
					end;
				end;
			end;
		elseif (arguments == "aura_corpseRevive") then
			if ( openAura.augments:Has(player, AUG_LIFEBRINGER) ) then
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
	elseif (entity:GetClass() == "aura_belongings" and arguments == "aura_belongingsOpen") then
		player:EmitSound("physics/body/body_medium_impact_soft"..math.random(1, 7)..".wav");
		
		openAura.player:OpenStorage( player, {
			name = "Belongings",
			weight = 100,
			entity = entity,
			distance = 192,
			cash = entity.cash,
			inventory = entity.inventory,
			OnGiveCash = function(player, storageTable, cash)
				entity.cash = storageTable.cash;
			end,
			OnTakeCash = function(player, storageTable, cash)
				entity.cash = storageTable.cash;
			end,
			OnClose = function(player, storageTable, entity)
				if ( IsValid(entity) ) then
					if ( (!entity.inventory and !entity.cash) or (table.Count(entity.inventory) == 0 and entity.cash == 0) ) then
						entity:Explode(entity:BoundingRadius() * 2);
						entity:Remove();
					end;
				end;
			end,
			CanGive = function(player, storageTable, itemTable)
				return false;
			end
		} );
	elseif (entity:GetClass() == "aura_breach") then
		entity:CreateDummyBreach();
		entity:BreachEntity(player);
	end;
end;

-- Called when a player's earn generator info should be adjusted.
function openAura.schema:PlayerAdjustEarnGeneratorInfo(player, info)
	if (info.entity:GetClass() == "aura_serumprinter") then
		if ( openAura.augments:Has(player, AUG_THIEVING) ) then
			info.cash = info.cash + 30;
		end;
	elseif (info.entity:GetClass() == "aura_serumproducer") then
		if ( openAura.augments:Has(player, AUG_METALSHIP) ) then
			info.cash = info.cash + 50;
		end;
	end;
end;

-- Called when OpenAura has loaded all of the entities.
function openAura.schema:OpenAuraInitPostEntity()
	self:LoadBelongings();
end;

-- Called just after data should be saved.
function openAura.schema:PostSaveData()
	self:SaveBelongings();
end;

-- Called when a player's inventory item has been updated.
function openAura.schema:PlayerInventoryItemUpdated(player, itemTable, amount, force)
	local clothes = player:GetCharacterData("clothes");
	
	if (clothes and itemTable.uniqueID == clothes) then
		if ( !player:HasItem(itemTable.uniqueID) ) then
			if ( player:Alive() ) then
				itemTable:OnChangeClothes(player, false);
			end;
			
			player:SetCharacterData("clothes", nil);
		end;
	elseif (itemTable.uniqueID == "skull_mask") then
		if ( player:GetSharedVar("skullMask") ) then
			if ( !player:HasItem(itemTable.uniqueID) ) then
				itemTable:OnPlayerUnequipped(player);
			end;
		end;
	elseif (itemTable.uniqueID == "heartbeat_implant") then
		if ( player:GetSharedVar("implant") ) then
			if ( !player:HasItem(itemTable.uniqueID) ) then
				itemTable:OnPlayerUnequipped(player);
			end;
		end;
	end;
end;

-- Called when a player attempts to spray their tag.
function openAura.schema:PlayerSpray(player)
	if ( !player:HasItem("spray_can") or player:GetSharedVar("tied") ) then
		return true;
	end;
end;

-- Called when a player presses F3.
function openAura.schema:ShowSpare1(player)
	local trace = player:GetEyeTraceNoCursor();
	local target = openAura.entity:GetPlayer(trace.Entity);

	if ( target and target:Alive() ) then
		if ( !target:GetSharedVar("tied") ) then
			openAura.player:RunOpenAuraCommand(player, "InvAction", "zip_tie", "use");
		else
			openAura.player:RunOpenAuraCommand(player, "CharSearch");
		end;
	end;
end;

-- Called when a player presses F4.
function openAura.schema:ShowSpare2(player)
	umsg.Start("aura_HotkeyMenu", player);
	umsg.End();
end;

-- Called when a player spawns an object.
function openAura.schema:PlayerSpawnObject(player)
	if ( player:GetSharedVar("tied") ) then
		openAura.player:Notify(player, "You don't have permission to do this right now!");
		
		return false;
	end;
end;

-- Called when a player attempts to breach an entity.
function openAura.schema:PlayerCanBreachEntity(player, entity)
	if ( openAura.entity:IsDoor(entity) ) then
		if ( !openAura.entity:IsDoorHidden(entity) ) then
			return true;
		end;
	end;
end;

-- Called when a player attempts to use the radio.
function openAura.schema:PlayerCanRadio(player, text, listeners, eavesdroppers)
	if ( player:HasItem("handheld_radio") ) then
		if ( !player:GetCharacterData("frequency") ) then
			openAura.player:Notify(player, "You need to set the radio frequency first!");
			
			return false;
		end;
	else
		openAura.player:Notify(player, "You do not own a radio!");
		
		return false;
	end;
end;

-- Called when a player attempts to use an entity in a vehicle.
function openAura.schema:PlayerCanUseEntityInVehicle(player, entity, vehicle)
	if ( entity:IsPlayer() or openAura.entity:IsPlayerRagdoll(entity) ) then
		return true;
	end;
end;

-- Called when a player attempts to use a door.
function openAura.schema:PlayerCanUseDoor(player, door)
	if ( player:GetSharedVar("tied") ) then
		return false;
	end;
end;

-- Called when a player's radio info should be adjusted.
function openAura.schema:PlayerAdjustRadioInfo(player, info)
	for k, v in ipairs( _player.GetAll() ) do
		if ( v:HasInitialized() and v:HasItem("handheld_radio") ) then
			if ( v:GetCharacterData("frequency") == player:GetCharacterData("frequency") ) then
				if ( !v:GetSharedVar("tied") ) then
					info.listeners[v] = v;
				end;
			end;
		end;
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
	if ( !data["trophies"] ) then data["trophies"] = {}; end;
	if ( !data["augments"] ) then data["augments"] = {}; end;
	if ( !data["notepad"] ) then data["notepad"] = ""; end;
	if ( !data["stamina"] ) then data["stamina"] = 100; end;
	if ( !data["heading"] ) then data["heading"] = ""; end;
	if ( !data["bounty"] ) then data["bounty"] = 0; end;
	if ( !data["karma"] ) then data["karma"] = 50; end;
	if ( !data["fuel"] ) then data["fuel"] = 100; end;
end;

-- Called when a player has been healed.
function openAura.schema:PlayerHealed(player, healer, itemTable)
	local action = openAura.player:GetAction(player);
	
	if ( player:IsGood() ) then
		healer:HandleKarma(5);
	else
		healer:HandleKarma(-5);
	end;
	
	if (itemTable.uniqueID == "health_vial") then
		healer:ProgressAttribute(ATB_DEXTERITY, 15, true);
	elseif (itemTable.uniqueID == "health_kit") then
		healer:ProgressAttribute(ATB_DEXTERITY, 25, true);
	elseif (itemTable.uniqueID == "bandage") then
		healer:ProgressAttribute(ATB_DEXTERITY, 5, true);
	end;
end;

-- Called when a player's shared variables should be set.
function openAura.schema:PlayerSetSharedVars(player, curTime)
	player:SetSharedVar( "clothes", player:GetCharacterData("clothes", 0) );
	player:SetSharedVar( "implant", player:GetCharacterData("implant", false) );
	player:SetSharedVar( "heading", player:GetCharacterData("heading") );
	player:SetSharedVar( "stamina", player:GetCharacterData("stamina") );
	player:SetSharedVar( "nextDC", player.nextDisconnect or 0 );
	player:SetSharedVar( "bounty", player:GetCharacterData("bounty") );
	player:SetSharedVar( "karma", player:GetCharacterData("karma") );
	player:SetSharedVar( "guild", player:GetCharacterData("guild", "") );
	player:SetSharedVar( "fuel", player:GetCharacterData("fuel") );
	player:SetSharedVar( "rank", player:GetCharacterData("rank") );
	
	if ( openAura.augments:Has(player, AUG_GHOSTHEART) ) then
		player:SetSharedVar("ghostheart", true);
	else
		player:SetSharedVar("ghostheart", false);
	end;
	
	if (player.cancelDisguise) then
		if ( curTime >= player.cancelDisguise or !IsValid( player:GetSharedVar("disguise") ) ) then
			openAura.player:Notify(player, "Your disguise has begun to fade away, your true identity is revealed.");
			
			player.cancelDisguise = nil;
			player:SetSharedVar("disguise", NULL);
		end;
	end;
	
	if (player:Alive() and !player:IsRagdolled() and player:GetVelocity():Length() > 0) then
		local inventoryWeight = openAura.inventory:GetWeight(player);
		
		if (inventoryWeight >= openAura.inventory:GetMaximumWeight(player) / 4) then
			player:ProgressAttribute(ATB_STRENGTH, inventoryWeight / 400, true);
		end;
	end;
	
	if (openAura.player:GetCash(player) > 200) then
		openAura.trophies:Progress(player, TRO_CODEKGUY);
	end;
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
	local curTime = CurTime();
	local clothes = player:GetCharacterData("clothes");

	if (player:Alive() and !player:IsRagdolled() and clothes) then
		if (player:GetCharacterData("fuel") > 5) then
			local itemTable = openAura.item:Get(clothes);
			
			if (itemTable and itemTable.hasJetpack) then
				local currentVelocity = moveData:GetVelocity();
				local isHoldingSprint = player:KeyDown(IN_SPEED);
				local isHoldingJump = player:KeyDown(IN_JUMP);
				
				if (isHoldingJump and isHoldingSprint) then
					local speed = openAura.attributes:Fraction(player, ATB_AERODYNAMICS, 256, 128);
					
					if (!isOnGround) then
						moveData:SetVelocity( player:GetAimVector() * (384 + speed) );
						player.wasJetpacking = true;
						
						if (!player.nextUpdateAero or curTime >= player.nextUpdateAero) then
							player.nextUpdateAero = curTime + 1;
							player:ProgressAttribute(ATB_AERODYNAMICS, 0.5, true);
						end;
						
						isJetpacking = true;
					end;
				elseif (isHoldingJump and player.wasJetpacking) then
					if (!isOnGround) then
						moveData:SetVelocity( Vector(currentVelocity.x, currentVelocity.y, 0) );
						isJetpacking = true;
					end;
				end;
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
	if ( player:Alive() and !player:IsRagdolled() ) then
		if (!player:InVehicle() and player:GetMoveType() == MOVETYPE_WALK) then
			if ( player:IsInWorld() ) then
				if ( !player:IsOnGround() and player:GetGroundEntity() != GetWorldEntity() ) then
					player:ProgressAttribute(ATB_ACROBATICS, 0.25, true);
				elseif (infoTable.running) then
					player:ProgressAttribute(ATB_AGILITY, 0.125, true);
				elseif (infoTable.jogging) then
					player:ProgressAttribute(ATB_AGILITY, 0.0625, true);
				end;
			end;
		end;
	end;
	
	local regeneration = 0;
	local acrobatics = openAura.attributes:Fraction(player, ATB_ACROBATICS, 175, 50);
	local aimVector = tostring( player:GetAimVector() );
	local strength = openAura.attributes:Fraction(player, ATB_STRENGTH, 8, 4);
	local agility = openAura.attributes:Fraction(player, ATB_AGILITY, 50, 25);
	local velocity = player:GetVelocity():Length();
	local armor = player:Armor();
	
	if ( !player.nextCheckAFK or (player.lastAimVector != aimVector and velocity < 1) ) then
		player.nextCheckAFK = curTime + 1800;
		player.lastAimVector = aimVector;
	end;
	
	if (curTime >= player.nextCheckAFK) then
		player:Kick("Kicked for being AFK");
	end;
	
	if (clothes != "") then
		local itemTable = openAura.item:Get(clothes);
		
		if (itemTable and itemTable.pocketSpace) then
			infoTable.inventoryWeight = infoTable.inventoryWeight + itemTable.pocketSpace;
		end;
	end;
	
	infoTable.inventoryWeight = infoTable.inventoryWeight + strength;
	infoTable.jumpPower = infoTable.jumpPower + acrobatics;
	infoTable.runSpeed = infoTable.runSpeed + agility;
	
	if ( openAura.augments:Has(player, AUG_GODSPEED) ) then
		infoTable.runSpeed = infoTable.runSpeed * 1.1;
	end;
	
	if (player.isJetpacking) then
		openAura.trophies:Progress(player, TRO_TAKETOTHESKIES, 0.5);
		
		if ( openAura.augments:Has(player, AUG_HIGHPOWERED) ) then
			player:SetCharacterData( "fuel", math.max(player:GetCharacterData("fuel") - 0.138888889, 0) );
		else
			player:SetCharacterData( "fuel", math.max(player:GetCharacterData("fuel") - 0.277777778, 0) );
		end;
		
		if ( !JETPACK_SOUNDS[player] ) then
			JETPACK_SOUNDS[player] = CreateSound(player, JETPACK_SOUND);
			JETPACK_SOUNDS[player]:PlayEx( 0.5, 100 + openAura.attributes:Fraction(player, ATB_AERODYNAMICS, 50, 50) );
		end;
	elseif ( JETPACK_SOUNDS[player] ) then
		JETPACK_SOUNDS[player]:Stop();
		JETPACK_SOUNDS[player] = nil;
	end;
	
	local mediumKevlar = openAura.item:Get("medium_kevlar");
	local heavyKevlar = openAura.item:Get("heavy_kevlar");
	local lightKevlar = openAura.item:Get("kevlar_vest");
	local playerGear = openAura.player:GetGear(player, "KevlarVest");
	
	if (armor > 100) then
		if (!playerGear or playerGear:GetItem() != heavyKevlar) then
			openAura.player:CreateGear(player, "KevlarVest", heavyKevlar);
		end;
	elseif (armor > 50) then
		if (!playerGear or playerGear:GetItem() != mediumKevlar) then
			openAura.player:CreateGear(player, "KevlarVest", mediumKevlar);
		end;
	elseif (armor > 0) then
		if (!playerGear or playerGear:GetItem() != lightKevlar) then
			openAura.player:CreateGear(player, "KevlarVest", lightKevlar);
		end;
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
	self:HandlePlayerImplants(player);
end;

-- Called when a player uses an item.
function openAura.schema:PlayerUseItem(player, itemTable)
	if (itemTable.category == "Consumables" or itemTable.category == "Alcohol") then
		player:SetCharacterData("stamina", 100);
	end;
end;

-- Called when a player orders an item shipment.
function openAura.schema:PlayerOrderShipment(player, itemTable, entity)
	if (itemTable.batch == 5) then
		openAura.trophies:Progress(player, TRO_BULKBUYER);
	end;
	
	if (itemTable.uniqueID == "aura_metalcrowbar") then
		openAura.trophies:Progress(player, AUG_FREEMAN);
	end;
	
	player:ProgressAttribute(ATB_CRAFTING, itemTable.cost / 3, true);	
end;

-- Called when attempts to use a command.
function openAura.schema:PlayerCanUseCommand(player, commandTable, arguments)
	if ( player:GetSharedVar("tied") ) then
		local blacklisted = {
			"OrderShipment",
			"Radio"
		};
		
		if ( table.HasValue(blacklisted, commandTable.name) ) then
			openAura.player:Notify(player, "You cannot use this command when you are tied!");
			
			return false;
		end;
	end;
end;

-- Called when a player attempts to use an entity.
function openAura.schema:PlayerUse(player, entity)
	local curTime = CurTime();
	
	if (entity.bustedDown) then
		return false;
	end;
	
	if ( player:GetSharedVar("tied") ) then
		if ( entity:IsVehicle() ) then
			if ( openAura.entity:IsChairEntity(entity) or openAura.entity:IsPodEntity(entity) ) then
				return;
			end;
		end;
		
		if ( !player.nextTieNotify or player.nextTieNotify < CurTime() ) then
			openAura.player:Notify(player, "You cannot use that when you are tied!");
			
			player.nextTieNotify = CurTime() + 2;
		end;
		
		return false;
	end;
end;

-- Called when a player attempts to destroy an item.
function openAura.schema:PlayerCanDestroyItem(player, itemTable, noMessage)
	if ( player:GetSharedVar("tied") ) then
		if (!noMessage) then
			openAura.player:Notify(player, "You cannot destroy items when you are tied!");
		end;
		
		return false;
	end;
end;

-- Called when a player attempts to drop an item.
function openAura.schema:PlayerCanDropItem(player, itemTable, noMessage)
	if ( player:GetSharedVar("tied") ) then
		if (!noMessage) then
			openAura.player:Notify(player, "You cannot drop items when you are tied!");
		end;
		
		return false;
	end;
end;

-- Called when a player attempts to use an item.
function openAura.schema:PlayerCanUseItem(player, itemTable, noMessage)
	if ( player:GetSharedVar("tied") ) then
		if (!noMessage) then
			openAura.player:Notify(player, "You cannot use items when you are tied!");
		end;
		
		return false;
	end;
	
	if (openAura.item:IsWeapon(itemTable) and !itemTable.fakeWeapon) then
		local throwableWeapon = nil;
		local secondaryWeapon = nil;
		local primaryWeapon = nil;
		local meleeWeapon = nil;
		local fault = nil;
		
		for k, v in ipairs( player:GetWeapons() ) do
			local weaponTable = openAura.item:GetWeapon(v);
			
			if (weaponTable and !weaponTable.fakeWeapon) then
				if ( !weaponTable:IsMeleeWeapon() and !weaponTable:IsThrowableWeapon() ) then
					if (weaponTable.weight <= 2) then
						secondaryWeapon = true;
					else
						primaryWeapon = true;
					end;
				elseif ( weaponTable:IsThrowableWeapon() ) then
					throwableWeapon = true;
				else
					meleeWeapon = true;
				end;
			end;
		end;
		
		if ( !itemTable:IsMeleeWeapon() and !itemTable:IsThrowableWeapon() ) then
			if (itemTable.weight <= 2) then
				if (secondaryWeapon) then
					fault = "You cannot use another secondary weapon!";
				end;
			elseif (primaryWeapon) then
				fault = "You cannot use another secondary weapon!";
			end;
		elseif ( itemTable:IsThrowableWeapon() ) then
			if (throwableWeapon) then
				fault = "You cannot use another throwable weapon!";
			end;
		elseif (meleeWeapon) then
			fault = "You cannot use another melee weapon!";
		end;
		
		if (fault) then
			if (!noMessage) then
				openAura.player:Notify(player, fault);
			end;
			
			return false;
		end;
	end;
end;

-- Called when a player attempts to say something out-of-character.
function openAura.schema:PlayerCanSayOOC(player, text)
	if ( !openAura.player:IsAdmin(player) ) then
		openAura.player:Notify(player, "Out-of-character discussion is disabled in this experiment.");
		
		return false;
	end;
end;

-- Called when a player attempts to say something locally out-of-character.
function openAura.schema:PlayerCanSayLOOC(player, text)
	if ( !player:Alive() ) then
		openAura.player:Notify(player, "You don't have permission to do this right now!");
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

-- Called when a player destroys generator.
function openAura.schema:PlayerDestroyGenerator(player, entity, generator)
	local owner = entity:GetPlayer();
	
	if ( IsValid(owner) and owner:IsGood() ) then
		if ( openAura.augments:Has(player, AUG_PAYBACK) ) then
			openAura.player:GiveCash( player, generator.cash, "destroying a "..string.lower(generator.name) );
			
			return;
		end;
	end;
	
	openAura.player:GiveCash( player, generator.cash / 2, "destroying a "..string.lower(generator.name) );
end;

-- Called when a player dies.
function openAura.schema:PlayerDeath(player, inflictor, attacker, damageInfo)
	openAura.trophies:Progress(player, TRO_BULLYVICTIM);
	
	if ( openAura.augments:Has(player, AUG_FLASHMARTYR) ) then
		self:SpawnFlash( player:GetPos() );
	elseif ( openAura.augments:Has(player, AUG_TEARMARTYR) ) then
		self:SpawnTearGas( player:GetPos() );
	end;
	
	if ( attacker:IsPlayer() ) then
		local listeners = {};
		local weapon = attacker:GetActiveWeapon();
		
		for k, v in ipairs( _player.GetAll() ) do
			if ( v:HasInitialized() and openAura.player:IsAdmin(v) ) then
				listeners[#listeners + 1] = v;
			end;
		end;
		
		if (#listeners > 0) then
			openAura.chatBox:Add( listeners, attacker, "killed", "", {victim = player} );
		end;
		
		if ( IsValid(weapon) ) then
			umsg.Start("aura_Death", player);
				umsg.Entity(weapon);
			umsg.End();
		else
			umsg.Start("aura_Death", player);
			umsg.End();
		end;
		
		if ( player:IsBad() ) then
			openAura.trophies:Progress(attacker, TRO_DEVILHUNTER);
			attacker:HandleKarma(5);
		else
			openAura.trophies:Progress(attacker, TRO_SAINTHUNTER);
			attacker:HandleKarma(-5);
		end;
		
		if ( player:IsWanted() and player:GetGuild() != attacker:GetGuild() ) then
			openAura.trophies:Progress(attacker, TRO_BOUNTYHUNTER);
			openAura.player:GiveCash(attacker, player:GetBounty(), "bounty hunting");
			player:RemoveBounty();
		end;
	else
		umsg.Start("aura_Death", player);
		umsg.End();
	end;
	
	if (damageInfo) then
		local miscellaneousDamage = damageInfo:IsBulletDamage() or damageInfo:IsFallDamage() or damageInfo:IsExplosionDamage();
		local meleeDamage = damageInfo:IsDamageType(DMG_CLUB) or damageInfo:IsDamageType(DMG_SLASH);
		
		if (miscellaneousDamage or meleeDamage) then
			self:PlayerDropRandomItems( player, player:GetRagdollEntity() );
		end;
	end;
end;

-- Called just before a player dies.
function openAura.schema:DoPlayerDeath(player, attacker, damageInfo)
	self:TiePlayer(player, false, true);
	
	player.beingSearched = nil;
	player.searching = nil;
end;

-- Called when a player's order item should be adjusted.
function openAura.schema:PlayerAdjustOrderItemTable(player, itemTable)
	if ( openAura.augments:Has(player, AUG_MERCANTILE) ) then
		itemTable.cost = itemTable.cost * 0.9;
	end;
end;

-- Called when a player's storage should close.
function openAura.schema:PlayerStorageShouldClose(player, storage)
	local entity = player:GetStorageEntity();
	
	if (player.searching and entity:IsPlayer() and !entity:GetSharedVar("tied") ) then
		return true;
	end;
end;

-- Called when a player attempts to fire a weapon.
function openAura.schema:PlayerCanFireWeapon(player, bIsRaised, weapon, bIsSecondary)
	if (bIsRaised and weapon:GetClass() != "aura_stealthcamo") then
		local stealthCamo = player:GetWeapon("aura_stealthcamo");
		local usingStealth = ( ValidEntity(stealthCamo) and stealthCamo:IsActivated() );
		
		if (usingStealth and player:GetVelocity():Length() <= 1) then
			return false;
		end;
	end;
end;

-- Called when a player's attribute has been updated.
function openAura.schema:PlayerAttributeUpdated(player, attributeTable, amount)
	local currentPoints = openAura.attributes:Get(player, attributeTable.uniqueID, true);
	
	if (!currentPoints) then
		return;
	end;
	
	if (currentPoints >= attributeTable.maximum) then
		if (attributeTable.uniqueID == ATB_ENDURANCE) then
			openAura.trophies:Progress(player, TRO_SNAKESKIN);
		elseif (attributeTable.uniqueID == ATB_DEXTERITY) then
			openAura.trophies:Progress(player, TRO_QUICKHANDS);
		elseif (attributeTable.uniqueID == ATB_AGILITY) then
			openAura.trophies:Progress(player, TRO_GONZALES);
		elseif (attributeTable.uniqueID == ATB_STRENGTH) then
			openAura.trophies:Progress(player, TRO_MIKETYSON);
		elseif (attributeTable.uniqueID == ATB_ACCURACY) then
			openAura.trophies:Progress(player, TRO_SHARPSHOOTER);
		elseif (attributeTable.uniqueID == ATB_STAMINA) then
			openAura.trophies:Progress(player, TRO_OLYMPICRUNNER);
		end;
	elseif (currentPoints >= 50) then
		if (attributeTable.uniqueID == ATB_ACROBATICS) then
			openAura.trophies:Progress(player, TRO_FIDDYACRO);
		end;
	end;
end;

-- Called just after a player spawns.
function openAura.schema:PostPlayerSpawn(player, lightSpawn, changeClass, firstSpawn)
	local skullMask = player:GetCharacterData("skullmask");
	local clothes = player:GetCharacterData("clothes");
	local team = player:Team();
	
	if (!lightSpawn) then
		player:SetCharacterData("stamina", 100);
		
		umsg.Start("aura_ClearEffects", player);
		umsg.End();
		
		player:SetSharedVar("disguise", NULL);
		player.cancelDisguise = nil;
		player.beingSearched = nil;
		player.searching = nil;
	end;
	
	if ( player:GetSharedVar("tied") ) then
		self:TiePlayer(player, true);
	end;
	
	if (skullMask) then
		local itemTable = openAura.item:Get("skull_mask");
		
		if ( itemTable and player:HasItem(itemTable.uniqueID) ) then
			openAura.player:CreateGear(player, "SkullMask", itemTable);
			
			player:SetSharedVar("skullMask", true);
			player:UpdateInventory(itemTable.uniqueID);
		else
			player:SetCharacterData("skullmask", nil);
		end;
	end;
	
	if (clothes) then
		local itemTable = openAura.item:Get(clothes);
		local team = player:Team();
		
		if ( itemTable and player:HasItem(itemTable.uniqueID) ) then
			self:PlayerWearClothes(player, itemTable);
		else
			player:SetCharacterData("clothes", nil);
		end;
	end;
end;

-- Called when a player's footstep sound should be played.
function openAura.schema:PlayerFootstep(player, position, foot, sound, volume, recipientFilter)
	local clothes = player:GetCharacterData("clothes");
	
	if (clothes) then
		local itemTable = openAura.item:Get(clothes);
		
		if (itemTable) then
			if ( player:IsRunning() or player:IsJogging() ) then
				if (itemTable.runSound) then
					if (type(itemTable.runSound) == "table") then
						sound = itemTable.runSound[ math.random(1, #itemTable.runSound) ];
					else
						sound = itemTable.runSound;
					end;
				end;
			elseif (itemTable.walkSound) then
				if (type(itemTable.walkSound) == "table") then
					sound = itemTable.walkSound[ math.random(1, #itemTable.walkSound) ];
				else
					sound = itemTable.walkSound;
				end;
			end;
		end;
	end;
	
	player:EmitSound(sound);
	
	return true;
end;

-- Called when a player throws a punch.
function openAura.schema:PlayerPunchThrown(player)
	player:ProgressAttribute(ATB_STRENGTH, 0.25, true);
end;

-- Called when a player punches an entity.
function openAura.schema:PlayerPunchEntity(player, entity)
	if ( entity:IsPlayer() or entity:IsNPC() ) then
		player:ProgressAttribute(ATB_STRENGTH, 1, true);
	else
		player:ProgressAttribute(ATB_STRENGTH, 0.5, true);
	end;
end;

-- Called when an entity has been breached.
function openAura.schema:EntityBreached(entity, activator)
	if ( openAura.entity:IsDoor(entity) ) then
		openAura.entity:OpenDoor(entity, 0, true, true);
		
		if ( IsValid(activator) ) then
			openAura.trophies:Progress(activator, TRO_BLOCKBUSTER);
		end;
	end;
end;

-- Called when a player takes damage.
function openAura.schema:PlayerTakeDamage(player, inflictor, attacker, hitGroup, damageInfo)
	local curTime = CurTime();
	local guild = player:GetGuild();
	
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
			
			if ( openAura.augments:Has(player, AUG_ADRENALINE) ) then
				local duration = 60;
				
				if ( openAura.augments:Has(player, AUG_LONGLASTER) ) then
					duration = duration / 2;
				end;
				
				openAura.player:SetAction(player, "die", duration, 1, function()
					if ( IsValid(player) and player:Alive() ) then
						openAura.player:SetRagdollState(player, RAGDOLL_NONE);
						player:SetHealth(10);
					end;
				end);
				
				player.nextDisconnect = curTime + duration + 30;
			else
				local duration = 60;
				
				if ( openAura.augments:Has(player, AUG_LONGLASTER) ) then
					duration = duration * 2;
				end;
				
				openAura.player:SetAction(player, "die", duration, 1, function()
					if ( IsValid(player) and player:Alive() ) then
						player:TakeDamage(player:Health() * 2, attacker, inflictor);
					end;
				end);
				
				player.nextDisconnect = curTime + duration + 30;
			end;
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
		
		if ( attacker:IsGood() and player:IsBad() ) then
			if ( openAura.augments:Has(attacker, AUG_BLOODDONOR) ) then
				local health = math.Round(damageInfo:GetDamage() * 0.1);
				
				if (health > 0) then
					attacker:SetHealth( math.Clamp( attacker:Health() + health, 0, attacker:GetMaxHealth() ) );
				end;
			end;
		end;
		
		if (guild and attacker:GetGuild() != guild) then
			for k, v in ipairs( _player.GetAll() ) do
				if (v:HasInitialized() and v:GetGuild() == guild) then
					umsg.Start("aura_TargetOutline", v);
						umsg.Entity(attacker);
					umsg.End();
				end;
			end;
		end;
		
		if ( damageInfo:IsBulletDamage() ) then
			if ( openAura.augments:Has(attacker, AUG_INCENDIARY) ) then
				if ( math.random() >= 0.9 and player:IsBad() ) then
					if ( !player:IsOnFire() ) then
						player:Ignite(5, 0);
					end;
				end;
			elseif ( openAura.augments:Has(attacker, AUG_FROZENROUNDS) ) then
				if ( math.random() >= 0.9 and player:IsGood() ) then
					if ( !player:IsRagdolled() ) then
						openAura.player:SetRagdollState(player, RAGDOLL_FALLENOVER, 5);
						
						local ragdollEntity = player:GetRagdollEntity();
						
						if ( IsValid(ragdollEntity) ) then
							openAura.entity:StatueRagdoll(ragdollEntity);
						end;
					end;
				end;
			end;
		end;
	end;
	
	if (!player.nextDisconnect or curTime > player.nextDisconnect + 60) then
		player.nextDisconnect = curTime + 60;
	end;
end;

-- Called when a player's limb damage is healed.
function openAura.schema:PlayerLimbDamageHealed(player, hitGroup, amount)
	if (hitGroup == HITGROUP_HEAD) then
		player:BoostAttribute("Limb Damage", ATB_DEXTERITY, false);
	elseif (hitGroup == HITGROUP_CHEST or hitGroup == HITGROUP_STOMACH) then
		player:BoostAttribute("Limb Damage", ATB_ENDURANCE, false);
	elseif (hitGroup == HITGROUP_LEFTLEG or hitGroup == HITGROUP_RIGHTLEG) then
		player:BoostAttribute("Limb Damage", ATB_ACROBATICS, false);
		player:BoostAttribute("Limb Damage", ATB_AGILITY, false);
	elseif (hitGroup == HITGROUP_LEFTARM or hitGroup == HITGROUP_RIGHTARM) then
		player:BoostAttribute("Limb Damage", ATB_STRENGTH, false);
	end;
end;

-- Called when a player's limb damage is reset.
function openAura.schema:PlayerLimbDamageReset(player)
	player:BoostAttribute("Limb Damage", nil, false);
end;

-- Called when a player's limb takes damage.
function openAura.schema:PlayerLimbTakeDamage(player, hitGroup, damage)
	local limbDamage = openAura.limb:GetDamage(player, hitGroup);
	
	if (hitGroup == HITGROUP_HEAD) then
		player:BoostAttribute("Limb Damage", ATB_DEXTERITY, -limbDamage);
	elseif (hitGroup == HITGROUP_CHEST or hitGroup == HITGROUP_STOMACH) then
		player:BoostAttribute("Limb Damage", ATB_ENDURANCE, -limbDamage);
	elseif (hitGroup == HITGROUP_LEFTLEG or hitGroup == HITGROUP_RIGHTLEG) then
		player:BoostAttribute("Limb Damage", ATB_ACROBATICS, -limbDamage);
		player:BoostAttribute("Limb Damage", ATB_AGILITY, -limbDamage);
	elseif (hitGroup == HITGROUP_LEFTARM or hitGroup == HITGROUP_RIGHTARM) then
		player:BoostAttribute("Limb Damage", ATB_STRENGTH, -limbDamage);
	end;
end;

-- A function to scale damage by hit group.
function openAura.schema:PlayerScaleDamageByHitGroup(player, attacker, hitGroup, damageInfo, baseDamage)
	local endurance = openAura.attributes:Fraction(player, ATB_ENDURANCE, 0.4, 0.5);
	local clothes = player:GetCharacterData("clothes");
	local curTime = CurTime();
	
	if ( hitGroup == HITGROUP_HEAD and openAura.augments:Has(player, AUG_HEADPLATE) ) then
		if (math.random() <= 0.5) then
			damageInfo:SetDamage(0);
		end;
	end;
	
	if (damageInfo:GetDamage() > 0 and hitGroup == HITGROUP_HEAD) then
		if ( attacker:IsPlayer() and openAura.augments:Has(attacker, AUG_RECYCLER) ) then
			if (math.random() <= 0.5) then
				attacker:SetHealth( math.Clamp( attacker:Health() + (damageInfo:GetDamage() / 2), 0, attacker:GetMaxHealth() ) );
			end;
		end;
	end;
	
	if ( damageInfo:IsDamageType(DMG_CLUB) or damageInfo:IsDamageType(DMG_SLASH) ) then
		if ( openAura.augments:Has(player, AUG_BLUNTDEFENSE) ) then
			damageInfo:ScaleDamage(0.75);
		end;
	end;
	
	if (attacker:GetClass() == "entityflame") then
		if (!player.nextTakeBurnDamage or curTime >= player.nextTakeBurnDamage) then
			player.nextTakeBurnDamage = curTime + 0.1;
			
			damageInfo:SetDamage(1);
		else
			damageInfo:SetDamage(0);
		end;
	end;
	
	if ( damageInfo:IsFallDamage() ) then
		if ( openAura.augments:Has(player, AUG_LEGBRACES) ) then
			damageInfo:ScaleDamage(0.5);
		end;
	else
		damageInfo:ScaleDamage(1.25 - endurance);
	end;
	
	if (clothes) then
		local itemTable = openAura.item:Get(clothes);
		
		if (itemTable) then
			if (itemTable.armorScale) then
				damageInfo:ScaleDamage( 1 - (itemTable.armorScale * 0.6) );
			end;
			
			if (itemTable.armorLevel) then
				damageInfo:ScaleDamage( 1.05 - (itemTable.armorLevel * 0.05) );
			end;
		end;
	end;
	
	if ( attacker:IsPlayer() and attacker:IsBad() and player:IsGood() ) then
		if ( openAura.augments:Has(attacker, AUG_HOLLOWPOINT) ) then
			damageInfo:ScaleDamage(1.1);
		end;
	end;
	
	if (openAura.player:GetAction(player) == "die") then
		if ( openAura.augments:Has(player, AUG_BORNSURVIVOR) ) then
			damageInfo:ScaleDamage(0);
		end;
	end;
	
	if ( attacker:IsPlayer() ) then
		local itemTable = openAura.item:GetWeapon( attacker:GetActiveWeapon() );
		
		if (itemTable and itemTable.weaponLevel) then
			damageInfo:ScaleDamage( 0.8 + (0.2 * itemTable.weaponLevel) );
		end;
	end;
end;

-- Called when an entity takes damage.
function openAura.schema:EntityTakeDamage(entity, inflictor, attacker, amount, damageInfo)
	local curTime = CurTime();
	local player = openAura.entity:GetPlayer(entity);
	
	if (player) then
		if (!player.nextEnduranceTime or CurTime() > player.nextEnduranceTime) then
			player:ProgressAttribute(ATB_ENDURANCE, math.Clamp(damageInfo:GetDamage(), 0, 75) / 10, true);
			player.nextEnduranceTime = CurTime() + 2;
		end;
	end;
	
	if ( attacker:IsPlayer() ) then
		local weapon = openAura.player:GetWeaponClass(attacker);
		
		if (weapon == "weapon_crowbar") then
			if ( entity:IsPlayer() ) then
				damageInfo:ScaleDamage(0.1);
			else
				damageInfo:ScaleDamage(0.8);
			end;
		end;
		
		if (entity:GetClass() == "prop_physics") then
			for k, v in ipairs( ents.FindByClass("aura_propguarder") ) do
				if (entity:GetPos():Distance( v:GetPos() ) < 512) then
					damageInfo:ScaleDamage(0.5);
					
					return;
				end;
			end;
			
			if ( damageInfo:IsBulletDamage() ) then
				damageInfo:ScaleDamage(0.5);
			end;
			
			local boundingRadius = entity:BoundingRadius() * 12;
			entity.health = entity.health or boundingRadius;
			entity.health = math.max(entity.health - damageInfo:GetDamage(), 0);
			
			local blackness = (255 / boundingRadius) * entity.health;
			entity:SetColor(blackness, blackness, blackness, 255);
			
			if (entity.health == 0 and !entity.isDead) then
				if ( entity:GetOwnerKey() != attacker:QueryCharacter("key") ) then
					openAura.trophies:Progress(attacker, AUG_HOOLIGAN);
				end;
				
				openAura.entity:Decay(entity, 5);
				
				entity:SetCollisionGroup(COLLISION_GROUP_WEAPON);
				entity:Ignite(5, 0);
				entity.isDead = true;
			end;
		end;
		
		for k, v in ipairs( ents.FindByClass("aura_doorguarder") ) do
			if (entity:GetPos():Distance( v:GetPos() ) < 256) then
				local owner = v:GetPlayer();
				
				if ( IsValid(owner) and openAura.augments:Has(owner, AUG_REVERSEMAN) ) then
					attacker:TakeDamageInfo(damageInfo);
				end;
				
				return;
			end;
		end;
		
		if ( damageInfo:IsBulletDamage() and !IsValid(entity.breach) ) then
			if (string.lower( entity:GetClass() ) == "prop_door_rotating") then
				if ( !openAura.entity:IsDoorFalse(entity) ) then
					local damagePosition = damageInfo:GetDamagePosition();
					
					if (entity:WorldToLocal(damagePosition):Distance( Vector(-1.0313, 41.8047, -8.1611) ) <= 8) then
						local effectData = EffectData();
						
						effectData:SetStart(damagePosition);
						effectData:SetOrigin(damagePosition);
						effectData:SetScale(8);
						
						util.Effect("GlassImpact", effectData, true, true);
						
						openAura.entity:OpenDoor( entity, 0, true, true, attacker:GetPos() );
					end;
				end;
			end;
		end;
	end;
end;