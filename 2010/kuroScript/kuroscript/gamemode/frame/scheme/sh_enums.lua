--[[
Name: "sh_enums.lua".
Product: "kuroScript".
--]]

-- A function to format currency.
function FORMAT_CURRENCY(amount, single, lower)
	amount = math.Round(amount);
	
	-- Check if a statement is true.
	if (!single) then
		return string.format( "$%s", tostring(amount) );
	else
		return string.format( "%s", tostring(amount) );
	end;
end;

-- Set some information.
STEAM_COMMUNITY_ID = 76561197960265728;

-- Set some information.
GAME_FOLDER = string.gsub(kuroScript.frame:GetFolder(), "/gamemode", "");

-- Set some information.
COLOR_INFORMATION = Color(255, 100, 100, 255);
COLOR_FOREGROUND = Color(100, 100, 100, 25);
COLOR_BACKGROUND = Color(0, 0, 0, 25);
COLOR_WHITE = Color(255, 255, 255, 255);

-- Set some information.
HOLSTER_DISASSEMBLE = 1;
HOLSTER_ASSEMBLE = 2;
HOLSTER_HOLSTER = 3;

-- Set some information.
RAGDOLL_KNOCKEDOUT = 1;
RAGDOLL_FALLENOVER = 2;
RAGDOLL_RESET = 3;
RAGDOLL_NONE = 4;

-- Set some information.
FONT_INTRO_TEXT_SMALL = "ks_IntroTextSmall";
FONT_INTRO_TEXT_BIG = "ks_IntroTextBig";
FONT_CINEMATIC_TEXT = "ks_CinematicText";
FONT_MAIN_TEXT = "TargetIDSmall";
FONT_BAR_TEXT = "TargetIDSmall";

-- Set some information.
DEFAULT_DATE = {month = 1, year = 2009, day = 1};
DEFAULT_TIME = {minute = 0, hour = 0, day = 1};
DEFAULT_DAYS = {"Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"};

-- Set some information.
GENDER_FEMALE = "Female";
GENDER_MALE = "Male";

-- Set some information.
MODEL_SHIPMENT = "models/items/item_item_crate.mdl";
MODEL_CURRENCY = "models/props_c17/briefcase001a.mdl";

-- Set some information.
KNOWN_PARTIAL = 1;
KNOWN_TOTAL = 2;
KNOWN_SAVE = 3;

-- Set some information.
ALIGN_CENTER = 1;
ALIGN_RIGHT = 2;
ALIGN_LEFT = 3;

-- Set some information.
TIME_MINUTE = 1;
TIME_MONTH = 2;
TIME_YEAR = 3;
TIME_HOUR = 4;
TIME_DAY = 5;

-- Set some information.
NAME_CURRENCY_LOWER = "money";
NAME_CURRENCY = "Money";
NAME_MENU = "Menu";

-- Set some information.
DOOR_ACCESS_BASIC = 1;
DOOR_ACCESS_COMPLETE = 2;

-- Set some information.
DOOR_INFO_TEXT = 1;
DOOR_INFO_NAME = 2;