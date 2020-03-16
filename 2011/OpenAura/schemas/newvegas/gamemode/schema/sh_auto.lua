--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

for k, v in pairs( {34, 37, 38, 40, 41, 42, 43, 51} ) do
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

openAura.animation:AddMaleHumanModel("models/ghoul/slow.mdl");
openAura.animation:AddMaleHumanModel("models/tactical_rebel.mdl");
openAura.animation:AddMaleHumanModel("models/power_armor/slow.mdl");
openAura.animation:AddMaleHumanModel("models/quake4pm/quakencr.mdl");

openAura.option:SetKey( "default_date", {month = 8, year = 2280, day = 22} );
openAura.option:SetKey( "default_time", {minute = 0, hour = 12, day = 1} );
openAura.option:SetKey("description_business", "Buy and sell caps for other equipment.");
openAura.option:SetKey("format_singular_cash", "%a");
openAura.option:SetKey("model_shipment", "models/props_junk/cardboard_box003b.mdl");
openAura.option:SetKey("name_business", "Trading");
openAura.option:SetKey("intro_image", "newvegas/newvegas");
openAura.option:SetKey("model_cash", "models/props_lab/box01a.mdl");
openAura.option:SetKey("menu_music", "sound/way_back_home.mp3");
openAura.option:SetKey("format_cash", "%a %n");
openAura.option:SetKey("name_cash", "Caps");
openAura.option:SetKey("gradient", "newvegas/bg_gradient");

openAura.config:ShareKey("intro_text_small");
openAura.config:ShareKey("intro_text_big");

openAura.player:RegisterSharedVar("customClass", NWTYPE_STRING);
openAura.player:RegisterSharedVar("clothes", NWTYPE_NUMBER, true);

openAura:IncludePrefixed("sh_coms.lua");
openAura:IncludePrefixed("sv_hooks.lua");
openAura:IncludePrefixed("cl_hooks.lua");
openAura:IncludePrefixed("cl_theme.lua");

openAura.config:ShareKey("intro_text_small");
openAura.config:ShareKey("intro_text_big");

openAura.flag:Add("T", "Trader", "Access to trade equipment for caps.");

-- A function to modify a physical description.
function openAura:ModifyPhysDesc(description)
	if ( string.find(description, "|") ) then
		description = string.gsub(description, "|", "/");
	end;
	
	if (string.len(description) <= 128) then
		if ( !string.find(string.sub(description, -2), "%p") ) then
			return description..".";
		else
			return description;
		end;
	else
		return string.sub(description, 1, 125).."...";
	end;
end;