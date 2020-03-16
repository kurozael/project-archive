--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

openAura.config = {};
openAura.config.indexes = {};
openAura.config.stored = {};
openAura.config.cache = {};
openAura.config.class = {};
openAura.config.map = {};

-- A function to create a new config object.
function openAura.config.class:Create(key)
	local config = openAura:NewMetaTable(openAura.config.class);
	
	config.data = openAura.config.stored[key];
	config.key = key;
	
	return config;
end;

-- A function to check if the config is valid.
function openAura.config.class:IsValid()
	return self.data != nil;
end;

-- A function to query the config.
function openAura.config.class:Query(key, default)
	if (self.data and self.data[key] != nil) then
		return self.data[key];
	else
		return default;
	end;
end;

-- A function to get the config's value as a boolean.
function openAura.config.class:GetBoolean(default)
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
function openAura.config.class:GetNumber(default)
	if (self.data) then
		return tonumber(self.data.value) or default or 0;
	else
		return default or 0;
	end;
end;

-- A function to get a config's value as a string.
function openAura.config.class:GetString(default)
	if (self.data) then
		return tostring(self.data.value);
	else
		return default or "";
	end;
end;

-- A function to get a config's default value.
function openAura.config.class:GetDefault(default)
	if (self.data) then
		return self.data.default;
	else
		return default;
	end;
end;

-- A function to get the config's next value.
function openAura.config.class:GetNext(default)
	if (self.data and self.data.nextValue != nil) then
		return self.data.nextValue;
	else
		return default;
	end;
end;

-- A function to get the config's value.
function openAura.config.class:Get(default)
	if (self.data and self.data.value != nil) then
		return self.data.value;
	else
		return default;
	end;
end;

-- A function to set whether the config has initialized.
function openAura.config:SetInitialized(initalized)
	self.initialized = initalized;
end;

-- A function to get whether the config has initialized.
function openAura.config:HasInitialized()
	return self.initialized;
end;

-- A function to get whether a config value is valid.
function openAura.config:IsValidValue(value)
	return type(value) == "string" or type(value) == "number" or type(value) == "boolean";
end;

-- A function to share a config key.
function openAura.config:ShareKey(key)
	local shortCRC = openAura:GetShortCRC(key);
	
	if (SERVER) then
		self.indexes[key] = shortCRC;
	else
		self.indexes[shortCRC] = key;
	end;
end;

-- A function to get the stored config.
function openAura.config:GetStored()
	return self.stored;
end;

-- A function to import a config file.
function openAura.config:Import(fileName)
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
function openAura.config:Parse(text)
	for key in string.gmatch(text, "%$(.-)%$") do
		local value = self:Get(key):Get();
		
		if (value != nil) then
			text = openAura:Replace( text, "$"..key.."$", tostring(value) );
		end;
	end;
	
	return text;
end;

-- A function to get a config object.
function openAura.config:Get(key)
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
	function openAura.config:Save(fileName, configTable)
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
			
			openAura:SaveOpenAuraData(fileName, config.global);
			openAura:SaveSchemaData(fileName, config.schema);
		else
			openAura:DeleteOpenAuraData(fileName);
			openAura:DeleteSchemaData(fileName);
		end;
	end;
	
	-- A function to send the config to a player.
	function openAura.config:Send(player, key)
		if ( player and player:IsBot() ) then
			openAura.plugin:Call("PlayerConfigInitialized", player);
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
					
					openAura:StartDataStream( player, "Config", { [key] = value } );
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
			
			openAura:StartDataStream(player, "Config", config);
		end;
	end;

	-- A function to load config from a _file.
	function openAura.config:Load(fileName, loadGlobal)
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
			return openAura:RestoreOpenAuraData(fileName);
		else
			return openAura:RestoreSchemaData(fileName);
		end;
	end;
	
	-- A function to add a new config key.
	function openAura.config:Add(key, value, isShared, isGlobal, isStatic, isPrivate, needsRestart)
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
					local configTable = openAura.config[v];
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
	function openAura.config.class:Set(value, map, forceSet, temporary)
		if (map) then
			map = string.lower(map);
		end;
		
		if (tostring(value) == "-1.#IND") then
			value = 0;
		end;
		
		if ( self.data and openAura.config:IsValidValue(value) ) then
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
						if ( (!openAura.config:HasInitialized() and self.data.value == self.data.default)
						or !self.data.needsRestart or forceSet ) then
							self.data.value = value;
							
							if (self.data.isShared) then
								openAura.config:Send(nil, self.key);
							end;
						end;
					end;
					
					if ( openAura.config:HasInitialized() ) then
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
							openAura.config:Save("config", openAura.config.stored);
						end;
						
						if (self.data.map) then
							if (default) then
								if ( openAura.config.map[self.data.map] ) then
									openAura.config.map[self.data.map][self.key] = nil;
								end;
							else
								if ( !openAura.config.map[self.data.map] ) then
									openAura.config.map[self.data.map] = {};
								end;
								
								openAura.config.map[self.data.map][self.key] = {
									default = self.data.default,
									global = self.data.isGlobal,
									value = value
								};
							end;
							
							if (!self.data.temporary) then
								openAura.config:Save( "config/"..self.data.map, openAura.config.map[self.data.map] );
							end;
						end;
					end;
				end;
				
				if ( self.data.value != previousValue and openAura.config:HasInitialized() ) then
					openAura.plugin:Call("OpenAuraConfigChanged", self.key, self.data, previousValue, self.data.value);
				end;
			end;
			
			return value;
		end;
	end;
	
	openAura:HookDataStream("ConfigInitialized", function(player, data)
		if ( !player:HasConfigInitialized() ) then
			player:SetConfigInitialized(true);
			
			openAura.plugin:Call("PlayerConfigInitialized", player);
		end;
	end);
else
	openAura.config.moderator = {};
	
	openAura:HookDataStream("Config", function(data)
		for k, v in pairs(data) do
			if ( openAura.config.indexes[k] ) then
				k = openAura.config.indexes[k];
			end;
			
			if ( !openAura.config.stored[k] ) then
				openAura.config:Add(k, v);
			else
				openAura.config:Get(k):Set(v);
			end;
		end;
		
		if ( !openAura.config:HasInitialized() ) then
			openAura.config:SetInitialized(true);
			
			for k, v in pairs(openAura.config.stored) do
				openAura.plugin:Call("OpenAuraConfigInitialized", k, v.value);
			end;
			
			if ( IsValid(openAura.Client) and !openAura.config:HasSentInitialized() ) then
				openAura:StartDataStream("ConfigInitialized", true);
				
				openAura.config:SetSentInitialized(true);
			end;
		end;
	end);
	
	-- A function to get whether the config has sent initialized.
	function openAura.config:SetSentInitialized(sentInitialized)
		self.sentInitialized = sentInitialized;
	end;

	-- A function to get whether the config has sent initialized.
	function openAura.config:HasSentInitialized()
		return self.sentInitialized;
	end;
	
	-- A function to set a config key's moderator.
	function openAura.config:AddModerator(key, help, minimum, maximum, decimals)
		self.moderator[key] = {
			decimals = decimals or 0,
			maximum = maximum or 100,
			minimum = minimum or 0,
			help = help or "No help was provided for this config key!"
		};
	end;
	
	--[[
		Backwards compatability, you shouldn't use this
		function for anything new.
	--]]
	openAura.config.AddAuraWatch = openAura.config.AddModerator;
	
	-- A function to get a config key's moderator.
	function openAura.config:GetModerator(key)
		return self.moderator[key];
	end;
	
	-- A function to add a new config key.
	function openAura.config:Add(key, value)
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
	function openAura.config.class:Set(value)
		if (tostring(value) == "-1.#IND") then
			value = 0;
		end;
		
		if ( self.data and openAura.config:IsValidValue(value) ) then
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
				
				if ( self.data.value != previousValue and openAura.config:HasInitialized() ) then
					openAura.plugin:Call("OpenAuraConfigChanged", self.key, self.data, previousValue, self.data.value);
				end;
			end;
			
			return self.data.value;
		end;
	end;
end;