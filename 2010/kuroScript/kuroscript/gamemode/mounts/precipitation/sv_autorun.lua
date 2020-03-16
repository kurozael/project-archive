--[[
Name: "sv_autorun.lua".
Product: "kuroScript".
--]]

local MOUNT = MOUNT;

-- Include some prefixed files.
kuroScript.frame:IncludePrefixed("sh_autorun.lua");

-- A function to decide the precipitation.
function MOUNT:DecidePrecipitation()
	if (math.random(1, 15) == 15) then
		if (math.random(1, 5) == 5 and self.dayTime == "Night Time") then
			kuroScript.frame:SetSharedVar("ks_Precipitation", PREC_STORM_RAIN);
		elseif (self.dayTime == "Night Time") then
			kuroScript.frame:SetSharedVar("ks_Precipitation", PREC_NIGHT_TIME_RAIN);
		elseif (self.dayTime == "Day Time") then
			kuroScript.frame:SetSharedVar("ks_Precipitation", PREC_DAY_TIME_RAIN);
		elseif (self.dayTime == "Morning") then
			kuroScript.frame:SetSharedVar("ks_Precipitation", PREC_MORNING_RAIN);
		elseif (self.dayTime == "Evening") then
			kuroScript.frame:SetSharedVar("ks_Precipitation", PREC_EVENING_RAIN);
		end;
	else
		kuroScript.frame:SetSharedVar("ks_Precipitation", 0);
	end;
end;

-- A function to calculate the day time.
function MOUNT:CalculateDayTime()
	local sysTime = SysTime();
	local minute = (kuroScript.time.hour * 60) + kuroScript.time.minute;
	local k, v;
	
	-- Check if a statement is true.
	if (minute > DAWN_START and minute < DAWN_END) then
		if (self.dayTime != "Morning") then
			self.dayTime = "Morning";
		end;
	elseif (minute > DAY_START and minute < DAY_END) then
		if (self.dayTime != "Day Time") then
			self.dayTime = "Day Time";
		end;
	elseif (minute > DUSK_START and minute < DUSK_END) then
		if (self.dayTime != "Evening") then
			self.dayTime = "Evening";
		end;
	elseif (self.dayTime != "Night Time") then
		self.dayTime = "Night Time";
	end;
	
	-- Check if a statement is true.
	if (!self.nextDecidePrecipitation or sysTime > self.nextDecidePrecipitation) then
		self.nextDecidePrecipitation = sysTime + math.random(300, 1200);
		
		-- Decide the precipitation.
		self:DecidePrecipitation();
	end;
end;