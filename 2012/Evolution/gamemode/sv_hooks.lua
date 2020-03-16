--[[
	© 2012 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

-- Called when a player attempts to use a lowered weapon.
function Schema:PlayerCanUseLoweredWeapon(player, weapon, secondary)
	if (secondary and (weapon.SilenceTime or weapon.PistolBurst)) then
		return true;
	end;
end;

-- Called when a player switches their flashlight on or off.
function Schema:PlayerSwitchFlashlight(player, bIsOn)
	local weaponItem = Clockwork.item:GetByWeapon(player:GetActiveWeapon());
	
	if (bIsOn and weaponItem and weaponItem("hasFlashlight")) then
		return true;
	end;
	
	return !bIsOn;
end;

-- Called when a player's data has loaded.
function Schema:PlayerDataLoaded(player)
	if (!player:GetData("ClockworkIntro")) then
		Clockwork.player:PlaySound(player, "aperture.mp3");
	end;
end;

-- Called when a player attempts to fire a weapon.
function Schema:PlayerCanFireWeapon(player, bIsRaised, weapon, bIsSecondary)
	if ((weapon:GetClass() == "rcs_g3sg1" or weapon:GetClass() == "rcs_awp"
	or weapon:GetClass() == "rcs_scout") and weapon:GetNetworkedInt("Zoom") == 0
	and !bIsSecondary) then
		return false;
	end;
end;

-- Called to get whether a player can give an item to storage.
function Schema:PlayerCanGiveToStorage(player, storageTable, itemTable)
	if (storageTable.entity:GetClass() == "cw_safebox" and itemTable:GetData("Rarity") == 3) then
		Clockwork.player:Notify(player, "You cannot place unique items into your safebox!");
		return false;
	end;
end;

-- Called when a player's earn generator info should be adjusted.
function Schema:PlayerAdjustEarnGeneratorInfo(player, info)
	info.cash = info.cash + ((info.cash * 0.5) * info.entity:GetNetworkedInt("Level"));
	
	if (player:GetTimeCreated() + 3600 > os.time()) then
		info.cash = info.cash * 2;
	end;
end;

-- Called when a player's character has initialized.
function Schema:PlayerCharacterInitialized(player)
	if (player:GetTimeCreated() + 3600 > os.time()
	and !player:GetCharacterData("DoubleGens")) then
		Clockwork.hint:Send(
			player, "You will recieve double printer pay for your first hour!", 60,
			Clockwork.option:GetColor("positive_hint"), "hl1/fvox/beep.wav"
		);
		
		player:SetCharacterData("DoubleGens", true);
	end;
end;

-- Called when an item entity has taken damage.
function Schema:ItemEntityTakeDamage(itemEntity, itemTable, damageInfo)
	if (itemTable:GetData("Rarity") == 2 or itemTable:GetData("Rarity") == 3) then
		damageInfo:ScaleDamage(0.25);
	end;
end;

-- Called when an entity fires some bullets.
function Schema:EntityFireBullets(entity, bulletInfo)
	if (entity:IsPlayer()) then
		local weaponItemTable = Clockwork.item:GetByWeapon(entity:GetActiveWeapon());
		local reduceAmount = (bulletInfo.Damage * ((bulletInfo.Num or 2) * 0.5)) / 150;
		
		if (weaponItemTable and weaponItemTable:IsBasedFrom("custom_weapon")) then
			weaponItemTable:SetData(
				"Durability", math.Clamp(weaponItemTable:GetData("Durability") - reduceAmount, 0, 100) 
			);
		end;
		
		local itemsList = entity:GetItemsByID("custom_ammo");
		local itemTable = nil;
		
		if (itemsList) then
			for k, v in pairs(itemsList) do
				if (v:GetData("IsEquipped")) then
					itemTable = v;
					break;
				end;
			end;
			
			if (itemTable) then
				itemTable:FireRound(nil, entity, bulletInfo, true);
			end;
		end;
		
		local stealthCamo = entity:GetWeapon("cw_stealthcamo");
		local bUsingStealth = (IsValid(stealthCamo) and stealthCamo:IsActivated());
		
		if (bUsingStealth and key == IN_ATTACK) then
			entity:SetSharedVar("HideStealth", CurTime() + 2);
			
			if (!entity.cwNextStealthOffSnd
			or CurTime() >= entity.cwNextStealthOffSnd) then
				entity.cwNextStealthOffSnd = CurTime() + 2;
				entity:EmitSound("buttons/combine_button5.wav");
			end;
		end;
	end;
	
	if (!bulletInfo.Tracer or bulletInfo.Tracer < 1) then
		return;
	end;
	
	local curTime = CurTime();
	local filter = {entity};
	local player = entity;
	
	if (entity:IsPlayer()) then
		table.insert(filter, entity:GetActiveWeapon());
	else
		player = entity:GetParent();
	end;
	
	local traceLine = util.TraceLine({
		endpos = bulletInfo.Src + (bulletInfo.Dir * 4096),
		start = bulletInfo.Src,
		filter = filter
	});
	
	for k, v in ipairs(_player.GetAll()) do
		if (v:HasInitialized() and player != v and traceLine.Entity != v
		and (v:GetShootPos():Distance(traceLine.HitPos) < 196
		or v:GetPos():Distance(traceLine.HitPos) < 256)) then
			if (!v.cwNextSuppress) then
				v.cwNextSuppress = curTime + 2;
			end;
			
			if (!v.cwSuppressCount or curTime > v.cwNextSuppress) then
				v.cwSuppressCount = 0;
			end;
			
			v.cwSuppressCount = v.cwSuppressCount + 1;
			v.cwNextSuppress = curTime + 2;
			
			if (v.cwSuppressCount > 2 or bulletInfo.Damage > 30) then
				v.cwSuppressCount = 0;
				
				umsg.Start("cwNearMiss", v);
				umsg.End();
			end;
		end;
	end;
end;

-- Called when an item entity has been destroyed.
function Schema:ItemEntityDestroyed(itemEntity, itemTable)
	if (itemTable:GetData("Rarity") == 3) then
		Clockwork.player:PlaySound(nil, "sad_trombone.mp3");
			Clockwork.item:SendToPlayer(nil, itemTable);
		Clockwork.chatBox:Add(nil, nil, "destroyed_unique", tostring(itemTable("itemID")));
	end;
end;

-- Called when a player is given an item.
function Schema:PlayerItemGiven(player, itemTable, bForce)
	if (itemTable:GetData("Name") != "" and itemTable:GetData("Found") != nil
	and (itemTable:GetData("Found") != true or itemTable:GetData("Rarity") == 3)
	and (!player.cwItemCreateTime or CurTime() >= player.cwItemCreateTime)) then
		--[[ Only play the Zelda fanfare sound with legendary or unique items. --]]
		if (itemTable:GetData("Rarity") < 2) then return; end;
		
		if (!player.cwNextFoundItem or CurTime() >= player.cwNextFoundItem
		or itemTable:GetData("Rarity") == 3) then
			player.cwNextFoundItem = CurTime() + 32;
			Clockwork.item:SendToPlayer(nil, itemTable);
			
			if (!itemTable:GetData("Found")) then
				Clockwork.chatBox:Add(nil, player, "discovered_item", tostring(itemTable("itemID")));
				
				if (itemTable:GetData("Rarity") == 3) then
					Clockwork.player:PlaySound(nil, "item_found.mp3");
				else
					Clockwork.player:PlaySound(nil, "buttons/button6.wav");
				end;
				
				player.cwNextCanDisconnect = CurTime() + 120;
			elseif (itemTable:GetData("LastKey") != player:GetCharacterKey()) then
				Clockwork.chatBox:Add(nil, player, "found_unique", tostring(itemTable("itemID")));
				itemTable:SetData("LastKey", player:GetCharacterKey());
				
				if (itemTable:GetData("Rarity") == 3) then
					Clockwork.player:PlaySound(nil, "item_found.mp3");
				else
					Clockwork.player:PlaySound(nil, "buttons/button6.wav");
				end;
				
				player.cwNextCanDisconnect = CurTime() + 120;
			end;
		end;
		
		itemTable:SetData("Found", true);
	end; 
end;

--[[
	This is the MySQL table query for the group system.
--]]

local GROUP_SYSTEM_TABLE_QUERY = [[
CREATE TABLE IF NOT EXISTS `test_groups` (
	`_Key` smallint(11) unsigned NOT NULL AUTO_INCREMENT,
	`_Name` varchar(150) NOT NULL,
	`_Notes` longtext NOT NULL,
	PRIMARY KEY (`_Key`)
)
]];

-- Called when Clockwork has initialized.
function Schema:ClockworkInitialized()
	tmysql.query(string.gsub(GROUP_SYSTEM_TABLE_QUERY, "%s", " "));
end;

-- Called when a player's character has unloaded.
function Schema:PlayerCharacterUnloaded(player)
	local nextCanDisconnect = 0;
	local curTime = CurTime();
	
	if (player.cwNextCanDisconnect) then
		nextCanDisconnect = player.cwNextCanDisconnect;
	end;
	
	if (player:HasInitialized()) then
		if (player:GetSharedVar("IsTied")
		or curTime < nextCanDisconnect) then
			self:PlayerDropRandomItems(player, nil, true);
			Clockwork.player:DropWeapons(player);
		end;
	end;
	
	if (!player.cwVehicleList) then return; end;
	
	for k, v in pairs(player.cwVehicleList) do
		if (IsValid(k)) then k:Remove(); end;
	end;
end;

-- Called each tick.
function Schema:Tick()
	if (!self.nextCleanDecals
	or CurTime() >= self.nextCleanDecals) then
		self.nextCleanDecals = CurTime() + 60;
		
		for k, v in ipairs(_player.GetAll()) do
			v:RunCommand("r_cleardecals");
		end;
	end;
end;

-- Called when a player should take damage.
function Schema:PlayerShouldTakeDamage(player, attacker, inflictor, damageInfo)
	if (self:IsInSafeZone(player) or (attacker:IsPlayer() and self:IsInSafeZone(attacker))) then
		return false;
	end;
end;

-- Called to get whether a player's weapon is raised.
function Schema:GetPlayerWeaponRaised(player, class, weapon)
	if (self:IsInSafeZone(player)) then
		return false;
	end;
end;

-- Called when a player attempts to spawn a prop.
function Schema:PlayerSpawnProp(player, model)
	model = string.Replace(model, "\\", "/");
	model = string.Replace(model, "//", "/");
	model = string.lower(model);
	
	if (string.find(model, "fence")) then
		Clockwork.player:Notify(player, "You cannot spawn fence props!");
		return false;
	end;
	
	if (player.cwNextCanSpawnProp and CurTime() < player.cwNextCanSpawnProp) then
		Clockwork.player:Notify(player, "You cannot spawn another prop for another "..math.ceil(player.cwNextCanSpawnProp - CurTime()).." second(s)!");
		return false;
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
			Clockwork.player:CreateGear(player, "Weapons", itemTable);
		end;
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
			Clockwork.player:GetGear(player, "Weapons")
		};
		
		for k, v in pairs(gearTable) do
			if (IsValid(v)) then
				if (v:GetItemTable():IsTheSameAs(info.itemTable)) then
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
	if (IsValid(entity) and entity:GetClass() == "prop_ragdoll"
	and entity.cwIsBelongings and entity.cwInventory and entity.cwCash) then
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
	
	if (IsValid(entity) and !entity.cwIsBelongings) then
		Clockwork.entity:DropItemsAndCash(entity.cwInventory, entity.cwCash, entity:GetPos(), entity);
		entity.cwInventory = nil;
		entity.cwCash = nil;
	end;
end;

-- Called when a player's prop cost info should be adjusted.
function Schema:PlayerAdjustPropCostInfo(player, entity, info)
	local model = string.lower(entity:GetModel());
	
	if (self.containers[model]) then
		info.name = self.containers[model][2];
	end;
end;

-- Called when an entity's menu option should be handled.
function Schema:EntityHandleMenuOption(player, entity, option, arguments)
	if (entity:GetClass() == "cw_item" and option == "Customize"
	and Clockwork.player:HasFlags(player, "s")) then
		local itemTable = entity:GetItemTable();
		
		if (itemTable:IsBasedFrom("custom_weapon")) then
			itemTable:SetData("Rarity", arguments.rarity);
			itemTable:SetData("Damage", arguments.damage);
			itemTable:SetData("Desc", arguments.desc);
			itemTable:SetData("Name", arguments.name);
			player.cwItemCreateTime = CurTime() + 30;
		elseif (itemTable:IsBasedFrom("custom_clothes")) then
			itemTable:SetData("Rarity", arguments.rarity);
			itemTable:SetData("Armor", arguments.armor);
			itemTable:SetData("Desc", arguments.desc);
			itemTable:SetData("Name", arguments.name);
			player.cwItemCreateTime = CurTime() + 30;
		elseif (itemTable("uniqueID") == "custom_script") then
			if (arguments.interval) then
				itemTable:SetData("Interval", arguments.interval);
			end;
			
			itemTable:SetData("Category", arguments.category);
			itemTable:SetData("Reusable", arguments.reusable);
			itemTable:SetData("UseText", arguments.useText);
			itemTable:SetData("Rarity", arguments.rarity);
			itemTable:SetData("Weight", arguments.weight);
			itemTable:SetData("Script", arguments.script);
			itemTable:SetData("Model", arguments.model);
			itemTable:SetData("Desc", arguments.desc);
			itemTable:SetData("Name", arguments.name);
			player.cwItemCreateTime = CurTime() + 30;
			
			entity:SetModel(arguments.model);
			entity:PhysicsInit(SOLID_VPHYSICS);
			
			--[[
				Save this custom item script. This could all be converted
				to MySQL for cross-server support.
			--]]
			
			itemTable:SaveToScripts();
		elseif (itemTable("uniqueID") == "custom_ammo") then
			itemTable:SetData("Rarity", arguments.rarity);
			itemTable:SetData("Rounds", arguments.rounds);
			itemTable:SetData("Script", arguments.script);
			itemTable:SetData("Model", arguments.model);
			itemTable:SetData("Desc", arguments.desc);
			itemTable:SetData("Name", arguments.name);
			player.cwItemCreateTime = CurTime() + 30;
			
			entity:SetModel(arguments.model);
			entity:PhysicsInit(SOLID_VPHYSICS);
			
			--[[
				Save this custom item script. This could all be converted
				to MySQL for cross-server support.
			--]]
			
			itemTable:SaveToScripts();
		end;
	end;
	
	if (entity:GetClass() == "cw_landmine" and !entity:IsBuilding()) then
		if (!player:GetSharedVar("IsTied")) then
			if (arguments == "cwMineDefuse") then
				local defuseTime = Schema:GetDexterityTime(player) * 2;
				Clockwork.player:SetAction(player, "defuse", defuseTime);
				
				--[[ Ensure that we keep looking at the target... --]]
				Clockwork.player:EntityConditionTimer(player, entity, entity, defuseTime, 80, function()
					return player:Alive() and !player:IsRagdolled() and !player:GetSharedVar("IsTied");
				end, function(success)
					Clockwork.player:SetAction(player, "defuse", false);
					
					if (success) then
						entity:Defuse();
						entity:Remove();
					end;
				end);
			elseif (arguments == "cwFireBlast") then
				if (!entity:HasUpgrade(MINE_FIRE)) then
					if (Clockwork.player:CanAfford(player, 40)) then
						Clockwork.player:GiveCash(player, -40, "upgrading a Landmine");
							player:EmitSound("buttons/button"..math.random(4, 5)..".wav");
						entity:GiveUpgrade(MINE_FIRE);
					else
						Clockwork.player:Notify(player, "You need another "..FORMAT_CASH(40 - player:GetCash(), nil, true).."!");
					end;
				end;
			elseif (arguments == "cwIceBlast") then
				if (!entity:HasUpgrade(MINE_ICE)) then
					if (Clockwork.player:CanAfford(player, 40)) then
						Clockwork.player:GiveCash(player, -40, "upgrading a Landmine");
							player:EmitSound("buttons/button"..math.random(4, 5)..".wav");
						entity:GiveUpgrade(MINE_ICE);
					else
						Clockwork.player:Notify(player, "You need another "..FORMAT_CASH(40 - player:GetCash(), nil, true).."!");
					end;
				end;
			elseif (arguments == "cwStealth") then
				if (!entity:HasUpgrade(MINE_STEALTH)) then
					if (Clockwork.player:CanAfford(player, 40)) then
						Clockwork.player:GiveCash(player, -40, "upgrading a Landmine");
							player:EmitSound("buttons/button"..math.random(4, 5)..".wav");
						entity:GiveUpgrade(MINE_STEALTH);
						entity:SetMaterial("sprites/heatwave");
						entity:DrawShadow(false);
					else
						Clockwork.player:Notify(player, "You need another "..FORMAT_CASH(40 - player:GetCash(), nil, true).."!");
					end;
				end;
			end;
		end;
	elseif (entity:GetClass() == "cw_sign_post" and entity:GetNetworkedString("Text") == "") then
		entity:SetNetworkedString("Text", string.sub(string.gsub(arguments, "\n", ""), 0, 396));
	elseif (entity:GetClass() == "prop_ragdoll") then
		if (arguments == "cwCorpseLoot") then
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
				if (IsValid(entity) and Clockwork.inventory:IsEmpty(entity.cwInventory)) then
					entity:Explode(entity:BoundingRadius() * 2);
					entity:Remove();
				end;
			end,
			CanGiveItem = function(player, storageTable, itemTable)
				return false;
			end
		});
	elseif (entity:GetClass() == "cw_cash_printer") then
		if (arguments == "cwPrinterUpgrade") then
			local itemTable = Clockwork.item:FindByID("cash_printer");
			
			if (Clockwork.player:CanAfford(player, (itemTable.cost * 0.5))) then
				if (entity:GetNetworkedInt("Level") < 2) then
					Clockwork.player:GiveCash(player, -(itemTable.cost * 0.5), "upgrading a Cash Printer");
						entity:SetNetworkedInt("Level", entity:GetNetworkedInt("Level") + 1);
					player:EmitSound("buttons/button"..math.random(4, 5)..".wav");
				end;
			else
				Clockwork.player:Notify(player, "You need another "..FORMAT_CASH((itemTable.cost * 0.5) - player:GetCash(), nil, true).."!");
			end;
		elseif (arguments == "cwPrinterCollect") then
			if (entity:GetNetworkedInt("Cash") > 0) then
				Clockwork.player:GiveCash(player, entity:GetNetworkedInt("Cash"), "collected from a Cash Printer");
					entity:SetNetworkedInt("Cash", 0);
				player:EmitSound("buttons/button"..math.random(4, 5)..".wav");
			end;
		end;
	elseif (entity:GetClass() == "cw_broadcaster") then
		if (option == "Set Name" and type(arguments) == "string") then
			entity:SetNetworkedString("Name", arguments);
			entity:GetItemTable():SetData("Name", arguments);
		elseif (arguments == "cwBroadcasterToggle") then
			entity:Toggle();
		elseif (arguments == "cwBroadcasterTake") then
			if (player:GiveItem(entity:GetItemTable())) then
				entity:Remove();
			end;
		end;
	elseif (entity:GetClass() == "cw_breach") then
		entity:CreateDummyBreach();
		entity:BreachEntity(player);
	elseif (entity:GetClass() == "cw_radio") then
		if (option == "Set Frequency" and type(arguments) == "string") then
			if (string.find(arguments, "^%d%d%d%.%d$")) then
				local iStart, iFinish, iDecimal = string.match(arguments, "(%d)%d(%d)%.(%d)");
				
				if (iStart and iFinish and iDecimal) then
					iStart = tonumber(iStart);
					iFinish = tonumber(iFinish);
					iDecimal = tonumber(iDecimal);
				end;
				
				if (iStart == 1 and iFinish > 0 and iFinish < 10 and iDecimal > 0 and iDecimal < 10) then
					entity:SetFrequency(arguments);
					Clockwork.player:Notify(player, "You have set this radio's frequency to "..arguments..".");
				else
					Clockwork.player:Notify(player, "The radio frequency must be between 101.1 and 199.9!");
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
	elseif (entity:GetClass() == "cw_safebox" and arguments == "cwContainerOpen") then
		self:OpenContainer(player, entity);
	elseif (arguments == "cwContainerOpen") then
		if (Clockwork.entity:IsPhysicsEntity(entity)) then
			local model = string.lower(entity:GetModel());
			
			if (self.containers[model]) then
				local containerWeight = self.containers[model][1];
				
				if (!entity.cwPassword or entity.cwIsBreached) then
					self:OpenContainer(player, entity, containerWeight);
				else
					umsg.Start("cwContainerPassword", player);
						umsg.Entity(entity);
					umsg.End();
				end;
			end;
		end;
	end;
end;

-- Called when Clockwork has loaded all of the entities.
function Schema:ClockworkInitPostEntity()
	self:LoadSafeZoneList();
	self:LoadMissionData();
	self:LoadSafeboxList();
	self:LoadRandomItems();
	self:LoadBelongings();
	self:LoadSignPosts();
	self:LoadStorage();
	self:LoadRadios();
end;

-- Called just after data should be saved.
function Schema:PostSaveData()
	self:SaveBelongings();
	self:SaveSignPosts();
	self:SaveRadios();
end;

-- Called when data should be saved.
function Schema:SaveData()
	self:SaveStorage();
end;

-- Called when a player attempts to spray their tag.
function Schema:PlayerSpray(player)
	if (!player:HasItemByID("spray_can") or player:GetSharedVar("IsTied")) then
		return true;
	end;
end;

-- Called when a player presses F3.
function Schema:ShowSpare1(player)
	local traceLine = player:GetEyeTraceNoCursor();
	local target = Clockwork.entity:GetPlayer(traceLine.Entity);

	if (target and target:Alive()) then
		if (!target:GetSharedVar("IsTied")) then
			Clockwork.player:RunClockworkCommand(player, "InvAction", "use", "zip_tie");
		else
			Clockwork.player:RunClockworkCommand(player, "CharSearch");
		end;
	end;
end;

-- Called when a player spawns an object.
function Schema:PlayerSpawnObject(player)
	if (player:GetSharedVar("IsTied")) then
		Clockwork.player:Notify(player, "You cannot do this action at the moment!");
		return false;
	end;
end;

-- Called when an entity attempts to be auto-removed.
function Schema:EntityCanAutoRemove(entity)
	if (self.storage[entity] or entity:GetNetworkedString("Name") != "") then
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
	
	if (entity.cwInventory and entity.cwPassword) then
		return true;
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
	if (player:GetSharedVar("IsTied")) then
		return false;
	end;
end;

-- Called when a player uses a door.
function Schema:PlayerUseDoor(player, door)
	if (string.lower(game.GetMap()) == "rp_c18_v1") then
		local name = string.lower(door:GetName());
		
		if (name == "nxs_brnroom" or name == "nxs_brnroom2" or name == "nxs_al_door1"
		or name == "nxs_al_door2" or name == "nxs_brnbcroom") then
			local curTime = CurTime();
			
			if (!door.cwNextAutoClose or curTime >= door.cwNextAutoClose) then
				door:Fire("Close", "", 10);
				door.cwNextAutoClose = curTime + 10;
			end;
		end;
	end;
end;

-- Called when a player deletes a character.
function Schema:PlayerDeleteCharacter(player, character)
	local validContainers = {};
	
	for k, v in ipairs(ents.FindByClass("prop_physics")) do
		local model = string.lower(v:GetModel());
		
		if (self.containers[model]) then
			validContainers[#validContainers + 1] = v;
		end;
	end;
	
	for k, v in pairs(character.inventory) do
		for k2, v2 in pairs(v) do
			if (v2:GetData("Rarity") == 3) then
				self:PlaceInContainer(
					v2, validContainers[math.random(1, #validContainers)]
				);
			end;
		end;
	end;
end;

-- Called when a chat box message has been added.
function Schema:ChatBoxMessageAdded(info)
	if (info.class != "ic") then return; end;
	
	local eavesdroppers = {};
	local talkRadius = Clockwork.config:Get("talk_radius"):Get();
	local listeners = {};
	local players = _player.GetAll();
	local radios = ents.FindByClass("cw_radio");
	local data = {};
	
	for k, v in ipairs(radios) do
		if (!v:IsOff() and info.speaker:GetPos():Distance(v:GetPos()) <= 80) then
			local frequency = v:GetNetworkedString("Frequency");
			
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
			local radioFrequency = v:GetNetworkedString("Frequency");
			
			if (!v:IsOff() and radioFrequency == data.frequency) then
				for k2, v2 in ipairs(players) do
					if (v2:HasInitialized() and !listeners[v2] and !eavesdroppers[v2]
					and v2:GetPos():Distance(radioPosition) <= (talkRadius * 2)) then
						eavesdroppers[v2] = v2;
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

-- Called when a player has used their radio.
function Schema:PlayerRadioUsed(player, text, listeners, eavesdroppers)
	local newEavesdroppers = {};
	local talkRadius = Clockwork.config:Get("talk_radius"):Get() * 2;
	local frequency = player:GetCharacterData("Frequency");
	
	for k, v in ipairs(ents.FindByClass("cw_radio")) do
		local radioPosition = v:GetPos();
		local radioFrequency = v:GetNetworkedString("Frequency");
		
		if (!v:IsOff() and radioFrequency == frequency) then
			for k2, v2 in ipairs(_player.GetAll()) do
				if (v2:HasInitialized() and !listeners[v2] and !eavesdroppers[v2]
				and v2:GetPos():Distance(radioPosition) <= talkRadius) then
					newEavesdroppers[v2] = v2;
				end;
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
		if (v:HasInitialized() and v:HasItemByID("handheld_radio")
		and v:GetCharacterData("Frequency") == player:GetCharacterData("Frequency")) then
			if (!v:GetSharedVar("IsTied")) then
				info.listeners[v] = v;
			end;
		end;
	end;
end;

-- Called when a player attempts to use a tool.
function Schema:CanTool(player, traceLine, tool)
	if (!Clockwork.player:HasFlags(player, "w")) then
		if (string.sub(tool, 1, 5) == "wire_" or string.sub(tool, 1, 6) == "wire2_") then
			player:RunCommand("gmod_toolmode \"\"");
			return false;
		end;
	end;
	
	if (IsValid(traceLine.Entity) and tool:lower() == "duplicator") then
		local generator = Clockwork.generator:FindByID(
			traceLine.Entity:GetClass()
		);
		
		if (generator) then
			player:Ban(0, "Duplicating a Cash Printer");
			return false;
		end;
	end;
end;

-- Called when a player's character data should be saved.
function Schema:PlayerSaveCharacterData(player, data)
	if (data["SafeboxItems"]) then
		data["SafeboxItems"] = Clockwork.inventory:ToSaveable(data["SafeboxItems"]);
	end;
end;

-- Called when a player's character data should be restored.
function Schema:PlayerRestoreCharacterData(player, data)
	if (!data["Notepad"]) then data["Notepad"] = ""; end;
	if (!data["Stamina"]) then data["Stamina"] = 100; end;
	if (!data["GroupInfo"]) then data["GroupInfo"] = {}; end;
	
	if (data["GroupInfo"].isOwner) then
		data["GroupInfo"].rank = RANK_MAJ;
		data["GroupInfo"].isOwner = nil;
	end;
	
	if (data["GroupInfo"].isLeader) then
		data["GroupInfo"].isLeader = nil;
	end;
	
	if (!data["NeedsInfo"]) then
		data["NeedsInfo"] = {
			isHungry = os.time() + 3600,
			isThirsty = os.time() + 3000
		};
	end;
	
	data["SafeboxItems"] = Clockwork.inventory:ToLoadable(data["SafeboxItems"] or {});
	data["SafeboxCash"] = data["SafeboxCash"] or 0;
	
	player:SetSharedVar("Thirsty", self:IsPlayerThirsty(player));
	player:SetSharedVar("Hungry", self:IsPlayerHungry(player));
end;

-- Called when a player has been bIsHealed.
function Schema:PlayerHealed(player, healer, itemTable)
	if (itemTable("uniqueID") == "health_vial") then
		healer:ProgressAttribute(ATB_DEXTERITY, 15, true);
	elseif (itemTable("uniqueID") == "health_kit") then
		healer:ProgressAttribute(ATB_DEXTERITY, 25, true);
	elseif (itemTable("uniqueID") == "bandage") then
		healer:ProgressAttribute(ATB_DEXTERITY, 5, true);
	end;
end;

-- Called when a player's shared variables should be set.
function Schema:PlayerSetSharedVars(player, curTime)
	local myGroupInfo = player:GetCharacterData("GroupInfo");
	local bWasThirsty = player:GetSharedVar("Thirsty");
	local bWasHungry = player:GetSharedVar("Hungry");
	
	player:SetSharedVar("Rank", myGroupInfo.rank);
	player:SetSharedVar("Group", myGroupInfo.name);
	player:SetSharedVar("Hungry", self:IsPlayerHungry(player));
	player:SetSharedVar("Thirsty", self:IsPlayerThirsty(player));
	player:SetSharedVar("Stamina", player:GetCharacterData("Stamina"));
	player:SetSharedVar("NextQuit", player.cwNextCanDisconnect or 0);
	
	if (self:IsInSafeZone(player)) then
		player:SetSharedVar("SafeZone", self:GetSafeZone(player));
	else
		player:SetSharedVar("SafeZone", NULL);
	end;
	
	if (!bWasHungry and player:GetSharedVar("Hungry")) then
		Clockwork.hint:Send(
			player, "You are now hungry. Your health will not regenerate until you eat!", 60,
			Clockwork.option:GetColor("negative_hint"), "hl1/fvox/beep.wav"
		);
	end;
	
	if (!bWasThirsty and player:GetSharedVar("Thirsty")) then
		Clockwork.hint:Send(
			player, "You are now thirsty. Your stamina will not regenerate until you drink!", 60,
			Clockwork.option:GetColor("negative_hint"), "hl1/fvox/beep.wav"
		);
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
	if (player:Alive() and !player:IsRagdolled() and player:IsInWorld()) then
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
	
	if (player:InVehicle()) then
		local vehicleEntity = player:GetVehicle();
		local parentVehicle = vehicleEntity:GetParent();

		if (IsValid(parentVehicle) and parentVehicle != vehicleEntity) then
			if (!IsValid(parentVehicle:GetDriver())) then
				player:ExitVehicle();
			end;
		end;
	end;
	
	local regeneration = 0;
	local aimVector = tostring(player:GetAimVector());
	local velocity = player:GetVelocity():Length();
	local stamMod = Clockwork.attributes:Fraction(player, ATB_STAMINA, 0.5, 0.5);
	
	if (!player.cwNextKickTime or (player.cwLastAimVec != aimVector and velocity < 1)) then
		player.cwNextKickTime = curTime + 1800;
		player.cwLastAimVec = aimVector;
	end;
	
	if (curTime >= player.cwNextKickTime) then
		player:Kick("Kicked for being AFK");
	end;
	
	infoTable.inventoryWeight = infoTable.inventoryWeight + Clockwork.attributes:Fraction(player, ATB_STRENGTH, 8, 4);
	infoTable.jumpPower = infoTable.jumpPower + Clockwork.attributes:Fraction(player, ATB_ACROBATICS, 175, 50);
	infoTable.runSpeed = infoTable.runSpeed + Clockwork.attributes:Fraction(player, ATB_STAMINA, 50, 25);
	
	if (!player:IsRunning()) then
		if (player:GetVelocity():Length() == 0) then
			if (player:Crouching()) then
				regeneration = 0.2;
			else
				regeneration = 0.1;
			end;
		else
			regeneration = 0.05;
		end;
	else
		player:SetCharacterData(
			"Stamina", math.Clamp(player:GetCharacterData("Stamina") - (1 - stamMod), 0, 100)
		);
	end;
	
	if (regeneration > 0 and !self:IsPlayerThirsty(player)) then
		player:SetCharacterData("Stamina", math.Clamp(player:GetCharacterData("Stamina") + regeneration + stamMod, 0, 100));
	end;
	
	local newRunSpeed = infoTable.runSpeed * 2;
	local diffRunSpeed = newRunSpeed - infoTable.walkSpeed;
		infoTable.runSpeed = newRunSpeed - (diffRunSpeed - ((diffRunSpeed / 100) * player:GetCharacterData("Stamina")));
	self:HandlePlayerDevices(player);
	
	local weaponItem = Clockwork.item:GetByWeapon(player:GetActiveWeapon());
	
	if (player:FlashlightIsOn() and (!weaponItem or !weaponItem("hasFlashlight"))) then
		player:Flashlight(false);
	end;
end;

-- Called to get whether a player's health should regenerate.
function Schema:PlayerShouldHealthRegenerate(player)
	if (self:IsPlayerHungry(player)) then
		return false;
	end;
end;

-- Called when a player uses an item.
function Schema:PlayerUseItem(player, itemTable)
	if (itemTable("category") == "Consumables"
	or itemTable("category") == "Alcohol") then
		player:SetCharacterData("Stamina", 100);
		
		if (itemTable("useText") == "Eat") then
			Clockwork.hint:Send(
				player, "You are no longer hungry. Your health will regenerate now.", 10,
				Clockwork.option:GetColor("positive_hint"), "hl1/fvox/beep.wav"
			);
			
			self:RestoreHunger(player);
		else
			Clockwork.hint:Send(
				player, "You are no longer thirsty. Your stamina will regenerate now.", 10,
				Clockwork.option:GetColor("positive_hint"), "hl1/fvox/beep.wav"
			);
			
			self:RestoreThirst(player);
		end;
	end;
end;

-- Called when attempts to use a command.
function Schema:PlayerCanUseCommand(player, commandTable, arguments)
	if (player:GetSharedVar("IsTied")) then
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

-- Called when a player attempts to use an entity.
function Schema:PlayerUse(player, entity)
	if (entity.cwIsBustedDown) then return false; end;
	
	if (entity:IsVehicle()) then
		if (player:InVehicle()) then
			if (!player.cwNextExitVehicle or player.cwNextExitVehicle < CurTime()) then
				local parentVehicle = player:GetVehicle():GetParent();

				if (IsValid(parentVehicle) and parentVehicle.cwItemTable) then
					return false;
				else
					return;
				end;
			else
				return false;
			end;
		end;

		if (!entity.cwIsLocked and entity.cwItemTable and player:KeyDown(IN_USE)) then
			local position = player:GetEyeTraceNoCursor().HitPos;
			local validSeat = nil;
			
			if (entity.cwPassengers and IsValid(entity:GetDriver())) then
				for k, v in pairs(entity.cwPassengers) do
					if (IsValid(v) and v:IsVehicle() and !IsValid(v:GetDriver())) then
						local distance = v:GetPos():Distance(position);
						
						if (!validSeat or distance < validSeat[1]) then
							validSeat = {distance, v};
						end;
					end;
				end;
				
				if (validSeat and IsValid(validSeat[2])) then
					player.cwNextExitVehicle = CurTime() + 2;

					validSeat[2]:Fire("unlock", "", 0);
						timer.Simple(FrameTime() * 0.5, function()
							if (IsValid(player) and IsValid(validSeat[2])) then
								player:EnterVehicle(validSeat[2]);
							end;
						end);
					validSeat[2]:Fire("lock", "", 1);
				end;

				return false;
			end;
		end;
	end;
	
	if (player:GetSharedVar("IsTied")) then
		if (entity:IsVehicle() and Clockwork.entity:IsChairEntity(entity)
		or Clockwork.entity:IsPodEntity(entity)) then
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
function Schema:PlayerCanDestroyItem(player, itemTable, bNoMsg)
	if (player:GetSharedVar("IsTied")) then
		if (!bNoMsg) then
			Clockwork.player:Notify(player, "You cannot destroy items when you are tied!");
		end;
		return false;
	end;
end;

-- Called when a player attempts to drop an item.
function Schema:PlayerCanDropItem(player, itemTable, bNoMsg)
	if (player:GetSharedVar("IsTied")) then
		if (!bNoMsg) then
			Clockwork.player:Notify(player, "You cannot drop items when you are tied!");
		end;
		return false;
	end;
end;

-- Called when a player attempts to use an item.
function Schema:PlayerCanUseItem(player, itemTable, bNoMsg)
	if (player:GetSharedVar("IsTied")) then
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
	if (!Clockwork.player:IsAdmin(player)) then
		Clockwork.player:Notify(player, "Out-of-character discussion is disabled.");
		return false;
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
	if (IsValid(info.speaker) and info.speaker:HasInitialized()
	and info.class == "ic") then
		for k, v in ipairs(ents.FindByClass("cw_broadcaster")) do
			if (!v:IsOff() and info.speaker:GetPos():Distance(v:GetPos()) <= 64) then
				for k2, v2 in ipairs(_player.GetAll()) do
					info.listeners[k2] = v2;
				end;
				
				info.data.entity = v;
				info.class = "broadcast";
				break;
			end;
		end;
	end;
end;

-- Called when a player destroys generator.
function Schema:PlayerDestroyGenerator(player, entity, generator)
	Clockwork.player:GiveCash(player, generator.cash / 2, "destroying a "..string.lower(generator.name));
end;

-- Called when a player dies.
function Schema:PlayerDeath(player, inflictor, attacker, damageInfo)
	if (attacker:IsPlayer()) then
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
		local bMiscellaneousDamage = damageInfo:IsBulletDamage() or damageInfo:IsFallDamage() or damageInfo:IsExplosionDamage();
		local bMeleeDamage = damageInfo:IsDamageType(DMG_CLUB) or damageInfo:IsDamageType(DMG_SLASH);
		
		if (bMiscellaneousDamage or bMeleeDamage) then
			self:PlayerDropRandomItems(player, player:GetRagdollEntity());
		end;
	end;
end;

-- Called just before a player dies.
function Schema:DoPlayerDeath(player, attacker, damageInfo)
	self:TiePlayer(player, false, true);
	player.cwIsBeingSearched = nil;
	player.cwIsSearchingChar = nil;
end;

-- Called when a player's storage should close.
function Schema:PlayerStorageShouldClose(player, storage)
	local entity = player:GetStorageEntity();
	
	if (player.cwIsSearchingChar and entity:IsPlayer()
	and !entity:GetSharedVar("IsTied")) then
		return true;
	end;
end;

-- Called just after a player spawns.
function Schema:PostPlayerSpawn(player, lightSpawn, changeClass, firstSpawn)
	local team = player:Team();
	
	if (!lightSpawn) then
		player:SetCharacterData("Stamina", 100);
		
		umsg.Start("cwClearEffects", player);
		umsg.End();
		
		player.cwIsBeingSearched = nil;
		player.cwIsSearchingChar = nil;
	end;
	
	if (player:GetSharedVar("IsTied")) then
		self:TiePlayer(player, true);
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
	
	if (!player:Crouching()) then player:EmitSound(sound); end;
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
	local curTime = CurTime();
	
	if (Clockwork.entity:IsDoor(entity)) then
		Clockwork.entity:SetDoorSpeedFast(entity);
		Clockwork.entity:OpenDoor(entity, 0, true, true);
		self:PlayerUseDoor(player, entity);
	end;
	
	if (entity.cwInventory and entity.cwPassword) then
		entity.cwIsBreached = true;
		Clockwork:CreateTimer("ResetBreach"..entity:EntIndex(), 120, 1, function()
			if (IsValid(entity)) then entity.cwIsBreached = nil; end;
		end);
	end;
	
	for k, v in ipairs(ents.FindByClass("cw_door_guarder")) do
		if (entity:GetPos():Distance(v:GetPos()) < 256) then
			local owner = Clockwork.entity:GetOwner(v);
			
			if (IsValid(owner) and (!owner.cwNextDoorAlert
			or curTime >= owner.cwNextDoorAlert)) then
				Clockwork.chatBox:Add(owner, nil, "alert",
					"Your door guarder has detected that a door is under attack!"
				);
				owner.cwNextDoorAlert = curTime + 60;
			end;
		end;
	end;
end;

-- Called when a player takes damage.
function Schema:PlayerTakeDamage(player, inflictor, attacker, hitGroup, damageInfo)
	local curTime = CurTime();
	
	if (damageInfo:IsBulletDamage()) then
		if (player:Armor() > 0) then
			umsg.Start("cwShotEffect", player);
				umsg.Float(0.25);
			umsg.End();
		else
			umsg.Start("cwShotEffect", player);
				umsg.Float(0.5);
			umsg.End();
		end;
	end;
	
	if (player:Health() <= 10 and math.random() <= 0.75) then
		if (Clockwork.player:GetAction(player) != "die") then
			Clockwork.player:SetRagdollState(player, RAGDOLL_FALLENOVER, nil, nil, Clockwork:ConvertForce(damageInfo:GetDamageForce() * 32));
			Clockwork.player:SetAction(player, "die", 60, 1, function()
				if (IsValid(player) and player:Alive()) then
					player:TakeDamage(player:Health() * 2, attacker, inflictor);
				end;
			end);
			
			player.cwNextCanDisconnect = curTime + 90;
		end;
	end;
	
	if (attacker:IsPlayer()) then
		umsg.Start("cwTakeDmg", player);
			umsg.Entity(attacker);
			umsg.Short(damageInfo:GetDamage());
		umsg.End();
		
		umsg.Start("cwDealDmg", attacker);
			umsg.Entity(player);
			umsg.Short(damageInfo:GetDamage());
		umsg.End();
		
		attacker.cwNextCanDisconnect = curTime + 90;
		
		if (damageInfo:IsBulletDamage()
		and !player.cwHandledBullet) then
			local itemsList = attacker:GetItemsByID("custom_ammo");
			local itemTable = nil;
			
			if (itemsList) then
				for k, v in pairs(itemsList) do
					if (v:GetData("IsEquipped")) then
						itemTable = v;
						break;
					end;
				end;
				
				if (itemTable) then
					itemTable:FireRound(player, attacker);
				end;
			end;
		end;
	end;
	
	if (!player.cwNextCanDisconnect or curTime > player.cwNextCanDisconnect + 60) then
		player.cwNextCanDisconnect = curTime + 60;
	end;
	
	local clothesItem = player:GetClothesItem();
	
	if (clothesItem) then
		clothesItem:SetData(
			"Durability", math.Clamp(
				clothesItem:GetData("Durability") - (damageInfo:GetDamage() / 100), 0, 100
			)
		);
	end;
	
	local itemsList = player:GetItemsByID("kevlar_vest");
	local armor = player:Armor();
	
	if (itemsList) then
		for k, v in pairs(itemsList) do
			if (v:GetData("IsEquipped")) then
				v:SetData("Armor", armor);
				break;
			end;
		end;
	end;
end;

-- Called when a player's limb damage is bIsHealed.
function Schema:PlayerLimbDamageHealed(player, hitGroup, amount)
	if (hitGroup == HITGROUP_HEAD) then
		player:BoostAttribute("Limb Damage", ATB_DEXTERITY, false);
	elseif (hitGroup == HITGROUP_CHEST or hitGroup == HITGROUP_STOMACH) then
		player:BoostAttribute("Limb Damage", ATB_ENDURANCE, false);
	elseif (hitGroup == HITGROUP_LEFTLEG or hitGroup == HITGROUP_RIGHTLEG) then
		player:BoostAttribute("Limb Damage", ATB_ACROBATICS, false);
		player:BoostAttribute("Limb Damage", ATB_STAMINA, false);
	elseif (hitGroup == HITGROUP_LEFTARM or hitGroup == HITGROUP_RIGHTARM) then
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
		player:BoostAttribute("Limb Damage", ATB_DEXTERITY, -limbDamage);
	elseif (hitGroup == HITGROUP_CHEST or hitGroup == HITGROUP_STOMACH) then
		player:BoostAttribute("Limb Damage", ATB_ENDURANCE, -limbDamage);
	elseif (hitGroup == HITGROUP_LEFTLEG or hitGroup == HITGROUP_RIGHTLEG) then
		player:BoostAttribute("Limb Damage", ATB_ACROBATICS, -limbDamage);
		player:BoostAttribute("Limb Damage", ATB_STAMINA, -limbDamage);
	elseif (hitGroup == HITGROUP_LEFTARM or hitGroup == HITGROUP_RIGHTARM) then
		player:BoostAttribute("Limb Damage", ATB_STRENGTH, -limbDamage);
	end;
end;

-- A function to scale damage by hit group.
function Schema:PlayerScaleDamageByHitGroup(player, attacker, hitGroup, damageInfo, baseDamage)
	local clothesItem = player:GetClothesItem();
	local endurance = Clockwork.attributes:Fraction(player, ATB_ENDURANCE, 0.4, 0.4);
	local curTime = CurTime();
	
	if (attacker:GetClass() == "entityflame") then
		if (!player.cwNextTakeBurnDmg or curTime >= player.cwNextTakeBurnDmg) then
			player.cwNextTakeBurnDmg = curTime + 0.5;
			damageInfo:SetDamage(1);
		else
			damageInfo:SetDamage(0);
		end;
	end;
	
	if (!damageInfo:IsFallDamage()) then
		damageInfo:ScaleDamage(1.25 - endurance);
	end;
	
	if (clothesItem and clothesItem:IsBasedFrom("custom_clothes")) then
		local armorScale = (clothesItem("armorScale") / 100) * clothesItem:GetData("Durability");
		damageInfo:ScaleDamage(math.max(1 - (armorScale * 0.75), 0.1));
	end;
	
	if (player:InVehicle()) then
		local damagePosition = damageInfo:GetDamagePosition();
		local vehicleEntity = player:GetVehicle();
		
		if (!vehicleEntity.cwItemTable) then
			return;
		end;
		
		if (player:GetPos():Distance(damagePosition) > 96
		and !damageInfo:IsExplosionDamage()) then
			damageInfo:SetDamage(0);
		end;

		if (vehicleEntity.cwIsLocked) then
			vehicleEntity.cwIsLocked = false;
			vehicleEntity:EmitSound("doors/door_latch3.wav");
			vehicleEntity:Fire("unlock", "", 0);
		end;
		
		if (!vehicleEntity.cwPassengers) then
			return;
		end;
		
		local function DamagePassengers()
			for k, v in pairs(vehicleEntity.cwPassengers) do
				if (IsValid(v) and IsValid(v:GetDriver())
				and v:GetDriver() != player) then
					if (v:GetDriver():GetPos():Distance(damagePosition) <= 96
					or damageInfo:IsExplosionDamage()) then
						damageInfo:SetDamage(baseDamage);
						v:GetDriver():TakeDamageInfo(damageInfo);
					end;
				end;
			end;
		end;
		
		timer.Simple(FrameTime() * 0.5, function()
			if (IsValid(vehicleEntity) and IsValid(player)) then
				DamagePassengers();
			end;
		end);
	elseif ((attacker:IsPlayer() and attacker:InVehicle()) or attacker:IsVehicle()) then
		if (baseDamage >= 50) then
			Clockwork.player:SetRagdollState(player, RAGDOLL_KNOCKEDOUT, 20);
			damageInfo:ScaleDamage(0.3);
		end;
	end;
end;

-- Called when an entity takes damage.
function Schema:EntityTakeDamage(entity, inflictor, attacker, amount, damageInfo)
	local curTime = CurTime();
	local player = Clockwork.entity:GetPlayer(entity);
	
	if (player and (!player.cwNextEnduranceTime or CurTime() > player.cwNextEnduranceTime)) then
		player:ProgressAttribute(ATB_ENDURANCE, math.Clamp(damageInfo:GetDamage(), 0, 75) / 4, true);
		player.cwNextEnduranceTime = CurTime() + 2;
	end;
	
	if (attacker:IsPlayer()) then
		local weaponItemTable = Clockwork.item:GetByWeapon(
			attacker:GetActiveWeapon()
		);
		
		if (!damageInfo:IsBulletDamage() and weaponItemTable
		and weaponItemTable:IsBasedFrom("custom_weapon")) then
			weaponItemTable:SetData(
				"Durability", math.Clamp(
					weaponItemTable:GetData("Durability") - (amount / 40), 0, 100
				)
			);
		end;
		
		local weaponItemTable = Clockwork.item:GetByWeapon(attacker:GetActiveWeapon());
		
		if (weaponItemTable and weaponItemTable:IsBasedFrom("custom_weapon")) then
			local damageScale = ((weaponItemTable("damageScale") / 100) / 100) * weaponItemTable:GetData("Durability");
			damageInfo:ScaleDamage(math.max(damageScale, 0.2));
		end;
		
		if (entity:GetClass() == "prop_physics" and !entity.cwIsInvincibile
		and !entity.PhysgunDisabled) then
			local bPropGuarder = false;
			
			for k, v in ipairs(ents.FindByClass("cw_prop_guarder")) do
				if (entity:GetPos():Distance(v:GetPos()) < 512) then
					local owner = Clockwork.entity:GetOwner(v);
					
					if (IsValid(owner) and (!owner.cwNextPropAlert
					or curTime >= owner.cwNextPropAlert)) then
						Clockwork.chatBox:Add(owner, nil, "alert",
							"Your prop guarder has detected that a prop is under attack!"
						);
						owner.cwNextPropAlert = curTime + 60;
					end;
					
					bPropGuarder = true;
				end;
			end;
			
			if (!bPropGuarder) then
				damageInfo:ScaleDamage(2);
			end;
			
			if (!entity.cwIsDestroyed) then
				local boundingRadius = entity:BoundingRadius() * 8;
				entity.cwEntHealth = entity.cwEntHealth or boundingRadius;
				entity.cwEntHealth = math.max(entity.cwEntHealth - damageInfo:GetDamage(), 0);
				
				local blackness = (255 / boundingRadius) * entity.cwEntHealth;
				entity:SetColor(blackness, blackness, blackness, 255);
				
				if (entity.cwEntHealth == 0) then
					for k, v in ipairs(_player.GetAll()) do
						if (v:HasInitialized()
						and v:GetPos():Distance(entity:GetPos()) < 512) then
							v.cwNextCanSpawnProp = curTime + 30;
						end;
					end;
					
					Clockwork.entity:Decay(entity, 5);
					entity:SetCollisionGroup(COLLISION_GROUP_WEAPON);
					entity.cwIsDestroyed = true;
					entity:Ignite(5, 0);
				end;
			end;
		elseif (entity:IsNPC()) then
			damageInfo:ScaleDamage(2);
		elseif (!damageInfo:IsDamageType(DMG_CLUB)
		and !damageInfo:IsDamageType(DMG_SLASH)) then
			damageInfo:ScaleDamage(0.3);
		else
			damageInfo:ScaleDamage(0.7);
		end;
		
		local bDoorGuarder = false;
		
		for k, v in ipairs(ents.FindByClass("cw_door_guarder")) do
			if (entity:GetPos():Distance(v:GetPos()) < 96) then
				local owner = Clockwork.entity:GetOwner(v);
				
				if (IsValid(owner) and (!owner.cwNextDoorAlert
				or curTime >= owner.cwNextDoorAlert)) then
					Clockwork.chatBox:Add(owner, nil, "alert",
						"Your door guarder has detected that a door is under attack!"
					);
					owner.cwNextDoorAlert = curTime + 60;
				end;
				
				bDoorGuarder = true;
			end;
		end;
		
		if (damageInfo:IsBulletDamage() and !IsValid(entity.cwBreachEnt)) then
			if (string.lower(entity:GetClass()) == "prop_door_rotating") then
				if (!Clockwork.entity:IsDoorFalse(entity) and !bDoorGuarder) then
					local damagePosition = damageInfo:GetDamagePosition();
					
					if (entity:WorldToLocal(damagePosition):Distance(Vector(-1.0313, 41.8047, -8.1611)) <= 8) then
						local effectData = EffectData();
							effectData:SetStart(damagePosition);
							effectData:SetOrigin(damagePosition);
							effectData:SetScale(8);
						util.Effect("GlassImpact", effectData, true, true);
						
						Clockwork.entity:SetDoorSpeedFast(entity);
						Clockwork.entity:OpenDoor(entity, 0, true, true, attacker:GetPos());
					end;
				end;
			end;
		end;
	end;
end;

--[[
	Define all vehicle-related hooks here to keep it organized, we could use
	a seperate file, but meh.
--]]

-- Called when a player's character has loaded.
function Schema:PlayerCharacterLoaded(player)
	local myGroupInfo = player:GetCharacterData("GroupInfo");
	
	if (myGroupInfo and myGroupInfo.name) then
		tmysql.query("SELECT _Notes FROM test_groups WHERE _Name = \""..tmysql.escape(myGroupInfo.name).."\"", function(result)
			if (result and type(result) == "table" and #result > 0) then
				Clockwork:StartDataStream(player, "GroupNotes", result[1]._Notes);
			end;
		end, 1);
	end;
	
	player.cwVehicleList = {};
end;

-- Called when a player attempts to pickup an entity with the physics gun.
function Schema:PhysgunPickup(player, entity)
	if (entity:IsVehicle() and entity.cwItemTable
	and !player:IsUserGroup("operator") and !player:IsAdmin()) then
		return false;
	end;
end;

-- Called when a player's saved inventory should be added to.
function Schema:PlayerAddToSavedInventory(player, character, Callback)
	if (!player.cwVehicleList) then return; end;
	
	for k, v in pairs(player.cwVehicleList) do
		Callback(v);
	end;
end;

-- Called when a player attempts to lock an entity.
function Schema:PlayerCanLockEntity(player, entity)
	if (entity:IsVehicle() and entity.cwItemTable) then
		return (Clockwork.entity:GetOwner(entity) == player);
	end;
end;

-- Called when a player attempts to unlock an entity.
function Schema:PlayerCanUnlockEntity(player, entity)
	if (entity:IsVehicle() and entity.cwItemTable) then
		return (Clockwork.entity:GetOwner(entity) == player);
	end;
end;

-- Called when a player's unlock info is needed.
function Schema:PlayerGetUnlockInfo(player, entity)
	if (entity:IsVehicle() and entity.cwItemTable) then
		return {
			duration = Clockwork.config:Get("unlock_time"):Get(),
			Callback = function(player, entity)
				entity.cwIsLocked = false;
				entity:Fire("unlock", "", 0);
			end
		};
	end;
end;

-- Called when a player's lock info is needed.
function Schema:PlayerGetLockInfo(player, entity)
	if (entity:IsVehicle() and entity.cwItemTable) then
		return {
			duration = Clockwork.config:Get("lock_time"):Get(),
			Callback = function(player, entity)
				entity.cwIsLocked = true;
				entity:Fire("lock", "", 0);
			end
		};
	end;
end;

-- Called when a player leaves a vehicle.
function Schema:PlayerLeaveVehicle(player, vehicleEntity)
	player.cwNextEnterVehicle = CurTime() + 2;
	player:SetVelocity(Vector(0, 0, 0));

	timer.Simple(FrameTime() * 2, function()
		if (IsValid(player) and IsValid(vehicleEntity) and !player:InVehicle()) then
			self:MakeExitVehicle(player, vehicleEntity);
		end;
	end);
end;

-- Called when a player attempts to enter a vehicle.
function Schema:CanPlayerEnterVehicle(player, vehicleEntity, role)
	if (player.cwNextEnterVehicle and player.cwNextEnterVehicle >= CurTime()) then
		return false;
	end;

	if (vehicleEntity.cwIsLocked) then
		return false;
	end;
end;

-- Called when a player attempts to exit a vehicle.
function Schema:CanExitVehicle(vehicleEntity, player)
	if (player.cwNextExitVehicle and player.cwNextExitVehicle >= CurTime()) then
		return false;
	end;

	local parentVehicle = vehicleEntity:GetParent();

	if (IsValid(parentVehicle) and parentVehicle.cwItemTable) then
		return false;
	end;

	if (vehicleEntity.cwIsLocked) then
		return false;
	end;
end;

-- Called when a player presses a key.
function Schema:KeyPress(player, key)
	if (player:InVehicle() and key == IN_USE) then
		local vehicleEntity = player:GetVehicle();
		local parentVehicle = vehicleEntity:GetParent();

		if (IsValid(parentVehicle) and parentVehicle.cwItemTable) then
			if (!parentVehicle.cwIsLocked) then
				player:ExitVehicle();
			end;
		end;
	end;
end;