--[[ 
	© CloudSixteen.com
	http://crowlite.com/license
--]]

--[[ Localization Optimizations -]]
local Crow = Crow;
local CrowNest = Crow.nest;

--[[
	@codebase Server
	@details A function to initialize the Crowlite framework.
--]]
function Crow.nest:Initialize()
	Crow.package:Initialize();
	Crow.package:CallAll("CrowliteInitialize");
end;