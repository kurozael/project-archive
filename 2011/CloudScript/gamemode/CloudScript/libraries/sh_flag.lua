--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

CloudScript.flag = {};
CloudScript.flag.stored = {};

-- A function to add a new flag.
function CloudScript.flag:Add(flag, name, details)
	if ( CLIENT and !self.stored[flag] ) then
		CloudScript.directory:AddCode("Flags", [[
			<tr>
				<td><b><font color="red">]]..flag..[[</font></b></td>
				<td><i>]]..details..[[</i></td>
			</tr>
		]], nil, flag, function(htmlCode, sortData)
			if ( CloudScript.player:HasFlags(CloudScript.Client, sortData) ) then
				return CloudScript:Replace(CloudScript:Replace(htmlCode, [[<font color="red">]], [[<font color="green">]]), "</font>", "</font>");
			else
				return htmlCode;
			end;
		end);
	end;
	
	self.stored[flag] = {
		name = name,
		details = details
	};
end;

-- A function to get a flag.
function CloudScript.flag:Get(flag)
	return self.stored[flag];
end;

-- A function to get the stored flags.
function CloudScript.flag:GetStored()
	return self.stored;
end;

-- A function to get a flag's name.
function CloudScript.flag:GetName(flag, default)
	if ( self.stored[flag] ) then
		return self.stored[flag].name;
	else
		return default;
	end;
end;

-- A function to get a flag's details.
function CloudScript.flag:GetDescription(flag, default)
	if ( self.stored[flag] ) then
		return self.stored[flag].details;
	else
		return default;
	end;
end;

-- A function to get a flag by it's name.
function CloudScript.flag:GetFlagByName(name, default)
	local lowerName = string.lower(name);
	
	for k, v in pairs(self.stored) do
		if (string.lower(v.name) == lowerName) then
			return k;
		end;
	end;
	
	return default;
end;

CloudScript.flag:Add("C", "Spawn Vehicles", "Access to spawn vehicles.");
CloudScript.flag:Add("r", "Spawn Ragdolls", "Access to spawn ragdolls.");
CloudScript.flag:Add("c", "Spawn Chairs", "Access to spawn chairs.");
CloudScript.flag:Add("e", "Spawn Props", "Access to spawn props.");
CloudScript.flag:Add("p", "Physics Gun", "Access to the physics gun.");
CloudScript.flag:Add("n", "Spawn NPCs", "Access to spawn NPCs.");
CloudScript.flag:Add("t", "Tool Gun", "Access to the tool gun.");
CloudScript.flag:Add("G", "Give Item", "Access to the give items.");