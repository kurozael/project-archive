--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

-- Called when a player uses an unknown item function.
function openAura.schema:PlayerUseUnknownItemFunction(player, itemTable, itemFunction)
	if (openAura.player:HasFlags(player, "T") and itemFunction == "Caps" and itemTable.cost) then
		local useSounds = {"buttons/button5.wav", "buttons/button4.wav"};
		
		player:UpdateInventory(itemTable.uniqueID, -1, true);
		player:EmitSound( useSounds[ math.random(1, #useSounds) ] );
		
		openAura.player:GiveCash(player, math.Round(itemTable.cost / 2), "scrapped an item");
	end;
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
	end;
end;

-- Called when a player attempts to use a lowered weapon.
function openAura.schema:PlayerCanUseLoweredWeapon(player, weapon, secondary)
	if ( secondary and (weapon.SilenceTime or weapon.PistolBurst) ) then
		return true;
	end;
end;

-- Called just after a player spawns.
function openAura.schema:PostPlayerSpawn(player, lightSpawn, changeClass, firstSpawn)
	local clothes = player:GetCharacterData("clothes");
	
	if (clothes) then
		local itemTable = openAura.item:Get(clothes);
		
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
		
		if (openAura.player:GetFaction(player) == FACTION_BROTHERHOOD) then
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
	end;
	
	player:EmitSound(sound);
	
	return true;
end;

-- Called when a player's character screen info should be adjusted.
function openAura.schema:PlayerAdjustCharacterScreenInfo(player, character, info)
	if ( character.data["customclass"] ) then
		info.customClass = character.data["customclass"];
	end;
end;

-- Called when a player's shared variables should be set.
function openAura.schema:PlayerSetSharedVars(player, curTime)
	player:SetSharedVar( "customClass", player:GetCharacterData("customclass", "") );
	player:SetSharedVar( "clothes", player:GetCharacterData("clothes", 0) );
end;

-- Called when a player's default inventory is needed.
function openAura.schema:GetPlayerDefaultInventory(player, character, inventory)
	if (character.faction == FACTION_NCR) then
		inventory["32_hunting_rifle"] = 1;
		inventory["handheld_radio"] = 1;
		inventory["10mm_pistol"] = 1;
		inventory["ammo_pistol"] = 3;
		inventory["ammo_357"] = 3;
		inventory["backpack"] = 1;
		inventory["jacket"] = 1;
	elseif (character.faction == FACTION_LEGION) then
		inventory["combat_shotgun"] = 1;
		inventory["handheld_radio"] = 1;
		inventory["10mm_pistol"] = 1;
		inventory["ammo_buckshot"] = 3;
		inventory["ammo_pistol"] = 3;
		inventory["backpack"] = 1;
		inventory["jacket"] = 1;
	elseif (character.faction == FACTION_CARAVAN) then
		inventory["chinese_assault_rifle"] = 1;
		inventory["handheld_radio"] = 1;
		inventory["10mm_pistol"] = 1;
		inventory["ammo_pistol"] = 3;
		inventory["ammo_smg1"] = 3;
		inventory["backpack"] = 1;
		inventory["jacket"] = 1;
	elseif (character.faction == FACTION_BROTHERHOOD) then
		inventory["laser_pistol"] = 1;
		inventory["laser_rifle"] = 1;
		inventory["handheld_radio"] = 1;
		inventory["energy_cell"] = 6;
		inventory["backpack"] = 1;
		inventory["jacket"] = 1;
	end;
end;

-- Called when OpenAura has initialized.
function openAura.schema:OpenAuraInitialized()
	self.trashItems = {};
	
	for k, v in pairs( openAura.item:GetAll() ) do
		if (v.category == "Junk" and !v.isBaseItem) then
			self.trashItems[#self.trashItems + 1] = v;
		end;
	end;
end;

-- Called each frame.
function openAura.schema:Tick()
	local curTime = CurTime();
	local totalItems = #ents.FindByClass("aura_item");
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
				openAura.entity:CreateItem(nil, trashItem.uniqueID, position);
			end;
		end;
	end;
end;

-- Called when OpenAura has loaded all of the entities.
function openAura.schema:OpenAuraInitPostEntity()
	self:LoadTrashSpawns();
	self:LoadRadios();
end;

-- Called just after data should be saved.
function openAura.schema:PostSaveData()
	self:SaveRadios();
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

-- Called when a player has been unragdolled.
function openAura.schema:PlayerUnragdolled(player, state, ragdoll)
	openAura.player:SetAction(player, "die", false);
end;

-- Called when a player has been ragdolled.
function openAura.schema:PlayerRagdolled(player, state, ragdoll)
	openAura.player:SetAction(player, "die", false);
end;

-- Called at an interval while a player is connected.
function openAura.schema:PlayerThink(player, curTime, infoTable)
	if ( openAura.player:HasFlags(player, "T") ) then
		infoTable.inventoryWeight = infoTable.inventoryWeight * 2;
	end;
end;

-- Called when death attempts to clear a player's recognised names.
function openAura.schema:PlayerCanDeathClearRecognisedNames(player, attacker, damageInfo) return false; end;

-- Called when death attempts to clear a player's name.
function openAura.schema:PlayerCanDeathClearName(player, attacker, damageInfo) return false; end;

-- Called when a player attempts to use an item.
function openAura.schema:PlayerCanUseItem(player, itemTable, noMessage)
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

-- Called when a chat box message has been added.
function openAura.schema:ChatBoxMessageAdded(info)
	if (info.class == "ic") then
		local eavesdroppers = {};
		local talkRadius = openAura.config:Get("talk_radius"):Get();
		local listeners = {};
		local players = _player.GetAll();
		local radios = ents.FindByClass("aura_radio");
		local data = {};
		
		for k, v in ipairs(radios) do
			if (!v:IsOff() and info.speaker:GetPos():Distance( v:GetPos() ) <= 64) then
				if (info.speaker:GetEyeTraceNoCursor().Entity == v) then
					local frequency = v:GetSharedVar("frequency");
					
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
				if ( v:HasInitialized() and v:Alive() and !v:IsRagdolled(RAGDOLL_FALLENOVER) ) then
					if ( ( v:GetCharacterData("frequency") == data.frequency and v:HasItem("handheld_radio") )
					or info.speaker == v ) then
						listeners[v] = v;
					elseif (v:GetPos():Distance(data.position) <= talkRadius) then
						eavesdroppers[v] = v;
					end;
				end;
			end;
			
			for k, v in ipairs(radios) do
				if (data.entity != v) then
					local radioPosition = v:GetPos();
					local radioFrequency = v:GetSharedVar("frequency");
					
					if (!v:IsOff() and radioFrequency == data.frequency) then
						for k2, v2 in ipairs(players) do
							if ( v2:HasInitialized() and !listeners[v2] and !eavesdroppers[v2] ) then
								if ( v2:GetPos():Distance(radioPosition) <= (talkRadius * 2) ) then
									eavesdroppers[v2] = v2;
								end;
							end;
						end;
					end;
				end;
			end;
			
			if (table.Count(listeners) > 0) then
				openAura.chatBox:Add(listeners, info.speaker, "radio", info.text);
			end;
			
			if (table.Count(eavesdroppers) > 0) then
				openAura.chatBox:Add(eavesdroppers, info.speaker, "radio_eavesdrop", info.text);
			end;
		end;
	end;
end;

-- Called when a player has used their radio.
function openAura.schema:PlayerRadioUsed(player, text, listeners, eavesdroppers)
	local newEavesdroppers = {};
	local talkRadius = openAura.config:Get("talk_radius"):Get() * 2;
	local frequency = player:GetCharacterData("frequency");
	
	for k, v in ipairs( ents.FindByClass("aura_radio") ) do
		local radioPosition = v:GetPos();
		local radioFrequency = v:GetSharedVar("frequency");
		
		if (!v:IsOff() and radioFrequency == frequency) then
			for k2, v2 in ipairs( _player.GetAll() ) do
				if ( v2:HasInitialized() and !listeners[v2] and !eavesdroppers[v2] ) then
					if (v2:GetPos():Distance(radioPosition) <= talkRadius) then
						newEavesdroppers[v2] = v2;
					end;
				end;
				
				break;
			end;
		end;
	end;
	
	if (table.Count(newEavesdroppers) > 0) then
		openAura.chatBox:Add(newEavesdroppers, player, "radio_eavesdrop", text);
	end;
end;

-- Called when a player's radio info should be adjusted.
function openAura.schema:PlayerAdjustRadioInfo(player, info)
	for k, v in ipairs( _player.GetAll() ) do
		if ( v:HasInitialized() and v:HasItem("handheld_radio") ) then
			if ( v:GetCharacterData("frequency") == player:GetCharacterData("frequency") ) then
				info.listeners[v] = v;
			end;
		end;
	end;
end;

-- Called when a player destroys generator.
function openAura.schema:PlayerDestroyGenerator(player, entity, generator)
	openAura.player:GiveCash( player, generator.cash / 4, "destroying a "..string.lower(generator.name) );
end;

-- Called when an entity's menu option should be handled.
function openAura.schema:EntityHandleMenuOption(player, entity, option, arguments)
	if (entity:GetClass() == "prop_ragdoll") then
		if (arguments == "aura_corpseMutilate") then
			local entityPlayer = openAura.entity:GetPlayer(entity);
			local trace = player:GetEyeTraceNoCursor();
			
			if ( !entityPlayer or !entityPlayer:Alive() ) then
				if (!entity.mutilated or entity.mutilated < 3) then
					entity.mutilated = (entity.mutilated or 0) + 1;
						player:UpdateInventory("human_meat", 1, true);
						player:EmitSound("npc/barnacle/barnacle_crunch"..math.random(2, 3)..".wav");
					openAura:CreateBloodEffects(entity:NearestPoint(trace.HitPos), 1, entity);
				end;
			end;
		end;
	elseif (entity:GetClass() == "aura_radio") then
		if (option == "Set Frequency" and type(arguments) == "string") then
			if ( string.find(arguments, "^%d%d%d%.%d$") ) then
				local start, finish, decimal = string.match(arguments, "(%d)%d(%d)%.(%d)");
				
				start = tonumber(start);
				finish = tonumber(finish);
				decimal = tonumber(decimal);
				
				if (start == 1 and finish > 0 and finish < 10 and decimal > 0 and decimal < 10) then
					entity:SetFrequency(arguments);
					
					openAura.player:Notify(player, "You have set this stationary radio's arguments to "..arguments..".");
				else
					openAura.player:Notify(player, "The radio arguments must be between 101.1 and 199.9!");
				end;
			else
				openAura.player:Notify(player, "The radio arguments must look like xxx.x!");
			end;
		elseif (arguments == "aura_radioToggle") then
			entity:Toggle();
		elseif (arguments == "aura_radioTake") then
			local success, fault = player:UpdateInventory("stationary_radio", 1);
			
			if (!success) then
				openAura.player:Notify(entity, fault);
			else
				entity:Remove();
			end;
		end;
	end;
end;

-- Called when a player takes damage.
function openAura.schema:PlayerTakeDamage(player, inflictor, attacker, hitGroup, damageInfo)
	if (player:Health() <= 10 and math.random() <= 0.75) then
		if (openAura.player:GetAction(player) != "die") then
			openAura.player:SetRagdollState( player, RAGDOLL_FALLENOVER, nil, nil, openAura:ConvertForce(damageInfo:GetDamageForce() * 32) );
			
			openAura.player:SetAction(player, "die", 120, 1, function()
				if ( IsValid(player) and player:Alive() ) then
					player:TakeDamage(player:Health() * 2, attacker, inflictor);
				end;
			end);
		end;
	end;
end;