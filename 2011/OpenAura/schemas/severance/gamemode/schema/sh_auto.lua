--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

for k, v in pairs( _file.Find("../models/pmc/pmc_4/*.mdl") ) do
	openAura.animation:AddMaleHumanModel("models/pmc/pmc_4/"..v);
end;

local groups = {34, 35, 36, 37, 38, 39, 40, 41};

for k, v in pairs(groups) do
	local groupName = "group"..v;
	
	for k2, v2 in pairs( _file.Find("../models/humans/"..groupName.."/*.*") ) do
		local fileName = string.lower(v2);
		
		if ( string.find(fileName, "female") ) then
			openAura.animation:AddFemaleHumanModel("models/humans/"..groupName.."/"..fileName);
		else
			openAura.animation:AddMaleHumanModel("models/humans/"..groupName.."/"..fileName);
		end;
	end;
end;

openAura.option:SetKey( "default_date", {month = 1, year = 2013, day = 1} );
openAura.option:SetKey( "default_time", {minute = 0, hour = 0, day = 1} );
openAura.option:SetKey("description_attributes", "Check on your character's stats.");
openAura.option:SetKey("description_inventory", "Manage the items in your satchel.");
openAura.option:SetKey("description_business", "Distribute a variety of items.");
openAura.option:SetKey("model_shipment", "models/props_junk/cardboard_box003b.mdl");
openAura.option:SetKey("intro_image", "severance/severance");
openAura.option:SetKey("name_attributes", "Stats");
openAura.option:SetKey("name_attribute", "Stat");
openAura.option:SetKey("name_inventory", "Satchel");
openAura.option:SetKey("menu_music", "music/hl1_song21.mp3");
openAura.option:SetKey("name_business", "Distribution");
openAura.option:SetKey("gradient", "severance/bg_gradient");

openAura.config:ShareKey("intro_text_small");
openAura.config:ShareKey("intro_text_big");

openAura.player:RegisterSharedVar("permaKilled", NWTYPE_BOOL, true);
openAura.player:RegisterSharedVar("clothes", NWTYPE_NUMBER, true);
openAura.player:RegisterSharedVar("tied", NWTYPE_NUMBER);

openAura:IncludePrefixed("sh_coms.lua");
openAura:IncludePrefixed("sv_hooks.lua");
openAura:IncludePrefixed("cl_hooks.lua");
openAura:IncludePrefixed("cl_theme.lua");

openAura.config:ShareKey("intro_text_small");
openAura.config:ShareKey("intro_text_big");

openAura.quiz:SetEnabled(true);
openAura.quiz:AddQuestion("Do you understand that roleplaying is slow paced and relaxed?", 1, "Yes.", "No.");
openAura.quiz:AddQuestion("Can you type properly, using capital letters and full-stops?", 2, "yes i can", "Yes, I can.");
openAura.quiz:AddQuestion("You do not need weapons to roleplay, do you understand?", 1, "Yes.", "No.");
openAura.quiz:AddQuestion("You do not need items to roleplay, do you understand?", 1, "Yes.", "No.");
openAura.quiz:AddQuestion("What do you think serious roleplaying is about?", 2, "Collecting items and upgrades.", "Developing your character.");
openAura.quiz:AddQuestion("What universe is this roleplaying game set in?", 2, "Real Life.", "Apocalypse.");

openAura.flag:Add("y", "Distribution", "Access to distribute items around the map.");