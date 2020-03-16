--[[
Name: "sh_mount.lua".
Product: "nexus".
--]]

nexus.mount = {};
nexus.mount.hooks = {};
nexus.mount.stored = {};
nexus.mount.buffer = {};

if (SERVER) then
	function nexus.mount.SetUnloaded(name, isUnloaded)
		local mount = nexus.mount.Get(name);
		
		if (mount and mount != SCHEMA) then
			if (isUnloaded) then
				nexus.mount.unloaded[mount.folderName] = true;
			else
				nexus.mount.unloaded[mount.folderName] = nil;
			end;
			
			NEXUS:SaveSchemaData("unloaded", nexus.mount.unloaded);
			
			return true;
		end;
		
		return false;
	end;
	
	-- A function to get whether a mount is disabled.
	function nexus.mount.IsDisabled(name, bFolder)
		if (!bFolder) then
			local mount = nexus.mount.Get(name);
			
			if (mount and mount != SCHEMA) then
				for k, v in pairs(nexus.mount.unloaded) do
					local unloaded = nexus.mount.Get(k);
					
					if (unloaded and unloaded != SCHEMA
					and mount.folderName != unloaded.folderName) then
						if ( table.HasValue(unloaded.mounts, mount.folderName) ) then
							return true;
						end;
					end;
				end;
			end;
		elseif (name != "schema") then
			for k, v in pairs(nexus.mount.unloaded) do
				local unloaded = nexus.mount.Get(k);
				
				if (unloaded and unloaded != SCHEMA
				and name != unloaded.folderName) then
					if ( table.HasValue(unloaded.mounts, name) ) then
						return true;
					end;
				end;
			end;
		end;
		
		return false;
	end;
	
	-- A function to get whether a mount is unloaded.
	function nexus.mount.IsUnloaded(name, bFolder)
		if (!bFolder) then
			local mount = nexus.mount.Get(name);
			
			if (mount and mount != SCHEMA) then
				return (nexus.mount.unloaded[mount.folderName] == true);
			end;
		elseif (name != "schema") then
			return (nexus.mount.unloaded[name] == true);
		end;
		
		return false;
	end;
else
	nexus.mount.override = {};
	
	-- A function to set whether a mount is unloaded.
	function nexus.mount.SetUnloaded(name, isUnloaded)
		local mount = nexus.mount.Get(name);
		
		if (mount) then
			nexus.mount.override[mount.folderName] = isUnloaded;
		end;
	end;
	
	-- A function to get whether a mount is disabled.
	function nexus.mount.IsDisabled(name, bFolder)
		if (!bFolder) then
			local mount = nexus.mount.Get(name);
			
			if (mount and mount != SCHEMA) then
				for k, v in pairs(nexus.mount.unloaded) do
					local unloaded = nexus.mount.Get(k);
					
					if (unloaded and unloaded != SCHEMA
					and mount.folderName != unloaded.folderName) then
						if ( table.HasValue(unloaded.mounts, mount.folderName) ) then
							return true;
						end;
					end;
				end;
			end;
		elseif (name != "schema") then
			for k, v in pairs(nexus.mount.unloaded) do
				local unloaded = nexus.mount.Get(k);
				
				if (unloaded and unloaded != SCHEMA
				and name != unloaded.folderName) then
					if ( table.HasValue(unloaded.mounts, name) ) then
						return true;
					end;
				end;
			end;
		end;
		
		return false;
	end;
	
	-- A function to get whether a mount is unloaded.
	function nexus.mount.IsUnloaded(name, bFolder)
		if (!bFolder) then
			local mount = nexus.mount.Get(name);
			
			if (mount and mount != SCHEMA) then
				if (nexus.mount.override[mount.folderName] != nil) then
					return nexus.mount.override[mount.folderName];
				end;
				
				return (nexus.mount.unloaded[mount.folderName] == true);
			end;
		elseif (name != "schema") then
			if (nexus.mount.override[name] != nil) then
				return nexus.mount.override[name];
			end;
			
			return (nexus.mount.unloaded[name] == true);
		end;
		
		return false;
	end;
end;

-- A function to call the cached hook.
function nexus.mount.CallCachedHook(name, arguments, callGamemodeHook)
	local cachedHooks = nexus.mount.CacheHook(name);
	
	for k, v in ipairs(cachedHooks) do
		local value = v.Callback( v.mount, unpack(arguments) );
		
		if (value != nil) then
			return value;
		end;
	end;
	
	if (SCHEMA) then
		if (SCHEMA[name] and type( SCHEMA[name] ) == "function") then
			local value = SCHEMA[name]( SCHEMA, unpack(arguments) );
			
			if (value != nil) then
				return value;
			end;
		end;
	end;
	
	if (callGamemodeHook) then
		if (NEXUS[name] and type( NEXUS[name] ) == "function") then
			local value = NEXUS[name]( NEXUS, unpack(arguments) );
			
			if (value != nil) then
				return value;
			end;
		end;
	end;
end;

-- A function to get whether a hook is cached.
function nexus.mount.IsHookCached(name)
	return nexus.mount.hooks[name] != nil;
end;

-- A function to cache a hook.
function nexus.mount.CacheHook(name)
	if ( !nexus.mount.IsHookCached(name) ) then
		if ( !nexus.mount.hooks[name] ) then
			nexus.mount.hooks[name] = {};
		end;
		
		for k, v in pairs(nexus.mount.stored) do
			if (SCHEMA != v) then
				if (v[name] and type( v[name] ) == "function") then
					local hooks = nexus.mount.hooks[name];
					
					hooks[#hooks + 1] = {
						Callback = v[name],
						mount = v
					};
				end;
			end;
		end;
	end;
	
	return nexus.mount.hooks[name];
end;

-- A function to register a new mount.
function nexus.mount.Register(mount)
	nexus.mount.stored[mount.name] = mount;
		nexus.mount.stored[mount.name].mounts = {};
	nexus.mount.buffer[mount.folderName] = mount;
	
	for k, v in pairs( g_File.FindInLua(mount.directory.."/mounts/*") ) do
		if (v != ".." and v != ".") then
			table.insert(
				nexus.mount.stored[mount.name].mounts,
				string.lower(v)
			);
		end;
	end;
	
	if ( !nexus.mount.IsUnloaded(mount) ) then
		nexus.mount.IncludeExtras(mount.directory);
		
		if (CLIENT) then
			mount.helpID = nexus.directory.AddCode("Mounts", [[
				<b>
					<font size="3">
						]]..mount.name..[[ <font size="2"><i>by ]]..mount.author..[[</i></font>
					</font>
				</b>
				<br>
				<font size="1">
					<i>]]..mount.description..[[</i>
				</font>
			]], nil, mount.author);
		end;
	end;

	nexus.mount.IncludeMounts(mount.directory);
end;

-- A function to include a mount's entities.
function nexus.mount.IncludeEntities(directory)
	for k, v in pairs( g_File.FindInLua(directory.."/entities/entities/*") ) do
		if (v != ".." and v != ".") then
			ENT = {Type = "anim"};
			
			if (SERVER) then
				include(directory.."/entities/entities/"..v.."/sv_auto.lua");
			elseif ( g_File.Exists("../lua_temp/"..directory.."/entities/entities/"..v.."/cl_auto.lua")
			or g_File.Exists("../gamemodes/"..directory.."/entities/entities/"..v.."/cl_auto.lua") ) then
				include(directory.."/entities/entities/"..v.."/cl_auto.lua");
			end;
			
			scripted_ents.Register(ENT, v); ENT = nil;
		end;
	end;
end;

-- A function to include a mount's effects.
function nexus.mount.IncludeEffects(directory)
	for k, v in pairs( g_File.FindInLua(directory.."/entities/effects/*") ) do
		if (v != ".." and v != ".") then
			if (SERVER) then
				if ( g_File.Exists("../gamemodes/"..directory.."/entities/effects/"..v.."/cl_auto.lua") ) then
					AddCSLuaFile(directory.."/entities/effects/"..v.."/cl_auto.lua");
				end;
			elseif ( g_File.Exists("../lua_temp/"..directory.."/entities/effects/"..v.."/cl_auto.lua")
			or g_File.Exists("../gamemodes/"..directory.."/entities/effects/"..v.."/cl_auto.lua") ) then
				EFFECT = {};
				
				include(directory.."/entities/effects/"..v.."/cl_auto.lua");
				
				effects.Register(EFFECT, v); EFFECT = nil;
			end;
		end;
	end;
end;

-- A function to include a mount's weapons.
function nexus.mount.IncludeWeapons(directory)
	for k, v in pairs( g_File.FindInLua(directory.."/entities/weapons/*") ) do
		if (v != ".." and v != ".") then
			SWEP = { Base = "weapon_base", Primary = {}, Secondary = {} };
			
			if (SERVER) then
				if ( g_File.Exists("../gamemodes/"..directory.."/entities/weapons/"..v.."/sh_auto.lua") ) then
					include(directory.."/entities/weapons/"..v.."/sh_auto.lua");
				end;
			elseif ( g_File.Exists("../lua_temp/"..directory.."/entities/weapons/"..v.."/sh_auto.lua")
			or g_File.Exists("../gamemodes/"..directory.."/entities/weapons/"..v.."/sh_auto.lua") ) then
				include(directory.."/entities/weapons/"..v.."/sh_auto.lua");
			end;
			
			weapons.Register(SWEP, v); SWEP = nil;
		end;
	end;
end;

-- A function to include a mount's derma.
function nexus.mount.IncludeDerma(directory)
	for k, v in pairs( g_File.FindInLua(directory.."/derma/*") ) do
		if (v != ".." and v != ".") then
			if (SERVER) then
				if ( g_File.Exists("../gamemodes/"..directory.."/derma/"..v) ) then
					AddCSLuaFile(directory.."/derma/"..v);
				end;
			elseif ( g_File.Exists("../lua_temp/"..directory.."/derma/"..v)
			or g_File.Exists("../gamemodes/"..directory.."/derma/"..v) ) then
				include(directory.."/derma/"..v);
			end;
		end;
	end;
end;

-- A function to include a mount's overwatch.
function nexus.mount.IncludeOverwatch(directory)
	for k, v in pairs( g_File.FindInLua(directory.."/overwatch/*.lua") ) do
		NEXUS:IncludePrefixed(directory.."/overwatch/"..v);
	end;
end;

-- A function to include a mount's directory.
function nexus.mount.IncludeDirectory(directory)
	for k, v in pairs( g_File.FindInLua(directory.."/directory/*.lua") ) do
		NEXUS:IncludePrefixed(directory.."/directory/"..v);
	end;
end;

-- A function to include a mount's items.
function nexus.mount.IncludeItems(directory)
	for k, v in pairs( g_File.FindInLua(directory.."/items/*.lua") ) do
		NEXUS:IncludePrefixed(directory.."/items/"..v);
	end;
end;

-- A function to include a mount's mounts.
function nexus.mount.IncludeMounts(directory)
	for k, v in pairs( g_File.FindInLua(directory.."/mounts/*") ) do
		if (v != ".." and v != ".") then
			if (CLIENT) then
				if ( g_File.IsDir("../lua_temp/"..directory.."/mounts/"..v) ) then
					nexus.mount.Include(directory.."/mounts/"..v);
				end;
			elseif ( g_File.IsDir("../gamemodes/"..directory.."/mounts/"..v) ) then
				nexus.mount.Include(directory.."/mounts/"..v);
			end;
		end;
	end;
end;

-- A function to include a mount's factions.
function nexus.mount.IncludeFactions(directory)
	for k, v in pairs( g_File.FindInLua(directory.."/factions/*.lua") ) do
		NEXUS:IncludePrefixed(directory.."/factions/"..v);
	end;
end;

-- A function to include a mount's classes.
function nexus.mount.IncludeClasses(directory)
	for k, v in pairs( g_File.FindInLua(directory.."/classes/*.lua") ) do
		NEXUS:IncludePrefixed(directory.."/classes/"..v);
	end;
end;

-- A function to include a mount's attributes.
function nexus.mount.IncludeAttributes(directory)
	for k, v in pairs( g_File.FindInLua(directory.."/attributes/*.lua") ) do
		NEXUS:IncludePrefixed(directory.."/attributes/"..v);
	end;
end;

-- A function to include a mount's extras.
function nexus.mount.IncludeExtras(directory)
	nexus.mount.IncludeEffects(directory);
	nexus.mount.IncludeWeapons(directory);
	nexus.mount.IncludeEntities(directory);
	nexus.mount.IncludeDirectory(directory);
	nexus.mount.IncludeOverwatch(directory);
	nexus.mount.IncludeFactions(directory);
	nexus.mount.IncludeClasses(directory);
	nexus.mount.IncludeAttributes(directory);
	nexus.mount.IncludeDerma(directory);
	nexus.mount.IncludeItems(directory);
end;

-- A function to include a mount.
function nexus.mount.Include(directory, schema)
	local explodeDir = NEXUS:ExplodeString("/", directory);
	local folderName = explodeDir[#explodeDir];
	
	MOUNT_FOLDERNAME = string.lower(folderName);
	MOUNT_DIRECTORY = string.lower(directory);
	MOUNT = nil;
	
	if (SERVER) then
		if (!schema) then
			MOUNT = nexus.mount.New();
		else
			SCHEMA = nexus.mount.New();
		end;
		
		if ( g_File.Exists("../gamemodes/"..directory.."/sh_info.lua") ) then
			include(directory.."/sh_info.lua");
			AddCSLuaFile(directory.."/sh_info.lua");
		else
			Error("nexus - The "..MOUNT_FOLDERNAME.." mount has no sh_info.lua.\n");
		end;
		
		local isUnloaded = nexus.mount.IsUnloaded(MOUNT_FOLDERNAME, true);
		local isDisabled = nexus.mount.IsDisabled(MOUNT_FOLDERNAME, true);
		
		if (schema) then
			isUnloaded = false;
			isDisabled = false;
		end;
		
		if (!isUnloaded and !isDisabled) then
			if ( g_File.Exists("../gamemodes/"..directory.."/sv_auto.lua") ) then
				include(directory.."/sv_auto.lua");
			end;
		end;
		
		if ( g_File.Exists("../gamemodes/"..directory.."/cl_auto.lua") ) then
			AddCSLuaFile(directory.."/cl_auto.lua");
		end;
	else
		if (!schema) then
			MOUNT = nexus.mount.New();
		else
			SCHEMA = nexus.mount.New();
		end;
		
		if ( g_File.Exists("../lua_temp/"..directory.."/sh_info.lua") ) then
			include(directory.."/sh_info.lua");
		else
			Error("nexus - The "..MOUNT_FOLDERNAME.." mount has no sh_info.lua.\n");
		end;
		
		local isUnloaded = nexus.mount.IsUnloaded(MOUNT_FOLDERNAME, true);
		local isDisabled = nexus.mount.IsDisabled(MOUNT_FOLDERNAME, true);
		
		if (schema) then
			isUnloaded = false;
			isDisabled = false;
		end;
		
		if (!isUnloaded and !isDisabled) then
			if ( g_File.Exists("../lua_temp/"..directory.."/cl_auto.lua") ) then
				include(directory.."/cl_auto.lua");
			end;
		end;
	end;
	
	if (schema and SCHEMA) then
		nexus.mount.Register(SCHEMA);
	elseif (MOUNT) then
		nexus.mount.Register(MOUNT);
		
		MOUNT = nil;
	end;
end;

-- A function to create a new mount.
function nexus.mount.New()
	return {
		directory = MOUNT_DIRECTORY,
		folderName = MOUNT_FOLDERNAME
	};
end;

-- A function to call a function for all mounts.
function nexus.mount.Call(name, ...)
	return nexus.mount.CallCachedHook(name, {...}, true);
end;

-- A function to get a mount.
function nexus.mount.Get(name)
	return nexus.mount.stored[name] or nexus.mount.buffer[name];
end;