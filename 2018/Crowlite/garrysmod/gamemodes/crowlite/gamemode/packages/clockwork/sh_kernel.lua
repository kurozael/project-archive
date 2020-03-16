--[[ 
	© CloudSixteen.com
	http://crowlite.com/license
--]]

local CrowNest = Crow.nest;
local CrowResource = CrowNest:GetLibrary("resource");

-- Additional aliases that some Schema code may use.
cwFile, cwPlayer, cwTeam = _file, _player, _team;

-- Establish the kernel table.
Clockwork.kernel = Clockwork.kernel or {};

--[[ 
	Create alias for existing functions so that 
	schemas can run properly without needing to be edited. 
]]--
Clockwork.kernel.IncludePrefixed = CrowNest.IncludeFile;
Clockwork.kernel.AddFile = CrowResource.AddFile;
Clockwork.kernel.AddDirectory = CrowResource.AddDirectory;