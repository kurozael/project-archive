--[[
Name: "cl_autorun.lua".
Product: "kuroScript".
--]]

local MOUNT = MOUNT;

-- Include some prefixed files.
kuroScript.frame:IncludePrefixed("sh_autorun.lua");

-- Hook a user message.
usermessage.Hook("ks_InflationCost", function(msg)
	local characters = msg:ReadLong();
	local economy = msg:ReadLong();
	local k, v;
	
	-- Check if a statement is true.
	if (characters) then
		MOUNT.characters = characters;
	end;
	
	-- Check if a statement is true.
	if (economy) then
		MOUNT.economy = economy;
	end;
	
	-- Loop through each value in a table.
	for k, v in pairs(kuroScript.item.stored) do
		if (v.cost) then
			if (!v.originalCost) then
				v.originalCost = v.cost;
			end;
			
			-- Set some information.
			v.cost = MOUNT:ConvertCurrency(v.originalCost);
		end;
	end;
	
	-- Loop through each value in a table.
	for k, v in pairs(kuroScript.contraband.stored) do
		if (v.currency) then
			if (!v.originalCurrency) then
				v.originalCurrency = v.currency;
			end;
			
			-- Set some information.
			v.currency = MOUNT:ConvertCurrency(v.originalCurrency);
		end;
	end;
	
	-- Call a gamemode hook.
	hook.Call("InflationRatesCalculated", kuroScript.frame, function(originalCost)
		return MOUNT:ConvertCurrency(originalCost);
	end);
end);