--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

-- Called when a player's property should be restored.
function openAura.schema:PlayerReturnProperty(player)
	local uniqueID = player:UniqueID();
	local removed = {};
	local key = player:QueryCharacter("key");
	
	for k, v in ipairs(self.billboards) do
		if (v.uniqueID == uniqueID) then
			if (v.key != key) then
				removed[#removed + 1] = k;
				
				v.uniqueID = nil;
				v.data = nil;
				v.key = nil;
			else
				v.data.owner = player;
			end;
		end;
	end;
	
	if (#removed > 0) then
		openAura:StartDataStream(nil, "BillboardRemove", removed);
	end;
end;

-- Called when a player's data stream info should be sent.
function openAura.schema:PlayerSendDataStreamInfo(player)
	local billboards = {};
	
	for k, v in ipairs(self.billboards) do
		if (v.data) then
			billboards[#billboards + 1] = {
				data = v.data,
				id = k
			};
		end;
	end;
	
	openAura:StartDataStream(player, "Billboards", billboards);
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
			target.nextStunInfo[2] = curTime + 8;
			
			if (target.nextStunInfo[1] == 1) then
				openAura.player:SetRagdollState(target, RAGDOLL_KNOCKEDOUT, 60);
			end;
		else
			target.nextStunInfo = {0, curTime + 4};
		end;
		
		target:ViewPunch( Angle(12 + strength, 0, 0) );
		
		umsg.Start("aura_Stunned", target);
			umsg.Float(0.5);
		umsg.End();
	end;
end;

-- Called to check if a player does recognise another player.
function openAura.schema:PlayerDoesRecognisePlayer(player, target, status, isAccurate, realValue)
	if (status < RECOGNISE_SAVE) then
		local playerTeam = player:Team();
		local targetTeam = target:Team();
		
		if (playerTeam == CLASS_POLICE or playerTeam == CLASS_DISPENSER or playerTeam == CLASS_RESPONSE
		or playerTeam == CLASS_SECRETARY or playerTeam == CLASS_PRESIDENT) then
			if (targetTeam == CLASS_POLICE or targetTeam == CLASS_DISPENSER or targetTeam == CLASS_RESPONSE
			or targetTeam == CLASS_SECRETARY or targetTeam == CLASS_PRESIDENT) then
				return true;
			end;
		end;
	end;
end;

-- Called when a player's weapons should be given.
function openAura.schema:PlayerGiveWeapons(player)
	if (player:Team() == CLASS_POLICE or player:Team() == CLASS_DISPENSER
	or player:Team() == CLASS_RESPONSE) then
		openAura.player:GiveSpawnWeapon(player, "aura_stunbaton");
	end;
end;

-- Called when a player attempts to use a lowered weapon.
function openAura.schema:PlayerCanUseLoweredWeapon(player, weapon, secondary)
	if ( secondary and (weapon.SilenceTime or weapon.PistolBurst) ) then
		return true;
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

-- Called when a player attempts to earn wages cash.
function openAura.schema:PlayerCanEarnWagesCash(player, cash)
	local team = player:Team();
	
	if (team == CLASS_POLICE or team == CLASS_DISPENSER or team == CLASS_SECRETARY
	or team == CLASS_PRESIDENT or team == CLASS_RESPONSE) then
		local noWagesTime = openAura:GetSharedVar("noWagesTime");
		local curTime = CurTime();
		
		if (noWagesTime >= curTime) then
			openAura.player:Notify(player, "You did not earn any wages because the president was killed recently.");
			
			return false;
		end;
	end;
end;

-- Called when a player gets high on a drug.
function openAura.schema:PlayerGetHighOnDrug(player, itemTable)
	if (itemTable.addictionRate) then
		local addictTable = player:GetCharacterData("addictions");
		
		if (addictTable) then
			if ( !addictTable[itemTable.uniqueID] ) then
				addictTable[itemTable.uniqueID] = {
					count = 0,
					nextFix = 0
				};
			end;
			
			addictTable[itemTable.uniqueID].count = addictTable[itemTable.uniqueID].count + 1;
			
			if (addictTable[itemTable.uniqueID].count >= itemTable.addictionRate) then
				openAura.hint:Send( player, "Your character is addicted to "..string.lower(itemTable.name)..".", 8, Color(150, 200, 50, 255) );
				addictTable[itemTable.uniqueID].nextFix = os.clock() + 10800;
			end;
		end;
	end;
end;

-- Called when a player attempts to earn generator cash.
function openAura.schema:PlayerCanEarnGeneratorCash(player, info, cash)
	local team = player:Team();
	
	if (team == CLASS_POLICE or team == CLASS_SECRETARY or team == CLASS_RESPONSE
	or team == CLASS_PRESIDENT or team == CLASS_DISPENSER) then
		return false;
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

-- Called when a player's character has loaded.
function openAura.schema:PlayerCharacterLoaded(player)
	player:SetSharedVar("lottery", false);
	player.lottery = nil;
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
	elseif (entity:GetClass() == "aura_broadcaster") then
		if (arguments == "aura_broadcasterToggle") then
			entity:Toggle();
		elseif (arguments == "aura_broadcasterTake") then
			local success, fault = player:UpdateInventory("broadcaster", 1);
			
			if (!success) then
				openAura.player:Notify(entity, fault);
			else
				entity:Remove();
			end;
		end;
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
					
					openAura.player:Notify(player, "You have set this stationary radio's frequency to "..arguments..".");
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

-- Called when OpenAura has loaded all of the entities.
function openAura.schema:OpenAuraInitPostEntity()
	openAura:SetSharedVar("lottery", CurTime() + 3600);
	
	self:LoadLotteryCash();
	self:LoadBelongings();
	self:LoadRadios();
end;

-- Called just after data should be saved.
function openAura.schema:PostSaveData()
	self:SaveLotteryCash();
	self:SaveBelongings();
	self:SaveRadios();
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
	elseif (itemTable.uniqueID == "heartbeat_sensor") then
		if ( player:GetSharedVar("sensor") ) then
			if ( !player:HasItem(itemTable.uniqueID) ) then
				itemTable:OnPlayerUnequipped(player);
			end;
		end;
	end;
end;

-- Called when a player switches their flashlight on or off.
function openAura.schema:PlayerSwitchFlashlight(player, on)
	if (on and player:GetSharedVar("tied") != 0) then
		return false;
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

-- Called when a player spawns an object.
function openAura.schema:PlayerSpawnObject(player)
	if (player:GetSharedVar("tied") != 0) then
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
	local team = player:Team();
	
	if ( player:GetSharedVar("tied") != 0 or (team != CLASS_POLICE and team != CLASS_SECRETARY
	and team != CLASS_PRESIDENT and team != CLASS_DISPENSER and team != CLASS_RESPONSE) ) then
		return false;
	end;
end;

-- Called when a player presses a key.
function openAura.schema:KeyPress(player, key)
	if (key == IN_USE) then
		local untieTime = openAura.schema:GetDexterityTime(player);
		local eyeTrace = player:GetEyeTraceNoCursor();
		local target = eyeTrace.Entity;
		local entity = target;
		
		if ( IsValid(target) ) then
			target = openAura.entity:GetPlayer(target);
			
			if (target and player:GetSharedVar("tied") == 0) then
				if (target:GetShootPos():Distance( player:GetShootPos() ) <= 192) then
					if ( target:GetSharedVar("tied") != 0 and target:Alive() ) then
						openAura.player:SetAction(player, "untie", untieTime);
						
						target:SetSharedVar("beingUntied", true);
						
						openAura.player:EntityConditionTimer(player, target, entity, untieTime, 192, function()
							return player:Alive() and target:Alive() and !player:IsRagdolled() and player:GetSharedVar("tied") == 0;
						end, function(success)
							if (success) then
								self:TiePlayer(target, false);
								
								player:ProgressAttribute(ATB_DEXTERITY, 15, true);
							end;
							
							if ( IsValid(target) ) then
								target:SetSharedVar("beingUntied", false);
							end;
							
							openAura.player:SetAction(player, "untie", false);
						end);
					end;
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
	local action = openAura.player:GetAction(player);
	
	if (itemTable.uniqueID == "health_vial") then
		healer:BoostAttribute(itemTable.name, ATB_DEXTERITY, 2, 600);
		healer:ProgressAttribute(ATB_MEDICAL, 15, true);
	elseif (itemTable.uniqueID == "health_kit") then
		healer:BoostAttribute(itemTable.name, ATB_DEXTERITY, 3, 600);
		healer:ProgressAttribute(ATB_MEDICAL, 25, true);
	elseif (itemTable.uniqueID == "bandage") then
		healer:BoostAttribute(itemTable.name, ATB_DEXTERITY, 1, 600);
		healer:ProgressAttribute(ATB_MEDICAL, 5, true);
	end;
end;

-- Called when config has initialized for a player.
function openAura.schema:PlayerConfigInitialized(player)
	local blacklist = player:GetData("blacklist");
	
	if (blacklist) then
		openAura:StartDataStream( {player}, "GetBlacklist", blacklist );
	end;
end;

-- Called when a player's data should be restored.
function openAura.schema:PlayerRestoreData(player, data)
	
	if ( !data["blacklist"] ) then
		data["blacklist"] = {};
	end;
	
	for k, v in ipairs( data["blacklist"] ) do
		if ( !openAura.class:Get(v) ) then
			table.remove(data["blacklist"], k);
		end;
	end;
end;

-- Called when a player's character data should be restored.
function openAura.schema:PlayerRestoreCharacterData(player, data)
	if (data["version"] != 1) then
		data["alliance"] = nil;
		data["version"] = 1;
	end;
	
	if ( !data["addictions"] ) then
		data["addictions"] = {};
	end;
	
	if (data["callerid"] == "911") then
		data["callerid"] = nil;
	end;
	
	if ( !data["hunger"] ) then
		data["hunger"] = 0;
	end;

	if ( !data["thirst"] ) then
		data["thirst"] = 0;
	end;
	
	if ( !data["stars"] ) then
		data["stars"] = {
			stars = 0,
			crimes = {},
			clearTime = 0
		};
	end;
end;

-- Called when a player's shared variables should be set.
function openAura.schema:PlayerSetSharedVars(player, curTime)
	player:SetSharedVar( "alliance", player:GetCharacterData("alliance", "") );
	player:SetSharedVar( "clothes", player:GetCharacterData("clothes", 0) );
	player:SetSharedVar( "leader", player:GetCharacterData("leader", false) );
	player:SetSharedVar( "sensor", player:GetCharacterData("sensor", false) );
	player:SetSharedVar( "hunger", math.Round( player:GetCharacterData("hunger") ) );
	player:SetSharedVar( "thirst", math.Round( player:GetCharacterData("thirst") ) );
	
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
	
	if ( player:Alive() ) then
		if (player:GetCharacterData("hunger") == 100) then
			player:BoostAttribute("Thirst", ATB_ACROBATICS, -50);
			player:BoostAttribute("Thirst", ATB_ENDURANCE, -50);
			player:BoostAttribute("Thirst", ATB_STRENGTH, -50);
			player:BoostAttribute("Thirst", ATB_AGILITY, -50);
		else
			player:BoostAttribute("Thirst", ATB_ACROBATICS, false);
			player:BoostAttribute("Thirst", ATB_ENDURANCE, false);
			player:BoostAttribute("Thirst", ATB_STRENGTH, false);
			player:BoostAttribute("Thirst", ATB_AGILITY, false);
		end;
		
		if (player:GetCharacterData("thirst") == 100) then
			player:BoostAttribute("Thirst", ATB_DEXTERITY, -50);
			player:BoostAttribute("Thirst", ATB_MEDICAL, -50);
		else
			player:BoostAttribute("Thirst", ATB_DEXTERITY, false);
			player:BoostAttribute("Thirst", ATB_MEDICAL, false);
		end;
	end;
	
	local addictTable = player:GetCharacterData("addictions");
	local addictedTo = {};
	local withdrawal = false;
	local unixTime = os.clock();
	
	for k, v in pairs(addictTable) do
		if (v.count > 0 and unixTime - v.nextFix >= 86400) then
			addictTable[k] = nil;
		elseif (v.count > 0 and unixTime >= v.nextFix) then
			local itemTable = openAura.item:Get(k);
			
			if (itemTable) then
				addictedTo[#addictedTo + 1] = itemTable.name;
				withdrawal = true;
			end;
		end;
	end;
	
	if (withdrawal) then
		player:BoostAttribute("Withdrawal", ATB_ACROBATICS, -50);
		player:BoostAttribute("Withdrawal", ATB_ENDURANCE, -50);
		player:BoostAttribute("Withdrawal", ATB_STRENGTH, -50);
		player:BoostAttribute("Withdrawal", ATB_AGILITY, -50);
		
		if (!player.nextWarnWithdrawal or curTime >= player.nextWarnWithdrawal) then
			if (#addictedTo > 0) then
				player.nextWarnWithdrawal = curTime + 1800;
				openAura.hint:Send( player, "Your character is suffering withdrawal symptoms from "..string.lower( table.concat(addictedTo, ", ") )..".", 8, Color(200, 150, 75, 255) );
			end;
		end;
	else
		player:BoostAttribute("Withdrawal", ATB_ACROBATICS, false);
		player:BoostAttribute("Withdrawal", ATB_ENDURANCE, false);
		player:BoostAttribute("Withdrawal", ATB_STRENGTH, false);
		player:BoostAttribute("Withdrawal", ATB_AGILITY, false);
	end;
	
	player:SetSharedVar("withdrawal", withdrawal);
	player:SetSharedVar("stars", player:GetCharacterData("stars").stars);
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
	local frequency = player:GetCharacterData("frequency");
	local ragdolled = player:IsRagdolled();
	local aimVector = tostring( player:GetAimVector() );
	local velocity = player:GetVelocity();
	local alive = player:Alive();
	
	if (player.lastAimVector != aimVector) then
		player.nextKickTime = curTime + 1800;
		player.lastAimVector = aimVector;
	end;
	
	if (player.nextKickTime and curTime >= player.nextKickTime) then
		player:Kick("You have been idle too long.");
	end;
	
	if (alive and !ragdolled) then
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
	
	if ( player:Alive() ) then
		player:SetCharacterData( "hunger", math.Clamp(player:GetCharacterData("hunger") + 0.008, 0, 100) );
		player:SetCharacterData( "thirst", math.Clamp(player:GetCharacterData("thirst") + 0.009, 0, 100) );
	end;
	
	local acrobatics = openAura.attributes:Fraction(player, ATB_ACROBATICS, 175, 50);
	local strength = openAura.attributes:Fraction(player, ATB_STRENGTH, 8, 4);
	local agility = openAura.attributes:Fraction(player, ATB_AGILITY, 50, 25);
	
	if (clothes != "") then
		local itemTable = openAura.item:Get(clothes);
		
		if (itemTable and itemTable.pocketSpace) then
			infoTable.inventoryWeight = infoTable.inventoryWeight + itemTable.pocketSpace;
		end;
	end;
	
	infoTable.inventoryWeight = infoTable.inventoryWeight + strength;
	infoTable.jumpPower = infoTable.jumpPower + acrobatics;
	infoTable.runSpeed = infoTable.runSpeed + agility;
	
	local stars = player:GetCharacterData("stars");
	
	if (stars.clearTime > 0 and os.clock() >= stars.clearTime) then
		stars.stars = 0;
		stars.crimes = {};
		stars.clearTime = 0;
		self:SendCrimes(player);
	end;
end;

-- Called when attempts to use a command.
function openAura.schema:PlayerCanUseCommand(player, commandTable, arguments)
	if (player:GetSharedVar("tied") != 0) then
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

-- Called when a player attempts to change class.
function openAura.schema:PlayerCanChangeClass(player, class)
	local blacklist = player:GetData("blacklist");
	
	if (player:GetSharedVar("tied") != 0) then
		openAura.player:Notify(player, "You cannot change classes when you are tied!");
		
		return false;
	end;
	
	if ( blacklist and table.HasValue(blacklist, class.index) ) then
		openAura.player:Notify(player, "You are blacklisted from this class!");
		
		return false;
	end;
end;

-- Called when a player attempts to use an entity.
function openAura.schema:PlayerUse(player, entity)
	local curTime = CurTime();
	
	if (entity.bustedDown) then
		return false;
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
	if (player:GetSharedVar("tied") != 0) then
		if (!noMessage) then
			openAura.player:Notify(player, "You cannot destroy items when you are tied!");
		end;
		
		return false;
	end;
end;

-- Called when a player attempts to drop an item.
function openAura.schema:PlayerCanDropItem(player, itemTable, noMessage)
	if (player:GetSharedVar("tied") != 0) then
		if (!noMessage) then
			openAura.player:Notify(player, "You cannot drop items when you are tied!");
		end;
		
		return false;
	end;
end;

-- Called when a player attempts to use an item.
function openAura.schema:PlayerCanUseItem(player, itemTable, noMessage)
	if (player:GetSharedVar("tied") != 0) then
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
	if ( !player:Alive() ) then
		openAura.player:Notify(player, "You don't have permission to do this right now!");
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
		
		if (info.class == "ic") then
			for k, v in ipairs( ents.FindByClass("aura_broadcaster") ) do
				if (!v:IsOff() and info.speaker:GetPos():Distance( v:GetPos() ) <= 64) then
					for k2, v2 in ipairs( _player.GetAll() ) do
						info.listeners[k2] = v2;
					end;
					
					info.class = "broadcast";
					
					break;
				end;
			end;
		end;
	end;
end;

-- Called when a player destroys generator.
function openAura.schema:PlayerDestroyGenerator(player, entity, generator)
	local team = player:Team();
	local cash = generator.cash;
	
	if ( string.find(generator.name, "Lab") ) then
		cash = cash / 2;
	end;
	
	if (team == CLASS_POLICE or team == CLASS_DISPENSER or team == CLASS_RESPONSE) then
		local recipients = {};
		
		table.Add( recipients, _team.GetPlayers(CLASS_DISPENSER) );
		table.Add( recipients, _team.GetPlayers(CLASS_POLICE) );
		
		for k, v in pairs(recipients) do
			openAura.player:GiveCash( v, cash, "destroying a "..string.lower(generator.name) );
		end;
	else
		openAura.player:GiveCash( player, cash, "destroying a "..string.lower(generator.name) );
	end;
end;

-- Called when a player dies.
function openAura.schema:PlayerDeath(player, inflictor, attacker, damageInfo)
	if ( attacker:IsPlayer() ) then
		local listeners = {};
		local weapon = attacker:GetActiveWeapon();
		
		for k, v in ipairs( _player.GetAll() ) do
			if ( v:IsAdmin() or v:IsUserGroup("operator") ) then
				if ( v:HasInitialized() ) then
					listeners[#listeners + 1] = v;
				end;
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
	else
		umsg.Start("aura_Death", player);
		umsg.End();
	end;
	
	if (damageInfo) then
		local miscellaneousDamage = damageInfo:IsBulletDamage() or damageInfo:IsExplosionDamage();
		local meleeDamage = damageInfo:IsDamageType(DMG_CLUB) or damageInfo:IsDamageType(DMG_SLASH);
		
		if (miscellaneousDamage or meleeDamage) then
			self:PlayerDropRandomItems( player, player:GetRagdollEntity() );
		end;
	end;
	
	if (player:Team() == CLASS_PRESIDENT) then
		if ( attacker:IsPlayer() ) then
			local team = attacker:Team();
			
			if (team == CLASS_SECRETARY or team == CLASS_POLICE or team == CLASS_RESPONSE
			or team == CLASS_PRESIDENT or team == CLASS_DISPENSER) then
				return;
			end;
		end;
		
		self.demotePresident = player;
	end;
end;

-- Called each frame that a player is dead.
function openAura.schema:PlayerDeathThink(player)
	if ( player:GetCharacterData("dead") ) then
		return true;
	end;
end;

-- Called when a player attempts to switch to a character.
function openAura.schema:PlayerCanSwitchCharacter(player, character)
	if ( player:GetCharacterData("dead") ) then
		return true;
	end;
end;

-- Called when a player's death info should be adjusted.
function openAura.schema:PlayerAdjustDeathInfo(player, info)
	if ( player:GetCharacterData("dead") ) then
		info.spawnTime = 0;
	end;
end;

-- Called when a player's character screen info should be adjusted.
function openAura.schema:PlayerAdjustCharacterScreenInfo(player, character, info)
	if ( character.data["dead"] ) then
		info.details = "This character is permanently dead.";
	end;
end;

-- Called when a player attempts to delete a character.
function openAura.schema:PlayerCanDeleteCharacter(player, character)
	if ( character.data["dead"] ) then
		return true;
	end;
end;

-- Called when a player attempts to use a character.
function openAura.schema:PlayerCanUseCharacter(player, character)
	if ( character.data["dead"] ) then
		return character.name.." is permanently killed and cannot be used!";
	end;
end;

-- Called each tick.
function openAura.schema:Tick()
	local nextLotteryTime = openAura:GetSharedVar("lottery");
	local curTime = CurTime();
	
	if ( self.demotePresident and !IsValid(self.demotePresident) ) then
		openAura:SetSharedVar( "noWagesTime", curTime + (openAura.config:Get("wages_interval"):Get() * 2) );
		self.demotePresident = nil;
	end;
	
	if ( curTime >= nextLotteryTime and (!self.lotteryPaused or curTime >= self.lotteryPaused) ) then
		math.randomseed(curTime);
		
		local winningNumbers = {
			math.random(1, 10),
			math.random(1, 10),
			math.random(1, 10)
		}
		local lotteryCash = self.lotteryCash;
		local playerWinners = {};
		
		self.lotteryPaused = curTime + 4;
		
		openAura:SetSharedVar("lottery", curTime + 3600);
		
		for k, v in ipairs( _player.GetAll() ) do
			if (v:HasInitialized() and v.lottery) then
				if ( self:HasWonLottery(v, v.lottery, winningNumbers) ) then
					playerWinners[#playerWinners + 1] = v;
				end;
				
				v:SetSharedVar("lottery", false);
				v.lottery = nil;
			end;
		end;
		
		if (#playerWinners > 0) then
			local cashEach = math.Round(lotteryCash / #playerWinners);
			local playerNames = "";
			local winnerCount = #playerWinners;
			
			self.lotteryCash = 0;
			
			for k, v in ipairs(playerWinners) do
				if (k == 1 or winnerCount == 1) then
					playerNames = v:Name();
				elseif (k == winnerCount) then
					playerNames = playerName.." and "..v:Name();
				else
					playerNames = playerNames..", ";
				end;
				
				openAura.player:GiveCash(v, cashEach, "winning the lottery");
			end;
			
			if (winnerCount == 1) then
				openAura.chatBox:Add(nil, nil, "lottery", "The lottery is over, "..playerNames.." has won "..FORMAT_CASH(cashEach).."!");
			else
				openAura.chatBox:Add(nil, nil, "lottery", "The lottery is over, "..playerNames.." have won "..FORMAT_CASH(cashEach).." each!");
			end;
		end;
	end;
end;

-- Called just before a player dies.
function openAura.schema:DoPlayerDeath(player, attacker, damageInfo)
	self:TiePlayer(player, false, true);
	
	player.beingSearched = nil;
	player.searching = nil;
end;

-- Called when a player's class has been set.
function openAura.schema:PlayerClassSet(player, newClass, oldClass, noRespawn, addDelay, noModelChange)
	local generatorEntities = {};
	
	for k, v in pairs(openAura.generator.stored) do
		table.Add( generatorEntities, ents.FindByClass(k) );
	end;
	
	if (newClass.index == CLASS_POLICE or newClass.index == CLASS_PRESIDENT
	or newClass.index == CLASS_DISPENSER or newClass.index == CLASS_RESPONSE) then
		if (newClass.index == CLASS_PRESIDENT or newClass.index == CLASS_RESPONSE) then
			player:SetArmor(150);
		else
			player:SetArmor(100);
		end;
		
		player.freeArmor = true;
	elseif (player.freeArmor) then
		player:SetArmor(0);
		player.freeArmor = nil;
	end;
	
	for k, v in pairs(generatorEntities) do
		if ( player == v:GetPlayer() ) then
			local generator = openAura.generator:Get( v:GetClass() );
			local itemTable = openAura.item:Get(generator.name);
			
			if ( itemTable and !openAura:HasObjectAccess(player, itemTable) ) then
				v:Explode();
				v:Remove();
			end;
		end;
	end;
end;

-- Called when a player's storage should close.
function openAura.schema:PlayerStorageShouldClose(player, storage)
	local entity = player:GetStorageEntity();
	
	if (player.searching and entity:IsPlayer()
	and entity:GetSharedVar("tied") == 0) then
		return true;
	end;
end;

-- Called just after a player spawns.
function openAura.schema:PostPlayerSpawn(player, lightSpawn, changeClass, firstSpawn)
	local skullMask = player:GetCharacterData("skullmask");
	local clothes = player:GetCharacterData("clothes");
	local team = player:Team();

	if (!firstSpawn and !lightSpawn) then
		player:SetCharacterData("hunger", 0);
		player:SetCharacterData("thirst", 0);
	end;
	
	if (!lightSpawn) then
		if (self.demotePresident == player) then
			openAura:SetSharedVar( "noWagesTime", CurTime() + (openAura.config:Get("wages_interval"):Get() * 2) );
				openAura.class:Set(player, CLASS_CIVILIAN, true, true, true);
			self.demotePresident = nil;
			
			openAura.player:SetDefaultModel(player);
		end;
		
		umsg.Start("aura_ClearEffects", player);
		umsg.End();
		
		player:SetCharacterData( "stars", {
			stars = 0,
			crimes = {},
			clearTime = 0
		} );
		player:SetSharedVar("disguise", NULL);
		player.cancelDisguise = nil;
		player.beingSearched = nil;
		player.searching = nil;
		
		self:SendCrimes(player);
	end;
	
	if (player:GetSharedVar("tied") != 0) then
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
			if ( !changeClass or (team != CLASS_POLICE and team != CLASS_DISPENSER
			and team != CLASS_RESPONSE) ) then
				self:PlayerWearClothes(player, itemTable);
			end;
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
		if (entity:GetClass() != "prop_door_rotating") then
			openAura.entity:OpenDoor(entity, 0, true, true);
		else
			self:BustDownDoor(activator, entity);
		end;
	end;
end;

-- Called when a player takes damage.
function openAura.schema:PlayerTakeDamage(player, inflictor, attacker, hitGroup, damageInfo)
	if (player:Health() <= 10 and math.random() <= 0.75) then
		if (openAura.player:GetAction(player) != "die") then
			openAura.player:SetRagdollState( player, RAGDOLL_FALLENOVER, nil, nil, openAura:ConvertForce(damageInfo:GetDamageForce() * 32) );
			
			openAura.player:SetAction(player, "die", 60, 1, function()
				if ( IsValid(player) and player:Alive() ) then
					player:TakeDamage(player:Health() * 2, attacker, inflictor);
				end;
			end);
		end;
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
	local endurance = openAura.attributes:Fraction(player, ATB_ENDURANCE, 0.5, 0.5);
	local clothes = player:GetCharacterData("clothes");
	
	if ( damageInfo:IsFallDamage() ) then
		damageInfo:ScaleDamage(1 - endurance);
	else
		damageInfo:ScaleDamage(1.25 - endurance);
	end;
	
	if (clothes) then
		local itemTable = openAura.item:Get(clothes);
		
		if (itemTable and itemTable.protection) then
			if ( damageInfo:IsBulletDamage() or (damageInfo:IsFallDamage() and itemTable.protection >= 0.8) ) then
				damageInfo:ScaleDamage(1 - itemTable.protection);
			end;
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
		local strength = openAura.attributes:Fraction(attacker, ATB_STRENGTH, 1, 0.5);
		local weapon = openAura.player:GetWeaponClass(attacker);
		
		if ( damageInfo:IsDamageType(DMG_CLUB) or damageInfo:IsDamageType(DMG_SLASH) ) then
			damageInfo:ScaleDamage(1 + strength);
		end;
		
		if (weapon == "weapon_crowbar") then
			if ( entity:IsPlayer() ) then
				damageInfo:ScaleDamage(0.1);
			else
				damageInfo:ScaleDamage(0.8);
			end;
		end;
	end;
end;