--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

-- Called when a player attempts to use a lowered weapon.
function Clockwork.schema:PlayerCanUseLoweredWeapon(player, weapon, secondary)
	if (secondary and (weapon.SilenceTime or weapon.PistolBurst)) then
		return true;
	end;
end;

-- Called when a player switches their flashlight on or off.
function Clockwork.schema:PlayerSwitchFlashlight(player, on)
	return false;
end;

-- Called when an item entity has taken damage.
function Clockwork.schema:ItemEntityTakeDamage(itemEntity, itemTable, damageInfo)
	if (itemTable:GetData("Rarity") == 2 or itemTable:GetData("Rarity") == 3) then
		damageInfo:ScaleDamage(0.25);
	end;
end;

-- Called when an entity fires some bullets.
function Clockwork.schema:EntityFireBullets(entity, bulletInfo)
	if (entity:IsPlayer()) then
		local weaponItemTable = Clockwork.item:GetByWeapon(entity:GetActiveWeapon());
		local reduceAmount = bulletInfo.Damage / 75;
		
		if (weaponItemTable and weaponItemTable:IsBasedFrom("custom_weapon")) then
			weaponItemTable:SetData(
				"Durability", math.Clamp(weaponItemTable:GetData("Durability") - reduceAmount, 0, 100) 
			);
		end;
	end;
	
	if (!bulletInfo.Tracer or bulletInfo.Tracer < 1) then
		return;
	end;
	
	local curTime = CurTime();
	local filter = {entity};
	
	if (entity:IsPlayer()) then
		table.insert(filter, entity:GetActiveWeapon());
	end;
	
	local traceLine = util.TraceLine({
		endpos = bulletInfo.Src + (bulletInfo.Dir * 4096),
		start = bulletInfo.Src,
		filter = filter
	});
	
	for k, v in ipairs(_player.GetAll()) do
		if (v:HasInitialized() and traceLine.Entity != v
		and v:GetShootPos():Distance(traceLine.HitPos) < 196
		or v:GetPos():Distance(traceLine.HitPos) < 256) then
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
function Clockwork.schema:ItemEntityDestroyed(itemEntity, itemTable)
	if (itemTable:GetData("Rarity") == 3) then
		Clockwork.player:PlaySound(nil, "sad_trombone.mp3");
			Clockwork.item:SendToPlayer(nil, itemTable);
		Clockwork.chatBox:Add(nil, nil, "destroyed_item", tostring(itemTable("itemID")));
	end;
end;

-- Called when a player is given an item.
function Clockwork.schema:PlayerItemGiven(player, itemTable, bForce)
	if (itemTable:GetData("Name") != "" and itemTable:GetData("Found") != nil
	and itemTable:GetData("Found") != true and (!player.cwItemCreateTime
	or CurTime() >= player.cwItemCreateTime)) then
		itemTable:SetData("Found", true);
		
		--[[ Only play the Zelda fanfare sound with legendary or unique items. --]]
		if (itemTable:GetData("Rarity") < 2) then return; end;
		
		if (!player.cwNextFoundItem or CurTime() >= player.cwNextFoundItem
		or itemTable:GetData("Rarity") == 3) then
			player.cwNextFoundItem = CurTime() + 16;
			
			if (itemTable:GetData("Rarity") == 3) then
				Clockwork.player:PlaySound(nil, "item_found.mp3");
			else
				Clockwork.player:PlaySound(nil, "buttons/button6.wav");
			end;
			
			Clockwork.item:SendToPlayer(nil, itemTable);
			Clockwork.chatBox:Add(nil, player, "found_item", tostring(itemTable("itemID")));
		end;
	end; 
end;

--[[
	This is the MySQL table query for the group system.
--]]

local GROUP_SYSTEM_TABLE_QUERY = [[
CREATE TABLE IF NOT EXISTS `test_groups` (
	`_Key` smallint(11) unsigned NOT NULL AUTO_INCREMENT,
	`_Name` varchar(150) NOT NULL,
	PRIMARY KEY (`_Key`)
)
]];

-- Called when Clockwork has initialized.
function Clockwork.schema:ClockworkInitialized()
	tmysql.query(string.gsub(GROUP_SYSTEM_TABLE_QUERY, "%s", " "));
end;

-- Called when a player's character has unloaded.
function Clockwork.schema:PlayerCharacterUnloaded(player)
	local nextCanDisconnect = 0;
	local curTime = CurTime();
	
	if (player.cwNextCanDisconnect) then
		nextCanDisconnect = player.cwNextCanDisconnect;
	end;
	
	if (player:HasInitialized()) then
		if (player:GetSharedVar("IsTied") or curTime < nextCanDisconnect) then
			self:PlayerDropRandomItems(player, nil, true);
			Clockwork.player:DropWeapons(player);
		end;
	end;
end;

-- Called each tick.
function Clockwork.schema:Tick()
	local curTime = CurTime();
	
	if (!self.nextCleanDecals or curTime >= self.nextCleanDecals) then
		self.nextCleanDecals = curTime + 60;
		
		for k, v in ipairs(_player.GetAll()) do
			v:RunCommand("r_cleardecals");
		end;
	end;
	
	if (!self.nextDoorCheck or curTime >= self.nextDoorCheck) then
		self.nextDoorCheck = curTime + 10;
		
		if (string.lower(game.GetMap()) == "rp_c18_v1") then
			for k, v in ipairs(ents.GetAll()) do
				if (IsValid(v) and Clockwork.entity:IsDoor(v)) then
					local name = string.lower(v:GetName());
					
					if (name == "nxs_brnroom" or name == "nxs_brnroom2" or name == "nxs_al_door1"
					or name == "nxs_al_door2" or name == "nxs_brnbcroom") then
						if (!v.cwNextAutoClose or curTime >= v.cwNextAutoClose) then
							v:Fire("Close", "", 10);
							v.cwNextAutoClose = curTime + 10;
						end;
					end;
				end;
			end;
		end;
	end;
end;

-- Called when a player attempts to spawn a prop.
function Clockwork.schema:PlayerSpawnProp(player, model)
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
function Clockwork.schema:PlayerGivenWeapon(player, class, itemTable)
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

-- Called when a player's drop weapon info should be adjusted.
function Clockwork.schema:PlayerAdjustDropWeaponInfo(player, info)
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
function Clockwork.schema:EntityRemoved(entity)
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
function Clockwork.schema:PlayerAdjustPropCostInfo(player, entity, info)
	local model = string.lower(entity:GetModel());
	
	if (self.containers[model]) then
		info.name = self.containers[model][2];
	end;
end;

-- Called when an entity's menu option should be handled.
function Clockwork.schema:EntityHandleMenuOption(player, entity, option, arguments)
	local mineTypes = {"cw_firemine", "cw_freezemine", "cw_explomine"};
	
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
		elseif (itemTable:IsBasedFrom("custom_storage")) then
			itemTable:SetData("Rarity", arguments.rarity);
			itemTable:SetData("Weight", arguments.weight);
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
		end;
	end;
	
	if (table.HasValue(mineTypes, entity:GetClass())) then
		if (arguments == "cwMineDefuse" and !player:GetSharedVar("IsTied")) then
			local defuseTime = Clockwork.schema:GetDexterityTime(player) * 2;
			
			Clockwork.player:SetAction(player, "defuse", defuseTime);
			
			Clockwork.player:EntityConditionTimer(player, entity, entity, defuseTime, 80, function()
				return player:Alive() and !player:IsRagdolled() and !player:GetSharedVar("IsTied");
			end, function(success)
				Clockwork.player:SetAction(player, "defuse", false);
				
				if (success) then
					entity:Defuse();
					entity:Remove();
				end;
			end);
		end;
	elseif (entity:GetClass() == "prop_ragdoll") then
		if (arguments == "cwCorpseLoot") then
			if (!entity.cwInventory) then entity.cwInventory = {}; end;
			if (!entity.cwCash) then entity.cwCash = 0; end;
			
			local entityPlayer = Clockwork.entity:GetPlayer(entity);
			
			if (!entityPlayer or !entityPlayer:Alive()) then
				player:EmitSound("physics/body/body_medium_impact_soft"..math.random(1, 7)..".wav");
				
				Clockwork.storage:Open(player, {
					name = "Corpse",
					weight = 8,
					entity = entity,
					distance = 192,
					cash = entity.cwCash,
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
			weight = 100,
			entity = entity,
			distance = 192,
			cash = entity.cwCash,
			inventory = entity.cwInventory,
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
	elseif (entity:GetClass() == "cw_breach") then
		entity:CreateDummyBreach();
		entity:BreachEntity(player);
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
function Clockwork.schema:ClockworkInitPostEntity()
	self:LoadSafeboxList();
	self:LoadRandomItems();
	self:LoadBelongings();
	self:LoadStorage();
end;

-- Called just after data should be saved.
function Clockwork.schema:PostSaveData()
	self:SaveBelongings();
end;

-- Called when data should be saved.
function Clockwork.schema:SaveData()
	self:SaveStorage();
end;

-- Called when a player attempts to spray their tag.
function Clockwork.schema:PlayerSpray(player)
	if (!player:HasItemByID("spray_can") or player:GetSharedVar("IsTied")) then
		return true;
	end;
end;

-- Called when a player presses F3.
function Clockwork.schema:ShowSpare1(player)
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
function Clockwork.schema:PlayerSpawnObject(player)
	if (player:GetSharedVar("IsTied")) then
		Clockwork.player:Notify(player, "You cannot do this action at the moment!");
		return false;
	end;
end;

-- Called when an entity attempts to be auto-removed.
function Clockwork.schema:EntityCanAutoRemove(entity)
	if (self.storage[entity] or entity:GetNetworkedString("Name") != "") then
		return false;
	end;
end;

-- Called when a player attempts to breach an entity.
function Clockwork.schema:PlayerCanBreachEntity(player, entity)
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
function Clockwork.schema:PlayerCanRadio(player, text, listeners, eavesdroppers)
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
function Clockwork.schema:PlayerCanUseEntityInVehicle(player, entity, vehicle)
	if (entity:IsPlayer() or Clockwork.entity:IsPlayerRagdoll(entity)) then
		return true;
	end;
end;

-- Called when a player attempts to use a door.
function Clockwork.schema:PlayerCanUseDoor(player, door)
	if (player:GetSharedVar("IsTied")) then
		return false;
	end;
end;

-- Called when a player uses a door.
function Clockwork.schema:PlayerUseDoor(player, door)
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

-- Called when a player's radio info should be adjusted.
function Clockwork.schema:PlayerAdjustRadioInfo(player, info)
	for k, v in ipairs(_player.GetAll()) do
		if (v:HasInitialized() and v:HasItemByID("handheld_radio")) then
			if (v:GetCharacterData("Frequency") == player:GetCharacterData("Frequency")) then
				if (!v:GetSharedVar("IsTied")) then
					info.listeners[v] = v;
				end;
			end;
		end;
	end;
end;

-- Called when a player attempts to use a tool.
function Clockwork.schema:CanTool(player, traceLine, tool)
	if (!Clockwork.player:HasFlags(player, "w")) then
		if (string.sub(tool, 1, 5) == "wire_" or string.sub(tool, 1, 6) == "wire2_") then
			player:RunCommand("gmod_toolmode \"\"");
			return false;
		end;
	end;
end;

-- Called when a player's character data should be saved.
function Clockwork.schema:PlayerSaveCharacterData(player, data)
	if (data["SafeboxItems"]) then
		data["SafeboxItems"] = Clockwork.inventory:ToSaveable(data["SafeboxItems"]);
	end;
end;

-- Called when a player's character data should be restored.
function Clockwork.schema:PlayerRestoreCharacterData(player, data)
	if (!data["Notepad"]) then data["Notepad"] = ""; end;
	if (!data["Stamina"]) then data["Stamina"] = 100; end;
	if (!data["GroupInfo"]) then data["GroupInfo"] = {}; end;
	
	data["SafeboxItems"] = Clockwork.inventory:ToLoadable(data["SafeboxItems"] or {});
	data["SafeboxCash"] = data["SafeboxCash"] or 0;
end;

-- Called when a player has been bIsHealed.
function Clockwork.schema:PlayerHealed(player, healer, itemTable)
	if (itemTable("uniqueID") == "health_vial") then
		healer:ProgressAttribute(ATB_DEXTERITY, 15, true);
	elseif (itemTable("uniqueID") == "health_kit") then
		healer:ProgressAttribute(ATB_DEXTERITY, 25, true);
	elseif (itemTable("uniqueID") == "bandage") then
		healer:ProgressAttribute(ATB_DEXTERITY, 5, true);
	end;
end;

-- Called when a player's shared variables should be set.
function Clockwork.schema:PlayerSetSharedVars(player, curTime)
	player:SetSharedVar("Group", player:GetCharacterData("GroupInfo").name);
	player:SetSharedVar("Stamina", player:GetCharacterData("Stamina"));
	player:SetSharedVar("NextQuit", player.cwNextCanDisconnect or 0);
end;

-- Called when a player has been unragdolled.
function Clockwork.schema:PlayerUnragdolled(player, state, ragdoll)
	Clockwork.player:SetAction(player, "die", false);
end;

-- Called when a player has been ragdolled.
function Clockwork.schema:PlayerRagdolled(player, state, ragdoll)
	Clockwork.player:SetAction(player, "die", false);
end;

-- Called at an interval while a player is connected.
function Clockwork.schema:PlayerThink(player, curTime, infoTable)
	if (player:Alive() and !player:IsRagdolled()) then
		if (!player:InVehicle() and player:GetMoveType() == MOVETYPE_WALK) then
			if (player:IsInWorld()) then
				if (!player:IsOnGround() and player:GetGroundEntity() != GetWorldEntity()) then
					player:ProgressAttribute(ATB_ACROBATICS, 0.25, true);
				elseif (infoTable.isRunning) then
					player:ProgressAttribute(ATB_AGILITY, 0.125, true);
				elseif (infoTable.isJogging) then
					player:ProgressAttribute(ATB_AGILITY, 0.0625, true);
				end;
			end;
		end;
	end;
	
	local regeneration = 0;
	local acrobatics = Clockwork.attributes:Fraction(player, ATB_ACROBATICS, 175, 50);
	local aimVector = tostring(player:GetAimVector());
	local strength = Clockwork.attributes:Fraction(player, ATB_STRENGTH, 8, 4);
	local agility = Clockwork.attributes:Fraction(player, ATB_AGILITY, 50, 25);
	local velocity = player:GetVelocity():Length();
	local armor = player:Armor();
	
	if (!player.cwNextKickTime or (player.cwLastAimVec != aimVector and velocity < 1)) then
		player.cwNextKickTime = curTime + 1800;
		player.cwLastAimVec = aimVector;
	end;
	
	if (curTime >= player.cwNextKickTime) then
		player:Kick("Kicked for being AFK");
	end;
	
	infoTable.inventoryWeight = infoTable.inventoryWeight + strength;
	infoTable.jumpPower = infoTable.jumpPower + acrobatics;
	infoTable.runSpeed = infoTable.runSpeed + agility;
	
	local mediumKevlar = Clockwork.item:FindByID("medium_kevlar");
	local heavyKevlar = Clockwork.item:FindByID("heavy_kevlar");
	local lightKevlar = Clockwork.item:FindByID("kevlar_vest");
	local playerGear = Clockwork.player:GetGear(player, "KevlarVest");
	
	if (armor > 100) then
		if (!playerGear or playerGear:GetItemTable()("uniqueID") != "heavy_kevlar") then
			Clockwork.player:CreateGear(player, "KevlarVest", heavyKevlar);
		end;
	elseif (armor > 50) then
		if (!playerGear or playerGear:GetItemTable()("uniqueID") != "medium_kevlar") then
			Clockwork.player:CreateGear(player, "KevlarVest", mediumKevlar);
		end;
	elseif (armor > 0) then
		if (!playerGear or playerGear:GetItemTable()("uniqueID")!= "kevlar_vest") then
			Clockwork.player:CreateGear(player, "KevlarVest", lightKevlar);
		end;
	end;
	
	if (!player:IsRunning()) then
		if (player:GetVelocity():Length() == 0) then
			if (player:Crouching()) then
				regeneration = 1;
			else
				regeneration = 0.5;
			end;
		else
			regeneration = 0.25;
		end;
	else
		player:ProgressAttribute(ATB_STAMINA, 0.125, true);
		player:SetCharacterData(
			"Stamina", math.Clamp(player:GetCharacterData("Stamina") - 1, 0, 100)
		);
	end;
	
	if (regeneration > 0) then
		player:SetCharacterData("Stamina", math.Clamp(player:GetCharacterData("Stamina") + regeneration, 0, 100));
	end;
	
	local newRunSpeed = infoTable.runSpeed * 2;
	local diffRunSpeed = newRunSpeed - infoTable.walkSpeed;
		infoTable.runSpeed = newRunSpeed - (diffRunSpeed - ((diffRunSpeed / 100) * player:GetCharacterData("Stamina")));
	self:HandlePlayerDevices(player);
end;

-- Called when a player uses an item.
function Clockwork.schema:PlayerUseItem(player, itemTable)
	if (itemTable("category") == "Consumables"
	or itemTable("category") == "Alcohol") then
		player:SetCharacterData("Stamina", 100);
	end;
end;

-- Called when attempts to use a command.
function Clockwork.schema:PlayerCanUseCommand(player, commandTable, arguments)
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
function Clockwork.schema:PlayerUse(player, entity)
	local curTime = CurTime();
	
	if (entity.cwIsBustedDown) then
		return false;
	end;
	
	if (player:GetSharedVar("IsTied")) then
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
function Clockwork.schema:PlayerCanDestroyItem(player, itemTable, bNoMsg)
	if (player:GetSharedVar("IsTied")) then
		if (!bNoMsg) then
			Clockwork.player:Notify(player, "You cannot destroy items when you are tied!");
		end;
		return false;
	end;
end;

-- Called when a player attempts to drop an item.
function Clockwork.schema:PlayerCanDropItem(player, itemTable, bNoMsg)
	if (player:GetSharedVar("IsTied")) then
		if (!bNoMsg) then
			Clockwork.player:Notify(player, "You cannot drop items when you are tied!");
		end;
		return false;
	end;
end;

-- Called when a player attempts to use an item.
function Clockwork.schema:PlayerCanUseItem(player, itemTable, bNoMsg)
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
function Clockwork.schema:PlayerCanSayOOC(player, text)
	if (!Clockwork.player:IsAdmin(player)) then
		Clockwork.player:Notify(player, "Out-of-character discussion is disabled.");
		return false;
	end;
end;

-- Called when a player attempts to say something locally out-of-character.
function Clockwork.schema:PlayerCanSayLOOC(player, text)
	if (!player:Alive()) then
		Clockwork.player:Notify(player, "You cannot do this action at the moment!");
	end;
end;

-- Called when chat box info should be adjusted.
function Clockwork.schema:ChatBoxAdjustInfo(info)
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
function Clockwork.schema:PlayerDestroyGenerator(player, entity, generator)
	Clockwork.player:GiveCash(player, generator.cash / 2, "destroying a "..string.lower(generator.name));
end;

-- Called when a player dies.
function Clockwork.schema:PlayerDeath(player, inflictor, attacker, damageInfo)
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
function Clockwork.schema:DoPlayerDeath(player, attacker, damageInfo)
	self:TiePlayer(player, false, true);
	player.cwIsBeingSearched = nil;
	player.cwIsSearchingChar = nil;
end;

-- Called when a player's storage should close.
function Clockwork.schema:PlayerStorageShouldClose(player, storage)
	local entity = player:GetStorageEntity();
	
	if (player.cwIsSearchingChar and entity:IsPlayer()
	and !entity:GetSharedVar("IsTied")) then
		return true;
	end;
end;

-- Called when a player attempts to fire a weapon.
function Clockwork.schema:PlayerCanFireWeapon(player, bIsRaised, weapon, bIsSecondary)
	if (bIsRaised and weapon:GetClass() != "cw_stealthcamo") then
		local stealthCamo = player:GetWeapon("cw_stealthcamo");
		local usingStealth = (ValidEntity(stealthCamo) and stealthCamo:IsActivated());
		
		if (usingStealth and player:GetVelocity():Length() <= 1) then
			return false;
		end;
	end;
end;

-- Called just after a player spawns.
function Clockwork.schema:PostPlayerSpawn(player, lightSpawn, changeClass, firstSpawn)
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
function Clockwork.schema:PlayerFootstep(player, position, foot, sound, volume, recipientFilter)
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
function Clockwork.schema:PlayerPunchThrown(player)
	player:ProgressAttribute(ATB_STRENGTH, 0.25, true);
end;

-- Called when a player punches an entity.
function Clockwork.schema:PlayerPunchEntity(player, entity)
	if (entity:IsPlayer() or entity:IsNPC()) then
		player:ProgressAttribute(ATB_STRENGTH, 1, true);
	else
		player:ProgressAttribute(ATB_STRENGTH, 0.5, true);
	end;
end;

-- Called when an entity has been breached.
function Clockwork.schema:EntityBreached(entity, activator)
	local curTime = CurTime();
	
	if (Clockwork.entity:IsDoor(entity)) then
		Clockwork.entity:OpenDoor(entity, 0, true, true);
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
function Clockwork.schema:PlayerTakeDamage(player, inflictor, attacker, hitGroup, damageInfo)
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
			
			player.cwNextCanDisconnect = curTime +90;
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
	end;
	
	if (!player.cwNextCanDisconnect or curTime > player.cwNextCanDisconnect + 60) then
		player.cwNextCanDisconnect = curTime + 60;
	end;
	
	local clothesItem = player:GetClothesItem();
	
	if (clothesItem) then
		clothesItem:SetData(
			"Durability", math.Clamp(
				clothesItem:GetData("Durability") - (damageInfo:GetDamage() / 50), 0, 100
			)
		);
	end;
end;

-- Called when a player's limb damage is bIsHealed.
function Clockwork.schema:PlayerLimbDamageHealed(player, hitGroup, amount)
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
function Clockwork.schema:PlayerLimbDamageReset(player)
	player:BoostAttribute("Limb Damage", nil, false);
end;

-- Called when a player's limb takes damage.
function Clockwork.schema:PlayerLimbTakeDamage(player, hitGroup, damage)
	local limbDamage = Clockwork.limb:GetDamage(player, hitGroup);
	
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
function Clockwork.schema:PlayerScaleDamageByHitGroup(player, attacker, hitGroup, damageInfo, baseDamage)
	local clothesItem = player:GetClothesItem();
	local endurance = Clockwork.attributes:Fraction(player, ATB_ENDURANCE, 0.4, 0.5);
	local curTime = CurTime();
	
	if (attacker:GetClass() == "entityflame") then
		if (!player.cwNextTakeBurnDmg or curTime >= player.cwNextTakeBurnDmg) then
			player.cwNextTakeBurnDmg = curTime + 0.1;
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
	
	if (attacker:IsNPC()) then
		damageInfo:ScaleDamage(3);
	end;
end;

-- Called when an NPC has been killed.
function Clockwork.schema:OnNPCKilled(victim, attacker, weapon)
	if (math.random(1, 2) == 1 or !self.uniqueItemsNPC) then
		local randomItemInfo = self:GetRandomItemInfo({"Consumables", "Disposable"});
		
		if (randomItemInfo) then
			Clockwork.entity:CreateItem(
				nil, Clockwork.item:CreateInstance(randomItemInfo[1]),
				victim:GetPos() + Vector(0, 0, 32)
			);
		end;
	else
		local randomItemID = self.uniqueItemsNPC[math.random(1, #self.uniqueItemsNPC)];
		
		if (randomItemID) then
			local itemInstance = self:LoadUniqueItemInstance(randomItemID);
			
			if (itemInstance) then
				Clockwork.entity:CreateItem(
					nil, itemInstance, victim:GetPos() + Vector(0, 0, 32)
				);
			end;
		end;
	end;
end;

-- Called when an entity takes damage.
function Clockwork.schema:EntityTakeDamage(entity, inflictor, attacker, amount, damageInfo)
	local curTime = CurTime();
	local player = Clockwork.entity:GetPlayer(entity);
	
	if (player and (!player.cwNextEnduranceTime or CurTime() > player.cwNextEnduranceTime)) then
		player:ProgressAttribute(ATB_ENDURANCE, math.Clamp(damageInfo:GetDamage(), 0, 75) / 10, true);
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
					weaponItemTable:GetData("Durability") - (amount / 20), 0, 100
				)
			);
		end;
		
		local weaponItemTable = Clockwork.item:GetByWeapon(attacker:GetActiveWeapon());
		
		if (weaponItemTable and weaponItemTable:IsBasedFrom("custom_weapon")) then
			local damageScale = ((weaponItemTable("damageScale") / 100) / 100) * weaponItemTable:GetData("Durability");
			damageInfo:ScaleDamage(math.max(damageScale, 0.1));
		end;
		
		if (entity:GetClass() == "prop_physics") then
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
		else
			damageInfo:ScaleDamage(0.5);
		end;
		
		local bDoorGuarder = false;
		
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
						
						Clockwork.entity:OpenDoor(entity, 0, true, true, attacker:GetPos());
					end;
				end;
			end;
		end;
	end;
end;