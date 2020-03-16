--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

-- A function to format cash.
function FORMAT_CASH(amount, singular, lowerName)
	local formatSingular = openAura.option:GetKey("format_singular_cash");
	local formatCash = openAura.option:GetKey("format_cash");
	local cashName = openAura.option:GetKey("name_cash", lowerName);
	local realAmount = tostring( math.Round(amount) );
	
	if (singular) then
		return openAura:Replace(openAura:Replace(formatSingular, "%n", cashName), "%a", realAmount);
	else
		return openAura:Replace(openAura:Replace(formatCash, "%n", cashName), "%a", realAmount);
	end;
end;

STEAM_COMMUNITY_ID = 76561197960265728;

LOGTYPE_CRITICAL = 1;
LOGTYPE_URGENT = 2;
LOGTYPE_MAJOR = 3;
LOGTYPE_MINOR = 4;
LOGTYPE_GENERIC = 5;

NWTYPE_STRING = 1;
NWTYPE_ENTITY = 2;
NWTYPE_VECTOR = 3;
NWTYPE_NUMBER = 4;
NWTYPE_ANGLE = 5;
NWTYPE_FLOAT = 6;
NWTYPE_BOOL = 7;

CHARACTER_MENU_LOADED = 1;
CHARACTER_MENU_CLOSE = 2;
CHARACTER_MENU_OPEN = 3;

RAGDOLL_KNOCKEDOUT = 1;
RAGDOLL_FALLENOVER = 2;
RAGDOLL_RESET = 3;
RAGDOLL_NONE = 4;

GENDER_FEMALE = "Female";
GENDER_MALE = "Male";

CLIP_ONE = 1;
CLIP_TWO = 2;

RECOGNISE_PARTIAL = 1;
RECOGNISE_TOTAL = 2;
RECOGNISE_SAVE = 3;

TIME_MINUTE = 1;
TIME_MONTH = 2;
TIME_YEAR = 3;
TIME_HOUR = 4;
TIME_DAY = 5;

DOOR_ACCESS_COMPLETE = 2;
DOOR_ACCESS_BASIC = 1;

DOOR_INFO_TEXT = 1;
DOOR_INFO_NAME = 2;