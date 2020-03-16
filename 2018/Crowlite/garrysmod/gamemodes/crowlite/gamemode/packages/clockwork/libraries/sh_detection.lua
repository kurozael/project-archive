--[[ 
	© CloudSixteen.com
	http://crowlite.com/license
--]]

local CrowNest = Crow.nest;
local CrowPackage = CrowNest:GetLibrary("package");
local CrowUtil = CrowNest:GetLibrary("util");

local DetectCW = {};

function DetectCW:PreIncludeGamemodeBoot(sDirectory)
	if (_file.Exists(sDirectory.."/schema/sh_schema.lua", "LUA")) then
		Schema = CrowGM;

		CrowNest:IncludeFile(sDirectory.."/schema/sh_schema.lua");

		return true;
	end;
end;

if (SERVER) then
	function DetectCW:PreReadPackageMetadata(sDirectory, sFolderName, sParentName)
		if (_file.Exists(sDirectory.."/"..sFolderName..".txt", "LUA")) then
			self:ReadSchemaInfo(sDirectory, sFolderName, sParentName);

			return true;
		end;
	end;

	function DetectCW:ReadSchemaInfo(sDirectory, sFolderName, sParentname)
		local schemaData = util.KeyValuesToTable(_file.Read(sDirectory.."/"..sFolderName..".txt", "LUA"));

		if (not schemaData) then
			schemaData = {};
		end;
			
		if (schemaData["Gamemode"]) then
			schemaData = schemaData["Gamemode"];
		end;
		
		local info = {};

		info.name = schemaData.title or "Undefined";
		info.author = schemaData.author or "Undefined";
		info.description = schemaData.description or "Undefined";
		info.website = schemaData.website or "Undefined";
	--	info.version = CrowUtil:VersionToTable(schemaData.version) or "Undefined";
		info.version = schemaData.version or "Undefined";
		info.directory = sDirectory or "Undefined";
		info.folderName = sFolderName or "Undefined";
		info.parentName = sParentName or "Undefined";
				
		if (schemaData.dependencies) then
			info.dependencies = {};

			for k, v in pairs(schemaData.dependencies) do
				info.dependencies[k] = CrowUtil:VersionToTable(v);
			end;
		end;

		CrowPackage.__metadata[sFolderName] = info;
	end;
end;

CrowPackage:AddModule("CW_Schema_Detector", DetectCW);