--[[
Name: "sh_flag.lua".
Product: "nexus".
--]]

nexus.flag = {};
nexus.flag.stored = {};

-- A function to add a new flag.
function nexus.flag.Add(flag, name, details)
	if ( CLIENT and !nexus.flag.stored[flag] ) then
		nexus.directory.AddCode( "Flags", [[
			<tr>
				<td><font color="red">]]..flag..[[</font></td>
				<td><i>]]..details..[[</i></td>
			</tr>
		]] );
	end;
	
	nexus.flag.stored[flag] = {
		name = name,
		details = details
	};
end;

-- A function to get a flag.
function nexus.flag.Get(flag)
	return nexus.flag.stored[flag];
end;

-- A function to get the stored flags.
function nexus.flag.GetStored()
	return nexus.flag.stored;
end;

-- A function to get a flag's name.
function nexus.flag.GetName(flag, default)
	if ( nexus.flag.stored[flag] ) then
		return nexus.flag.stored[flag].name;
	else
		return default;
	end;
end;

-- A function to get a flag's details.
function nexus.flag.GetDescription(flag, default)
	if ( nexus.flag.stored[flag] ) then
		return nexus.flag.stored[flag].details;
	else
		return default;
	end;
end;

-- A function to get a flag by it's name.
function nexus.flag.GetFlagByName(name, default)
	local lowerName = string.lower(name);
	
	for k, v in pairs(nexus.flag.stored) do
		if (string.lower(v.name) == lowerName) then
			return k;
		end;
	end;
	
	return default;
end;

nexus.flag.Add("C", "Spawn Vehicles", "Access to spawn vehicles.");
nexus.flag.Add("r", "Spawn Ragdolls", "Access to spawn ragdolls.");
nexus.flag.Add("c", "Spawn Chairs", "Access to spawn chairs.");
nexus.flag.Add("e", "Spawn Props", "Access to spawn props.");
nexus.flag.Add("p", "Physics Gun", "Access to the physics gun.");
nexus.flag.Add("n", "Spawn NPCs", "Access to spawn NPCs.");
nexus.flag.Add("t", "Tool Gun", "Access to the tool gun.");
nexus.flag.Add("G", "Give Item", "Access to the give items.");