--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local modelGroups = {60, 61, 62};

for _, group in pairs(modelGroups) do
	for k, v in pairs( _file.Find("../models/humans/group"..group.."/*.mdl") ) do
		if ( string.find(string.lower(v), "female") ) then
			openAura.animation:AddFemaleHumanModel("models/humans/group"..group.."/"..v);
		else
			openAura.animation:AddMaleHumanModel("models/humans/group"..group.."/"..v);
		end;
	end;
end;

for k, v in pairs( _file.Find("../models/napalm_atc/*.mdl") ) do
	openAura.animation:AddMaleHumanModel("models/napalm_atc/"..v);
end;

for k, v in pairs( _file.Find("../models/nailgunner/*.mdl") ) do
	openAura.animation:AddMaleHumanModel("models/nailgunner/"..v);
end;

for k, v in pairs( _file.Find("../models/salem/*.mdl") ) do
	openAura.animation:AddMaleHumanModel("models/salem/"..v);
end;

for k, v in pairs( _file.Find("../models/bio_suit/*.mdl") ) do
	openAura.animation:AddMaleHumanModel("models/bio_suit/"..v);
end;

for k, v in pairs( _file.Find("../models/srp/*.mdl") ) do
	openAura.animation:AddMaleHumanModel("models/srp/"..v);
end;

openAura.animation:AddMaleHumanModel("models/humans/group03/male_experim.mdl");
openAura.animation:AddMaleHumanModel("models/pmc/pmc_4/pmc__07.mdl");
openAura.animation:AddMaleHumanModel("models/tactical_rebel.mdl");
openAura.animation:AddMaleHumanModel("models/riot_ex2.mdl");

local MODEL_SPX7 = openAura.animation:AddMaleHumanModel("models/spx7.mdl");
local MODEL_SPX2 = openAura.animation:AddMaleHumanModel("models/spx2.mdl");
local MODEL_SPEX = openAura.animation:AddMaleHumanModel("models/spex.mdl");
local SPEX_MODELS = {MODEL_SPEX, MODEL_SPX2, MODEL_SPX7};

for k, v in ipairs(SPEX_MODELS) do
	openAura.animation:AddOverride(v, "stand_grenade_idle", "LineIdle03");
	openAura.animation:AddOverride(v, "stand_pistol_idle", "LineIdle03");
	openAura.animation:AddOverride(v, "stand_blunt_idle", "LineIdle03");
	openAura.animation:AddOverride(v, "stand_slam_idle", "LineIdle03");
	openAura.animation:AddOverride(v, "stand_fist_idle", "LineIdle03");
end;

openAura.option:SetKey("description_business", "Craft a variety of equipment with your rations.");
openAura.option:SetKey("intro_image", "phasefour/phasefour");
openAura.option:SetKey("name_business", "Crafting");
openAura.option:SetKey("menu_music", "music/hl2_song19.mp3");
openAura.option:SetKey("model_shipment", "models/items/item_item_exper.mdl");
openAura.option:SetKey("model_cash", "models/props_lab/exp01a.mdl");
openAura.option:SetKey("name_cash", "Rations");
openAura.option:SetKey("gradient", "phasefour/bg_gradient");

openAura.config:ShareKey("intro_text_small");
openAura.config:ShareKey("intro_text_big");
openAura.config:ShareKey("alliance_cost");

openAura.player:RegisterSharedVar("beingChloro", NWTYPE_BOOL, true);
openAura.player:RegisterSharedVar("beingTied", NWTYPE_BOOL, true);
openAura.player:RegisterSharedVar("clothes", NWTYPE_NUMBER, true);
openAura.player:RegisterSharedVar("implant", NWTYPE_BOOL, true);
openAura.player:RegisterSharedVar("nextDC", NWTYPE_NUMBER, true);
openAura.player:RegisterSharedVar("fuel", NWTYPE_NUMBER, true);

openAura.player:RegisterSharedVar("ghostheart", NWTYPE_BOOL);
openAura.player:RegisterSharedVar("skullMask", NWTYPE_BOOL);
openAura.player:RegisterSharedVar("alliance", NWTYPE_STRING);
openAura.player:RegisterSharedVar("disguise", NWTYPE_ENTITY);
openAura.player:RegisterSharedVar("jetpack", NWTYPE_ENTITY);
openAura.player:RegisterSharedVar("bounty", NWTYPE_NUMBER);
openAura.player:RegisterSharedVar("title", NWTYPE_STRING);
openAura.player:RegisterSharedVar("honor", NWTYPE_NUMBER);
openAura.player:RegisterSharedVar("rank", NWTYPE_NUMBER);
openAura.player:RegisterSharedVar("tied", NWTYPE_BOOL);

openAura.quiz:SetName("Agreement");
openAura.quiz:SetEnabled(true);
openAura.quiz:AddQuestion("I know that because of the logs, I will never get away with rule-breaking.", 1, "Yes.", "No.");
openAura.quiz:AddQuestion("When creating a character, I will use a full and appropriate name.", 1, "Yes.", "No.");
openAura.quiz:AddQuestion("I understand that the script has vast logs that are checked often.", 1, "Yes.", "No.");
openAura.quiz:AddQuestion("I will read the directory in the main menu for help and guides.", 1, "Yes.", "No.");

RANK_RCT = 0;
RANK_PVT = 1;
RANK_SGT = 2;
RANK_LT = 3;
RANK_CPT = 4;
RANK_MAJ = 5;

-- A function to register a leveled weapon.
function openAura.schema:RegisterLeveledWeapon(itemTable)
	openAura.item:Register(itemTable);
	
	local uniqueID = itemTable.uniqueID;
	local name = itemTable.name;
	
	itemTable.nextWeaponID = itemTable.uniqueID.."_2";
	itemTable.weaponLevel = 1;
	
	for i = 2, 10 do
		itemTable = table.Copy(itemTable);
		itemTable.name = name.." Mk. "..i;
		itemTable.plural = name.." Mk. "..i.."s";
		itemTable.business = false;
		itemTable.uniqueID = uniqueID.."_"..i;
		itemTable.weaponLevel = i;
		
		if (i != 10) then
			itemTable.nextWeaponID = uniqueID.."_"..(i + 1);
		end;
		
		openAura.item:Register(itemTable);
	end;
end;

-- A function to register some leveled armor.
function openAura.schema:RegisterLeveledArmor(itemTable)
	openAura.item:Register(itemTable);
	
	local uniqueID = itemTable.uniqueID;
	local name = itemTable.name;
	
	itemTable.nextArmorID = itemTable.uniqueID.."_2";
	itemTable.armorLevel = 1;
	itemTable.name = name.." Mk1";
	
	for i = 2, 10 do
		itemTable = table.Copy(itemTable);
		itemTable.name = name.." Mk"..i;
		itemTable.business = false;
		itemTable.uniqueID = uniqueID.."_"..i;
		itemTable.armorLevel = i;
		
		if (i != 10) then
			itemTable.nextArmorID = uniqueID.."_"..(i + 1);
		end;
		
		openAura.item:Register(itemTable);
	end;
end;

-- A function to get a player's honor text.
function openAura.schema:PlayerGetHonorText(player, honor)
	if (honor >= 90) then
		return "This character is like Jesus!";
	elseif (honor >= 80) then
		return "This character is divine."
	elseif (honor >= 70) then
		return "This character is blessed."
	elseif (honor >= 60) then
		return "This character is a nice guy.";
	elseif (honor >= 50) then
		return "This character is friendly.";
	elseif (honor >= 40) then
		return "This character is nasty.";
	elseif (honor >= 30) then
		return "This character is a bad guy.";
	elseif (honor >= 20) then
		return "This character is cursed.";
	elseif (honor >= 10) then
		return "This character is evil.";
	else
		return "This character is like Hitler!";
	end;
end;

openAura:IncludePrefixed("sh_coms.lua");
openAura:IncludePrefixed("sv_hooks.lua");
openAura:IncludePrefixed("cl_hooks.lua");
openAura:IncludePrefixed("cl_theme.lua");