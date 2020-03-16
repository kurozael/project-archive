--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

openAura.time = {};
openAura.date = {};

-- A function to get the time minute.
function openAura.time:GetMinute()
	if (CLIENT) then
		return openAura:GetSharedVar("minute");
	else
		return self.minute;
	end;
end;

-- A function to get the time hour.
function openAura.time:GetHour()
	if (CLIENT) then
		return openAura:GetSharedVar("hour");
	else
		return self.hour;
	end;
end;

-- A function to get the time day.
function openAura.time:GetDay()
	if (CLIENT) then
		return openAura:GetSharedVar("day");
	else
		return self.day;
	end;
end;

-- A function to get the day name.
function openAura.time:GetDayName()
	local defaultDays = openAura.option:GetKey("default_days");
	
	if (defaultDays) then
		return defaultDays[ self:GetDay() ] or "Unknown";
	end;
end;

if (SERVER) then
	function openAura.time:GetSaveData()
		return {
			minute = self:GetMinute(),
			hour = self:GetHour(),
			day = self:GetDay()
		};
	end;
	
	-- A function to get the date save data.
	function openAura.date:GetSaveData()
		return {
			month = self:GetMonth(),
			year = self:GetYear(),
			day = self:GetDay()
		};
	end;
	
	-- A function to get the date year.
	function openAura.date:GetYear()
		return self.year;
	end;

	-- A function to get the date month.
	function openAura.date:GetMonth()
		return self.month;
	end;

	-- A function to get the date day.
	function openAura.date:GetDay()
		return self.day;
	end;
else
	function openAura.date:GetString()
		return openAura:GetSharedVar("date");
	end;
	
	-- A function to get the time as a string.
	function openAura.time:GetString()
		local minute = openAura:ZeroNumberToDigits(self:GetMinute(), 2);
		local hour = openAura:ZeroNumberToDigits(self:GetHour(), 2);
		
		if (NX_CONVAR_TWELVEHOURCLOCK:GetInt() == 1) then
			hour = tonumber(hour);
			
			if (hour >= 12) then
				if (hour > 12) then
					hour = hour - 12;
				end;
				
				return openAura:ZeroNumberToDigits(hour, 2)..":"..minute.."pm";
			else
				return openAura:ZeroNumberToDigits(hour, 2)..":"..minute.."am";
			end;
		else
			return hour..":"..minute;
		end;
	end;
end;