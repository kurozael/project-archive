--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

CloudScript.config = {};
CloudScript.config.indexes = {};
CloudScript.config.stored = {};
CloudScript.config.cache = {};
CloudScript.config.class = {};
CloudScript.config.map = {};

-- A function to create a new config object.
function CloudScript.config.class:Create(key)
	local config = CloudScript:NewMetaTable(CloudScript.config.class);
	
	config.data = CloudScript.config.stored[key];
	config.key = key;
	
	return config;
end;

-- A function to check if the config is valid.
function CloudScript.config.class:IsValid()
	return self.data != nil;
end;

-- A function to query the config.
function CloudScript.config.class:Query(key, default)
	if (self.data and self.data[key] != nil) then
		return self.data[key];
	else
		return default;
	end;
end;

-- A function to get the config's value as a boolean.
function CloudScript.config.class:GetBoolean(default)
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
function CloudScript.config.class:GetNumber(default)
	if (self.data) then
		return tonumber(self.data.value) or default or 0;
	else
		return default or 0;
	end;
end;

-- A function to get a config's value as a string.
function CloudScript.config.class:GetString(default)
	if (self.data) then
		return tostring(self.data.value);
	else
		return default or "";
	end;
end;

-- A function to get a config's default value.
function CloudScript.config.class:GetDefault(default)
	if (self.data) then
		return self.data.default;
	else
		return default;
	end;
end;

-- A function to get the config's next value.
function CloudScript.config.class:GetNext(default)
	if (self.data and self.data.nextValue != nil) then
		return self.data.nextValue;
	else
		return default;
	end;
end;

-- A function to get the config's value.
function CloudScript.config.class:Get(default)
	if (self.data and self.data.value != nil) then
		return self.data.value;
	else
		return default;
	end;
end;

-- A function to set whether the config has initialized.
function CloudScript.config:SetInitialized(initalized)
	self.initialized = initalized;
end;

-- A function to get whether the config has initialized.
function CloudScript.config:HasInitialized()
	return self.initialized;
end;

-- A function to get whether a config value is valid.
function CloudScript.config:IsValidValue(value)
	return type(value) == "string" or type(value) == "number" or type(value) == "boolean";
end;

-- A function to share a config key.
function CloudScript.config:ShareKey(key)
	local shortCRC = CloudScript:GetShortCRC(key);
	
	if (SERVER) then
		self.indexes[key] = shortCRC;
	else
		self.indexes[shortCRC] = key;
	end;
end;

-- A function to get the stored config.
function CloudScript.config:GetStored()
	return self.stored;
end;

-- A function to import a config file.
function CloudScript.config:Import(fileName)
	local data = _file.Read(fileName) or "";
	
	for k, v in ipairs( string.Explode("\n", data) ) do
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
						local config = self:Get(key);
						
						if ( !config:IsValid() ) then
							self:Add(key, value, isShared, isGlobal, isStatic, isPrivate, needsRestart);
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
function CloudScript.config:Parse(text)
	for key in string.gmatch(text, "%$(.-)%$") do
		local value = self:Get(key):Get();
		
		if (value != nil) then
			text = CloudScript:Replace( text, "$"..key.."$", tostring(value) );
		end;
	end;
	
	return text;
end;

-- A function to get a config object.
function CloudScript.config:Get(key)
	if ( !self.cache[key] ) then
		local configObject = self.class:Create(key);
		
		if (configObject.data) then
			self.cache[key] = configObject;
		end;
		
		return configObject;
	else
		return self.cache[key];
	end;
end;

if (SERVER) then
	function CloudScript.config:Save(fileName, configTable)
		if (configTable) then
			local config = { global = {}, schema = {} };
			
			for k, v in pairs(configTable) do
				if ( !v.map and !v.temporary and !string.find(k, "mysql_") ) then
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
			
			CloudScript:SaveCloudScriptData(fileName, config.global);
			CloudScript:SaveSchemaData(fileName, config.schema);
		else
			CloudScript:DeleteCloudScriptData(fileName);
			CloudScript:DeleteSchemaData(fileName);
		end;
	end;
	
	-- A function to send the config to a player.
	function CloudScript.config:Send(player, key)
		if ( player and player:IsBot() ) then
			CloudScript.plugin:Call("PlayerConfigInitialized", player);
				player.configInitialized = true;
			return;
		end;
		
		if (!player) then
			player = _player.GetAll();
		else
			player = {player};
		end;
		
		if (key) then
			if ( self.stored[key] ) then
				local value = self.stored[key].value;
				
				if (self.stored[key].isShared) then
					if ( self.indexes[key] ) then
						key = self.indexes[key];
					end;
					
					CloudScript:StartDataStream( player, "Config", { [key] = value } );
				end;
			end;
		else
			local config = {};
			
			for k, v in pairs(self.stored) do
				if (v.isShared) then
					local index = self.indexes[k];
					
					if (index) then
						config[index] = v.value;
					else
						config[k] = v.value;
					end;
				end;
			end;
			
			CloudScript:StartDataStream(player, "Config", config);
		end;
	end;

	-- A function to load config from a _file.
	function CloudScript.config:Load(fileName, loadGlobal)
		if (!fileName) then
			local configClasses = {"default", "map"};
			local configTable;
			local map = string.lower( game.GetMap() );
			
			if (loadGlobal) then
				self.global = {
					default = self:Load("config", true),
					map = self:Load("config/"..map, true)
				};
				
				configTable = self.global;
			else
				self.schema = {
					default = self:Load("config"),
					map = self:Load("config/"..map)
				};
				
				configTable = self.schema;
			end;
			
			for k, v in pairs(configClasses) do
				for k2, v2 in pairs( configTable[v] ) do
					local configObject = self:Get(k2);
					
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
			return CloudScript:RestoreCloudScriptData(fileName);
		else
			return CloudScript:RestoreSchemaData(fileName);
		end;
	end;
	
	-- A function to add a new config key.
	function CloudScript.config:Add(key, value, isShared, isGlobal, isStatic, isPrivate, needsRestart)
		if ( self:IsValidValue(value) ) then
			if ( !self.stored[key] ) then
				self.stored[key] = {
					needsRestart = needsRestart,
					isPrivate = isPrivate,
					isShared = isShared,
					isStatic = isStatic,
					isGlobal = isGlobal,
					default = value,
					value = value
				};
				
				local configClasses = {"global", "schema"};
				local configObject = self.class:Create(key);
				
				if (!isGlobal) then
					table.remove(configClasses, 1);
				end;
				
				for k, v in pairs(configClasses) do
					local configTable = CloudScript.config[v];
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
				
				self:Send(nil, key);
				
				return configObject;
			end;
		end;
	end;
	
	-- A function to set the config's value.
	function CloudScript.config.class:Set(value, map, forceSet, temporary)
		if (map) then
			map = string.lower(map);
		end;
		
		if (tostring(value) == "-1.#IND") then
			value = 0;
		end;
		
		if ( self.data and CloudScript.config:IsValidValue(value) ) then
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
						if ( (!CloudScript.config:HasInitialized() and self.data.value == self.data.default)
						or !self.data.needsRestart or forceSet ) then
							self.data.value = value;
							
							if (self.data.isShared) then
								CloudScript.config:Send(nil, self.key);
							end;
						end;
					end;
					
					if ( CloudScript.config:HasInitialized() ) then
						self.data.temporary = temporary;
						self.data.forceSet = forceSet;
						self.data.map = map;
						
						if (self.data.needsRestart) then
							if (self.data.forceSet) then
								self.data.nextValue = nil;
							else
								self.data.nextValue = value;
							end;
						end;
						
						if (!self.data.map and !self.data.temporary) then
							CloudScript.config:Save("config", CloudScript.config.stored);
						end;
						
						if (self.data.map) then
							if (default) then
								if ( CloudScript.config.map[self.data.map] ) then
									CloudScript.config.map[self.data.map][self.key] = nil;
								end;
							else
								if ( !CloudScript.config.map[self.data.map] ) then
									CloudScript.config.map[self.data.map] = {};
								end;
								
								CloudScript.config.map[self.data.map][self.key] = {
									default = self.data.default,
									global = self.data.isGlobal,
									value = value
								};
							end;
							
							if (!self.data.temporary) then
								CloudScript.config:Save( "config/"..self.data.map, CloudScript.config.map[self.data.map] );
							end;
						end;
					end;
				end;
				
				if ( self.data.value != previousValue and CloudScript.config:HasInitialized() ) then
					CloudScript.plugin:Call("CloudScriptConfigChanged", self.key, self.data, previousValue, self.data.value);
				end;
			end;
			
			return value;
		end;
	end;
	
	CloudScript:HookDataStream("ConfigInitialized", function(player, data)
		if ( !player:HasConfigInitialized() ) then
			player:SetConfigInitialized(true);
			
			CloudScript.plugin:Call("PlayerConfigInitialized", player);
		end;
	end);
else
	CloudScript.config.system = {};
	
	CloudScript:HookDataStream("Config", function(data)
		for k, v in pairs(data) do
			if ( CloudScript.config.indexes[k] ) then
				k = CloudScript.config.indexes[k];
			end;
			
			if ( !CloudScript.config.stored[k] ) then
				CloudScript.config:Add(k, v);
			else
				CloudScript.config:Get(k):Set(v);
			end;
		end;
		
		if ( !CloudScript.config:HasInitialized() ) then
			CloudScript.config:SetInitialized(true);
			
			for k, v in pairs(CloudScript.config.stored) do
				CloudScript.plugin:Call("CloudScriptConfigInitialized", k, v.value);
			end;
			
			if ( IsValid(CloudScript.Client) and !CloudScript.config:HasSentInitialized() ) then
				CloudScript:StartDataStream("ConfigInitialized", true);
				
				CloudScript.config:SetSentInitialized(true);
			end;
		end;
	end);
	
	-- A function to get whether the config has sent initialized.
	function CloudScript.config:SetSentInitialized(sentInitialized)
		self.sentInitialized = sentInitialized;
	end;

	-- A function to get whether the config has sent initialized.
	function CloudScript.config:HasSentInitialized()
		return self.sentInitialized;
	end;
	
	-- A function to set a config key's system.
	function CloudScript.config:AddSystem(key, help, minimum, maximum, decimals)
		self.system[key] = {
			decimals = decimals or 0,
			maximum = maximum or 100,
			minimum = minimum or 0,
			help = help or "No help was provided for this config key!"
		};
	end;
	
	-- A function to get a config key's system.
	function CloudScript.config:GetSystem(key)
		return self.system[key];
	end;
	
	-- A function to add a new config key.
	function CloudScript.config:Add(key, value)
		if ( self:IsValidValue(value) ) then
			if ( !self.stored[key] ) then
				self.stored[key] = {
					default = value,
					value = value
				};
				
				return self.class:Create(key);
			end;
		end;
	end;
	
	-- A function to set the config's value.
	function CloudScript.config.class:Set(value)
		if (tostring(value) == "-1.#IND") then
			value = 0;
		end;
		
		if ( self.data and CloudScript.config:IsValidValue(value) ) then
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
				
				if ( self.data.value != previousValue and CloudScript.config:HasInitialized() ) then
					CloudScript.plugin:Call("CloudScriptConfigChanged", self.key, self.data, previousValue, self.data.value);
				end;
			end;
			
			return self.data.value;
		end;
	end;
end;