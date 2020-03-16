--[[
Name: "sh_faction.lua".
Product: "nexus".
--]]

nexus.faction = {};
nexus.faction.stored = {};
nexus.faction.buffer = {};

FACTION_CITIZENS_FEMALE = {
	"models/humans/group01/female_01.mdl",
	"models/humans/group01/female_02.mdl",
	"models/humans/group01/female_03.mdl",
	"models/humans/group01/female_04.mdl",
	"models/humans/group01/female_06.mdl",
	"models/humans/group01/female_07.mdl"
};

FACTION_CITIZENS_MALE = {
	"models/humans/group01/male_01.mdl",
	"models/humans/group01/male_02.mdl",
	"models/humans/group01/male_03.mdl",
	"models/humans/group01/male_04.mdl",
	"models/humans/group01/male_05.mdl",
	"models/humans/group01/male_06.mdl",
	"models/humans/group01/male_07.mdl",
	"models/humans/group01/male_08.mdl",
	"models/humans/group01/male_09.mdl"
};

-- A function to register a new faction.
function nexus.faction.Register(data, name)
	if (data.models) then
		data.models.female = data.models.female or FACTION_CITIZENS_FEMALE;
		data.models.male = data.models.male or FACTION_CITIZENS_MALE;
	else
		data.models = {
			female = FACTION_CITIZENS_FEMALE,
			male = FACTION_CITIZENS_MALE
		};
	end;
	
	for k, v in pairs(data.models.female) do
		util.PrecacheModel(v);
	end;
	
	for k, v in pairs(data.models.male) do
		util.PrecacheModel(v);
	end;
	
	data.limit = data.limit or 128;
	data.index = NEXUS:GetShortCRC(name);
	data.name = data.name or name;
	
	nexus.faction.buffer[data.index] = data;
	nexus.faction.stored[data.name] = data;
	
	return data.name;
end;

-- A function to get the faction limit.
function nexus.faction.GetLimit(name)
	local faction = nexus.faction.Get(name);
	
	if (faction) then
		if (faction.limit != 128) then
			return math.ceil( faction.limit / ( 128 / #g_Player.GetAll() ) );
		else
			return MaxPlayers();
		end;
	else
		return 0;
	end;
end;

-- A function to get whether a gender is valid.
function nexus.faction.IsGenderValid(faction, gender)
	local factionTable = nexus.faction.Get(faction);
	
	if ( factionTable and (gender == GENDER_MALE or gender == GENDER_FEMALE) ) then
		if (!factionTable.singleGender or gender == factionTable.singleGender) then
			return true;
		end;
	end;
end;

-- A function to get whether a model is valid.
function nexus.faction.IsModelValid(faction, gender, model)
	if (gender and model) then
		local factionTable = nexus.faction.Get(faction);
		
		if ( factionTable and table.HasValue(factionTable.models[ string.lower(gender) ], model) ) then
			return true;
		end;
	end;
end;

-- A function to get a faction.
function nexus.faction.Get(name)
	if (name) then
		if ( tonumber(name) ) then
			local index = tonumber(name);
			
			return nexus.faction.buffer[index];
		else
			return nexus.faction.stored[name];
		end;
	end;
end;

-- A function to get each player in a faction.
function nexus.faction.GetPlayers(faction)
	local players = {};
	
	for k, v in ipairs( g_Player.GetAll() ) do
		if ( v:HasInitialized() ) then
			if (SERVER) then
				if (v:QueryCharacter("faction") == faction) then
					players[#players + 1] = v;
				end;
			elseif (nexus.player.GetFaction(v) == faction) then
				players[#players + 1] = v;
			end;
		end;
	end;
	
	return players;
end;

if (SERVER) then
	function nexus.faction.HasReachedMaximum(player, faction)
		local factionTable = nexus.faction.Get(faction);
		local characters = player:GetCharacters();
		
		if (factionTable and factionTable.maximum) then
			local totalCharacters = 0;
			
			for k, v in pairs(characters) do
				if (v.faction == factionTable.name) then
					totalCharacters = totalCharacters + 1;
				end;
			end;
			
			if (totalCharacters >= factionTable.maximum) then
				return true;
			end;
		end;
	end;
else
	function nexus.faction.HasReachedMaximum(faction)
		local factionTable = nexus.faction.Get(faction);
		local characters = nexus.character.GetAll();
		
		if (factionTable and factionTable.maximum) then
			local totalCharacters = 0;
			
			for k, v in pairs(characters) do
				if (v.faction == factionTable.name) then
					totalCharacters = totalCharacters + 1;
				end;
			end;
			
			if (totalCharacters >= factionTable.maximum) then
				return true;
			end;
		end;
	end;
end;