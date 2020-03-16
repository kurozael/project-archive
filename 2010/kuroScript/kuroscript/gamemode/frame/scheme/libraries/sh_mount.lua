--[[
Name: "sh_mount.lua".
Product: "kuroScript".
--]]

kuroScript.mount = {};
kuroScript.mount.hooks = {};
kuroScript.mount.stored = {};

-- A function to call the cached hook.
function kuroScript.mount.CallCachedHook(name, arguments)
	local cachedHooks = kuroScript.mount.CacheHook(name);
	local k, v;
	
	-- Check if a statement is true.
	if (kuroScript.game) then
		if (kuroScript.game[name] and type( kuroScript.game[name] ) == "function") then
			local value = kuroScript.game[name]( kuroScript.game, unpack(arguments) );
			
			-- Check if a statement is true.
			if (value != nil) then
				return value;
			end;
		end;
	end;
	
	-- Loop through each value in a table.
	for k, v in ipairs(cachedHooks) do
		local value = v.callback( v.mount, unpack(arguments) );
		
		-- Check if a statement is true.
		if (value != nil) then
			return value;
		end;
	end;
end;

-- A function to get whether a hook is cached.
function kuroScript.mount.IsHookCached(name)
	return kuroScript.mount.hooks[name] != nil;
end;

-- A function to cache a hook.
function kuroScript.mount.CacheHook(name)
	if ( !kuroScript.mount.IsHookCached(name) ) then
		local k, v;
		
		-- Set some information.
		if ( !kuroScript.mount.hooks[name] ) then
			kuroScript.mount.hooks[name] = {};
		end;
		
		-- Loop through each value in a table.
		for k, v in pairs(kuroScript.mount.stored) do
			if (kuroScript.game != v) then
				if (v[name] and type( v[name] ) == "function") then
					local hooks = kuroScript.mount.hooks[name];
					
					-- Set some information.
					hooks[#hooks + 1] = {
						callback = v[name],
						mount = v
					};
				end;
			end;
		end;
	end;
	
	-- Return the cached hooks.
	return kuroScript.mount.hooks[name];
end;

-- A function to register a new mount.
function kuroScript.mount.Register(mount)
	kuroScript.mount.stored[mount.name] = mount;
	
	-- Include the extras and mounts.
	kuroScript.mount.IncludeExtras(mount.directory)
	kuroScript.mount.IncludeMounts(mount.directory);
end;

-- A function to include a mount's entities.
function kuroScript.mount.IncludeEntities(directory)
	for k, v in pairs( file.FindInLua(directory.."/entities/entities/*") ) do
		if (v != ".." and v != ".") then
			ENT = {Type = "anim"};
			
			-- Check if a statement is true.
			if (SERVER) then
				include(directory.."/entities/entities/"..v.."/sv_autorun.lua");
			elseif ( file.Exists("../lua_temp/"..directory.."/entities/entities/"..v.."/cl_autorun.lua")
			or file.Exists("../gamemodes/"..directory.."/entities/entities/"..v.."/cl_autorun.lua") ) then
				include(directory.."/entities/entities/"..v.."/cl_autorun.lua");
			end;
			
			-- Register the entity.
			scripted_ents.Register(ENT, v); ENT = nil;
		end;
	end;
end;

-- A function to include a mount's effects.
function kuroScript.mount.IncludeEffects(directory)
	for k, v in pairs( file.FindInLua(directory.."/entities/effects/*") ) do
		if (v != ".." and v != ".") then
			if (SERVER) then
				if ( file.Exists("../gamemodes/"..directory.."/entities/effects/"..v.."/cl_autorun.lua") ) then
					AddCSLuaFile(directory.."/entities/effects/"..v.."/cl_autorun.lua");
				end;
			elseif ( file.Exists("../lua_temp/"..directory.."/entities/effects/"..v.."/cl_autorun.lua")
			or file.Exists("../gamemodes/"..directory.."/entities/effects/"..v.."/cl_autorun.lua") ) then
				EFFECT = {};
				
				-- Include a file.
				include(directory.."/entities/effects/"..v.."/cl_autorun.lua");
				
				-- Register the effect.
				effects.Register(EFFECT, v); EFFECT = nil;
			end;
		end;
	end;
end;

-- A function to include a mount's weapons.
function kuroScript.mount.IncludeWeapons(directory)
	for k, v in pairs( file.FindInLua(directory.."/entities/weapons/*") ) do
		if (v != ".." and v != ".") then
			SWEP = { Base = "weapon_base", Primary = {}, Secondary = {} };
			
			-- Check if a statement is true.
			if (SERVER) then
				if ( file.Exists("../gamemodes/"..directory.."/entities/weapons/"..v.."/sh_autorun.lua") ) then
					include(directory.."/entities/weapons/"..v.."/sh_autorun.lua");
				end;
			elseif ( file.Exists("../lua_temp/"..directory.."/entities/weapons/"..v.."/sh_autorun.lua")
			or file.Exists("../gamemodes/"..directory.."/entities/weapons/"..v.."/sh_autorun.lua") ) then
				include(directory.."/entities/weapons/"..v.."/sh_autorun.lua");
			end;
			
			-- Register the weapon.
			weapons.Register(SWEP, v); SWEP = nil;
		end;
	end;
end;

-- A function to include a mount's derma.
function kuroScript.mount.IncludeDerma(directory)
	for k, v in pairs( file.FindInLua(directory.."/scheme/derma/*") ) do
		if (v != ".." and v != ".") then
			if (SERVER) then
				if ( file.Exists("../gamemodes/"..directory.."/scheme/derma/"..v) ) then
					AddCSLuaFile(directory.."/scheme/derma/"..v);
				end;
			elseif ( file.Exists("../lua_temp/"..directory.."/scheme/derma/"..v)
			or file.Exists("../gamemodes/"..directory.."/scheme/derma/"..v) ) then
				include(directory.."/scheme/derma/"..v);
			end;
		end;
	end;
end;

-- A function to include a mount's directory.
function kuroScript.mount.IncludeDirectory(directory)
	for k, v in pairs( file.FindInLua(directory.."/scheme/directory/*.lua") ) do
		kuroScript.frame:IncludePrefixed(directory.."/scheme/directory/"..v);
	end;
end;

-- A function to include a mount's items.
function kuroScript.mount.IncludeItems(directory)
	for k, v in pairs( file.FindInLua(directory.."/scheme/objects/items/*.lua") ) do
		kuroScript.frame:IncludePrefixed(directory.."/scheme/objects/items/"..v);
	end;
end;

-- A function to include a mount's mounts.
function kuroScript.mount.IncludeMounts(directory)
	for k, v in pairs( file.FindInLua(directory.."/mounts/*") ) do
		if (v != ".." and v != ".") then
			kuroScript.mount.Include(directory.."/mounts/"..v);
		end;
	end;
end;

-- A function to include a mount's classes.
function kuroScript.mount.IncludeClasses(directory)
	for k, v in pairs( file.FindInLua(directory.."/scheme/classes/*.lua") ) do
		kuroScript.frame:IncludePrefixed(directory.."/scheme/classes/"..v);
	end;
end;

-- A function to include a mount's vocations.
function kuroScript.mount.IncludeVocations(directory)
	for k, v in pairs( file.FindInLua(directory.."/scheme/vocations/*.lua") ) do
		kuroScript.frame:IncludePrefixed(directory.."/scheme/vocations/"..v);
	end;
end;

-- A function to include a mount's attributes.
function kuroScript.mount.IncludeAttributes(directory)
	for k, v in pairs( file.FindInLua(directory.."/scheme/objects/attributes/*.lua") ) do
		kuroScript.frame:IncludePrefixed(directory.."/scheme/objects/attributes/"..v);
	end;
end;

-- A function to include a mount's extras.
function kuroScript.mount.IncludeExtras(directory)
	kuroScript.mount.IncludeEffects(directory);
	kuroScript.mount.IncludeWeapons(directory);
	kuroScript.mount.IncludeEntities(directory);
	kuroScript.mount.IncludeDirectory(directory);
	kuroScript.mount.IncludeClasses(directory);
	kuroScript.mount.IncludeVocations(directory);
	kuroScript.mount.IncludeAttributes(directory);
	kuroScript.mount.IncludeDerma(directory);
	kuroScript.mount.IncludeItems(directory);
end;

-- A function to include a mount.
function kuroScript.mount.Include(directory, game)
	MOUNT_DIRECTORY = directory; MOUNT = nil;
	
	-- Check if a statement is true.
	if (SERVER) then
		if ( file.Exists("../gamemodes/"..directory.."/sv_autorun.lua") ) then
			if (game) then
				kuroScript.game = kuroScript.mount.New();
			else
				MOUNT = kuroScript.mount.New();
			end;
			
			-- Include a file.
			include(directory.."/sv_autorun.lua");
		end;
		
		-- Check if a statement is true.
		if ( file.Exists("../gamemodes/"..directory.."/cl_autorun.lua") ) then
			AddCSLuaFile(directory.."/cl_autorun.lua");
		end;
	elseif ( file.Exists("../lua_temp/"..directory.."/cl_autorun.lua") or file.Exists("../gamemodes/"..directory.."/cl_autorun.lua") ) then
		if (game) then
			kuroScript.game = kuroScript.mount.New();
		else
			MOUNT = kuroScript.mount.New();
		end;
		
		-- Include a file.
		include(directory.."/cl_autorun.lua");
	end;
	
	-- Check if a statement is true.
	if (game and kuroScript.game) then
		kuroScript.mount.Register(kuroScript.game);
	elseif (MOUNT) then
		kuroScript.mount.Register(MOUNT);
		
		-- Set some information.
		MOUNT = nil;
	end;
end;

-- A function to create a new mount.
function kuroScript.mount.New()
	return {directory = MOUNT_DIRECTORY};
end;

-- A function to call a function for all mounts.
function kuroScript.mount.Call(name, ...)
	return kuroScript.mount.CallCachedHook( name, {...} );
end;

-- A function to get a mount.
function kuroScript.mount.Get(name)
	return kuroScript.mount.stored[name];
end;