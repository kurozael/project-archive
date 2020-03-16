--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

openAura.plugin = {};
openAura.plugin.hooks = {};
openAura.plugin.stored = {};
openAura.plugin.buffer = {};
openAura.plugin.modules = {};

if (SERVER) then
	function openAura.plugin:SetUnloaded(name, isUnloaded)
		local plugin = self:Get(name);
		
		if (plugin and plugin != openAura.schema) then
			if (isUnloaded) then
				self.unloaded[plugin.folderName] = true;
			else
				self.unloaded[plugin.folderName] = nil;
			end;
			
			openAura:SaveSchemaData("plugins", self.unloaded);
			
			return true;
		end;
		
		return false;
	end;
	
	-- A function to get whether a plugin is disabled.
	function openAura.plugin:IsDisabled(name, bFolder)
		if (!bFolder) then
			local plugin = self:Get(name);
			
			if (plugin and plugin != openAura.schema) then
				for k, v in pairs(self.unloaded) do
					local unloaded = self:Get(k);
					
					if (unloaded and unloaded != openAura.schema
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
				
				if (unloaded and unloaded != openAura.schema and name != unloaded.folderName) then
					if ( table.HasValue(unloaded.plugins, name) ) then
						return true;
					end;
				end;
			end;
		end;
		
		return false;
	end;
	
	-- A function to get whether a plugin is unloaded.
	function openAura.plugin:IsUnloaded(name, bFolder)
		if (!bFolder) then
			local plugin = self:Get(name);
			
			if (plugin and plugin != openAura.schema) then
				return (self.unloaded[plugin.folderName] == true);
			end;
		elseif (name != "schema") then
			return (self.unloaded[name] == true);
		end;
		
		return false;
	end;
else
	openAura.plugin.override = {};
	
	-- A function to set whether a plugin is unloaded.
	function openAura.plugin:SetUnloaded(name, isUnloaded)
		local plugin = self:Get(name);
		
		if (plugin) then
			self.override[plugin.folderName] = isUnloaded;
		end;
	end;
	
	-- A function to get whether a plugin is disabled.
	function openAura.plugin:IsDisabled(name, bFolder)
		if (!bFolder) then
			local plugin = self:Get(name);
			
			if (plugin and plugin != openAura.schema) then
				for k, v in pairs(self.unloaded) do
					local unloaded = self:Get(k);
					
					if (unloaded and unloaded != openAura.schema and plugin.folderName != unloaded.folderName) then
						if ( table.HasValue(unloaded.plugins, plugin.folderName) ) then
							return true;
						end;
					end;
				end;
			end;
		elseif (name != "schema") then
			for k, v in pairs(self.unloaded) do
				local unloaded = self:Get(k);
				
				if (unloaded and unloaded != openAura.schema
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
	function openAura.plugin:IsUnloaded(name, bFolder)
		if (!bFolder) then
			local plugin = self:Get(name);
			
			if (plugin and plugin != openAura.schema) then
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
function openAura.plugin:CallCachedHook(name, callGamemodeHook, ...)
	local cachedHooks = self:CacheHook(name);
	
	for k, v in ipairs(cachedHooks) do
		local value = v.Callback(v.plugin, ...);
		
		if (value != nil) then
			return value;
		end;
	end;
	
	if (openAura.schema) then
		if (openAura.schema[name] and type( openAura.schema[name] ) == "function") then
			local value = openAura.schema[name](openAura.schema, ...);
			
			if (value != nil) then
				return value;
			end;
		end;
	end;
	
	if (callGamemodeHook) then
		if (openAura[name] and type( openAura[name] ) == "function") then
			local value = openAura[name](openAura, ...);
			
			if (value != nil) then
				return value;
			end;
		end;
	end;
end;

-- A function to get whether a hook is cached.
function openAura.plugin:IsHookCached(name)
	return self.hooks[name] != nil;
end;

-- A function to cache a hook.
function openAura.plugin:CacheHook(name)
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
			if (openAura.schema != v) then
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
function openAura.plugin:Register(plugin)
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
		
		if (CLIENT and openAura.schema != plugin) then
			plugin.helpID = openAura.directory:AddCode("Plugins", [[
				<div class="auraInfoTitle">
					]]..string.upper( plugin:GetName() )..[[
				</div>
				<div class="auraInfoText">
					<div class="auraInfoTip">
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
function openAura.plugin:IncludeEntities(directory)
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
function openAura.plugin:IncludeEffects(directory)
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
function openAura.plugin:IncludeWeapons(directory)
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

-- A function to include a plugin's libraries.
function openAura.plugin:IncludeLibraries(directory)
	for k, v in pairs( _file.FindInLua(directory.."/libraries/*.lua") ) do
		openAura:IncludePrefixed(directory.."/libraries/"..v);
	end;
end;
-- A function to include a plugin's derma.
function openAura.plugin:IncludeDerma(directory)
	for k, v in pairs( _file.FindInLua(directory.."/derma/*") ) do
		if (v != ".." and v != ".") then
			if (SERVER) then
				if ( _file.Exists("../gamemodes/"..directory.."/derma/"..v) ) then
					AddCSLuaFile(directory.."/derma/"..v);
				end;
			elseif ( _file.Exists("../lua_temp/"..directory.."/derma/"..v)
			or _file.Exists("../gamemodes/"..directory.."/derma/"..v) ) then
				include(directory.."/derma/"..v);
			end;
		end;
	end;
end;

-- A function to include a plugin's moderator.
function openAura.plugin:IncludeModerator(directory)
	for k, v in pairs( _file.FindInLua(directory.."/moderator/*.lua") ) do
		openAura:IncludePrefixed(directory.."/moderator/"..v);
	end;
end;

-- A function to include a plugin's directory.
function openAura.plugin:IncludeDirectory(directory)
	for k, v in pairs( _file.FindInLua(directory.."/directory/*.lua") ) do
		openAura:IncludePrefixed(directory.."/directory/"..v);
	end;
end;

-- A function to include a plugin's items.
function openAura.plugin:IncludeItems(directory)
	for k, v in pairs( _file.FindInLua(directory.."/items/*.lua") ) do
		openAura:IncludePrefixed(directory.."/items/"..v);
	end;
end;

-- A function to include a plugin's plugins.
function openAura.plugin:IncludePlugins(directory)
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

-- A function to include a plugin's factions.
function openAura.plugin:IncludeFactions(directory)
	for k, v in pairs( _file.FindInLua(directory.."/factions/*.lua") ) do
		openAura:IncludePrefixed(directory.."/factions/"..v);
	end;
end;

-- A function to include a plugin's classes.
function openAura.plugin:IncludeClasses(directory)
	for k, v in pairs( _file.FindInLua(directory.."/classes/*.lua") ) do
		openAura:IncludePrefixed(directory.."/classes/"..v);
	end;
end;

-- A function to include a plugin's attributes.
function openAura.plugin:IncludeAttributes(directory)
	for k, v in pairs( _file.FindInLua(directory.."/attributes/*.lua") ) do
		openAura:IncludePrefixed(directory.."/attributes/"..v);
	end;
end;

-- A function to include a plugin's extras.
function openAura.plugin:IncludeExtras(directory)
	self:IncludeEffects(directory);
	self:IncludeWeapons(directory);
	self:IncludeEntities(directory);
	self:IncludeLibraries(directory);
	self:IncludeDirectory(directory);
	self:IncludeModerator(directory);
	self:IncludeFactions(directory);
	self:IncludeClasses(directory);
	self:IncludeAttributes(directory);
	self:IncludeDerma(directory);
	self:IncludeItems(directory);
end;

-- A function to include a plugin.
function openAura.plugin:Include(directory, schema)
	local explodeDir = string.Explode("/", directory);
	local folderName = explodeDir[#explodeDir];
	
	PLUGIN_FOLDERNAME = string.lower(folderName);
	PLUGIN_DIRECTORY = string.lower(directory);
	PLUGIN = nil;
	
	if (SERVER) then
		if (!schema) then
			PLUGIN = self:New();
		else
			openAura.schema = self:New();
		end;
		
		if ( _file.Exists("../gamemodes/"..directory.."/sh_info.lua") ) then
			include(directory.."/sh_info.lua");
			AddCSLuaFile(directory.."/sh_info.lua");
		else
			ErrorNoHalt("OpenAura -> the "..PLUGIN_FOLDERNAME.." plugin has no sh_info.lua.");
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
			openAura.schema = self:New();
		end;
		
		if ( _file.Exists("../lua_temp/"..directory.."/sh_info.lua") ) then
			include(directory.."/sh_info.lua");
		else
			ErrorNoHalt("OpenAura -> the "..PLUGIN_FOLDERNAME.." plugin has no sh_info.lua.");
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
	
	if (schema and openAura.schema) then
		self:Register(openAura.schema);
	elseif (PLUGIN) then
		self:Register(PLUGIN);
		
		PLUGIN = nil;
	end;
end;

-- A function to create a new plugin.
function openAura.plugin:New()
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
function openAura.plugin:Call(name, ...)
	return self:CallCachedHook(name, true, ...);
end;

-- A function to get a plugin.
function openAura.plugin:Get(name)
	return self.stored[name] or self.buffer[name];
end;

-- A function to add a table as a module.
function openAura.plugin:Add(name, module)
	self.modules[name] = module;
end;