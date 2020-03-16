--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

openAura.flag = {};
openAura.flag.stored = {};

-- A function to add a new flag.
function openAura.flag:Add(flag, name, details)
	if ( CLIENT and !self.stored[flag] ) then
		openAura.directory:AddCode("Flags", [[
			<tr>
				<td><b><font color="red">]]..flag..[[</font></b></td>
				<td><i>]]..details..[[</i></td>
			</tr>
		]], nil, flag, function(htmlCode, sortData)
			if ( openAura.player:HasFlags(openAura.Client, sortData) ) then
				return openAura:Replace(openAura:Replace(htmlCode, [[<font color="red">]], [[<font color="green">]]), "</font>", "</font>");
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
function openAura.flag:Get(flag)
	return self.stored[flag];
end;

-- A function to get the stored flags.
function openAura.flag:GetStored()
	return self.stored;
end;

-- A function to get a flag's name.
function openAura.flag:GetName(flag, default)
	if ( self.stored[flag] ) then
		return self.stored[flag].name;
	else
		return default;
	end;
end;

-- A function to get a flag's details.
function openAura.flag:GetDescription(flag, default)
	if ( self.stored[flag] ) then
		return self.stored[flag].details;
	else
		return default;
	end;
end;

-- A function to get a flag by it's name.
function openAura.flag:GetFlagByName(name, default)
	local lowerName = string.lower(name);
	
	for k, v in pairs(self.stored) do
		if (string.lower(v.name) == lowerName) then
			return k;
		end;
	end;
	
	return default;
end;

openAura.flag:Add("C", "Spawn Vehicles", "Access to spawn vehicles.");
openAura.flag:Add("r", "Spawn Ragdolls", "Access to spawn ragdolls.");
openAura.flag:Add("c", "Spawn Chairs", "Access to spawn chairs.");
openAura.flag:Add("e", "Spawn Props", "Access to spawn props.");
openAura.flag:Add("p", "Physics Gun", "Access to the physics gun.");
openAura.flag:Add("n", "Spawn NPCs", "Access to spawn NPCs.");
openAura.flag:Add("t", "Tool Gun", "Access to the tool gun.");
openAura.flag:Add("G", "Give Item", "Access to the give items.");