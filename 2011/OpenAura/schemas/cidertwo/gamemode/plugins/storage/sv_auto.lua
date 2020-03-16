--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PLUGIN = PLUGIN;

openAura:IncludePrefixed("sh_auto.lua");

openAura.config:Add("max_locker_weight", 60);

openAura.hint:Add("Wire", "You can wire transfer money by using the command $command_prefix$wire.");
openAura.hint:Add("Wire ID", "You can set your wire transfer number by using the command $command_prefix$wireid.");

openAura:HookDataStream("ContainerPassword", function(player, data)
	local password = data[1];
	local entity = data[2];
	
	if ( IsValid(entity) ) then
		if ( openAura.entity:IsPhysicsEntity(entity) ) then
			local model = string.lower( entity:GetModel() );
			
			if ( PLUGIN.containers[model] ) then
				local containerWeight = PLUGIN.containers[model][1];
				
				if (entity.password == password) then
					PLUGIN:OpenContainer(player, entity, containerWeight);
				else
					openAura.player:Notify(player, "You have entered an incorrect password!");
				end;
			end;
		end;
	end;
end);

-- A function to get a random item.
function PLUGIN:GetRandomItem()
	if (#self.randomItems > 0) then
		local item = self.randomItems[ math.random(1, #self.randomItems) ];
		
		if (item) then
			if ( item[3] ) then
				local chance = (1 / self.highestCost) * math.min(item[3], self.highestCost * 0.99);
				
				if (math.random() >= chance) then
					return item;
				else
					return self:GetRandomItem();
				end;
			else
				return item;
			end;
		end;
	end;
end;

-- A function to save the storage.
function PLUGIN:SaveStorage()
	local storage = {};
	
	for k, v in pairs(self.storage) do
		if ( IsValid(v) ) then
			if (v.inventory and v.cash and (table.Count(v.inventory) > 0 or v.cash > 0 or v:GetNetworkedString("aura_StorageName") != "") ) then
				local startPosition = v:GetStartPosition();
				local physicsObject = v:GetPhysicsObject();
				local moveable;
				local model = v:GetModel();
				
				if (v:IsMapEntity() and startPosition) then
					model = nil;
				end;
				
				if ( IsValid(physicsObject) ) then
					moveable = physicsObject:IsMoveable();
				end;
				
				storage[#storage + 1] = {
					name = v:GetNetworkedString("aura_StorageName"),
					model = model,
					color = { v:GetColor() },
					angles = v:GetAngles(),
					position = v:GetPos(),
					moveable = moveable,
					message = v.message,
					password = v.password,
					cash = v.cash,
					inventory = v.inventory,
					startPosition = startPosition
				};
			end;
		end;
	end;
	
	openAura:SaveSchemaData("plugins/storage/"..game.GetMap(), storage);
end;

-- A function to load the storage.
function PLUGIN:LoadStorage()
	self.storage = {};
	
	local storage = openAura:RestoreSchemaData( "plugins/storage/"..game.GetMap() );
	
	for k, v in pairs(storage) do
		for k2, v2 in pairs(v.inventory) do
			local itemTable = openAura.item:Get(k2);
			
			if (!itemTable) then
				v.inventory[k2] = nil;
			end;
		end;
		
		if (!v.model) then
			local entity = ents.FindInSphere(v.startPosition or v.position, 16)[1];
			
			if ( IsValid(entity) and entity:IsMapEntity() ) then
				self.storage[entity] = entity;
				
				entity.inventory = v.inventory;
				entity.cash = v.cash;
				entity.password = v.password;
				entity.message = v.message;
				
				if ( IsValid( entity:GetPhysicsObject() ) ) then
					if (!v.moveable) then
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
					entity:SetColor( unpack(v.color) );
				end;
				
				if (v.name and v.name != "") then
					entity:SetNetworkedString("aura_StorageName", v.name);
				end;
			end;
		else
			local entity = ents.Create("prop_physics");
			
			entity:SetAngles(v.angles);
			entity:SetModel(v.model);
			entity:SetPos(v.position);
			entity:Spawn();
			
			if ( IsValid( entity:GetPhysicsObject() ) ) then
				if (!v.moveable) then
					entity:GetPhysicsObject():EnableMotion(false);
				end;
			end;
			
			if (v.color) then
				entity:SetColor( unpack(v.color) );
			end;
			
			if (v.name and v.name != "") then
				entity:SetNetworkedString("aura_StorageName", v.name);
			end;
			
			self.storage[entity] = entity;
			
			entity.inventory = v.inventory;
			entity.cash = v.cash;
			entity.password = v.password;
			entity.message = v.message;
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
	
	openAura:SaveSchemaData("plugins/personal/"..game.GetMap(), personalStorage);
end;

-- A function to load the personal storage.
function PLUGIN:LoadPersonalStorage()
	self.personalStorage = {};
	
	local personalStorage = openAura:RestoreSchemaData( "plugins/personal/"..game.GetMap() );
	
	for k, v in pairs(personalStorage) do
		local data = {
			position = v.position,
			angles = v.angles,
			isATM = v.isATM
		};
		
		if (v.isATM) then
			data.entity = ents.Create("aura_atm");
		else
			data.entity = ents.Create("aura_locker");
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
	
	if (entity:GetClass() == "aura_locker") then
		cash = 0;
		weight = openAura.config:Get("max_locker_weight"):Get();
		inventory = player:GetCharacterData("lockerstorage");
	elseif (entity:GetClass() == "aura_atm") then
		cash = player:GetCharacterData("lockercash");
		name = "ATM";
		weight = openAura.config:Get("max_locker_weight"):Get() * 4;
		inventory = {};
	else
		local model = string.lower( entity:GetModel() );
		
		if (!entity.inventory) then
			self.storage[entity] = entity;
			
			entity.inventory = {};
		end;
		
		if (!entity.cash) then
			entity.cash = 0;
		end;
		
		if ( self.containers[model] ) then
			name = self.containers[model][2];
		else
			name = "Container";
		end;
		
		inventory = entity.inventory;
		cash = entity.cash;
		
		if (!weight) then
			weight = 8;
		end;
	end;
	
	if (entity:GetNetworkedString("name") != "") then
		name = entity:GetNetworkedString("name");
	end;
	
	if (entity.message) then
		umsg.Start("aura_StorageMessage", player);
			umsg.Entity(entity);
			umsg.String(entity.message);
		umsg.End();
	end;
	
	openAura.player:OpenStorage( player, {
		name = name,
		cash = cash,
		weight = weight,
		entity = entity,
		distance = 192,
		inventory = inventory,
		noCashWeight = true,
		OnGive = function(player, storageTable, itemTable)
			if (player:GetCharacterData("clothes") == itemTable.index) then
				if ( !player:HasItem(itemTable.index) ) then
					player:SetCharacterData("clothes", nil);
					
					itemTable:OnChangeClothes(player, false);
				end;
			end;
		end,
		CanGive = function(player, storageTable, item)
			if (storageTable.entity:GetClass() == "aura_atm") then
				return false;
			end;
		end,
		CanTake = function(player, storageTable, item)
			if (storageTable.entity:GetClass() == "aura_atm") then
				return false;
			end;
		end,
		OnGiveCash = function(player, storageTable, cash)
			if (storageTable.entity:GetClass() == "aura_atm") then
				player:SetCharacterData("lockercash", storageTable.cash);
			else
				storageTable.entity.cash = storageTable.cash;
			end;
		end,
		OnTakeCash = function(player, storageTable, cash)
			if (storageTable.entity:GetClass() == "aura_atm") then
				player:SetCharacterData("lockercash", storageTable.cash);
			else
				storageTable.entity.cash = storageTable.cash;
			end;
		end,
		CanGiveCash = function(player, storageTable, cash)
			if (storageTable.entity:GetClass() == "aura_locker") then
				return false;
			end;
		end,
		CanTakeCash = function(player, storageTable, cash)
			if (storageTable.entity:GetClass() == "aura_locker") then
				return false;
			end;
		end
	} );
end;