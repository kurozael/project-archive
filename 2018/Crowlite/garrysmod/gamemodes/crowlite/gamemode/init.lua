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

--[[ Comment this out if you do not want to include the CodeAuth module. --]]
require("codeauth");

AddCSLuaFile("cl_init.lua");

AddCSLuaFile("framework/sh_boot.lua");
include("framework/sh_boot.lua");

AddCSLuaFile("dependencies/sh_jsonstream.lua");
include("dependencies/sh_jsonstream.lua");

Crow.nest:Initialize();

--CodeAuth.Execute("", "#crowlite");
--CodeAuth.Execute("dev-key01", "SaZcvhwvWcuwDEi2DMzKHIWJy77zwcV0jY+72hl9acrTUF2MKhRGQ/JouNBrwJ2i/g7YXP/qkgAbcIftJ/4QUkoDjdsXR6rX7GgZTLH8CN0=");

--[[ Log Loading Time ]]--
Crow.nest:Log("Nest", "Loading took "..math.Round(os.clock() - startTime, 3).. " second(s).");