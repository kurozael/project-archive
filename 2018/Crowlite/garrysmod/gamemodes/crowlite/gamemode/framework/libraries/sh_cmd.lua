--[[
	© CloudSixteen.com
	http://crowlite.com/license
--]]

--[[ Localized Dependencies ]]--
local Crow = Crow;

--[[
	@codebase Shared
	@details Handles the registration and execution of chat and console commands.
--]]
local CrowCmd = Crow.nest:GetLibrary("cmd");

--[[ Private Members ]]--
CrowCmd.__stored = CrowCmd.__stored or {};

function CrowCmd:New(name)
	local instance = Clockwork.kernel:NewInstance(CLASS_TABLE);
		instance.name = name or "Unknown";
	return instance;
end;

function CrowCmd:Register(data, name)
	local realName = string.gsub(name, "%s", "");
	local uniqueID = string.lower(realName);
	
	self.__stored[uniqueID] = data;
	self.__stored[uniqueID].name = realName;
	
	return self.__stored[uniqueID];
end;

function CrowCmd:Find(identifier)
	return self.stored[string.lower(string.gsub(identifier, "%s", ""))];
end;

if (SERVER) then
	function CrowCmd:ConsoleCommand(player, command, arguments)
		
	end;

--	concommand.Add("crow", function(player, command, arguments)
--		CrowCmd:ConsoleCommand(player, command, arguments);
--	end);
end;
