--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

CloudScript.generator = {};
CloudScript.generator.stored = {};

-- A function to register a new generator.
function CloudScript.generator:Register(name, power, health, maximum, cash, uniqueID, powerName, powerPlural)
	self.stored[uniqueID] = {
		powerPlural = powerPlural or powerName or "Power",
		powerName = powerName or "Power",
		uniqueID = uniqueID,
		maximum = maximum or 5,
		health = health or 100,
		power = power or 2,
		cash = cash or 100,
		name = name
	};
end;

-- A function to get all generators.
function CloudScript.generator:GetAll()
	return self.stored;
end;

-- A function to get a generator by its name.
function CloudScript.generator:Get(name)
	if (name) then
		if ( self.stored[name] ) then
			return self.stored[name];
		else
			local generator;
			
			for k, v in pairs(self.stored) do
				if ( string.find( string.lower(v.name), string.lower(name) ) ) then
					if (generator) then
						if ( string.len(v.name) < string.len(generator.name) ) then
							generator = v;
						end;
					else
						generator = v;
					end;
				end;
			end;
			
			return generator;
		end;
	end;
end;