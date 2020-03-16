--[[
	© CloudSixteen.com
	http://crowlite.com/license
]]--

--[[ Localized Dependencies ]]--
local Crow = Crow;
local CrowNest = Crow.nest;

--[[
	@codebase Shared
	@details Provides various utility methods for use with Crowlite packages and gamemodes.
]]--
local CrowUtil = CrowNest:GetLibrary("util");

--[[
	@codebase Shared
	@details A function to convert a version string to a table.
	@params String The version string to convert to a table.
	@returns Table A converted version table containing 'string', 'major', 'minor', and 'patch' members.
]]--
function CrowUtil:VersionToTable(version)
	local split = string.Explode(".", version);
	
	if (split and #split == 3) then
		local major = tonumber(split[1]);
		local minor = tonumber(split[2]);
		local patch = tonumber(split[3]);
		
		if (major and minor and patch) then
			return {
				string = version,
				major = major,
				minor = minor,
				patch = patch
			};
		else
			CrowNest:LogWarning("Util::VersionToTable", "Version string must be in the format of x.x.x.");
			return false;
		end;
	else
		CrowNest:LogWarning("Util::VersionToTable", "Version string must be in the format of x.x.x.");
		return false;
	end;
end;