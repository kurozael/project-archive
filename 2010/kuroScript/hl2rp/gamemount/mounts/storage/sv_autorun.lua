--[[
Name: "sv_autorun.lua".
Product: "HL2 RP".
--]]

local MOUNT = MOUNT;

-- Include some prefixed files.
kuroScript.frame:IncludePrefixed("sh_autorun.lua");

-- The maximum weight that lockers can hold (kilograms).
kuroScript.config.Add("max_locker_weight", 20);

-- Hook a data stream.
datastream.Hook("ks_ContainerPassword", function(player, handler, uniqueID, rawData, procData)
	MOUNT:ShowTeam(player, procData);
end);

-- Hook a data stream.
datastream.Hook("ks_PlayersLocker", function(player, handler, uniqueID, rawData, procData)
	if ( kuroScript.game:PlayerIsCombine(player) ) then
		local entity = player:GetEyeTraceNoCursor().Entity;
		
		-- Check if a statement is true.
		if (ValidEntity(procData) and ValidEntity(entity) and entity:GetClass() == "ks_locker") then
			if (entity:GetPos():Distance( player:GetShootPos() ) <= 192) then
				if (procData == player or procData:GetSharedVar("ks_Tied") == 2) then
					local inventory = procData:GetCharacterData("locker");
					local name = "Locker";
					
					-- Check if a statement is true.
					if (procData != player) then
						name = procData:Name().."'s Locker";
					end;
					
					-- Open storage for the player.
					kuroScript.player.OpenStorage( player, {
						name = name,
						weight = kuroScript.config.Get("max_locker_weight"):Get(),
						entity = entity,
						distance = 192,
						currency = procData:GetCharacterData("lockercur"),
						inventory = inventory,
						ShouldClose = function(player, storage)
							if ( ( !ValidEntity(procData) or procData:GetSharedVar("ks_Tied") != 2 or !procData:Alive() ) and procData != player ) then
								return true;
							end;
						end
					} );
				end;
			end;
		end;
	end;
end);

-- A function to get a random item.
function MOUNT:GetRandomItem()
	if (#self.randomItems > 0) then
		local item = self.randomItems[ math.random(1, #self.randomItems) ];
		
		-- Check if a statement is true.
		if (item) then
			if ( item[3] ) then
				local chance = (1 / self.highestCost) * math.min(item[3], self.highestCost * 0.99);
				
				-- Check if a statement is true.
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
function MOUNT:SaveStorage()
	local storage = {};
	local k, v;
	
	-- Loop through each value in a table.
	for k, v in pairs(self.storage) do
		if ( ValidEntity(v) ) then
			if (v._Inventory and (table.Count(v._Inventory) > 0 or v:GetNetworkedString("ks_StorageName") != "") ) then
				local startPosition = v:GetStartPosition();
				local physicsObject = v:GetPhysicsObject();
				local moveable;
				local model = v:GetModel();
				
				-- Check if a statement is true.
				if (v:IsMapEntity() and startPosition) then
					model = nil;
				end;
				
				-- Check if a statement is true.
				if ( ValidEntity(physicsObject) ) then
					moveable = physicsObject:IsMoveable();
				end;
				
				-- Set some information.
				storage[#storage + 1] = {
					name = v:GetNetworkedString("ks_StorageName"),
					model = model,
					color = { v:GetColor() },
					angles = v:GetAngles(),
					position = v:GetPos(),
					moveable = moveable,
					password = v._Password,
					currency = v._Currency,
					inventory = v._Inventory,
					startPosition = startPosition
				};
			end;
		end;
	end;
	
	-- Save some game data.
	kuroScript.frame:SaveGameData("mounts/storage/"..game.GetMap(), storage);
end;

-- A function to load the storage.
function MOUNT:LoadStorage()
	self.storage = {};
	
	-- Set some information.
	local storage = kuroScript.frame:RestoreGameData( "mounts/storage/"..game.GetMap() );
	local k2, v2;
	local k, v;
	
	-- Loop through each value in a table.
	for k, v in pairs(storage) do
		for k2, v2 in pairs(v.inventory) do
			local itemTable = kuroScript.item.Get(k2);
			
			-- Check if a statement is true.
			if (!itemTable) then
				v.inventory[k2] = nil;
			end;
		end;
		
		-- Check if a statement is true.
		if (!v.model) then
			local entity = ents.FindInSphere(v.startPosition or v.position, 16)[1];
			
			-- Check if a statement is true.
			if ( ValidEntity(entity) and entity:IsMapEntity() ) then
				self.storage[entity] = entity;
				
				-- Set some information.
				entity._Inventory = v.inventory;
				entity._Currency = v.currency;
				entity._Password = v.password;
				
				-- Check if a statement is true.
				if ( ValidEntity( entity:GetPhysicsObject() ) ) then
					if (!v.moveable) then
						entity:GetPhysicsObject():EnableMotion(false);
					else
						entity:GetPhysicsObject():EnableMotion(true);
					end;
				end;
				
				-- Check if a statement is true.
				if (v.angles) then
					entity:SetAngles(v.angles);
					entity:SetPos(v.position);
				end;
				
				-- Check if a statement is true.
				if (v.color) then
					entity:SetColor( unpack(v.color) );
				end;
				
				-- Check if a statement is true.
				if (v.name and v.name != "") then
					entity:SetNetworkedString("ks_StorageName", v.name);
				end;
			end;
		else
			local entity = ents.Create("prop_physics");
			
			-- Set some information.
			entity:SetAngles(v.angles);
			entity:SetModel(v.model);
			entity:SetPos(v.position);
			entity:Spawn();
			
			-- Check if a statement is true.
			if ( ValidEntity( entity:GetPhysicsObject() ) ) then
				if (!v.moveable) then
					entity:GetPhysicsObject():EnableMotion(false);
				end;
			end;
			
			-- Check if a statement is true.
			if (v.color) then
				entity:SetColor( unpack(v.color) );
			end;
			
			-- Check if a statement is true.
			if (v.name and v.name != "") then
				entity:SetNetworkedString("ks_StorageName", v.name);
			end;
			
			-- Set some information.
			self.storage[entity] = entity;
			
			-- Set some information.
			entity._Inventory = v.inventory;
			entity._Currency = v.currency;
			entity._Password = v.password;
		end;
	end;
end;

-- A function to save the lockers.
function MOUNT:SaveLockers()
	local lockers = {};
	
	-- Loop through each value in a table.
	for k, v in pairs(self.lockers) do
		lockers[#lockers + 1] = {
			position = v.position,
			angles = v.angles
		};
	end;
	
	-- Save some game data.
	kuroScript.frame:SaveGameData("mounts/lockers/"..game.GetMap(), lockers);
end;

-- A function to load the lockers.
function MOUNT:LoadLockers()
	self.lockers = {};
	
	-- Set some information.
	local lockers = kuroScript.frame:RestoreGameData( "mounts/lockers/"..game.GetMap() );
	
	-- Loop through each value in a table.
	for k, v in pairs(lockers) do
		local data = {
			position = v.position,
			angles = v.angles
		};
		
		-- Set some information.
		data.entity = ents.Create("ks_locker");
		data.entity:SetAngles(data.angles);
		data.entity:SetPos(data.position);
		data.entity:Spawn();
		
		-- Disable the entity's motion.
		data.entity:GetPhysicsObject():EnableMotion(false);
		
		-- Set some information.
		self.lockers[#self.lockers + 1] = data;
	end;
end;

-- A function to open a container for a player.
function MOUNT:OpenContainer(player, entity, weight)
	local inventory;
	local currency = 0;
	local name = "Locker";
	local k, v;
	
	-- Check if a statement is true.
	if (entity:GetClass() == "ks_locker") then
		inventory = player:GetCharacterData("locker");
		currency = player:GetCharacterData("lockercur");
	else
		local model = string.lower( entity:GetModel() );
		
		-- Check if a statement is true.
		if (!entity._Inventory) then
			self.storage[entity] = entity;
			
			-- Set some information.
			entity._Inventory = {};
		end;
		
		-- Check if a statement is true.
		if (!entity._Currency) then
			entity._Currency = 0;
		end;
		
		-- Loop through each value in a table.
		if ( self.containers[model] ) then
			name = self.containers[model][2];
		else
			name = "Container";
		end;
		
		-- Set some information.
		inventory = entity._Inventory;
		currency = entity._Currency;
	end;
	
	-- Check if a statement is true.
	if (entity:GetNetworkedString("ks_StorageName") != "") then
		name = entity:GetNetworkedString("ks_StorageName");
	end;
	
	-- Open storage for the player.
	kuroScript.player.OpenStorage( player, {
		name = name,
		weight = weight or kuroScript.config.Get("max_locker_weight"):Get(),
		entity = entity,
		distance = 192,
		currency = currency,
		inventory = inventory,
		OnGiveCurrency = function(player, storageTable, currency)
			if (storageTable.entity:GetClass() == "ks_locker") then
				player:SetCharacterData("lockercur", storageTable.currency);
			else
				storageTable.entity._Currency = storageTable.currency;
			end;
		end,
		OnTakeCurrency = function(player, storageTable, currency)
			if (storageTable.entity:GetClass() == "ks_locker") then
				player:SetCharacterData("lockercur", storageTable.currency);
			else
				storageTable.entity._Currency = storageTable.currency;
			end;
		end
	} );
end;