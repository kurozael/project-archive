--[[
Name: "sh_datetime.lua".
Product: "nexus".
--]]

nexus.time = {};
nexus.date = {};

-- A function to get the time minute.
function nexus.time.GetMinute()
	if (CLIENT) then
		return NEXUS:GetSharedVar("sh_Minute");
	else
		return nexus.time.minute;
	end;
end;

-- A function to get the time hour.
function nexus.time.GetHour()
	if (CLIENT) then
		return NEXUS:GetSharedVar("sh_Hour");
	else
		return nexus.time.hour;
	end;
end;

-- A function to get the time day.
function nexus.time.GetDay()
	if (CLIENT) then
		return NEXUS:GetSharedVar("sh_Day");
	else
		return nexus.time.day;
	end;
end;

-- A function to get the day name.
function nexus.time.GetDayName()
	local defaultDays = nexus.schema.GetOption("default_days");
	
	if (defaultDays) then
		return defaultDays[ nexus.time.GetDay() ] or "Unknown";
	end;
end;

if (SERVER) then
	function nexus.time.GetSaveData()
		return {
			minute = nexus.time.GetMinute(),
			hour = nexus.time.GetHour(),
			day = nexus.time.GetDay()
		};
	end;
	
	-- A function to get the date save data.
	function nexus.date.GetSaveData()
		return {
			month = nexus.date.GetMonth(),
			year = nexus.date.GetYear(),
			day = nexus.date.GetDay()
		};
	end;
	
	-- A function to get the date year.
	function nexus.date.GetYear()
		return nexus.date.year;
	end;

	-- A function to get the date month.
	function nexus.date.GetMonth()
		return nexus.date.month;
	end;

	-- A function to get the date day.
	function nexus.date.GetDay()
		return nexus.date.day;
	end;
else
	function nexus.date.GetString()
		return NEXUS:GetSharedVar("sh_Date");
	end;
	
	-- A function to get the time as a string.
	function nexus.time.GetString()
		local minute = NEXUS:ZeroNumberToDigits(nexus.time.GetMinute(), 2);
		local hour = NEXUS:ZeroNumberToDigits(nexus.time.GetHour(), 2);
		
		if (NX_CONVAR_TWELVEHOURCLOCK:GetInt() == 1) then
			hour = tonumber(hour);
			
			if (hour >= 12) then
				if (hour > 12) then
					hour = hour - 12;
				end;
				
				return NEXUS:ZeroNumberToDigits(hour, 2)..":"..minute.."pm";
			else
				return NEXUS:ZeroNumberToDigits(hour, 2)..":"..minute.."am";
			end;
		else
			return hour..":"..minute;
		end;
	end;
end;