--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

-- Called when a player's property should be restored.
function Schema:PlayerReturnProperty(player)
	local uniqueID = player:UniqueID();
	local removed = {};
	local key = player:GetCharacterKey();
	
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
		Clockwork:StartDataStream(nil, "BillboardRemove", removed);
	end;
end;

-- Called when a player's data stream info should be sent.
function Schema:PlayerSendDataStreamInfo(player)
	local billboards = {};
	
	for k, v in ipairs(self.billboards) do
		if (v.data) then
			billboards[#billboards + 1] = {
				data = v.data,
				id = k
			};
		end;
	end;
	
	Clockwork:StartDataStream(player, "Billboards", billboards);
end;

-- Called when a player stuns an entity.
function Schema:PlayerStunEntity(player, entity)
	local target = Clockwork.entity:GetPlayer(entity);
	local strength = Clockwork.attributes:Fraction(player, ATB_STRENGTH, 12, 6);
	
	player:ProgressAttribute(ATB_STRENGTH, 0.5, true);
	
	if (target and target:Alive()) then
		local curTime = CurTime();
		
		if (target.nextStunInfo and curTime <= target.nextStunInfo[2]) then
			target.nextStunInfo[1] = target.nextStunInfo[1] + 1;
			target.nextStunInfo[2] = curTime + 8;
			
			if (target.nextStunInfo[1] == 1) then
				Clockwork.player:SetRagdollState(target, RAGDOLL_KNOCKEDOUT, 60);
			end;
		else
			target.nextStunInfo = {0, curTime + 4};
		end;
		
		target:ViewPunch(Angle(12 + strength, 0, 0));
		
		umsg.Start("cwStunned", target);
			umsg.Float(0.5);
		umsg.End();
	end;
end;

-- Called to check if a player does recognise another player.
function Schema:PlayerDoesRecognisePlayer(player, target, status, isAccurate, realValue)
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
function Schema:PlayerGiveWeapons(player)
	if (player:Team() == CLASS_POLICE or player:Team() == CLASS_DISPENSER
	or player:Team() == CLASS_RESPONSE) then
		Clockwork.player:GiveSpawnWeapon(player, "cw_stunbaton");
	end;
end;

-- Called when a player attempts to use a lowered weapon.
function Schema:PlayerCanUseLoweredWeapon(player, weapon, secondary)
	if (secondary and (weapon.SilenceTime or weapon.PistolBurst)) then
		return true;
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

-- Called when a player attempts to earn wages cash.
function Schema:PlayerCanEarnWagesCash(player, cash)
	local team = player:Team();
	
	if (team == CLASS_POLICE or team == CLASS_DISPENSER or team == CLASS_SECRETARY
	or team == CLASS_PRESIDENT or team == CLASS_RESPONSE) then
		local noWagesTime = Clockwork:GetSharedVar("NoWagesTime");
		local curTime = CurTime();
		
		if (noWagesTime >= curTime) then
			Clockwork.player:Notify(player, "You did not earn any wages because the president was killed recently.");
			
			return false;
		end;
	end;
end;

-- Called when a player gets high on a drug.
function Schema:PlayerGetHighOnDrug(player, itemTable)
	if (itemTable("addictionRate")) then
		local addictTable = player:GetCharacterData("Addictions");
		local itemUniqueID = itemTable("uniqueID");
		
		if (addictTable) then
			if (!addictTable[itemUniqueID]) then
				addictTable[itemUniqueID] = {
					count = 0,
					nextFix = 0
				};
			end;
			
			addictTable[itemUniqueID].count = addictTable[itemUniqueID].count + 1;
			
			if (addictTable[itemUniqueID].count >= itemTable("addictionRate")) then
				Clockwork.hint:Send(player, "Your character is addicted to "..string.lower(itemTable("name"))..".", 8, Color(150, 200, 50, 255));
				addictTable[itemUniqueID].nextFix = os.clock() + 10800;
			end;
		end;
	end;
end;

-- Called when a player attempts to earn generator cash.
function Schema:PlayerCanEarnGeneratorCash(player, info, cash)
	local team = player:Team();
	
	if (team == CLASS_POLICE or team == CLASS_SECRETARY or team == CLASS_RESPONSE
	or team == CLASS_PRESIDENT or team == CLASS_DISPENSER) then
		return false;
	end;
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

-- Called when an entity is removed.
function Schema:EntityRemoved(entity)
	if (IsValid(entity) and entity:GetClass() == "prop_ragdoll") then
		if (entity.cwIsBelongings) then
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

-- Called when a player's character has loaded.
function Schema:PlayerCharacterLoaded(player)
	player:SetSharedVar("Lottery", false);
	player.cwLottery = nil;
end;

-- Called when an entity's menu option should be handled.
function Schema:EntityHandleMenuOption(player, entity, option, arguments)
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
				OnTakeItem = function(player, storageTable, itemTable)
					if (entity.cwClothesData and itemTable("itemID") == entity.cwClothesData[1]) then
						entity:SetModel(entity.cwClothesData[2]);
						entity:SetSkin(entity.cwClothesData[3]);
					end;
				end,
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
	elseif (entity:GetClass() == "cw_broadcaster") then
		if (arguments == "cwBroadcasterToggle") then
			entity:Toggle();
		elseif (arguments == "cwBroadcasterTake") then
			local success, fault = player:GiveItem(entity:GetItemTable());
			
			if (!success) then
				Clockwork.player:Notify(entity, fault);
			else
				entity:Remove();
			end;
		end;
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
					
					Clockwork.player:Notify(player, "You have set this stationary radio's frequency to "..arguments..".");
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

-- Called when Clockwork has loaded all of the entities.
function Schema:ClockworkInitPostEntity()
	Clockwork:SetSharedVar("Lottery", CurTime() + 3600);
	
	self:LoadLotteryCash();
	self:LoadBelongings();
	self:LoadRadios();
end;

-- Called just after data should be saved.
function Schema:PostSaveData()
	self:SaveLotteryCash();
	self:SaveBelongings();
	self:SaveRadios();
end;

-- Called when a player has an item taken.
function Clockwork:PlayerItemTaken(player, itemTable)
	if (itemTable("uniqueID") == "skull_mask") then
		if (player:GetSharedVar("SkullMask") == itemTable("itemID")) then
			itemTable:OnPlayerUnequipped(player);
		end;
	elseif (itemTable("uniqueID") == "heartbeat_sensor") then
		if (player:GetSharedVar("Sensor") == itemTable("itemID")) then
			itemTable:OnPlayerUnequipped(player);
		end;
	end;
end;

-- Called when a player switches their flashlight on or off.
function Schema:PlayerSwitchFlashlight(player, bIsOn)
	if (bIsOn and player:GetSharedVar("IsTied") != 0) then
		return false;
	end;
end;

-- Called when a player attempts to spray their tag.
function Schema:PlayerSpray(player)
	if (!player:HasItemByID("spray_can") or player:GetSharedVar("IsTied") != 0) then
		return true;
	end;
end;

-- Called when a player presses F3.
function Schema:ShowSpare1(player)
	Clockwork.player:RunClockworkCommand(player, "InvAction", "use", "zip_tie");
end;

-- Called when a player presses F4.
function Schema:ShowSpare2(player)
	Clockwork.player:RunClockworkCommand(player, "CharSearch");
end;

-- Called when a player spawns an object.
function Schema:PlayerSpawnObject(player)
	if (player:GetSharedVar("IsTied") != 0) then
		Clockwork.player:Notify(player, "You cannot do this action at the moment!");
		
		return false;
	end;
end;

-- Called when a player attempts to breach an entity.
function Schema:PlayerCanBreachEntity(player, entity)
	if (Clockwork.entity:IsDoor(entity)) then
		if (!Clockwork.entity:IsDoorHidden(entity)) then
			return true;
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

-- Called when a player attempts to use a door.
function Schema:PlayerCanUseDoor(player, door)
	local team = player:Team();
	
	if (player:GetSharedVar("IsTied") != 0 or (team != CLASS_POLICE and team != CLASS_SECRETARY
	and team != CLASS_PRESIDENT and team != CLASS_DISPENSER and team != CLASS_RESPONSE)) then
		return false;
	end;
end;

-- Called when a player presses a key.
function Schema:KeyPress(player, key)
	if (key == IN_USE) then
		local untieTime = Schema:GetDexterityTime(player);
		local eyeTrace = player:GetEyeTraceNoCursor();
		local target = eyeTrace.Entity;
		local entity = target;
		
		if (IsValid(target)) then
			target = Clockwork.entity:GetPlayer(target);
			
			if (target and player:GetSharedVar("IsTied") == 0) then
				if (target:GetShootPos():Distance(player:GetShootPos()) <= 192) then
					if (target:GetSharedVar("IsTied") != 0 and target:Alive()) then
						Clockwork.player:SetAction(player, "untie", untieTime);
						
						target:SetSharedVar("BeingUntied", true);
						
						Clockwork.player:EntityConditionTimer(player, target, entity, untieTime, 192, function()
							return player:Alive() and target:Alive() and !player:IsRagdolled() and player:GetSharedVar("IsTied") == 0;
						end, function(success)
							if (success) then
								self:TiePlayer(target, false);
								
								player:ProgressAttribute(ATB_DEXTERITY, 15, true);
							end;
							
							if (IsValid(target)) then
								target:SetSharedVar("BeingUntied", false);
							end;
							
							Clockwork.player:SetAction(player, "untie", false);
						end);
					end;
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
					if ((v:GetCharacterData("Frequency") == data.frequency and v:GetSharedVar("IsTied") == 0
					and v:HasItemByID("handheld_radio")) or info.speaker == v) then
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
				if (v:GetSharedVar("IsTied") == 0) then
					info.listeners[v] = v;
				end;
			end;
		end;
	end;
end;

-- Called when a player attempts to use a tool.
function Schema:CanTool(player, trace, tool)
	if (!Clockwork.player:HasFlags(player, "w")) then
		if (string.sub(tool, 1, 5) == "wire_" or string.sub(tool, 1, 6) == "wire2_") then
			player:RunCommand("gmod_toolmode \"\"");
			
			return false;
		end;
	end;
end;

-- Called when a player has been bIsHealed.
function Schema:PlayerHealed(player, healer, itemTable)
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

-- Called when config has initialized for a player.
function Schema:PlayerConfigInitialized(player)
	local blacklisted = player:GetData("Blacklisted");
	
	if (blacklisted) then
		Clockwork:StartDataStream({player}, "GetBlacklist", blacklisted);
	end;
end;

-- Called when a player's data should be restored.
function Schema:PlayerRestoreData(player, data)
	if (!data["Blacklisted"]) then
		data["Blacklisted"] = {};
	end;
	
	for k, v in ipairs(data["Blacklisted"]) do
		if (!Clockwork.class:FindByID(v)) then
			table.remove(data["Blacklisted"], k);
		end;
	end;
end;

-- Called when a player's character data should be restored.
function Schema:PlayerRestoreCharacterData(player, data)
	if (data["Version"] != 1) then
		data["Alliance"] = nil;
		data["Version"] = 1;
	end;
	
	if (!data["Addictions"]) then
		data["Addictions"] = {};
	end;
	
	if (data["CallerID"] == "911") then
		data["CallerID"] = nil;
	end;
	
	if (!data["Hunger"]) then
		data["Hunger"] = 0;
	end;

	if (!data["Thirst"]) then
		data["Thirst"] = 0;
	end;
	
	if (!data["Stars"]) then
		data["Stars"] = {
			stars = 0,
			crimes = {},
			clearTime = 0
		};
	end;
end;

-- Called when a player's shared variables should be set.
function Schema:PlayerSetSharedVars(player, curTime)
	player:SetSharedVar("Alliance", player:GetCharacterData("Alliance"));
	player:SetSharedVar("Leader", player:GetCharacterData("Leader"));
	player:SetSharedVar("Sensor", player:GetCharacterData("Sensor"));
	player:SetSharedVar("Hunger", math.Round(player:GetCharacterData("Hunger")));
	player:SetSharedVar("Thirst", math.Round(player:GetCharacterData("Thirst")));
	
	if (player.cwCancelDisguise) then
		if (curTime >= player.cwCancelDisguise or !IsValid(player:GetSharedVar("Disguise"))) then
			Clockwork.player:Notify(player, "Your disguise has begun to fade away, your true identity is revealed.");
			
			player.cwCancelDisguise = nil;
			player:SetSharedVar("Disguise", NULL);
		end;
	end;
	
	if (player:Alive() and !player:IsRagdolled() and player:GetVelocity():Length() > 0) then
		local inventoryWeight = player:GetInventoryWeight();
		
		if (inventoryWeight >= player:GetMaxWeight() / 4) then
			player:ProgressAttribute(ATB_STRENGTH, inventoryWeight / 400, true);
		end;
	end;
	
	if (player:Alive()) then
		if (player:GetCharacterData("Hunger") == 100) then
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
		
		if (player:GetCharacterData("Thirst") == 100) then
			player:BoostAttribute("Thirst", ATB_DEXTERITY, -50);
			player:BoostAttribute("Thirst", ATB_MEDICAL, -50);
		else
			player:BoostAttribute("Thirst", ATB_DEXTERITY, false);
			player:BoostAttribute("Thirst", ATB_MEDICAL, false);
		end;
	end;
	
	local addictTable = player:GetCharacterData("Addictions");
	local addictedTo = {};
	local withdrawal = false;
	local unixTime = os.clock();
	
	for k, v in pairs(addictTable) do
		if (v.count > 0 and unixTime - v.nextFix >= 86400) then
			addictTable[k] = nil;
		elseif (v.count > 0 and unixTime >= v.nextFix) then
			local itemTable = Clockwork.item:FindByID(k);
			
			if (itemTable) then
				addictedTo[#addictedTo + 1] = itemTable("name");
				withdrawal = true;
			end;
		end;
	end;
	
	if (withdrawal) then
		player:BoostAttribute("Withdrawal", ATB_ACROBATICS, -50);
		player:BoostAttribute("Withdrawal", ATB_ENDURANCE, -50);
		player:BoostAttribute("Withdrawal", ATB_STRENGTH, -50);
		player:BoostAttribute("Withdrawal", ATB_AGILITY, -50);
		
		if (!player.cwNextWarnWithdrawal or curTime >= player.cwNextWarnWithdrawal) then
			if (#addictedTo > 0) then
				player.cwNextWarnWithdrawal = curTime + 1800;
				Clockwork.hint:Send(player, "Your character is suffering withdrawal symptoms from "..string.lower(table.concat(addictedTo, ", "))..".", 8, Color(200, 150, 75, 255));
			end;
		end;
	else
		player:BoostAttribute("Withdrawal", ATB_ACROBATICS, false);
		player:BoostAttribute("Withdrawal", ATB_ENDURANCE, false);
		player:BoostAttribute("Withdrawal", ATB_STRENGTH, false);
		player:BoostAttribute("Withdrawal", ATB_AGILITY, false);
	end;
	
	player:SetSharedVar("Withdrawal", withdrawal);
	player:SetSharedVar("Stars", player:GetCharacterData("Stars").stars);
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
	local bIsRagdolled = player:IsRagdolled();
	local frequency = player:GetCharacterData("Frequency");
	local aimVector = tostring(player:GetAimVector());
	local velocity = player:GetVelocity();
	local bIsAlive = player:Alive();
	
	if (player.cwLastAimVec != aimVector) then
		player.cwNextKickTime = curTime + 1800;
		player.cwLastAimVec = aimVector;
	end;
	
	if (player.cwNextKickTime and curTime >= player.cwNextKickTime) then
		player:Kick("You have been idle too long.");
	end;
	
	if (bIsAlive and !bIsRagdolled and player:IsInWorld()) then
		if (!player:InVehicle() and player:GetMoveType() == MOVETYPE_WALK) then
			if (!player:IsOnGround() and !IsValid(player:GetGroundEntity())) then
				player:ProgressAttribute(ATB_ACROBATICS, 0.1, true);
			elseif (infoTable.isRunning) then
				player:ProgressAttribute(ATB_STAMINA, 0.025, true);
			elseif (infoTable.isJogging) then
				player:ProgressAttribute(ATB_STAMINA, 0.0125, true);
			end;
		end;
	end;
	
	if (player:Alive()) then
		player:SetCharacterData("Hunger", math.Clamp(player:GetCharacterData("Hunger") + 0.00016, 0, 100));
		player:SetCharacterData("Thirst", math.Clamp(player:GetCharacterData("Thirst") + 0.00018, 0, 100));
	end;
	
	local acrobatics = Clockwork.attributes:Fraction(player, ATB_ACROBATICS, 175, 50);
	local strength = Clockwork.attributes:Fraction(player, ATB_STRENGTH, 8, 4);
	local agility = Clockwork.attributes:Fraction(player, ATB_AGILITY, 50, 25);
	
	if (clothes != "") then
		local itemTable = Clockwork.item:FindByID(clothes);
		
		if (itemTable and itemTable("pocketSpace")) then
			infoTable.inventoryWeight = infoTable.inventoryWeight + itemTable("pocketSpace");
		end;
	end;
	
	infoTable.inventoryWeight = infoTable.inventoryWeight + strength;
	infoTable.jumpPower = infoTable.jumpPower + acrobatics;
	infoTable.runSpeed = infoTable.runSpeed + agility;
	
	local stars = player:GetCharacterData("Stars");
	
	if (stars.clearTime > 0 and os.clock() >= stars.clearTime) then
		stars.stars = 0;
		stars.crimes = {};
		stars.clearTime = 0;
		self:SendCrimes(player);
	end;
end;

-- Called when attempts to use a command.
function Schema:PlayerCanUseCommand(player, commandTable, arguments)
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
function Schema:PlayerCanChangeClass(player, class)
	local blacklisted = player:GetData("Blacklisted");
	
	if (player:GetSharedVar("IsTied") != 0) then
		Clockwork.player:Notify(player, "You cannot change classes when you are tied!");
		return false;
	end;
	
	if (blacklisted and table.HasValue(blacklisted, class.index)) then
		Clockwork.player:Notify(player, "You are blacklisted from this class!");
		return false;
	end;
end;

-- Called when a player attempts to use an entity.
function Schema:PlayerUse(player, entity)
	local curTime = CurTime();
	
	if (entity.cwIsBustedDown) then
		return false;
	end;
	
	if (player:GetSharedVar("IsTied") != 0) then
		if (entity:IsVehicle()) then
			if (Clockwork.entity:IsChairEntity(entity) or Clockwork.entity:IsPodEntity(entity)) then
				return;
			end;
		end;
		
		if (!player.cwNextTieNotice or player.cwNextTieNotice < CurTime()) then
			Clockwork.player:Notify(player, "You cannot use that when you are tied!");
			player.cwNextTieNotice = CurTime() + 2;
		end;
		
		return false;
	end;
end;

-- Called when a player attempts to destroy an item.
function Schema:PlayerCanDestroyItem(player, itemTable, bNoMsg)
	if (player:GetSharedVar("IsTied") != 0) then
		if (!bNoMsg) then
			Clockwork.player:Notify(player, "You cannot destroy items when you are tied!");
		end;
		
		return false;
	end;
end;

-- Called when a player attempts to drop an item.
function Schema:PlayerCanDropItem(player, itemTable, bNoMsg)
	if (player:GetSharedVar("IsTied") != 0) then
		if (!bNoMsg) then
			Clockwork.player:Notify(player, "You cannot drop items when you are tied!");
		end;
		
		return false;
	end;
end;

-- Called when a player attempts to use an item.
function Schema:PlayerCanUseItem(player, itemTable, bNoMsg)
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

-- Called when a player attempts to say something out-of-character.
function Schema:PlayerCanSayOOC(player, text)
	if (!player:Alive()) then
		Clockwork.player:Notify(player, "You cannot do this action at the moment!");
	end;
end;

-- Called when a player attempts to say something locally out-of-character.
function Schema:PlayerCanSayLOOC(player, text)
	if (!player:Alive()) then
		Clockwork.player:Notify(player, "You cannot do this action at the moment!");
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
		
		if (info.class == "ic") then
			for k, v in ipairs(ents.FindByClass("cw_broadcaster")) do
				if (!v:IsOff() and info.speaker:GetPos():Distance(v:GetPos()) <= 64) then
					for k2, v2 in ipairs(_player.GetAll()) do
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
function Schema:PlayerDestroyGenerator(player, entity, generator)
	local team = player:Team();
	local cash = generator.cash;
	
	if (string.find(generator.name, "Lab")) then
		cash = cash / 2;
	end;
	
	if (team == CLASS_POLICE or team == CLASS_DISPENSER or team == CLASS_RESPONSE) then
		local recipients = {};
		
		table.Add(recipients, _team.GetPlayers(CLASS_DISPENSER));
		table.Add(recipients, _team.GetPlayers(CLASS_POLICE));
		
		for k, v in pairs(recipients) do
			Clockwork.player:GiveCash(v, cash, "destroying a "..string.lower(generator.name));
		end;
	else
		Clockwork.player:GiveCash(player, cash, "destroying a "..string.lower(generator.name));
	end;
end;

-- Called when a player dies.
function Schema:PlayerDeath(player, inflictor, attacker, damageInfo)
	if (attacker:IsPlayer()) then
		local listeners = {};
		local weapon = attacker:GetActiveWeapon();
		
		for k, v in ipairs(_player.GetAll()) do
			if (v:IsAdmin() or v:IsUserGroup("operator")) then
				if (v:HasInitialized()) then
					listeners[#listeners + 1] = v;
				end;
			end;
		end;
		
		if (#listeners > 0) then
			Clockwork.chatBox:Add(listeners, attacker, "killed", "", {victim = player});
		end;
		
		if (IsValid(weapon)) then
			umsg.Start("cwDeath", player);
				umsg.Entity(weapon);
			umsg.End();
		else
			umsg.Start("cwDeath", player);
			umsg.End();
		end;
	else
		umsg.Start("cwDeath", player);
		umsg.End();
	end;
	
	if (damageInfo) then
		local miscellaneousDamage = damageInfo:IsBulletDamage() or damageInfo:IsExplosionDamage();
		local meleeDamage = damageInfo:IsDamageType(DMG_CLUB) or damageInfo:IsDamageType(DMG_SLASH);
		
		if (miscellaneousDamage or meleeDamage) then
			self:PlayerDropRandomItems(player, player:GetRagdollEntity());
		end;
	end;
	
	if (player:Team() == CLASS_PRESIDENT) then
		if (attacker:IsPlayer()) then
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
function Schema:PlayerDeathThink(player)
	if (player:GetCharacterData("IsDead")) then
		return true;
	end;
end;

-- Called when a player attempts to switch to a character.
function Schema:PlayerCanSwitchCharacter(player, character)
	if (player:GetCharacterData("IsDead")) then
		return true;
	end;
end;

-- Called when a player's death info should be adjusted.
function Schema:PlayerAdjustDeathInfo(player, info)
	if (player:GetCharacterData("IsDead")) then
		info.spawnTime = 0;
	end;
end;

-- Called when a player's character screen info should be adjusted.
function Schema:PlayerAdjustCharacterScreenInfo(player, character, info)
	if (character.data["IsDead"]) then
		info.details = "This character is permanently dead.";
	end;
end;

-- Called when a player attempts to delete a character.
function Schema:PlayerCanDeleteCharacter(player, character)
	if (character.data["IsDead"]) then
		return true;
	end;
end;

-- Called when a player attempts to use a character.
function Schema:PlayerCanUseCharacter(player, character)
	if (character.data["IsDead"]) then
		return character.name.." is permanently killed and cannot be used!";
	end;
end;

-- Called each tick.
function Schema:Tick()
	local nextLotteryTime = Clockwork:GetSharedVar("Lottery");
	local curTime = CurTime();
	
	if (self.demotePresident and !IsValid(self.demotePresident)) then
		Clockwork:SetSharedVar("NoWagesTime", curTime + (Clockwork.config:Get("wages_interval"):Get() * 2));
		self.demotePresident = nil;
	end;
	
	if (curTime >= nextLotteryTime and (!self.cwLotteryPaused or curTime >= self.cwLotteryPaused)) then
		math.randomseed(curTime);
		
		local winningNumbers = {
			math.random(1, 10),
			math.random(1, 10),
			math.random(1, 10)
		}
		local lotteryCash = self.cwLotteryCash;
		local playerWinners = {};
		
		self.cwLotteryPaused = curTime + 4;
		
		Clockwork:SetSharedVar("Lottery", curTime + 3600);
		
		for k, v in ipairs(_player.GetAll()) do
			if (v:HasInitialized() and v.cwLottery) then
				if (self:HasWonLottery(v, v.cwLottery, winningNumbers)) then
					playerWinners[#playerWinners + 1] = v;
				end;
				
				v:SetSharedVar("Lottery", false);
				v.cwLottery = nil;
			end;
		end;
		
		if (#playerWinners > 0) then
			local cashEach = math.Round(lotteryCash / #playerWinners);
			local playerNames = "";
			local winnerCount = #playerWinners;
			
			self.cwLotteryCash = 0;
			
			for k, v in ipairs(playerWinners) do
				if (k == 1 or winnerCount == 1) then
					playerNames = v:Name();
				elseif (k == winnerCount) then
					playerNames = playerName.." and "..v:Name();
				else
					playerNames = playerNames..", ";
				end;
				
				Clockwork.player:GiveCash(v, cashEach, "winning the lottery");
			end;
			
			if (winnerCount == 1) then
				Clockwork.chatBox:Add(nil, nil, "lottery", "The lottery is over, "..playerNames.." has won "..FORMAT_CASH(cashEach).."!");
			else
				Clockwork.chatBox:Add(nil, nil, "lottery", "The lottery is over, "..playerNames.." have won "..FORMAT_CASH(cashEach).." each!");
			end;
		end;
	end;
end;

-- Called just before a player dies.
function Schema:DoPlayerDeath(player, attacker, damageInfo)
	self:TiePlayer(player, false, true);
	
	player.cwIsBeingSearched = nil;
	player.cwIsSearchingChar = nil;
end;

-- Called when a player's class has been set.
function Schema:PlayerClassSet(player, newClass, oldClass, noRespawn, addDelay, noModelChange)
	local generatorEntities = {};
	
	for k, v in pairs(Clockwork.generator.stored) do
		table.Add(generatorEntities, ents.FindByClass(k));
	end;
	
	if (newClass.index == CLASS_POLICE or newClass.index == CLASS_PRESIDENT
	or newClass.index == CLASS_DISPENSER or newClass.index == CLASS_RESPONSE) then
		if (newClass.index == CLASS_PRESIDENT or newClass.index == CLASS_RESPONSE) then
			player:SetArmor(150);
		else
			player:SetArmor(100);
		end;
		
		player.cwHasFreeArmor = true;
	elseif (player.cwHasFreeArmor) then
		player:SetArmor(0);
		player.cwHasFreeArmor = nil;
	end;
	
	for k, v in pairs(generatorEntities) do
		if (player == v:GetPlayer()) then
			local generator = Clockwork.generator:FindByID(v:GetClass());
			local itemTable = Clockwork.item:FindByID(generator.name);
			
			if (itemTable and !Clockwork:HasObjectAccess(player, itemTable)) then
				v:Explode();
				v:Remove();
			end;
		end;
	end;
end;

-- Called when a player's storage should close.
function Schema:PlayerStorageShouldClose(player, storage)
	local entity = player:GetStorageEntity();
	
	if (player.cwIsSearchingChar and entity:IsPlayer()
	and entity:GetSharedVar("IsTied") == 0) then
		return true;
	end;
end;

-- Called just after a player spawns.
function Schema:PostPlayerSpawn(player, lightSpawn, changeClass, firstSpawn)
	local skullMask = player:GetCharacterData("SkullMask");
	local team = player:Team();

	if (!firstSpawn and !lightSpawn) then
		player:SetCharacterData("Hunger", 0);
		player:SetCharacterData("Thirst", 0);
	end;
	
	if (!lightSpawn) then
		if (self.demotePresident == player) then
			Clockwork:SetSharedVar("NoWagesTime", CurTime() + (Clockwork.config:Get("wages_interval"):Get() * 2));
				Clockwork.class:Set(player, CLASS_CIVILIAN, true, true, true);
			self.demotePresident = nil;
			
			Clockwork.player:SetDefaultModel(player);
		end;
		
		umsg.Start("cwClearEffects", player);
		umsg.End();
		
		player:SetCharacterData("Stars", {
			stars = 0,
			crimes = {},
			clearTime = 0
		});
		player:SetSharedVar("Disguise", NULL);
		player.cwCancelDisguise = nil;
		player.cwIsBeingSearched = nil;
		player.cwIsSearchingChar = nil;
		
		self:SendCrimes(player);
	end;
	
	if (player:GetSharedVar("IsTied") != 0) then
		self:TiePlayer(player, true);
	end;
	
	if (skullMask) then
		local itemTable = Clockwork.item:FindByID("skull_mask");
		
		if (itemTable and player:HasItemInstance(itemTable("uniqueID"))) then
			Clockwork.player:CreateGear(player, "SkullMask", itemTable);
			player:SetSharedVar("SkullMask", true);
		else
			player:SetCharacterData("SkullMask", nil);
		end;
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
	
	player:EmitSound(sound);
end;

-- Called when a player throws a punch.
function Schema:PlayerPunchThrown(player)
	player:ProgressAttribute(ATB_STRENGTH, 0.25, true);
end;

-- Called when a player punches an entity.
function Schema:PlayerPunchEntity(player, entity)
	if (entity:IsPlayer() or entity:IsNPC()) then
		player:ProgressAttribute(ATB_STRENGTH, 1, true);
	else
		player:ProgressAttribute(ATB_STRENGTH, 0.5, true);
	end;
end;

-- Called when an entity has been breached.
function Schema:EntityBreached(entity, activator)
	if (Clockwork.entity:IsDoor(entity)) then
		if (entity:GetClass() != "prop_door_rotating") then
			Clockwork.entity:OpenDoor(entity, 0, true, true);
		else
			self:BustDownDoor(activator, entity);
		end;
	end;
end;

-- Called when a player takes damage.
function Schema:PlayerTakeDamage(player, inflictor, attacker, hitGroup, damageInfo)
	if (player:Health() <= 10 and math.random() <= 0.75) then
		if (Clockwork.player:GetAction(player) != "die") then
			Clockwork.player:SetRagdollState(player, RAGDOLL_FALLENOVER, nil, nil, Clockwork:ConvertForce(damageInfo:GetDamageForce() * 32));
			
			Clockwork.player:SetAction(player, "die", 60, 1, function()
				if (IsValid(player) and player:Alive()) then
					player:TakeDamage(player:Health() * 2, attacker, inflictor);
				end;
			end);
		end;
	end;
end;

-- Called when a player's limb damage is bIsHealed.
function Schema:PlayerLimbDamageHealed(player, hitGroup, amount)
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
function Schema:PlayerLimbDamageReset(player)
	player:BoostAttribute("Limb Damage", nil, false);
end;

-- Called when a player's limb takes damage.
function Schema:PlayerLimbTakeDamage(player, hitGroup, damage)
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
function Schema:PlayerScaleDamageByHitGroup(player, attacker, hitGroup, damageInfo, baseDamage)
	local clothesItem = player:GetClothesItem();
	local endurance = Clockwork.attributes:Fraction(player, ATB_ENDURANCE, 0.5, 0.5);
	
	if (damageInfo:IsFallDamage()) then
		damageInfo:ScaleDamage(1 - endurance);
	else
		damageInfo:ScaleDamage(1.25 - endurance);
	end;
	
	if (clothesItem and clothesItem.protection) then
		if (damageInfo:IsBulletDamage() or (damageInfo:IsFallDamage() and clothesItem.protection >= 0.8)) then
			damageInfo:ScaleDamage(1 - clothesItem.protection);
		end;
	end;
end;

-- Called when an entity takes damage.
function Schema:EntityTakeDamage(entity, inflictor, attacker, amount, damageInfo)
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