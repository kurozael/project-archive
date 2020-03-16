--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

Clockwork.config:Add("max_locker_weight", 60);

Clockwork.hint:Add("Wire", "You can wire transfer money by using the command $command_prefix$wire.");
Clockwork.hint:Add("Wire ID", "You can set your wire transfer number by using the command $command_prefix$wireid.");

Clockwork:HookDataStream("ContainerPassword", function(player, data)
	local password = data[1];
	local entity = data[2];
	local PLUGIN = Clockwork.plugin:FindByID("Storage");
	
	if (IsValid(entity) and Clockwork.entity:IsPhysicsEntity(entity)) then
		local model = string.lower(entity:GetModel());
		
		if (PLUGIN.containers[model]) then
			local containerWeight = PLUGIN.containers[model][1];
			
			if (entity.cwPassword == password) then
				PLUGIN:OpenContainer(player, entity, containerWeight);
			else
				Clockwork.player:Notify(player, "You have entered an incorrect password!");
			end;
		end;
	end;
end);

-- A function to get a random item.
function PLUGIN:GetRandomItem()
	if (#self.randomItems <= 0) then
		return;
	end;
	
	local randomItem = self.randomItems[
		math.random(1, #self.randomItems)
	];
	
	if (!randomItem) then
		return;
	end;
	
	if (randomItem[3]) then
		local chance = (1 / self.highestCost) * math.min(randomItem[3], self.highestCost * 0.99);
		
		if (math.random() >= chance) then
			return randomItem;
		else
			return self:GetRandomItem();
		end;
	else
		return randomItem;
	end;
end;

-- A function to save the storage.
function PLUGIN:SaveStorage()
	local storage = {};
	
	for k, v in pairs(self.storage) do
		if (IsValid(v)) then
			if (v.cwInventory and v.cwCash and (table.Count(v.cwInventory) > 0 or v.cwCash > 0 or v:GetNetworkedString("Name") != "")) then
				local startPos = v:GetStartPosition();
				local physicsObject = v:GetPhysicsObject();
				local bMoveable = nil;
				local model = v:GetModel();
				
				if (v:IsMapEntity() and startPos) then
					model = nil;
				end;
				
				if (IsValid(physicsObject)) then
					bMoveable = physicsObject:IsMoveable();
				end;
				
				storage[#storage + 1] = {
					name = v:GetNetworkedString("Name"),
					model = model,
					cash = v.cwCash,
					color = { v:GetColor() },
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
	end;
	
	Clockwork:SaveSchemaData("plugins/storage/"..game.GetMap(), storage);
end;

-- A function to load the storage.
function PLUGIN:LoadStorage()
	local storage = Clockwork:RestoreSchemaData("plugins/storage/"..game.GetMap());
	self.storage = {};
	
	for k, v in pairs(storage) do
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
			
			entity.inventory = Clockwork.inventory:ToLoadable(v.inventory);
			entity.password = v.cwPassword;
			entity.message = v.cwMessage;
			entity.cash = v.cwCash;
		end;
	end;
end;

-- A function to save the personal storage.
function PLUGIN:SavePersonalStorage()
	local personalStorage = {};
	
	for k, v in pairs(self.personalStorage) do
		personalStorage[#personalStorage + 1] = {
			position = v.position,
			angles = v.angles,
			isATM = v.isATM
		};
	end;
	
	Clockwork:SaveSchemaData("plugins/personal/"..game.GetMap(), personalStorage);
end;

-- A function to load the personal storage.
function PLUGIN:LoadPersonalStorage()
	self.personalStorage = {};
	
	local personalStorage = Clockwork:RestoreSchemaData("plugins/personal/"..game.GetMap());
	
	for k, v in pairs(personalStorage) do
		local data = {
			position = v.position,
			angles = v.angles,
			isATM = v.isATM
		};
		
		if (v.isATM) then
			data.entity = ents.Create("cw_cashmachine");
		else
			data.entity = ents.Create("cw_locker");
		end;
		
		data.entity:SetAngles(data.angles);
		data.entity:SetPos(data.position);
		data.entity:Spawn();
		
		data.entity:GetPhysicsObject():EnableMotion(false);
		
		self.personalStorage[#self.personalStorage + 1] = data;
	end;
end;

-- A function to open a container for a player.
function PLUGIN:OpenContainer(player, entity, weight)
	local inventory;
	local cash = 0;
	local name = "Locker";
	
	if (entity:GetClass() == "cw_locker") then
		cash = 0;
		weight = Clockwork.config:Get("max_locker_weight"):Get();
		inventory = player:GetCharacterData("LockerItems");
	elseif (entity:GetClass() == "cw_cashmachine") then
		cash = player:GetCharacterData("BankCash");
		name = "ATM";
		weight = Clockwork.config:Get("max_locker_weight"):Get() * 4;
		inventory = {};
	else
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
		noCashWeight = true,
		CanGiveItem = function(player, storageTable, itemTable)
			if (storageTable.entity:GetClass() == "cw_cashmachine") then
				return false;
			end;
		end,
		CanTakeItem = function(player, storageTable, itemTable)
			if (storageTable.entity:GetClass() == "cw_cashmachine") then
				return false;
			end;
		end,
		OnGiveCash = function(player, storageTable, cash)
			if (storageTable.entity:GetClass() == "cw_cashmachine") then
				player:SetCharacterData("BankCash", storageTable.cash);
			else
				storageTable.entity.cwCash = storageTable.cash;
			end;
		end,
		OnTakeCash = function(player, storageTable, cash)
			if (storageTable.entity:GetClass() == "cw_cashmachine") then
				player:SetCharacterData("BankCash", storageTable.cash);
			else
				storageTable.entity.cwCash = storageTable.cash;
			end;
		end,
		CanGiveCash = function(player, storageTable, cash)
			if (storageTable.entity:GetClass() == "cw_locker") then
				return false;
			end;
		end,
		CanTakeCash = function(player, storageTable, cash)
			if (storageTable.entity:GetClass() == "cw_locker") then
				return false;
			end;
		end
	});
end;