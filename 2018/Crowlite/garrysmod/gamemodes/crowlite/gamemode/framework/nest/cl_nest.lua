--[[ 
	© CloudSixteen.com
	http://crowlite.com/license
--]]

--[[ Localized Dependencies ]]--
local Crow = Crow;
local CrowNest = Crow.nest;

--[[
	@codebase Client
	@details A function to initialize the Crowlite framework.
--]]
function Crow.nest:Initialize()
	Crow.package:Initialize();
	Crow.package:CallAll("CrowliteInitialize");
end;