--[[
Name: "sh_generator.lua".
Product: "nexus".
--]]

nexus.generator = {};
nexus.generator.stored = {};

-- A function to register a new generator.
function nexus.generator.Register(name, power, health, maximum, cash, uniqueID, powerName, powerPlural)
	nexus.generator.stored[uniqueID] = {
		powerPlural = powerPlural or powerName or "Power",
		powerName = powerName or "Power",
		maximum = maximum or 5,
		health = health or 100,
		power = power or 2,
		cash = cash or 100,
		name = name
	};
end;

-- A function to get all generators.
function nexus.generator.GetAll()
	return nexus.generator.stored;
end;

-- A function to get a generator by its name.
function nexus.generator.Get(name)
	if (name) then
		if ( nexus.generator.stored[name] ) then
			return nexus.generator.stored[name];
		else
			local generator;
			
			for k, v in pairs(nexus.generator.stored) do
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