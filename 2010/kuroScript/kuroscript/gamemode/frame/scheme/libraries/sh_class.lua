--[[
Name: "sh_class.lua".
Product: "kuroScript".
--]]

kuroScript.class = {};
kuroScript.class.stored = {};
kuroScript.class.buffer = {};

-- Set some information.
CLASS_CITIZENS_FEMALE = {
	"models/humans/group01/female_01.mdl",
	"models/humans/group01/female_02.mdl",
	"models/humans/group01/female_03.mdl",
	"models/humans/group01/female_04.mdl",
	"models/humans/group01/female_06.mdl",
	"models/humans/group01/female_07.mdl",
	"models/alpha1/group05/female_05.mdl",
	"models/alpha1/group05/female_08.mdl",
	"models/alpha1/group05/female_09.mdl",
	"models/alpha1/group05/female_10.mdl",
	"models/alpha1/group05/female_11.mdl",
	"models/alpha1/group05/female_14.mdl",
	"models/alpha1/group05/female_18.mdl"

};

-- Set some information.
CLASS_CITIZENS_MALE = {
	"models/humans/group01/male_01.mdl",
	"models/humans/group01/male_02.mdl",
	"models/humans/group01/male_03.mdl",
	"models/humans/group01/male_04.mdl",
	"models/humans/group01/male_05.mdl",
	"models/humans/group01/male_06.mdl",
	"models/humans/group01/male_07.mdl",
	"models/humans/group01/male_08.mdl",
	"models/humans/group01/male_09.mdl",
	"models/humans/group01/male_00.mdl",
	"models/alpha1/group05/male_10.mdl",
	"models/alpha1/group05/male_11.mdl",
	"models/alpha1/group05/male_12.mdl",
	"models/alpha1/group05/male_13.mdl",
	"models/alpha1/group05/male_14.mdl",
	"models/alpha1/group05/male_15.mdl",
	"models/alpha1/group05/male_16.mdl",
	"models/alpha1/group05/male_18.mdl",
	"models/alpha1/group05/male_20.mdl",
	"models/alpha1/group05/male_21.mdl",
	"models/alpha1/group05/male_22.mdl",
	"models/alpha1/group05/male_23.mdl",
	"models/alpha1/group05/male_24.mdl",
	"models/alpha1/group05/male_25.mdl",
	"models/alpha1/group05/male_26.mdl",
	"models/alpha1/group05/male_28.mdl"

};

-- A function to register a new class.
function kuroScript.class.Register(data, name)
	if (data.models) then
		data.models.female = data.models.female or CLASS_CITIZENS_FEMALE;
		data.models.male = data.models.male or CLASS_CITIZENS_MALE;
	else
		data.models = {
			female = CLASS_CITIZENS_FEMALE,
			male = CLASS_CITIZENS_MALE
		};
	end;
	
	-- Set some information.
	data.limit = data.limit or MaxPlayers();
	data.index = kuroScript.frame:GetShortCRC(name);
	data.name = data.name or name;
	
	-- Set some information.
	kuroScript.class.buffer[data.index] = data;
	kuroScript.class.stored[data.name] = data;
	
	-- Return the name of the class.
	return data.name;
end;

-- A function to get whether a gender is valid.
function kuroScript.class.IsGenderValid(class, gender)
	class = kuroScript.class.Get(class);
	
	-- Check if a statement is true.
	if ( class and (gender == GENDER_MALE or gender == GENDER_FEMALE) ) then
		if (!class.singleGender or gender == class.singleGender) then
			return true;
		end;
	end;
end;

-- A function to get a class.
function kuroScript.class.Get(name)
	if (name) then
		if ( tonumber(name) ) then
			local index = tonumber(name);
			
			-- Return the class.
			return kuroScript.class.buffer[index];
		else
			return kuroScript.class.stored[name];
		end;
	end;
end;

-- A function to get each player in a class.
function kuroScript.class.GetPlayers(class)
	local players = {};
	local k, v;
	
	-- Loop through each value in a table.
	for k, v in ipairs( g_Player.GetAll() ) do
		if ( v:HasInitialized() ) then
			local vocation = kuroScript.vocation.stored[ g_Team.GetName( v:Team() ) ];
			
			-- Check if a statement is true.
			if (vocation and vocation.class == class) then
				players[#players + 1] = v;
			end;
		end;
	end;
	
	-- Return the players.
	return players;
end;