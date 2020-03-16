--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

--[[
	Set up the crime enumerations. New ones can be
	added if you know what you're doing.
--]]

CRIME_MURDER = 1; CRIME_ASSAULT = 2;
CRIME_WEAPON = 3; CRIME_DRUGS = 4;

local conversion = {
	[CRIME_MURDER] = "Murder",
	[CRIME_ASSAULT] = "Assault",
	[CRIME_WEAPON] = "Weapon",
	[CRIME_DRUGS] = "Drugs"
};

-- A function to convert a crime to its name.
function Schema:CrimeToName(crime)
	return conversion[crime] or "Common";
end;

if (CLIENT) then
	Schema.lastHeartbeatAmount = 0;
	Schema.nextHeartbeatCheck = 0;
	Schema.heartbeatGradient = Material("gui/gradient_down");
	Schema.heartbeatOverlay = Material("effects/combine_binocoverlay");
	Schema.heartbeatPoints = {};
	Schema.nextGetSnipers = 0;
	Schema.heartbeatPoint = Material("sprites/glow04_noz");
	Schema.laserSprite = Material("sprites/glow04_noz");
	Schema.highDistance = 0;
	Schema.highEffects = {};
	Schema.stunEffects = {};
	Schema.highTarget = 5;
	Schema.blacklist = {};
end;

Schema.billboards = {
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

for k, v in pairs(_file.Find("../models/humans/group17/*.mdl")) do
	Clockwork.animation:AddMaleHumanModel("models/humans/group17/"..v);
end;

for k, v in pairs(_file.Find("../models/humans/group99/*.mdl")) do
	if (string.find(string.lower(v), "female")) then
		Clockwork.animation:AddFemaleHumanModel("models/humans/group99/"..v);
	else
		Clockwork.animation:AddMaleHumanModel("models/humans/group99/"..v);
	end;
end;

for k, v in pairs(_file.Find("../models/humans/group09/*.mdl")) do
	if (string.find(string.lower(v), "female")) then
		Clockwork.animation:AddFemaleHumanModel("models/humans/group09/"..v);
	else
		Clockwork.animation:AddMaleHumanModel("models/humans/group09/"..v);
	end;
end;

for k, v in pairs(_file.Find("../models/humans/group10/*.mdl")) do
	if (string.find(string.lower(v), "female")) then
		Clockwork.animation:AddFemaleHumanModel("models/humans/group10/"..v);
	else
		Clockwork.animation:AddMaleHumanModel("models/humans/group10/"..v);
	end;
end;

for k, v in pairs(_file.Find("../models/humans/group08/*.mdl")) do
	if (string.find(string.lower(v), "female")) then
		Clockwork.animation:AddFemaleHumanModel("models/humans/group08/"..v);
	else
		Clockwork.animation:AddMaleHumanModel("models/humans/group08/"..v);
	end;
end;

for k, v in pairs(_file.Find("../models/humans/group07/*.mdl")) do
	if (string.find(string.lower(v), "female")) then
		Clockwork.animation:AddFemaleHumanModel("models/humans/group07/"..v);
	else
		Clockwork.animation:AddMaleHumanModel("models/humans/group07/"..v);
	end;
end;

for k, v in pairs(_file.Find("../models/humans/group04/*.mdl")) do
	if (string.find(string.lower(v), "female")) then
		Clockwork.animation:AddFemaleHumanModel("models/humans/group04/"..v);
	else
		Clockwork.animation:AddMaleHumanModel("models/humans/group04/"..v);
	end;
end;

Clockwork.option:SetKey("model_shipment", "models/props_junk/cardboard_box003b.mdl");
Clockwork.option:SetKey("intro_image", "cwCityLife/citylife2");
Clockwork.option:SetKey("menu_music", "music/hl2_song20_submix0.mp3");
Clockwork.option:SetKey("gradient", "cwCityLife/bg_gradient");

Clockwork.config:ShareKey("using_star_system");
Clockwork.config:ShareKey("intro_text_small");
Clockwork.config:ShareKey("intro_text_big");

Clockwork.quiz:SetName("Agreement");
Clockwork.quiz:SetEnabled(true);
Clockwork.quiz:AddQuestion("I know that because of the logs, I will never get away with rule-breaking.", 1, "Yes.", "No.");
Clockwork.quiz:AddQuestion("When creating a character, I will use a full and appropriate name.", 1, "Yes.", "No.");
Clockwork.quiz:AddQuestion("I understand that the script has vast logs that are checked often.", 1, "Yes.", "No.");
Clockwork.quiz:AddQuestion("I will read the guidelines and directory in the main menu.", 1, "Yes.", "No.");

Clockwork:IncludePrefixed("sh_hooks.lua");
Clockwork:IncludePrefixed("sv_hooks.lua");
Clockwork:IncludePrefixed("cl_hooks.lua");
Clockwork:IncludePrefixed("cl_theme.lua");
Clockwork:IncludePrefixed("sh_coms.lua");

Clockwork.flag:Add("q", "Special", "Access to the special items.");