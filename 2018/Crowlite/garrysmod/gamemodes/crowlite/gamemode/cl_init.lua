--[[ 
	© CloudSixteen.com
	http://crowlite.com/license
--]]

local startTime = os.clock();
local LOG_COLOR_WHITE = Color(255, 255, 255, 255);
local LOG_COLOR_GREY = Color(200, 200, 200, 255);

isReloading = (Crow != nil);

if (!isReloading) then
	MsgC(LOG_COLOR_GREY, "\nCrowlite::Nest\n", LOG_COLOR_WHITE, "Initializing...\n\n");
else
	MsgC(LOG_COLOR_GREY, "\nCrowlite::Nest\n", LOG_COLOR_WHITE, "Refreshing...\n\n");
end;

include("dependencies/sh_jsonstream.lua");
include("framework/sh_boot.lua");

local CrowPackage = Crow.nest:GetLibrary("package");

jsonstream.Receive("crow-init", function(data)
	Crow.nest:SetBootdata(data[1]);
	Crow.nest:Initialize();
	CrowPackage:LoadGamemode(data[2], true);
end);

--[[ Log Loading Time ]]--
Crow.nest:Log("Nest", "Loading took "..math.Round(os.clock() - startTime, 3).. " second(s).");