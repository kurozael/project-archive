--[[
Name: "sh_config.lua".
Product: "nexus".
--]]

nexus.config = {};
nexus.config.indexes = {};
nexus.config.stored = {};
nexus.config.cache = {};
nexus.config.class = {};
nexus.config.map = {};

-- A function to create a new config object.
function nexus.config.class:Create(key)
	local config = NEXUS:NewMetaTable(nexus.config.class);
	
	config.data = nexus.config.stored[key];
	config.key = key;
	
	return config;
end;

-- A function to check if the config is valid.
function nexus.config.class:IsValid()
	return self.data != nil;
end;

-- A function to query the config.
function nexus.config.class:Query(key, default)
	if (self.data and self.data[key] != nil) then
		return self.data[key];
	else
		return default;
	end;
end;

-- A function to get the config's value as a boolean.
function nexus.config.class:GetBoolean(default)
	if (self.data) then
		return (self.data.value == true or self.data.value == "true"
		or self.data.value == "yes" or self.data.value == "1" or self.data.value == 1);
	elseif (default != nil) then
		return default;
	else
		return false;
	end;
end;

-- A function to get a config's value as a number.
function nexus.config.class:GetNumber(default)
	if (self.data) then
		return tonumber(self.data.value) or default or 0;
	else
		return default or 0;
	end;
end;

-- A function to get a config's value as a string.
function nexus.config.class:GetString(default)
	if (self.data) then
		return tostring(self.data.value);
	else
		return default or "";
	end;
end;

-- A function to get a config's default value.
function nexus.config.class:GetDefault(default)
	if (self.data) then
		return self.data.default;
	else
		return default;
	end;
end;

-- A function to get the config's next value.
function nexus.config.class:GetNext(default)
	if (self.data and self.data.nextValue != nil) then
		return self.data.nextValue;
	else
		return default;
	end;
end;

-- A function to get the config's value.
function nexus.config.class:Get(default)
	if (self.data and self.data.value != nil) then
		return self.data.value;
	else
		return default;
	end;
end;

-- A function to set whether the config has initialized.
function nexus.config.SetInitialized(initalized)
	nexus.config.initialized = initalized;
end;

-- A function to get whether the config has initialized.
function nexus.config.HasInitialized()
	return nexus.config.initialized;
end;

-- A function to get whether a config value is valid.
function nexus.config.IsValidValue(value)
	return type(value) == "string" or type(value) == "number" or type(value) == "boolean";
end;

-- A function to share a config key.
function nexus.config.ShareKey(key)
	local shortCRC = NEXUS:GetShortCRC(key);
	
	if (SERVER) then
		nexus.config.indexes[key] = shortCRC;
	else
		nexus.config.indexes[shortCRC] = key;
	end;
end;

-- A function to get the stored config.
function nexus.config.GetStored()
	return nexus.config.stored;
end;

-- A function to import a config file.
function nexus.config.Import(fileName)
	local data = g_File.Read(fileName);
	
	if (!data or data == "") then
		return;
	end;
	
	for k, v in ipairs( NEXUS:ExplodeString("\n", data) ) do
		if ( v != "" and !string.find(v, "^%s$") ) then
			if ( !string.find(v, "^%[.+%]$") and !string.find(v, "^//") ) then
				local class, key, value = string.match(v, "^(.-)%s(.-)%s=%s(.+);");
				
				if (class and key and value) then
					if ( string.find(class, "boolean") ) then
						value = (value == "true" or value == "yes" or value == "1");
					elseif ( string.find(class, "number") ) then
						value = tonumber(value);
					end;
					
					local forceSet = string.find(class, "force") != nil;
					local isGlobal = string.find(class, "global") != nil;
					local isShared = string.find(class, "shared") != nil;
					local isStatic = string.find(class, "static") != nil;
					local isPrivate = string.find(class, "private") != nil;
					local needsRestart = string.find(class, "restart") != nil;
					
					if (value) then
						local config = nexus.config.Get(key);
						
						if ( !config:IsValid() ) then
							nexus.config.Add(key, value, isShared, isGlobal, isStatic, isPrivate, needsRestart);
						else
							config:Set(value, nil, forceSet);
						end;
					end;
				end;
			end;
		end;
	end;
end;

-- A function to parse config keys.
function nexus.config.Parse(text)
	for key in string.gmatch(text, "%$(.-)%$") do
		local value = nexus.config.Get(key):Get();
		
		if (value != nil) then
			text = string.Replace( text, "$"..key.."$", tostring(value) );
		end;
	end;
	
	return text;
end;

-- A function to get a config object.
function nexus.config.Get(key)
	if ( !nexus.config.cache[key] ) then
		local configObject = nexus.config.class:Create(key);
		
		if (configObject.data) then
			nexus.config.cache[key] = configObject;
		end;
		
		return configObject;
	else
		return nexus.config.cache[key];
	end;
end;

if (SERVER) then
	function nexus.config.Save(fileName, configTable)
		if (configTable) then
			local config = { global = {}, schema = {} };
			
			for k, v in pairs(configTable) do
				if (!v.map and !v.temporary) then
					local value = v.value;
					
					if (v.nextValue != nil) then
						value = v.nextValue;
					end;
					
					if (value != v.default) then
						if (v.isGlobal) then
							config.global[k] = {
								value = value,
								default = v.default
							};
						else
							config.schema[k] = {
								value = value,
								default = v.default
							};
						end;
					end;
				end;
			end;
			
			NEXUS:SaveNexusData(fileName, config.global);
			NEXUS:SaveSchemaData(fileName, config.schema);
		else
			NEXUS:DeleteNexusData(fileName);
			NEXUS:DeleteSchemaData(fileName);
		end;
	end;
	
	-- A function to send the config to a player.
	function nexus.config.Send(player, key)
		if ( player and player:IsBot() ) then
			nexus.mount.Call("PlayerConfigInitialized", player);
				player.configInitialized = true;
			return;
		end;
		
		if (!player) then
			player = g_Player.GetAll();
		else
			player = {player};
		end;
		
		if (key) then
			if ( nexus.config.stored[key] ) then
				local value = nexus.config.stored[key].value;
				
				if (nexus.config.stored[key].isShared) then
					if ( nexus.config.indexes[key] ) then
						key = nexus.config.indexes[key];
					end;
					
					NEXUS:StartDataStream( player, "Config", { [key] = value } );
				end;
			end;
		else
			local config = {};
			
			for k, v in pairs(nexus.config.stored) do
				if (v.isShared) then
					local index = nexus.config.indexes[k];
					
					if (index) then
						config[index] = v.value;
					else
						config[k] = v.value;
					end;
				end;
			end;
			
			NEXUS:StartDataStream(player, "Config", config);
		end;
	end;

	-- A function to load config from a g_File.
	function nexus.config.Load(fileName, loadGlobal)
		if (!fileName) then
			local configClasses = {"default", "map"};
			local configTable;
			local map = string.lower( game.GetMap() );
			
			if (loadGlobal) then
				nexus.config.global = {
					default = nexus.config.Load("config", true),
					map = nexus.config.Load("config/"..map, true)
				};
				
				configTable = nexus.config.global;
			else
				nexus.config.schema = {
					default = nexus.config.Load("config"),
					map = nexus.config.Load("config/"..map)
				};
				
				configTable = nexus.config.schema;
			end;
			
			for k, v in pairs(configClasses) do
				for k2, v2 in pairs( configTable[v] ) do
					local configObject = nexus.config.Get(k2);
					
					if ( configObject:IsValid() ) then
						if (configObject:Query("default") == v2.default) then
							if (v == "map") then
								configObject:Set(v2.value, map, true);
							else
								configObject:Set(v2.value, nil, true);
							end;
						end;
					end;
				end;
			end;
		elseif (loadGlobal) then
			return NEXUS:RestoreNexusData(fileName);
		else
			return NEXUS:RestoreSchemaData(fileName);
		end;
	end;
	
	-- A function to add a new config key.
	function nexus.config.Add(key, value, isShared, isGlobal, isStatic, isPrivate, needsRestart)
		if ( nexus.config.IsValidValue(value) ) then
			if ( !nexus.config.stored[key] ) then
				nexus.config.stored[key] = {
					needsRestart = needsRestart,
					isPrivate = isPrivate,
					isShared = isShared,
					isStatic = isStatic,
					isGlobal = isGlobal,
					default = value,
					value = value
				};
				
				local configClasses = {"global", "schema"};
				local configObject = nexus.config.class:Create(key);
				
				if (!isGlobal) then
					table.remove(configClasses, 1);
				end;
				
				for k, v in pairs(configClasses) do
					local configTable = nexus.config[v];
					local map = string.lower( game.GetMap() );
					
					if ( configTable and configTable.default and configTable.default[key] ) then
						if (configObject:Query("default") == configTable.default[key].default) then
							configObject:Set(configTable.default[key].value, nil, true);
						end;
					end;
					
					if ( configTable and configTable.map and configTable.map[key] ) then
						if (configObject:Query("default") == configTable.map[key].default) then
							configObject:Set(configTable.map[key].value, map, true);
						end;
					end;
				end;
				
				nexus.config.Send(nil, key);
				
				return configObject;
			end;
		end;
	end;
	
	-- A function to set the config's value.
	function nexus.config.class:Set(value, map, forceSet, temporary)
		if (map) then
			map = string.lower(map);
		end;
		
		if (tostring(value) == "-1.#IND") then
			value = 0;
		end;
		
		if ( self.data and nexus.config.IsValidValue(value) ) then
			if (self.data.value != value) then
				local previousValue = self.data.value;
				local default = (value == "!default");
				
				if (!default) then
					if (type(self.data.value) == "number") then
						value = tonumber(value) or self.data.value;
					elseif (type(self.data.value) == "boolean") then
						value = (value == true or value == "true"
						or value == "yes" or value == "1" or value == 1);
					end;
				else
					value = self.data.default;
				end;
				
				if (!self.data.isStatic or forceSet) then
					if (!map or string.lower( game.GetMap() ) == map) then
						if (!nexus.config.HasInitialized() or !self.data.needsRestart or forceSet) then
							self.data.value = value;
							
							if (self.data.isShared) then
								nexus.config.Send(nil, self.key);
							end;
						end;
					end;
					
					self.data.temporary = temporary;
					self.data.forceSet = forceSet;
					self.data.map = map;
					
					if ( self.data.needsRestart and nexus.config.HasInitialized() ) then
						if (self.data.forceSet) then
							self.data.nextValue = nil;
						else
							self.data.nextValue = value;
						end;
					end;
					
					if ( !self.data.map and !self.data.temporary and nexus.config.HasInitialized() ) then
						nexus.config.Save("config", nexus.config.stored);
					end;
					
					if (self.data.map) then
						if (default) then
							if ( nexus.config.map[self.data.map] ) then
								nexus.config.map[self.data.map][self.key] = nil;
							end;
						else
							if ( !nexus.config.map[self.data.map] ) then
								nexus.config.map[self.data.map] = {};
							end;
							
							nexus.config.map[self.data.map][self.key] = {
								default = self.data.default,
								global = self.data.isGlobal,
								value = value
							};
						end;
						
						if ( !self.data.temporary and nexus.config.HasInitialized() ) then
							nexus.config.Save( "config/"..self.data.map, nexus.config.map[self.data.map] );
						end;
					end;
				end;
				
				if ( self.data.value != previousValue and nexus.config.HasInitialized() ) then
					nexus.mount.Call("NexusConfigChanged", self.key, self.data, previousValue, self.data.value);
				end;
			end;
			
			return value;
		end;
	end;
	
	NEXUS:HookDataStream("ConfigInitialized", function(player, data)
		if ( !player:HasConfigInitialized() ) then
			player:SetConfigInitialized(true);
			
			nexus.mount.Call("PlayerConfigInitialized", player);
		end;
	end);
else
	nexus.config.overwatch = {};
	
	NEXUS:HookDataStream("Config", function(data)
		for k, v in pairs(data) do
			if ( nexus.config.indexes[k] ) then
				k = nexus.config.indexes[k];
			end;
			
			if ( !nexus.config.stored[k] ) then
				nexus.config.Add(k, v);
			else
				nexus.config.Get(k):Set(v);
			end;
		end;
		
		if ( !nexus.config.HasInitialized() ) then
			nexus.config.SetInitialized(true);
			
			for k, v in pairs(nexus.config.stored) do
				nexus.mount.Call("NexusConfigInitialized", k, v.value);
			end;
			
			if ( IsValid(g_LocalPlayer) and !nexus.config.HasSentInitialized() ) then
				NEXUS:StartDataStream("ConfigInitialized", true);
				
				nexus.config.SetSentInitialized(true);
			end;
		end;
	end);
	
	-- A function to get whether the config has sent initialized.
	function nexus.config.SetSentInitialized(sentInitialized)
		nexus.config.sentInitialized = sentInitialized;
	end;

	-- A function to get whether the config has sent initialized.
	function nexus.config.HasSentInitialized()
		return nexus.config.sentInitialized;
	end;
	
	-- A function to set a config key's overwatch.
	function nexus.config.SetOverwatch(key, help, minimum, maximum, decimals)
		nexus.config.overwatch[key] = {
			decimals = decimals or 0,
			maximum = maximum or 100,
			minimum = minimum or 0,
			help = help or "No help was provided for this config key!"
		};
	end;
	
	-- A function to get a config key's overwatch.
	function nexus.config.GetOverwatch(key)
		return nexus.config.overwatch[key];
	end;
	
	-- A function to add a new config key.
	function nexus.config.Add(key, value)
		if ( nexus.config.IsValidValue(value) ) then
			if ( !nexus.config.stored[key] ) then
				nexus.config.stored[key] = {
					default = value,
					value = value
				};
				
				return nexus.config.class:Create(key);
			end;
		end;
	end;
	
	-- A function to set the config's value.
	function nexus.config.class:Set(value)
		if (tostring(value) == "-1.#IND") then
			value = 0;
		end;
		
		if ( self.data and nexus.config.IsValidValue(value) ) then
			if (self.data.value != value) then
				local previousValue = self.data.value;
				local default = (value == "!default");
				
				if (!default) then
					if (type(self.data.value) == "number") then
						value = tonumber(value) or self.data.value;
					elseif (type(self.data.value) == "boolean") then
						value = (value == true or value == "true"
						or value == "yes" or value == "1" or value == 1);
					elseif ( type(self.data.value) != type(value) ) then
						return;
					end;
					
					self.data.value = value;
				else
					self.data.value = self.data.default;
				end;
				
				if ( self.data.value != previousValue and nexus.config.HasInitialized() ) then
					nexus.mount.Call("NexusConfigChanged", self.key, self.data, previousValue, self.data.value);
				end;
			end;
			
			return self.data.value;
		end;
	end;
end;