--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

openAura.schema.billboards = {
	{
		position = Vector(-7847.8687, -7728.4404, 930.2415),
		angles = Angle(0, 90, 90),
		scale = 0.4375
	},
	{
		position = Vector(-5579.8511 -7212.6436, 816.4194),
		angles = Angle(0, -90, 90),
		scale = 0.4375
	},
	{
		position = Vector(-7719.0088, -4902.2466, 929.4857),
		angles = Angle(0, 90, 90),
		scale = 0.4375
	},
	{
		position = Vector(-5615.9512, -10324.8281, 926.2682),
		angles = Angle(0, -90, 90),
		scale = 0.4375
	},
	{
		position = Vector(-5579.8511, -7214.5537, 815.8289),
		angles = Angle(0, -90, 90),
		scale = 0.4375
	},
	{
		position = Vector(-446.1304, 6122.8198, 342.4596),
		angles = Angle(0, 50, 90),
		scale = 0.4375
	},
	{
		position = Vector(3489.8989, -6673.7188, 499.5970),
		angles = Angle(0, -180, 90),
		scale = 0.4375
	},
	{
		position = Vector(427.7188, 4524.6401, 440.7368),
		angles = Angle(0, -90, 90),
		scale = 0.4375
	},
	{
		position = Vector(790.3043, 7232.0161, 571.6388),
		angles = Angle(0, 90, 90),
		scale = 0.4375
	},
	{
		position = Vector(4208.2612, 5631.6914, 723.6007),
		angles = Angle(0, 90, 90),
		scale = 0.4375
	},
	{
		position = Vector(1861.0153, 3574.7188, 523.0126),
		angles = Angle(0, 0, 90),
		scale = 0.4375
	}
};

for k, v in pairs( _file.Find("../models/humans/group17/*.mdl") ) do
	openAura.animation:AddMaleHumanModel("models/humans/group17/"..v);
end;

for k, v in pairs( _file.Find("../models/humans/group99/*.mdl") ) do
	if ( string.find(string.lower(v), "female") ) then
		openAura.animation:AddFemaleHumanModel("models/humans/group99/"..v);
	else
		openAura.animation:AddMaleHumanModel("models/humans/group99/"..v);
	end;
end;

for k, v in pairs( _file.Find("../models/humans/group09/*.mdl") ) do
	if ( string.find(string.lower(v), "female") ) then
		openAura.animation:AddFemaleHumanModel("models/humans/group09/"..v);
	else
		openAura.animation:AddMaleHumanModel("models/humans/group09/"..v);
	end;
end;

for k, v in pairs( _file.Find("../models/humans/group10/*.mdl") ) do
	if ( string.find(string.lower(v), "female") ) then
		openAura.animation:AddFemaleHumanModel("models/humans/group10/"..v);
	else
		openAura.animation:AddMaleHumanModel("models/humans/group10/"..v);
	end;
end;

for k, v in pairs( _file.Find("../models/humans/group08/*.mdl") ) do
	if ( string.find(string.lower(v), "female") ) then
		openAura.animation:AddFemaleHumanModel("models/humans/group08/"..v);
	else
		openAura.animation:AddMaleHumanModel("models/humans/group08/"..v);
	end;
end;

for k, v in pairs( _file.Find("../models/humans/group07/*.mdl") ) do
	if ( string.find(string.lower(v), "female") ) then
		openAura.animation:AddFemaleHumanModel("models/humans/group07/"..v);
	else
		openAura.animation:AddMaleHumanModel("models/humans/group07/"..v);
	end;
end;

for k, v in pairs( _file.Find("../models/humans/group04/*.mdl") ) do
	if ( string.find(string.lower(v), "female") ) then
		openAura.animation:AddFemaleHumanModel("models/humans/group04/"..v);
	else
		openAura.animation:AddMaleHumanModel("models/humans/group04/"..v);
	end;
end;

openAura.option:SetKey("model_shipment", "models/props_junk/cardboard_box003b.mdl");
openAura.option:SetKey("intro_image", "cidertwo/cidertwo2");
openAura.option:SetKey("menu_music", "music/hl2_song20_submix0.mp3");
openAura.option:SetKey("gradient", "cidertwo/bg_gradient");

openAura.config:ShareKey("using_star_system");
openAura.config:ShareKey("intro_text_small");
openAura.config:ShareKey("intro_text_big");

openAura:RegisterGlobalSharedVar("noWagesTime", NWTYPE_NUMBER);
openAura:RegisterGlobalSharedVar("lottery", NWTYPE_NUMBER);
openAura:RegisterGlobalSharedVar("agenda", NWTYPE_STRING);

openAura.player:RegisterSharedVar("beingChloro", NWTYPE_BOOL, true);
openAura.player:RegisterSharedVar("skullMask", NWTYPE_BOOL);
openAura.player:RegisterSharedVar("beingTied", NWTYPE_BOOL, true);
openAura.player:RegisterSharedVar("alliance", NWTYPE_STRING);
openAura.player:RegisterSharedVar("disguise", NWTYPE_ENTITY);
openAura.player:RegisterSharedVar("clothes", NWTYPE_NUMBER, true);
openAura.player:RegisterSharedVar("lottery", NWTYPE_BOOL, true);
openAura.player:RegisterSharedVar("sensor", NWTYPE_BOOL, true);
openAura.player:RegisterSharedVar("hunger", NWTYPE_NUMBER, true);
openAura.player:RegisterSharedVar("thirst", NWTYPE_NUMBER, true);
openAura.player:RegisterSharedVar("leader", NWTYPE_BOOL);
openAura.player:RegisterSharedVar("crimes", NWTYPE_STRING);
openAura.player:RegisterSharedVar("stars", NWTYPE_NUMBER);
openAura.player:RegisterSharedVar("tied", NWTYPE_NUMBER);

openAura.quiz:SetName("Agreement");
openAura.quiz:SetEnabled(true);
openAura.quiz:AddQuestion("I know that because of the logs, I will never get away with rule-breaking.", 1, "Yes.", "No.");
openAura.quiz:AddQuestion("When creating a character, I will use a full and appropriate name.", 1, "Yes.", "No.");
openAura.quiz:AddQuestion("I understand that the script has vast logs that are checked often.", 1, "Yes.", "No.");
openAura.quiz:AddQuestion("I will read the guidelines and directory in the main menu.", 1, "Yes.", "No.");

openAura:IncludePrefixed("sh_coms.lua");
openAura:IncludePrefixed("sv_hooks.lua");
openAura:IncludePrefixed("cl_hooks.lua");
openAura:IncludePrefixed("cl_theme.lua");

CRIME_MURDER = 1;
CRIME_ASSAULT = 2;
CRIME_WEAPON = 3;
CRIME_DRUGS = 4;

local conversion = {
	[CRIME_MURDER] = "Murder",
	[CRIME_ASSAULT] = "Assault",
	[CRIME_WEAPON] = "Weapon",
	[CRIME_DRUGS] = "Drugs"
};

-- A function to convert a crime to its name.
function openAura.schema:CrimeToName(crime)
	return conversion[crime] or "Common";
end;

openAura.flag:Add("q", "Special", "Access to the special items.");