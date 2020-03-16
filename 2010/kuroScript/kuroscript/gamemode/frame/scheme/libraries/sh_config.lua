--[[
Name: "sh_config.lua".
Product: "kuroScript".
--]]

kuroScript.config = {};
kuroScript.config.stored = {};
kuroScript.config.cache = {};
kuroScript.config.class = {};
kuroScript.config.map = {};

-- A function to create a new config object.
function kuroScript.config.class:Create(key)
	local config = kuroScript.frame:NewMetaTable(kuroScript.config.class);
	
	-- Set some information.
	config.data = kuroScript.config.stored[key];
	config.key = key;
	
	-- Return the config object.
	return config;
end;

-- A function to check if the config is valid.
function kuroScript.config.class:IsValid()
	return self.data != nil;
end;

-- A function to query the config.
function kuroScript.config.class:Query(key, default)
	if (self.data and self.data[key] != nil) then
		return self.data[key];
	else
		return default;
	end;
end;

-- A function to get the config's value as a boolean.
function kuroScript.config.class:GetBoolean(default)
	if (self.data) then
		return (self.data.value == true or self.data.value == "true" or self.data.value == "1" or self.data.value == 1);
	elseif (default != nil) then
		return default;
	else
		return false;
	end;
end;

-- A function to get a config's value as a number.
function kuroScript.config.class:GetNumber(default)
	if (self.data) then
		return tonumber(self.data.value) or default or 0;
	else
		return default or 0;
	end;
end;

-- A function to get a config's value as a string.
function kuroScript.config.class:GetString(default)
	if (self.data) then
		return tostring(self.data.value);
	else
		return default or "";
	end;
end;

-- A function to get a config's default value.
function kuroScript.config.class:GetDefault(default)
	if (self.data) then
		return self.data.default;
	else
		return default;
	end;
end;

-- A function to get the config's next value.
function kuroScript.config.class:GetNext(default)
	if (self.data and self.data.nextValue != nil) then
		return self.data.nextValue;
	else
		return default;
	end;
end;

-- A function to get the config's value.
function kuroScript.config.class:Get(default)
	if (self.data and self.data.value != nil) then
		return self.data.value;
	else
		return default;
	end;
end;

-- A function to get whether the config has initialized.
function kuroScript.config.HasInitialized()
	return kuroScript.config.initialized;
end;

-- A function to get whether a config value is valid.
function kuroScript.config.IsValidValue(value)
	return type(value) == "string" or type(value) == "number" or type(value) == "boolean";
end;

-- A function to import a config file.
function kuroScript.config.Import(file)
	local data = g_File.Read(file);
	
	-- Check if a statement is true.
	if (data) then
		for k, v in ipairs( kuroScript.frame:ExplodeString("\n", data) ) do
			if ( v != "" and !string.find(v, "^%s$") ) then
				if ( !string.find(v, "^%[.+%]$") and !string.find(v, "^//") ) then
					local class, key, value = string.match(v, "^(.-)%s(.-)%s=%s(.+)");
					
					-- Check if a statement is true.
					if (class and key and value) then
						if ( string.find(class, "boolean") ) then
							value = (value == "true" or value == "1");
						elseif ( string.find(class, "number") ) then
							value = tonumber(value);
						end;
						
						-- Set some information.
						local force = string.find(class, "force") != nil;
						local shared = string.find(class, "shared") != nil;
						local global = string.find(class, "global") != nil;
						local static = string.find(class, "static") != nil;
						local private = string.find(class, "private") != nil;
						local restart = string.find(class, "restart") != nil;
						
						-- Check if a statement is true.
						if (value) then
							local config = kuroScript.config.Get(key);
							
							-- Check if a statement is true.
							if ( !config:IsValid() ) then
								kuroScript.config.Add(key, value, shared, global, static, private, restart);
							else
								config:Set(value, nil, force);
							end;
						end;
					end;
				end;
			end;
		end;
	end;
end;

-- A function to parse config keys.
function kuroScript.config.Parse(text)
	for key in string.gmatch(text, "%$(.-)%$") do
		local value = kuroScript.config.Get(key):Get();
		
		-- Check if a statement is true.
		if (value != nil) then
			text = string.Replace( text, "$"..key.."$", tostring(value) );
		end;
	end;
	
	-- Return the text.
	return text;
end;

-- A function to get a config object.
function kuroScript.config.Get(key)
	if ( kuroScript.config.cache[key] ) then
		if (kuroScript.config.stored[key] and !kuroScript.config.cache[key].data) then
			kuroScript.config.cache[key].data = kuroScript.config.stored[key];
			
			-- Return the config object.
			return kuroScript.config.cache[key];
		else
			return kuroScript.config.cache[key];
		end;
	else
		kuroScript.config.cache[key] = kuroScript.config.class:Create(key);
		
		-- Return the config object.
		return kuroScript.config.cache[key];
	end;
end;

-- Check if a statement is true.
if (SERVER) then
	function kuroScript.config.Save(file, input)
		if (input) then
			local config = { global = {}, game = {} };
			
			-- Loop through each value in a table.
			for k, v in pairs(input) do
				if (!v.map and !v.temporary) then
					local value = v.value;
					
					-- Check if a statement is true.
					if (v.nextValue != nil) then
						value = v.nextValue;
					end;
					
					-- Check if a statement is true.
					if (value != v.default) then
						if (v.global) then
							config.global[k] = {value = value, default = v.default};
						else
							config.game[k] = {value = value, default = v.default};
						end;
					end;
				end;
			end;
			
			-- Save some game data.
			kuroScript.frame:SaveKuroScriptData(file, config.global);
			kuroScript.frame:SaveGameData(file, config.game);
		else
			kuroScript.frame:DeleteKuroScriptData(file);
			kuroScript.frame:DeleteGameData(file);
		end;
	end;
	
	-- A function to send the config to a player.
	function kuroScript.config.Send(player, key)
		if (!player) then
			player = g_Player.GetAll();
		else
			player = {player};
		end;
		
		-- Check if a statement is true.
		if (key) then
			if ( kuroScript.config.stored[key] ) then
				if (kuroScript.config.stored[key].shared) then
					datastream.StreamToClients( player, "ks_Config", { [key] = kuroScript.config.stored[key].value } );
				end;
			end;
		else
			local config = {};
			local k, v;
			
			-- Loop through each value in a table.
			for k, v in pairs(kuroScript.config.stored) do
				if (v.shared) then config[k] = v.value; end;
			end;
			
			-- Start a data stream.
			datastream.StreamToClients(player, "ks_Config", config);
		end;
	end;

	-- A function to load config from a file.
	function kuroScript.config.Load(file, global)
		if (!file) then
			local configClasses = {"default", "map"};
			local configTable;
			local k2, v2;
			local k, v;
			local map = string.lower( game.GetMap() );
			
			-- Check if a statement is true.
			if (global) then
				kuroScript.config.global = {
					default = kuroScript.config.Load("config", true),
					map = kuroScript.config.Load("config/"..map, true)
				};
				
				-- Set some information.
				configTable = kuroScript.config.global;
			else
				kuroScript.config.game = {
					default = kuroScript.config.Load("config"),
					map = kuroScript.config.Load("config/"..map)
				};
				
				-- Set some information.
				configTable = kuroScript.config.game;
			end;
			
			-- Loop through each value in a table.
			for k, v in pairs(configClasses) do
				for k2, v2 in pairs( configTable[v] ) do
					local configObject = kuroScript.config.Get(k2);
					
					-- Check if a statement is true.
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
		elseif (global) then
			return kuroScript.frame:RestoreKuroScriptData(file);
		else
			return kuroScript.frame:RestoreGameData(file);
		end;
	end;
	
	-- A function to add a new config key.
	function kuroScript.config.Add(key, value, shared, global, static, private, restart)
		if ( kuroScript.config.IsValidValue(value) ) then
			if ( !kuroScript.config.stored[key] ) then
				kuroScript.config.stored[key] = {
					restart = restart,
					private = private,
					default = value,
					global = global,
					shared = shared,
					static = static,
					value = value
				};
				
				-- Set some information.
				local configClasses = {"global", "game"};
				local configObject = kuroScript.config.class:Create(key);
				local k, v;
				
				-- Check if a statement is true.
				if (!global) then table.remove(configClasses, 1); end;
				
				-- Loop through each value in a table.
				for k, v in pairs(configClasses) do
					local configTable = kuroScript.config[v];
					local map = string.lower( game.GetMap() );
					
					-- Check if a statement is true.
					if ( configTable and configTable.default and configTable.default[key] ) then
						if (configObject:Query("default") == configTable.default[key].default) then
							configObject:Set(configTable.default[key].value, nil, true);
						end;
					end;
					
					-- Check if a statement is true.
					if ( configTable and configTable.map and configTable.map[key] ) then
						if (configObject:Query("default") == configTable.map[key].default) then
							configObject:Set(configTable.map[key].value, map, true);
						end;
					end;
				end;
				
				-- Send the config to each player.
				kuroScript.config.Send(nil, key);
				
				-- Return the config object.
				return configObject;
			end;
		end;
	end;
	
	-- A function to set the config's value.
	function kuroScript.config.class:Set(value, map, force, temporary)
		if (map) then map = string.lower(map); end;
		
		-- Check if a statement is true.
		if (tostring(value) == "-1.#IND") then value = 0; end;
		
		-- Check is a statement is true.
		if ( self.data and kuroScript.config.IsValidValue(value) ) then
			if (self.data.value != value) then
				local previousValue = self.data.value;
				local default = (value == "!default");
				
				-- Check is a statement is true.
				if (!default) then
					if (type(self.data.value) == "number") then
						value = tonumber(value) or self.data.value;
					elseif (type(self.data.value) == "boolean") then
						value = (value == true or value == "true" or value == "1" or value == 1);
					end;
				else
					value = self.data.default;
				end;
				
				-- Check if a statement is true.
				if (!self.data.static or force) then
					if (!map or string.lower( game.GetMap() ) == map) then
						if (!self.data.restart or force) then
							self.data.value = value;
							
							-- Check if a statement is true.
							if (self.data.shared) then
								kuroScript.config.Send(nil, self.key);
							end;
						end;
					end;
					
					-- Set some information.
					self.data.temporary = temporary;
					self.data.force = force;
					self.data.map = map;
					
					-- Check if a statement is true.
					if (self.data.restart) then
						if (self.data.force) then
							self.data.nextValue = nil;
						else
							self.data.nextValue = value;
						end;
					end;
					
					-- Check if a statement is true.
					if (!self.data.map and !self.data.temporary and kuroScript.config.initialized) then
						kuroScript.config.Save("config", kuroScript.config.stored);
					end;
					
					-- Check if a statement is true.
					if (self.data.map) then
						if (default) then
							if ( kuroScript.config.map[self.data.map] ) then
								kuroScript.config.map[self.data.map][self.key] = nil;
							end;
						else
							if ( !kuroScript.config.map[self.data.map] ) then
								kuroScript.config.map[self.data.map] = {};
							end;
							
							-- Set some information.
							kuroScript.config.map[self.data.map][self.key] = {
								default = self.data.default,
								global = self.data.global,
								value = value
							};
						end;
						
						-- Check if a statement is true.
						if (!self.data.temporary and kuroScript.config.initialized) then
							kuroScript.config.Save( "config/"..self.data.map, kuroScript.config.map[self.data.map] );
						end;
					end;
				end;
				
				-- Check if a statement is true.
				if (self.data.value != previousValue and kuroScript.config.initialized) then
					hook.Call("KuroScriptConfigChanged", kuroScript.frame, self.key, self.data, previousValue, self.data.value);
				end;
			end;
			
			-- Return the value.
			return value;
		end;
	end;
	
	-- Hook a data stream.
	datastream.Hook("ks_ConfigInitialized", function(player, handler, uniqueID, rawData, procData)
		if ( !player:HasConfigInitialized() ) then
			player._ConfigInitialized = true;
			
			-- Call a gamemode hook.
			hook.Call("PlayerConfigInitialized", kuroScript.frame, player);
		end;
	end);
else
	datastream.Hook("ks_Config", function(handler, uniqueID, rawData, procData)
		local k, v;
		
		-- Loop through each value in a table.
		for k, v in pairs(procData) do
			if ( !kuroScript.config.stored[k] ) then
				kuroScript.config.Add(k, v);
			else
				kuroScript.config.Get(k):Set(v);
			end;
		end;
		
		-- Check if a statement is true.
		if (!kuroScript.config.initialized) then
			kuroScript.config.initialized = true;
			
			-- Loop through each value in a table.
			for k, v in pairs(kuroScript.config.stored) do
				hook.Call("KuroScriptConfigInitialized", kuroScript.frame, k, v.value);
			end;
			
			-- Check if a statement is true.
			if (ValidEntity(g_LocalPlayer) and !kuroScript.config.sentInitialized) then
				datastream.StreamToServer("ks_ConfigInitialized", true);
				
				-- Set some information.
				kuroScript.config.sentInitialized = true;
			end;
		end;
	end);
	
	-- A function to add a new config key.
	function kuroScript.config.Add(key, value)
		if ( kuroScript.config.IsValidValue(value) ) then
			if ( !kuroScript.config.stored[key] ) then
				kuroScript.config.stored[key] = {
					default = value,
					value = value
				};
				
				-- Return a new config object.
				return kuroScript.config.class:Create(key);
			end;
		end;
	end;
	
	-- A function to set the config's value.
	function kuroScript.config.class:Set(value)
		if (tostring(value) == "-1.#IND") then
			value = 0;
		end;
		
		-- Check is a statement is true.
		if ( self.data and kuroScript.config.IsValidValue(value) ) then
			if (self.data.value != value) then
				local previousValue = self.data.value;
				local default = (value == "!default");
				
				-- Check is a statement is true.
				if (!default) then
					if (type(self.data.value) == "number") then
						value = tonumber(value) or self.data.value;
					elseif (type(self.data.value) == "boolean") then
						value = (value == true or value == "true" or value == "1" or value == 1);
					end;
					
					-- Set some information.
					self.data.value = value;
				else
					self.data.value = self.data.default;
				end;
				
				-- Check if a statement is true.
				if (self.data.value != previousValue and kuroScript.config.initialized) then
					hook.Call("KuroScriptConfigChanged", kuroScript.frame, self.key, self.data, previousValue, self.data.value);
				end;
			end;
			
			-- Return the value.
			return self.data.value;
		end;
	end;
end;