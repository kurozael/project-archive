--[[
Name: "sh_class.lua".
Product: "nexus".
--]]

nexus.class = {};
nexus.class.stored = {};
nexus.class.buffer = {};

-- A function to register a new class.
function nexus.class.Register(data, name)
	if (!data.maleModel) then
		data.maleModel = data.femaleModel;
	end;
	
	if (!data.femaleModel) then
		data.femaleModel = data.maleModel;
	end;
	
	data.flags = data.flags or "b";
	data.limit = data.limit or 128;
	data.wages = data.wages or 0;
	data.index = NEXUS:GetShortCRC(name);
	data.name = name;
	
	g_Team.SetUp(data.index, data.name, data.color);
	
	nexus.class.buffer[data.index] = data;
	nexus.class.stored[data.name] = data;
	
	return data.index;
end;

-- A function to get the class limit.
function nexus.class.GetLimit(name)
	local class = nexus.class.Get(name);
	
	if (class) then
		if (class.limit != 128) then
			return math.ceil( class.limit / ( 128 / #g_Player.GetAll() ) );
		else
			return MaxPlayers();
		end;
	else
		return 0;
	end;
end;

-- A function to get a class.
function nexus.class.Get(name)
	if (name) then
		if ( tonumber(name) ) then
			local index = tonumber(name);
			
			return nexus.class.buffer[index];
		else
			return nexus.class.stored[name];
		end;
	end;
end;

function nexus.class.AssignToDefault(player)
	local defaultClasses = {};
	local faction = player:QueryCharacter("faction");
	
	for k, v in pairs(nexus.class.stored) do
		if ( v.factions and v.isDefault and table.HasValue(v.factions, faction) ) then
			defaultClasses[#defaultClasses + 1] = v.index;
		end;
	end;
	
	if (#defaultClasses > 0) then
		local class = defaultClasses[ math.random(1, #defaultClasses) ];
		
		if (class) then
			return nexus.class.Set(player, class);
		end;
	else
		for k, v in pairs(nexus.class.stored) do
			if ( v.factions and table.HasValue(v.factions, faction) ) then
				return nexus.class.Set(player, v.index);
			end;
		end;
		
		for k, v in pairs(nexus.class.stored) do
			if ( NEXUS:HasObjectAccess(player, v) ) then
				return nexus.class.Set(player, v.index);
			end;
		end;
	end;
end;

-- A function to get an appropriate class model for a player.
function nexus.class.GetAppropriateModel(name, player, noSubstitute)
	local defaultModel;
	local class = nexus.class.Get(name);
	local model;
	local skin;
	
	if (SERVER) then
		defaultModel = player:QueryCharacter("model");
	else
		defaultModel = player:GetSharedVar("sh_Model");
	end;
	
	if (class) then
		model, skin = nexus.class.GetModelByGender( name, nexus.player.GetGender(player) );
		
		if (class.GetModel) then
			model, skin = class:GetModel(player, defaultModel);
		end;
	end;
	
	if (!model and !noSubstitute) then
		model = defaultModel;
	end;
	
	if (!skin and !noSubstitute) then
		skin = 1;
	end;
	
	return model, skin;
end;

-- A function to get a class's model by gender.
function nexus.class.GetModelByGender(name, gender)
	local model = nexus.class.Query(name, string.lower(gender).."Model");
	
	if (type(model) == "table") then
		return model[1], model[2];
	else
		return model, 0;
	end;
end;

-- A function to check if a class has any flags.
function nexus.class.HasAnyFlags(name, flags)
	local query = nexus.class.Query(name, "flags")
	
	if (query) then
		-- local i;
		
		for i = 1, string.len(flags) do
			local flag = string.sub(flags, i, i);
			
			if ( string.find(query, flag) ) then
				return true;
			end;
		end;
	end;
end;

-- A function to check if a class has flags.
function nexus.class.HasFlags(name, flags)
	local query = nexus.class.Query(name, "flags")
	
	if (query) then
		for i = 1, string.len(flags) do
			local flag = string.sub(flags, i, i);
			
			if ( !string.find(query, flag) ) then
				return false;
			end;
		end;
		
		return true;
	end;
end;

-- A function to query a class.
function nexus.class.Query(name, key, default)
	local class = nexus.class.Get(name);
	
	if (class) then
		return class[key] or default;
	else
		return default;
	end;
end;

if (SERVER) then
	function nexus.class.Set(player, name, noRespawn, addDelay, noModelChange)
		local weapons = nexus.player.GetWeapons(player);
		local oldClass = nexus.class.Get( player:Team() );
		local newClass = nexus.class.Get(name);
		local ammo = nexus.player.GetAmmo(player, !player.firstSpawn);
		
		if (newClass) then
			player:SetTeam(newClass.index);
			
			if (!noModelChange) then
				NEXUS:PlayerSetModel(player);
			end;
			
			if (!noRespawn) then
				player.changeClass = true;
				
				if (!player:Alive() or player.firstSpawn) then
					player:Spawn();
				elseif ( !player:IsRagdolled() ) then
					nexus.player.LightSpawn(player, weapons, ammo);
				end;
			end;
			
			if (addDelay) then
				player.nextChangeClass = CurTime() + nexus.config.Get("change_class_interval"):Get();
			end;
			
			nexus.mount.Call("PlayerClassSet", player, newClass, oldClass, noRespawn, addDelay, noModelChange);
			
			return true;
		else
			return false, "This is not a valid class!";
		end;
	end;
end;