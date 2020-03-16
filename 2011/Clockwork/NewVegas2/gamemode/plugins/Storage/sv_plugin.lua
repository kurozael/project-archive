--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

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
function PLUGIN:GetRandomItem(uniqueID)
	if (uniqueID) then
		uniqueID = string.lower(uniqueID);
	end;
	
	if (#self.randomItems <= 0) then
		return;
	end;
	
	local randomItem = self.randomItems[
		math.random(1, #self.randomItems)
	];
	
	if (randomItem) then
		local itemTable = Clockwork.item:FindByID(randomItem[1]);
		
		if (!uniqueID or string.find(string.lower(itemTable("category")), uniqueID)) then
			return randomItem;
		end;
	end;
	
	return self:GetRandomItem(uniqueID);
end;

-- A function to save the storage.
function PLUGIN:SaveStorage()
	local storage = {};
	
	for k, v in pairs(self.storage) do
		if (v.cwInventory and v.cwCash and (v.cwMessage or v.cwPassword
		or table.Count(v.cwInventory) > 0 or v.cwCash > 0
		or v:GetNetworkedString("Name") != "")) then
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
				cash = v.cwCash,
				model = model,
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

-- A function to open a container for a player.
function PLUGIN:OpenContainer(player, entity, weight)
	local inventory;
	local cash = 0;
	local model = string.lower(entity:GetModel());
	local name = "";
	
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
		weight = weight,
		entity = entity,
		distance = 192,
		cash = cash,
		inventory = inventory,
		OnGiveCash = function(player, storageTable, cash)
			storageTable.entity.cwCash = storageTable.cash;
		end,
		OnTakeCash = function(player, storageTable, cash)
			storageTable.entity.cwCash = storageTable.cash;
		end
	});
end;