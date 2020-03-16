--[[
	© CloudSixteen.com
	http://crowlite.com/license
]]--

--[[ Localized Dependencies ]]--
local Crow = Crow;
local CrowNest = Crow.nest;

--[[ Localized Global Functions ]]--
local AddFile = resource.AddFile;
local stringMatch = string.match;
local fileExists = _file.Exists;
local stringSub = string.sub;
local fileFind = _file.Find;
local pairs = pairs;

--[[
	@codebase Shared
	@details Provides various utility methods for use with Crowlite packages and gamemodes.
]]--
local CrowResource = CrowNest:GetLibrary("resource");

--[[
	@codebase Shared
	@details A function to add a file and its related files to the list of files for clients to download if the file exists.
	@params String The path of the file to add for clients to download.
]]--
function CrowResource:AddFile(fileName)
	if (fileExists(fileName, "GAME")) then
		AddFile(fileName);
	end;
end;

--[[
	@codebase Shared
	@details A function to add a directory and optionally all of the directories inside of it to the list of files for clients to download.
	@params String The path of the directory to add to client downloads.
	@params Bool Whether or not to add directories inside of the directory as well.
]]--
function CrowResource:AddDirectory(directory, bRecursive)
	if (stringSub(directory, -1) == "/") then
		directory = directory.."*.*";
	end;
	
	local files, folders = fileFind(directory, "GAME", "namedesc");
	local rawDirectory = stringMatch(directory, "(.*)/").."/";
	
	for k, v in pairs(files) do
		self:AddFile(rawDirectory..v);
	end;
	
	if (bRecursive) then
		for k, v in pairs(folders) do
			if (v != ".." and v != ".") then
				self:AddDirectory(rawDirectory..v, true);
			end;
		end;
	end;
end;