--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

openAura.class = {};
openAura.class.stored = {};
openAura.class.buffer = {};

-- A function to register a new class.
function openAura.class:Register(data, name)
	if (!data.maleModel) then
		data.maleModel = data.femaleModel;
	end;
	
	if (!data.femaleModel) then
		data.femaleModel = data.maleModel;
	end;
	
	data.flags = data.flags or "b";
	data.limit = data.limit or 128;
	data.wages = data.wages or 0;
	data.index = openAura:GetShortCRC(name);
	data.name = name;
	
	_team.SetUp(data.index, data.name, data.color);
	
	self.buffer[data.index] = data;
	self.stored[data.name] = data;
	
	if (SERVER and data.image) then
		resource.AddFile("materials/"..data.image..".vtf");
		resource.AddFile("materials/"..data.image..".vmt");
	end;
	
	return data.index;
end;

-- A function to get the class limit.
function openAura.class:GetLimit(name)
	local class = self:Get(name);
	
	if (class) then
		if (class.limit != 128) then
			return math.ceil( class.limit / ( 128 / #_player.GetAll() ) );
		else
			return MaxPlayers();
		end;
	else
		return 0;
	end;
end;

-- A function to get a class.
function openAura.class:Get(name)
	if (name) then
		if ( tonumber(name) ) then
			local index = tonumber(name);
			
			return self.buffer[index];
		else
			return self.stored[name];
		end;
	end;
end;

function openAura.class:AssignToDefault(player)
	local defaultClasses = {};
	local faction = player:QueryCharacter("faction");
	
	for k, v in pairs(self.stored) do
		if ( v.factions and v.isDefault and table.HasValue(v.factions, faction) ) then
			defaultClasses[#defaultClasses + 1] = v.index;
		end;
	end;
	
	if (#defaultClasses > 0) then
		local class = defaultClasses[ math.random(1, #defaultClasses) ];
		
		if (class) then
			return self:Set(player, class);
		end;
	else
		for k, v in pairs(self.stored) do
			if ( v.factions and table.HasValue(v.factions, faction) ) then
				return self:Set(player, v.index);
			end;
		end;
		
		for k, v in pairs(self.stored) do
			if ( openAura:HasObjectAccess(player, v) ) then
				return self:Set(player, v.index);
			end;
		end;
	end;
end;

-- A function to get an appropriate class model for a player.
function openAura.class:GetAppropriateModel(name, player, noSubstitute)
	local defaultModel;
	local class = self:Get(name);
	local model;
	local skin;
	
	if (SERVER) then
		defaultModel = player:QueryCharacter("model");
	else
		defaultModel = player:GetSharedVar("model");
	end;
	
	if (class) then
		model, skin = self:GetModelByGender( name, openAura.player:GetGender(player) );
		
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
function openAura.class:GetModelByGender(name, gender)
	local model = self:Query(name, string.lower(gender).."Model");
	
	if (type(model) == "table") then
		return model[1], model[2];
	else
		return model, 0;
	end;
end;

-- A function to check if a class has any flags.
function openAura.class:HasAnyFlags(name, flags)
	local query = self:Query(name, "flags")
	
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
function openAura.class:HasFlags(name, flags)
	local query = self:Query(name, "flags")
	
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
function openAura.class:Query(name, key, default)
	local class = self:Get(name);
	
	if (class) then
		return class[key] or default;
	else
		return default;
	end;
end;

if (SERVER) then
	function openAura.class:Set(player, name, noRespawn, addDelay, noModelChange)
		local weapons = openAura.player:GetWeapons(player);
		local oldClass = self:Get( player:Team() );
		local newClass = self:Get(name);
		local ammo = openAura.player:GetAmmo(player, !player.firstSpawn);
		
		if (newClass) then
			player:SetTeam(newClass.index);
			
			if (!noModelChange) then
				openAura:PlayerSetModel(player);
			end;
			
			if (!noRespawn) then
				player.changeClass = true;
				
				if (!player:Alive() or player.firstSpawn) then
					player:Spawn();
				elseif ( !player:IsRagdolled() ) then
					openAura.player:LightSpawn(player, weapons, ammo);
				end;
			end;
			
			if (addDelay) then
				player.nextChangeClass = CurTime() + openAura.config:Get("change_class_interval"):Get();
			end;
			
			openAura.plugin:Call("PlayerClassSet", player, newClass, oldClass, noRespawn, addDelay, noModelChange);
			
			return true;
		else
			return false, "This is not a valid class!";
		end;
	end;
end;