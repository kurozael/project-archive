--[[ 
	© CloudSixteen.com
	http://crowlite.com/license
]]--

--[[ Localized Dependencies ]]--
local Crow = Crow;

--[[ Localized Tables ]]--
local string = string;
local _file = _file;

--[[ Localized Methods ]]--
local FindMetaTable = FindMetaTable;
local setmetatable = setmetatable;
local AddCSLuaFile = AddCSLuaFile;
local include = include;
local pcall = pcall;
local pairs = pairs;
local MsgN = MsgN;
local stringFind = string.find;
local stringSub = string.sub;
local _fileFind = _file.Find;

--[[ Create Nest Table ]]--
if (!Crow.nest) then
	Crow.nest = {};
end;

--[[ Private Members ]]--
Crow.nest.__version = nil;
Crow.nest.__bootdata = Crow.nest.__bootdata or {};

--[[
	@codebase Shared
	@details A function to return the version information of the Crowlite framework.
	@returns Table Returns a table with 'string', 'major', 'minor', 'patch' and 'name'.
]]--
function Crow.nest:GetVersion()
	if (not self.__version) then
		self.___version = Crow.util:VersionToTable(Crow.BuildVersion);
		self.___version.name = Crow.BuildName;
	end;

	return self.__version;
end;

--[[
	@codebase Shared
	@details A function to create an instance from a metatable.
	@params Table The metatable to create an instance from.
	@returns Table The newly created metatable instance.
]]--
function Crow.nest:NewInstance(baseTable)
	local instance = {};
		setmetatable(instance, baseTable);
		baseTable.__index = baseTable;
	return instance;
end;

--[[
	@codebase Shared
	@details A function to easily include files, will take filenames into account when determining codebase (sh_, cl_, sv_, shared, cl_init).
	@params String The directory and name of the file to include.
]]--
function Crow.nest:IncludeFile(fileName, dontInclude)
	local isShared = (stringFind(fileName, "sh_") or stringFind(fileName, "shared.lua"));
	local isServer = (stringFind(fileName, "sv_") or (!isClient and stringFind(fileName, "init.lua")));
	local isClient = stringFind(fileName, "cl_");
	
	if (isServer and !SERVER) then
		return;
	end;
	
	if ((isShared or isClient) and SERVER) then
		AddCSLuaFile(fileName);

		if (isClient) then return; end;
	end;
	
	if (!dontInclude) then
		local wasSuccess, err = pcall(include, fileName);
		
		if (!wasSuccess) then
			Crow.nest:LogWarning("FileSystem", err);
		end;
	end;
end;

--[[
	@codebase Shared
	@details A function to easily include a directory of files, will use IncludeFile function from the nest table.
	@params String The name of the directory to include.
	@params Bool Whether or not the directory is part of the nest Crow directory (/metronome/gamemode/framework/).
]]--
function Crow.nest:IncludeDirectory(directory, fromBase, dontInclude)
	if (fromBase) then
		directory = "crowlite/gamemode/framework/"..directory;
	end;
	
	if (stringSub(directory, -1) != "/") then
		directory = directory.."/";
	end;
	
	for k, v in pairs(_fileFind(directory.."*.lua", "LUA", "namedesc")) do
		self:IncludeFile(directory..v, dontInclude);
	end;
end;

local LOG_COLOR_RED = Color(255, 100, 0, 255);
local LOG_COLOR_WHITE = Color(255, 255, 255, 255);
local LOG_COLOR_YELLOW = Color(225, 225, 105, 255);
local LOG_COLOR_GREY = Color(200, 200, 200, 255);
local LOG_COLOR_GREEN = Color(50, 225, 50, 255);

--[[
	@codebase Shared
	@details A function to log out an error to the console.
	@params String The log namespace to use.
	@params String The log content to print to the console.
	@params Bool Whether or not to isolate the log with extra spacing.
]]--
function Crow.nest:LogError(namespace, content, isolate)
	if (isolate != false) then
		MsgC(LOG_COLOR_RED, "Error::Crowlite::"..namespace.."\n", LOG_COLOR_WHITE, content.."\n\n");
	else
		MsgC(LOG_COLOR_RED, "Error::Crowlite::"..namespace.." -> ", LOG_COLOR_WHITE, content.."\n");
	end;
end;

--[[
	@codebase Shared
	@details A function to log out a success message to the console.
	@params String The log namespace to use.
	@params String The log content to print to the console.
	@params Bool Whether or not to isolate the log with extra spacing.
]]--
function Crow.nest:LogSuccess(namespace, content, isolate)
	if (isolate != false) then
		MsgC(LOG_COLOR_GREEN, "Crowlite::"..namespace.."\n", LOG_COLOR_WHITE, content.."\n\n");
	else
		MsgC(LOG_COLOR_GREEN, "Crowlite::"..namespace.." -> ", LOG_COLOR_WHITE, content.."\n");
	end;
end;

--[[
	@codebase Shared
	@details A function to log out a warning to the console.
	@params String The log namespace to use.
	@params String The log content to print to the console.
	@params Bool Whether or not to isolate the log with extra spacing.
]]--
function Crow.nest:LogWarning(namespace, content, isolate)
	if (isolate != false) then
		MsgC(LOG_COLOR_YELLOW, "Warning::Crowlite::"..namespace.."\n", LOG_COLOR_WHITE, content.."\n\n");
	else
		MsgC(LOG_COLOR_YELLOW, "Warning::Crowlite::"..namespace.." -> ", LOG_COLOR_WHITE, content.."\n");
	end;
end;

--[[
	@codebase Shared
	@details A function to log out to the console.s
	@params String The log namespace to use.
	@params String The log content to print to the console.
	@params Bool Whether or not to isolate the log with extra spacing.
]]--
function Crow.nest:Log(namespace, content, isolate)
	if (isolate != false) then
		MsgC(LOG_COLOR_GREY, "Crowlite::"..namespace.."\n", LOG_COLOR_WHITE, content.."\n\n");
	else
		MsgC(LOG_COLOR_GREY, "Crowlite::"..namespace.." -> ", LOG_COLOR_WHITE, content.."\n");
	end;
end;

--[[
	@codebase Shared
	@details Locate bootdata by its unique key.
	@params String The unique key to search for.
	@returns Untyped Any bootdata that was found in the table.
]]--
function Crow.nest:GetBootdata(key)
	return self.__bootdata[key];
end;

if (SERVER) then
	--[[
		@codebase Server
		@details Set bootdata by a unique key and its value.
		@params String The unique key to identify this data by.
		@params Untyped The value of this bootdata.
		@returns Untyped The same value passed in to the method.
	]]--
	function Crow.nest:SetBootdata(key, value)
		self.__bootdata[key] = value;
		
		return self.__bootdata[key];
	end;
else
	--[[
		@codebase Client
		@details Set the entire bootdata table to a new value.
		@params Table The table reference to set the bootdata to.
	]]--
	function Crow.nest:SetBootdata(value)
		self.__bootdata = value;
	end;
end;

--[[
	@codebase Shared
	@details A function to create a new library, or return the current one if it already exists.
	@params String The desired name of the new library.
	@returns Table The new library created, or the existing one of it exists.
]]--
function Crow.nest:GetLibrary(libName)
	if (!Crow[libName]) then
		Crow[libName] = self:NewInstance(CROW_LIBRARY);
	end;

	return Crow[libName];
end;