--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

openAura.schema.customPermits = {};

for k, v in pairs( _file.Find("../models/humans/group17/*.mdl") ) do
	openAura.animation:AddMaleHumanModel("models/humans/group17/"..v);
end;

openAura.animation:AddCivilProtectionModel("models/eliteghostcp.mdl");
openAura.animation:AddCivilProtectionModel("models/eliteshockcp.mdl");
openAura.animation:AddCivilProtectionModel("models/leet_police2.mdl");
openAura.animation:AddCivilProtectionModel("models/sect_police2.mdl");
openAura.animation:AddCivilProtectionModel("models/policetrench.mdl");

openAura.option:SetKey( "default_date", {month = 1, year = 2016, day = 1} );
openAura.option:SetKey( "default_time", {minute = 0, hour = 0, day = 1} );
openAura.option:SetKey("format_singular_cash", "%a");
openAura.option:SetKey("model_shipment", "models/items/item_item_crate.mdl");
openAura.option:SetKey("intro_image", "halfliferp/halfliferp");
openAura.option:SetKey("schema_logo", "halfliferp/logo");
openAura.option:SetKey("format_cash", "%a %n");
openAura.option:SetKey("menu_music", "music/hl2_song19.mp3");
openAura.option:SetKey("name_cash", "Tokens");
openAura.option:SetKey("model_cash", "models/props_lab/box01a.mdl");
openAura.option:SetKey("gradient", "halfliferp/bg_gradient");

openAura.config:ShareKey("intro_text_small");
openAura.config:ShareKey("intro_text_big");
openAura.config:ShareKey("business_cost");
openAura.config:ShareKey("permits");

openAura:RegisterGlobalSharedVar("PKMode", NWTYPE_NUMBER);

openAura.player:RegisterSharedVar("antidepressants", NWTYPE_NUMBER, true);
openAura.player:RegisterSharedVar("customClass", NWTYPE_STRING);
openAura.player:RegisterSharedVar("citizenID", NWTYPE_STRING, true);
openAura.player:RegisterSharedVar("scanner", NWTYPE_ENTITY, true);
openAura.player:RegisterSharedVar("clothes", NWTYPE_NUMBER, true);
openAura.player:RegisterSharedVar("tied", NWTYPE_NUMBER);

openAura:IncludePrefixed("sh_coms.lua");
openAura:IncludePrefixed("sh_voices.lua");
openAura:IncludePrefixed("sv_hooks.lua");
openAura:IncludePrefixed("cl_hooks.lua");
openAura:IncludePrefixed("cl_theme.lua");

openAura.quiz:SetEnabled(true);
openAura.quiz:AddQuestion("Do you understand that roleplaying is slow paced and relaxed?", 1, "Yes.", "No.");
openAura.quiz:AddQuestion("Can you type properly, using capital letters and full-stops?", 2, "yes i can", "Yes, I can.");
openAura.quiz:AddQuestion("You do not need weapons to roleplay, do you understand?", 1, "Yes.", "No.");
openAura.quiz:AddQuestion("You do not need items to roleplay, do you understand?", 1, "Yes.", "No.");
openAura.quiz:AddQuestion("What do you think serious roleplaying is about?", 2, "Collecting items and upgrades.", "Developing your character.");
openAura.quiz:AddQuestion("What universe is this roleplaying game set in?", 2, "Real Life.", "Half-Life 2.");

openAura.flag:Add("v", "Light Blackmarket", "Access to light blackmarket goods.");
openAura.flag:Add("V", "Heavy Blackmarket", "Access to heavy blackmarket goods.");
openAura.flag:Add("m", "Resistance Manager", "Access to the resistance manager's goods.");

-- A function to add a custom permit.
function openAura.schema:AddCustomPermit(name, flag, model)
	local formattedName = string.gsub(name, "[%s%p]", "");
	local lowerName = string.lower(name);
	
	self.customPermits[ string.lower(formattedName) ] = {
		model = model,
		name = name,
		flag = flag,
		key = openAura:SetCamelCase(formattedName, true)
	};
end;

-- A function to check if a string is a Combine rank.
function openAura.schema:IsStringCombineRank(text, rank)
	if (type(rank) == "table") then
		for k, v in ipairs(rank) do
			if ( self:IsStringCombineRank(text, v) ) then
				return true;
			end;
		end;
	elseif (rank == "EpU") then
		if ( string.find(text, "%pSeC%p") or string.find(text, "%pDvL%p")
		or string.find(text, "%pEpU%p") ) then
			return true;
		end;
	else
		return string.find(text, "%p"..rank.."%p");
	end;
end;

-- A function to check if a player is a Combine rank.
function openAura.schema:IsPlayerCombineRank(player, rank, realRank)
	local name = player:Name();
	
	if (type(rank) == "table") then
		for k, v in ipairs(rank) do
			if ( self:IsPlayerCombineRank(player, v, realRank) ) then
				return true;
			end;
		end;
	elseif (rank == "EpU" and !realRank) then
		if ( string.find(name, "%pSeC%p") or string.find(name, "%pDvL%p")
		or string.find(name, "%pEpU%p") ) then
			return true;
		end;
	else
		return string.find(name, "%p"..rank.."%p");
	end;
end;

-- A function to get a player's Combine rank.
function openAura.schema:GetPlayerCombineRank(player)
	local faction;
	
	if (SERVER) then
		faction = player:QueryCharacter("faction");
	else
		faction = openAura.player:GetFaction(player);
	end;
	
	if (faction == FACTION_OTA) then
		if ( self:IsPlayerCombineRank(player, "OWS") ) then
			return 0;
		elseif ( self:IsPlayerCombineRank(player, "EOW") ) then
			return 1;
		else
			return 2;
		end;
	elseif ( self:IsPlayerCombineRank(player, "RCT") ) then
		return 0;
	elseif ( self:IsPlayerCombineRank(player, "04") ) then
		return 1;
	elseif ( self:IsPlayerCombineRank(player, "03") ) then
		return 2;
	elseif ( self:IsPlayerCombineRank(player, "02") ) then
		return 3;
	elseif ( self:IsPlayerCombineRank(player, "01") ) then
		return 4;
	elseif ( self:IsPlayerCombineRank(player, "OfC") ) then
		return 6;
	elseif ( self:IsPlayerCombineRank(player, "EpU", true) ) then
		return 7;
	elseif ( self:IsPlayerCombineRank(player, "DvL") ) then
		return 8;
	elseif ( self:IsPlayerCombineRank(player, "SeC") ) then
		return 9;
	elseif ( self:IsPlayerCombineRank(player, "SCN") ) then
		if ( !self:IsPlayerCombineRank(player, "SYNTH") ) then
			return 10;
		else
			return 11;
		end;
	else
		return 5;
	end;
end;

-- A function to get if a faction is Combine.
function openAura.schema:IsCombineFaction(faction)
	return (faction == FACTION_MPF or faction == FACTION_OTA);
end;