--[[ 
	© CloudSixteen.com
	http://crowlite.com/license
--]]

CROW_CMD = {__index = CROW_CMD};

--[[
	@codebase Shared
	@details A function to register the command to Crowlite's cmd system.
]]--
function CROW_CMD:Register()
	return Clockwork.command:Register(self, self.name);
end;
