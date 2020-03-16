--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

-- Called when Clockwork has initialized.
function Severance:ClockworkInitialized()
	for k, v in pairs(Clockwork.item:GetAll()) do
		if (!v("isBaseItem") and !v("isRareItem")) then
			v.business = true;
			v.access = "y";
			v.batch = 1;
		end;
	end;
end;

-- Called when a player attempts to switch to a character.
function Severance:PlayerCanSwitchCharacter(player, character)
	if (player:GetCharacterData("PermaKilled")) then
		return true;
	end;
end;

-- Called when a player's character data should be restored.
function Severance:PlayerRestoreCharacterData(player, data)
	if (!data["Hunger"]) then
		data["Hunger"] = 100;
	end;

	if (!data["Thirst"]) then
		data["Thirst"] = 100;
	end;

	if (!data["Energy"]) then
		data["Energy"] = 100;
	end;
end;


-- Called when a player's character has loaded.
function Severance:PlayerCharacterLoaded(player)
	if !player:GetCharacterData("Hunger") then
		player:SetCharacterData("Hunger", 100);
	end;

	if !player:GetCharacterData("Thirst") then
		player:SetCharacterData("Thirst", 100);
	end;

	if !player:GetCharacterData("Energy") then
		player:SetCharacterData("Energy", 100);
	end;

	player:SetSharedVar("PermaKilled", false);
	player:SetSharedVar("IsTied", 0);
	player:SetSharedVar("Hunger", player:GetCharacterData("Hunger"));
	player:SetSharedVar("Thirst", player:GetCharacterData("Thirst"));
	player:SetSharedVar("Energy", player:GetCharacterData("Energy"));
end;

-- Called when a player's default inventory is needed.
function Severance:GetPlayerDefaultInventory(player, character, inventory)
	if (character.faction == FACTION_CDF) then
		local instances = {};
		
		instances["kevlar"] = 1;
		instances["backpack"] = 2;
		instances["rcs_p228"] = 1;
		instances["ammo_smg1"] = 4;
		instances["rcs_sg552"] = 1;
		instances["ammo_pistol"] = 3;
		instances["ceda_uniform"] = 1;
		instances["storage_jacket"] = 1;
		instances["handheld_radio"] = 1;
		
		for k, v in pairs(instances) do
			for i = 1, v do
				Clockwork.inventory:AddInstance(
					inventory, Clockwork.item:CreateInstance(k)
				);
			end;
		end;
	end;
end;

-- Called each frame that a player is dead.
function Severance:PlayerDeathThink(player)
	if (player:GetCharacterData("PermaKilled")) then
		return true;
	end;
end;

-- Called when a player's death info should be adjusted.
function Severance:PlayerAdjustDeathInfo(player, info)
	if (player:GetCharacterData("PermaKilled")) then
		info.spawnTime = 0;
	end;
end;

-- Called when a player attempts to use a lowered weapon.
function Severance:PlayerCanUseLoweredWeapon(player, weapon, secondary)
	if (secondary and (weapon.SilenceTime or weapon.PistolBurst)) then
		return true;
	end;
end;

-- Called when Clockwork has loaded all of the entities.
function Severance:ClockworkInitPostEntity()
	self:LoadBelongings();
	self:LoadRadios();
end;

-- Called just after data should be saved.
function Severance:PostSaveData()
	self:SaveBelongings();
	self:SaveRadios();
end;

-- Called when a player switches their flashlight on or off.
function Severance:PlayerSwitchFlashlight(player, bIsOn)
	if (bIsOn and player:GetSharedVar("IsTied") != 0) then
		return false;
	end;
end;

-- Called when a player's storage should close.
function Severance:PlayerStorageShouldClose(player, storage)
	local entity = player:GetStorageEntity();
	
	if (player.cwIsSearchingChar and entity:IsPlayer() and entity:GetSharedVar("IsTied") == 0) then
		return true;
	end;
end;

-- Called when a player attempts to spray their tag.
function Severance:PlayerSpray(player)
	if (!player:HasItemByID("spray_can") or player:GetSharedVar("IsTied") != 0) then
		return true;
	end;
end;

-- Called when a player presses F3.
function Severance:ShowSpare1(player)
	Clockwork.player:RunClockworkCommand(player, "InvAction", "use", "zip_tie");
end;

-- Called when a player presses F4.
function Severance:ShowSpare2(player)
	Clockwork.player:RunClockworkCommand(player, "CharSearch");
end;

-- Called when a player's drop weapon info should be adjusted.
function Severance:PlayerAdjustDropWeaponInfo(player, info)
	if (Clockwork.player:GetWeaponClass(player) == info.itemTable("weaponClass")) then
		info.position = player:GetShootPos();
		info.angles = player:GetAimVector():Angle();
	else
		local gearTable = {
			Clockwork.player:GetGear(player, "Throwable"),
			Clockwork.player:GetGear(player, "Secondary"),
			Clockwork.player:GetGear(player, "Primary"),
			Clockwork.player:GetGear(player, "Melee")
		};
		
		for k, v in pairs(gearTable) do
			if (IsValid(v)) then
				local gearItemTable = v:GetItemTable();
				
				if (gearItemTable.itemID == info.itemTable("itemID")) then
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

-- Called when a player has been given a weapon.
function Severance:PlayerGivenWeapon(player, class, itemTable)
	if (Clockwork.item:IsWeapon(itemTable) and !itemTable:IsFakeWeapon()) then
		if (!itemTable:IsMeleeWeapon() and !itemTable:IsThrowableWeapon()) then
			if (itemTable("weight") <= 2) then
				Clockwork.player:CreateGear(player, "Secondary", itemTable);
			else
				Clockwork.player:CreateGear(player, "Primary", itemTable);
			end;
		elseif (itemTable:IsThrowableWeapon()) then
			Clockwork.player:CreateGear(player, "Throwable", itemTable);
		else
			Clockwork.player:CreateGear(player, "Melee", itemTable);
		end;
	end;
end;

-- Called when a player spawns an object.
function Severance:PlayerSpawnObject(player)
	if (player:GetSharedVar("IsTied") != 0) then
		Clockwork.player:Notify(player, "You cannot do this action at the moment!");
		
		return false;
	end;
end;

-- Called when a player attempts to breach an entity.
function Severance:PlayerCanBreachEntity(player, entity)
	if (Clockwork.entity:IsDoor(entity)) then
		if (!Clockwork.entity:IsDoorFalse(entity)) then
			return true;
		end;
	end;
end;

-- Called when a player attempts to use the radio.
function Severance:PlayerCanRadio(player, text, listeners, eavesdroppers)
	if (player:HasItemByID("handheld_radio")) then
		if (!player:GetCharacterData("Frequency")) then
			Clockwork.player:Notify(player, "You need to set the radio frequency first!");
			
			return false;
		end;
	else
		Clockwork.player:Notify(player, "You do not own a radio!");
		
		return false;
	end;
end;

-- Called when a player attempts to use an entity in a vehicle.
function Severance:PlayerCanUseEntityInVehicle(player, entity, vehicle)
	if (entity:IsPlayer() or Clockwork.entity:IsPlayerRagdoll(entity)) then
		return true;
	end;
end;

-- Called when a player presses a key.
function Severance:KeyPress(player, key)
	if (key == IN_USE) then
		local untieTime = Severance:GetDexterityTime(player);
		local eyeTrace = player:GetEyeTraceNoCursor();
		local target = eyeTrace.Entity;
		local entity = target;
		
		if (IsValid(target)) then
			target = Clockwork.entity:GetPlayer(target);
			
			if (target and player:GetSharedVar("IsTied") == 0) then
				if (target:GetShootPos():Distance(player:GetShootPos()) <= 192) then
					if (target:GetSharedVar("IsTied") != 0 and target:Alive()) then
						Clockwork.player:SetAction(player, "untie", untieTime);
						
						Clockwork.player:EntityConditionTimer(player, target, entity, untieTime, 192, function()
							return player:Alive() and target:Alive() and !player:IsRagdolled() and player:GetSharedVar("IsTied") == 0;
						end, function(success)
							if (success) then
								self:TiePlayer(target, false);
								
								player:ProgressAttribute(ATB_DEXTERITY, 15, true);
							end;
							
							Clockwork.player:SetAction(player, "untie", false);
						end);
					end;
				end;
			end;
		end;
	elseif (key == IN_RELOAD) then
		if (player:GetNetworkedVar("GhostMode", true)) then
			self:ToggleGhost(player);

			player.cwBreathSound = CreateSound(player, "npc/zombie_poison/pz_breathe_loop1.wav")
			player.cwBreathSound:Play()
			player.cwBreathSound:ChangePitch(60, 0)
			player.cwBreathSound:ChangeVolume(0.3, 0)
		end;
	end;
end;

-- Called when a player's character screen info should be adjusted.
function Severance:PlayerAdjustCharacterScreenInfo(player, character, info)
	if (character.data["PermaKilled"]) then
		info.details = "This character is permanently killed.";
	end;
end;

-- Called when a chat box message has been added.
function Severance:ChatBoxMessageAdded(info)
	if (info.class == "ic") then
		local eavesdroppers = {};
		local talkRadius = Clockwork.config:Get("talk_radius"):Get();
		local listeners = {};
		local players = cwPlayer.GetAll();
		local radios = ents.FindByClass("cw_radio");
		local data = {};
		
		for k, v in ipairs(radios) do
			if (!v:IsOff() and info.speaker:GetPos():Distance(v:GetPos()) <= 80) then
				local frequency = v:GetSharedVar("Frequency");
				
				if (frequency != "") then
					info.shouldSend = false;
					info.listeners = {};
					data.frequency = frequency;
					data.position = v:GetPos();
					data.entity = v;
					
					break;
				end;
			end;
		end;
		
		if (IsValid(data.entity) and data.frequency != "") then
			for k, v in ipairs(players) do
				if (v:HasInitialized() and v:Alive() and !v:IsRagdolled(RAGDOLL_FALLENOVER)) then
					if ((v:GetCharacterData("Frequency") == data.frequency
					and v:GetSharedVar("IsTied") == 0 and v:HasItemByID("handheld_radio"))
					or info.speaker == v) then
						listeners[v] = v;
					elseif (v:GetPos():Distance(data.position) <= talkRadius) then
						eavesdroppers[v] = v;
					end;
				end;
			end;
			
			for k, v in ipairs(radios) do
				local radioPosition = v:GetPos();
				local radioFrequency = v:GetSharedVar("Frequency");
				
				if (!v:IsOff() and radioFrequency == data.frequency) then
					for k2, v2 in ipairs(players) do
						if (v2:HasInitialized() and !listeners[v2] and !eavesdroppers[v2]) then
							if (v2:GetPos():Distance(radioPosition) <= (talkRadius * 2)) then
								eavesdroppers[v2] = v2;
							end;
						end;
						
						break;
					end;
				end;
			end;
			
			if (table.Count(listeners) > 0) then
				Clockwork.chatBox:Add(listeners, info.speaker, "radio", info.text);
			end;
			
			if (table.Count(eavesdroppers) > 0) then
				Clockwork.chatBox:Add(eavesdroppers, info.speaker, "radio_eavesdrop", info.text);
			end;
		end;
	end;
end;

-- Called when a player has used their radio.
function Severance:PlayerRadioUsed(player, text, listeners, eavesdroppers)
	local newEavesdroppers = {};
	local talkRadius = Clockwork.config:Get("talk_radius"):Get() * 2;
	local frequency = player:GetCharacterData("Frequency");
	
	for k, v in ipairs(ents.FindByClass("cw_radio")) do
		local radioPosition = v:GetPos();
		local radioFrequency = v:GetSharedVar("Frequency");
		
		if (!v:IsOff() and radioFrequency == frequency) then
			for k2, v2 in ipairs(cwPlayer.GetAll()) do
				if (v2:HasInitialized() and !listeners[v2] and !eavesdroppers[v2]) then
					if (v2:GetPos():Distance(radioPosition) <= talkRadius) then
						newEavesdroppers[v2] = v2;
					end;
				end;
				
				break;
			end;
		end;
	end;
	
	if (table.Count(newEavesdroppers) > 0) then
		Clockwork.chatBox:Add(newEavesdroppers, player, "radio_eavesdrop", text);
	end;
end;

-- Called when a player's radio info should be adjusted.
function Severance:PlayerAdjustRadioInfo(player, info)
	for k, v in ipairs(cwPlayer.GetAll()) do
		if (v:HasInitialized() and v:HasItemByID("handheld_radio")) then
			if (v:GetCharacterData("Frequency") == player:GetCharacterData("Frequency")) then
				if (v:GetSharedVar("IsTied") == 0) then
					info.listeners[v] = v;
				end;
			end;
		end;
	end;
end;

-- Called when a player has been bIsHealed.
function Severance:PlayerHealed(player, healer, itemTable)
	if (itemTable("uniqueID") == "health_vial") then
		healer:BoostAttribute(itemTable("name"), ATB_DEXTERITY, 2, 600);
		healer:ProgressAttribute(ATB_MEDICAL, 15, true);
	elseif (itemTable("uniqueID") == "health_kit") then
		healer:BoostAttribute(itemTable("name"), ATB_DEXTERITY, 3, 600);
		healer:ProgressAttribute(ATB_MEDICAL, 25, true);
	elseif (itemTable("uniqueID") == "bandage") then
		healer:BoostAttribute(itemTable("name"), ATB_DEXTERITY, 1, 600);
		healer:ProgressAttribute(ATB_MEDICAL, 5, true);
	end;
end;

-- Called when a player has been unragdolled.
function Severance:PlayerUnragdolled(player, state, ragdoll)
	Clockwork.player:SetAction(player, "die", false);
end;

-- Called when a player has been ragdolled.
function Severance:PlayerRagdolled(player, state, ragdoll)
	Clockwork.player:SetAction(player, "die", false);
end;

-- Called at an interval while a player is connected.
function Severance:PlayerThink(player, curTime, infoTable)
	local bIsRagdolled = player:IsRagdolled();
	local bIsAlive = player:Alive();
	
	if (bIsAlive and !bIsRagdolled) then
		if (!player:InVehicle() and player:GetMoveType() == MOVETYPE_WALK) then
			if (player:IsInWorld()) then
				if (!player:IsOnGround()) then
					player:ProgressAttribute(ATB_ACROBATICS, 0.25, true);
				elseif (infoTable.isRunning) then
					player:ProgressAttribute(ATB_AGILITY, 0.125, true);
				elseif (infoTable.isJogging) then
					player:ProgressAttribute(ATB_AGILITY, 0.0625, true);
				end;
			end;
		end;
	end;
	
	if (player:WaterLevel() >= 2) then
		player:TakeDamageInfo(
			Clockwork.kernel:FakeDamageInfo(2, GetWorldEntity(), GetWorldEntity(), player:GetShootPos(), DMG_RADIATION, 1)
		);
	end;
	
	local acrobatics = Clockwork.attributes:Fraction(player, ATB_ACROBATICS, 100, 50);
	local strength = Clockwork.attributes:Fraction(player, ATB_STRENGTH, 8, 4);
	local agility = Clockwork.attributes:Fraction(player, ATB_AGILITY, 50, 25);
	
	local clothesItem = player:GetClothesItem();
	
	if (clothesItem and clothesItem.pocketSpace) then
		infoTable.inventoryWeight = infoTable.inventoryWeight + clothesItem.pocketSpace;
	end;
	
	infoTable.inventoryWeight = infoTable.inventoryWeight + strength;
	infoTable.jumpPower = infoTable.jumpPower + acrobatics;
	infoTable.runSpeed = infoTable.runSpeed + agility;
	
	if (self:PlayerIsZombie(player) and !player:GetNetworkedVar("GhostMode", true)) then
		infoTable.walkSpeed = 40;
		infoTable.runSpeed = 230;

		if (!player.nextEmitSound or curTime <= player.nextEmitSound) then
			player.nextEmitSound = math.random(5, 15);
			player:EmitSound("npc/zombie/zombie_voice_idle"..math.random(2, 7)..".wav", 100, 30);
		end;
	elseif (player:GetNetworkedVar("GhostMode", true)) then
		infoTable.walkSpeed = 700
	end;
	
	--[[
		This is a test system for implementing zombie spawns in a way that
		doesn't mean the server administrator has to set them.
	--]]
	if (!player.cwNextZombieSpawn or curTime >= player.cwNextZombieSpawn) then
		player.cwNextZombieSpawn = curTime + 60;
		
		if (#Severance.zombieSpawns > 200) then
			table.remove(Severance.zombieSpawns, 1);
		end;
		
		table.insert(Severance.zombieSpawns, player:GetPos());
	end;

--[[-------------------------------------------------------------------------
	Unsure if it's desirable to allow owners to set hunger/thirst/energy intervals entirely on their own, but I just copy pasted this (probably)
	inefficient function over a few times just for speed. It can and probably will be changed to all be wrapped under one timer in the future.
	--REMOVE COMMENT WHEN/IF SEVERANCE GOES TO SALE--
---------------------------------------------------------------------------]]

	local HungerTime = Clockwork.config:Get("hunger_interval"):Get()

	if (self:CheckHunger(player) <= -1) then
		self:SetHunger(player, 1);
	end;

	if (!player.NextHunger or curTime >= player.NextHunger and self:CheckHunger(player) >= 1) then
		player.NextHunger = curTime + HungerTime;
		self:SetHunger(player, self:CheckHunger(player) - 1);
	end;

	local ThirstTime = Clockwork.config:Get("thirst_interval"):Get()

	if (self:CheckThirst(player) <= -1) then
		self:SetThirst(player, 1);
	end;

	if (!player.NextThirst or curTime >= player.NextThirst and self:CheckThirst(player) >= 1) then
		player.NextThirst = curTime + ThirstTime;
		self:SetThirst(player, self:CheckThirst(player) - 1);
	end;

	local EnergyTime = Clockwork.config:Get("energy_interval"):Get()

	if (self:CheckEnergy(player) <= -1) then
		self:SetEnergy(player, 1);
	end;

	if (!player.NextEnergy or curTime >= player.NextEnergy and self:CheckEnergy(player) >= 1) then
		player.NextEnergy = curTime + EnergyTime;
		self:SetEnergy(player, self:CheckEnergy(player) - 1);
	end;
end;

-- Called every tick that the game is running.
function Severance:Tick()
	local curTime = CurTime();
	
	if (curTime < self.nextZombieSpawn) then
		return;
	end;
	
	local minSpawn = Clockwork.config:Get("min_spawn_interval"):Get();
	local maxSpawn = Clockwork.config:Get("max_spawn_interval"):Get()

	if (minSpawn >= maxSpawn) then
		self.nextZombieSpawn = curTime + 60;
		return Clockwork.player:NotifyAdmins("s", "The minimum spawn interval should not be higher than the maximum spawn interval! Change it in the config for zombies to spawn properly!");
	end;

	self.nextZombieSpawn = curTime + math.random(minSpawn, maxSpawn);
	
	local zombieCount = #ents.FindByClass("cw_zombie_nextbot");
	local maxZombies = Clockwork.config:Get("max_zombies"):Get();

	if (zombieCount >= maxZombies) then return; end;
	
	local zombiesToMake = (maxZombies - zombieCount);
	local numSpawnPoints = #self.zombieSpawns;
	local spawnChance = 1 / numSpawnPoints;
	
	for i = 1, numSpawnPoints do
		if (math.random() <= spawnChance) then
			local position = self.zombieSpawns[i];
			local shouldCreate = true;
			
			for k, v in ipairs(player.GetAll()) do
				if (v:GetPos():Distance(position) < 512 or Clockwork.player:CanSeePosition(v, position)) then
					shouldCreate = false;
					break;
				end;
			end;
			
			if (shouldCreate) then
				local entity = ents.Create("cw_zombie_nextbot");
					entity:SelectRandomModel();
					entity:SetPos(position)
					entity:Spawn();
					entity:Activate();

				zombiesToMake = zombiesToMake - 1;
			end;
		end;
		
		if (zombiesToMake == 0) then break; end;
	end;
end;

-- Called when a player attempts to delete a character.
function Severance:PlayerCanDeleteCharacter(player, character)
	if (character.data["PermaKilled"]) then
		return true;
	end;
end;

-- Called when a player attempts to use a character.
function Severance:PlayerCanUseCharacter(player, character)
	if (character.data["PermaKilled"]) then
		return character.name.." is permanently killed and cannot be used!";
	end;
end;

-- Called when attempts to use a command.
function Severance:PlayerCanUseCommand(player, commandTable, arguments)
	if (player:GetSharedVar("IsTied") != 0) then
		local blacklisted = {
			"OrderShipment",
			"Radio"
		};
		
		if (table.HasValue(blacklisted, commandTable.name)) then
			Clockwork.player:Notify(player, "You cannot use this command when you are tied!");
			
			return false;
		end;
	end;
end;

-- Called when a player attempts to change class.
function Severance:PlayerCanChangeClass(player, class)
	if (player:GetSharedVar("IsTied") != 0) then
		Clockwork.player:Notify(player, "You cannot change classes when you are tied!");
		
		return false;
	end;
end;

-- Called when death attempts to clear a player's recognised names.
function Severance:PlayerCanDeathClearRecognisedNames(player, attacker, damageInfo) return false; end;

-- Called when death attempts to clear a player's name.
function Severance:PlayerCanDeathClearName(player, attacker, damageInfo) return false; end;

-- Called when a player attempts to use an entity.
function Severance:PlayerUse(player, entity)
	local curTime = CurTime();
	
	if (entity.cwIsBustedDown) then
		return false;
	end;
	
	if (player:GetSharedVar("IsTied") != 0) then
		if (entity:IsVehicle()) then
			return;
		end;
		
		if (!player.cwNextTieNotice or player.cwNextTieNotice < CurTime()) then
			Clockwork.player:Notify(player, "You cannot use that when you are tied!");
			
			player.cwNextTieNotice = CurTime() + 2;
		end;
		
		return false;
	end;
end;

-- Called when a player attempts to destroy an item.
function Severance:PlayerCanDestroyItem(player, itemTable, bNoMsg)
	if (player:GetSharedVar("IsTied") != 0) then
		if (!bNoMsg) then
			Clockwork.player:Notify(player, "You cannot destroy items when you are tied!");
		end;
		
		return false;
	end;
end;

-- Called when a player attempts to drop an item.
function Severance:PlayerCanDropItem(player, itemTable, bNoMsg)
	if (player:GetSharedVar("IsTied") != 0) then
		if (!bNoMsg) then
			Clockwork.player:Notify(player, "You cannot drop items when you are tied!");
		end;
		
		return false;
	end;
end;

-- Called when a player attempts to use an item.
function Severance:PlayerCanUseItem(player, itemTable, bNoMsg)
	if (player:GetSharedVar("IsTied") != 0) then
		if (!bNoMsg) then
			Clockwork.player:Notify(player, "You cannot use items when you are tied!");
		end;
		
		return false;
	end;
	
	if (Clockwork.item:IsWeapon(itemTable) and !itemTable:IsFakeWeapon()) then
		local isThrowableWeapon = nil;
		local secondaryWeapon = nil;
		local primaryWeapon = nil;
		local isMeleeWeapon = nil;
		local fault = nil;
		
		for k, v in ipairs(player:GetWeapons()) do
			local itemTable = Clockwork.item:GetByWeapon(v);
			
			if (itemTable and !itemTable:IsFakeWeapon()) then
				if (!itemTable:IsMeleeWeapon() and !itemTable:IsThrowableWeapon()) then
					if (itemTable("weight") <= 2) then
						secondaryWeapon = true;
					else
						primaryWeapon = true;
					end;
				elseif (itemTable:IsThrowableWeapon()) then
					isThrowableWeapon = true;
				else
					isMeleeWeapon = true;
				end;
			end;
		end;
		
		if (!itemTable:IsMeleeWeapon() and !itemTable:IsThrowableWeapon()) then
			if (itemTable("weight") <= 2) then
				if (secondaryWeapon) then
					fault = "You cannot use another secondary weapon!";
				end;
			elseif (primaryWeapon) then
				fault = "You cannot use another secondary weapon!";
			end;
		elseif (itemTable:IsThrowableWeapon()) then
			if (isThrowableWeapon) then
				fault = "You cannot use another throwable weapon!";
			end;
		elseif (isMeleeWeapon) then
			fault = "You cannot use another melee weapon!";
		end;
		
		if (fault) then
			if (!bNoMsg) then
				Clockwork.player:Notify(player, fault);
			end;
			
			return false;
		end;
	end;
end;

-- Called when a player uses an item.
function Severance:PlayerUseItem(player, itemTable, itemEntity)
	if (itemTable["HungerAmount"]) then
		self:SetHunger(player, self:CheckHunger(player) + itemTable["HungerAmount"]);
	end;

	if (itemTable["ThirstAmount"]) then
		self:SetThirst(player, self:CheckThirst(player) + itemTable["ThirstAmount"]);
	end;

	if (itemTable["EnergyAmount"]) then
		self:SetEnergy(player, self:CheckEnergy(player) + itemTable["EnergyAmount"]);
	end;
end;

-- Called when chat box info should be adjusted.
function Severance:ChatBoxAdjustInfo(info)
	if (IsValid(info.speaker) and info.speaker:HasInitialized()) then
		if (info.class != "ooc" and info.class != "looc") then
			if (IsValid(info.speaker) and info.speaker:HasInitialized()) then
				if (string.sub(info.text, 1, 1) == "?") then
					info.text = string.sub(info.text, 2);
					info.data.anon = true;
				end;
			end;
		end;
	end;
end;

-- Called when a player destroys generator.
function Severance:PlayerDestroyGenerator(player, entity, generator)
	Clockwork.player:GiveCash(player, generator.cash / 4, "destroying a "..string.lower(generator.name));
end;

-- Called when an entity's menu option should be handled.
function Severance:EntityHandleMenuOption(player, entity, option, arguments)
	if (entity:GetClass() == "prop_ragdoll" and arguments == "cwCorpseLoot") then
		if (!entity.cwInventory) then entity.cwInventory = {}; end;
		if (!entity.cwCash) then entity.cwCash = 0; end;
		
		local entityPlayer = Clockwork.entity:GetPlayer(entity);
		
		if (!entityPlayer or !entityPlayer:Alive()) then
			player:EmitSound("physics/body/body_medium_impact_soft"..math.random(1, 7)..".wav");
			
			Clockwork.storage:Open(player, {
				name = "Corpse",
				cash = entity.cwCash,
				weight = 8,
				entity = entity,
				distance = 192,
				inventory = entity.cwInventory,
				OnGiveCash = function(player, storageTable, cash)
					entity.cwCash = storageTable.cash;
				end,
				OnTakeCash = function(player, storageTable, cash)
					entity.cwCash = storageTable.cash;
				end
			});
		end;
	elseif (entity:GetClass() == "cw_belongings" and arguments == "cwBelongingsOpen") then
		player:EmitSound("physics/body/body_medium_impact_soft"..math.random(1, 7)..".wav");
		
		Clockwork.storage:Open(player, {
			name = "Belongings",
			cash = entity.cwCash,
			weight = 100,
			entity = entity,
			distance = 192,
			inventory = entity.cwInventory,
			isOneSided = true,
			OnGiveCash = function(player, storageTable, cash)
				entity.cwCash = storageTable.cash;
			end,
			OnTakeCash = function(player, storageTable, cash)
				entity.cwCash = storageTable.cash;
			end,
			OnClose = function(player, storageTable, entity)
				if (IsValid(entity)) then
					if ((!entity.cwInventory and !entity.cwCash)
					or (table.Count(entity.cwInventory) == 0 and entity.cwCash == 0)) then
						entity:Explode(entity:BoundingRadius() * 2);
						entity:Remove();
					end;
				end;
			end,
			CanGiveItem = function(player, storageTable, itemTable)
				return false;
			end
		});
	elseif (entity:GetClass() == "cw_breach") then
		entity:CreateDummyBreach();
		entity:BreachEntity(player);
	elseif (entity:GetClass() == "cw_radio") then
		if (option == "Set Frequency" and type(arguments) == "string") then
			if (string.find(arguments, "^%d%d%d%.%d$")) then
				local start, finish, decimal = string.match(arguments, "(%d)%d(%d)%.(%d)");
				
				start = tonumber(start);
				finish = tonumber(finish);
				decimal = tonumber(decimal);
				
				if (start == 1 and finish > 0 and finish < 10 and decimal > 0 and decimal < 10) then
					entity:SetFrequency(arguments);
					
					Clockwork.player:Notify(player, "You have set this stationary radio's arguments to "..arguments..".");
				else
					Clockwork.player:Notify(player, "The radio arguments must be between 101.1 and 199.9!");
				end;
			else
				Clockwork.player:Notify(player, "The radio arguments must look like xxx.x!");
			end;
		elseif (arguments == "cwRadioToggle") then
			entity:Toggle();
		elseif (arguments == "cwRadioTake") then
			local success, fault = player:GiveItem(entity:GetItemTable());
			
			if (!success) then
				Clockwork.player:Notify(entity, fault);
			else
				entity:Remove();
			end;
		end;
	end;
end;

-- Called when an entity is removed.
function Severance:EntityRemoved(entity)
	if (IsValid(entity) and entity:GetClass() == "prop_ragdoll") then
		if (entity.cwIsBelongings and entity.cwInventory and entity.cwCash) then
			if (table.Count(entity.cwInventory) > 0 or entity.cwCash > 0) then
				local belongings = ents.Create("cw_belongings");
				
				belongings:SetAngles(Angle(0, 0, -90));
				belongings:SetData(entity.cwInventory, entity.cwCash);
				belongings:SetPos(entity:GetPos() + Vector(0, 0, 32));
				belongings:Spawn();
				
				entity.cwInventory = nil;
				entity.cwCash = nil;
			end;
		end;
	end;
end;

-- Called just before a player dies.
function Severance:DoPlayerDeath(player, attacker, damageInfo)
	local action = Clockwork.player:GetAction(player);
	
	self:TiePlayer(player, false, true);
	
	player.cwIsBeingSearched = nil;
	player.cwIsSearchingChar = nil;

	if (player.cwBreathSound) then
		player.cwBreathSound:Stop()
		player.cwBreathSound = nil
	end
end;

-- Called just after a player spawns.
function Severance:PostPlayerSpawn(player, lightSpawn, changeClass, firstSpawn)
	if (!lightSpawn) then
		umsg.Start("cwClearEffects", player);
		umsg.End();
		
		player.cwIsBeingSearched = nil;
		player.cwIsSearchingChar = nil;
		
		player:SetNetworkedVar("GhostMode", false)
		if (self:PlayerIsZombie(player)) then
			self:ToggleGhost(player)
		end;

		if (player.cwBreathSound) then
			player.cwBreathSound:Stop()
			player.cwBreathSound = nil
		end
	end;
	
	if (player:GetSharedVar("IsTied") != 0) then
		self:TiePlayer(player, true);
	end;
end;

-- Called when a player's pain sound should be played.
function Severance:PlayerPlayPainSound(player, gender, damageInfo, hitGroup)
	if (self:PlayerIsZombie(player)) then
		return "npc/zombie/zombie_pain"..math.random(1, 6)..".wav";
	end;
end;

-- Called when a player's death sound should be played.
function Severance:PlayerPlayDeathSound(player, gender)
	if (player:GetFaction() == FACTION_ZOMB) then
		return "runner/death"..math.random(1, 2)..".wav";
	end;
end;

-- Called when a player's footstep sound should be played.
function Severance:PlayerFootstep(player, position, foot, sound, volume, recipientFilter)
	local clothesItem = player:GetClothesItem();
	
	if (player:GetNetworkedVar("GhostMode", true)) then
		return true
	end;
	
	if (clothesItem) then
		if (player:IsRunning() or player:IsJogging()) then
			if (clothesItem.runSound) then
				if (type(clothesItem.runSound) == "table") then
					sound = clothesItem.runSound[math.random(1, #clothesItem.runSound)];
				else
					sound = clothesItem.runSound;
				end;
			end;
		elseif (clothesItem.walkSound) then
			if (type(clothesItem.walkSound) == "table") then
				sound = clothesItem.walkSound[math.random(1, #clothesItem.walkSound)];
			else
				sound = clothesItem.walkSound;
			end;
		end;
	end;
	
	player:EmitSound(sound);
end;

-- Called when a player throws a punch.
function Severance:PlayerPunchThrown(player)
	player:ProgressAttribute(ATB_STRENGTH, 0.25, true);
end;

-- Called when a player punches an entity.
function Severance:PlayerPunchEntity(player, entity)
	if (entity:IsPlayer() or entity:IsNPC()) then
		player:ProgressAttribute(ATB_STRENGTH, 1, true);
	else
		player:ProgressAttribute(ATB_STRENGTH, 0.5, true);
	end;
end;

-- Called when an entity has been breached.
function Severance:EntityBreached(entity, activator)
	if (Clockwork.entity:IsDoor(entity)) then
		if (!IsValid(activator)) then
			Clockwork.entity:OpenDoor(entity, 0, true, true);
		else
			self:BustDownDoor(activator, entity);
		end;
	end;
end;

-- Called when a player takes damage.
function Severance:PlayerTakeDamage(player, inflictor, attacker, hitGroup, damageInfo)
	if (player:Health() <= 15 and math.random() <= 0.75) then
		if (Clockwork.player:GetAction(player) != "die") then
			Clockwork.player:SetRagdollState(player, RAGDOLL_FALLENOVER, nil, nil, Clockwork.kernel:ConvertForce(damageInfo:GetDamageForce()));
			
			Clockwork.player:SetAction(player, "die", 60, 1, function()
				if (IsValid(player) and player:Alive()) then
					player:TakeDamage(99999, attacker, inflictor);
				end;
			end);
		end;
	end;
end;

-- Called when a player's limb damage is bIsHealed.
function Severance:PlayerLimbDamageHealed(player, hitGroup, amount)
	if (hitGroup == HITGROUP_HEAD) then
		player:BoostAttribute("Limb Damage", ATB_MEDICAL, false);
	elseif (hitGroup == HITGROUP_CHEST or hitGroup == HITGROUP_STOMACH) then
		player:BoostAttribute("Limb Damage", ATB_ENDURANCE, false);
	elseif (hitGroup == HITGROUP_LEFTLEG or hitGroup == HITGROUP_RIGHTLEG) then
		player:BoostAttribute("Limb Damage", ATB_ACROBATICS, false);
		player:BoostAttribute("Limb Damage", ATB_AGILITY, false);
	elseif (hitGroup == HITGROUP_LEFTARM or hitGroup == HITGROUP_RIGHTARM) then
		player:BoostAttribute("Limb Damage", ATB_DEXTERITY, false);
		player:BoostAttribute("Limb Damage", ATB_STRENGTH, false);
	end;
end;

-- Called when a player's limb damage is reset.
function Severance:PlayerLimbDamageReset(player)
	player:BoostAttribute("Limb Damage", nil, false);
end;

-- Called when a player's limb takes damage.
function Severance:PlayerLimbTakeDamage(player, hitGroup, damage)
	local limbDamage = Clockwork.limb:GetDamage(player, hitGroup);
	
	if (hitGroup == HITGROUP_HEAD) then
		player:BoostAttribute("Limb Damage", ATB_MEDICAL, -limbDamage);
	elseif (hitGroup == HITGROUP_CHEST or hitGroup == HITGROUP_STOMACH) then
		player:BoostAttribute("Limb Damage", ATB_ENDURANCE, -limbDamage);
	elseif (hitGroup == HITGROUP_LEFTLEG or hitGroup == HITGROUP_RIGHTLEG) then
		player:BoostAttribute("Limb Damage", ATB_ACROBATICS, -limbDamage);
		player:BoostAttribute("Limb Damage", ATB_AGILITY, -limbDamage);
	elseif (hitGroup == HITGROUP_LEFTARM or hitGroup == HITGROUP_RIGHTARM) then
		player:BoostAttribute("Limb Damage", ATB_DEXTERITY, -limbDamage);
		player:BoostAttribute("Limb Damage", ATB_STRENGTH, -limbDamage);
	end;
end;

-- A function to scale damage by hit group.
function Severance:PlayerScaleDamageByHitGroup(player, attacker, hitGroup, damageInfo, baseDamage)
	local clothesItem = player:GetClothesItem();
	local endurance = Clockwork.attributes:Fraction(player, ATB_ENDURANCE, 0.75, 0.75);
	
	damageInfo:ScaleDamage(1.5 - endurance);
	
	if (clothesItem and clothesItem.protection) then
		if (damageInfo:IsBulletDamage() or (damageInfo:IsFallDamage() and clothesItem.protection >= 0.8)) then
			damageInfo:ScaleDamage(1 - clothesItem.protection);
		end;
	end;
end;

-- Called when an entity takes damage.
function Severance:EntityTakeDamage(entity, damageInfo)
	local attacker = damageInfo:GetAttacker();
	local curTime = CurTime();
	local player = Clockwork.entity:GetPlayer(entity);
	
	if (player) then
		if (!player.cwNextEnduranceTime or CurTime() > player.cwNextEnduranceTime) then
			player:ProgressAttribute(ATB_ENDURANCE, math.Clamp(damageInfo:GetDamage(), 0, 75) / 10, true);
			
			player.cwNextEnduranceTime = CurTime() + 2;
		end;
	end;
	
	if (attacker:IsPlayer()) then
		local strength = Clockwork.attributes:Fraction(attacker, ATB_STRENGTH, 1, 0.5);
		local weapon = Clockwork.player:GetWeaponClass(attacker);
		
		if (damageInfo:IsDamageType(DMG_CLUB) or damageInfo:IsDamageType(DMG_SLASH)) then
			damageInfo:ScaleDamage(1 + strength);
		end;
		
		if (weapon == "weapon_crowbar") then
			if (entity:IsPlayer()) then
				damageInfo:ScaleDamage(0.1);
			else
				damageInfo:ScaleDamage(0.8);
			end;
		end;
	end;
end;

-- Called when a player's stamina should drain.
function Severance:PlayerShouldStaminaDrain(player)
	return (player:GetFaction() != FACTION_INFECTED);
end;