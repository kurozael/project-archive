--[[
Name: "sh_vocation.lua".
Product: "kuroScript".
--]]

kuroScript.vocation = {};
kuroScript.vocation.stored = {};
kuroScript.vocation.buffer = {};

-- A function to register a new vocation.
function kuroScript.vocation.Register(data, name)
	if (!data.maleModel) then
		data.maleModel = data.femaleModel;
	end;
	
	-- Check if a statement is true.
	if (!data.femaleModel) then
		data.femaleModel = data.maleModel;
	end;
	
	-- Set some information.
	data.access = data.access or "b";
	data.limit = data.limit or MaxPlayers();
	data.wages = data.wages or 0;
	data.index = kuroScript.frame:GetShortCRC(name);
	data.name = name;
	
	-- Set some information.
	g_Team.SetUp(data.index, data.name, data.color);
	
	-- Set some information.
	kuroScript.vocation.buffer[data.index] = data;
	kuroScript.vocation.stored[data.name] = data;
	
	-- Return the index.
	return data.index;
end;

-- A function to get a vocation.
function kuroScript.vocation.Get(name)
	if (name) then
		if ( tonumber(name) ) then
			local index = tonumber(name);
			
			-- Return the vocation.
			return kuroScript.vocation.buffer[index];
		else
			return kuroScript.vocation.stored[name];
		end;
	end;
end;

-- A function to get a vocation's model by gender.
function kuroScript.vocation.GetModelByGender(name, gender)
	return kuroScript.vocation.Query(name, string.lower(gender).."Model");
end;

-- A function to check if a vocation has any access.
function kuroScript.vocation.HasAnyAccess(name, access)
	local query = kuroScript.vocation.Query(name, "access")
	
	-- Check if a statement is true.
	if (query) then
		local i;
		
		-- Loop through a range of values.
		for i = 1, string.len(access) do
			local flag = string.sub(access, i, i);
			
			-- Check if a statement is true.
			if ( string.find(query, flag) ) then
				return true;
			end;
		end;
	end;
end;

-- A function to check if a vocation has access.
function kuroScript.vocation.HasAccess(name, access)
	local query = kuroScript.vocation.Query(name, "access")
	
	-- Check if a statement is true.
	if (query) then
		local i;
		
		-- Loop through a range of values.
		for i = 1, string.len(access) do
			local flag = string.sub(access, i, i);
			
			-- Check if a statement is true.
			if ( !string.find(query, flag) ) then
				return false;
			end;
		end;
		
		-- Return true to break the function.
		return true;
	end;
end;

-- A function to query a vocation.
function kuroScript.vocation.Query(name, key, default)
	local vocation = kuroScript.vocation.Get(name);
	
	-- Check if a statement is true.
	if (vocation) then
		return vocation[key] or default;
	else
		return default;
	end;
end;

-- Check if a statement is true.
if (SERVER) then
	function kuroScript.vocation.Set(player, name, stay)
		local vocation = kuroScript.vocation.Get(name);
		local weapons = kuroScript.player.GetWeapons(player);
		local ammo = kuroScript.player.GetAmmo(player, !player._FirstSpawn);
		
		-- Check if a statement is true.
		if (vocation) then
			player:SetTeam(vocation.index);
			
			-- Set some information.
			kuroScript.frame:PlayerSetModel(player);
			
			-- Check if a statement is true.
			if (!stay) then
				player._ChangeVocation = true;
				
				-- Check if a statement is true.
				if (!player:Alive() or player._FirstSpawn) then
					player:Spawn();
				elseif ( !player:IsRagdolled() ) then
					kuroScript.player.LightSpawn(player, weapons, ammo);
				end;
			end;
			
			-- Return true to break the function.
			return true;
		else
			return false, "This is not a valid vocation!";
		end;
	end;
end;