--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

CloudScript.plugin = {};
CloudScript.plugin.hooks = {};
CloudScript.plugin.stored = {};
CloudScript.plugin.buffer = {};
CloudScript.plugin.modules = {};

if (SERVER) then
	function CloudScript.plugin:SetUnloaded(name, isUnloaded)
		local plugin = self:Get(name);
		
		if (plugin and plugin != CloudScript.schema) then
			if (isUnloaded) then
				self.unloaded[plugin.folderName] = true;
			else
				self.unloaded[plugin.folderName] = nil;
			end;
			
			CloudScript:SaveSchemaData("plugins", self.unloaded);
			
			return true;
		end;
		
		return false;
	end;
	
	-- A function to get whether a plugin is disabled.
	function CloudScript.plugin:IsDisabled(name, bFolder)
		if (!bFolder) then
			local plugin = self:Get(name);
			
			if (plugin and plugin != CloudScript.schema) then
				for k, v in pairs(self.unloaded) do
					local unloaded = self:Get(k);
					
					if (unloaded and unloaded != CloudScript.schema
					and plugin.folderName != unloaded.folderName) then
						if ( table.HasValue(unloaded.plugins, plugin.folderName) ) then
							return true;
						end;
					end;
				end;
			end;
		elseif (name != "schema") then
			for k, v in pairs(self.unloaded) do
				local unloaded = self:Get(k);
				
				if (unloaded and unloaded != CloudScript.schema and name != unloaded.folderName) then
					if ( table.HasValue(unloaded.plugins, name) ) then
						return true;
					end;
				end;
			end;
		end;
		
		return false;
	end;
	
	-- A function to get whether a plugin is unloaded.
	function CloudScript.plugin:IsUnloaded(name, bFolder)
		if (!bFolder) then
			local plugin = self:Get(name);
			
			if (plugin and plugin != CloudScript.schema) then
				return (self.unloaded[plugin.folderName] == true);
			end;
		elseif (name != "schema") then
			return (self.unloaded[name] == true);
		end;
		
		return false;
	end;
else
	CloudScript.plugin.override = {};
	
	-- A function to set whether a plugin is unloaded.
	function CloudScript.plugin:SetUnloaded(name, isUnloaded)
		local plugin = self:Get(name);
		
		if (plugin) then
			self.override[plugin.folderName] = isUnloaded;
		end;
	end;
	
	-- A function to get whether a plugin is disabled.
	function CloudScript.plugin:IsDisabled(name, bFolder)
		if (!bFolder) then
			local plugin = self:Get(name);
			
			if (plugin and plugin != CloudScript.schema) then
				for k, v in pairs(self.unloaded) do
					local unloaded = self:Get(k);
					
					if (unloaded and unloaded != CloudScript.schema and plugin.folderName != unloaded.folderName) then
						if ( table.HasValue(unloaded.plugins, plugin.folderName) ) then
							return true;
						end;
					end;
				end;
			end;
		elseif (name != "schema") then
			for k, v in pairs(self.unloaded) do
				local unloaded = self:Get(k);
				
				if (unloaded and unloaded != CloudScript.schema
				and name != unloaded.folderName) then
					if ( table.HasValue(unloaded.plugins, name) ) then
						return true;
					end;
				end;
			end;
		end;
		
		return false;
	end;
	
	-- A function to get whether a plugin is unloaded.
	function CloudScript.plugin:IsUnloaded(name, bFolder)
		if (!bFolder) then
			local plugin = self:Get(name);
			
			if (plugin and plugin != CloudScript.schema) then
				if (self.override[plugin.folderName] != nil) then
					return self.override[plugin.folderName];
				end;
				
				return (self.unloaded[plugin.folderName] == true);
			end;
		elseif (name != "schema") then
			if (self.override[name] != nil) then
				return self.override[name];
			end;
			
			return (self.unloaded[name] == true);
		end;
		
		return false;
	end;
end;

-- A function to call the cached hook.
function CloudScript.plugin:CallCachedHook(name, callGamemodeHook, ...)
	local cachedHooks = self:CacheHook(name);
	
	for k, v in ipairs(cachedHooks) do
		local value = v.Callback(v.plugin, ...);
		
		if (value != nil) then
			return value;
		end;
	end;
	
	if (CloudScript.schema) then
		if (CloudScript.schema[name] and type( CloudScript.schema[name] ) == "function") then
			local value = CloudScript.schema[name](CloudScript.schema, ...);
			
			if (value != nil) then
				return value;
			end;
		end;
	end;
	
	if (callGamemodeHook) then
		if (CloudScript[name] and type( CloudScript[name] ) == "function") then
			local value = CloudScript[name](CloudScript, ...);
			
			if (value != nil) then
				return value;
			end;
		end;
	end;
end;

-- A function to get whether a hook is cached.
function CloudScript.plugin:IsHookCached(name)
	return self.hooks[name] != nil;
end;

-- A function to cache a hook.
function CloudScript.plugin:CacheHook(name)
	if ( !self:IsHookCached(name) ) then
		if ( !self.hooks[name] ) then
			self.hooks[name] = {};
		end;
		
		for k, v in pairs(self.modules) do
			if (v[name] and type( v[name] ) == "function") then
				local hooks = self.hooks[name];
				
				hooks[#hooks + 1] = {
					Callback = v[name],
					plugin = v
				};
			end;
		end;
		
		for k, v in pairs(self.stored) do
			if (CloudScript.schema != v) then
				if (v[name] and type( v[name] ) == "function") then
					local hooks = self.hooks[name];
					
					hooks[#hooks + 1] = {
						Callback = v[name],
						plugin = v
					};
				end;
			end;
		end;
	end;
	
	return self.hooks[name];
end;

-- A function to register a new plugin.
function CloudScript.plugin:Register(plugin)
	self.stored[plugin.name] = plugin;
	self.stored[plugin.name].plugins = {};
	self.buffer[plugin.folderName] = plugin;
	
	for k, v in pairs( _file.FindInLua(plugin.directory.."/plugins/*") ) do
		if (v != ".." and v != ".") then
			table.insert( self.stored[plugin.name].plugins, string.lower(v) );
		end;
	end;
	
	if ( !self:IsUnloaded(plugin) ) then
		self:IncludeExtras(plugin.directory);
		
		if (CLIENT and CloudScript.schema != plugin) then
			plugin.helpID = CloudScript.directory:AddCode("Plugins", [[
				<div class="cloudInfoTitle">
					]]..string.upper( plugin:GetName() )..[[
				</div>
				<div class="cloudInfoText">
					<div class="cloudInfoTip">
						developed by ]]..plugin:GetAuthor()..[[
					</div>
					]]..plugin:GetDescription()..[[
				</div>
			]], true, plugin.author);
		end;
	end;

	self:IncludePlugins(plugin.directory);
end;

-- A function to include a plugin's entities.
function CloudScript.plugin:IncludeEntities(directory)
	for k, v in pairs( _file.FindInLua(directory.."/entities/entities/*") ) do
		if (v != ".." and v != ".") then
			ENT = {Type = "anim"};
			
			if (SERVER) then
				include(directory.."/entities/entities/"..v.."/sv_auto.lua");
			elseif ( _file.Exists("../lua_temp/"..directory.."/entities/entities/"..v.."/cl_auto.lua")
			or _file.Exists("../gamemodes/"..directory.."/entities/entities/"..v.."/cl_auto.lua") ) then
				include(directory.."/entities/entities/"..v.."/cl_auto.lua");
			end;
			
			scripted_ents.Register(ENT, v); ENT = nil;
		end;
	end;
end;

-- A function to include a plugin's effects.
function CloudScript.plugin:IncludeEffects(directory)
	for k, v in pairs( _file.FindInLua(directory.."/entities/effects/*") ) do
		if (v != ".." and v != ".") then
			if (SERVER) then
				if ( _file.Exists("../gamemodes/"..directory.."/entities/effects/"..v.."/cl_auto.lua") ) then
					AddCSLuaFile(directory.."/entities/effects/"..v.."/cl_auto.lua");
				end;
			elseif ( _file.Exists("../lua_temp/"..directory.."/entities/effects/"..v.."/cl_auto.lua")
			or _file.Exists("../gamemodes/"..directory.."/entities/effects/"..v.."/cl_auto.lua") ) then
				EFFECT = {};
				
				include(directory.."/entities/effects/"..v.."/cl_auto.lua");
				
				effects.Register(EFFECT, v); EFFECT = nil;
			end;
		end;
	end;
end;

-- A function to include a plugin's weapons.
function CloudScript.plugin:IncludeWeapons(directory)
	for k, v in pairs( _file.FindInLua(directory.."/entities/weapons/*") ) do
		if (v != ".." and v != ".") then
			SWEP = { Base = "weapon_base", Primary = {}, Secondary = {} };
			
			if (SERVER) then
				if ( _file.Exists("../gamemodes/"..directory.."/entities/weapons/"..v.."/sh_auto.lua") ) then
					include(directory.."/entities/weapons/"..v.."/sh_auto.lua");
				end;
			elseif ( _file.Exists("../lua_temp/"..directory.."/entities/weapons/"..v.."/sh_auto.lua")
			or _file.Exists("../gamemodes/"..directory.."/entities/weapons/"..v.."/sh_auto.lua") ) then
				include(directory.."/entities/weapons/"..v.."/sh_auto.lua");
			end;
			
			weapons.Register(SWEP, v); SWEP = nil;
		end;
	end;
end;

-- A function to include a plugin's plugins.
function CloudScript.plugin:IncludePlugins(directory)
	if ( string.find(directory, "/schema") ) then
		directory = string.gsub(directory, "/schema", "");
	end;
	
	for k, v in pairs( _file.FindInLua(directory.."/plugins/*") ) do
		if (v != ".." and v != ".") then
			if (CLIENT) then
				if ( _file.IsDir("../lua_temp/"..directory.."/plugins/"..v) ) then
					self:Include(directory.."/plugins/"..v);
				end;
			elseif ( _file.IsDir("../gamemodes/"..directory.."/plugins/"..v) ) then
				self:Include(directory.."/plugins/"..v);
			end;
		end;
	end;
end;

-- A function to include a plugin's extras.
function CloudScript.plugin:IncludeExtras(directory)
	self:IncludeEffects(directory); self:IncludeWeapons(directory);
	self:IncludeEntities(directory);
	
	for k, v in pairs( _file.FindInLua(directory.."/libraries/*.lua") ) do
		CloudScript:IncludePrefixed(directory.."/libraries/"..v);
	end;

	for k, v in pairs( _file.FindInLua(directory.."/directory/*.lua") ) do
		CloudScript:IncludePrefixed(directory.."/directory/"..v);
	end;
	
	for k, v in pairs( _file.FindInLua(directory.."/objects/system/*.lua") ) do
		CloudScript:IncludePrefixed(directory.."/objects/system/"..v);
	end;
	
	for k, v in pairs( _file.FindInLua(directory.."/objects/factions/*.lua") ) do
		CloudScript:IncludePrefixed(directory.."/objects/factions/"..v);
	end;
	
	for k, v in pairs( _file.FindInLua(directory.."/objects/classes/*.lua") ) do
		CloudScript:IncludePrefixed(directory.."/objects/classes/"..v);
	end;
	
	for k, v in pairs( _file.FindInLua(directory.."/objects/attributes/*.lua") ) do
		CloudScript:IncludePrefixed(directory.."/objects/attributes/"..v);
	end;
	
	for k, v in pairs( _file.FindInLua(directory.."/objects/items/*.lua") ) do
		CloudScript:IncludePrefixed(directory.."/objects/items/"..v);
	end;
	
	for k, v in pairs( _file.FindInLua(directory.."/objects/derma/*.lua") ) do
		CloudScript:IncludePrefixed(directory.."/objects/derma/"..v);
	end;
end;

-- A function to include a plugin.
function CloudScript.plugin:Include(directory, schema)
	local explodeDir = string.Explode("/", directory);
	local folderName = explodeDir[#explodeDir];
	
	PLUGIN_FOLDERNAME = string.lower(folderName);
	PLUGIN_DIRECTORY = string.lower(directory);
	PLUGIN = nil;
	
	if (SERVER) then
		if (!schema) then
			PLUGIN = self:New();
		else
			CloudScript.schema = self:New();
		end;
		
		if ( _file.Exists("../gamemodes/"..directory.."/sh_info.lua") ) then
			include(directory.."/sh_info.lua");
			AddCSLuaFile(directory.."/sh_info.lua");
		else
			ErrorNoHalt("CloudScript -> the "..PLUGIN_FOLDERNAME.." plugin has no sh_info.lua.");
		end;
		
		local isUnloaded = self:IsUnloaded(PLUGIN_FOLDERNAME, true);
		local isDisabled = self:IsDisabled(PLUGIN_FOLDERNAME, true);
		
		if (schema) then
			isUnloaded = false;
			isDisabled = false;
		end;
		
		if (!isUnloaded and !isDisabled) then
			if ( _file.Exists("../gamemodes/"..directory.."/sv_auto.lua") ) then
				include(directory.."/sv_auto.lua");
			end;
		end;
		
		if ( _file.Exists("../gamemodes/"..directory.."/cl_auto.lua") ) then
			AddCSLuaFile(directory.."/cl_auto.lua");
		end;
	else
		if (!schema) then
			PLUGIN = self:New();
		else
			CloudScript.schema = self:New();
		end;
		
		if ( _file.Exists("../lua_temp/"..directory.."/sh_info.lua") ) then
			include(directory.."/sh_info.lua");
		else
			ErrorNoHalt("CloudScript -> the "..PLUGIN_FOLDERNAME.." plugin has no sh_info.lua.");
		end;
		
		local isUnloaded = self:IsUnloaded(PLUGIN_FOLDERNAME, true);
		local isDisabled = self:IsDisabled(PLUGIN_FOLDERNAME, true);
		
		if (schema) then
			isUnloaded = false;
			isDisabled = false;
		end;
		
		if (!isUnloaded and !isDisabled) then
			if ( _file.Exists("../lua_temp/"..directory.."/cl_auto.lua") ) then
				include(directory.."/cl_auto.lua");
			end;
		end;
	end;
	
	if (schema and CloudScript.schema) then
		self:Register(CloudScript.schema);
	elseif (PLUGIN) then
		self:Register(PLUGIN);
		
		PLUGIN = nil;
	end;
end;

-- A function to create a new plugin.
function CloudScript.plugin:New()
	local pluginTable = {
		directory = PLUGIN_DIRECTORY,
		folderName = PLUGIN_FOLDERNAME
	};
	
	pluginTable.GetDescription = function(pluginTable)
		return pluginTable.description;
	end;
	
	pluginTable.GetAuthor = function(pluginTable)
		return pluginTable.author;
	end;
	
	pluginTable.GetName = function(pluginTable)
		return pluginTable.name;
	end;
	
	return pluginTable;
end;

-- A function to call a function for all plugins.
function CloudScript.plugin:Call(name, ...)
	return self:CallCachedHook(name, true, ...);
end;

-- A function to get a plugin.
function CloudScript.plugin:Get(name)
	return self.stored[name] or self.buffer[name];
end;

-- A function to add a table as a module.
function CloudScript.plugin:Add(name, module)
	self.modules[name] = module;
end;