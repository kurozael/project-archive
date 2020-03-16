--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

CloudScript.time = {};
CloudScript.date = {};

-- A function to get the time minute.
function CloudScript.time:GetMinute()
	if (CLIENT) then
		return CloudScript:GetSharedVar("minute");
	else
		return self.minute;
	end;
end;

-- A function to get the time hour.
function CloudScript.time:GetHour()
	if (CLIENT) then
		return CloudScript:GetSharedVar("hour");
	else
		return self.hour;
	end;
end;

-- A function to get the time day.
function CloudScript.time:GetDay()
	if (CLIENT) then
		return CloudScript:GetSharedVar("day");
	else
		return self.day;
	end;
end;

-- A function to get the day name.
function CloudScript.time:GetDayName()
	local defaultDays = CloudScript.option:GetKey("default_days");
	
	if (defaultDays) then
		return defaultDays[ self:GetDay() ] or "Unknown";
	end;
end;

if (SERVER) then
	function CloudScript.time:GetSaveData()
		return {
			minute = self:GetMinute(),
			hour = self:GetHour(),
			day = self:GetDay()
		};
	end;
	
	-- A function to get the date save data.
	function CloudScript.date:GetSaveData()
		return {
			month = self:GetMonth(),
			year = self:GetYear(),
			day = self:GetDay()
		};
	end;
	
	-- A function to get the date year.
	function CloudScript.date:GetYear()
		return self.year;
	end;

	-- A function to get the date month.
	function CloudScript.date:GetMonth()
		return self.month;
	end;

	-- A function to get the date day.
	function CloudScript.date:GetDay()
		return self.day;
	end;
else
	function CloudScript.date:GetString()
		return CloudScript:GetSharedVar("date");
	end;
	
	-- A function to get the time as a string.
	function CloudScript.time:GetString()
		local minute = CloudScript:ZeroNumberToDigits(self:GetMinute(), 2);
		local hour = CloudScript:ZeroNumberToDigits(self:GetHour(), 2);
		
		if (NX_CONVAR_TWELVEHOURCLOCK:GetInt() == 1) then
			hour = tonumber(hour);
			
			if (hour >= 12) then
				if (hour > 12) then
					hour = hour - 12;
				end;
				
				return CloudScript:ZeroNumberToDigits(hour, 2)..":"..minute.."pm";
			else
				return CloudScript:ZeroNumberToDigits(hour, 2)..":"..minute.."am";
			end;
		else
			return hour..":"..minute;
		end;
	end;
end;