--[[ 
	© CloudSixteen.com
	http://crowlite.com/license
]]--

--[[ Localized Dependencies ]]--
local Crow = Crow;
local CrowNest = Crow.nest;
local CrowUtil = CrowNest:GetLibrary("util");

--[[ Localize Tables ]]--
local scripted_ents = scripted_ents;
local gamemode = gamemode;
local effects = effects;
local weapons = weapons;
local string = string;
local debug = debug;
local _file = _file;
local ents = ents;
local hook = hook;

--[[ Localize Methods ]]--
local isstring = isstring;
local istable = istable;
local unpack = unpack;
local ipairs = ipairs;
local pairs = pairs;
local pcall = pcall;

--[[ Create Library ]]--
local CrowPackage = CrowNest:GetLibrary("package");

--[[ Private Members ]]--
CrowPackage.__activeGamemode = CrowPackage.__activeGamemode or nil;
CrowPackage.__activePackages = CrowPackage.__activePackages or {};
CrowPackage.__metadata = CrowPackage.__metadata or {};
CrowPackage.__bootdata = CrowPackage.__bootdata or {};
CrowPackage.__gamemodes = CrowPackage.__gamemodes or {};
CrowPackage.__packages = CrowPackage.__packages or {};
CrowPackage.__modules = CrowPackage.__modules or {};
CrowPackage.__extras = CrowPackage.__extras or {};

--[[ Initialize the cache where all package hooks will be called from. ]]--
local hookCache = {};

--[[
	@codebase Shared
	@details A function that will return the package library's local hook cache.
	@returns Table The hook cache that contains all hooks from currently active packages, gamemodes and modules.
]]--
function CrowPackage:GetHookCache()
	return hookCache;
end;

--[[
	@codebase Shared
	@details A function to get the original table (not a copy) of scripted entities.
	@returns Table The original table full of all registered SENTs.
]]--
function scripted_ents.GetSENTList()
	local name, sentList = debug.getupvalue(scripted_ents.GetStored, 1);

	return sentList;
end;

--[[
	@codebase Shared
	@details A function to create a new package table.
	@returns Package The newly created package table.
]]--
function CrowPackage:New()
	return CrowNest:NewInstance(CROW_PACKAGE);
end;

--[[
	@codebase Shared
	@details A function to return the stored table, containing all the currently included packages.
	@returns Table The stored table which contains all the currently included packages.
]]--
function CrowPackage:GetAll()
	return self.__packages;
end;

--[[
	@codebase Shared
	@details A function to return the table of packages, containing all the currently active packages.
	@returns Table The stored table which contains all the currently active packages.
]]--
function CrowPackage:GetActivePackages()
	return self.__activePackages;
end;

--[[
	@codebase Shared
	@details A function to save a package table to the list of stored packages.
	@params Package The package table to save to the stored packages table.
]]--
function CrowPackage:Register(packageTable)
	self.__packages[packageTable.folderName] = packageTable;
end;

--[[
	@codebase Shared
	@details A function to find a stored package table by its folder name and remove it.
	@params String The folder name of the package to find and remove.
]]--
function CrowPackage:RemoveByID(id)
	id = string.lower(id);
	
	if (self.__packages[id]) then
		self.__packages[id] = nil;
	end;
end;

--[[
	@codebase Shared
	@details A function to find a stored package table by its folder name.
	@params String The folder name of the package to search for.
	@returns Package The stored package table, if it exists.
]]--
function CrowPackage:FindByID(id)
	id = string.lower(id);
	
	return self.__packages[id];
end;

--[[
	@codebase Shared
	@details A function to save a gamemode table to the list of stored gamemodes.
	@params Package The gamemode table to save to the stored gamemodes table.
]]--
function CrowPackage:RegisterGamemode(packageTable)
	self.__gamemodes[packageTable.folderName] = packageTable;
end;

--[[
	@codebase Shared
	@details A function to find a stored gamemode table by its folder name and remove it.
	@params String The folder name of the gamemode to find and remove.
]]--
function CrowPackage:RemoveGamemode(id)
	id = string.lower(id);
	
	if (self.__gamemodes[id]) then
		self.__gamemodes[id] = nil;
	end;
end;

--[[
	@codebase Shared
	@details A function to find a stored gamemode table by its name.
	@params String The name of the gamemode to search for.
	@returns Package The stored gamemode table, if it exists.
]]--
function CrowPackage:FindGamemode(id)
	return self.__gamemodes[string.lower(id)];
end;

--[[
	@codebase Shared
	@details A function to get all the currently stored gamemodes.
	@params Table The table containing all of the currently stored gamemodes.
]]--
function CrowPackage:GetAllGamemodes()
	return self.__gamemodes;
end;

--[[
	@codebase Shared
	@details A function to add a package module to the stored module table.
	@params String The name of the module, if the table doesn't already have a name set.
	@params Table The module table to add.
]]--
function CrowPackage:AddModule(name, moduleTable)
	if (!moduleTable.name) then
		moduleTable.name = name;
	end;

	self.__modules[string.lower(moduleTable.name)] = moduleTable;

	for k, v in pairs(moduleTable) do
		if (isfunction(v)) then
			hookCache[k] = hookCache[k] or {};
			hookCache[k][name] = {v, moduleTable};
		end;
	end;
end;

--[[
	@codebase Shared
	@details A function to find a stored package module by its name.
	@params String The name of the module to search the stored module table for.
	@returns Table The stored module table, if found.
]]--
function CrowPackage:FindModule(name)
	return self.__modules[string.lower(name)];
end;

--[[
	@codebase Shared
	@details A function to find a stored package module by its name and remove it.
	@params String The name of the module to search for and remove.
]]--
function CrowPackage:RemoveModule(name)
	local moduleTable = self.__modules[string.lower(name)];

	if (moduleTable) then
		for k, v in pairs(moduleTable) do
			if (isfunction(v)) then
				if (hookCache[k]) then
					hookCache[k][name] = nil;

					if (#hookCache[k] == 0) then
						hookCache[k] = nil;
					end;
				end;
			end;
		end;	
	end;

	self.__modules[string.lower(name)] = nil;
end;

--[[
	@codebase Shared
	@details A function to get all the currently stored package modules.
	@params Table The table containing all of the currently stored package modules.
]]--
function CrowPackage:GetAllModules()
	return self.__modules;
end;

--[[
	@codebase Shared
	@details A function to run a hook from all loaded packages and/or the gamemode.
	@params String The name of the hook to run.
	@params Bool Whether to run hooks on the gamemode itself.
	@params vararg The arguments to be used with the hook.
]]--
function CrowPackage:Call(name, useGamemode, ...)
	if (hookCache[name]) then
		for k, v in pairs(hookCache[name]) do
			local wasSuccess, value = pcall(v[1], v[2], ...);
				
			if (!wasSuccess) then
				CrowNest:LogError("Package::"..v[2].name, "The '"..name.."' hook has failed to run.\n"..value.."\n");
			elseif (value != nil) then
				return value;
			end;
		end;
	end;

	if (useGamemode and Crow[name]) then
		local wasSuccess, value = pcall(Crow[name], Crow, ...);
		
		if (!wasSuccess) then
			CrowNest:LogError("Package::Framework", "The '"..name.."' hook has failed to run.\n"..value.."\n");
		elseif (value != nil) then
			return value;
		end;
	end;
end;

--[[
	@codebase Shared
	@details A function to run a hook on all loaded packages and the gamemode.
	@params String The name of the hook to run.
	@params vararg The arguments to call the hook with.
]]--
function CrowPackage:CallAll(name, ...)
	return self:Call(name, true, ...);
end;

--[[
	@codebase Shared
	@details A function to include all entities inside a certain directory.
	@params String The directory of entities to be included.
]]--
function CrowPackage:IncludeEntities(directory, parentTable, dontInclude)
	local files, entityFolders = _file.Find(directory.."/entities/entities/*", "LUA", "namedesc");

	for k, v in pairs(entityFolders) do
		if (v != ".." and v != ".") then
			if (dontInclude) then
				CrowNest:IncludeDirectory(directory.."/entities/weapons/"..v.."/", true);

				continue;
			end;

			ENT = {Type = "anim", Folder = directory.."/entities/entities/"..v};

			CrowNest:IncludeDirectory(directory.."/entities/entities/"..v.."/");

			if (parentTable) then
				parentTable.extras.entities[#parentTable.extras.entities + 1] = v;
			end;
			
			scripted_ents.Register(ENT, v); ENT = nil;
		end;
	end;
end;

--[[
	@codebase Shared
	@details A function to include all effects inside a certain directory.
	@params String The directory of effects to be included.
]]--
function CrowPackage:IncludeEffects(directory, parentTable, dontInclude)
	local files, effectFolders = _file.Find(directory.."/entities/effects/*", "LUA", "namedesc");
	
	for k, v in pairs(effectFolders) do
		if (v != ".." and v != ".") then
			if (dontInclude) then
				CrowNest:IncludeDirectory(directory.."/entities/weapons/"..v.."/", true);

				continue;
			end;

			EFFECT = {Folder = directory.."/entities/effects/"..v};

			CrowNest:IncludeDirectory(directory.."/entities/effects/"..v.."/");

			if (parentTable) then
				parentTable.extras.effects[#parentTable.extras.effects + 1] = v;
			end;

			effects.Register(EFFECT, v); EFFECT = nil;
		end;
	end;
end;

--[[
	@codebase Shared
	@details A function to include all weapons inside a certain directory.
	@params String The directory of weapons to be included.
]]--
function CrowPackage:IncludeWeapons(directory, parentTable, dontInclude)
	local files, weaponFolders = _file.Find(directory.."/entities/weapons/*", "LUA");

	for k, v in pairs(weaponFolders) do
		if (v != ".." and v != ".") then
			if (dontInclude) then
				CrowNest:IncludeDirectory(directory.."/entities/weapons/"..v.."/", true);

				continue;
			end;

			SWEP = { Folder = directory.."/entities/weapons/"..v, Base = "weapon_base", Primary = {}, Secondary = {} };
			
			CrowNest:IncludeDirectory(directory.."/entities/weapons/"..v.."/");

			if (parentTable) then
				parentTable.extras.weapons[#parentTable.extras.weapons + 1] = v;
			end;
			
			weapons.Register(SWEP, v); SWEP = nil;
		end;
	end;
end;

--[[
	@codebase Shared
	@details A function to add a folder name that will be checked for and included in every package and gamemode.
	@params String The name of the folder to add to the extras list.
]]--
function CrowPackage:AddExtra(folderName)
	self.__extras[folderName] = true;
end;

--[[
	@codebase Shared
	@details A function to get the list of all folder names that will be checked for and included in every package and gamemode.
	@returns Table The table of extras.
]]--
function CrowPackage:GetExtras()
	return self.__extras;
end;

--[[
	@codebase Shared
	@details A function to load all the extras (including entities, effects, and weapons) from a certain directory.
	@params String The directory to check and include extras inside.
]]--
function CrowPackage:IncludeExtras(directory, parentTable, dontInclude)
	self:IncludeEntities(directory, parentTable, dontInclude);
	self:IncludeEffects(directory, parentTable, dontInclude);
	self:IncludeWeapons(directory, parentTable, dontInclude);

	for k, v in pairs(self.__extras) do
		CrowNest:IncludeDirectory(directory..k, dontInclude);
	end;
end;

--[[
	@codebase Shared
	@details A function to remove all the entities, effects, and weapons that have been loaded from a package.
	@params Package The package to check for extras to remove.
]]--
function CrowPackage:RemoveExtras(package)
	for k, v in pairs(package.extras.entities) do
		for k2, v2 in pairs(ents.FindByClass(v)) do
			v2:Remove();
		end;

		local SENTList = scripted_ents.GetSENTList();

		if (SENTList and SENTList[k]) then
			SENTList[k] = nil;
		end;
	end;

	for k, v in pairs(package.extras.weapons) do
		local weaponTable = weapons.GetList();

		for k2, v2 in ipairs(weaponTable) do
			if (v2.ClassName == v) then
				weaponTable[k2] = nil;

				break;
			end;
		end;
	end;
end;

--[[
	@codebase Shared
	@details A function to copy metadata information to a package table.
	@params Package The package table to copy metadata to.
	@params Table A table of metadata, ideally from metadata.json.
]]--
function CrowPackage:CopyMetadata(package, metadata)
	local validFields = {"name", "author", "website", "version", "description"};
	local folderName = package.folderName;
	
	for k, v in ipairs(validFields) do
		if (metadata[v]) then
			package[v] = metadata[v];
		else
			CrowNest:LogError("Package::"..folderName, "metadata.json does not contain a '"..v.."' field!");
			return false;
		end;
	end;
	
	if (metadata.namespace) then
		package:SetNamespace(metadata.namespace);
	end;
	
	return true;
end;

--[[
	@codebase Shared
	@details A function to include either a package or gamemode made for Crowlite.
	@params String The directory of the package to be included.
	@params Bool Whether or not the package being included is a gamemode or not.
]]--
function CrowPackage:Include(directory, isGamemode, parentName)
	local explodeDir = string.Explode("/", directory);
	local folderName = explodeDir[#explodeDir];
	
	if (isGamemode) then
		if (self.__gamemodes[folderName]) then
			return;
		end;
	elseif (self.__packages[folderName]) then
		return;
	end;

	local metadata = self.__metadata[folderName];
	
	if (metadata == nil) then
		CrowNest:LogError("Package::"..folderName, "Unable to load metadata for this package!");
		return;
	end;
	
	if (metadata.dependencies) then
		for k, v in pairs(metadata.dependencies) do
			local dependency = self.__metadata[k];
			
			if (dependency) then
				local version = dependency.version;
				
				if (version.major >= v.major and version.minor >= v.minor and version.patch >= v.patch) then
					if (metadata.parentName != dependency.folderName) then
						self:Include(dependency.directory, dependency.isGamemode, dependency.parentName);
					end;
				else
					CrowNest:LogError("Package::"..folderName, "Package requires dependency '"..k.."' version "..v.string.." or better!");
					return;
				end;
			else
				CrowNest:LogError("Package::"..folderName, "Unable to locate package dependency '"..k.."'!");
				return;
			end;
		end;
	end;
	
	PACKAGE = self:New();
	
	if (parentName) then
		PACKAGE.parent = parentName;
	end;

	PACKAGE.baseDir = directory;
	PACKAGE.folderName = folderName;
	
	if (not self:CopyMetadata(PACKAGE, metadata)) then
		return;
	end;
	
	if (!isGamemode) then
		if (_file.Exists(directory.."/sh_boot.lua", "LUA")) then
			CrowNest:IncludeFile(directory.."/sh_boot.lua");
		else
			CrowNest:LogWarning("Package::"..folderName, "This package has no sh_boot.lua!");
		end;
		
		PACKAGE:Register();
		
		self:IncludeExtras(directory);
		self:IncludePackages(directory, PACKAGE.folderName);
	else
		CrowGM = PACKAGE;

		if (!self:CallAll("PreIncludeGamemodeBoot", directory)) then
			if (_file.Exists(directory.."/sh_boot.lua", "LUA")) then
				CrowNest:IncludeFile(directory.."/sh_boot.lua");
			else
				CrowNest:LogWarning("Gamemode::"..folderName, "This gamemode has no sh_boot.lua!");
			end;
		end;
		
		self:IncludeExtras(directory);
		self:IncludePackages(directory, CrowGM.folderName);
		self:RegisterGamemode(CrowGM);

		CrowGM = nil;
	end;

	if (isGamemode) then
		CrowNest:LogSuccess("Gamemode::"..folderName, "Gamemode has been registered without errors.");
	else
		CrowNest:LogSuccess("Package::"..folderName, "Package has been registered without errors.");
	end;
	
	PACKAGE = nil;
end;

--[[
	@codebase Shared
	@details A function to load a package, along with all of its packages and extras.
	@params Package The package table to load, can also be a string of the package's folder name.
]]--
function CrowPackage:LoadPackage(package)
	if (isstring(package)) then
		package = self:FindByID(package);
	end
	
	if (package and istable(package)) then
		self.__activePackages[package.folderName] = package;		

		for k, v in pairs(package) do
			if (isfunction(v)) then
				hookCache[k] = hookCache[k] or {};
				hookCache[k][package.folderName] = {v, package};
			end;
		end;

		if (package.OnInitialize) then
			package:OnInitialize();
		end;
	end;
end;

--[[
	@codebase Shared
	@details A function to unload a package, along with all of its packages and extras.
	@params Package The package table to unload, can also be a string of the package's name.
]]--
function CrowPackage:UnloadPackage(package)
	if (isstring(package)) then
		package = self:FindByID(package);
	end

	if (package and istable(package)) then
		for k, v in pairs(package) do
			if (isfunction(v)) then
				if (hookCache[k]) then
					hookCache[k][package.folderName] = nil;

					if (#hookCache[k] == 0) then
						hookCache[k] = nil;
					end;
				end;
			end;
		end;

		if (package.OnUnloaded) then
			package:OnUnloaded();
		end;

		self.__activePackages[package.folderName] = nil;

		if (CLIENT and LocalPlayer) then
			local client = LocalPlayer();
			
			if (IsValid(client)) then
				client:ConCommand("spawnmenu_reload");
			end;
		end;
	end;
end;

--[[
	@codebase Shared
	@details A function to load a gamemode, along with all of its packages and extras.
	@params Package The gamemode table to load, can also be a string of the gamemode's folder name.
	@params Boolean Whether to force the gamemode to load, regardless of if it's the same as the active gamemode (used for auto refresh).
]]--
function CrowPackage:LoadGamemode(gameTable, forceLoad)
	if (isstring(gameTable)) then
		gameTable = self:FindGamemode(gameTable);
	end

	if (gameTable and istable(gameTable)) then
		local canLoad = true;

		if (self.__activeGamemode) then
			if (self.__activeGamemode.folderName != gameTable.folderName) then
				self:UnloadGamemode(self.__activeGamemode);
			elseif (!forceLoad) then
				canLoad = false;
			end;
		end;
		
		if (canLoad) then
			self.__activeGamemode = gameTable;
			
			if (SERVER) then
				jsonstream.Send("crow-gamemode", {gameTable.folderName}, _player.GetAll());
			end;

			for k, v in pairs(gameTable) do
				if (isfunction(v)) then
					hookCache[k] = hookCache[k] or {};
					hookCache[k][gameTable.folderName] = {v, gameTable};
				end;
			end;

			if (gameTable.OnInitialize) then
				gameTable:OnInitialize();
			end;

			CrowNest:Log("Package", "Successfully loaded the "..gameTable.name.." gamemode!", true);
		end;
	end;
end;

--[[
	@codebase Shared
	@details A function to unload a gamemode, along with all of its packages and extras.
	@params Package The gamemode table to unload, can also be a string of the gamemode's name.
]]--
function CrowPackage:UnloadGamemode(gameTable)
	if (isstring(gameTable)) then
		gameTable = self:FindGamemode(gameTable);
	end

	if (gameTable and istable(gameTable)) then
		for k, v in pairs(gameTable) do
			if (isfunction(v)) then
				if (hookCache[k]) then
					hookCache[k][gameTable.folderName] = nil;

					if (#hookCache[k] == 0) then
						hookCache[k] = nil;
					end;
				end;
			end;
		end;

		if (gameTable.OnUnloaded) then
			gameTable:OnUnloaded();
		end;
		
		self.__activeGamemode = nil;
	end;
end;

--[[
	@codebase Shared
	@details A function to unload all of a package's child packages.
	@params String The name of the package to check for child packages to unload.
]]--
function CrowPackage:UnloadChildPackages(packageName)
	for k, v in pairs(self.__activePackages) do
		if (v.parent and string.lower(v.parent) == string.lower(packageName)) then
			self:UnloadPackage(k);
		end;
	end;
end;

--[[
	@codebase Shared
	@details A function to include all gamemodes made for Crowlite inside a certain directory.
	@params String The directory of gamemodes to be included.
]]--
function CrowPackage:IncludeGamemodes(directory)
	local files, folders = _file.Find(directory.."/gamemodes/*", "LUA", "namedesc");

	for k, v in pairs(folders) do
		self:Include(directory.."/gamemodes/"..v, true);
	end;
end;

--[[
	@codebase Shared
	@details A function to include all packages inside a certain directory.
	@params String The directory of packages to be included.
]]--
function CrowPackage:IncludePackages(directory, parentName)
	local files, folders = _file.Find(directory.."/packages/*", "LUA", "namedesc");

	for k, v in pairs(folders) do
		self:Include(directory.."/packages/"..v, nil, parentName);
	end;
end;

function CrowPackage:ReadMetadata(directory, parentName)
	local explodeDir = string.Explode("/", directory);
	local folderName = explodeDir[#explodeDir];
	
	if (SERVER) then
		if (!self:CallAll("PreReadPackageMetadata", directory, folderName, parentName)) then
			if (_file.Exists(directory.."/metadata.json", "LUA")) then
				local metadata = util.JSONToTable(_file.Read(directory.."/metadata.json", "LUA"));
				
				if (!metadata) then
					CrowNest:LogError("Package::"..folderName, "metadata.json is not readable or is an invalid format!");
					return;
				end;
				
				metadata.version = CrowUtil:VersionToTable(metadata.version);
				metadata.directory = directory;
				metadata.folderName = folderName;
				metadata.parentName = parentName;
				
				if (metadata.dependencies) then
					for k, v in pairs(metadata.dependencies) do
						metadata.dependencies[k] = CrowUtil:VersionToTable(v);
					end;
				end;
				
				return metadata;
			else
				CrowNest:LogError("Package::"..folderName, "This package has no metadata.json!");
				return;
			end;
		end;
	elseif (not self.__bootdata[folderName]) then
		CrowNest:LogError("Package::"..folderName, "This package has no metadata in the bootdata table!");
		return;
	else
		return self.__bootdata[folderName];
	end;
end;

function CrowPackage:LoadMetadata(directory, parentName, searchFolder)
	local files, folders = _file.Find(directory.."/"..searchFolder.."/*", "LUA", "namedesc");

	for k, v in pairs(folders) do
		local checkFolder = directory.."/"..searchFolder.."/"..v;
		local metadata = self:ReadMetadata(checkFolder, parentName);
		
		if (metadata) then
			self.__metadata[metadata.folderName] = metadata;
			
			if (SERVER) then
				self.__bootdata[metadata.folderName] = metadata;
				
				if (searchFolder == "gamemodes") then
					metadata.isGamemode = true;
				end;
			end;
		end;
		
		self:LoadMetadata(checkFolder, v, "packages");
	end;
end;

--[[
	@codebase Shared
	@details A function to include all packages, gamemodes and extras from the Crowlite gamemode folder.
]]--
function CrowPackage:Initialize()
	self.__bootdata = CrowNest:GetBootdata("packages");
	self.__gamemodes = {};
	self.__packages = {};

	if (CLIENT) then
		if (self.__bootdata == nil) then
			CrowNest:LogError("Package", "Critical error! No 'packages' bootdata could be found!");
			return;
		end;
	else
		self.__bootdata = CrowNest:SetBootdata("packages", {});
	end;

	self:LoadMetadata("crowlite/gamemode", nil, "packages");
	self:IncludePackages("crowlite/gamemode");

	self:LoadMetadata("crowlite/gamemode", nil, "gamemodes");
	self:IncludeGamemodes("crowlite/gamemode");
	
	self:IncludeExtras("crowlite/gamemode/framework");

	for k, v in pairs(self.__packages) do
		self:LoadPackage(k);
	end;
	
	if (SERVER) then
		local folderName = "sandbox";
		local lastGM = self.__activeGamemode;
		local GMConvar = GetConVar("crow_gamemode");

		if (GMConvar) then
			local convarString = GMConvar:GetString();

			if (convarString) then
				folderName = convarString;
			end;
		end;

		if (lastGM) then
			folderName = lastGM.folderName;	
		end;
	
		self:LoadGamemode(folderName);
	end;
end;

--[[
	@codebase Shared
	@details A function to get the currently loaded and active gamemode table.
	@returns Package The active gamemode table itself, in the form of a package object.
]]--
function CrowPackage:GetActiveGamemode()
	return self.__activeGamemode;
end;

--[[
	This is a hack to allow us to call package hooks based
	on default GMod hooks that are called.

	It modifies the hook.Call funtion to call hooks inside Crowlite packages 
	and gamemodes as well as hooks that are added normally with hook.Add.
]]--
hook.__CrowCall = hook.__CrowCall or hook.Call;

function hook.Call(name, gamemode, ...)
	local arguments = {...};
	local wasSuccess, value = pcall(CrowPackage.Call, CrowPackage, name, nil, unpack(arguments));

	if (!wasSuccess) then
		CrowNest:LogError("Hook", "The '"..name.."' hook has failed to run.\n"..value.."\n");
	end;

	if (value == nil) then
		local wasSuccess, a, b, c = pcall(hook.__CrowCall, name, gamemode or Crow, unpack(arguments));

		if (!wasSuccess) then
			CrowNest:LogError("Hook", "The '"..name.."' hook has failed to run.\n"..a.."\n");
		else
			return a, b, c;
		end;
	else
		return value;
	end;
end;

if (SERVER) then
	concommand.Add("crow", function(ply, cmd, args, argStr)
		print("AAAA");
		PrintTable(args);
		if (args[1] == "gamemode") then
			CrowPackage:LoadGamemode(args[2]);
		end;
	end);
else
	jsonstream.Receive("crow-gamemode", function(data)
		CrowPackage:LoadGamemode(data[1]);
	end);
end;