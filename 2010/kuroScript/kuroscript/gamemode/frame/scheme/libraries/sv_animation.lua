--[[
Name: "sv_animation.lua".
Product: "kuroScript".
--]]

kuroScript.animation = {};
kuroScript.animation.models = {};
kuroScript.animation.stored = {};
kuroScript.animation.convert = {
	[ACT_HL2MP_IDLE_CROSSBOW] = "smg",
	[ACT_HL2MP_IDLE_GRENADE] = "grenade",
	[ACT_HL2MP_IDLE_SHOTGUN] = "smg",
	[ACT_HL2MP_IDLE_PHYSGUN] = "heavy",
	[ACT_HL2MP_IDLE_PISTOL] = "pistol",
	[ACT_HL2MP_IDLE_MELEE2] = "blunt",
	[ACT_HL2MP_IDLE_MELEE] = "blunt",
	[ACT_HL2MP_IDLE_KNIFE] = "blunt",
	[ACT_HL2MP_IDLE_FIST] = "fist",
	[ACT_HL2MP_IDLE_SLAM] = "slam",
	[ACT_HL2MP_IDLE_SMG1] = "smg",
	[ACT_HL2MP_IDLE_AR2] = "smg",
	[ACT_HL2MP_IDLE_RPG] = "heavy",
	[ACT_HL2MP_IDLE] = "fist",
	["gravitygun"] = "pistol",
	["crossbow"] = "heavy",
	["physgun"] = "heavy",
	["grenade"] = "grenade",
	["shotgun"] = "smg",
	["pistol"] = "pistol",
	["normal"] = "fist",
	["melee"] = "blunt",
	["slam"] = "slam",
	["smg"] = "smg",
	["ar2"] = "smg",
	["357"] = "pistol",
	["rpg"] = "heavy"
};

-- Set some information.
kuroScript.animation.holdTypes = {
	["gmod_tool"] = "pistol",
	["weapon_357"] = "pistol",
	["weapon_ar2"] = "smg",
	["weapon_smg1"] = "smg",
	["weapon_frag"] = "grenade",
	["weapon_slam"] = "slam",
	["weapon_pistol"] = "pistol",
	["weapon_crowbar"] = "blunt",
	["weapon_physgun"] = "heavy",
	["weapon_shotgun"] = "smg",
	["weapon_crossbow"] = "smg",
	["weapon_stunstick"] = "blunt",
	["weapon_physcannon"] = "heavy"
};

-- Set some information.
kuroScript.animation.stored.combineOverwatch = {
	["crouch_grenade_aim_idle"] = 5,
	["stand_grenade_aim_idle"] = 1,
	["crouch_pistol_aim_walk"] = 341,
	["crouch_pistol_aim_idle"] = 45,
	["crouch_blunt_aim_walk"] = 341,
	["crouch_heavy_aim_idle"] = 45,
	["crouch_blunt_aim_idle"] = 281,
	["stand_grenade_aim_run"] = 349,
	["crouch_heavy_aim_walk"] = 341,
	["stand_pistol_aim_idle"] = 302,
	["stand_pistol_aim_walk"] = 340,
	["stand_heavy_aim_idle"] = 302,
	["stand_pistol_aim_run"] = 344,
	["stand_heavy_aim_walk"] = 340,
	["crouch_slam_aim_idle"] = 281,
	["stand_blunt_aim_walk"] = 348,
	["crouch_fist_aim_idle"] = 45,
	["crouch_slam_aim_walk"] = 341,
	["crouch_fist_aim_walk"] = 341,
	["stand_blunt_aim_idle"] = 326,
	["crouch_smg_aim_walk"] = 341,
	["crouch_smg_aim_idle"] = 45,
	["crouch_grenade_idle"] = 5,
	["stand_fist_aim_idle"] = 302,
	["stand_blunt_aim_run"] = 349,
	["stand_heavy_aim_run"] = 344,
	["crouch_grenade_walk"] = 341,
	["stand_fist_aim_walk"] = 340,
	["stand_slam_aim_idle"] = 326,
	["stand_grenade_walk"] = 339,
	["crouch_pistol_idle"] = 45,
	["stand_smg_aim_idle"] = 302,
	["stand_fist_aim_run"] = 344,
	["crouch_pistol_walk"] = 341,
	["stand_smg_aim_walk"] = 340,
	["stand_grenade_idle"] = 1,
	["stand_slam_aim_run"] = 343,
	["crouch_heavy_walk"] = 341,
	["stand_smg_aim_run"] = 344,
	["crouch_blunt_idle"] = 5,
	["stand_pistol_idle"] = 1,
	["crouch_blunt_walk"] = 8,
	["stand_pistol_walk"] = 339,
	["crouch_heavy_idle"] = 45,
	["stand_grenade_run"] = 343,
	["crouch_slam_walk"] = 341,
	["stand_heavy_walk"] = 339,
	["crouch_fist_idle"] = 45,
	["stand_blunt_walk"] = 339,
	["stand_heavy_idle"] = 1,
	["crouch_slam_idle"] = 5,
	["stand_blunt_idle"] = 1,
	["crouch_fist_walk"] = 341,
	["stand_pistol_run"] = 343,
	["stand_fist_walk"] = 339,
	["stand_heavy_run"] = 343,
	["stand_slam_idle"] = 1,
	["stand_fist_idle"] = "IDLE_UNARMED",
	["crouch_smg_idle"] = 45,
	["crouch_smg_walk"] = 341,
	["stand_blunt_run"] = 343,
	["stand_smg_walk"] = 339,
	["stand_fist_run"] = 343,
	["stand_smg_idle"] = 1,
	["grenade_attack"] = 274,
	["stand_slam_run"] = 343,
	["stand_smg_run"] = 343,
	["pistol_reload"] = 65,
	["pistol_attack"] = 265,
	["heavy_attack"] = 265,
	["blunt_attack"] = 63,
	["heavy_reload"] = 65,
	["crouch_idle"] = 45,
	["slam_attack"] = 107,
	["crouch_walk"] = 341,
	["stand_walk"] = 339,
	["stand_idle"] = "IDLE_UNARMED",
	["smg_attack"] = 265,
	["smg_reload"] = 65,
	["stand_run"] = 343,
	["jump"] = 27,
	["sit"] = 5
};

-- Set some information.
kuroScript.animation.stored.civilProtection = {
	["crouch_grenade_aim_idle"] = 282,
	["crouch_grenade_aim_walk"] = 6,
	["stand_grenade_aim_idle"] = 1,
	["crouch_pistol_aim_idle"] = 283,
	["crouch_pistol_aim_walk"] = 8,
	["stand_grenade_aim_walk"] = 323,
	["crouch_heavy_aim_idle"] = 283,
	["crouch_blunt_aim_walk"] = 8,
	["stand_pistol_aim_idle"] = 270,
	["stand_grenade_aim_run"] = 10,
	["stand_pistol_aim_walk"] = 352,
	["crouch_blunt_aim_idle"] = 283,
	["crouch_heavy_aim_walk"] = 8,
	["stand_pistol_aim_run"] = 353,
	["crouch_fist_aim_walk"] = 8,
	["stand_blunt_aim_walk"] = 323,
	["crouch_fist_aim_idle"] = 283,
	["stand_blunt_aim_idle"] = 328,
	["stand_heavy_aim_walk"] = 340,
	["crouch_slam_aim_walk"] = 8,
	["crouch_slam_aim_idle"] = 280,
	["stand_heavy_aim_idle"] = 302,
	["crouch_smg_aim_walk"] = 8,
	["stand_slam_aim_idle"] = 326,
	["stand_slam_aim_walk"] = 339,
	["stand_blunt_aim_run"] = 10,
	["crouch_grenade_walk"] = 8,
	["crouch_smg_aim_idle"] = 283,
	["stand_heavy_aim_run"] = 344,
	["stand_fist_aim_walk"] = 340,
	["crouch_grenade_idle"] = 282,
	["stand_fist_aim_idle"] = 265,
	["crouch_pistol_walk"] = 8,
	["stand_fist_aim_run"] = 343,
	["stand_smg_aim_idle"] = 302,
	["crouch_pistol_idle"] = 282,
	["stand_grenade_walk"] = 6,
	["stand_smg_aim_walk"] = 340,
	["stand_grenade_idle"] = 1,
	["stand_slam_aim_run"] = 343,
	["crouch_heavy_walk"] = 8,
	["crouch_blunt_idle"] = 282,
	["stand_pistol_idle"] = 1,
	["crouch_blunt_walk"] = 8,
	["stand_pistol_walk"] = 6,
	["stand_smg_aim_run"] = 344,
	["stand_grenade_run"] = 10,
	["crouch_heavy_idle"] = 283,
	["stand_pistol_run"] = 10,
	["stand_heavy_walk"] = 339,
	["stand_heavy_idle"] = 301,
	["crouch_slam_walk"] = 8,
	["crouch_fist_walk"] = 8,
	["crouch_slam_idle"] = 282,
	["stand_blunt_idle"] = 1,
	["crouch_fist_idle"] = 282,
	["stand_blunt_walk"] = 6,
	["stand_blunt_run"] = 10,
	["stand_slam_idle"] = 1,
	["stand_fist_walk"] = 6,
	["stand_heavy_run"] = 343,
	["stand_slam_walk"] = 6,
	["crouch_smg_walk"] = 8,
	["crouch_smg_idle"] = 283,
	["stand_fist_idle"] = 1,
	["stand_slam_run"] = 10,
	["grenade_attack"] = 274,
	["stand_fist_run"] = 10,
	["stand_smg_idle"] = 301,
	["stand_smg_walk"] = 339,
	["stand_smg_run"] = 343,
	["pistol_reload"] = 357,
	["pistol_attack"] = 270,
	["heavy_attack"] = 265,
	["blunt_attack"] = 277,
	["heavy_reload"] = 359,
	["crouch_idle"] = 282,
	["crouch_walk"] = 8,
	["slam_attack"] = 73,
	["smg_reload"] = 359,
	["stand_walk"] = 6,
	["stand_idle"] = 1,
	["smg_attack"] = 265,
	["stand_run"] = 10,
	["jump"] = 27,
	["sit"] = 282
};

-- Set some information.
kuroScript.animation.stored.femaleHuman = {
	["crouch_grenade_aim_idle"] = 5,
	["crouch_grenade_aim_walk"] = 8,
	["stand_grenade_aim_idle"] = 1,
	["crouch_pistol_aim_idle"] = 266,
	["crouch_pistol_aim_walk"] = 342,
	["stand_grenade_aim_walk"] = 6,
	["crouch_heavy_aim_idle"] = 266,
	["crouch_blunt_aim_walk"] = 341,
	["stand_pistol_aim_idle"] = 304,
	["stand_grenade_aim_run"] = 10,
	["stand_pistol_aim_walk"] = 352,
	["crouch_blunt_aim_idle"] = 60,
	["crouch_heavy_aim_walk"] = 340,
	["stand_pistol_aim_run"] = 353,
	["crouch_fist_aim_walk"] = 340,
	["stand_blunt_aim_walk"] = 340,
	["crouch_fist_aim_idle"] = 279,
	["stand_blunt_aim_idle"] = 326,
	["stand_heavy_aim_walk"] = 318,
	["crouch_slam_aim_walk"] = 335,
	["crouch_slam_aim_idle"] = 332,
	["stand_heavy_aim_idle"] = 331,
	["crouch_smg_aim_walk"] = 340,
	["stand_slam_aim_idle"] = 307,
	["stand_slam_aim_walk"] = 308,
	["stand_blunt_aim_run"] = 488,
	["crouch_grenade_walk"] = 8,
	["crouch_smg_aim_idle"] = 266,
	["stand_heavy_aim_run"] = 319,
	["stand_fist_aim_walk"] = 318,
	["crouch_grenade_idle"] = 5,
	["stand_fist_aim_idle"] = 265,
	["crouch_pistol_walk"] = 8,
	["stand_fist_aim_run"] = 319,
	["stand_smg_aim_idle"] = 265,
	["crouch_pistol_idle"] = 5,
	["stand_grenade_walk"] = 6,
	["stand_smg_aim_walk"] = 318,
	["stand_grenade_idle"] = 1,
	["stand_slam_aim_run"] = 334,
	["crouch_heavy_walk"] = 335,
	["crouch_blunt_idle"] = 5,
	["stand_pistol_idle"] = 1,
	["crouch_blunt_walk"] = 8,
	["stand_pistol_walk"] = 6,
	["stand_smg_aim_run"] = 319,
	["stand_grenade_run"] = 10,
	["crouch_heavy_idle"] = 332,
	["stand_pistol_run"] = 10,
	["stand_heavy_walk"] = 337,
	["stand_heavy_idle"] = 322,
	["crouch_slam_walk"] = 335,
	["crouch_fist_walk"] = 8,
	["crouch_slam_idle"] = 3,
	["stand_blunt_idle"] = 1,
	["crouch_fist_idle"] = 5,
	["stand_blunt_walk"] = 6,
	["stand_blunt_run"] = 10,
	["stand_slam_idle"] = 309,
	["stand_fist_walk"] = 6,
	["stand_heavy_run"] = 338,
	["stand_slam_walk"] = 310,
	["crouch_smg_walk"] = 335,
	["crouch_smg_idle"] = 332,
	["stand_fist_idle"] = 1,
	["stand_slam_run"] = 10,
	["grenade_attack"] = 274,
	["stand_fist_run"] = 10,
	["stand_smg_idle"] = 311,
	["stand_smg_walk"] = 313,
	["stand_smg_run"] = 316,
	["pistol_reload"] = 365,
	["pistol_attack"] = 289,
	["heavy_attack"] = 289,
	["blunt_attack"] = 277,
	["heavy_reload"] = 365,
	["crouch_idle"] = 5,
	["crouch_walk"] = 8,
	["slam_attack"] = 73,
	["smg_reload"] = 365,
	["stand_walk"] = 6,
	["stand_idle"] = 1,
	["smg_attack"] = 289,
	["stand_run"] = 10,
	["jump"] = 27,
	["sit"] = 5
};

-- Set some information.
kuroScript.animation.stored.maleHuman = {
	["crouch_grenade_aim_idle"] = 5,
	["crouch_grenade_aim_walk"] = 8,
	["stand_grenade_aim_idle"] = 1,
	["crouch_pistol_aim_idle"] = 271,
	["crouch_pistol_aim_walk"] = 340,
	["stand_grenade_aim_walk"] = 6,
	["crouch_heavy_aim_idle"] = 266,
	["crouch_blunt_aim_walk"] = 341,
	["stand_pistol_aim_idle"] = 270,
	["stand_grenade_aim_run"] = 10,
	["stand_pistol_aim_walk"] = 318,
	["crouch_blunt_aim_idle"] = 60,
	["crouch_heavy_aim_walk"] = 340,
	["stand_pistol_aim_run"] = 319,
	["crouch_fist_aim_walk"] = 340,
	["stand_blunt_aim_walk"] = 340,
	["crouch_fist_aim_idle"] = 279,
	["stand_blunt_aim_idle"] = 326,
	["stand_heavy_aim_walk"] = 318,
	["crouch_slam_aim_walk"] = 335,
	["crouch_slam_aim_idle"] = 332,
	["stand_heavy_aim_idle"] = 331,
	["crouch_smg_aim_walk"] = 340,
	["stand_slam_aim_idle"] = 307,
	["stand_slam_aim_walk"] = 308,
	["stand_blunt_aim_run"] = 488,
	["crouch_grenade_walk"] = 8,
	["crouch_smg_aim_idle"] = 266,
	["stand_heavy_aim_run"] = 319,
	["stand_fist_aim_walk"] = 318,
	["crouch_grenade_idle"] = 5,
	["stand_fist_aim_idle"] = 265,
	["crouch_pistol_walk"] = 8,
	["stand_fist_aim_run"] = 319,
	["stand_smg_aim_idle"] = 265,
	["crouch_pistol_idle"] = 5,
	["stand_grenade_walk"] = 6,
	["stand_smg_aim_walk"] = 318,
	["stand_grenade_idle"] = 1,
	["stand_slam_aim_run"] = 334,
	["crouch_heavy_walk"] = 335,
	["crouch_blunt_idle"] = 5,
	["stand_pistol_idle"] = 1,
	["crouch_blunt_walk"] = 8,
	["stand_pistol_walk"] = 6,
	["stand_smg_aim_run"] = 319,
	["stand_grenade_run"] = 10,
	["crouch_heavy_idle"] = 332,
	["stand_pistol_run"] = 10,
	["stand_heavy_walk"] = 337,
	["stand_heavy_idle"] = 322,
	["crouch_slam_walk"] = 335,
	["crouch_fist_walk"] = 8,
	["crouch_slam_idle"] = 3,
	["stand_blunt_idle"] = 1,
	["crouch_fist_idle"] = 5,
	["stand_blunt_walk"] = 6,
	["stand_blunt_run"] = 10,
	["stand_slam_idle"] = 309,
	["stand_fist_walk"] = 6,
	["stand_heavy_run"] = 338,
	["stand_slam_walk"] = 310,
	["crouch_smg_walk"] = 335,
	["crouch_smg_idle"] = 332,
	["stand_fist_idle"] = 1,
	["stand_slam_run"] = 10,
	["grenade_attack"] = 274,
	["stand_fist_run"] = 10,
	["stand_smg_idle"] = 330,
	["stand_smg_walk"] = 337,
	["stand_smg_run"] = 338,
	["pistol_reload"] = 365,
	["pistol_attack"] = 270,
	["heavy_attack"] = 260,
	["blunt_attack"] = 277,
	["heavy_reload"] = 365,
	["crouch_idle"] = 5,
	["crouch_walk"] = 8,
	["slam_attack"] = 73,
	["smg_reload"] = 365,
	["stand_walk"] = 6,
	["stand_idle"] = 1,
	["smg_attack"] = 265,
	["stand_run"] = 10,
	["jump"] = 27,
	["sit"] = 5
};

-- A function to add a model.
function kuroScript.animation.addModel(class, model)
	kuroScript.animation.models[ string.lower(model) ] = class;
end;

-- A function to get a model's class.
function kuroScript.animation.getModelClass(model)
	return kuroScript.animation.models[ string.lower(model) ];
end;

-- A function to add a Combine Overwatch model.
function kuroScript.animation.AddCombineOverwatchModel(model)
	kuroScript.animation.addModel("combineOverwatch", model);
end;

-- A function to add a Civil Protection model.
function kuroScript.animation.AddCivilProtectionModel(model)
	kuroScript.animation.addModel("civilProtection", model);
end;

-- A function to add a female human model.
function kuroScript.animation.AddFemaleHumanModel(model)
	kuroScript.animation.addModel("femaleHuman", model);
end;

-- A function to add a male human model.
function kuroScript.animation.AddMaleHumanModel(model)
	kuroScript.animation.addModel("maleHuman", model);
end;

-- A function to get a weapon's hold type.
function kuroScript.animation.GetWeaponHoldType(player, weapon)
	local class = string.lower( weapon:GetClass() );
	local weaponTable = weapons.GetStored(class);
	
	-- Check if a statement is true.
	if ( kuroScript.animation.holdTypes[class] ) then
		return kuroScript.animation.holdTypes[class];
	elseif (weaponTable and weaponTable.HoldType) then
		if ( kuroScript.animation.convert[weaponTable.HoldType] ) then
			return kuroScript.animation.convert[weaponTable.HoldType];
		else
			return weaponTable.HoldType;
		end;
	else
		local act = player:Weapon_TranslateActivity(ACT_HL2MP_IDLE) or -1;
		
		-- Check if a statement is true.
		if (act != -1) then
			if ( kuroScript.animation.convert[act] ) then
				return kuroScript.animation.convert[act];
			else
				return "fist";
			end;
		else
			return "fist";
		end;
	end;
end;

-- A function to get an animation table.
function kuroScript.animation.GetTable(model)
	local lowerModel = string.lower(model);
	local class = kuroScript.animation.models[lowerModel];
	
	-- Check if a statement is true.
	if ( class and kuroScript.animation.stored[class] ) then
		return kuroScript.animation.stored[class];
	elseif ( string.find(lowerModel, "female") ) then
		return kuroScript.animation.stored.femaleHuman;
	else
		return kuroScript.animation.stored.maleHuman;
	end;
end;

-- Add some Combine Overwatch models.
kuroScript.animation.AddCombineOverwatchModel("models/combine_soldier_prisonguard.mdl");
kuroScript.animation.AddCombineOverwatchModel("models/combine_super_soldier.mdl");
kuroScript.animation.AddCombineOverwatchModel("models/combine_soldier.mdl");

-- Add some Civil Protection models.
kuroScript.animation.AddCivilProtectionModel("models/police.mdl");
kuroScript.animation.AddCivilProtectionModel("models/yellowlake/BlaCop.mdl");
kuroScript.animation.AddCivilProtectionModel("models/biopolice.mdl");
kuroScript.animation.AddCivilProtectionModel("models/C08Cop.mdl");
kuroScript.animation.AddCivilProtectionModel("models/c08coptrench.mdl");
kuroScript.animation.AddCivilProtectionModel("models/c08sql.mdl");
kuroScript.animation.AddCivilProtectionModel("models/echocp.mdl");
kuroScript.animation.AddCivilProtectionModel("models/eliteghostcp.mdl");
kuroScript.animation.AddCivilProtectionModel("models/eliteshockcp.mdl");
kuroScript.animation.AddCivilProtectionModel("models/leet_police2.mdl");
kuroScript.animation.AddCivilProtectionModel("models/leet_police_bt.mdl");
kuroScript.animation.AddCivilProtectionModel("models/metrold.mdl");
kuroScript.animation.AddCivilProtectionModel("models/policetrench.mdl");
kuroScript.animation.AddCivilProtectionModel("models/police_opcmd.mdl");
kuroScript.animation.AddCivilProtectionModel("models/Redice.mdl");
kuroScript.animation.AddCivilProtectionModel("models/Rolice.mdl");
kuroScript.animation.AddCivilProtectionModel("models/sect_police2.mdl");
kuroScript.animation.AddCivilProtectionModel("models/tribal.mdl");
kuroScript.animation.AddCivilProtectionModel("models/urbantrenchcoat.mdl");

-- Add some female human models.
kuroScript.animation.AddFemaleHumanModel("models/humans/group01/female_01.mdl");
kuroScript.animation.AddFemaleHumanModel("models/humans/group01/female_02.mdl");
kuroScript.animation.AddFemaleHumanModel("models/humans/group01/female_03.mdl");
kuroScript.animation.AddFemaleHumanModel("models/humans/group01/female_04.mdl");
kuroScript.animation.AddFemaleHumanModel("models/humans/group01/female_06.mdl");
kuroScript.animation.AddFemaleHumanModel("models/humans/group01/female_07.mdl");
kuroScript.animation.AddFemaleHumanModel("models/humans/group02/female_01.mdl");
kuroScript.animation.AddFemaleHumanModel("models/humans/group02/female_02.mdl");
kuroScript.animation.AddFemaleHumanModel("models/humans/group02/female_03.mdl");
kuroScript.animation.AddFemaleHumanModel("models/humans/group02/female_04.mdl");
kuroScript.animation.AddFemaleHumanModel("models/humans/group02/female_06.mdl");
kuroScript.animation.AddFemaleHumanModel("models/humans/group02/female_07.mdl");
kuroScript.animation.AddFemaleHumanModel("models/humans/group03/female_01.mdl");
kuroScript.animation.AddFemaleHumanModel("models/humans/group03/female_02.mdl");
kuroScript.animation.AddFemaleHumanModel("models/humans/group03/female_03.mdl");
kuroScript.animation.AddFemaleHumanModel("models/humans/group03/female_04.mdl");
kuroScript.animation.AddFemaleHumanModel("models/humans/group03/female_06.mdl");
kuroScript.animation.AddFemaleHumanModel("models/humans/group03/female_07.mdl");
kuroScript.animation.AddFemaleHumanModel("models/humans/group03m/female_01.mdl");
kuroScript.animation.AddFemaleHumanModel("models/humans/group03m/female_02.mdl");
kuroScript.animation.AddFemaleHumanModel("models/humans/group03m/female_03.mdl");
kuroScript.animation.AddFemaleHumanModel("models/humans/group03m/female_04.mdl");
kuroScript.animation.AddFemaleHumanModel("models/humans/group03m/female_06.mdl");
kuroScript.animation.AddFemaleHumanModel("models/humans/group03m/female_07.mdl");
kuroScript.animation.AddFemaleHumanModel("models/barnes/Refugee/Female_01.mdl");
kuroScript.animation.AddFemaleHumanModel("models/barnes/Refugee/Female_02.mdl");
kuroScript.animation.AddFemaleHumanModel("models/barnes/Refugee/Female_03.mdl");
kuroScript.animation.AddFemaleHumanModel("models/barnes/Refugee/Female_04.mdl");
kuroScript.animation.AddFemaleHumanModel("models/barnes/Refugee/Female_06.mdl");
kuroScript.animation.AddFemaleHumanModel("models/barnes/Refugee/Female_07.mdl");
kuroScript.animation.AddFemaleHumanModel("models/barnes/Refugee/female_19.mdl");
kuroScript.animation.AddFemaleHumanModel("models/barnes/citizen/Female_01.mdl");
kuroScript.animation.AddFemaleHumanModel("models/barnes/citizen/Female_02.mdl");
kuroScript.animation.AddFemaleHumanModel("models/barnes/citizen/Female_03.mdl");
kuroScript.animation.AddFemaleHumanModel("models/barnes/citizen/Female_04.mdl");
kuroScript.animation.AddFemaleHumanModel("models/barnes/citizen/Female_06.mdl");
kuroScript.animation.AddFemaleHumanModel("models/barnes/citizen/Female_07.mdl");
kuroScript.animation.AddFemaleHumanModel("models/humans/airex/airex_female.mdl");
kuroScript.animation.AddFemaleHumanModel("models/humans/group01/anony_ray.mdl");
kuroScript.animation.AddFemaleHumanModel("models/humans/group01/anony_rus.mdl");
kuroScript.animation.AddFemaleHumanModel("models/humans/group01/drconnors.mdl");
kuroScript.animation.AddFemaleHumanModel("models/humans/group01/female_05.mdl");
kuroScript.animation.AddFemaleHumanModel("models/humans/group01/female_08.mdl");
kuroScript.animation.AddFemaleHumanModel("models/humans/group01/female_09.mdl");
kuroScript.animation.AddFemaleHumanModel("models/humans/group01/female_10.mdl");
kuroScript.animation.AddFemaleHumanModel("models/humans/group01/female_11.mdl");
kuroScript.animation.AddFemaleHumanModel("models/humans/group01/female_12.mdl");
kuroScript.animation.AddFemaleHumanModel("models/humans/group01/female_13.mdl");
kuroScript.animation.AddFemaleHumanModel("models/humans/group01/female_14.mdl");
kuroScript.animation.AddFemaleHumanModel("models/humans/group01/female_15.mdl");
kuroScript.animation.AddFemaleHumanModel("models/humans/group01/female_16.mdl");
kuroScript.animation.AddFemaleHumanModel("models/humans/group01/Female_17.mdl");
kuroScript.animation.AddFemaleHumanModel("models/humans/group01/female_18.mdl");
kuroScript.animation.AddFemaleHumanModel("models/humans/group01/female_19.mdl");
kuroScript.animation.AddFemaleHumanModel("models/humans/group01/gurne_vaccine.mdl");
kuroScript.animation.AddFemaleHumanModel("models/humans/group01/shac_chrissie.mdl");
kuroScript.animation.AddFemaleHumanModel("models/humans/group02/casualfem.mdl");
kuroScript.animation.AddFemaleHumanModel("models/humans/group03/anna_snood.mdl");
kuroScript.animation.AddFemaleHumanModel("models/humans/group03/female_05.mdl");
kuroScript.animation.AddFemaleHumanModel("models/humans/group03/female_08.mdl");
kuroScript.animation.AddFemaleHumanModel("models/humans/group03/female_09.mdl");
kuroScript.animation.AddFemaleHumanModel("models/humans/group03/female_10.mdl");
kuroScript.animation.AddFemaleHumanModel("models/humans/group03/female_11.mdl");
kuroScript.animation.AddFemaleHumanModel("models/humans/group03/female_12.mdl");
kuroScript.animation.AddFemaleHumanModel("models/humans/group03/female_13.mdl");
kuroScript.animation.AddFemaleHumanModel("models/humans/group03/female_14.mdl");
kuroScript.animation.AddFemaleHumanModel("models/humans/group03/female_15.mdl");
kuroScript.animation.AddFemaleHumanModel("models/humans/group03/female_16.mdl");
kuroScript.animation.AddFemaleHumanModel("models/humans/group03/female_17.mdl");
kuroScript.animation.AddFemaleHumanModel("models/humans/group03/female_18.mdl");
kuroScript.animation.AddFemaleHumanModel("models/humans/group03/female_19.mdl");
kuroScript.animation.AddFemaleHumanModel("models/humans/group03/gurne_vaccine_citizen.mdl");
kuroScript.animation.AddFemaleHumanModel("models/humans/group04/female_02.mdl");
kuroScript.animation.AddFemaleHumanModel("models/humans/group04/female_02.mdl");
kuroScript.animation.AddFemaleHumanModel("models/humans/group04/female_02.mdl");
kuroScript.animation.AddFemaleHumanModel("models/humans/group03m/female_05.mdl");
kuroScript.animation.AddFemaleHumanModel("models/humans/group03m/female_08.mdl");
kuroScript.animation.AddFemaleHumanModel("models/humans/group03m/female_09.mdl");
kuroScript.animation.AddFemaleHumanModel("models/humans/group03m/female_10.mdl");
kuroScript.animation.AddFemaleHumanModel("models/humans/group03m/female_11.mdl");
kuroScript.animation.AddFemaleHumanModel("models/humans/group03m/female_12.mdl");
kuroScript.animation.AddFemaleHumanModel("models/humans/group03m/female_13.mdl");
kuroScript.animation.AddFemaleHumanModel("models/humans/group03m/female_14.mdl");
kuroScript.animation.AddFemaleHumanModel("models/humans/group03m/female_15.mdl");
kuroScript.animation.AddFemaleHumanModel("models/humans/group03m/female_16.mdl");
kuroScript.animation.AddFemaleHumanModel("models/humans/group03m/female_17.mdl");
kuroScript.animation.AddFemaleHumanModel("models/humans/group03m/female_18.mdl");
kuroScript.animation.AddFemaleHumanModel("models/humans/group03m/female_19.mdl");
kuroScript.animation.AddFemaleHumanModel("models/jbarnes/rebels/miko.mdl");
kuroScript.animation.AddFemaleHumanModel("models/thespectator/assassin.mdl");
kuroScript.animation.AddFemaleHumanModel("models/thespectator/atsushi8.mdl");
kuroScript.animation.AddFemaleHumanModel("models/alyn.mdl");
kuroScript.animation.AddFemaleHumanModel("models/c08cop_female.mdl");
kuroScript.animation.AddFemaleHumanModel("models/police_female.mdl");
kuroScript.animation.AddFemaleHumanModel("models/police_female_blondecp.mdl");
kuroScript.animation.AddFemaleHumanModel("models/police_female_darkhair.mdl");
kuroScript.animation.AddFemaleHumanModel("models/police_female_finalcop.mdl");
kuroScript.animation.AddFemaleHumanModel("models/police_female_unmasked.mdl");
kuroScript.animation.AddFemaleHumanModel("models/police_female_unmasked_c8.mdl");
kuroScript.animation.AddFemaleHumanModel("models/humans/airex/airex_female.mdl");
kuroScript.animation.AddFemaleHumanModel("models/barnes/citizen/Female_01.mdl");
kuroScript.animation.AddFemaleHumanModel("models/barnes/citizen/Female_02.mdl");
kuroScript.animation.AddFemaleHumanModel("models/barnes/citizen/Female_03.mdl");
kuroScript.animation.AddFemaleHumanModel("models/barnes/citizen/Female_04.mdl");
kuroScript.animation.AddFemaleHumanModel("models/barnes/citizen/female_05.mdl");
kuroScript.animation.AddFemaleHumanModel("models/barnes/citizen/Female_06.mdl");
kuroScript.animation.AddFemaleHumanModel("models/barnes/citizen/Female_07.mdl");
kuroScript.animation.AddFemaleHumanModel("models/barnes/citizen/female_08.mdl");
kuroScript.animation.AddFemaleHumanModel("models/barnes/citizen/female_09.mdl");
kuroScript.animation.AddFemaleHumanModel("models/barnes/citizen/female_10.mdl");
kuroScript.animation.AddFemaleHumanModel("models/barnes/citizen/female_11.mdl");
kuroScript.animation.AddFemaleHumanModel("models/barnes/citizen/female_14.mdl");
kuroScript.animation.AddFemaleHumanModel("models/barnes/citizen/female_18.mdl");
kuroScript.animation.AddFemaleHumanModel("models/alpha1/group05/female_05.mdl");
kuroScript.animation.AddFemaleHumanModel("models/alpha1/group05/female_08.mdl");
kuroScript.animation.AddFemaleHumanModel("models/alpha1/group05/female_09.mdl");
kuroScript.animation.AddFemaleHumanModel("models/alpha1/group05/female_10.mdl");
kuroScript.animation.AddFemaleHumanModel("models/alpha1/group05/female_11.mdl");
kuroScript.animation.AddFemaleHumanModel("models/alpha1/group05/female_14.mdl");
kuroScript.animation.AddFemaleHumanModel("models/alpha1/group05/female_18.mdl");
kuroScript.animation.AddFemaleHumanModel("models/alpha1/group01/female_01.mdl");
kuroScript.animation.AddFemaleHumanModel("models/alpha1/group01/female_02.mdl");
kuroScript.animation.AddFemaleHumanModel("models/alpha1/group01/female_03.mdl");
kuroScript.animation.AddFemaleHumanModel("models/alpha1/group01/female_04.mdl");
kuroScript.animation.AddFemaleHumanModel("models/alpha1/group01/female_05.mdl");
kuroScript.animation.AddFemaleHumanModel("models/alpha1/group01/female_06.mdl");
kuroScript.animation.AddFemaleHumanModel("models/alpha1/group01/female_07.mdl");
kuroScript.animation.AddFemaleHumanModel("models/alpha1/group01/female_08.mdl");
kuroScript.animation.AddFemaleHumanModel("models/alpha1/group01/female_09.mdl");
kuroScript.animation.AddFemaleHumanModel("models/alpha1/group01/female_10.mdl");
kuroScript.animation.AddFemaleHumanModel("models/alpha1/group01/female_11.mdl");
kuroScript.animation.AddFemaleHumanModel("models/alpha1/group01/female_12.mdl");
kuroScript.animation.AddFemaleHumanModel("models/alpha1/group01/female_14.mdl");
kuroScript.animation.AddFemaleHumanModel("models/alpha1/group01/female_18.mdl");
kuroScript.animation.AddFemaleHumanModel("models/alpha1/alphaHL/female_01.mdl");
kuroScript.animation.AddFemaleHumanModel("models/alpha1/alphaHL/female_02.mdl");
kuroScript.animation.AddFemaleHumanModel("models/alpha1/alphaHL/female_03.mdl");
kuroScript.animation.AddFemaleHumanModel("models/alpha1/alphaHL/female_04.mdl");
kuroScript.animation.AddFemaleHumanModel("models/alpha1/alphaHL/female_05.mdl");
kuroScript.animation.AddFemaleHumanModel("models/alpha1/alphaHL/female_06.mdl");
kuroScript.animation.AddFemaleHumanModel("models/alpha1/alphaHL/female_07.mdl");
kuroScript.animation.AddFemaleHumanModel("models/alpha1/alphaHL/female_08.mdl");
kuroScript.animation.AddFemaleHumanModel("models/alpha1/alphaHL/female_09.mdl");
kuroScript.animation.AddFemaleHumanModel("models/alpha1/alphaHL/female_10.mdl");
kuroScript.animation.AddFemaleHumanModel("models/alpha1/alphaHL/female_11.mdl");
kuroScript.animation.AddFemaleHumanModel("models/alpha1/alphaHL/female_12.mdl");
kuroScript.animation.AddFemaleHumanModel("models/alpha1/alphaHL/female_14.mdl");
kuroScript.animation.AddFemaleHumanModel("models/alpha1/alphaHL/female_18.mdl");
  
-- Add some male human models.
kuroScript.animation.AddMaleHumanModel("models/humans/group01/male_01.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group01/male_02.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group01/male_03.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group01/male_04.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group01/male_05.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group01/male_06.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group01/male_07.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group01/male_08.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group01/male_09.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group02/male_01.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group02/male_02.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group02/male_03.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group02/male_04.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group02/male_05.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group02/male_06.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group02/male_07.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group02/male_08.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group02/male_09.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group03/male_01.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group03/male_02.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group03/male_03.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group03/male_04.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group03/male_05.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group03/male_06.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group03/male_07.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group03/male_08.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group03/male_09.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group03m/male_01.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group03m/male_02.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group03m/male_03.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group03m/male_04.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group03m/male_05.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group03m/male_06.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group03m/male_07.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group03m/male_08.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group03m/male_09.mdl");
kuroScript.animation.AddMaleHumanModel("models/Purvis/keiichi_metrocop.mdl");
kuroScript.animation.AddMaleHumanModel("models/Purvis/male_01_metrocop.mdl");
kuroScript.animation.AddMaleHumanModel("models/Purvis/male_02_metrocop.mdl");
kuroScript.animation.AddMaleHumanModel("models/Purvis/male_03_metrocop.mdl");
kuroScript.animation.AddMaleHumanModel("models/Purvis/male_04_metrocop.mdl");
kuroScript.animation.AddMaleHumanModel("models/Purvis/male_05_metrocop.mdl");
kuroScript.animation.AddMaleHumanModel("models/Purvis/male_06_metrocop.mdl");
kuroScript.animation.AddMaleHumanModel("models/Purvis/male_07_metrocop.mdl");
kuroScript.animation.AddMaleHumanModel("models/Purvis/male_08_metrocop.mdl");
kuroScript.animation.AddMaleHumanModel("models/Purvis/male_09_metrocop.mdl");
kuroScript.animation.AddMaleHumanModel("models/Purvis/male_10_metrocop.mdl");
kuroScript.animation.AddMaleHumanModel("models/Purvis/male_12_metrocop.mdl");
kuroScript.animation.AddMaleHumanModel("models/Purvis/male_16_metrocop.mdl");
kuroScript.animation.AddMaleHumanModel("models/Purvis/male_18_metrocop.mdl");
kuroScript.animation.AddMaleHumanModel("models/Purvis/male_20_metrocop.mdl");
kuroScript.animation.AddMaleHumanModel("models/Purvis/male_24_metrocop.mdl");
kuroScript.animation.AddMaleHumanModel("models/Purvis/male_25_metrocop.mdl");
kuroScript.animation.AddMaleHumanModel("models/barnes/Refugee/Male_01.mdl");
kuroScript.animation.AddMaleHumanModel("models/barnes/Refugee/male_02.mdl");
kuroScript.animation.AddMaleHumanModel("models/barnes/Refugee/male_03.mdl");
kuroScript.animation.AddMaleHumanModel("models/barnes/Refugee/Male_04.mdl");
kuroScript.animation.AddMaleHumanModel("models/barnes/Refugee/Male_05.mdl");
kuroScript.animation.AddMaleHumanModel("models/barnes/Refugee/male_06.mdl");
kuroScript.animation.AddMaleHumanModel("models/barnes/Refugee/male_07.mdl");
kuroScript.animation.AddMaleHumanModel("models/barnes/Refugee/male_08.mdl");
kuroScript.animation.AddMaleHumanModel("models/barnes/Refugee/male_09.mdl");
kuroScript.animation.AddMaleHumanModel("models/barnes/citizen/Male_01.mdl");
kuroScript.animation.AddMaleHumanModel("models/barnes/citizen/male_02.mdl");
kuroScript.animation.AddMaleHumanModel("models/barnes/citizen/male_03.mdl");
kuroScript.animation.AddMaleHumanModel("models/barnes/citizen/Male_04.mdl");
kuroScript.animation.AddMaleHumanModel("models/barnes/citizen/Male_05.mdl");
kuroScript.animation.AddMaleHumanModel("models/barnes/citizen/male_06.mdl");
kuroScript.animation.AddMaleHumanModel("models/barnes/citizen/male_07.mdl");
kuroScript.animation.AddMaleHumanModel("models/barnes/citizen/male_08.mdl");
kuroScript.animation.AddMaleHumanModel("models/barnes/citizen/male_09.mdl");
kuroScript.animation.AddMaleHumanModel("models/characters/gallaha.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/eze_unknown.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/sinner_sas.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/airex/airex_male.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/airex/male_04.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/barnes/oshikawa.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group01/jasona.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group01/male_00.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group01/male_10.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group01/male_11.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group01/male_12.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group01/male_13.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group01/male_14.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group01/male_15.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group01/male_16.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group01/male_17.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group01/male_18.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group01/male_19.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group01/male_20.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group01/male_21.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group01/male_22.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group01/male_23.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group01/male_24.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group01/male_25.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group01/male_26.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group01/male_27.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group01/male_28.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group01/male_postal.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group01/marky_rileyh.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group01/shac_durke.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group03/hassan_dk.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group03/male_10.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group03/male_11.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group03/male_12.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group03/male_13.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group03/male_14.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group03/male_15.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group03/male_16.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group03/male_17.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group03/male_18.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group03/male_19.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group03/male_20.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group03/male_21.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group03/male_22.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group03/male_23.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group03/male_24.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group03/male_25.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group03/male_26.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group03/male_27.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group03/male_28.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group03/male_fuhrer.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group03/male_soldier.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group03m/male_10.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group03m/male_11.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group03m/male_12.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group03m/male_13.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group03m/male_14.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group03m/male_15.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group03m/male_16.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group03m/male_17.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group03m/male_18.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group03m/male_19.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group03m/male_20.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group03m/male_21.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group03m/male_22.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group03m/male_23.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group03m/male_24.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group03m/male_25.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group03m/male_26.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group03m/male_27.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group04/male_04.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/nogardm/nogardf.mdl");
kuroScript.animation.AddMaleHumanModel("models/tactical_rebel.mdl");
kuroScript.animation.AddMaleHumanModel("models/barnes/citizen/Male_01.mdl");
kuroScript.animation.AddMaleHumanModel("models/barnes/citizen/male_02.mdl");
kuroScript.animation.AddMaleHumanModel("models/barnes/citizen/male_03.mdl");
kuroScript.animation.AddMaleHumanModel("models/barnes/citizen/Male_04.mdl");
kuroScript.animation.AddMaleHumanModel("models/barnes/citizen/Male_05.mdl");
kuroScript.animation.AddMaleHumanModel("models/barnes/citizen/male_06.mdl");
kuroScript.animation.AddMaleHumanModel("models/barnes/citizen/male_07.mdl");
kuroScript.animation.AddMaleHumanModel("models/barnes/citizen/male_08.mdl");
kuroScript.animation.AddMaleHumanModel("models/barnes/citizen/male_09.mdl");
kuroScript.animation.AddMaleHumanModel("models/barnes/citizen/male_10.mdl");
kuroScript.animation.AddMaleHumanModel("models/barnes/citizen/male_11.mdl");
kuroScript.animation.AddMaleHumanModel("models/barnes/citizen/male_12.mdl");
kuroScript.animation.AddMaleHumanModel("models/barnes/citizen/male_13.mdl");
kuroScript.animation.AddMaleHumanModel("models/barnes/citizen/male_14.mdl");
kuroScript.animation.AddMaleHumanModel("models/barnes/citizen/male_15.mdl");
kuroScript.animation.AddMaleHumanModel("models/barnes/citizen/male_16.mdl");
kuroScript.animation.AddMaleHumanModel("models/barnes/citizen/male_18.mdl");
kuroScript.animation.AddMaleHumanModel("models/barnes/citizen/male_20.mdl");
kuroScript.animation.AddMaleHumanModel("models/barnes/citizen/male_21.mdl");
kuroScript.animation.AddMaleHumanModel("models/barnes/citizen/male_22.mdl");
kuroScript.animation.AddMaleHumanModel("models/barnes/citizen/male_23.mdl");
kuroScript.animation.AddMaleHumanModel("models/barnes/citizen/male_24.mdl");
kuroScript.animation.AddMaleHumanModel("models/barnes/citizen/male_25.mdl");
kuroScript.animation.AddMaleHumanModel("models/barnes/citizen/male_26.mdl");
kuroScript.animation.AddMaleHumanModel("models/barnes/citizen/male_28.mdl");
kuroScript.animation.AddMaleHumanModel("models/alpha1/group05/male_10.mdl");
kuroScript.animation.AddMaleHumanModel("models/alpha1/group05/male_11.mdl");
kuroScript.animation.AddMaleHumanModel("models/alpha1/group05/male_12.mdl");
kuroScript.animation.AddMaleHumanModel("models/alpha1/group05/male_13.mdl");
kuroScript.animation.AddMaleHumanModel("models/alpha1/group05/male_14.mdl");
kuroScript.animation.AddMaleHumanModel("models/alpha1/group05/male_15.mdl");
kuroScript.animation.AddMaleHumanModel("models/alpha1/group05/male_16.mdl");
kuroScript.animation.AddMaleHumanModel("models/alpha1/group05/male_18.mdl");
kuroScript.animation.AddMaleHumanModel("models/alpha1/group05/male_20.mdl");
kuroScript.animation.AddMaleHumanModel("models/alpha1/group05/male_21.mdl");
kuroScript.animation.AddMaleHumanModel("models/alpha1/group05/male_22.mdl");
kuroScript.animation.AddMaleHumanModel("models/alpha1/group05/male_23.mdl");
kuroScript.animation.AddMaleHumanModel("models/alpha1/group05/male_24.mdl");
kuroScript.animation.AddMaleHumanModel("models/alpha1/group05/male_25.mdl");
kuroScript.animation.AddMaleHumanModel("models/alpha1/group05/male_26.mdl");
kuroScript.animation.AddMaleHumanModel("models/alpha1/group05/male_28.mdl");
kuroScript.animation.AddMaleHumanModel("models/alpha1/group01/male_01.mdl");
kuroScript.animation.AddMaleHumanModel("models/alpha1/group01/male_02.mdl");
kuroScript.animation.AddMaleHumanModel("models/alpha1/group01/male_03.mdl");
kuroScript.animation.AddMaleHumanModel("models/alpha1/group01/male_04.mdl");
kuroScript.animation.AddMaleHumanModel("models/alpha1/group01/male_05.mdl");
kuroScript.animation.AddMaleHumanModel("models/alpha1/group01/male_06.mdl");
kuroScript.animation.AddMaleHumanModel("models/alpha1/group01/male_07.mdl");
kuroScript.animation.AddMaleHumanModel("models/alpha1/group01/male_08.mdl");
kuroScript.animation.AddMaleHumanModel("models/alpha1/group01/male_09.mdl");
kuroScript.animation.AddMaleHumanModel("models/alpha1/group01/male_10.mdl");
kuroScript.animation.AddMaleHumanModel("models/alpha1/group01/male_11.mdl");
kuroScript.animation.AddMaleHumanModel("models/alpha1/group01/male_12.mdl");
kuroScript.animation.AddMaleHumanModel("models/alpha1/group01/male_13.mdl");
kuroScript.animation.AddMaleHumanModel("models/alpha1/group01/male_14.mdl");
kuroScript.animation.AddMaleHumanModel("models/alpha1/group01/male_15.mdl");
kuroScript.animation.AddMaleHumanModel("models/alpha1/group01/male_16.mdl");
kuroScript.animation.AddMaleHumanModel("models/alpha1/group01/male_18.mdl");
kuroScript.animation.AddMaleHumanModel("models/alpha1/group01/male_19.mdl");
kuroScript.animation.AddMaleHumanModel("models/alpha1/group01/male_20.mdl");
kuroScript.animation.AddMaleHumanModel("models/alpha1/group01/male_21.mdl");
kuroScript.animation.AddMaleHumanModel("models/alpha1/group01/male_22.mdl");
kuroScript.animation.AddMaleHumanModel("models/alpha1/group01/male_23.mdl");
kuroScript.animation.AddMaleHumanModel("models/alpha1/group01/male_24.mdl");
kuroScript.animation.AddMaleHumanModel("models/alpha1/group01/male_25.mdl");
kuroScript.animation.AddMaleHumanModel("models/alpha1/group01/male_26.mdl");
kuroScript.animation.AddMaleHumanModel("models/alpha1/group01/male_28.mdl");
kuroScript.animation.AddMaleHumanModel("models/alpha1/alphaHL/male_01.mdl");
kuroScript.animation.AddMaleHumanModel("models/alpha1/alphaHL/male_02.mdl");
kuroScript.animation.AddMaleHumanModel("models/alpha1/alphaHL/male_03.mdl");
kuroScript.animation.AddMaleHumanModel("models/alpha1/alphaHL/male_04.mdl");
kuroScript.animation.AddMaleHumanModel("models/alpha1/alphaHL/male_05.mdl");
kuroScript.animation.AddMaleHumanModel("models/alpha1/alphaHL/male_06.mdl");
kuroScript.animation.AddMaleHumanModel("models/alpha1/alphaHL/male_07.mdl");
kuroScript.animation.AddMaleHumanModel("models/alpha1/alphaHL/male_08.mdl");
kuroScript.animation.AddMaleHumanModel("models/alpha1/alphaHL/male_09.mdl");
kuroScript.animation.AddMaleHumanModel("models/alpha1/alphaHL/male_10.mdl");
kuroScript.animation.AddMaleHumanModel("models/alpha1/alphaHL/male_11.mdl");
kuroScript.animation.AddMaleHumanModel("models/alpha1/alphaHL/male_12.mdl");
kuroScript.animation.AddMaleHumanModel("models/alpha1/alphaHL/male_13.mdl");
kuroScript.animation.AddMaleHumanModel("models/alpha1/alphaHL/male_14.mdl");
kuroScript.animation.AddMaleHumanModel("models/alpha1/alphaHL/male_15.mdl");
kuroScript.animation.AddMaleHumanModel("models/alpha1/alphaHL/male_16.mdl");
kuroScript.animation.AddMaleHumanModel("models/alpha1/alphaHL/male_18.mdl");
kuroScript.animation.AddMaleHumanModel("models/alpha1/alphaHL/male_19.mdl");
kuroScript.animation.AddMaleHumanModel("models/alpha1/alphaHL/male_20.mdl");
kuroScript.animation.AddMaleHumanModel("models/alpha1/alphaHL/male_21.mdl");
kuroScript.animation.AddMaleHumanModel("models/alpha1/alphaHL/male_22.mdl");
kuroScript.animation.AddMaleHumanModel("models/alpha1/alphaHL/male_23.mdl");
kuroScript.animation.AddMaleHumanModel("models/alpha1/alphaHL/male_24.mdl");
kuroScript.animation.AddMaleHumanModel("models/alpha1/alphaHL/male_25.mdl");
kuroScript.animation.AddMaleHumanModel("models/alpha1/alphaHL/male_26.mdl");
kuroScript.animation.AddMaleHumanModel("models/alpha1/alphaHL/male_28.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/airex/airex_male.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/airex/male_04.mdl");
