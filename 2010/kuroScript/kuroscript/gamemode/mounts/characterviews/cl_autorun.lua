--[[
Name: "cl_autorun.lua".
Product: "kuroScript".
--]]

local MOUNT = MOUNT;

-- Include some prefixed files.
kuroScript.frame:IncludePrefixed("sh_autorun.lua");

-- Hook a data stream.
datastream.Hook("ks_CharacterViews", function(handler, uniqueID, rawData, procData)
	MOUNT.characterViews = {};
	
	-- Set some information.
	local k, v;
	
	-- Loop through each value in a table.
	for k, v in ipairs(procData) do
		if (!v.class or v.class == "") then
			v.class = "none";
		end;
		
		-- Check if a statement true.
		if ( !MOUNT.characterViews[v.class] ) then
			MOUNT.characterViews[v.class] = {};
		end;
		
		-- Set some information.
		MOUNT.characterViews[v.class][#MOUNT.characterViews[v.class] + 1] = v;
	end;
	
	-- Check if a statement is true.
	if ( MOUNT.characterViews["none"] ) then
		local data = MOUNT.characterViews["none"];
		
		-- Set some information.
		MOUNT.characterView = data[ math.random( 1, #data ) ];
	end;
end);