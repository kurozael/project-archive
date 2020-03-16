--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

-- A function to modify a physical description.
function Clockwork:ModifyPhysDesc(description)
	if (string.find(description, "|")) then
		description = string.gsub(description, "|", "/");
	end;
	
	if (string.len(description) <= 128) then
		if (!string.find(string.sub(description, -2), "%p")) then
			return description..".";
		else
			return description;
		end;
	else
		return string.sub(description, 1, 125).."...";
	end;
end;

for k, v in pairs({34, 37, 38, 40, 41, 42, 43, 51}) do
	local groupName = "group"..v;
	
	for k2, v2 in pairs(_file.Find("../models/humans/"..groupName.."/*.*")) do
		local fileName = string.lower(v2);
		
		if (string.find(fileName, "female")) then
			Clockwork.animation:AddFemaleHumanModel("models/humans/"..groupName.."/"..fileName);
		else
			Clockwork.animation:AddMaleHumanModel("models/humans/"..groupName.."/"..fileName);
		end;
	end;
end;

Clockwork.animation:AddMaleHumanModel("models/ghoul/slow.mdl");
Clockwork.animation:AddMaleHumanModel("models/tactical_rebel.mdl");
Clockwork.animation:AddMaleHumanModel("models/power_armor/slow.mdl");
Clockwork.animation:AddMaleHumanModel("models/quake4pm/quakencr.mdl");

Clockwork.option:SetKey("default_date", {month = 8, year = 2280, day = 22});
Clockwork.option:SetKey("default_time", {minute = 0, hour = 12, day = 1});
Clockwork.option:SetKey("description_business", "Buy and sell caps for other equipment.");
Clockwork.option:SetKey("format_singular_cash", "%a");
Clockwork.option:SetKey("model_shipment", "models/props_junk/cardboard_box003b.mdl");
Clockwork.option:SetKey("name_business", "Trading");
Clockwork.option:SetKey("intro_image", "cwNewVegas/newvegas");
Clockwork.option:SetKey("model_cash", "models/props_lab/box01a.mdl");
Clockwork.option:SetKey("menu_music", "sound/way_back_home.mp3");
Clockwork.option:SetKey("format_cash", "%a %n");
Clockwork.option:SetKey("name_cash", "Caps");
Clockwork.option:SetKey("gradient", "cwNewVegas/bg_gradient");

Clockwork.config:ShareKey("intro_text_small");
Clockwork.config:ShareKey("intro_text_big");

Clockwork:IncludePrefixed("sh_hooks.lua");
Clockwork:IncludePrefixed("sv_hooks.lua");
Clockwork:IncludePrefixed("cl_hooks.lua");
Clockwork:IncludePrefixed("cl_theme.lua");
Clockwork:IncludePrefixed("sh_coms.lua");

Clockwork.config:ShareKey("intro_text_small");
Clockwork.config:ShareKey("intro_text_big");

Clockwork.flag:Add("T", "Trader", "Access to trade equipment for caps.");