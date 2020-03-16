--[[
Name: "cl_autorun.lua".
Product: "kuroScript".
--]]

local MOUNT = MOUNT;

-- Include some prefixed files.
kuroScript.frame:IncludePrefixed("sh_autorun.lua");

-- Hook a data stream.
datastream.Hook("ks_AreaNames", function(handler, uniqueID, rawData, procData)
	MOUNT.areaNames = procData;
end);

-- Hook a user message.
usermessage.Hook("ks_AreaRemove", function(msg)
	local name = msg:ReadString();
	local minimum = msg:ReadVector();
	local maximum = msg:ReadVector();
	
	-- Loop through each value in a table.
	for k, v in pairs(MOUNT.areaNames) do
		if (v.name == name and v.minimum == minimum and v.maximum == maximum) then
			MOUNT.areaNames[k] = nil;
		end;
	end;
end);

-- Hook a user message.
usermessage.Hook("ks_AreaAdd", function(msg)
	local name = msg:ReadString();
	local minimum = msg:ReadVector();
	local maximum = msg:ReadVector();
	
	-- Set some information.
	MOUNT.areaNames[#MOUNT.areaNames + 1] = {
		name = name,
		minimum = minimum,
		maximum = maximum
	};
end);