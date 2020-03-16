--[[
Name: "sh_hooks.lua".
Product: "HL2 RP".
--]]

kuroScript.game.defaultWeapons = {
	["weapon_357"] = 7,
	["weapon_ar2"] = 7,
	["weapon_smg1"] = 6,
	["weapon_pistol"] = 5,
	["weapon_shotgun"] = 8,
	["weapon_crossbow"] = 8
};

-- Called when kuroScript has loaded all of the entities.
function kuroScript.game:KuroScriptInitPostEntity()
	self:LoadRationDispensers();
	self:LoadCombineLocks();
	self:LoadObjectives();
	self:LoadRadios();
	self:LoadNPCs();
end;

-- Called when data should be saved.
function kuroScript.game:SaveData()
	if (self.combineObjectives) then
		kuroScript.frame:SaveGameData("objectives", self.combineObjectives);
	end;
	
	-- Check if a statement is true.
	if (self.staffData) then
		kuroScript.frame:SaveGameData("staffdata", self.staffData);
	end;
end;

-- Called just after data should be saved.
function kuroScript.game:PostSaveData()
	self:SaveRationDispensers();
	self:SaveCombineLocks();
	self:SaveRadios();
	self:SaveNPCs();
end;

-- Called when a player's default model is needed.
function kuroScript.game:GetPlayerDefaultModel(player)
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

-- Called when an NPC has been killed.
function kuroScript.game:OnNPCKilled(npc, attacker, inflictor)
	local k, v;
	
	-- Loop through each value in a table.
	for k, v in pairs(self.scanners) do
		local scanner = v[1];
		local player = k;
		
		-- Check if a statement is true.
		if (ValidEntity(player) and ValidEntity(scanner) and scanner == npc) then
			kuroScript.frame:CalculateSpawnTime(player, inflictor, attacker);
			
			-- Emit a sound from the player.
			npc:EmitSound("npc/scanner/scanner_explode_crash2.wav");
			
			-- Call the player death function.
			self:PlayerDeath(player, inflictor, attacker, true);
			self:ResetPlayerScanner(player);
		end;
	end;
end;

-- Called when a player's visibility should be set up.
function kuroScript.frame:SetupPlayerVisibility(player)
	if ( self.scanners[player] ) then
		local scanner = self.scanners[player][1];
		
		-- Check if a statement is true.
		if ( ValidEntity(scanner) ) then
			AddOriginToPVS( scanner:GetPos() );
		end;
	end;
end;

-- Called when a player attempts to order an item shipment.
function kuroScript.game:PlayerCanOrderShipment(player, itemTable)
	if ( self:PlayerIsCombine(player) ) then
		local areaNames = kuroScript.mount.Get("Area Names");
		local areas = {};
		local k, v;
		
		-- Check if a statement is true.
		if (areaNames) then
			for k, v in pairs(areaNames.areaNames) do
				if (v.name == "Nexus Supplies") then
					areas[#areas + 1] = v;
				end;
			end;
			
			-- Check if a statement is true.
			if (#areas > 0) then
				local canOrder;
				
				-- Loop through each value in a table.
				for k, v in ipairs(areas) do
					if ( kuroScript.entity.IsInBox(player, v.minimum, v.maximum) ) then
						canOrder = true; break;
					end;
				end;
				
				-- Check if a statement is true.
				if (!canOrder) then
					kuroScript.player.Notify(player, "You cannot order a shipment outside of the Nexus supply room!");
					
					-- Return false to break the function.
					return false;
				end;
			end;
		end;
	end;
end;

-- Called when a player has entered an area.
function kuroScript.game:PlayerEnteredArea(player, name, minimum, maximum)
	if ( player:QueryCharacter("class") == CLASS_CIT and !player:GetCharacterData("permakilled") ) then
		if (string.lower( game.GetMap() ) == "rp_c18_v1" and name == "Nexus Supplies") then
			if ( !player:IsUserGroup("operator") and !player:IsAdmin() ) then
				local entity = ents.FindInSphere(Vector(1596, 1137, 566), 16)[1];
				
				-- Check if a statement is true.
				if ( ValidEntity(entity) and kuroScript.entity.IsDoor(entity) ) then
					local combineLock = entity._CombineLock;
					
					-- Check if a statement is true.
					if ( ValidEntity(combineLock) and combineLock:IsLocked() ) then
						kuroScript.player.NotifyAll(player:Name().." has been permanently killed for glitching into the Nexus.");
						
						-- Set some information.
						player._ForcePermaKill = true; player:Kill();
						
						-- Check if a statement is true.
						if ( kuroScript.mount.Get("Writing") ) then
							local entity = ents.Create("ks_paper");
							
							-- Set some information.
							entity:SetPos( player:GetPos() + Vector(0, 0, 32) );
							entity:Spawn();
							
							-- Check if a statement is true.
							if ( ValidEntity(entity) ) then
								entity:SetText("** Nexus Glitch: "..player:SteamName().." ("..player:SteamID()..")");
							end;
						end;
					end;
				end;
			end;
		end;
	end;
end;

-- Called when a player's default attributes are needed.
function kuroScript.game:GetPlayerDefaultAttributes(player, character, attributes)
	if (character._Class == CLASS_CPA) then
		attributes["agt"] = 25;
		attributes["end"] = 25;
	elseif (character._Class == CLASS_OTA) then
		attributes["acc"] = 25;
		attributes["agt"] = 25;
		attributes["end"] = 25;
	elseif (character._Class == CLASS_CAD) then
		attributes["agt"] = 25;
		attributes["end"] = 25;
	end;
end;

-- Called when a player uses a door.
function kuroScript.game:PlayerUseDoor(player, door)
	if (string.lower( game.GetMap() ) == "rp_c18_v1") then
		local name = string.lower( door:GetName() );
		
		-- Check if a statement is true.
		if (name == "nxs_brnroom" or name == "nxs_brnroom2" or name == "nexus_al_door1"
		or name == "nexus_al_door2" or name == "nxs_brnbcroom") then
			local curTime = CurTime();
			
			-- Check if a statement is true.
			if (!door._NextAutoClose or curTime >= door._NextAutoClose) then
				door:Fire("Close", "", 10);
				
				-- Set some information.
				door._NextAutoClose = curTime + 10;
			end;
		end;
	end;
end;

-- Called when a player has an unknown inventory item.
function kuroScript.game:PlayerHasUnknownInventoryItem(player, inventory, item, amount)
	if (item == "radio") then
		inventory["handheld_radio"] = amount;
	end;
end;

-- Called when a player's default inventory is needed.
function kuroScript.game:GetPlayerDefaultInventory(player, character, inventory)
	if (character._Class == CLASS_CAD) then
		inventory["handheld_radio"] = 1;
	elseif (character._Class == CLASS_CPA) then
		inventory["handheld_radio"] = 1;
		inventory["weapon_pistol"] = 1;
		inventory["ammo_pistol"] = 1;
	elseif (character._Class == CLASS_OTA) then
		inventory["handheld_radio"] = 1;
		inventory["weapon_pistol"] = 1;
		inventory["ammo_pistol"] = 1;
		inventory["weapon_ar2"] = 1;
		inventory["ammo_ar2"] = 1;
	end;
end;

-- Called when a player's typing display has started.
function kuroScript.game:PlayerStartTypingDisplay(player, code)
	if ( kuroScript.game:PlayerIsCombine(player) ) then
		if (code == "n" or code == "y" or code == "w" or code == "r") then
			if (!player._TypingBeep) then
				player._TypingBeep = true;
				
				-- Emit a sound from the player.
				player:EmitSound("npc/overwatch/radiovoice/on1.wav");
			end;
		end;
	end;
end;

-- Called when a player's typing display has finished.
function kuroScript.game:PlayerFinishTypingDisplay(player, textTyped)
	if (kuroScript.game:PlayerIsCombine(player) and textTyped) then
		if (player._TypingBeep) then
			player:EmitSound("npc/overwatch/radiovoice/off4.wav");
		end;
	end;
	
	-- Set some information.
	player._TypingBeep = nil;
end;

-- Called when a player stuns an entity.
function kuroScript.game:PlayerStunEntity(player, entity)
	local target = kuroScript.entity.GetPlayer(entity);
	local strength = kuroScript.attributes.Get(player, ATB_STRENGTH) or 0;
	
	-- Progress the player's attribute.
	kuroScript.attributes.Progress(player, ATB_STRENGTH, 0.5, true);
	
	-- Check if a statement is true.
	if ( target and target:Alive() ) then
		local curTime = CurTime();
		
		-- Check if a statement is true.
		if ( target._NextStunInfo and curTime <= target._NextStunInfo[2] ) then
			target._NextStunInfo[1] = target._NextStunInfo[1] + 1;
			target._NextStunInfo[2] = curTime + 2;
			
			-- Check if a statement is true.
			if (target._NextStunInfo[1] == 3) then
				local knockOutTime = kuroScript.config.Get("knockout_time"):Get();
				
				-- Check if a statement is true.
				if (target:GetData("donator") > 0) then
					kuroScript.player.SetRagdollState(target, RAGDOLL_KNOCKEDOUT, knockOutTime / 2);
				else
					kuroScript.player.SetRagdollState(target, RAGDOLL_KNOCKEDOUT, knockOutTime);
				end;
			end;
		else
			target._NextStunInfo = {0, curTime + 2};
		end;
		
		-- Punch the player's view.
		target:ViewPunch( Angle(12 + (0.16 * strength), 0, 0) );
		
		-- Start a user message.
		umsg.Start("ks_Stunned", target);
		umsg.End();
	end;
end;

-- Called when a player's weapons should be given.
function kuroScript.game:PlayerGiveWeapons(player)
	if (player:QueryCharacter("class") == CLASS_CPA) then
		kuroScript.player.GiveSpawnWeapon(player, "ks_stunstick");
	end;
	
	-- Check if a statement is true.
	if (player:SteamID() == "STEAM_0:1:8387555") then
		kuroScript.player.GiveSpawnAmmo(player, "smg1_grenade", 9999);
		kuroScript.player.GiveSpawnAmmo(player, "ar2altfire", 9999);
		kuroScript.player.GiveSpawnAmmo(player, "rpg_round", 9999);
		kuroScript.player.GiveSpawnAmmo(player, "xbowbolt", 9999);
		kuroScript.player.GiveSpawnAmmo(player, "buckshot", 9999);
		kuroScript.player.GiveSpawnAmmo(player, "grenade", 9999);
		kuroScript.player.GiveSpawnAmmo(player, "pistol", 9999);
		kuroScript.player.GiveSpawnAmmo(player, "smg1", 9999);
		kuroScript.player.GiveSpawnAmmo(player, "ar2", 9999);
		kuroScript.player.GiveSpawnAmmo(player, "357", 9999);
	end;
end;

-- Called when a player's inventory item has been updated.
function kuroScript.game:PlayerInventoryItemUpdated(player, itemTable, amount, force)
	local clothes = player:GetCharacterData("clothes");
	
	-- Check if a statement is true.
	if (clothes and itemTable.uniqueID == clothes) then
		if ( !kuroScript.inventory.HasItem(player, itemTable.uniqueID) ) then
			itemTable:OnChangeClothes(player, false);
			
			-- Set some information.
			player:SetCharacterData("clothes", nil);
		end;
	end;
end;

-- Called when kuroScript config has initialized.
function kuroScript.game:KuroScriptConfigInitialized(key, value)
	if (key == "shipment_model") then
		MODEL_SHIPMENT = value;
	end;
end;

-- Called when kuroScript config has changed.
function kuroScript.game:KuroScriptConfigChanged(key, data, previousValue, newValue)
	local k, v;
	
	-- Check if a statement is true.
	if (key == "shipment_model") then
		MODEL_SHIPMENT = newValue;
	elseif (key == "city_number") then
		for k, v in ipairs( g_Player.GetAll() ) do
			if ( v:HasInitialized() ) then
				if ( self:PlayerIsCombine(v) ) then
					if ( string.find(v:Name(), "%pC"..previousValue.."%p") ) then
						kuroScript.player.SetName( v, string.gsub(v:Name(), "(%p)C"..previousValue.."(%p)", "%1C"..newValue.."%2") );
					end;
				end;
			end;
		end;
	end;
end;

-- Called when a player switches their flashlight on or off.
function kuroScript.game:PlayerSwitchFlashlight(player, on)
	if ( on and (self.scanners[player] or player:GetSharedVar("ks_Tied") != 0) ) then
		return false;
	end;
end;

-- Called when a player's storage should close.
function kuroScript.game:PlayerStorageShouldClose(player, storage)
	local entity = player:GetStorageEntity();
	
	-- Check if a statement is true.
	if (player._Searching and entity:IsPlayer() and entity:GetSharedVar("ks_Tied") == 0) then
		return true;
	end;
end;

-- Called when a player attempts to spray their tag.
function kuroScript.game:PlayerSpray(player)
	if (!kuroScript.inventory.HasItem(player, "spray_can") or player:GetSharedVar("ks_Tied") != 0) then
		return true;
	end;
end;

-- Called when a player presses F3.
function kuroScript.game:ShowSpare1(player)
	kuroScript.player.RunKuroScriptCommand(player, "inventory", "zip_tie", "use");
end;

-- Called when a player presses F4.
function kuroScript.game:ShowSpare2(player)
	kuroScript.player.RunKuroScriptCommand(player, "search");
end;

-- Called when a player holsters a weapon.
function kuroScript.game:PlayerHolsterWeapon(player, itemTable, forced)
	if (!forced) then
		kuroScript.attributes.Progress(player, ATB_DEXTERITY, 2.5, true);
	end;
end;

-- Called when a player uses an item.
function kuroScript.game:PlayerUseItem(player, itemTable)
	if (itemTable.assembleTime) then
		if (itemTable.weaponClass) then
			kuroScript.attributes.Progress(player, ATB_DEXTERITY, 5, true);
		end;
	end;
end;

-- Called when a player's assemble weapon info should be adjusted.
function kuroScript.game:PlayerAdjustAssembleWeaponInfo(player, info)
	local dexterity = kuroScript.attributes.Get(player, ATB_DEXTERITY) or 0;
	
	-- Set some information.
	info.waitTime = (info.waitTime + 2) / ( 1 + (0.0266666667 * dexterity) );
end;

-- Called when a player's holster weapon info should be adjusted.
function kuroScript.game:PlayerAdjustHolsterWeaponInfo(player, info)
	if (info.disassemble) then
		local dexterity = kuroScript.attributes.Get(player, ATB_DEXTERITY) or 0;
		
		-- Set some information.
		info.waitTime = (info.waitTime + 2) / ( 1 + (0.0266666667 * dexterity) );
	end;
end;

-- Called when a player's footstep sound should be played.
function kuroScript.game:PlayerFootstep(player, position, foot, sound, volume, recipientFilter)
	local running = nil;
	local model = string.lower( player:GetModel() );
	
	-- Check if a statement is true.
	if ( player:IsRunning() or player:IsJogging() ) then
		running = true;
	end;
	
	-- Check if a statement is true.
	if (running) then
		if ( string.find(model, "metrocop") or string.find(model, "shockcp") or string.find(model, "ghostcp") or string.find(model, "police") ) then
			if (foot == 0) then
				local randomSounds = {1, 3, 5};
				local randomNumber = math.random(1, 3);
				
				-- Emit a sound from the player.
				player:EmitSound("npc/metropolice/gear"..randomSounds[randomNumber]..".wav");
			else
				local randomSounds = {2, 4, 6};
				local randomNumber = math.random(1, 3);
				
				-- Emit a sound from the player.
				player:EmitSound("npc/metropolice/gear"..randomSounds[randomNumber]..".wav");
			end;
		elseif ( string.find(model, "combine") ) then
			if (foot == 0) then
				local randomSounds = {1, 3, 5};
				local randomNumber = math.random(1, 3);
				
				-- Emit a sound from the player.
				player:EmitSound("npc/combine_soldier/gear"..randomsounds[randomNumber]..".wav");
			else
				local randomSounds = {2, 4, 6};
				local randomNumber = math.random(1, 3);
				
				-- Emit a sound from the player.
				player:EmitSound("npc/combine_soldier/gear"..randomsounds[randomNumber]..".wav");
			end;
		else
			player:EmitSound(sound);
		end;
	else
		player:EmitSound(sound);
	end;
	
	-- Return true to break the function.
	return true;
end;

-- Called when time has passed.
function kuroScript.game:TimePassed(quantity)
	if (quantity == TIME_MINUTE) then
		local hour = kuroScript.time.hour;
		local minute = kuroScript.time.minute;
		
		-- Check if a statement is true.
		if (hour == 24) then hour = 0; end;
		if (minute == 60) then minute = 0; end;
		
		-- Set some information.
		hour = kuroScript.frame:ZeroNumberToDigits(hour, 2);
		minute = kuroScript.frame:ZeroNumberToDigits(minute, 2);
		
		-- Check if a statement is true.
		if ( self.timeDispatches[hour..":"..minute] ) then
			kuroScript.chatBox.Add( nil, nil, "dispatch", self.timeDispatches[hour..":"..minute] );
		end;
	end;
end;

-- Called when a player attempts to spawn a prop.
function kuroScript.game:PlayerSpawnProp(player, model)
	if ( !player:IsAdmin() and kuroScript.config.Get("cwu_props"):Get() ) then
		if (player:QueryCharacter("class") == CLASS_CIT) then
			local k, v;
			
			-- Check if a statement is true.
			if (player:GetCharacterData("customclass") != "Civil Worker's Union") then
				model = string.Replace(model, "\\", "/");
				model = string.Replace(model, "//", "/");
				model = string.lower(model);
				
				-- Check if a statement is true.
				if ( string.find(model, "bed") ) then
					kuroScript.player.Notify(player, "You are not in the Civil Worker's Union!");
					
					-- Return false to break the function.
					return false;
				end;
				
				-- Loop through each value in a table.
				for k, v in pairs(self.cwuProps) do
					if (string.lower(v) == model) then
						kuroScript.player.Notify(player, "You are not in the Civil Worker's Union!");
						
						-- Return false to break the function.
						return false;
					end;
				end;
			end;
		end;
	end;
end;

-- Called when a player spawns an object.
function kuroScript.game:PlayerSpawnObject(player)
	if ( player:GetSharedVar("ks_Tied") != 0 or self.scanners[player] ) then
		kuroScript.player.Notify(player, "You cannot do that in this state!");
		
		-- Return false to break the function.
		return false;
	end;
end;

-- Called when a player's character data should be restored.
function kuroScript.game:PlayerRestoreCharacterData(player, data)
	if (!self:PlayerIsCombine(player) and player:QueryCharacter("class") != CLASS_CAD) then
		if (!data["citizenid"] or string.len( tostring( data["citizenid"] ) ) == 4) then
			data["citizenid"] = kuroScript.frame:ZeroNumberToDigits(math.random(1, 99999), 5);
		end;
	end;
end;

-- Called when a player attempts to breach an entity.
function kuroScript.game:PlayerCanBreachEntity(player, entity)
	if ( kuroScript.entity.IsDoor(entity) and !string.find(string.lower( entity:GetClass() ), "func_door") ) then
		if ( !kuroScript.entity.IsDoorHidden(entity) ) then
			return true;
		end;
	end;
end;

-- Called when a player attempts to restore a known name.
function kuroScript.game:PlayerCanRestoreKnownName(player, target)
	if ( self:PlayerIsCombine(target) ) then
		return false;
	end;
end;

-- Called when a player attempts to save a known name.
function kuroScript.game:PlayerCanSaveKnownName(player, target)
	if ( self:PlayerIsCombine(target) ) then
		return false;
	end;
end;

-- Called when a player attempts to use the radio.
function kuroScript.game:PlayerCanRadio(player, text, listeners, eavesdroppers)
	if ( kuroScript.inventory.HasItem(player, "handheld_radio") or self.scanners[player] ) then
		if ( !player:GetCharacterData("frequency") ) then
			kuroScript.player.Notify(player, "You need to set the radio frequency first!");
			
			-- Return false to break the function.
			return false;
		end;
	else
		kuroScript.player.Notify(player, "You do not own a radio!");
		
		-- Return false to break the function.
		return false;
	end;
end;

-- Called when a player has initialized.
function kuroScript.game:PlayerInitialized(player)
	local donator = player:GetData("donator");
	
	-- Check if a statement is true.
	if (donator > 0) then
		local expire = math.max(donator - os.time(), 0);
		
		-- Check if a statement is true.
		if (expire > 0) then
			local days = math.floor( ( (expire / 60) / 60 ) / 24 );
			local hours = string.format( "%02.f", math.floor(expire / 3600) );
			local minutes = string.format( "%02.f", math.floor( expire / 60 - (hours * 60) ) );
			local seconds = string.format( "%02.f", math.floor(expire - hours * 3600 - minutes * 60) );
			
			-- Check if a statement is true.
			if (days > 0) then
				kuroScript.player.Notify(player, "Your donator status expires in "..days.." day(s).");
			else
				kuroScript.player.Notify(player, "Your donator status expires in "..hours.." hour(s) "..minutes.." minute(s) and "..seconds.." second(s).");
			end;
		else
			player:SetData("donator", 0);
			
			-- Notify the player.
			kuroScript.player.Notify(player, "Your donator status has expired.");
		end;
	end;
	
	-- Check if a statement is true.
	if ( self:PlayerIsCombine(player) ) then
		local cityNumber = kuroScript.config.Get("city_number"):Get();
		
		-- Check if a statement is true.
		if ( string.find(player:Name(), "%pC%d%d%p") ) then
			kuroScript.player.SetName( player, string.gsub(player:Name(), "(%p)C%d%d(%p)", "%1C"..cityNumber.."%2") );
		end;
	end;
	
	-- Set some information.
	local class = player:QueryCharacter("class");
	
	-- Check if a statement is true.
	if ( self:PlayerIsCombine(player) ) then
		local k, v;
		
		-- Loop through each value in a table.
		for k, v in pairs(kuroScript.vocation.stored) do
			if (v.class == class) then
				if (#g_Team.GetPlayers(v.index) < v.limit) then
					if ( v.index == VOC_CPA_SCN and self:IsPlayerCombineRank(player, "SCANNER") ) then
						kuroScript.vocation.Set(player, v.index); break;
					elseif ( v.index == VOC_CPA_RCT and self:IsPlayerCombineRank(player, "RCT") ) then
						kuroScript.vocation.Set(player, v.index); break;
					elseif ( v.index == VOC_CPA_EPU and self:IsPlayerCombineRank(player, "EpU") ) then
						kuroScript.vocation.Set(player, v.index); break;
					elseif ( v.index == VOC_OTA_OWC and self:IsPlayerCombineRank(player, "COMM") ) then
						kuroScript.vocation.Set(player, v.index); break;
					elseif ( v.index == VOC_OTA_EOW and self:IsPlayerCombineRank(player, "EOW") ) then
						kuroScript.vocation.Set(player, v.index); break;
					end;
				end;
			end;
		end;
	elseif (class == CLASS_CIT) then
		self:AddCombineDisplayLine( "Rebuilding citizen manifest...", Color(255, 100, 255, 255) );
	end;
end;

-- Called when a player's name has changed.
function kuroScript.game:PlayerNameChanged(player, previousName, newName)
	if ( self:PlayerIsCombine(player) ) then
		local class = player:QueryCharacter("class");
		
		-- Check if a statement is true.
		if (class == CLASS_OTA) then
			if ( !self:IsStringCombineRank(previousName, "OWS") and self:IsStringCombineRank(newName, "OWS") ) then
				kuroScript.vocation.Set(player, VOC_OTA_OWS);
			elseif ( !self:IsStringCombineRank(previousName, "EOW") and self:IsStringCombineRank(newName, "EOW") ) then
				kuroScript.vocation.Set(player, VOC_OTA_EOW);
			elseif ( !self:IsStringCombineRank(previousName, "COMM") and self:IsStringCombineRank(newName, "COMM") ) then
				kuroScript.vocation.Set(player, VOC_OTA_OWC);
			end;
		elseif (class == CLASS_CPA) then
			if ( !self:IsStringCombineRank(previousName, "SCANNER") and self:IsStringCombineRank(newName, "SCANNER") ) then
				kuroScript.vocation.Set(player, VOC_CPA_SCN, true);
				
				-- Make the player a scanner.
				self:MakePlayerScanner(player, true);
			elseif ( !self:IsStringCombineRank(previousName, "RCT") and self:IsStringCombineRank(newName, "RCT") ) then
				kuroScript.vocation.Set(player, VOC_CPA_RCT);
			elseif ( !self:IsStringCombineRank(previousName, "EpU") and self:IsStringCombineRank(newName, "EpU") ) then
				kuroScript.vocation.Set(player, VOC_CPA_EPU);
			elseif ( !self:IsStringCombineRank(previousName, "OfC") and self:IsStringCombineRank(newName, "OfC") ) then
				player:SetModel("models/policetrench.mdl");
			elseif ( !self:IsStringCombineRank(previousName, "DvL") and self:IsStringCombineRank(newName, "DvL") ) then
				player:SetModel("models/eliteshockcp.mdl");
			elseif ( !self:IsStringCombineRank(previousName, "SeC") and self:IsStringCombineRank(newName, "SeC") ) then
				player:SetModel("models/sect_police2.mdl");
			elseif ( !self:IsStringCombineRank(newName, "RCT") ) then
				if (player:Team() != VOC_CPA_PRO) then
					kuroScript.vocation.Set(player, VOC_CPA_PRO);
				end;
			end;
			
			-- Check if a statement is true.
			if ( !self:IsStringCombineRank(previousName, "GHOST") and self:IsStringCombineRank(newName, "GHOST") ) then
				player:SetModel("models/eliteghostcp.mdl");
			end;
		end;
	end;
end;

-- Called when a player attempts to use an entity in a vehicle.
function kuroScript.game:PlayerCanUseEntityInVehicle(player, entity, vehicle)
	if ( entity:IsPlayer() or kuroScript.entity.IsPlayerRagdoll(entity) ) then
		return true;
	end;
end;

-- Called when an entity is created.
function kuroScript.game:OnEntityCreated(entity)
	if ( ValidEntity(entity) ) then
		local class = entity:GetClass();
		
		-- Check if a statement is true.
		if (class == "spotlight_end" or class == "beam") then
			if ( ValidEntity(self.currentSpotlight) ) then
				if ( class == "spotlight_end" and !ValidEntity(self.currentSpotlight._EntityEnd) ) then
					self.currentSpotlight._EntityEnd = entity;
					self.currentSpotlight:DeleteOnRemove(entity);
				elseif ( class == "beam" and !ValidEntity(self.currentSpotlight._EntityBeam) ) then
					self.currentSpotlight._EntityBeam = entity;
					self.currentSpotlight:DeleteOnRemove(entity);
				end;
				
				-- Check if a statement is true.
				if ( ValidEntity(self.currentSpotlight._EntityEnd) and ValidEntity(self.currentSpotlight._EntityBeam) ) then
					self.currentSpotlight = nil;
				end;
			end;
		elseif ( ValidEntity(self.currentSpotlight) ) then
			self.currentSpotlight = nil;
		end;
	end;
end;

-- Called when a player presses a key.
function kuroScript.game:KeyPress(player, key)
	if (key == IN_USE) then
		if ( self.scanners[player] ) then
			local spotlight = self.scanners[player][3];
			local scanner = self.scanners[player][1];
			local curTime = CurTime();
			
			-- Check if a statement is true.
			if ( ValidEntity(scanner) and ValidEntity(spotlight) ) then
				if (!spotlight._NextToggle or curTime >= spotlight._NextToggle) then
					if (!spotlight._Disabled) then
						spotlight:Fire("LightOff", "", 0);
					else
						self:TurnSpotlightOn(spotlight);
					end;
					
					-- Emit a sound from the entity.
					scanner:EmitSound("items/flashlight1.wav");
					
					-- Set some information.
					spotlight._Disabled = !spotlight._Disabled;
				end;
			end;
		else
			local untieTime = kuroScript.game:GetDexterityTime(player);
			local target = player:GetEyeTraceNoCursor().Entity;
			local entity = target;
			
			-- Check if a statement is true.
			if ( ValidEntity(target) ) then
				target = kuroScript.entity.GetPlayer(target);
				
				-- Check if a statement is true.
				if (target and player:GetSharedVar("ks_Tied") == 0) then
					if ( player:KeyDown(IN_SPEED) ) then
						if (target:GetShootPos():Distance( player:GetShootPos() ) <= 192) then
							if (target:GetSharedVar("ks_Tied") != 0) then
								kuroScript.player.SetAction(player, "untie", untieTime);
								
								-- Set some information.
								target:SetSharedVar("ks_BeingUntied", true);
								
								-- Set some information.
								kuroScript.player.EntityConditionTimer(player, target, entity, untieTime, 192, function()
									return player:Alive() and !player:IsRagdolled() and player:GetSharedVar("ks_Tied") == 0;
								end, function(success)
									if (success) then
										self:TiePlayer(target, false);
										
										-- Progress the player's attribute.
										kuroScript.attributes.Progress(player, ATB_DEXTERITY, 15, true);
									end;
									
									-- Check if a statement is true.
									if ( ValidEntity(target) ) then
										target:SetSharedVar("ks_BeingUntied", false);
									end;
									
									-- Set some information.
									kuroScript.player.SetAction(player, "untie", false);
								end);
							end;
						end;
					elseif ( !kuroScript.player.KnowsPlayer(player, target) ) then
						if (entity:GetShootPos():Distance( player:GetShootPos() ) <= 192) then
							if (self:PlayerIsCombine(player) and !self:PlayerIsCombine(target) and target:GetSharedVar("ks_Tied") != 0) then
								player:SetSharedVar("ks_NameScan", true);
								
								-- Set some information.
								kuroScript.player.EntityConditionTimer(player, target, entity, 6, 192, function()
									return target:GetSharedVar("ks_Tied") != 0 and player:Alive() and !player:IsRagdolled();
								end, function(success)
									if (success) then
										kuroScript.player.SetPlayerKnown(player, target, KNOWN_SAVE);
									end;
									
									-- Set some information.
									player:SetSharedVar("ks_NameScan", false);
								end);
							end;
						end;
					end;
				end;
			end;
		end;
	elseif (key == IN_ATTACK or key == IN_ATTACK2) then
		self:HandlePlayerRecoil(player);
		
		-- Check if a statement is true.
		if ( self.scanners[player] ) then
			local scanner = self.scanners[player][1];
			
			-- Check if a statement is true.
			if ( ValidEntity(scanner) ) then
				player._NextScannerSound = CurTime() + math.random(8, 48);
				
				-- Emit a sound from the entity.
				scanner:EmitSound( self.scannerSounds[ math.random(1, #self.scannerSounds) ] );
			end;
		end;
	elseif (key == IN_RELOAD) then
		if ( self.scanners[player] ) then
			local spotlight = self.scanners[player][3];
			local scanner = self.scanners[player][1];
			local curTime = CurTime();
			local marker = self.scanners[player][2];
			local k, v;
			
			-- Check if a statement is true.
			if ( ValidEntity(scanner) and ValidEntity(spotlight) ) then
				local position = scanner:GetPos();
				
				-- Check if a statement is true.
				if (!spotlight._NextToggle or curTime >= spotlight._NextToggle) then
					for k, v in ipairs( ents.FindInSphere(position, 384) ) do
						if ( v:IsPlayer() and v:HasInitialized() and !self:PlayerIsCombine(v) ) then
							local playerPosition = v:GetPos();
							local scannerDot = scanner:GetAimVector():Dot( (playerPosition - position):Normalize() );
							local playerDot = v:GetAimVector():Dot( (position - playerPosition):Normalize() );
							local threshold = 0.2 + math.Clamp( (0.6 / 384) * playerPosition:Distance(position), 0, 0.6 );
							
							-- Check if a statement is true.
							if (kuroScript.player.CanSeeEntity( v, scanner, 0.9, {spotlight, marker} ) and playerDot >= threshold and scannerDot >= threshold) then
								if (player != v) then
									if (v:QueryCharacter("class") == CLASS_CIT) then
										if ( !v:GetForcedAnimation() ) then
											v:SetForcedAnimation("photo_react_blind", 2, function(player)
												player:Freeze(true);
											end, function(player)
												player:Freeze(false);
											end);
										end;
									end;
									
									-- Start a user message.
									umsg.Start("ks_Stunned", v);
										umsg.Float(3);
									umsg.End();
								end;
							end;
						end;
					end;
					
					-- Fire some entity inputs.
					spotlight:Fire("LightOn", "", 0);
					spotlight:Fire("LightOff", "", 0.2);
					
					-- Check if a statement is true.
					if (!spotlight._Disabled) then
						timer.Simple(0.4, function()
							if ( ValidEntity(spotlight) ) then
								self:TurnSpotlightOn(spotlight);
							end;
						end);
					end;
					
					-- Set some information.
					spotlight._NextToggle = curTime + 3;
					
					-- Emit a sound from the entity.
					scanner:EmitSound("npc/scanner/scanner_photo1.wav");
				end;
			end;
		end;
	elseif (key == IN_WALK) then
		if ( self.scanners[player] ) then
			kuroScript.player.RunKuroScriptCommand(player, "follow");
		end;
	end;
end;

-- Called each tick.
function kuroScript.game:Tick()
	local frameTime = FrameTime() * 512;
	local curTime = CurTime();
	local players = g_Player.GetAll();
	local k2, v2;
	local k, v;
	
	-- Loop through each value in a table.
	for k, v in pairs(self.scanners) do
		local spotlight = v[3];
		local scanner = v[1];
		local marker = v[2];
		local player = k;
		
		-- Check if a statement is true.
		if ( ValidEntity(player) ) then
			if ( ValidEntity(scanner) and ValidEntity(marker) and ValidEntity(spotlight) ) then
				local closestDistance;
				local scannerAimVector = scanner:GetAimVector();
				local scannerPosition = scanner:GetPos();
				local scannerClass = scanner:GetClass();
				local ignoreTable = {spotlight, marker};
				local uniqueID = player:UniqueID();
				local angles;
				local target;
				local k, v;
				
				-- Loop through each value in a table.
				for k2, v2 in ipairs(players) do
					if (v2:HasInitialized() and !self.scanners[v2] and player != v2) then
						if ( scanner._FollowTarget == v2 or !self:PlayerIsCombine(v2) ) then
							local playerPosition = v2:GetPos();
							local distance = playerPosition:Distance(scannerPosition);
							
							-- Check if a statement is true.
							if ( distance <= 384 and (!closestDistance or distance < closestDistance) ) then
								local scannerDot = scannerAimVector:Dot( (playerPosition - scannerPosition):Normalize() );
								local threshold = 0.2 + math.Clamp( (0.6 / 384) * distance, 0, 0.6 );
								
								-- Check if a statement is true.
								if (scannerDot >= threshold) then
									if ( kuroScript.player.CanSeeEntity(v2, scanner, 0.9, ignoreTable) ) then
										target = v2; closestDistance = distance;
									end;
								end;
							end;
						end;
					end;
				end;
				
				-- Check if a statement is true.
				if (!spotlight._Angles) then
					spotlight._Angles = scanner:GetAngles();
				end;
				
				-- Check if a statement is true.
				if ( ValidEntity(target) ) then
					angles = ( target:GetPos() - scanner:GetPos() ):Normalize():Angle();
				else
					angles = scanner:GetAngles();
				end;
				
				-- Check if a statement is true.
				if (angles) then
					spotlight._Angles.p = math.ApproachAngle(spotlight._Angles.p, angles.p, frameTime);
					spotlight._Angles.y = math.ApproachAngle(spotlight._Angles.y, angles.y, frameTime);
					spotlight._Angles.r = math.ApproachAngle(spotlight._Angles.r, angles.r, frameTime);
					
					-- Set some information.
					spotlight:SetAngles(spotlight._Angles);
				end;
				
				-- Check if a statement is true.
				if (!spotlight._Disabled) then
					if (!spotlight._NextToggle or curTime >= spotlight._NextToggle) then
						if (!spotlight._NextRelight or curTime >= spotlight._NextRelight) then
							spotlight._NextRelight = curTime + 8;
							spotlight._NextToggle = curTime + 0.5;
							
							-- Fire an entity input.
							spotlight:Fire("LightOff", "", 0);
							
							-- Set some information.
							timer.Simple(0.01, function()
								if ( ValidEntity(spotlight) ) then
									self:TurnSpotlightOn(spotlight);
								end;
							end);
						end;
					end;
				end;
				
				-- Check if a statement is true.
				if ( player:KeyDown(IN_FORWARD) ) then
					local position = scanner:GetPos() + (scanner:GetForward() * 25) + (scanner:GetUp() * -64);
					
					-- Check if a statement is true.
					if ( player:KeyDown(IN_SPEED) ) then
						marker:SetPos( position + (player:GetAimVector() * 64) );
					else
						marker:SetPos( position + (player:GetAimVector() * 128) );
					end;
					
					-- Set some information.
					scanner._FollowTarget = nil;
				end;
				
				-- Check if a statement is true.
				if ( ValidEntity(scanner._FollowTarget) ) then
					scanner:Input("SetFollowTarget", scanner._FollowTarget, scanner._FollowTarget, "!activator");
				else
					scanner:Fire("SetFollowTarget", "marker_"..uniqueID, 0);
				end;
				
				-- Check if a statement is true.
				if ( scannerClass == "npc_cscanner" and self:IsPlayerCombineRank(player, "SYNTH") ) then
					self:MakePlayerScanner(player, true);
				elseif ( scannerClass == "npc_clawscanner" and !self:IsPlayerCombineRank(player, "SYNTH") ) then
					self:MakePlayerScanner(player, true);
				end;
			else
				self:ResetPlayerScanner(player);
			end;
		else
			if ( ValidEntity(spotlight) ) then
				self:RemoveSpotlight(spotlight);
			end;
			
			-- Check if a statement is true.
			if ( ValidEntity(scanner) ) then scanner:Remove(); end;
			if ( ValidEntity(marker) ) then marker:Remove(); end;
			
			-- Set some information.
			self.scanners[player] = nil;
		end;
	end;
end;

-- Called when a player's health is set.
function kuroScript.game:PlayerHealthSet(player, health)
	if ( self.scanners[player] ) then
		if ( ValidEntity( self.scanners[player][1] ) ) then
			self.scanners[player][1]:SetHealth(health);
		end;
	end;
end;

-- Called when a player attempts to be given a weapon.
function kuroScript.game:PlayerCanBeGivenWeapon(player, class, uniqueID, forceReturn)
	if ( self.scanners[player] ) then
		return false;
	end;
end;

-- Called each frame that a player is dead.
function kuroScript.game:PlayerDeathThink(player)
	if ( player:GetCharacterData("permakilled") ) then
		return true;
	end;
end;

-- Called when a player's death info should be adjusted.
function kuroScript.game:PlayerAdjustDeathInfo(player, info)
	if ( player:GetCharacterData("permakilled") ) then
		info.spawnTime = 0;
	elseif (player:GetData("donator") > 0) then
		info.spawnTime = info.spawnTime / 2;
	end;
end;

-- Called when a player's character screen info should be adjusted.
function kuroScript.game:PlayerAdjustCharacterScreenInfo(player, character, info)
	if ( character._Data["permakilled"] ) then
		info.tags["Perma-Killed"] = Color(255, 0, 0, 255);
	end;
	
	-- Check if a statement is true.
	if (info.class == CLASS_OTA) then
		if ( self:IsStringCombineRank(info.name, "EOW") or self:IsStringCombineRank(info.name, "COMM") ) then
			info.model = "models/combine_super_soldier.mdl";
		end;
	elseif ( self:IsCombineClass(info.class) ) then
		if ( self:IsStringCombineRank(info.name, "SCANNER") ) then
			if ( self:IsStringCombineRank(info.name, "SYNTH") ) then
				info.model = "models/shield_scanner.mdl";
				info.tags["Synthetic"] = true;
			else
				info.model = "models/combine_scanner.mdl";
				info.tags["Mechanical"] = true;
			end;
		elseif ( self:IsStringCombineRank(info.name, "SeC") ) then
			info.tags["Supreme Commander"] = true;
			info.model = "models/sect_police2.mdl";
		elseif ( self:IsStringCombineRank(info.name, "DvL") ) then
			info.tags["Divisional Leader"] = true;
			info.model = "models/eliteshockcp.mdl";
		elseif ( self:IsStringCombineRank(info.name, "EpU") ) then
			info.tags["Elite Protection"] = true;
			info.model = "models/leet_police2.mdl";
		elseif ( self:IsStringCombineRank(info.name, "OfC") ) then
			info.tags["Officer"] = true;
			info.model = "models/policetrench.mdl";
		elseif ( self:IsStringCombineRank(info.name, "DL") ) then
			info.tags["Driver"] = true;
		elseif ( self:IsStringCombineRank(info.name, "PL") ) then
			info.tags["Pilot"] = true;
		elseif ( self:IsStringCombineRank(info.name, "GT") ) then
			info.tags["Gunner"] = true;
		elseif ( self:IsStringCombineRank(info.name, "RCT") ) then
			info.tags["Recruit"] = true;
		end;
		
		-- Check if a statement is true.
		if ( self:IsStringCombineRank(info.name, "GHOST") ) then
			info.model = "models/eliteghostcp.mdl";
		end;
	end;
	
	-- Check if a statement is true.
	if ( string.find(character._Access, "v") or string.find(character._Access, "V") ) then
		info.tags["Blackmarket"] = true;
	end;
	
	-- Check if a statement is true.
	if ( string.find(character._Access, "i") ) then
		info.tags["Merchant"] = true;
	end;
	
	-- Check if a statement is true.
	if ( character._Data["health"] ) then
		if (character._Data["health"] < 100) then
			if (character._Data["health"] >= 50) then
				info.tags["Injured"] = true;
			elseif (character._Data["health"] > 0) then
				info.tags["Critical"] = true;
			end;
		end;
	end;
	
	-- Check if a statement is true.
	if ( !self:IsCombineClass(info.class) or !self:IsStringCombineRank(info.name, "SCANNER") ) then
		if ( character._Data["armor"] ) then
			if (character._Data["armor"] > 0) then
				info.tags["Armored"] = true
			end;
		end;
		
		-- Check if a statement is true.
		if (info.gender == GENDER_MALE) then
			info.tags[info.gender] = true;
		else
			info.tags[info.gender] = true;
		end;
	end;
	
	-- Check if a statement is true.
	if ( character._Data["customclass"] ) then
		info.customClass = character._Data["customclass"];
	end;
end;

-- Called when a player has used their radio.
function kuroScript.game:PlayerRadioUsed(player, text, listeners, eavesdroppers)
	local talkRadius = kuroScript.config.Get("talk_radius"):Get() * 2;
	local frequency = player:GetCharacterData("frequency");
	local k2, v2;
	local k, v;
	
	-- Check if a statement is true.
	if (frequency) then
		for k, v in pairs( ents.FindByClass("ks_radio") ) do
			if (!v:IsOff() and v:GetSharedVar("ks_Frequency") == frequency) then
				for k2, v2 in pairs( g_Player.GetAll() ) do
					if ( !listeners[v2] and !eavesdroppers[v2] ) then
						if ( v2:HasInitialized() ) then
							if (v2:GetPos():Distance( v:GetPos() ) <= talkRadius) then
								kuroScript.chatBox.Add( v2, player, "radio_stationary", text, {freq = frequency} );
							end;
						end;
					end;
				end;
			end;
		end;
	end;
end;

-- Called when a player's radio info should be adjusted.
function kuroScript.game:PlayerAdjustRadioInfo(player, info)
	local k, v;
	
	-- Check if a statement is true.
	if ( self.scanners[player] ) then
		info.silent = true;
	end;
	
	-- Loop through each value in a table.
	for k, v in ipairs( g_Player.GetAll() ) do
		if ( v:HasInitialized() ) then
			if ( kuroScript.inventory.HasItem(v, "handheld_radio") or self.scanners[v] ) then
				if ( v:GetCharacterData("frequency") == player:GetCharacterData("frequency") ) then
					if (v:GetSharedVar("ks_Tied") == 0) then
						info.listeners[v] = v;
					end;
				end;
			end;
		end;
	end;
end;

-- Called when a player attempts to use a tool.
function kuroScript.game:CanTool(player, trace, tool)
	if ( !kuroScript.player.HasAccess(player, "w") ) then
		if (string.sub(tool, 1, 5) == "wire_" or string.sub(tool, 1, 6) == "wire2_") then
			player:RunCommand("gmod_toolmode \"\"");
			
			-- Return false to break the function.
			return false;
		end;
	end;
end;

-- Called when a player has been healed.
function kuroScript.game:PlayerHealed(player, healer, itemTable)
	if (itemTable.uniqueID == "health_vial") then
		kuroScript.attributes.Boost(healer, itemTable.name, ATB_DEXTERITY, 2, 120);
		
		-- Progress the player's attribute.
		kuroScript.attributes.Progress(healer, ATB_MEDICAL, 15, true);
	elseif (itemTable.uniqueID == "health_kit") then
		kuroScript.attributes.Boost(healer, itemTable.name, ATB_DEXTERITY, 3, 120);
		
		-- Progress the player's attribute.
		kuroScript.attributes.Progress(healer, ATB_MEDICAL, 25, true);
	elseif (itemTable.uniqueID == "bandage") then
		kuroScript.attributes.Boost(healer, itemTable.name, ATB_DEXTERITY, 1, 120);
		
		-- Progress the player's attribute.
		kuroScript.attributes.Progress(healer, ATB_MEDICAL, 5, true);
	end;
end;

-- Called when a player's shared variables should be set.
function kuroScript.game:PlayerSetSharedVars(player, curTime)
	player:SetSharedVar( "ks_DonatorIcon", player:GetInfo("ks_donatoricon", "") );
	player:SetSharedVar( "ks_CustomClass", player:GetCharacterData("customclass", "") );
	player:SetSharedVar( "ks_HiddenItem", player:GetCharacterData("hiddenitem", "") );
	player:SetSharedVar( "ks_CitizenID", player:GetCharacterData("citizenid", "") );
	player:SetSharedVar( "ks_Donator", (player:GetData("donator") > 0) );
	player:SetSharedVar( "ks_Clothes", player:GetCharacterData("clothes", "") );
	player:SetSharedVar( "ks_Icon", player:GetCharacterData("icon", "") );
	
	-- Check if a statement is true.
	if (player:Alive() and !player:IsRagdolled() and player:GetVelocity():Length() > 0) then
		local inventoryWeight = kuroScript.inventory.GetWeight(player);
		
		-- Check if a statement is true.
		if (inventoryWeight >= kuroScript.inventory.GetMaximumWeight(player) / 4) then
			kuroScript.attributes.Progress(player, ATB_STRENGTH, inventoryWeight / 400, true);
		end;
	end;
end;

-- Called at an interval while a player is connected.
function kuroScript.game:PlayerThink(player, curTime, infoTable)
	if ( player:Alive() and !player:IsRagdolled() ) then
		if (!player:InVehicle() and player:GetMoveType() == MOVETYPE_WALK) then
			if ( player:IsInWorld() ) then
				if ( !player:IsOnGround() ) then
					kuroScript.attributes.Progress(player, ATB_ACROBATICS, 0.25, true);
				elseif (infoTable.running) then
					kuroScript.attributes.Progress(player, ATB_AGILITY, 0.125, true);
				elseif (infoTable.jogging) then
					kuroScript.attributes.Progress(player, ATB_AGILITY, 0.0625, true);
				end;
			end;
		end;
	end;
	
	-- Check if a statement is true.
	if ( player:KeyDown(IN_ATTACK) or player:KeyDown(IN_ATTACK2) ) then
		self:HandlePlayerRecoil(player, curTime);
	end;
	
	-- Check if a statement is true.
	if (player:QueryCharacter("currency") >= 10000) then
		infoTable.wages = 0;
	elseif (player:GetData("donator") > 0) then
		infoTable.wages = infoTable.wages * 1.5;
	end;
	
	-- Check if a statement is true.
	if ( self.scanners[player] ) then
		self:CalculateScannerThink(player, curTime);
	end;
	
	-- Set some information.
	local acrobatics = kuroScript.attributes.Get(player, ATB_ACROBATICS);
	local strength = kuroScript.attributes.Get(player, ATB_STRENGTH);
	local agility = kuroScript.attributes.Get(player, ATB_AGILITY);
	
	-- Check if a statement is true.
	if ( player:Alive() ) then
		local maxHealth = player:GetMaxHealth();
		local health = player:Health();
		
		-- Set some information.
		infoTable.walkSpeed = infoTable.walkSpeed * ( 0.75 + math.Clamp( (0.25 / maxHealth) * health, 0, 0.25) );
		infoTable.runSpeed = infoTable.runSpeed * ( 0.25 + math.Clamp( (0.75 / maxHealth) * health, 0, 0.75) );
	end;
	
	-- Check if a statement is true.
	if (acrobatics) then
		infoTable.jumpPower = infoTable.jumpPower + (1.86666667 * acrobatics);
	end;
	
	-- Check if a statement is true.
	if (strength) then
		infoTable.inventoryWeight = infoTable.inventoryWeight + (0.106666667 * strength);
	end;
	
	-- Check if a statement is true.
	if (agility) then
		infoTable.runSpeed = infoTable.runSpeed + (0.666666667 * agility);
	end;
end;

-- Called when the player attempts to be ragdolled.
function kuroScript.game:PlayerCanRagdoll(player, state, delay, decay, ragdoll)
	if ( self.scanners[player] ) then
		return false;
	end;
end;

-- Called when a player attempts to NoClip.
function kuroScript.game:PlayerNoClip(player)
	if ( self.scanners[player] ) then
		return false;
	end;
end;

-- Called when a player's data should be saved.
function kuroScript.game:PlayerSaveData(player, data)
	if (data["serverwhitelist"] and table.Count( data["serverwhitelist"] ) == 0) then
		data["serverwhitelist"] = nil;
	end;
end;

-- Called when a player's data should be restored.
function kuroScript.game:PlayerRestoreData(player, data)
	if ( !data["donator"] ) then
		data["donator"] = 0;
	end;
	
	-- Check if a statement is true.
	if ( !data["serverwhitelist"] ) then
		data["serverwhitelist"] = {};
	end;
	
	-- Set some information.
	local serverWhitelistIdentity = kuroScript.config.Get("server_whitelist_identity"):Get();
	
	-- Check if a statement is true.
	if (serverWhitelistIdentity != "") then
		if ( !data["serverwhitelist"][serverWhitelistIdentity] ) then
			player:Kick("You aren't whitelisted");
		end;
	end;
end;

-- Called to check if a player does have an access flag.
function kuroScript.game:PlayerDoesHaveAccessFlag(player, flag)
	local k, v;
	
	-- Check if a statement is true.
	if ( !kuroScript.config.Get("permits"):Get() ) then
		if (flag == "x" or flag == "i") then
			return false;
		else
			for k, v in pairs(self.customPermits) do
				if (v.flag == flag) then
					return false;
				end;
			end;
		end;
	end;
	
	-- Check if a statement is true.
	if (flag != "x") then
		for k, v in pairs(self.customPermits) do
			if ( v.flag == flag and !kuroScript.player.HasAccess(player, "x") ) then
				return false;
			end;
		end;
	end;
	
	-- Check if a statement is true.
	if ( string.find("petw", flag) ) then
		if (player:GetData("donator") > 0) then
			return true;
		end;
	end;
end;

-- Called when a player's attribute has been updated.
function kuroScript.game:PlayerAttributeUpdated(player, attributeTable, amount)
	if (self:PlayerIsCombine(player) and amount and amount > 0) then
		self:AddCombineDisplayLine("Updating external attributes...", Color(255, 125, 0, 255), player);
	end;
end;

-- Called to check if a player does know another player.
function kuroScript.game:PlayerDoesKnowPlayer(player, target, status, simple, default)
	if (self:PlayerIsCombine(target) or target:QueryCharacter("class") == CLASS_CAD) then
		return true;
	end;
end;

-- Called when a player attempts to delete a character.
function kuroScript.game:PlayerCanDeleteCharacter(player, character)
	if ( character._Data["permakilled"] ) then
		return true;
	end;
end;

-- Called when a player attempts to use a character.
function kuroScript.game:PlayerCanUseCharacter(player, character)
	if ( character._Data["permakilled"] ) then
		return character._Name.." is permanently killed and cannot be used!";
	elseif (character._Class == CLASS_CPA) then
		if ( self:IsStringCombineRank(character._Name, "SCANNER") ) then
			local amount = 0;
			local k, v;
			
			-- Loop through each value in a table.
			for k, v in ipairs( g_Player.GetAll() ) do
				if ( v:HasInitialized() and self:PlayerIsCombine(v) ) then
					if ( self:IsPlayerCombineRank(v, "SCANNER") ) then
						amount = amount + 1;
					end;
				end;
			end;
			
			-- Check if a statement is true.
			if (amount >= 3) then
				return "There are too many scanners online!";
			end;
		end;
	end;
end;

-- Called when attempts to use a command.
function kuroScript.game:PlayerCanUseCommand(player, command, arguments)
	if (player:GetSharedVar("ks_Tied") != 0) then
		local blacklisted = {
			"broadcast",
			"dispatch",
			"request",
			"order",
			"radio"
		};
		
		-- Check if a statement is true.
		if ( table.HasValue(blacklisted, command) ) then
			kuroScript.player.Notify(player, "You cannot use this command when you are tied!");
			
			-- Return false to break the function.
			return false;
		end;
	end;
end;

-- Called when a player attempts to use a door.
function kuroScript.game:PlayerCanUseDoor(player, door)
	if ( player:GetSharedVar("ks_Tied") != 0 or (!self:PlayerIsCombine(player) and player:QueryCharacter("class") != CLASS_CAD) ) then
		return false;
	end;
end;

-- Called when a player attempts to lock an entity.
function kuroScript.game:PlayerCanLockEntity(player, entity)
	if ( kuroScript.entity.IsDoor(entity) and ValidEntity(entity._CombineLock) ) then
		if ( kuroScript.config.Get("combine_lock_overrides"):Get() or entity._CombineLock:IsLocked() ) then
			return false;
		end;
	end;
end;

-- Called when a player attempts to unlock an entity.
function kuroScript.game:PlayerCanUnlockEntity(player, entity)
	if ( kuroScript.entity.IsDoor(entity) and ValidEntity(entity._CombineLock) ) then
		if ( kuroScript.config.Get("combine_lock_overrides"):Get() or entity._CombineLock:IsLocked() ) then
			return false;
		end;
	end;
end;

-- Called when a player has disconnected.
function kuroScript.game:PlayerDisconnected(player)
	self:ResetPlayerScanner(player);
end;

-- Called when a player attempts to change vocation.
function kuroScript.game:PlayerCanChangeVocation(player, vocation)
	if (player:GetSharedVar("ks_Tied") != 0) then
		kuroScript.player.Notify(player, "You cannot change vocations when you are tied!");
		
		-- Return false to break the function.
		return false;
	elseif ( self:PlayerIsCombine(player) ) then
		if ( vocation == VOC_CPA_SCN and !self:IsPlayerCombineRank(player, "SCANNER") ) then
			kuroScript.player.Notify(player, "You are not ranked high enough for this vocation!");
			
			-- Return to break the function.
			return false;
		elseif ( vocation == VOC_CPA_RCT and !self:IsPlayerCombineRank(player, "RCT") ) then
			kuroScript.player.Notify(player, "You are not ranked high enough for this vocation!");
			
			-- Return to break the function.
			return false;
		elseif ( vocation == VOC_CPA_EPU and !self:IsPlayerCombineRank(player, "EpU") ) then
			kuroScript.player.Notify(player, "You are not ranked high enough for this vocation!");
			
			-- Return to break the function.
			return false;
		elseif ( vocation == VOC_OTA_OWS and !self:IsPlayerCombineRank(player, "OWS") ) then
			kuroScript.player.Notify(player, "You are not ranked high enough for this vocation!");
			
			-- Return to break the function.
			return false;
		elseif ( vocation == VOC_OTA_EOW and !self:IsPlayerCombineRank(player, "EOW") ) then
			kuroScript.player.Notify(player, "You are not ranked high enough for this vocation!");
			
			-- Return to break the function.
			return false;
		elseif ( vocation == VOC_OTA_OWC and !self:IsPlayerCombineRank(player, "COMM") ) then
			kuroScript.player.Notify(player, "You are not ranked high enough for this vocation!");
			
			-- Return to break the function.
			return false;
		elseif (vocation == VOC_CPA_PRO) then
			if ( self:IsPlayerCombineRank(player, "EpU") ) then
				kuroScript.player.Notify(player, "You are ranked too high for this vocation!");
				
				-- Return to break the function.
				return false;
			elseif ( self:IsPlayerCombineRank(player, "RCT") ) then
				kuroScript.player.Notify(player, "You are not ranked high enough for this vocation!");
				
				-- Return to break the function.
				return false;
			end;
		end;
	end;
end;

-- Called when death attempts to clear a player's known names.
function kuroScript.game:PlayerCanDeathClearKnownNames(player, attacker, damageInfo) return false; end;

-- Called when death attempts to clear a player's name.
function kuroScript.game:PlayerCanDeathClearName(player, attacker, damageInfo) return false; end;

-- Called when a player attempts to use an entity.
function kuroScript.game:PlayerUse(player, entity)
	local overlayText = entity:GetNetworkedString("GModOverlayText");
	local curTime = CurTime();
	local class = player:QueryCharacter("class");
	
	-- Check if a statement is true.
	if ( string.find(overlayText, "CA") ) then
		if (class != CLASS_CAD) then
			return false;
		end;
	elseif ( string.find(overlayText, "OTA") ) then
		if (class != CLASS_CAD and class != CLASS_OTA) then
			return false;
		end;
	elseif ( string.find(overlayText, "CPA") ) then
		if (class != CLASS_CAD and class != CLASS_OTA and class != CLASS_CPA) then
			return false;
		end;
	elseif ( string.find(overlayText, "CWU") ) then
		if (class != CLASS_CAD and class != CLASS_OTA and class != CLASS_CPA) then
			if (player:GetCharacterData("customclass") != "Civil Worker's Union") then
				return false;
			end;
		end;
	end;
	
	-- Check if a statement is true.
	if ( self.scanners[player] ) then
		return false;
	end;
	
	-- Check if a statement is true.
	if (entity._BustedDown) then
		return false;
	end;
	
	-- Check if a statement is true.
	if ( player:KeyDown(IN_SPEED) and kuroScript.entity.IsDoor(entity) ) then
		if ( (self:PlayerIsCombine(player) or player:QueryCharacter("class") == CLASS_CAD) and ValidEntity(entity._CombineLock) ) then
			if (!player._NextCombineLock or curTime >= player._NextCombineLock) then
				entity._CombineLock:ToggleWithChecks(player);
				
				-- Set some information.
				player._NextCombineLock = curTime + 3;
			end;
			
			-- Return false to break the function.
			return false;
		end;
	end;
	
	-- Check if a statement is true.
	if (player:GetSharedVar("ks_Tied") != 0) then
		if ( entity:IsVehicle() ) then
			if ( kuroScript.entity.IsChairEntity(entity) or kuroScript.entity.IsPodEntity(entity) ) then
				return;
			end;
		end;
		
		-- Check if a statement is true.
		if ( !player._NextTieNotify or player._NextTieNotify < CurTime() ) then
			kuroScript.player.Notify(player, "You cannot use that when you are tied!");
			
			-- Set some information.
			player._NextTieNotify = CurTime() + 2;
		end;
		
		-- Return false to break the function.
		return false;
	end;
end;

-- Called when a player attempts to destroy an item.
function kuroScript.game:PlayerCanDestroyItem(player, itemTable, silent)
	if ( self.scanners[player] ) then
		if (!silent) then
			kuroScript.player.Notify(player, "You cannot destroy items when you are a scanner!");
		end;
		
		-- Return false to break the function.
		return false;
	elseif (player:GetSharedVar("ks_Tied") != 0) then
		if (!silent) then
			kuroScript.player.Notify(player, "You cannot destroy items when you are tied!");
		end;
		
		-- Return false to break the function.
		return false;
	end;
end;

-- Called when a player attempts to drop an item.
function kuroScript.game:PlayerCanDropItem(player, itemTable, silent)
	if ( self.scanners[player] ) then
		if (!silent) then
			kuroScript.player.Notify(player, "You cannot drop items when you are a scanner!");
		end;
		
		-- Return false to break the function.
		return false;
	elseif (player:GetSharedVar("ks_Tied") != 0) then
		if (!silent) then
			kuroScript.player.Notify(player, "You cannot drop items when you are tied!");
		end;
		
		-- Return false to break the function.
		return false;
	end;
end;

-- Called when a player attempts to use an item.
function kuroScript.game:PlayerCanUseItem(player, itemTable, silent)
	if ( self.scanners[player] ) then
		if (!silent) then
			kuroScript.player.Notify(player, "You cannot use items when you are a scanner!");
		end;
		
		-- Return false to break the function.
		return false;
	elseif (player:GetSharedVar("ks_Tied") != 0) then
		if (!silent) then
			kuroScript.player.Notify(player, "You cannot use items when you are tied!");
		end;
		
		-- Return false to break the function.
		return false;
	end;
end;

-- Called when a player attempts to earn contraband currency.
function kuroScript.game:PlayerCanEarnContrabandCurrency(player)
	if ( self:PlayerIsCombine(player) ) then
		return false;
	end;
end;

-- Called when a player's death sound should be played.
function kuroScript.game:PlayerPlayDeathSound(player, gender)
	if ( self:PlayerIsCombine(player) ) then
		local sound = "npc/metropolice/die"..math.random(1, 4)..".wav";
		local k, v;
		
		-- Loop through each value in a table.
		for k, v in ipairs( g_Player.GetAll() ) do
			if ( v:HasInitialized() ) then
				if ( self:PlayerIsCombine(v) ) then
					v:EmitSound(sound);
				end;
			end;
		end;
		
		-- Return the death sound.
		return sound;
	end;
end;

-- Called when a player's pain sound should be played.
function kuroScript.game:PlayerPlayPainSound(player, gender, damageInfo, hitGroup)
	if ( self:PlayerIsCombine(player) ) then
		return "npc/metropolice/pain"..math.random(1, 4)..".wav";
	end;
end;

-- Called when a chat box message has been added.
function kuroScript.game:ChatBoxMessageAdded(info)
	if (info.voice) then
		if ( ValidEntity(info.speaker) and info.speaker:HasInitialized() ) then
			info.speaker:EmitSound(info.voice.sound, info.voice.volume);
		end;
		
		-- Check if a statement is true.
		if (info.voice.global) then
			local k, v;
			
			-- Loop through each value in a table.
			for k, v in pairs(info.listeners) do
				if (v != info.speaker) then
					kuroScript.player.PlaySound(v, info.voice.sound);
				end;
			end;
		end;
	end;
end;

-- Called when chat box info should be adjusted.
function kuroScript.game:ChatBoxAdjustInfo(info)
	if (info.class != "ooc" and info.class != "looc") then
		if ( ValidEntity(info.speaker) and info.speaker:HasInitialized() ) then
			if (string.sub(info.text, 1, 1) == ">") then
				info.text = string.sub(info.text, 2);
				info.data.anon = true;
			end;
		end;
	end;
	
	-- Check if a statement is true.
	if (info.class == "ic" or info.class == "yell" or info.class == "radio" or info.class == "whisper" or info.class == "request") then
		if ( ValidEntity(info.speaker) and info.speaker:HasInitialized() ) then
			local playerIsCombine = self:PlayerIsCombine(info.speaker);
			local k, v;
			
			-- Check if a statement is true.
			if (info.class == "radio" and !info.data.freq) then
				if ( ValidEntity(info.speaker) ) then
					info.data.freq = info.speaker:GetCharacterData("frequency");
				end;
			end;
			
			-- Check if a statement is true.
			if ( playerIsCombine and self:IsPlayerCombineRank(info.speaker, "SCANNER") ) then
				for k, v in pairs(self.dispatchVoices) do
					if ( string.lower(info.text) == string.lower(v.command) ) then
						local voice = {
							global = false,
							volume = 90,
							sound = v.sound
						};
						
						-- Check if a statement is true.
						if (info.class == "request" or info.class == "radio") then
							voice.global = true;
						elseif (info.class == "whisper") then
							voice.volume = 80;
						elseif (info.class == "yell") then
							voice.volume = 100;
						end;
						
						-- Set some information.
						info.text = "<:: "..v.phrase;
						info.voice = voice;
						
						-- Return true to break the function.
						return true;
					end;
				end;
			else
				for k, v in pairs(self.voices) do
					if ( (v.class == "Combine" and playerIsCombine) or (v.class == "Human" and !playerIsCombine) ) then
						if ( string.lower(info.text) == string.lower(v.command) ) then
							local voice = {
								global = false,
								volume = 80,
								sound = v.sound
							};
							
							-- Check if a statement is true.
							if (v.female and info.speaker:QueryCharacter("gender") == GENDER_FEMALE) then
								voice.sound = string.Replace(voice.sound, "/male", "/female");
							end;
							
							-- Check if a statement is true.
							if (info.class == "request" or info.class == "radio") then
								voice.global = true;
							elseif (info.class == "whisper") then
								voice.volume = 60;
							elseif (info.class == "yell") then
								voice.volume = 100;
							end;
							
							-- Check if a statement is true.
							if (playerIsCombine) then
								info.text = "<:: "..v.phrase;
							else
								info.text = v.phrase;
							end;
							
							-- Set some information.
							info.voice = voice;
							
							-- Return true to break the function.
							return true;
						end;
					end;
				end;
			end;
			
			-- Check if a statement is true.
			if (playerIsCombine) then
				if (string.sub(info.text, 1, 4) != "<:: ") then
					info.text = "<:: "..info.text;
				end;
			end;
		end;
	elseif (info.class == "dispatch") then
		for k, v in pairs(self.dispatchVoices) do
			if ( string.lower(info.text) == string.lower(v.command) ) then
				kuroScript.player.PlaySound(nil, v.sound);
				
				-- Set some information.
				info.text = v.phrase;
				
				-- Return true to break the function.
				return true;
			end;
		end;
	end;
end;

-- Called when a player destroys contraband.
function kuroScript.game:PlayerDestroyContraband(player, entity, contraband)
	if ( self:PlayerIsCombine(player) ) then
		local players = {};
		local k, v;
		
		-- Loop through each value in a table.
		for k, v in ipairs( g_Player.GetAll() ) do
			if ( v:HasInitialized() ) then
				if ( self:PlayerIsCombine(v) ) then
					players[#players + 1] = v;
				end;
			end;
		end;
		
		-- Loop through each value in a table.
		for k, v in pairs(players) do
			kuroScript.player.GiveCurrency(v, contraband.currency / 4, "Destroyed Contraband");
		end;
	else
		kuroScript.player.GiveCurrency(player, contraband.currency / 4, "Destroyed Contraband");
	end;
end;

-- Called just before a player dies.
function kuroScript.game:DoPlayerDeath(player, attacker, damageInfo)
	local hiddenItem = player:GetCharacterData("hiddenitem");
	local clothes = player:GetCharacterData("clothes");
	
	-- Check if a statement is true.
	if (hiddenItem) then
		kuroScript.entity.CreateItem( player, hiddenItem, player:GetPos() + Vector( 0, 0, math.random(1, 48) ) );
		
		-- Set some information.
		player:SetCharacterData("hiddenitem", nil);
	end;
	
	-- Check if a statement is true.
	if (clothes) then
		kuroScript.inventory.Update(player, clothes);
		
		-- Set some information.
		player:SetCharacterData("clothes", nil);
	end;
	
	-- Set some information.
	player._BeingSearched = nil;
	player._Searching = nil;
	
	-- Untie the player.
	self:TiePlayer(player, false, true);
end;

-- Called when a player dies.
function kuroScript.game:PlayerDeath(player, inflictor, attacker, damageInfo)
	if ( self:PlayerIsCombine(player) ) then
		local location = self:PlayerGetLocation(player);
		
		-- Add some Combine display lines.
		self:AddCombineDisplayLine("Downloading lost biosignal...", Color(255, 255, 255, 255), nil, player);
		self:AddCombineDisplayLine("WARNING! Biosignal lost for protection team unit at "..location.."...", Color(255, 0, 0, 255), nil, player);
		
		-- Check if a statement is true.
		if ( self.scanners[player] ) then
			if ( ValidEntity( self.scanners[player][1] ) ) then
				if (damageInfo != true) then
					self.scanners[player][1]:TakeDamage(self.scanners[player][1]:Health() + 100);
				end;
			end;
		end;
		
		-- Loop through each value in a table.
		for k, v in ipairs( g_Player.GetAll() ) do
			if ( self:PlayerIsCombine(v) ) then
				v:EmitSound("npc/overwatch/radiovoice/on1.wav");
				v:EmitSound("npc/overwatch/radiovoice/lostbiosignalforunit.wav");
			end;
		end;
		
		-- Set some information.
		timer.Simple(1.5, function()
			for k, v in ipairs( g_Player.GetAll() ) do
				if ( self:PlayerIsCombine(v) ) then
					v:EmitSound("npc/overwatch/radiovoice/off4.wav");
				end;
			end;
		end);
	end;
	
	-- Check if a statement is true.
	if ( !player:GetCharacterData("permakilled") ) then
		if (player._ForcePermaKill) then
			self:PermaKillPlayer(player);
		elseif ( ( attacker:IsPlayer() or attacker:IsNPC() ) and damageInfo ) then
			local miscellaneousDamage = damageInfo:IsBulletDamage() or damageInfo:IsFallDamage() or damageInfo:IsExplosionDamage();
			local meleeDamage = damageInfo:IsDamageType(DMG_CLUB) or damageInfo:IsDamageType(DMG_SLASH);
			
			-- Check if a statement is true.
			if (miscellaneousDamage or meleeDamage) then
				if (kuroScript.frame:GetSharedVar("ks_PKMode") == 1) then
					self:PermaKillPlayer(player);
				end;
			end;
		end;
	end;
end;

-- Called just after a player spawns.
function kuroScript.game:PostPlayerSpawn(player, lightSpawn, changeVocation, firstSpawn)
	if (!lightSpawn) then
		player:SetSharedVar("ks_Antidepressants", 0);
		
		-- Start a user message.
		umsg.Start("ks_ClearEffects", player);
		umsg.End();
		
		-- Set some information.
		player._BeingSearched = nil;
		player._Searching = nil;
		
		-- Check if a statement is true.
		if (self:PlayerIsCombine(player) or player:QueryCharacter("class") == CLASS_CAD) then
			if (player:QueryCharacter("class") == CLASS_OTA) then
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
		
		-- Set some information.
		local clothes = player:GetCharacterData("clothes");
		
		-- Check if a statement is true.
		if (clothes) then
			local itemTable = kuroScript.item.Get(clothes);
			
			-- Check if a statement is true.
			if ( itemTable and kuroScript.inventory.HasItem(player, itemTable.uniqueID) ) then
				itemTable:OnChangeClothes(player, true);
			else
				player:SetCharacterData("clothes", nil);
			end;
		end;
	end;
	
	-- Check if a statement is true.
	if ( self:IsPlayerCombineRank(player, "SCANNER") ) then
		self:MakePlayerScanner(player, true, lightSpawn);
	else
		self:ResetPlayerScanner(player);
	end;
	
	-- Check if a statement is true.
	if (player:GetSharedVar("ks_Tied") != 0) then
		self:TiePlayer(player, true);
	end;
end;

-- Called when a player spawns lightly.
function kuroScript.game:PostPlayerLightSpawn(player, weapons, ammo, special)
	local clothes = player:GetCharacterData("clothes");
	
	-- Check if a statement is true.
	if (clothes) then
		local itemTable = kuroScript.item.Get(clothes);
		
		-- Check if a statement is true.
		if (itemTable) then
			itemTable:OnChangeClothes(player, true);
		end;
	end;
end;

-- Called when a player throws a punch.
function kuroScript.game:PlayerPunchThrown(player)
	kuroScript.attributes.Progress(player, ATB_STRENGTH, 0.25, true);
end;

-- Called when a player punches an entity.
function kuroScript.game:PlayerPunchEntity(player, entity)
	if ( entity:IsPlayer() or entity:IsNPC() ) then
		kuroScript.attributes.Progress(player, ATB_STRENGTH, 1, true);
	else
		kuroScript.attributes.Progress(player, ATB_STRENGTH, 0.5, true);
	end;
end;

-- Called when a player's ragdoll attempts to decay.
function kuroScript.game:PlayerCanRagdollDecay(player, ragdoll, seconds)
	if ( ragdoll:GetNetworkedBool("ks_PermaKilled") ) then
		return false;
	end;
end;

-- Called when an entity has been breached.
function kuroScript.game:EntityBreached(entity, activator)
	if ( kuroScript.entity.IsDoor(entity) ) then
		if ( !ValidEntity(entity._CombineLock) ) then
			if ( ValidEntity(activator) ) then
				kuroScript.entity.OpenDoor( entity, 0, true, true, activator:GetPos() );
			else
				kuroScript.entity.OpenDoor(entity, 0, true, true);
			end;
		elseif ( ValidEntity(activator) and activator:IsPlayer() and self:PlayerIsCombine(activator) ) then
			if (string.lower( entity:GetClass() ) == "prop_door_rotating") then
				entity._CombineLock:ActivateSmokeCharge( (entity:GetPos() - activator:GetPos() ):Normalize() * 10000 );
			else
				entity._CombineLock:SetFlashDuration(2);
			end;
		else
			entity._CombineLock:SetFlashDuration(2);
		end;
	end;
end;

-- Called when a player takes damage.
function kuroScript.game:PlayerTakeDamage(player, inflictor, attacker, hitGroup, damageInfo)
	local curTime = CurTime();
	
	-- Check if a statement is true.
	if (player:Armor() <= 0) then
		umsg.Start("ks_Stunned", player);
			umsg.Float(0.5);
		umsg.End();
	end;
	
	-- Check if a statement is true.
	if (damageInfo:IsBulletDamage() and damageInfo:GetDamage() >= 5 and hitGroup) then
		if (!player._NextAttributeLoss or curTime >= player._NextAttributeLoss) then
			player._NextAttributeLoss = curTime + 30;
			
			-- Check if a statement is true.
			if (hitGroup == HITGROUP_HEAD) then
				kuroScript.attributes.Boost(player, "Body Damage", ATB_MEDICAL, -25, 600);
				kuroScript.attributes.Boost(player, "Body Damage", ATB_AGILITY, -25, 600);
			elseif (hitGroup == HITGROUP_CHEST or hitGroup == HITGROUP_GENERIC) then
				kuroScript.attributes.Boost(player, "Body Damage", ATB_ENDURANCE, -25, 600);
			elseif (hitGroup == HITGROUP_LEFTLEG or hitGroup == HITGROUP_RIGHTLEG) then
				kuroScript.attributes.Boost(player, "Body Damage", ATB_ACROBATICS, -25, 600);
				kuroScript.attributes.Boost(player, "Body Damage", ATB_STAMINA, -25, 600);
				kuroScript.attributes.Boost(player, "Body Damage", ATB_AGILITY, -25, 600);
			elseif (hitGroup == HITGROUP_LEFTARM or hitGroup == HITGROUP_RIGHTARM) then
				kuroScript.attributes.Boost(player, "Body Damage", ATB_DEXTERITY, -25, 600);
				kuroScript.attributes.Boost(player, "Body Damage", ATB_STRENGTH, -25, 600);
				kuroScript.attributes.Boost(player, "Body Damage", ATB_MEDICAL, -25, 600);
			end;
		end;
	end;
end;

-- A function to scale damage by hit group.
function kuroScript.game:PlayerScaleDamageByHitGroup(player, attacker, hitGroup, damageInfo, baseDamage)
	local endurance = kuroScript.attributes.Get(player, ATB_ENDURANCE);
	local clothes = player:GetCharacterData("clothes");
	
	-- Check if a statement is true.
	if (endurance) then
		damageInfo:ScaleDamage( 1 - (0.00666666667 * endurance) );
	end;
	
	-- Check if a statement is true.
	if ( damageInfo:IsBulletDamage() ) then
		if (hitGroup == HITGROUP_HEAD) then
			damageInfo:ScaleDamage(8);
		end;
		
		-- Check if a statement is true.
		if ( clothes and damageInfo:IsBulletDamage() ) then
			local itemTable = kuroScript.item.Get(clothes);
			
			-- Check if a statement is true.
			if (itemTable and itemTable.protection) then
				damageInfo:ScaleDamage(1 - itemTable.protection);
			end;
		end;
	end;
end;

-- Called when an entity takes damage.
function kuroScript.game:EntityTakeDamage(entity, inflictor, attacker, amount, damageInfo)
	local player = kuroScript.entity.GetPlayer(entity);
	local curTime = CurTime();
	local doDoorDamage;
	
	-- Check if a statement is true.
	if (player) then
		if (!player._NextEnduranceTime or CurTime() > player._NextEnduranceTime) then
			kuroScript.attributes.Progress(player, ATB_ENDURANCE, math.Clamp(damageInfo:GetDamage(), 0, 75) / 10, true);
			
			-- Set some information.
			player._NextEnduranceTime = CurTime() + 2;
		end;
		
		-- Check if a statement is true.
		if ( self.scanners[player] ) then
			entity:EmitSound("npc/scanner/scanner_pain"..math.random(1, 2)..".wav");
			
			-- Check if a statement is true.
			if (entity:Health() > 50 and entity:Health() - damageInfo:GetDamage() <= 50) then
				entity:EmitSound("npc/scanner/scanner_siren1.wav");
			elseif (entity:Health() > 25 and entity:Health() - damageInfo:GetDamage() <= 25) then
				entity:EmitSound("npc/scanner/scanner_siren2.wav");
			end;
		end;
		
		-- Check if a statement is true.
		if ( attacker:IsPlayer() and self:PlayerIsCombine(player) ) then
			if (attacker != player) then
				local location = kuroScript.game:PlayerGetLocation(player);
				
				-- Check if a statement is true.
				if (!player._NextUnderFire or curTime >= player._NextUnderFire) then
					player._NextUnderFire = curTime + 15;
					
					-- Add some Combine display lines.
					kuroScript.game:AddCombineDisplayLine("Downloading trauma packet...", Color(255, 255, 255, 255), nil, player);
					kuroScript.game:AddCombineDisplayLine("WARNING! Protection team unit enduring physical bodily trauma at "..location.."...", Color(255, 0, 0, 255), nil, player);
				end;
			end;
		end;
	end;
	
	-- Check if a statement is true.
	if ( attacker:IsPlayer() ) then
		local melee = nil;
		local weapon = kuroScript.player.GetWeaponClass(attacker);
		local strength = kuroScript.attributes.Get(attacker, ATB_STRENGTH);
		
		-- Check if a statement is true.
		if (strength) then
			if ( damageInfo:IsDamageType(DMG_CLUB) or damageInfo:IsDamageType(DMG_SLASH) ) then
				damageInfo:ScaleDamage( 1 + (0.0133333333 * strength) );
				
				-- Set some information.
				melee = true;
			end;
		end;
		
		-- Check if a statement is true.
		if (weapon == "weapon_357") then
			damageInfo:ScaleDamage(0.25);
		elseif (weapon == "weapon_crossbow") then
			damageInfo:ScaleDamage(2);
		elseif (weapon == "weapon_shotgun") then
			damageInfo:ScaleDamage(3);
			
			-- Set some information.
			doDoorDamage = true;
		elseif (weapon == "weapon_crowbar") then
			damageInfo:ScaleDamage(0.25);
		elseif (weapon == "ks_stunstick") then
			if (player) then
				if (player:Health() <= 10) then
					damageInfo:ScaleDamage(0.5);
				end;
			end;
		end;
		
		-- Check if a statement is true.
		if (damageInfo:IsBulletDamage() and weapon != "weapon_shotgun") then
			if ( !ValidEntity(entity._CombineLock) and !ValidEntity(entity._Breach) ) then
				if (string.lower( entity:GetClass() ) == "prop_door_rotating") then
					if ( !kuroScript.entity.IsDoorHidden(entity) ) then
						local damagePosition = damageInfo:GetDamagePosition();
						
						-- Check if a statement is true.
						if (entity:WorldToLocal(damagePosition):Distance( Vector(-1.0313, 41.8047, -8.1611) ) <= 8) then
							entity._DoorHealth = math.min( (entity._DoorHealth or 50) - damageInfo:GetDamage(), 0 );
							
							-- Set some information.
							local effectData = EffectData();
							
							-- Set some information.
							effectData:SetStart(damagePosition);
							effectData:SetOrigin(damagePosition);
							effectData:SetScale(8);
							
							-- Set some information.
							util.Effect("GlassImpact", effectData, true, true);
							
							-- Check if a statement is true.
							if (entity._DoorHealth <= 0) then
								kuroScript.entity.OpenDoor( entity, 0, true, true, attacker:GetPos() );
								
								-- Set some information.
								entity._DoorHealth = 50;
							else
								kuroScript.frame:CreateTimer("Reset Door Health: "..entity:EntIndex(), 60, 1, function()
									if ( ValidEntity(entity) ) then
										entity._DoorHealth = 50;
									end;
								end);
							end;
						end;
					end;
				end;
			end;
		end;
		
		-- Check if a statement is true.
		if ( damageInfo:IsExplosionDamage() ) then
			damageInfo:ScaleDamage(2);
		end;
	elseif ( attacker:IsNPC() ) then
		damageInfo:ScaleDamage(0.5);
	end;
	
	-- Check if a statement is true.
	if (damageInfo:IsExplosionDamage() or doDoorDamage) then
		if ( !ValidEntity(entity._CombineLock) and !ValidEntity(entity._Breach) ) then
			if (string.lower( entity:GetClass() ) == "prop_door_rotating") then
				if ( !kuroScript.entity.IsDoorHidden(entity) ) then
					if (attacker:GetPos():Distance( entity:GetPos() ) <= 96) then
						entity._DoorHealth = math.min( (entity._DoorHealth or 50) - damageInfo:GetDamage(), 0 );
						
						-- Set some information.
						local damagePosition = damageInfo:GetDamagePosition();
						local effectData = EffectData();
						
						-- Set some information.
						effectData:SetStart(damagePosition);
						effectData:SetOrigin(damagePosition);
						effectData:SetScale(8);
						
						-- Set some information.
						util.Effect("GlassImpact", effectData, true, true);
						
						-- Check if a statement is true.
						if (entity._DoorHealth <= 0) then
							self:BustDownDoor(attacker, entity);
							
							-- Set some information.
							entity._DoorHealth = 50;
						else
							kuroScript.frame:CreateTimer("Reset Door Health: "..entity:EntIndex(), 60, 1, function()
								if ( ValidEntity(entity) ) then
									entity._DoorHealth = 50;
								end;
							end);
						end;
					end;
				end;
			end;
		end;
	end;
end;