--[[
Name: "sh_contraband.lua".
Product: "kuroScript".
--]]

kuroScript.contraband = {};
kuroScript.contraband.stored = {};

-- A function to register a new contraband.
function kuroScript.contraband.Register(name, power, health, maximum, currency, uniqueID, powerName, powerPlural)
	kuroScript.contraband.stored[uniqueID] = {
		powerPlural = powerPlural or powerName or "Power",
		powerName = powerName or "Power",
		currency = currency or 100,
		maximum = maximum or 5,
		health = health or 100,
		power = power or 2,
		name = name
	};
end;

-- A function to get a contraband by its name.
function kuroScript.contraband.Get(name)
	if (name) then
		if ( kuroScript.contraband.stored[name] ) then
			return kuroScript.contraband.stored[name];
		else
			local contraband;
			
			-- Loop through each value in a table.
			for k, v in pairs(kuroScript.contraband.stored) do
				if ( string.find( string.lower(v.name), string.lower(name) ) ) then
					if (contraband) then
						if ( string.len(v.name) < string.len(contraband.name) ) then
							contraband = v;
						end;
					else
						contraband = v;
					end;
				end;
			end;
			
			-- Return the contraband.
			return contraband;
		end;
	end;
end;