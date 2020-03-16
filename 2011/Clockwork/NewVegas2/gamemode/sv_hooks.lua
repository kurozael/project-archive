--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

-- Called when a player uses an unknown item function.
function Schema:PlayerUseUnknownItemFunction(player, itemTable, itemFunction)
	if (Clockwork.player:HasFlags(player, "T") and itemFunction == "Caps" and itemTable("cost")) then
		local useSounds = {"buttons/button5.wav", "buttons/button4.wav"};
		
		player:TakeItem(itemTable, true);
		player:EmitSound(useSounds[math.random(1, #useSounds)]);
		
		Clockwork.player:GiveCash(player, math.Round(itemTable("cost") / 2), "scrapped an item");
	end;
end;

-- Called when a player attempts to use a lowered weapon.
function Schema:PlayerCanUseLoweredWeapon(player, weapon, secondary)
	if (secondary and (weapon.SilenceTime or weapon.PistolBurst)) then
		return true;
	end;
end;

-- Called when a player's footstep sound should be played.
function Schema:PlayerFootstep(player, position, foot, sound, volume, recipientFilter)
	local clothesItem = player:GetClothesItem();
	
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
		
	if (player:GetFaction() == FACTION_BROTHERHOOD) then
		local runSounds = {
			"npc/metropolice/gear1.wav",
			"npc/metropolice/gear2.wav",
			"npc/metropolice/gear3.wav",
			"npc/metropolice/gear4.wav",
			"npc/metropolice/gear5.wav",
			"npc/metropolice/gear6.wav"
		};
		
		sound = runSounds[math.random(1, #runSounds)];
	end;
	
	player:EmitSound(sound);
end;

-- Called when a player's character screen info should be adjusted.
function Schema:PlayerAdjustCharacterScreenInfo(player, character, info)
	if (character.data["CustomClass"]) then
		info.customClass = character.data["CustomClass"];
	end;
end;

-- Called when a player's shared variables should be set.
function Schema:PlayerSetSharedVars(player, curTime)
	player:SetSharedVar("CustomClass", player:GetCharacterData("CustomClass"));
end;

-- Called when a player's default inventory is needed.
function Schema:GetPlayerDefaultInventory(player, character, inventory)
	local instances = {};
	
	if (character.faction == FACTION_NCR) then
		instances["32_hunting_rifle"] = 1;
		instances["handheld_radio"] = 1;
		instances["10mm_pistol"] = 1;
		instances["ammo_pistol"] = 3;
		instances["ammo_357"] = 3;
		instances["backpack"] = 1;
		instances["jacket"] = 1;
	elseif (character.faction == FACTION_LEGION) then
		instances["combat_shotgun"] = 1;
		instances["handheld_radio"] = 1;
		instances["10mm_pistol"] = 1;
		instances["ammo_buckshot"] = 3;
		instances["ammo_pistol"] = 3;
		instances["backpack"] = 1;
		instances["jacket"] = 1;
	elseif (character.faction == FACTION_CARAVAN) then
		instances["chinese_assault_rifle"] = 1;
		instances["handheld_radio"] = 1;
		instances["10mm_pistol"] = 1;
		instances["ammo_pistol"] = 3;
		instances["ammo_smg1"] = 3;
		instances["backpack"] = 1;
		instances["jacket"] = 1;
	elseif (character.faction == FACTION_BROTHERHOOD) then
		instances["laser_pistol"] = 1;
		instances["laser_rifle"] = 1;
		instances["handheld_radio"] = 1;
		instances["energy_cell"] = 6;
		instances["backpack"] = 1;
		instances["jacket"] = 1;
	end;
	
	for k, v in pairs(instances) do
		for i = 1, v do
			Clockwork.inventory:AddInstance(
				inventory, Clockwork.item:CreateInstance(k)
			);
		end;
	end;
end;

-- Called when Clockwork has initialized.
function Schema:ClockworkInitialized()
	self.trashItems = {};
	
	for k, v in pairs(Clockwork.item:GetAll()) do
		if (v("category") == "Junk" and !v("isBaseItem")) then
			self.trashItems[#self.trashItems + 1] = v;
		end;
	end;
end;

-- Called each frame.
function Schema:Tick()
	local curTime = CurTime();
	local totalItems = #ents.FindByClass("cw_item");
	local maximumSpawns = 40;
	
	if (!self.nextTrashSpawns) then
		self.nextTrashSpawns = curTime + math.random(1800, 3600);
	end;
	
	if (curTime >= self.nextTrashSpawns and #self.trashSpawns > 0) then
		if (totalItems < maximumSpawns) then
			self.nextTrashSpawns = nil;
			
			math.randomseed(curTime);
			
			local totalWorth = 0;
			local targetWorth = (maximumSpawns - totalItems);
			
			while (totalWorth < targetWorth) do
				local trashItem = self:GetRandomTrashItem();
				local position = self:GetRandomTrashSpawn();
					totalWorth = totalWorth + trashItem.worth;
				Clockwork.entity:CreateItem(
					nil, Clockwork.item:CreateInstance(
						trashItem("uniqueID")
					), position
				);
			end;
		end;
	end;
end;

-- Called when Clockwork has loaded all of the entities.
function Schema:ClockworkInitPostEntity()
	self:LoadTrashSpawns();
	self:LoadRadios();
end;

-- Called just after data should be saved.
function Schema:PostSaveData()
	self:SaveRadios();
end;

-- Called when a player's drop weapon info should be adjusted.
function Schema:PlayerAdjustDropWeaponInfo(player, info)
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
function Schema:PlayerGivenWeapon(player, class, itemTable)
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

-- Called when a player attempts to use the radio.
function Schema:PlayerCanRadio(player, text, listeners, eavesdroppers)
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
function Schema:PlayerCanUseEntityInVehicle(player, entity, vehicle)
	if (entity:IsPlayer() or Clockwork.entity:IsPlayerRagdoll(entity)) then
		return true;
	end;
end;

-- Called when a player has been unragdolled.
function Schema:PlayerUnragdolled(player, state, ragdoll)
	Clockwork.player:SetAction(player, "die", false);
end;

-- Called when a player has been ragdolled.
function Schema:PlayerRagdolled(player, state, ragdoll)
	Clockwork.player:SetAction(player, "die", false);
end;

-- Called at an interval while a player is connected.
function Schema:PlayerThink(player, curTime, infoTable)
	if (Clockwork.player:HasFlags(player, "T")) then
		infoTable.inventoryWeight = infoTable.inventoryWeight * 2;
	end;
end;

-- Called when death attempts to clear a player's recognised names.
function Schema:PlayerCanDeathClearRecognisedNames(player, attacker, damageInfo) return false; end;

-- Called when death attempts to clear a player's name.
function Schema:PlayerCanDeathClearName(player, attacker, damageInfo) return false; end;

-- Called when a player attempts to use an item.
function Schema:PlayerCanUseItem(player, itemTable, bNoMsg)
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

-- Called when chat box info should be adjusted.
function Schema:ChatBoxAdjustInfo(info)
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

-- Called when a chat box message has been added.
function Schema:ChatBoxMessageAdded(info)
	if (info.class == "ic") then
		local eavesdroppers = {};
		local talkRadius = Clockwork.config:Get("talk_radius"):Get();
		local listeners = {};
		local players = _player.GetAll();
		local radios = ents.FindByClass("cw_radio");
		local data = {};
		
		for k, v in ipairs(radios) do
			if (!v:IsOff() and info.speaker:GetPos():Distance(v:GetPos()) <= 64) then
				if (info.speaker:GetEyeTraceNoCursor().Entity == v) then
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
		end;
		
		if (IsValid(data.entity) and data.frequency != "") then
			for k, v in ipairs(players) do
				if (v:HasInitialized() and v:Alive() and !v:IsRagdolled(RAGDOLL_FALLENOVER)) then
					if ((v:GetCharacterData("Frequency") == data.frequency and v:HasItemByID("handheld_radio"))
					or info.speaker == v) then
						listeners[v] = v;
					elseif (v:GetPos():Distance(data.position) <= talkRadius) then
						eavesdroppers[v] = v;
					end;
				end;
			end;
			
			for k, v in ipairs(radios) do
				if (data.entity != v) then
					local radioPosition = v:GetPos();
					local radioFrequency = v:GetSharedVar("Frequency");
					
					if (!v:IsOff() and radioFrequency == data.frequency) then
						for k2, v2 in ipairs(players) do
							if (v2:HasInitialized() and !listeners[v2] and !eavesdroppers[v2]) then
								if (v2:GetPos():Distance(radioPosition) <= (talkRadius * 2)) then
									eavesdroppers[v2] = v2;
								end;
							end;
						end;
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
function Schema:PlayerRadioUsed(player, text, listeners, eavesdroppers)
	local newEavesdroppers = {};
	local talkRadius = Clockwork.config:Get("talk_radius"):Get() * 2;
	local frequency = player:GetCharacterData("Frequency");
	
	for k, v in ipairs(ents.FindByClass("cw_radio")) do
		local radioPosition = v:GetPos();
		local radioFrequency = v:GetSharedVar("Frequency");
		
		if (!v:IsOff() and radioFrequency == frequency) then
			for k2, v2 in ipairs(_player.GetAll()) do
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
function Schema:PlayerAdjustRadioInfo(player, info)
	for k, v in ipairs(_player.GetAll()) do
		if (v:HasInitialized() and v:HasItemByID("handheld_radio")) then
			if (v:GetCharacterData("Frequency") == player:GetCharacterData("Frequency")) then
				info.listeners[v] = v;
			end;
		end;
	end;
end;

-- Called when a player destroys generator.
function Schema:PlayerDestroyGenerator(player, entity, generator)
	Clockwork.player:GiveCash(player, generator.cash / 4, "destroying a "..string.lower(generator.name));
end;

-- Called when an entity's menu option should be handled.
function Schema:EntityHandleMenuOption(player, entity, option, arguments)
	if (entity:GetClass() == "prop_ragdoll") then
		if (arguments == "cwCorpseMutilate") then
			local entityPlayer = Clockwork.entity:GetPlayer(entity);
			local trace = player:GetEyeTraceNoCursor();
			
			if (!entityPlayer or !entityPlayer:Alive()) then
				if (!entity.cwMutilationAmt or entity.cwMutilationAmt < 3) then
					entity.cwMutilationAmt = (entity.cwMutilationAmt or 0) + 1;
						player:GiveItem("human_meat");
						player:EmitSound("npc/barnacle/barnacle_crunch"..math.random(2, 3)..".wav");
					Clockwork:CreateBloodEffects(entity:NearestPoint(trace.HitPos), 1, entity);
				end;
			end;
		end;
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

-- Called when a player takes damage.
function Schema:PlayerTakeDamage(player, inflictor, attacker, hitGroup, damageInfo)
	if (player:Health() <= 10 and math.random() <= 0.75) then
		if (Clockwork.player:GetAction(player) != "die") then
			Clockwork.player:SetRagdollState(player, RAGDOLL_FALLENOVER, nil, nil, Clockwork:ConvertForce(damageInfo:GetDamageForce() * 32));
			
			Clockwork.player:SetAction(player, "die", 120, 1, function()
				if (IsValid(player) and player:Alive()) then
					player:TakeDamage(player:Health() * 2, attacker, inflictor);
				end;
			end);
		end;
	end;
end;