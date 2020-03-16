--[[
	© 2012 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

AddCSLuaFile("sh_boot");
AddCSLuaFile("cl_init.lua");
include("sh_boot");

--[[ Define some member variables for the schema. --]]
Schema.randomItemInfo = {};
Schema.normalExits = {
	"exit1", "exit2", "exit3", "exit4", "exit5", "exit6"
};
Schema.safeZoneList = {};
Schema.safeboxList = {};
Schema.highestCost = 0;
Schema.storage = {};

-- A function to place an item into a container.
function Schema:PlaceInContainer(itemTable, containerEntity)
	if (!containerEntity.cwInventory) then
		containerEntity.cwInventory = {};
		self.storage[containerEntity] = containerEntity;
	end;
	
	if (!containerEntity.cwCash) then
		containerEntity.cwCash = 0;
	end;
	
	Clockwork.inventory:AddInstance(
		containerEntity.cwInventory, itemTable
	);
end;

-- A function to make an entity not available in Safe Zones.
function Schema:SetNoSafeZone(entity)
	entity.cwNoSafeZone = true;
end;

-- Called when a player enters a Safe Zone.
function Schema:PlayerEnterSafeZone(player, safeZone)
	Clockwork.player:SetAction(player, "safezone_leave", false);
	Clockwork.player:SetAction(player, "safezone_enter", 20);
	player.cwIsUnsafeInTime = nil;
	player.cwIsSafeInTime = CurTime() + 20;
	player.cwUnsafeZone = nil;
end;

-- Called when a player leaves a Safe Zone.
function Schema:PlayerLeaveSafeZone(player, safeZone)
	Clockwork.player:SetAction(player, "safezone_enter", false);
	
	if (self:IsInSafeZone(player, safeZone)) then
		Clockwork.player:SetAction(player, "safezone_leave", 10);
		player.cwIsUnsafeInTime = CurTime() + 10;
		player.cwUnsafeZone = safeZone;
	else
		Clockwork.player:SetAction(player, "safezone_leave", false);
		player.cwIsUnsafeInTime = nil;
		player.cwUnsafeZone = nil;
	end;
	
	player.cwIsSafeInTime = nil;
end;

-- A function to get whether a player is in a Safe Zone.
function Schema:IsInSafeZone(player, safeZone)
	if (player.cwIsUnsafeInTime and CurTime() < player.cwIsUnsafeInTime) then
		return true;
	end;
	
	if (IsValid(safeZone or player.cwIsInSafeZone)
	and (!player.cwIsSafeInTime or CurTime() > player.cwIsSafeInTime)) then
		return true;
	end;
	
	return false;
end;

-- A function to get a player's Safe Zone.
function Schema:GetSafeZone(player)
	if (player.cwIsUnsafeInTime and CurTime() < player.cwIsUnsafeInTime) then
		return player.cwUnsafeZone;
	else
		return player.cwIsInSafeZone;
	end;
end;

-- A function to handle devices for a player.
function Schema:HandlePlayerDevices(player)
	local thermalVision = player:GetWeapon("cw_thermalvision");
	local stealthCamo = player:GetWeapon("cw_stealthcamo");
	local bIsRagdolled = player:IsRagdolled();
	local bIsAlive = player:Alive();
	
	if (IsValid(thermalVision) and thermalVision:IsActivated()
	and bIsAlive and !bIsRagdolled) then
		if (player:GetCharacterData("Stamina") > 20) then
			player:SetSharedVar("Thermal", true);
			player.cwStopReducingStamina = CurTime() + 5;
		else
			player:EmitSound("items/nvg_off.wav");
			thermalVision:SetActivated(false);
		end;
	else
		player:SetSharedVar("Thermal", false);
	end;
	
	if (IsValid(stealthCamo) and stealthCamo:IsActivated()
	and bIsAlive and !bIsRagdolled) then
		if (!player.cwLastMaterial) then
			player.cwLastMaterial = player:GetMaterial();
		end;
		
		if (!player.cwLastColor) then
			player.cwLastColor = {player:GetColor()};
		end;
		
		player:SetMaterial("sprites/heatwave");
		player:SetColor(255, 255, 255, 0);
	elseif (player.cwLastMaterial and player.cwLastColor) then
		player:SetMaterial(player.cwLastMaterial);
		player:SetColor(unpack(player.cwLastColor));
		player.cwLastMaterial = nil;
		player.cwLastColor = nil;
	end;
	
	if (player.cwStopReducingStamina and CurTime() < player.cwStopReducingStamina) then
		player:SetCharacterData(
			"Stamina", math.Clamp(player:GetCharacterData("Stamina") - 1, 0, 100)
		);
	end;
end;

-- A function to get whether a player is hungry.
function Schema:IsPlayerHungry(player)
	return (os.time() >= player:GetCharacterData("NeedsInfo").isHungry);
end;

-- A function to get whether a player is thirsty.
function Schema:IsPlayerThirsty(player)
	return (os.time() >= player:GetCharacterData("NeedsInfo").isThirsty);
end;

-- A function to restore a player's hunger.
function Schema:RestoreHunger(player)
	player:GetCharacterData("NeedsInfo").isHungry = os.time() + 3600;
end;

-- A function to restore a player's thirst.
function Schema:RestoreThirst(player)
	player:GetCharacterData("NeedsInfo").isThirsty = os.time() + 3000;
end;

-- A function to load the random items.
function Schema:LoadRandomItems()
	for k, v in pairs(Clockwork.item:GetAll()) do
		if (v("business") and !v("isRareItem") and !v("isBaseItem")) then
			if (v("cost") > self.highestCost) then
				self.highestCost = v.cost;
			end;
			
			self.randomItemInfo[#self.randomItemInfo + 1] = {
				v("uniqueID"), v("weight"), v("cost"), v("category")
			};
		end;
	end;
end;

-- A function to get some random item info.
function Schema:GetRandomItemInfo(categoryList)
	if (#self.randomItemInfo <= 0) then
		return;
	end;
	
	local randomItemInfo = self.randomItemInfo[
		math.random(1, #self.randomItemInfo)
	];
	
	if (!randomItemInfo) then
		return;
	end;
	
	if (randomItemInfo[3]) then
		local iChance = 1 - ((1 / self.highestCost) * math.min(randomItemInfo[3], self.highestCost * 0.99));
		
		if (math.random() < iChance or (categoryList
		and !table.HasValue(categoryList, randomItemInfo[4]))) then
			return self:GetRandomItemInfo(categoryList);
		else
			return randomItemInfo;
		end;
	elseif (categoryList and !table.HasValue(categoryList, randomItemInfo[4])) then
		return self:GetRandomItemInfo(categoryList);
	else
		return randomItemInfo;
	end;
end;

-- A function to get a list of rare and legenedary items.
function Schema:GetRareAndLegendaries()
	local schemaData = Clockwork:FindSchemaDataInDir("itemtypes/*.cw");
	local uniqueItems = {
		rare = {}, legendary = {}, topCost = 0
	};
	
	-- A function to grab a random legendary item.
	function uniqueItems:GetRandomLegendaryItem()
		local itemInstance = self.legendary[math.random(1, #self.legendary)];
		local itemCost = itemInstance("cost");
		
		if (itemCost == 0 or (math.random() > (1 / self.topCost) * itemCost)) then
			return Clockwork.item:CreateCopy(itemInstance);
		else
			return self:GetRandomRareItem();
		end;
	end;
	
	-- A function to grab a random rare item.
	function uniqueItems:GetRandomRareItem()
		local itemInstance = self.rare[math.random(1, #self.rare)];
		local itemCost = itemInstance("cost");
		
		if (itemCost == 0 or (math.random() > (1 / self.topCost) * itemCost)) then
			return Clockwork.item:CreateCopy(itemInstance);
		else
			return self:GetRandomRareItem();
		end;
	end;
	
	for k, v in pairs(schemaData) do
		local itemInstance = Schema:LoadUniqueItemInstance(
			string.Replace(v, ".cw", "")
		);
		
		if (itemInstance) then
			if (itemInstance:GetData("Rarity") == 1) then
				uniqueItems.rare[#uniqueItems.rare + 1] = itemInstance;
			elseif (itemInstance:GetData("Rarity") == 2) then
				uniqueItems.legendary[#uniqueItems.legendary + 1] = itemInstance;
			end;
			
			if (itemInstance("cost") > uniqueItems.topCost) then
				uniqueItems.topCost = itemInstance("cost");
			end;
		end;
	end;
	
	return uniqueItems;
end;

-- A function to load a unique item instance.
function Schema:LoadUniqueItemInstance(uniqueID)
	local itemType = Clockwork:RestoreSchemaData("itemtypes/"..uniqueID, false);
	
	if (itemType) then
		local itemInstance = Clockwork.item:CreateInstance(
			itemType.uniqueID, nil, itemType.data
		);
		local bIsScriptItem = itemInstance:IsBasedFrom("custom_script");
		
		if (itemInstance and (!bIsScriptItem or itemInstance:OnLoaded())) then
			return itemInstance;
		end;
	end;
end;

-- A function to load the mission data.
function Schema:LoadMissionData()
	Clockwork.mission.locations = Clockwork:RestoreSchemaData("missions/locations/"..game.GetMap());
end;

-- A function to save the storage.
function Schema:SaveStorage()
	local storage = {};
	
	for k, v in pairs(self.storage) do
		if (IsValid(v) and v.cwInventory and v.cwCash and (table.Count(v.cwInventory) > 0
		or v.cwCash > 0 or v:GetNetworkedString("Name") != "")) then
			local physicsObject = v:GetPhysicsObject();
			local bMoveable = nil;
			local startPos = v:GetStartPosition();
			local model = v:GetModel();
			
			if (v:IsMapEntity() and startPos) then
				model = nil;
			end;
			
			if (IsValid(physicsObject)) then
				bMoveable = physicsObject:IsMoveable();
			end;
			
			storage[#storage + 1] = {
				name = v:GetNetworkedString("Name"),
				cash = v.cwCash,
				model = model,
				color = {v:GetColor()},
				angles = v:GetAngles(),
				position = v:GetPos(),
				message = v.cwMessage,
				password = v.cwPassword,
				startPos = startPos,
				inventory = Clockwork.inventory:ToSaveable(v.cwInventory),
				isMoveable = bMoveable
			};
		end;
	end;
	
	Clockwork:SaveSchemaData("plugins/storage/"..game.GetMap(), storage);
end;

-- A function to load the storage.
function Schema:LoadStorage()
	for k, v in pairs(Clockwork:RestoreSchemaData("plugins/storage/"..game.GetMap())) do
		if (!v.model) then
			local entity = ents.FindInSphere(v.startPos or v.position, 16)[1];
			
			if (IsValid(entity) and entity:IsMapEntity()) then
				self.storage[entity] = entity;
				entity.cwInventory = Clockwork.inventory:ToLoadable(v.inventory);
				entity.cwPassword = v.password;
				entity.cwMessage = v.message;
				entity.cwCash = v.cash;
				
				if (IsValid(entity:GetPhysicsObject())) then
					if (!v.isMoveable) then
						entity:GetPhysicsObject():EnableMotion(false);
					else
						entity:GetPhysicsObject():EnableMotion(true);
					end;
				end;
				
				if (v.angles) then
					entity:SetAngles(v.angles);
					entity:SetPos(v.position);
				end;
				
				if (v.color) then
					entity:SetColor(unpack(v.color));
				end;
				
				if (v.name != "") then
					entity:SetNetworkedString("Name", v.name);
				end;
			end;
		else
			local entity = ents.Create("prop_physics");
			entity:SetAngles(v.angles);
			entity:SetModel(v.model);
			entity:SetPos(v.position);
			entity:Spawn();
			
			if (IsValid(entity:GetPhysicsObject())) then
				if (!v.isMoveable) then
					entity:GetPhysicsObject():EnableMotion(false);
				end;
			end;
			
			if (v.color) then
				entity:SetColor(unpack(v.color));
			end;
			
			if (v.name != "") then
				entity:SetNetworkedString("Name", v.name);
			end;
			
			self.storage[entity] = entity;
			
			entity.cwInventory = Clockwork.inventory:ToLoadable(v.inventory);
			entity.cwPassword = v.password;
			entity.cwMessage = v.message;
			entity.cwCash = v.cash;
		end;
	end;
end;

-- A function to load the radios.
function Schema:LoadRadios()
	local radioList = Clockwork:RestoreSchemaData("plugins/radios/"..game.GetMap());
	
	for k, v in pairs(radioList) do
		local entity = ents.Create(v.class);
		
		Clockwork.player:GivePropertyOffline(
			v.key, v.uniqueID, entity
		);
		entity:SetItemTable(
			Clockwork.item:CreateInstance(v.item, v.itemID, v.data)
		);
		entity:SetAngles(v.angles);
		entity:SetPos(v.position);
		entity:Spawn();
		
		if (IsValid(entity)) then
			entity:SetOff(v.off);
		end;
		
		if (!v.isMoveable) then
			local physicsObject = entity:GetPhysicsObject();
			
			if (IsValid(physicsObject)) then
				physicsObject:EnableMotion(false);
			end;
		end;
	end;
end;

-- A function to save the radios.
function Schema:SaveRadios()
	local radioList = {};
	
	for k, v in pairs(ents.FindByClass("cw_radio")) do
		local physicsObject = v:GetPhysicsObject();
		local itemTable = v:GetItemTable();
		local bMoveable = nil;
		
		if (IsValid(physicsObject)) then
			bMoveable = physicsObject:IsMoveable();
		end;
		
		radioList[#radioList + 1] = {
			off = v:IsOff(),
			key = Clockwork.entity:QueryProperty(v, "key"),
			item = itemTable("uniqueID"),
			data = itemTable("data"),
			class = v:GetClass(),
			angles = v:GetAngles(),
			itemID = itemTable("itemID"),
			uniqueID = Clockwork.entity:QueryProperty(v, "uniqueID"),
			position = v:GetPos(),
			isMoveable = bMoveable
		};
	end;
	
	for k, v in pairs(ents.FindByClass("cw_broadcaster")) do
		local physicsObject = v:GetPhysicsObject();
		local itemTable = v:GetItemTable();
		local bMoveable = nil;
		
		if (IsValid(physicsObject)) then
			bMoveable = physicsObject:IsMoveable();
		end;
		
		radioList[#radioList + 1] = {
			off = v:IsOff(),
			key = Clockwork.entity:QueryProperty(v, "key"),
			item = itemTable("uniqueID"),
			data = itemTable("data"),
			class = v:GetClass(),
			angles = v:GetAngles(),
			itemID = itemTable("itemID"),
			uniqueID = Clockwork.entity:QueryProperty(v, "uniqueID"),
			position = v:GetPos(),
			isMoveable = bMoveable
		};
	end;
	
	Clockwork:SaveSchemaData("plugins/radios/"..game.GetMap(), radioList);
end;

-- A function to save the safebox list.
function Schema:SaveSafeboxList()
	local safeboxList = {};
	
	for k, v in pairs(self.safeboxList) do
		safeboxList[#safeboxList + 1] = {
			position = v.position,
			angles = v.angles
		};
	end;
	
	Clockwork:SaveSchemaData("plugins/safeboxes/"..game.GetMap(), safeboxList);
end;

-- A function to load the safebox list.
function Schema:LoadSafeboxList()
	local safeboxList = Clockwork:RestoreSchemaData("plugins/safeboxes/"..game.GetMap());
	
	for k, v in pairs(safeboxList) do
		local data = {
			position = v.position,
			angles = v.angles
		};
		
		data.entity = ents.Create("cw_safebox");
		data.entity:SetAngles(data.angles);
		data.entity:SetPos(data.position);
		data.entity:Spawn();
		data.entity:GetPhysicsObject():EnableMotion(false);
		
		self.safeboxList[#self.safeboxList + 1] = data;
	end;
end;

-- A function to save the Safe Zone list.
function Schema:SaveSafeZoneList()
	local safeZoneList = {};
	
	for k, v in pairs(self.safeZoneList) do
		safeZoneList[#safeZoneList + 1] = {
			position = v.position,
			angles = v.angles,
			name = v.name,
			size = v.size
		};
	end;
	
	Clockwork:SaveSchemaData("plugins/safezones/"..game.GetMap(), safeZoneList);
end;

-- A function to load the Safe Zone list.
function Schema:LoadSafeZoneList()
	local safeZoneList = Clockwork:RestoreSchemaData("plugins/safezones/"..game.GetMap());
	
	for k, v in pairs(safeZoneList) do
		local data = {
			position = v.position,
			angles = v.angles,
			name = v.name,
			size = v.size
		};
		
		data.entity = ents.Create("cw_safezone");
		data.entity:SetAngles(data.angles);
		data.entity:SetPos(data.position);
		data.entity:Spawn();
		
		--[[ Set the size and name of the Safe Zone. --]]
		data.entity:GetPhysicsObject():EnableMotion(false);
		data.entity:SetNetworkedString("Name", data.name);
		data.entity:SetSize(data.size);
		
		self.safeZoneList[#self.safeZoneList + 1] = data;
	end;
end;

-- A function to open a container for a player.
function Schema:OpenContainer(player, entity, weight)
	local inventory = nil;
	local cash = 0;
	local name = "Safebox";
	
	if (entity:GetClass() != "cw_safebox") then
		local model = string.lower(entity:GetModel());
		
		if (!entity.cwInventory) then
			self.storage[entity] = entity;
			entity.cwInventory = {};
		end;
		
		if (!entity.cwCash) then
			entity.cwCash = 0;
		end;
		
		if (self.containers[model]) then
			name = self.containers[model][2];
		else
			name = "Container";
		end;
		
		inventory = entity.cwInventory;
		cash = entity.cwCash;
		
		if (!weight) then
			weight = 8;
		end;
	else
		inventory = player:GetCharacterData("SafeboxItems");
		weight = Clockwork.config:Get("max_safebox_weight"):Get();
		cash = player:GetCharacterData("SafeboxCash");
	end;
	
	if (entity:GetNetworkedString("Name") != "") then
		name = entity:GetNetworkedString("Name");
	end;
	
	if (entity.cwMessage) then
		umsg.Start("cwStorageMessage", player);
			umsg.Entity(entity);
			umsg.String(entity.cwMessage);
		umsg.End();
	end;
	
	Clockwork.storage:Open(player, {
		name = name,
		cash = cash,
		weight = weight,
		entity = entity,
		distance = 192,
		inventory = inventory,
		OnGiveCash = function(player, storageTable, cash)
			if (storageTable.entity:GetClass() == "cw_safebox") then
				player:SetCharacterData("SafeboxCash", storageTable.cash);
			else
				storageTable.entity.cwCash = storageTable.cash;
			end;
		end,
		OnTakeCash = function(player, storageTable, cash)
			if (storageTable.entity:GetClass() == "cw_safebox") then
				player:SetCharacterData("SafeboxCash", storageTable.cash);
			else
				storageTable.entity.cwCash = storageTable.cash;
			end;
		end,
		noCashWeight = true
	});
end;

-- A function to make an explosion.
function Schema:MakeExplosion(position, scale)
	local explosionEffect = EffectData();
	local smokeEffect = EffectData();
		explosionEffect:SetOrigin(position);
		explosionEffect:SetScale(scale);
		smokeEffect:SetOrigin(position);
		smokeEffect:SetScale(scale);
	util.Effect("explosion", explosionEffect, true, true);
	util.Effect("cw_smoke_effect", smokeEffect, true, true);
end;

-- A function to spawn a flash.
function Schema:SpawnFlash(position)
	local curTime = CurTime();
	
	local effectData = EffectData();
		effectData:SetStart(position);
		effectData:SetOrigin(position);
		effectData:SetScale(16);
	util.Effect("Explosion", effectData, true, true);
	
	local effectData = EffectData();
		effectData:SetOrigin(position);
		effectData:SetScale(2);
	util.Effect("cw_smoke_effect", effectData, true, true);
	
	for k, v in ipairs(_player.GetAll()) do
		if (v:HasInitialized() and v:GetPos():Distance(position) <= 768) then
			if (Clockwork.player:CanSeePosition(v, position, 0.9, true)) then
				umsg.Start("cwFlashed", v);
				umsg.End();
			end;
		end;
	end;
end;

-- A function to spawn tear gas.
function Schema:SpawnTearGas(position)
	local curTime = CurTime();
	
	local effectData = EffectData();
		effectData:SetStart(position);
		effectData:SetOrigin(position);
		effectData:SetScale(16);
	util.Effect("Explosion", effectData, true, true);
	
	local effectData = EffectData();
		effectData:SetOrigin(position);
		effectData:SetScale(2);
	util.Effect("cw_smoke_effect", effectData, true, true);
	
	for k, v in ipairs(ents.FindInSphere(position, 512)) do
		if (v:IsPlayer() and v:HasInitialized()) then
			if (Clockwork.player:CanSeePosition(v, position, 0.9, true)) then
				local clothesItem = v:GetClothesItem();
				
				if (!clothesItem or !clothesItem("tearGasProtection")) then
					if (!v.nextTearGas or curTime >= v.nextTearGas) then
						v.nextTearGas = curTime + 30;
						
						umsg.Start("cwTearGas", v);
						umsg.End();
					end;
				end;
			end;
		end;
	end;
end;

-- A function to get a player's heal amount.
function Schema:GetHealAmount(player, scale)
	return (15 + Clockwork.attributes:Fraction(player, ATB_DEXTERITY, 35)) * (scale or 1);
end;

-- A function to get a player's dexterity time.
function Schema:GetDexterityTime(player)
	return 12 - Clockwork.attributes:Fraction(player, ATB_DEXTERITY, 5, 5);
end;

-- A function to bust down a door.
function Schema:BustDownDoor(player, door, force)
	door.cwIsBustedDown = true;
	door:SetNotSolid(true);
	door:DrawShadow(false);
	door:SetNoDraw(true);
	door:EmitSound("physics/wood/wood_box_impact_hard3.wav");
	door:Fire("Unlock", "", 0);
	
	local fakeDoor = ents.Create("prop_physics");
	
	fakeDoor:SetCollisionGroup(COLLISION_GROUP_WORLD);
	fakeDoor:SetAngles(door:GetAngles());
	fakeDoor:SetModel(door:GetModel());
	fakeDoor:SetSkin(door:GetSkin());
	fakeDoor:SetPos(door:GetPos());
	fakeDoor:Spawn();
	
	local physicsObject = fakeDoor:GetPhysicsObject();
	
	if (IsValid(physicsObject)) then
		if (!force) then
			if (IsValid(player)) then
				physicsObject:ApplyForceCenter((door:GetPos() - player:GetPos()):Normalize() * 10000);
			end;
		else
			physicsObject:ApplyForceCenter(force);
		end;
	end;
	
	Clockwork.entity:Decay(fakeDoor, 300);
	
	Clockwork:CreateTimer("ResetDoor"..door:EntIndex(), 300, 1, function()
		if (IsValid(door)) then
			door:SetNotSolid(false);
			door:DrawShadow(true);
			door:SetNoDraw(false);
			door.cwIsBustedDown = nil;
		end;
	end);
end;

-- A function to load the belongings.
function Schema:LoadBelongings()
	local belongings = Clockwork:RestoreSchemaData("plugins/belongings/"..game.GetMap());
	
	for k, v in pairs(belongings) do
		local entity = ents.Create("cw_belongings");
			entity:SetAngles(v.angles);
			entity:SetData(
				Clockwork.inventory:ToLoadable(v.inventory),
				v.cwCash
			);
			entity:SetPos(v.position);
		entity:Spawn();
		
		if (!v.isMoveable) then
			local physicsObject = entity:GetPhysicsObject();
			
			if (IsValid(physicsObject)) then
				physicsObject:EnableMotion(false);
			end;
		end;
	end;
end;

-- A function to save the belongings.
function Schema:SaveBelongings()
	local belongings = {};
	
	for k, v in pairs(ents.FindByClass("prop_ragdoll")) do
		if (v.cwIsBelongings and (v.cwCash > 0 or table.Count(v.cwInventory) > 0)) then
			belongings[#belongings + 1] = {
				cash = v.cwCash,
				angles = Angle(0, 0, -90),
				position = v:GetPos() + Vector(0, 0, 32),
				inventory = Clockwork.inventory:ToSaveable(v.cwInventory),
				isMoveable = true
			};
		end;
	end;
	
	for k, v in pairs(ents.FindByClass("cw_belongings")) do
		if (v.cwCash and v.cwInventory and (v.cwCash > 0 or table.Count(v.cwInventory) > 0)) then
			local physicsObject = v:GetPhysicsObject();
			local bMoveable = nil;
			
			if (IsValid(physicsObject)) then
				bMoveable = physicsObject:IsMoveable();
			end;
			
			belongings[#belongings + 1] = {
				cash = v.cwCash,
				angles = v:GetAngles(),
				position = v:GetPos(),
				inventory = Clockwork.inventory:ToSaveable(v.cwInventory),
				isMoveable = bMoveable
			};
		end;
	end;
	
	Clockwork:SaveSchemaData("plugins/belongings/"..game.GetMap(), belongings);
end;

-- A function to load the sign posts.
function Schema:LoadSignPosts()
	local signPosts = Clockwork:RestoreSchemaData("plugins/signposts/"..game.GetMap());
	
	for k, v in pairs(signPosts) do
		local entity = ents.Create("cw_sign_post");
			entity:SetAngles(v.angles);
			entity:SetPos(v.position);
		entity:Spawn();
		
		Clockwork.player:GivePropertyOffline(
			v.key, v.uniqueID, entity
		);
		
		if (!v.isMoveable) then
			local physicsObject = entity:GetPhysicsObject();
			
			if (IsValid(physicsObject)) then
				physicsObject:EnableMotion(false);
			end;
		end;
		
		entity:SetNetworkedString("Text", v.text);
	end;
end;

-- A function to save the sign posts.
function Schema:SaveSignPosts()
	local signPosts = {};
	
	for k, v in pairs(ents.FindByClass("cw_sign_post")) do
		local physicsObject = v:GetPhysicsObject();
		local bMoveable = nil;
		
		if (IsValid(physicsObject)) then
			bMoveable = physicsObject:IsMoveable();
		end;
		
		signPosts[#signPosts + 1] = {
			key = Clockwork.entity:QueryProperty(v, "key"),
			text = v:GetNetworkedString("Text"),
			angles = v:GetAngles(),
			position = v:GetPos(),
			uniqueID = Clockwork.entity:QueryProperty(v, "uniqueID"),
			isMoveable = bMoveable
		};
	end;
	
	Clockwork:SaveSchemaData("plugins/signposts/"..game.GetMap(), signPosts);
end;

-- A function to make a player drop random items.
function Schema:PlayerDropRandomItems(player, ragdoll, bEvenClothes)
	local clothesItem = player:GetClothesItem();
	local inventory = player:GetInventory();
	local cash = player:GetCash();
	local info = {
		inventory = {},
		cash = cash
	};
	
	if (!IsValid(ragdoll)) then
		info.entity = ents.Create("cw_belongings");
	end;
	
	for k, v in pairs(inventory) do
		for k2, v2 in pairs(v) do
			if (!v2("isRareItem")
			and v2("allowStorage") != false) then
				if (bEvenClothes or !clothesItem
				or !clothesItem:IsTheSameAs(v2)) then
					Clockwork.inventory:AddInstance(
						info.inventory, v2
					);
					
					player:TakeItem(v2);
				end;
			end;
		end;
	end;
	
	player:SetCharacterData("Cash", 0, true);
	
	if (!IsValid(ragdoll)) then
		if (!Clockwork.inventory:IsEmpty(info.inventory) or info.cash > 0) then
			info.entity:SetAngles(Angle(0, 0, -90));
			info.entity:SetData(info.inventory, info.cash);
			info.entity:SetPos(player:GetPos() + Vector(0, 0, 48));
			info.entity:Spawn();
		else
			info.entity:Remove();
		end;
	else
		ragdoll.cwIsBelongings = true;
		ragdoll.cwInventory = info.inventory;
		ragdoll.cwCash = info.cash;
	end;
	
	player:SaveCharacter();
end;

-- A function to tie or untie a player.
function Schema:TiePlayer(player, isTied, reset, government)
	player:SetSharedVar("IsTied", isTied == true);
	
	if (isTied) then
		Clockwork.player:DropWeapons(player);
		Clockwork:PrintLog(LOGTYPE_GENERIC, player:Name().." has been tied.");
		
		player:Flashlight(false);
		player:StripWeapons();
	elseif (!reset) then
		if (player:Alive() and !player:IsRagdolled()) then 
			Clockwork.player:LightSpawn(player, true, true);
		end;
		
		Clockwork:PrintLog(LOGTYPE_GENERIC, player:Name().." has been untied.");
	end;
end;

--[[
	Define all functions related to handling the vehicle
	system here.
--]]

-- A function to get a vehicle exit for a player.
function Schema:GetVehicleExit(player, vehicleEntity)
	local availableVehicles = {};
	local closestVehicle = {};
	
	if (vehicleEntity.cwItemTable and vehicleEntity.cwItemTable("customExits")) then
		for k, v in ipairs(vehicleEntity.cwItemTable("customExits")) do
			local bIsUnsafe = nil;
			local position = vehicleEntity:LocalToWorld(v);
			local entities = ents.FindInSphere(position, 1);
			
			for k2, v2 in ipairs(entities) do
				if (player != v2 and v2:IsPlayer()) then
					bIsUnsafe = true;
					break;
				end;
			end;
			
			if (util.IsInWorld(position) and !bIsUnsafe) then
				availableVehicles[#availableVehicles + 1] = position;
			end;
		end;
	end;
	
	for k, v in ipairs(self.normalExits) do
		local attachment = vehicleEntity:GetAttachment(vehicleEntity:LookupAttachment(v));
		
		if (attachment) then
			local bIsUnsafe = false;
			local position = attachment.Pos;
			local entities = ents.FindInSphere(position, 1);
			
			for k2, v2 in ipairs(entities) do
				if (player != v2 and v2:IsPlayer()) then
					bIsUnsafe = true;
					break;
				end;
			end;
			
			if (!bIsUnsafe and util.IsInWorld(position)) then
				availableVehicles[#availableVehicles + 1] = position;
			end;
		end;
	end;
	
	for k, v in ipairs(availableVehicles) do
		local distance = player:GetPos():Distance(v);
		
		if (!closestVehicle[1] or distance < closestVehicle[1]) then
			closestVehicle[1] = distance;
			closestVehicle[2] = v;
		end;
	end;

	if (closestVehicle[2]) then
		Clockwork.player:SetSafePosition(player, closestVehicle[2]);
	end;
end;

-- A function to make a player exit a vehicle.
function Schema:MakeExitVehicle(player, vehicleEntity)
	player:SetVelocity(Vector(0, 0, 0));

	if (!player:InVehicle()) then
		local parentVehicle = vehicleEntity:GetParent();
		
		if (IsValid(parentVehicle)) then
			self:GetVehicleExit(player, parentVehicle);
		else
			self:GetVehicleExit(player, vehicleEntity);
		end;
	end;
end;

-- A function to spawn a vehicle.
function Schema:SpawnVehicle(player, itemTable)
	local eyeTrace = player:GetEyeTraceNoCursor();

	if (player:GetPos():Distance(eyeTrace.HitPos) <= 512) then
		local trace = util.QuickTrace(eyeTrace.HitPos, eyeTrace.HitNormal * 100000);

		if (!trace.HitSky) then
			Clockwork.player:Notify(player, "You can only spawn a vehicle outside!");
			return false;
		end;

		local vehicleEntity, fault = self:MakeVehicle(player, itemTable, eyeTrace.HitPos + Vector(0, 0, 32), Angle(0, player:GetAngles().yaw + 180, 0));

		if (!IsValid(vehicleEntity)) then
			if (fault) then Clockwork.player:Notify(player, fault); end;
			return false;
		end;

		if (itemTable("skin")) then
			vehicleEntity:SetSkin(itemTable("skin"));
		end;

		vehicleEntity.m_tblToolsAllowed = {"remover"};
		
		-- Called when a player attempts to use a tool.
		function vehicleEntity:CanTool(player, trace, tool)
			return (mode == "remover" and player:IsAdmin());
		end;

		Clockwork.player:GiveProperty(player, vehicleEntity, true);
			player.cwVehicleList[vehicleEntity] = itemTable;
		return vehicleEntity;
	else
		Clockwork.player:Notify(player, "You cannot spawn a vehicle that far away!");
		return false;
	end;
end;

-- A function to make a vehicle.
function Schema:MakeVehicle(player, itemTable, position, angles)
	local vehicleEntity = ents.Create(itemTable("class"));
	local itemKeyValues = itemTable("keyValues");
	
	vehicleEntity:SetModel(itemTable("model"));

	if (itemKeyValues) then
		for k, v in pairs(itemKeyValues) do
			vehicleEntity:SetKeyValue(k, v);
		end		
	end;

	vehicleEntity:SetAngles(angles);
		vehicleEntity:SetPos(position);
		vehicleEntity:Spawn();
		vehicleEntity:Activate();
		vehicleEntity:SetUseType(SIMPLE_USE);
	vehicleEntity:SetNetworkedInt("Index", itemTable("index"));

	local physicsObject = vehicleEntity:GetPhysicsObject();

	if (!IsValid(physicsObject)) then
		return false, "The physics object for this vehicle is not valid!";
	end

	if (physicsObject:IsPenetrating()) then
		vehicleEntity:Remove();
		return false, "A vehicle cannot be spawned at this location!";
	end

	vehicleEntity.cwItemTable = itemTable;
	vehicleEntity.VehicleName = itemTable("name");
	vehicleEntity.ClassOverride = itemTable("class");
	
	-- A function to get the vehicle's item table.
	function vehicleEntity:GetItemTable()
		return self.cwItemTable;
	end;

	local localPosition = vehicleEntity:GetPos();
	local localAngles = vehicleEntity:GetAngles();

	if (itemTable("passengers")) then		
		local seatType = itemTable("seatType");
		local seatData = list.Get("Vehicles")[seatType];

		for k, v in ipairs(itemTable("passengers")) do
			local seatPosition = localPosition + (localAngles:Forward() * v.position.x) + (localAngles:Right() * v.position.y) + (localAngles:Up() * v.position.z);
			local seatEntity = ents.Create("prop_vehicle_prisoner_pod");

			seatEntity:SetKeyValue("vehiclescript", "scripts/vehicles/prisoner_pod.txt");
			seatEntity:SetAngles(localAngles + v.angles);
			seatEntity:SetModel(seatData.Model);
			seatEntity:SetPos(seatPosition);
			seatEntity:Spawn();

			seatEntity:Activate();
			seatEntity:Fire("lock", "", 0);

			seatEntity:SetCollisionGroup(COLLISION_GROUP_WORLD);
			seatEntity:SetParent(vehicleEntity);
			
			if (itemTable("useLocalPositioning")) then
				seatEntity:SetLocalPos(v.position);
				seatEntity:SetLocalAngles(v.angles);
			end;

			if (itemTable("hideSeats")) then
				seatEntity:SetColor(255, 255, 255, 0);
			end;

			if (seatData.Members) then
				table.Merge(seatEntity, seatData.Members);
			end;

			if (seatData.KeyValues) then
				for k2, v2 in pairs(seatData.KeyValues) do
					seatEntity:SetKeyValue(k2, v2);
				end;
			end;

			seatEntity:DeleteOnRemove(vehicleEntity);
			seatEntity.ClassOverride = "prop_vehicle_prisoner_pod";
			seatEntity.VehicleTable = seatData
			seatEntity.VehicleName = "Jeep Seat";

			if (!vehicleEntity.cwPassengers) then
				vehicleEntity.cwPassengers = {};
			end;

			vehicleEntity.cwPassengers[k] = seatEntity;
		end;
	end;
	
	Clockwork.item:AddItemEntity(vehicleEntity, itemTable);
	return vehicleEntity;
end;

--[[ Begin adding resource files. --]]

resource.AddFile("materials/models/weapons/temptexture/handsmesh1.vtf");
resource.AddFile("materials/models/weapons/temptexture/handsmesh1.vmt");
resource.AddFile("models/weapons/v_sledgehammer/v_sledgehammer.mdl");
resource.AddFile("resource/fonts/Anklada.ttf");
resource.AddFile("materials/models/weapons/v_katana/katana.vtf");
resource.AddFile("materials/models/weapons/v_katana/katana.vmt");
resource.AddFile("models/weapons/v_shovel/v_shovel.mdl");
resource.AddFile("materials/models/weapons/sledge.vtf");
resource.AddFile("sound/weapons/LaserPistol_NoAmmo.wav");
resource.AddFile("sound/weapons/LaserPistol_Fire.wav");
resource.AddFile("materials/effects/FXTracerAlienHeroic.vtf");
resource.AddFile("materials/effects/FXTracerAlienHeroic.vmt");
resource.AddFile("materials/effects/FXTracerAlien.vtf");
resource.AddFile("materials/effects/FXTracerAlien.vmt");
resource.AddFile("materials/effects/EXNiceBigFlare.vtf");
resource.AddFile("materials/effects/EXNiceBigFlare.vmt");
resource.AddFile("materials/effects/FXBlueFlare.vtf");
resource.AddFile("materials/effects/FXBlueFlare.vmt");
resource.AddFile("materials/models/weapons/sledge.vmt");
resource.AddFile("materials/models/weapons/shovel.vtf");
resource.AddFile("materials/models/weapons/shovel.vmt");
resource.AddFile("materials/models/weapons/axe.vtf");
resource.AddFile("materials/models/weapons/axe.vmt");
resource.AddFile("models/weapons/w_sledgehammer.mdl");
resource.AddFile("models/weapons/v_axe/v_axe.mdl");
resource.AddFile("models/pmc/pmc_4/pmc__07.mdl");
resource.AddFile("models/weapons/w_katana.mdl");
resource.AddFile("models/weapons/v_katana.mdl");
resource.AddFile("models/weapons/w_shovel.mdl");
resource.AddFile("models/tactical_rebel.mdl");
resource.AddFile("models/weapons/w_axe.mdl");
resource.AddFile("sound/vehicles/honk.wav");
resource.AddFile("sound/item_found.mp3");
resource.AddFile("sound/sad_trombone.mp3");
resource.AddFile("sound/aperture.mp3");
resource.AddFile("models/riot_ex2.mdl");
resource.AddFile("models/sprayca2.mdl");
resource.AddFile("models/tacoma2.mdl");

for k, v in pairs(_file.Find("../materials/models/humans/female/group01/ciaizen_sheet.*")) do
	resource.AddFile("materials/models/humans/female/group01/"..v);
end;

for k, v in pairs(_file.Find("../materials/models/humans/male/group01/ciaizen_sheet.*")) do
	resource.AddFile("materials/models/humans/male/group01/"..v);
end;

for k, v in pairs(_file.Find("../materials/models/humans/female/group01/cilizen_sheet.*")) do
	resource.AddFile("materials/models/humans/female/group01/"..v);
end;

for k, v in pairs(_file.Find("../materials/models/humans/male/group01/cilizen_sheet.*")) do
	resource.AddFile("materials/models/humans/male/group01/"..v);
end;

for k, v in pairs(_file.Find("../materials/models/humans/female/group01/cibizen_sheet.*")) do
	resource.AddFile("materials/models/humans/female/group01/"..v);
end;

for k, v in pairs(_file.Find("../materials/models/humans/male/group01/cibizen_sheet.*")) do
	resource.AddFile("materials/models/humans/male/group01/"..v);
end;

for k, v in pairs(_file.Find("../materials/models/player/slow/aot/salem/*.*")) do
	resource.AddFile("materials/models/player/slow/aot/salem/"..v);
end;

for k, v in pairs(_file.Find("../materials/models/props_vehicles/car002a_01.*")) do
	resource.AddFile("materials/models/props_vehicles/"..v);
end;

for k, v in pairs(_file.Find("../materials/models/props/de_tides/truck001c_01.*")) do
	resource.AddFile("materials/models/props/de_tides/"..v);
end;

for k, v in pairs(_file.Find("../materials/models/props/de_tides/trucktires.*")) do
	resource.AddFile("materials/models/props/de_tides/"..v);
end;

for k, v in pairs(_file.Find("../materials/models/player/slow/napalm_atc/*.*")) do
	resource.AddFile("materials/models/player/slow/napalm_atc/"..v);
end;

for k, v in pairs(_file.Find("../materials/models/player/slow/nailgunner/*.*")) do
	resource.AddFile("materials/models/player/slow/nailgunner/"..v);
end;

for k, v in pairs(_file.Find("../materials/models/jason278/fallout 3/*.*")) do
	resource.AddFile("materials/models/jason278/fallout 3/"..v);
end;

for k, v in pairs(_file.Find("../materials/models/player/slow/bio_suit/*.*")) do
	resource.AddFile("materials/models/player/slow/bio_suit/"..v);
end;

for k, v in pairs(_file.Find("../materials/models/player/riex/*.*")) do
	resource.AddFile("materials/models/player/riex/"..v);
end;

for k, v in pairs(_file.Find("../materials/models/pmc/pmc_shared/*.*")) do
	resource.AddFile("materials/models/pmc/pmc_shared/"..v);
end;

for k, v in pairs(_file.Find("../materials/models/gasmask/tac_rbe/*.*")) do
	resource.AddFile("materials/models/gasmask/tac_rbe/"..v);
end;

for k, v in pairs(_file.Find("../materials/models/ill_hanger/vehicles/*.*")) do
	resource.AddFile("materials/models/ill_hanger/vehicles/"..v);
end;

for k, v in pairs(_file.Find("../materials/models/kevlarvest/*.*")) do
	resource.AddFile("materials/models/kevlarvest/"..v);
end;

for k, v in pairs(_file.Find("../materials/models/stalker/sx/*.*")) do
	resource.AddFile("materials/models/stalker/sx/"..v);
end;

for k, v in pairs(_file.Find("../materials/models/stalker/mx/*.*")) do
	resource.AddFile("materials/models/stalker/mx/"..v);
end;

for k, v in pairs(_file.Find("../materials/models/stalker/fx/*.*")) do
	resource.AddFile("materials/models/stalker/fx/"..v);
end;

for k, v in pairs(_file.Find("../materials/models/stalker/dx/*.*")) do
	resource.AddFile("materials/models/stalker/dx/"..v);
end;

for k, v in pairs(_file.Find("../materials/models/banditv/*.*")) do
	resource.AddFile("materials/models/banditv/"..v);
end;

for k, v in pairs(_file.Find("../materials/models/pmc/pmc_4/*.*")) do
	resource.AddFile("materials/models/pmc/pmc_4/"..v);
end;

for k, v in pairs(_file.Find("../sound/vehicles/truck/*.*")) do
	resource.AddFile("sound/vehicles/truck/"..v);
end;

for k, v in pairs(_file.Find("../sound/vehicles/enzo/*.*")) do
	resource.AddFile("sound/vehicles/enzo/"..v);
end;

for k, v in pairs(_file.Find("../sound/vehicles/cf_mech*.*")) do
	resource.AddFile("sound/vehicles/"..v);
end;

for k, v in pairs(_file.Find("../sound/vehicles/digger_*.*")) do
	resource.AddFile("sound/vehicles/"..v);
end;

for k, v in pairs(_file.Find("../models/humans/group04/*.mdl")) do
	resource.AddFile("models/humans/group04/"..v);
end;

for k, v in pairs(_file.Find("../models/humans/group07/*.mdl")) do
	resource.AddFile("models/humans/group07/"..v);
end;

for k, v in pairs(_file.Find("../models/fallout 3/backpack_*.mdl")) do
	resource.AddFile("models/fallout 3/"..v);
end;

for k, v in pairs(_file.Find("../models/humans/group08/*.mdl")) do
	resource.AddFile("models/humans/group08/"..v);
end;

for k, v in pairs(_file.Find("../models/kevlarvest/*.mdl")) do
	resource.AddFile("models/kevlarvest/"..v);
end;

for k, v in pairs(_file.Find("../models/tideslkw.*")) do
	resource.AddFile("models/"..v);
end;

for k, v in pairs(_file.Find("../models/trabbi.*")) do
	resource.AddFile("models/"..v);
end;

for k, v in pairs(_file.Find("../models/napalm_atc/*.mdl")) do
	resource.AddFile("models/napalm_atc/"..v);
end;

for k, v in pairs(_file.Find("../models/nailgunner/*.mdl")) do
	resource.AddFile("models/nailgunner/"..v);
end;
for k, v in pairs(_file.Find("../models/salem/*.mdl")) do
	resource.AddFile("models/salem/"..v);
end;

for k, v in pairs(_file.Find("../models/bio_suit/*.mdl")) do
	resource.AddFile("models/bio_suit/"..v);
end;

for k, v in pairs(_file.Find("../models/srp/*.mdl")) do
	resource.AddFile("models/srp/"..v);
end;

for k, v in pairs(_file.Find("../scripts/vehicles/*.*")) do
	resource.AddFile("scripts/vehicles/"..v);
end;

Clockwork.config:Add("intro_text_small", "Good luck trying to survive out there.", true);
Clockwork.config:Add("intro_text_big", "WELCOME TO THE ZONE", true);
Clockwork.config:Add("max_safebox_weight", 30);

Clockwork.config:Get("scale_attribute_progress"):Set(0.25);
Clockwork.config:Get("enable_gravgun_punt"):Set(false);
Clockwork.config:Get("default_inv_weight"):Set(4);
Clockwork.config:Get("enable_crosshair"):Set(false);
Clockwork.config:Get("minimum_physdesc"):Set(16);
Clockwork.config:Get("scale_prop_cost"):Set(0.35);
Clockwork.config:Get("scale_head_dmg"):Set(2);
Clockwork.config:Get("disable_sprays"):Set(false);
Clockwork.config:Get("default_cash"):Set(50);

Clockwork.hint:Add("Healing", "You can heal players by using the Give command in your inventory.");
Clockwork.hint:Add("Zip Tie", "Press F3 while looking at a character to use a zip tie.");
Clockwork.hint:Add("Search Char", "Press F3 while looking at a tied character to search them.");
Clockwork.hint:Add("Group Start", "Start a group using the $command_prefix$GroupStart chat command.");
Clockwork.hint:Add("Group Invite", "Invite people to your group using the $command_prefix$GroupInvite chat command.");

Clockwork:HookDataStream("Notepad", function(player, data)
	local itemTable = player:FindItemByID(data.index, data.itemID);
	
	if (type(data.text) == "string" and itemTable) then
		itemTable:SetData("Text", string.sub(data.text, 0, 500));
		itemTable:SetData("Hint", string.sub(data.text, 0, 32));
	end;
end);

Clockwork:HookDataStream("JoinGroup", function(player, data)
	if (!player.cwGroupInvite) then
		Clockwork.player:Notify(player, "You have not been invited to a group!");
		return;
	end;
	
	local groupInfo = player:GetCharacterData("GroupInfo");
		groupInfo.name = player.cwGroupInvite;
		groupInfo.rank = RANK_RCT;
	player.cwGroupInvite = nil;
end);

Clockwork:HookDataStream("StartGroup", function(player, data)
	if (!player.cwGroupName) then
		Clockwork.player:Notify(player, "You have not specified a name for your group!");
		return;
	end;
	
	local groupName = string.gsub(string.sub(player.cwGroupName, 1, 32), "[%p%d]", "");
	
	tmysql.query("SELECT * FROM test_groups WHERE _Name = \""..tmysql.escape(groupName).."\"", function(result)
		if (!IsValid(player)) then return; end;
		
		if (result and type(result) == "table" and #result > 0) then
			Clockwork.player:Notify(player, "A group with the name "..groupName.." already exists!");
		elseif (Clockwork.player:CanAfford(player, 1000)) then
			tmysql.query("INSERT INTO test_groups (_Name) VALUES (\""..tmysql.escape(groupName).."\")", function(result)
				local groupInfo = player:GetCharacterData("GroupInfo");
					groupInfo.name = groupName;
					groupInfo.rank = RANK_MAJ;
				player.cwGroupName = nil;
				
				Clockwork.player:GiveCash(player, -1000, "creating a group");
				Clockwork.player:Notify(player, "You have created the "..groupName.." group.");
			end, 1);
		else
			Clockwork.player:Notify(player, "You need another "..FORMAT_CASH(1000 - player:GetCash(), nil, true).."!");
		end;
	end, 1);
end);

Clockwork:HookDataStream("GroupNotes", function(player, data)
	local groupNotes = string.sub(data, 0, 1024);
	local myGroupInfo = player:GetCharacterData("GroupInfo");
	
	if (!myGroupInfo.name or myGroupInfo.rank < RANK_SGT) then
		return;
	end;
	
	tmysql.query("UPDATE test_groups SET _Notes = \""..tmysql.escape(groupNotes).."\" WHERE _Name = \""..tmysql.escape(myGroupInfo.name).."\"");
	
	local memberList = {};
		for k, v in ipairs(_player.GetAll()) do
			if (v:HasInitialized() and v:GetCharacterData("GroupInfo").name == myGroupInfo.name) then
				memberList[#memberList + 1] = v;
			end;
		end;
	Clockwork:StartDataStream(memberList, "GroupNotes", groupNotes);
	
	for k, v in ipairs(memberList) do
		if (player != v) then
			Clockwork.player:Notify(v, "The group notes for "..myGroupInfo.name.." have been updated.");
		end;
	end;
end);

Clockwork:HookDataStream("RepairItem", function(player, data)
	local itemTable = player:FindItemByID(data.uniqueID, data.itemID);
	if (!itemTable) then return end;
	
	local durability = itemTable:GetData("Durability");
	if (durability == 100) then return; end;
	
	local itemCost = itemTable("cost");
	local minPrice = itemCost * 0.1;
	local maxPrice = itemCost * 0.6;
	local repairCost = math.max((maxPrice / 100) * (100 - durability), minPrice);
	local useSounds = {"buttons/button5.wav", "buttons/button4.wav"};
	local currentCash = player:GetCash();
	
	if (Clockwork.player:CanAfford(player, repairCost)) then
		Clockwork.player:GiveCash(player, -repairCost, "repairing an item");
			player:EmitSound(useSounds[math.random(1, #useSounds)]);
		itemTable:SetData("Durability", 100);
	elseif (currentCash >= minPrice) then
		local newDurability = ((100 - durability) / repairCost) * currentCash;
		local newRepairCost = math.ceil((repairCost / (100 - durability)) * newDurability);
		Clockwork.player:GiveCash(player, -newRepairCost, "repairing an item");
			player:EmitSound(useSounds[math.random(1, #useSounds)]);
		itemTable:SetData("Durability", math.ceil(durability + newDurability));
	else
		Clockwork.player:Notify(player, "You need another "..FORMAT_CASH(repairCost - currentCash, nil, true).."!");
	end;
end);

Clockwork:HookDataStream("UpgradeItem", function(player, data)
	local itemTable = player:FindItemByID(data.uniqueID, data.itemID);
	if (!itemTable) then return end;
	
	local itemLevel = itemTable:GetData("Level");
	if (itemLevel == 6) then return; end;
	
	local upgradeCost = itemTable("cost") * (itemTable:GetData("Level") + 1); 
	local currentCash = player:GetCash();
	local useSounds = {"buttons/button5.wav", "buttons/button4.wav"};
	
	if (Clockwork.player:CanAfford(player, upgradeCost)) then
		Clockwork.player:GiveCash(player, -upgradeCost, "upgrading an item");
			player:EmitSound(useSounds[math.random(1, #useSounds)]);
		itemTable:SetData("Level", itemTable:GetData("Level") + 1);
	else
		Clockwork.player:Notify(player, "You need another "..FORMAT_CASH(upgradeCost - currentCash, nil, true).."!");
	end;
end);

Clockwork:HookDataStream("ContainerPassword", function(player, data)
	local password = data[1];
	local entity = data[2];
	
	if (IsValid(entity) and Clockwork.entity:IsPhysicsEntity(entity)) then
		local model = string.lower(entity:GetModel());
		
		if (Schema.containers[model]) then
			local containerWeight = Schema.containers[model][1];
			
			if (entity.cwPassword == password) then
				Schema:OpenContainer(player, entity, containerWeight);
			else
				Clockwork.player:Notify(player, "You have entered an incorrect password!");
			end;
		end;
	end;
end);

Clockwork:HookDataStream("ManageCar", function(player, data)
	local vehicleEntity = player:GetVehicle();
	if (!IsValid(vehicleEntity)) then return; end;

	local parentVehicle = vehicleEntity:GetParent();
	
	if (!IsValid(parentVehicle)) then
		if (vehicleEntity.cwItemTable) then
			parentVehicle = vehicleEntity;
		end;
	end;
	
	if (player:InVehicle() and IsValid(parentVehicle)
	and parentVehicle.cwItemTable) then
		if (parentVehicle:GetDriver() == player) then
			if (data == "unlock") then
				parentVehicle.cwIsLocked = false;
				parentVehicle:EmitSound("doors/door_latch3.wav");
				parentVehicle:Fire("unlock", "", 0);
			elseif (data == "lock") then
				parentVehicle.cwIsLocked = true;
				parentVehicle:EmitSound("doors/door_latch3.wav");
				parentVehicle:Fire("lock", "", 0);
			elseif (data == "horn") then
				if (parentVehicle.cwItemTable.PlayHornSound) then
					parentVehicle.cwItemTable:PlayHornSound(player, parentVehicle);
				elseif (parentVehicle.cwItemTable("hornSound")) then
					parentVehicle:EmitSound(parentVehicle.cwItemTable("hornSound"));
				end;
			end;
		end;
	end;
end);

--[[
	Add the correct seat for the vehicles with the rollercoaster
	animation.
--]]

-- A function to handle the roller coaster animation.
local function HandleRollercoasterAnimation(vehicle, player)
	return player:SelectWeightedSequence(ACT_GMOD_SIT_ROLLERCOASTER);
end;

list.Set("Vehicles", "Seat_Jeep", { 	
	Name = "Jeep Seat",
	Model = "models/nova/jeep_seat.mdl",
	Class = "prop_vehicle_prisoner_pod",
	Author = "Nova[X]",
	Members = {
		HandleAnimation = HandleRollercoasterAnimation,
	},
	Category = "Half-Life 2",
	KeyValues = {
		vehiclescript = "scripts/vehicles/prisoner_pod.txt",
		limitview = "0"
	},
	Information = "Classic Jeep passenger Seat",
	CustomExits = { Vector(0, -50, 0), Vector(50, 0, 0), Vector(-50, 0, 0), Vector(0, 50, 0), Vector(0, 0, 50), Vector(0, 0, -50) },
});

--[[
	The schema must be registered so that the kernel information
	can be included (entities, effects, weapons, etc). This must
	be done at the end of the init.lua and cl_init.lua files.
--]]

Schema:Register();