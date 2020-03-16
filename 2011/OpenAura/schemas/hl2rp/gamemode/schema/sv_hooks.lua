--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

-- Called when OpenAura has loaded all of the entities.
function openAura.schema:OpenAuraInitPostEntity()
	self:LoadRationDispensers();
	self:LoadCombineLocks();
	self:LoadObjectives();
	self:LoadRadios();
	self:LoadNPCs();
end;

-- Called when data should be saved.
function openAura.schema:SaveData()
	if (self.combineObjectives) then
		openAura:SaveSchemaData("objectives", self.combineObjectives);
	end;
end;

-- Called just after data should be saved.
function openAura.schema:PostSaveData()
	self:SaveRationDispensers();
	self:SaveCombineLocks();
	self:SaveRadios();
	self:SaveNPCs();
end;

-- Called when a player's default model is needed.
function openAura.schema:GetPlayerDefaultModel(player)
	if ( self:IsPlayerCombineRank(player, "GHOST") ) then
		return "models/eliteghostcp.mdl";
	elseif ( self:IsPlayerCombineRank(player, "OfC") ) then
		return "models/policetrench.mdl";
	elseif ( self:IsPlayerCombineRank(player, "DvL") ) then
		return "models/eliteshockcp.mdl";
	elseif ( self:IsPlayerCombineRank(player, "SeC") ) then
		return "models/sect_police2.mdl";
	end;
end;

-- Called when an entity's menu option should be handled.
function openAura.schema:EntityHandleMenuOption(player, entity, option, arguments)
	if (entity:GetClass() == "prop_ragdoll" and arguments == "aura_corpseLoot") then
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
				OnGiveCash = function(player, storageTable, cash)
					entity.cash = storageTable.cash;
				end,
				OnTakeCash = function(player, storageTable, cash)
					entity.cash = storageTable.cash;
				end
			} );
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

-- Called when an NPC has been killed.
function openAura.schema:OnNPCKilled(npc, attacker, inflictor)
	for k, v in pairs(self.scanners) do
		local scanner = v[1];
		local player = k;
		
		if (IsValid(player) and IsValid(scanner) and scanner == npc) then
			openAura:CalculateSpawnTime(player, inflictor, attacker);
			
			npc:EmitSound("npc/scanner/scanner_explode_crash2.wav");
			
			self:PlayerDeath(player, inflictor, attacker, true);
			self:ResetPlayerScanner(player);
		end;
	end;
end;

-- Called when a player's visibility should be set up.
function openAura.schema:SetupPlayerVisibility(player)
	if ( self.scanners[player] ) then
		local scanner = self.scanners[player][1];
		
		if ( IsValid(scanner) ) then
			AddOriginToPVS( scanner:GetPos() );
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

-- Called when a player uses a door.
function openAura.schema:PlayerUseDoor(player, door)
	if (string.lower( game.GetMap() ) == "rp_c18_v1") then
		local name = string.lower( door:GetName() );
		
		if (name == "nxs_brnroom" or name == "nxs_brnroom2" or name == "openAura_al_door1"
		or name == "openAura_al_door2" or name == "nxs_brnbcroom") then
			local curTime = CurTime();
			
			if (!door.nextAutoClose or curTime >= door.nextAutoClose) then
				door:Fire("Close", "", 10);
				door.nextAutoClose = curTime + 10;
			end;
		end;
	end;
end;

-- Called when a player has an unknown inventory item.
function openAura.schema:PlayerHasUnknownInventoryItem(player, inventory, item, amount)
	if (item == "radio") then
		inventory["handheld_radio"] = amount;
	end;
end;

-- Called when a player's default inventory is needed.
function openAura.schema:GetPlayerDefaultInventory(player, character, inventory)
	if (character.faction == FACTION_ADMIN) then
		inventory["handheld_radio"] = 1;
	elseif (character.faction == FACTION_MPF) then
		inventory["handheld_radio"] = 1;
		inventory["weapon_pistol"] = 1;
		inventory["ammo_pistol"] = 2;
	elseif (character.faction == FACTION_OTA) then
		inventory["handheld_radio"] = 1;
		inventory["weapon_pistol"] = 1;
		inventory["ammo_pistol"] = 1;
		inventory["weapon_ar2"] = 1;
		inventory["ammo_ar2"] = 1;
	else
		inventory["suitcase"] = 1;
	end;
end;

-- Called when a player's typing display has started.
function openAura.schema:PlayerStartTypingDisplay(player, code)
	if ( openAura.schema:PlayerIsCombine(player) ) then
		if (code == "n" or code == "y" or code == "w" or code == "r") then
			if (!player.typingBeep) then
				player.typingBeep = true;
				
				player:EmitSound("npc/overwatch/radiovoice/on1.wav");
			end;
		end;
	end;
end;

-- Called when a player's typing display has finished.
function openAura.schema:PlayerFinishTypingDisplay(player, textTyped)
	if (openAura.schema:PlayerIsCombine(player) and textTyped) then
		if (player.typingBeep) then
			player:EmitSound("npc/overwatch/radiovoice/off4.wav");
		end;
	end;
	
	player.typingBeep = nil;
end;

-- Called when a player stuns an entity.
function openAura.schema:PlayerStunEntity(player, entity)
	local target = openAura.entity:GetPlayer(entity);
	local strength = openAura.attributes:Fraction(player, ATB_STRENGTH, 12, 6);
	
	player:ProgressAttribute(ATB_STRENGTH, 0.5, true);
	
	if ( target and target:Alive() ) then
		local curTime = CurTime();
		
		if ( target.nextStunInfo and curTime <= target.nextStunInfo[2] ) then
			target.nextStunInfo[1] = target.nextStunInfo[1] + 1;
			target.nextStunInfo[2] = curTime + 2;
			
			if (target.nextStunInfo[1] == 3) then
				openAura.player:SetRagdollState( target, RAGDOLL_KNOCKEDOUT, openAura.config:Get("knockout_time"):Get() );
			end;
		else
			target.nextStunInfo = {0, curTime + 2};
		end;
		
		target:ViewPunch( Angle(12 + strength, 0, 0) );
		
		umsg.Start("aura_Stunned", target);
			umsg.Float(0.5);
		umsg.End();
	end;
end;

-- Called when a player's weapons should be given.
function openAura.schema:PlayerGiveWeapons(player)
	if (player:QueryCharacter("faction") == FACTION_MPF) then
		openAura.player:GiveSpawnWeapon(player, "aura_stunstick");
	end;
end;

-- Called when a player's inventory item has been updated.
function openAura.schema:PlayerInventoryItemUpdated(player, itemTable, amount, force)
	local clothes = player:GetCharacterData("clothes");
	
	if (clothes == itemTable.index) then
		if ( !player:HasItem(itemTable.uniqueID) ) then
			itemTable:OnChangeClothes(player, false);
			
			player:SetCharacterData("clothes", nil);
		end;
	end;
end;

-- Called when a player switches their flashlight on or off.
function openAura.schema:PlayerSwitchFlashlight(player, on)
	if ( on and (self.scanners[player] or player:GetSharedVar("tied") != 0) ) then
		return false;
	end;
end;

-- Called when a player's storage should close.
function openAura.schema:PlayerStorageShouldClose(player, storage)
	local entity = player:GetStorageEntity();
	
	if (player.searching and entity:IsPlayer() and entity:GetSharedVar("tied") == 0) then
		return true;
	end;
end;

-- Called when a player attempts to spray their tag.
function openAura.schema:PlayerSpray(player)
	if (!player:HasItem("spray_can") or player:GetSharedVar("tied") != 0) then
		return true;
	end;
end;

-- Called when a player presses F3.
function openAura.schema:ShowSpare1(player)
	openAura.player:RunOpenAuraCommand(player, "InvAction", "zip_tie", "use");
end;

-- Called when a player presses F4.
function openAura.schema:ShowSpare2(player)
	openAura.player:RunOpenAuraCommand(player, "CharSearch");
end;

-- Called when a player's footstep sound should be played.
function openAura.schema:PlayerFootstep(player, position, foot, sound, volume, recipientFilter)
	local running = nil;
	local clothes = player:GetCharacterData("clothes");
	local model = string.lower( player:GetModel() );
	
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
	
	if ( player:IsRunning() or player:IsJogging() ) then
		running = true;
	end;
	
	if (running) then
		if ( string.find(model, "metrocop") or string.find(model, "shockcp") or string.find(model, "ghostcp") or string.find(model, "police") ) then
			if (foot == 0) then
				local randomSounds = {1, 3, 5};
				local randomNumber = math.random(1, 3);
				
				sound = "npc/metropolice/gear"..randomSounds[randomNumber]..".wav";
			else
				local randomSounds = {2, 4, 6};
				local randomNumber = math.random(1, 3);
				
				sound = "npc/metropolice/gear"..randomSounds[randomNumber]..".wav";
			end;
		elseif ( string.find(model, "combine") ) then
			if (foot == 0) then
				local randomSounds = {1, 3, 5};
				local randomNumber = math.random(1, 3);
				
				sound = "npc/combine_soldier/gear"..randomSounds[randomNumber]..".wav";
			else
				local randomSounds = {2, 4, 6};
				local randomNumber = math.random(1, 3);
				
				sound = "npc/combine_soldier/gear"..randomSounds[randomNumber]..".wav";
			end;
		end;
	end;
	
	player:EmitSound(sound);
	
	return true;
end;

-- Called when a player attempts to spawn a prop.
function openAura.schema:PlayerSpawnProp(player, model)
	if ( !player:IsAdmin() and openAura.config:Get("cwu_props"):Get() ) then
		if (player:QueryCharacter("faction") == FACTION_CITIZEN) then
			
			if (player:GetCharacterData("customclass") != "Civil Worker's Union") then
				model = string.Replace(model, "\\", "/");
				model = string.Replace(model, "//", "/");
				model = string.lower(model);
				
				if ( string.find(model, "bed") ) then
					openAura.player:Notify(player, "You are not in the Civil Worker's Union!");
					
					return false;
				end;
				
				for k, v in pairs(self.cwuProps) do
					if (string.lower(v) == model) then
						openAura.player:Notify(player, "You are not in the Civil Worker's Union!");
						
						return false;
					end;
				end;
			end;
		end;
	end;
end;

-- Called when a player spawns an object.
function openAura.schema:PlayerSpawnObject(player)
	if ( player:GetSharedVar("tied") != 0 or self.scanners[player] ) then
		openAura.player:Notify(player, "You don't have permission to do this right now!");
		
		return false;
	end;
end;

-- Called when a player's character data should be restored.
function openAura.schema:PlayerRestoreCharacterData(player, data)
	if (!self:PlayerIsCombine(player) and player:QueryCharacter("faction") != FACTION_ADMIN) then
		if (!data["citizenid"] or string.len( tostring( data["citizenid"] ) ) == 4) then
			data["citizenid"] = openAura:ZeroNumberToDigits(math.random(1, 99999), 5);
		end;
	end;
end;

-- Called when a player attempts to breach an entity.
function openAura.schema:PlayerCanBreachEntity(player, entity)
	if (string.lower( entity:GetClass() ) == "func_door_rotating") then
		return false;
	end;
	
	if ( openAura.entity:IsDoor(entity) ) then
		if ( !openAura.entity:IsDoorFalse(entity) ) then
			return true;
		end;
	end;
end;

-- Called when a player attempts to restore a recognised name.
function openAura.schema:PlayerCanRestoreRecognisedName(player, target)
	if ( self:PlayerIsCombine(target) ) then
		return false;
	end;
end;

-- Called when a player attempts to save a recognised name.
function openAura.schema:PlayerCanSaveRecognisedName(player, target)
	if ( self:PlayerIsCombine(target) ) then
		return false;
	end;
end;

-- Called when a player attempts to use the radio.
function openAura.schema:PlayerCanRadio(player, text, listeners, eavesdroppers)
	if ( player:HasItem("handheld_radio") or self.scanners[player] ) then
		if ( !player:GetCharacterData("frequency") ) then
			openAura.player:Notify(player, "You need to set the radio frequency first!");
			
			return false;
		end;
	else
		openAura.player:Notify(player, "You do not own a radio!");
		
		return false;
	end;
end;

-- Called when a player's character has initialized.
function openAura.schema:PlayerCharacterInitialized(player)
	local faction = player:QueryCharacter("faction");
	
	if ( self:PlayerIsCombine(player) ) then
		
		for k, v in pairs(openAura.class.stored) do
			if ( v.factions and table.HasValue(v.factions, faction) ) then
				if ( #_team.GetPlayers(v.index) < openAura.class:GetLimit(v.name) ) then
					if ( v.index == CLASS_MPS and self:IsPlayerCombineRank(player, "SCN") ) then
						openAura.class:Set(player, v.index); break;
					elseif ( v.index == CLASS_MPR and self:IsPlayerCombineRank(player, "RCT") ) then
						openAura.class:Set(player, v.index); break;
					elseif ( v.index == CLASS_EMP and self:IsPlayerCombineRank(player, "EpU") ) then
						openAura.class:Set(player, v.index); break;
					elseif ( v.index == CLASS_EOW and self:IsPlayerCombineRank(player, "EOW") ) then
						openAura.class:Set(player, v.index); break;
					end;
				end;
			end;
		end;
	elseif (faction == FACTION_CITIZEN) then
		self:AddCombineDisplayLine( "Rebuilding citizen manifest...", Color(255, 100, 255, 255) );
	end;
end;

-- Called when a player's name has changed.
function openAura.schema:PlayerNameChanged(player, previousName, newName)
	if ( self:PlayerIsCombine(player) ) then
		local faction = player:QueryCharacter("faction");
		
		if (faction == FACTION_OTA) then
			if ( !self:IsStringCombineRank(previousName, "OWS") and self:IsStringCombineRank(newName, "OWS") ) then
				openAura.class:Set(player, CLASS_OWS);
			elseif ( !self:IsStringCombineRank(previousName, "EOW") and self:IsStringCombineRank(newName, "EOW") ) then
				openAura.class:Set(player, CLASS_EOW);
			end;
		elseif (faction == FACTION_MPF) then
			if ( !self:IsStringCombineRank(previousName, "SCN") and self:IsStringCombineRank(newName, "SCN") ) then
				openAura.class:Set(player, CLASS_MPS, true);
				
				self:MakePlayerScanner(player, true);
			elseif ( !self:IsStringCombineRank(previousName, "RCT") and self:IsStringCombineRank(newName, "RCT") ) then
				openAura.class:Set(player, CLASS_MPR);
			elseif ( !self:IsStringCombineRank(previousName, "EpU") and self:IsStringCombineRank(newName, "EpU") ) then
				openAura.class:Set(player, CLASS_EMP);
			elseif ( !self:IsStringCombineRank(previousName, "OfC") and self:IsStringCombineRank(newName, "OfC") ) then
				player:SetModel("models/policetrench.mdl");
			elseif ( !self:IsStringCombineRank(previousName, "DvL") and self:IsStringCombineRank(newName, "DvL") ) then
				player:SetModel("models/eliteshockcp.mdl");
			elseif ( !self:IsStringCombineRank(previousName, "SeC") and self:IsStringCombineRank(newName, "SeC") ) then
				player:SetModel("models/sect_police2.mdl");
			elseif ( !self:IsStringCombineRank(newName, "RCT") ) then
				if (player:Team() != CLASS_MPU) then
					openAura.class:Set(player, CLASS_MPU);
				end;
			end;
			
			if ( !self:IsStringCombineRank(previousName, "GHOST") and self:IsStringCombineRank(newName, "GHOST") ) then
				player:SetModel("models/eliteghostcp.mdl");
			end;
		end;
	end;
end;

-- Called when a player attempts to use an entity in a vehicle.
function openAura.schema:PlayerCanUseEntityInVehicle(player, entity, vehicle)
	if ( entity:IsPlayer() or openAura.entity:IsPlayerRagdoll(entity) ) then
		return true;
	end;
end;

-- Called when a player presses a key.
function openAura.schema:KeyPress(player, key)
	if (key == IN_USE) then
		if ( !self.scanners[player] ) then
			local untieTime = openAura.schema:GetDexterityTime(player);
			local target = player:GetEyeTraceNoCursor().Entity;
			local entity = target;
			
			if ( IsValid(target) ) then
				target = openAura.entity:GetPlayer(target);
				
				if (target and player:GetSharedVar("tied") == 0) then
					if (target:GetShootPos():Distance( player:GetShootPos() ) <= 192) then
						if (target:GetSharedVar("tied") != 0) then
							openAura.player:SetAction(player, "untie", untieTime);
							
							openAura.player:EntityConditionTimer(player, target, entity, untieTime, 192, function()
								return player:Alive() and !player:IsRagdolled() and player:GetSharedVar("tied") == 0;
							end, function(success)
								if (success) then
									self:TiePlayer(target, false);
									
									player:ProgressAttribute(ATB_DEXTERITY, 15, true);
								end;
								
								openAura.player:SetAction(player, "untie", false);
							end);
						end;
					end;
				end;
			end;
		end;
	elseif (key == IN_ATTACK or key == IN_ATTACK2) then
		if ( self.scanners[player] ) then
			local scanner = self.scanners[player][1];
			
			if ( IsValid(scanner) ) then
				player.nextScannerSound = CurTime() + math.random(8, 48);
				
				scanner:EmitSound( self.scannerSounds[ math.random(1, #self.scannerSounds) ] );
			end;
		end;
	elseif (key == IN_RELOAD) then
		if ( self.scanners[player] ) then
			local scanner = self.scanners[player][1];
			local curTime = CurTime();
			local marker = self.scanners[player][2];
			
			if ( IsValid(scanner) ) then
				local position = scanner:GetPos();
				
				for k, v in ipairs( ents.FindInSphere(position, 384) ) do
					if ( v:IsPlayer() and v:HasInitialized() and !self:PlayerIsCombine(v) ) then
						local playerPosition = v:GetPos();
						local scannerDot = scanner:GetAimVector():Dot( (playerPosition - position):Normalize() );
						local playerDot = v:GetAimVector():Dot( (position - playerPosition):Normalize() );
						local threshold = 0.2 + math.Clamp( (0.6 / 384) * playerPosition:Distance(position), 0, 0.6 );
						
						if (openAura.player:CanSeeEntity( v, scanner, 0.9, {marker} ) and playerDot >= threshold and scannerDot >= threshold) then
							if (player != v) then
								if (v:QueryCharacter("faction") == FACTION_CITIZEN) then
									if ( !v:GetForcedAnimation() ) then
										v:SetForcedAnimation("photo_react_blind", 2, function(player)
											player:Freeze(true);
										end, function(player)
											player:Freeze(false);
										end);
									end;
								end;
								
								umsg.Start("aura_Stunned", v);
									umsg.Float(3);
								umsg.End();
							end;
						end;
					end;
				end;
				
				scanner:EmitSound("npc/scanner/scanner_photo1.wav");
			end;
		end;
	elseif (key == IN_WALK) then
		if ( self.scanners[player] ) then
			openAura.player:RunOpenAuraCommand(player, "CharFollow");
		end;
	end;
end;

-- Called each tick.
function openAura.schema:Tick()
	for k, v in pairs(self.scanners) do
		local scanner = v[1];
		local marker = v[2];
		
		if ( IsValid(k) ) then
			if ( IsValid(scanner) and IsValid(marker) ) then
				if ( k:KeyDown(IN_FORWARD) ) then
					local position = scanner:GetPos() + (scanner:GetForward() * 25) + (scanner:GetUp() * -64);
					
					if ( k:KeyDown(IN_SPEED) ) then
						marker:SetPos( position + (k:GetAimVector() * 64) );
					else
						marker:SetPos( position + (k:GetAimVector() * 128) );
					end;
					
					scanner.followTarget = nil;
				end;
				
				if ( IsValid(scanner.followTarget) ) then
					scanner:Input("SetFollowTarget", scanner.followTarget, scanner.followTarget, "!activator");
				else
					scanner:Fire("SetFollowTarget", "marker_"..k:UniqueID(), 0);
				end;
				
				if ( scannerClass == "npc_cscanner" and self:IsPlayerCombineRank(k, "SYNTH") ) then
					self:MakePlayerScanner(k, true);
				elseif ( scannerClass == "npc_clawscanner" and !self:IsPlayerCombineRank(k, "SYNTH") ) then
					self:MakePlayerScanner(k, true);
				end;
			else
				self:ResetPlayerScanner(k);
			end;
		else
			if ( IsValid(scanner) ) then
				scanner:Remove();
			end;
			
			if ( IsValid(marker) ) then
				marker:Remove();
			end;
			
			self.scanners[k] = nil;
		end;
	end;
end;

-- Called when a player's health is set.
function openAura.schema:PlayerHealthSet(player, newHealth, oldHealth)
	if ( self.scanners[player] ) then
		if ( IsValid( self.scanners[player][1] ) ) then
			self.scanners[player][1]:SetHealth(newHealth);
		end;
	end;
end;

-- Called when a player attempts to be given a weapon.
function openAura.schema:PlayerCanBeGivenWeapon(player, class, uniqueID, forceReturn)
	if ( self.scanners[player] ) then
		return false;
	end;
end;

-- Called each frame that a player is dead.
function openAura.schema:PlayerDeathThink(player)
	if ( player:GetCharacterData("permakilled") ) then
		return true;
	end;
end;

-- Called when a player attempts to switch to a character.
function openAura.schema:PlayerCanSwitchCharacter(player, character)
	if ( player:GetCharacterData("permakilled") ) then
		return true;
	end;
end;

-- Called when a player's death info should be adjusted.
function openAura.schema:PlayerAdjustDeathInfo(player, info)
	if ( player:GetCharacterData("permakilled") ) then
		info.spawnTime = 0;
	end;
end;

-- Called when a player's character screen info should be adjusted.
function openAura.schema:PlayerAdjustCharacterScreenInfo(player, character, info)
	if ( character.data["permakilled"] ) then
		info.details = "This character is permanently killed.";
	end;
	
	if (info.faction == FACTION_OTA) then
		if ( self:IsStringCombineRank(info.name, "EOW") ) then
			info.model = "models/combine_super_soldier.mdl";
		end;
	elseif ( self:IsCombineFaction(info.faction) ) then
		if ( self:IsStringCombineRank(info.name, "SCN") ) then
			if ( self:IsStringCombineRank(info.name, "SYNTH") ) then
				info.model = "models/shield_scanner.mdl";
			else
				info.model = "models/combine_scanner.mdl";
			end;
		elseif ( self:IsStringCombineRank(info.name, "SeC") ) then
			info.model = "models/sect_police2.mdl";
		elseif ( self:IsStringCombineRank(info.name, "DvL") ) then
			info.model = "models/eliteshockcp.mdl";
		elseif ( self:IsStringCombineRank(info.name, "EpU") ) then
			info.model = "models/leet_police2.mdl";
		elseif ( self:IsStringCombineRank(info.name, "OfC") ) then
			info.model = "models/policetrench.mdl";
		end;
		
		if ( self:IsStringCombineRank(info.name, "GHOST") ) then
			info.model = "models/eliteghostcp.mdl";
		end;
	end;
	
	if ( character.data["customclass"] ) then
		info.customClass = character.data["customclass"];
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
			if (!v:IsOff() and info.speaker:GetPos():Distance( v:GetPos() ) <= 80) then
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
		
		if (IsValid(data.entity) and data.frequency != "") then
			for k, v in ipairs(players) do
				if ( v:HasInitialized() and v:Alive() and !v:IsRagdolled(RAGDOLL_FALLENOVER) ) then
					if ( ( v:GetCharacterData("frequency") == data.frequency and v:GetSharedVar("tied") == 0
					and v:HasItem("handheld_radio") ) or info.speaker == v ) then
						listeners[v] = v;
					elseif (v:GetPos():Distance(data.position) <= talkRadius) then
						eavesdroppers[v] = v;
					end;
				end;
			end;
			
			for k, v in ipairs(radios) do
				local radioPosition = v:GetPos();
				local radioFrequency = v:GetSharedVar("frequency");
				
				if (!v:IsOff() and radioFrequency == data.frequency) then
					for k2, v2 in ipairs(players) do
						if ( v2:HasInitialized() and !listeners[v2] and !eavesdroppers[v2] ) then
							if ( v2:GetPos():Distance(radioPosition) <= (talkRadius * 2) ) then
								eavesdroppers[v2] = v2;
							end;
						end;
						
						break;
					end;
				end;
			end;
			
			if (table.Count(listeners) > 0) then
				openAura.chatBox:Add(listeners, info.speaker, "radio", info.text);
			end;
			
			if (table.Count(eavesdroppers) > 0) then
				openAura.chatBox:Add(eavesdroppers, info.speaker, "radio_eavesdrop", info.text);
			end;
			
			table.Merge(info.listeners, listeners);
			table.Merge(info.listeners, eavesdroppers);
		end;
	end;
	
	if (info.voice) then
		if ( IsValid(info.speaker) and info.speaker:HasInitialized() ) then
			info.speaker:EmitSound(info.voice.sound, info.voice.volume);
		end;
		
		if (info.voice.global) then
			for k, v in pairs(info.listeners) do
				if (v != info.speaker) then
					openAura.player:PlaySound(v, info.voice.sound);
				end;
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
				if (v:GetSharedVar("tied") == 0) then
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

-- Called when a player has been healed.
function openAura.schema:PlayerHealed(player, healer, itemTable)
	if (itemTable.uniqueID == "health_vial") then
		healer:BoostAttribute(itemTable.name, ATB_DEXTERITY, 2, 120);
		healer:ProgressAttribute(ATB_MEDICAL, 15, true);
	elseif (itemTable.uniqueID == "health_kit") then
		healer:BoostAttribute(itemTable.name, ATB_DEXTERITY, 3, 120);
		healer:ProgressAttribute(ATB_MEDICAL, 25, true);
	elseif (itemTable.uniqueID == "bandage") then
		healer:BoostAttribute(itemTable.name, ATB_DEXTERITY, 1, 120);
		healer:ProgressAttribute(ATB_MEDICAL, 5, true);
	end;
end;

-- Called when a player's shared variables should be set.
function openAura.schema:PlayerSetSharedVars(player, curTime)
	player:SetSharedVar( "customClass", player:GetCharacterData("customclass", "") );
	player:SetSharedVar( "citizenID", player:GetCharacterData("citizenid", "") );
	player:SetSharedVar( "clothes", player:GetCharacterData("clothes", 0) );
	player:SetSharedVar( "icon", player:GetCharacterData("icon", "") );
	
	if (player:Alive() and !player:IsRagdolled() and player:GetVelocity():Length() > 0) then
		local inventoryWeight = openAura.inventory:GetWeight(player);
		
		if (inventoryWeight >= openAura.inventory:GetMaximumWeight(player) / 4) then
			player:ProgressAttribute(ATB_STRENGTH, inventoryWeight / 400, true);
		end;
	end;
end;

-- Called at an interval while a player is connected.
function openAura.schema:PlayerThink(player, curTime, infoTable)
	if ( player:Alive() and !player:IsRagdolled() ) then
		if (!player:InVehicle() and player:GetMoveType() == MOVETYPE_WALK) then
			if ( player:IsInWorld() ) then
				if ( !player:IsOnGround() ) then
					player:ProgressAttribute(ATB_ACROBATICS, 0.25, true);
				elseif (infoTable.running) then
					player:ProgressAttribute(ATB_AGILITY, 0.125, true);
				elseif (infoTable.jogging) then
					player:ProgressAttribute(ATB_AGILITY, 0.0625, true);
				end;
			end;
		end;
	end;
	
	if ( openAura.player:HasAnyFlags(player, "vV") ) then
		if (infoTable.wages == 0) then
			infoTable.wages = 20;
		end;
	end;
	
	if ( self.scanners[player] ) then
		self:CalculateScannerThink(player, curTime);
	end;
	
	local acrobatics = openAura.attributes:Fraction(player, ATB_ACROBATICS, 100, 50);
	local strength = openAura.attributes:Fraction(player, ATB_STRENGTH, 8, 4);
	local agility = openAura.attributes:Fraction(player, ATB_AGILITY, 50, 25);
	
	if ( self:PlayerIsCombine(player) ) then
		infoTable.inventoryWeight = infoTable.inventoryWeight + 8;
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
end;

-- Called when an entity is removed.
function openAura.schema:EntityRemoved(entity)
	if (IsValid(entity) and entity:GetClass() == "prop_ragdoll") then
		if (entity.areBelongings and entity.inventory and entity.cash) then
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

-- Called when the player attempts to be ragdolled.
function openAura.schema:PlayerCanRagdoll(player, state, delay, decay, ragdoll)
	if ( self.scanners[player] ) then
		return false;
	end;
end;

-- Called when a player attempts to NoClip.
function openAura.schema:PlayerNoClip(player)
	if ( self.scanners[player] ) then
		return false;
	end;
end;

-- Called when a player's data should be saved.
function openAura.schema:PlayerSaveData(player, data)
	if (data["serverwhitelist"] and table.Count( data["serverwhitelist"] ) == 0) then
		data["serverwhitelist"] = nil;
	end;
end;

-- Called when a player's data should be restored.
function openAura.schema:PlayerRestoreData(player, data)
	if ( !data["serverwhitelist"] ) then
		data["serverwhitelist"] = {};
	end;
	
	local serverWhitelistIdentity = openAura.config:Get("server_whitelist_identity"):Get();
	
	if (serverWhitelistIdentity != "") then
		if ( !data["serverwhitelist"][serverWhitelistIdentity] ) then
			player:Kick("You aren't whitelisted");
		end;
	end;
end;

-- Called to check if a player does have an flag.
function openAura.schema:PlayerDoesHaveFlag(player, flag)
	if ( !openAura.config:Get("permits"):Get() ) then
		if (flag == "x" or flag == "1") then
			return false;
		end;
		
		for k, v in pairs(self.customPermits) do
			if (v.flag == flag) then
				return false;
			end;
		end;
	end;
end;

-- Called when a player's attribute has been updated.
function openAura.schema:PlayerAttributeUpdated(player, attributeTable, amount)
	if (self:PlayerIsCombine(player) and amount and amount > 0) then
		self:AddCombineDisplayLine("Updating external "..openAura.option:GetKey("name_attributes", true).."...", Color(255, 125, 0, 255), player);
	end;
end;

-- Called to check if a player does recognise another player.
function openAura.schema:PlayerDoesRecognisePlayer(player, target, status, isAccurate, realValue)
	if (self:PlayerIsCombine(target) or target:QueryCharacter("faction") == FACTION_ADMIN) then
		return true;
	end;
end;

-- Called when a player attempts to delete a character.
function openAura.schema:PlayerCanDeleteCharacter(player, character)
	if ( character.data["permakilled"] ) then
		return true;
	end;
end;

-- Called when a player attempts to use a character.
function openAura.schema:PlayerCanUseCharacter(player, character)
	if ( character.data["permakilled"] ) then
		return character.name.." is permanently killed and cannot be used!";
	elseif (character.faction == FACTION_MPF) then
		if ( self:IsStringCombineRank(character.name, "SCN") ) then
			local amount = 0;
			
			for k, v in ipairs( _player.GetAll() ) do
				if ( v:HasInitialized() and self:PlayerIsCombine(v) ) then
					if ( self:IsPlayerCombineRank(v, "SCN") ) then
						amount = amount + 1;
					end;
				end;
			end;
			
			if (amount >= 3) then
				return "There are too many scanners online!";
			end;
		end;
	end;
end;

-- Called when attempts to use a command.
function openAura.schema:PlayerCanUseCommand(player, commandTable, arguments)
	if (player:GetSharedVar("tied") != 0) then
		local blacklisted = {
			"OrderShipment",
			"Broadcast",
			"Dispatch",
			"Request",
			"Radio"
		};
		
		if ( table.HasValue(blacklisted, commandTable.name) ) then
			openAura.player:Notify(player, "You cannot use this command when you are tied!");
			
			return false;
		end;
	end;
end;

-- Called when a player attempts to use a door.
function openAura.schema:PlayerCanUseDoor(player, door)
	if ( player:GetSharedVar("tied") != 0 or (!self:PlayerIsCombine(player) and player:QueryCharacter("faction") != FACTION_ADMIN) ) then
		return false;
	end;
end;

-- Called when a player attempts to lock an entity.
function openAura.schema:PlayerCanLockEntity(player, entity)
	if ( openAura.entity:IsDoor(entity) and IsValid(entity.combineLock) ) then
		if ( openAura.config:Get("combine_lock_overrides"):Get() or entity.combineLock:IsLocked() ) then
			return false;
		end;
	end;
end;

-- Called when a player attempts to unlock an entity.
function openAura.schema:PlayerCanUnlockEntity(player, entity)
	if ( openAura.entity:IsDoor(entity) and IsValid(entity.combineLock) ) then
		if ( openAura.config:Get("combine_lock_overrides"):Get() or entity.combineLock:IsLocked() ) then
			return false;
		end;
	end;
end;

-- Called when a player's character has unloaded.
function openAura.schema:PlayerCharacterUnloaded(player)
	self:ResetPlayerScanner(player);
end;

-- Called when a player attempts to change class.
function openAura.schema:PlayerCanChangeClass(player, class)
	if (player:GetSharedVar("tied") != 0) then
		openAura.player:Notify(player, "You cannot change classes when you are tied!");
		
		return false;
	elseif ( self:PlayerIsCombine(player) ) then
		if ( class == CLASS_MPS and !self:IsPlayerCombineRank(player, "SCN") ) then
			openAura.player:Notify(player, "You are not ranked high enough for this class!");
			
			return false;
		elseif ( class == CLASS_MPR and !self:IsPlayerCombineRank(player, "RCT") ) then
			openAura.player:Notify(player, "You are not ranked high enough for this class!");
			
			return false;
		elseif ( class == CLASS_EMP and !self:IsPlayerCombineRank(player, "EpU") ) then
			openAura.player:Notify(player, "You are not ranked high enough for this class!");
			
			return false;
		elseif ( class == CLASS_OWS and !self:IsPlayerCombineRank(player, "OWS") ) then
			openAura.player:Notify(player, "You are not ranked high enough for this class!");
			
			return false;
		elseif ( class == CLASS_EOW and !self:IsPlayerCombineRank(player, "EOW") ) then
			openAura.player:Notify(player, "You are not ranked high enough for this class!");
			
			return false;
		elseif (class == CLASS_MPU) then
			if ( self:IsPlayerCombineRank(player, "EpU") ) then
				openAura.player:Notify(player, "You are ranked too high for this class!");
				
				return false;
			elseif ( self:IsPlayerCombineRank(player, "RCT") ) then
				openAura.player:Notify(player, "You are not ranked high enough for this class!");
				
				return false;
			end;
		end;
	end;
end;

-- Called when a player attempts to use an entity.
function openAura.schema:PlayerUse(player, entity)
	local overlayText = entity:GetNetworkedString("GModOverlayText");
	local curTime = CurTime();
	local faction = player:QueryCharacter("faction");
	
	if ( string.find(overlayText, "CA") ) then
		if (faction != FACTION_ADMIN) then
			return false;
		end;
	elseif ( string.find(overlayText, "OTA") ) then
		if (faction != FACTION_ADMIN and faction != FACTION_OTA) then
			return false;
		end;
	elseif ( string.find(overlayText, "MPF") ) then
		if (faction != FACTION_ADMIN and faction != FACTION_OTA and faction != FACTION_MPF) then
			return false;
		end;
	elseif ( string.find(overlayText, "CWU") ) then
		if (faction != FACTION_ADMIN and faction != FACTION_OTA and faction != FACTION_MPF) then
			if (player:GetCharacterData("customclass") != "Civil Worker's Union") then
				return false;
			end;
		end;
	end;
	
	if ( self.scanners[player] ) then
		return false;
	end;
	
	if (entity.bustedDown) then
		return false;
	end;
	
	if ( player:KeyDown(IN_SPEED) and openAura.entity:IsDoor(entity) ) then
		if ( (self:PlayerIsCombine(player) or player:QueryCharacter("faction") == FACTION_ADMIN) and IsValid(entity.combineLock) ) then
			if (!player.nextCombineLock or curTime >= player.nextCombineLock) then
				entity.combineLock:ToggleWithChecks(player);
				
				player.nextCombineLock = curTime + 3;
			end;
			
			return false;
		end;
	end;
	
	if (player:GetSharedVar("tied") != 0) then
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
	if ( self.scanners[player] ) then
		if (!noMessage) then
			openAura.player:Notify(player, "You cannot destroy items when you are a scanner!");
		end;
		
		return false;
	elseif (player:GetSharedVar("tied") != 0) then
		if (!noMessage) then
			openAura.player:Notify(player, "You cannot destroy items when you are tied!");
		end;
		
		return false;
	end;
end;

-- Called when a player attempts to drop an item.
function openAura.schema:PlayerCanDropItem(player, itemTable, noMessage)
	if ( self.scanners[player] ) then
		if (!noMessage) then
			openAura.player:Notify(player, "You cannot drop items when you are a scanner!");
		end;
		
		return false;
	elseif (player:GetSharedVar("tied") != 0) then
		if (!noMessage) then
			openAura.player:Notify(player, "You cannot drop items when you are tied!");
		end;
		
		return false;
	end;
end;

-- Called when a player attempts to use an item.
function openAura.schema:PlayerCanUseItem(player, itemTable, noMessage)
	if ( self.scanners[player] ) then
		if (!noMessage) then
			openAura.player:Notify(player, "You cannot use items when you are a scanner!");
		end;
		
		return false;
	elseif (player:GetSharedVar("tied") != 0) then
		if (!noMessage) then
			openAura.player:Notify(player, "You cannot use items when you are tied!");
		end;
		
		return false;
	end;
	
	if (openAura.item:IsWeapon(itemTable) and !itemTable.fakeWeapon) then
		local secondaryWeapon;
		local primaryWeapon;
		local sideWeapon;
		local fault;
		
		for k, v in ipairs( player:GetWeapons() ) do
			local weaponTable = openAura.item:GetWeapon(v);
			
			if (weaponTable and !weaponTable.fakeWeapon) then
				if (weaponTable.weight >= 1) then
					if (weaponTable.weight <= 2) then
						secondaryWeapon = true;
					else
						primaryWeapon = true;
					end;
				else
					sideWeapon = true;
				end;
			end;
		end;
		
		if (itemTable.weight >= 1) then
			if (itemTable.weight <= 2) then
				if (secondaryWeapon) then
					fault = "You cannot use another secondary weapon!";
				end;
			elseif (primaryWeapon) then
				fault = "You cannot use another secondary weapon!";
			end;
		elseif (sideWeapon) then
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

-- Called when a player attempts to earn generator cash.
function openAura.schema:PlayerCanEarnGeneratorCash(player, info, cash)
	if ( self:PlayerIsCombine(player) ) then
		return false;
	end;
end;

-- Called when a player's death sound should be played.
function openAura.schema:PlayerPlayDeathSound(player, gender)
	if ( self:PlayerIsCombine(player) ) then
		local sound = "npc/metropolice/die"..math.random(1, 4)..".wav";
		
		for k, v in ipairs( _player.GetAll() ) do
			if ( v:HasInitialized() ) then
				if ( self:PlayerIsCombine(v) ) then
					v:EmitSound(sound);
				end;
			end;
		end;
		
		return sound;
	end;
end;

-- Called when a player's pain sound should be played.
function openAura.schema:PlayerPlayPainSound(player, gender, damageInfo, hitGroup)
	if ( self:PlayerIsCombine(player) ) then
		return "npc/metropolice/pain"..math.random(1, 4)..".wav";
	end;
end;
-- Called when chat box info should be adjusted.
function openAura.schema:ChatBoxAdjustInfo(info)
	if (info.class != "ooc" and info.class != "looc") then
		if ( IsValid(info.speaker) and info.speaker:HasInitialized() ) then
			if (string.sub(info.text, 1, 1) == "?") then
				info.text = string.sub(info.text, 2);
				info.data.anon = true;
			end;
		end;
	end;
	
	if (info.class == "ic" or info.class == "yell" or info.class == "radio" or info.class == "whisper" or info.class == "request") then
		if ( IsValid(info.speaker) and info.speaker:HasInitialized() ) then
			local playerIsCombine = self:PlayerIsCombine(info.speaker);
			
			if ( playerIsCombine and self:IsPlayerCombineRank(info.speaker, "SCN") ) then
				for k, v in pairs(self.dispatchVoices) do
					if ( string.lower(info.text) == string.lower(v.command) ) then
						local voice = {
							global = false,
							volume = 90,
							sound = v.sound
						};
						
						if (info.class == "request" or info.class == "radio") then
							voice.global = true;
						elseif (info.class == "whisper") then
							voice.volume = 80;
						elseif (info.class == "yell") then
							voice.volume = 100;
						end;
						
						info.text = "<:: "..v.phrase;
						info.voice = voice;
						
						return true;
					end;
				end;
			else
				for k, v in pairs(self.voices) do
					if ( (v.faction == "Combine" and playerIsCombine) or (v.faction == "Human" and !playerIsCombine) ) then
						if ( string.lower(info.text) == string.lower(v.command) ) then
							local voice = {
								global = false,
								volume = 80,
								sound = v.sound
							};
							
							if (v.female and info.speaker:QueryCharacter("gender") == GENDER_FEMALE) then
								voice.sound = string.Replace(voice.sound, "/male", "/female");
							end;
							
							if (info.class == "request" or info.class == "radio") then
								voice.global = true;
							elseif (info.class == "whisper") then
								voice.volume = 60;
							elseif (info.class == "yell") then
								voice.volume = 100;
							end;
							
							if (playerIsCombine) then
								info.text = "<:: "..v.phrase;
							else
								info.text = v.phrase;
							end;
							
							info.voice = voice;
							
							return true;
						end;
					end;
				end;
			end;
			
			if (playerIsCombine) then
				if (string.sub(info.text, 1, 4) != "<:: ") then
					info.text = "<:: "..info.text;
				end;
			end;
		end;
	elseif (info.class == "dispatch") then
		for k, v in pairs(self.dispatchVoices) do
			if ( string.lower(info.text) == string.lower(v.command) ) then
				openAura.player:PlaySound(nil, v.sound);
				
				info.text = v.phrase;
				
				return true;
			end;
		end;
	end;
end;

-- Called when a player destroys generator.
function openAura.schema:PlayerDestroyGenerator(player, entity, generator)
	if ( self:PlayerIsCombine(player) ) then
		local players = {};
		
		for k, v in ipairs( _player.GetAll() ) do
			if ( v:HasInitialized() ) then
				if ( self:PlayerIsCombine(v) ) then
					players[#players + 1] = v;
				end;
			end;
		end;
		
		for k, v in pairs(players) do
			openAura.player:GiveCash( v, generator.cash / 4, "destroying a "..string.lower(generator.name) );
		end;
	else
		openAura.player:GiveCash( v, generator.cash / 4, "destroying a "..string.lower(generator.name) );
	end;
end;

-- Called just before a player dies.
function openAura.schema:DoPlayerDeath(player, attacker, damageInfo)
	local clothes = player:GetCharacterData("clothes");
	
	if (clothes) then
		player:UpdateInventory(clothes);
		player:SetCharacterData("clothes", nil);
	end;
	
	player.beingSearched = nil;
	player.searching = nil;
	
	self:TiePlayer(player, false, true);
end;

-- Called when a player dies.
function openAura.schema:PlayerDeath(player, inflictor, attacker, damageInfo)
	if ( self:PlayerIsCombine(player) ) then
		local location = self:PlayerGetLocation(player);
		
		self:AddCombineDisplayLine("Downloading lost biosignal...", Color(255, 255, 255, 255), nil, player);
		self:AddCombineDisplayLine("WARNING! Biosignal lost for protection team unit at "..location.."...", Color(255, 0, 0, 255), nil, player);
		
		if ( self.scanners[player] ) then
			if ( IsValid( self.scanners[player][1] ) ) then
				if (damageInfo != true) then
					self.scanners[player][1]:TakeDamage(self.scanners[player][1]:Health() + 100);
				end;
			end;
		end;
		
		for k, v in ipairs( _player.GetAll() ) do
			if ( self:PlayerIsCombine(v) ) then
				v:EmitSound("npc/overwatch/radiovoice/on1.wav");
				v:EmitSound("npc/overwatch/radiovoice/lostbiosignalforunit.wav");
			end;
		end;
		
		timer.Simple(1.5, function()
			for k, v in ipairs( _player.GetAll() ) do
				if ( self:PlayerIsCombine(v) ) then
					v:EmitSound("npc/overwatch/radiovoice/off4.wav");
				end;
			end;
		end);
	end;
	
	if ( !player:GetCharacterData("permakilled") ) then
		if ( ( attacker:IsPlayer() or attacker:IsNPC() ) and damageInfo ) then
			local miscellaneousDamage = damageInfo:IsBulletDamage() or damageInfo:IsFallDamage() or damageInfo:IsExplosionDamage();
			local meleeDamage = damageInfo:IsDamageType(DMG_CLUB) or damageInfo:IsDamageType(DMG_SLASH);
			
			if (miscellaneousDamage or meleeDamage) then
				if (openAura:GetSharedVar("PKMode") == 1) then
					self:PermaKillPlayer( player, player:GetRagdollEntity() );
				end;
			end;
		end;
	end;
end;

-- Called when a player's character has loaded.
function openAura.schema:PlayerCharacterLoaded(player)
	player:SetSharedVar("permaKilled", false);
	player:SetSharedVar("tied", 0);
end;

-- Called when a player attempts to switch to a character.
function openAura.schema:PlayerCanSwitchCharacter(player, character)
	if (player:GetSharedVar("tied") != 0) then
		return false, "You cannot switch to this character while tied!";
	end;
end;

-- Called just after a player spawns.
function openAura.schema:PostPlayerSpawn(player, lightSpawn, changeClass, firstSpawn)
	local clothes = player:GetCharacterData("clothes");
	
	if (!lightSpawn) then
		player:SetSharedVar("antidepressants", 0);
		
		umsg.Start("aura_ClearEffects", player);
		umsg.End();
		
		player.beingSearched = nil;
		player.searching = nil;
		
		if (self:PlayerIsCombine(player) or player:QueryCharacter("faction") == FACTION_ADMIN) then
			if (player:QueryCharacter("faction") == FACTION_OTA) then
				player:SetMaxHealth(150);
				player:SetMaxArmor(150);
				player:SetHealth(150);
				player:SetArmor(150);
			elseif ( !self:IsPlayerCombineRank(player, "RCT") ) then
				player:SetArmor(100);
			else
				player:SetArmor(50);
			end;
		end;
		
		if (self:PlayerIsCombine(player) and player:GetAmmoCount("pistol") == 0) then
			if ( !player:HasItem("ammo_pistol") ) then
				player:UpdateInventory("ammo_pistol", 1, true, true);
			end;
		end;
	end;
	
	if ( self:PlayerIsCombine(player) and self:IsPlayerCombineRank(player, "SCN") ) then
		self:MakePlayerScanner(player, true, lightSpawn);
	else
		self:ResetPlayerScanner(player);
	end;
	
	if (player:GetSharedVar("tied") != 0) then
		self:TiePlayer(player, true);
	end;
	
	if (clothes) then
		local itemTable = openAura.item:Get(clothes);
		
		if ( itemTable and player:HasItem(itemTable.uniqueID) ) then
			self:PlayerWearClothes(player, itemTable);
		else
			player:SetCharacterData("clothes", nil);
		end;
	end;
end;

-- Called when a player spawns lightly.
function openAura.schema:PostPlayerLightSpawn(player, weapons, ammo, special)
	local clothes = player:GetCharacterData("clothes");
	
	if (clothes) then
		local itemTable = openAura.item:Get(clothes);
		
		if (itemTable) then
			itemTable:OnChangeClothes(player, true);
		end;
	end;
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
		if ( !IsValid(entity.combineLock) ) then
			if (!IsValid(activator) or string.lower( entity:GetClass() ) != "prop_door_rotating") then
				openAura.entity:OpenDoor(entity, 0, true, true);
			else
				self:BustDownDoor(activator, entity);
			end;
		elseif ( IsValid(activator) and activator:IsPlayer() and self:PlayerIsCombine(activator) ) then
			if (string.lower( entity:GetClass() ) == "prop_door_rotating") then
				entity.combineLock:ActivateSmokeCharge( (entity:GetPos() - activator:GetPos() ):Normalize() * 10000 );
			else
				entity.combineLock:SetFlashDuration(2);
			end;
		else
			entity.combineLock:SetFlashDuration(2);
		end;
	end;
end;

-- Called when a player takes damage.
function openAura.schema:PlayerTakeDamage(player, inflictor, attacker, hitGroup, damageInfo)
	local curTime = CurTime();
	
	if (player:Armor() <= 0) then
		umsg.Start("aura_Stunned", player);
			umsg.Float(0.5);
		umsg.End();
	else
		umsg.Start("aura_Stunned", player);
			umsg.Float(1);
		umsg.End();
	end;
end;

-- Called when a player's limb damage is healed.
function openAura.schema:PlayerLimbDamageHealed(player, hitGroup, amount)
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
function openAura.schema:PlayerLimbDamageReset(player)
	player:BoostAttribute("Limb Damage", nil, false);
end;

-- Called when a player's limb takes damage.
function openAura.schema:PlayerLimbTakeDamage(player, hitGroup, damage)
	local limbDamage = openAura.limb:GetDamage(player, hitGroup);
	
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
function openAura.schema:PlayerScaleDamageByHitGroup(player, attacker, hitGroup, damageInfo, baseDamage)
	local endurance = openAura.attributes:Fraction(player, ATB_ENDURANCE, 0.75, 0.75);
	local clothes = player:GetCharacterData("clothes");
	
	damageInfo:ScaleDamage(1.5 - endurance);
	
	if ( damageInfo:IsBulletDamage() ) then
		if ( clothes and damageInfo:IsBulletDamage() ) then
			local itemTable = openAura.item:Get(clothes);
			
			if (itemTable and itemTable.protection) then
				damageInfo:ScaleDamage(1 - itemTable.protection);
			end;
		end;
	end;
end;

-- Called when an entity takes damage.
function openAura.schema:EntityTakeDamage(entity, inflictor, attacker, amount, damageInfo)
	local player = openAura.entity:GetPlayer(entity);
	local curTime = CurTime();
	local doDoorDamage = nil;
	
	if (player) then
		if (!player.nextEnduranceTime or CurTime() > player.nextEnduranceTime) then
			player:ProgressAttribute(ATB_ENDURANCE, math.Clamp(damageInfo:GetDamage(), 0, 75) / 10, true);
			player.nextEnduranceTime = CurTime() + 2;
		end;
		
		if ( self.scanners[player] ) then
			entity:EmitSound("npc/scanner/scanner_pain"..math.random(1, 2)..".wav");
			
			if (entity:Health() > 50 and entity:Health() - damageInfo:GetDamage() <= 50) then
				entity:EmitSound("npc/scanner/scanner_siren1.wav");
			elseif (entity:Health() > 25 and entity:Health() - damageInfo:GetDamage() <= 25) then
				entity:EmitSound("npc/scanner/scanner_siren2.wav");
			end;
		end;
		
		if ( attacker:IsPlayer() and self:PlayerIsCombine(player) ) then
			if (attacker != player) then
				local location = openAura.schema:PlayerGetLocation(player);
				
				if (!player.nextUnderFire or curTime >= player.nextUnderFire) then
					player.nextUnderFire = curTime + 15;
					
					openAura.schema:AddCombineDisplayLine("Downloading trauma packet...", Color(255, 255, 255, 255), nil, player);
					openAura.schema:AddCombineDisplayLine("WARNING! Protection team unit enduring physical bodily trauma at "..location.."...", Color(255, 0, 0, 255), nil, player);
				end;
			end;
		end;
	end;
	
	if ( attacker:IsPlayer() ) then
		local strength = openAura.attributes:Fraction(attacker, ATB_STRENGTH, 1, 0.5);
		local weapon = openAura.player:GetWeaponClass(attacker);
		
		if ( damageInfo:IsDamageType(DMG_CLUB) or damageInfo:IsDamageType(DMG_SLASH) ) then
			damageInfo:ScaleDamage(1 + strength);
		end;
		
		if (weapon == "weapon_357") then
			damageInfo:ScaleDamage(0.25);
		elseif (weapon == "weapon_crossbow") then
			damageInfo:ScaleDamage(2);
		elseif (weapon == "weapon_shotgun") then
			damageInfo:ScaleDamage(3);
			
			doDoorDamage = true;
		elseif (weapon == "weapon_crowbar") then
			damageInfo:ScaleDamage(0.25);
		elseif (weapon == "aura_stunstick") then
			if (player) then
				if (player:Health() <= 10) then
					damageInfo:ScaleDamage(0.5);
				end;
			end;
		end;
		
		if (damageInfo:IsBulletDamage() and weapon != "weapon_shotgun") then
			if ( !IsValid(entity.combineLock) and !IsValid(entity.breach) ) then
				if (string.lower( entity:GetClass() ) == "prop_door_rotating") then
					if ( !openAura.entity:IsDoorFalse(entity) ) then
						local damagePosition = damageInfo:GetDamagePosition();
						
						if (entity:WorldToLocal(damagePosition):Distance( Vector(-1.0313, 41.8047, -8.1611) ) <= 8) then
							entity.doorHealth = math.min( (entity.doorHealth or 50) - damageInfo:GetDamage(), 0 );
							
							local effectData = EffectData();
							
							effectData:SetStart(damagePosition);
							effectData:SetOrigin(damagePosition);
							effectData:SetScale(8);
							
							util.Effect("GlassImpact", effectData, true, true);
							
							if (entity.doorHealth <= 0) then
								openAura.entity:OpenDoor( entity, 0, true, true, attacker:GetPos() );
								
								entity.doorHealth = 50;
							else
								openAura:CreateTimer("reset_door_health_"..entity:EntIndex(), 60, 1, function()
									if ( IsValid(entity) ) then
										entity.doorHealth = 50;
									end;
								end);
							end;
						end;
					end;
				end;
			end;
		end;
		
		if ( damageInfo:IsExplosionDamage() ) then
			damageInfo:ScaleDamage(2);
		end;
	elseif ( attacker:IsNPC() ) then
		damageInfo:ScaleDamage(0.5);
	end;
	
	if (damageInfo:IsExplosionDamage() or doDoorDamage) then
		if ( !IsValid(entity.combineLock) and !IsValid(entity.breach) ) then
			if (string.lower( entity:GetClass() ) == "prop_door_rotating") then
				if ( !openAura.entity:IsDoorFalse(entity) ) then
					if (attacker:GetPos():Distance( entity:GetPos() ) <= 96) then
						entity.doorHealth = math.min( (entity.doorHealth or 50) - damageInfo:GetDamage(), 0 );
						
						local damagePosition = damageInfo:GetDamagePosition();
						local effectData = EffectData();
						
						effectData:SetStart(damagePosition);
						effectData:SetOrigin(damagePosition);
						effectData:SetScale(8);
						
						util.Effect("GlassImpact", effectData, true, true);
						
						if (entity.doorHealth <= 0) then
							self:BustDownDoor(attacker, entity);
							
							entity.doorHealth = 50;
						else
							openAura:CreateTimer("reset_door_health_"..entity:EntIndex(), 60, 1, function()
								if ( IsValid(entity) ) then
									entity.doorHealth = 50;
								end;
							end);
						end;
					end;
				end;
			end;
		end;
	end;
end;