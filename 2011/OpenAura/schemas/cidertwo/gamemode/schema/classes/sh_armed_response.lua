--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local CLASS = {};

CLASS.wages = 25;
CLASS.ammo = {pistol = 64, smg1 = 128};
CLASS.color = Color(150, 125, 100, 255);
CLASS.model = "models/pmc/pmc_4/pmc__07.mdl";
CLASS.weapons = {"weapon_glock", "weapon_mp5"};
CLASS.factions = {FACTION_POLICE};
CLASS.description = "An armed response unit responsible for carrying out raids.\nThey earn more than a civilian\nwith full contraband, without the risk\nof having it destroyed.";
CLASS.headsetGroup = 1;
CLASS.defaultPhysDesc = "Wearing a nice, clean armed response uniform";

CLASS_RESPONSE = openAura.class:Register(CLASS, "Armed Response");