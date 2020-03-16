--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

for k, v in pairs( _file.Find("../models/napalm_atc/*.mdl") ) do
	openAura.animation:AddMaleHumanModel("models/napalm_atc/"..v);
end;

openAura.option:SetKey("intro_image", "gangwars2/gangwars2");
openAura.option:SetKey("schema_logo", "gangwars2/logo");
openAura.option:SetKey("menu_music", "music/hl1_song25_remix3.mp3");
openAura.option:SetKey("name_cash", "Drugs");
openAura.option:SetKey("gradient", "gangwars2/bg_gradient");

openAura.config:ShareKey("intro_text_small");
openAura.config:ShareKey("intro_text_big");

openAura.option:SetSound("click_release", "npc/combine_soldier/gear1.wav");
openAura.option:SetSound("rollover", "npc/combine_soldier/gear5.wav");
openAura.option:SetSound("click", "npc/combine_soldier/gear6.wav");

openAura.player:RegisterSharedVar("jetpack", NWTYPE_ENTITY);
openAura.player:RegisterSharedVar("thermal", NWTYPE_BOOL, true);
openAura.player:RegisterSharedVar("stamina", NWTYPE_NUMBER, true);
openAura.player:RegisterSharedVar("reqEXP", NWTYPE_NUMBER, true);
openAura.player:RegisterSharedVar("curEXP", NWTYPE_NUMBER, true);
openAura.player:RegisterSharedVar("level", NWTYPE_NUMBER);
openAura.player:RegisterSharedVar("title", NWTYPE_STRING);

openAura:RegisterGlobalSharedVar("resY", NWTYPE_NUMBER);
openAura:RegisterGlobalSharedVar("resK", NWTYPE_NUMBER);
openAura:RegisterGlobalSharedVar("resM", NWTYPE_NUMBER);
openAura:RegisterGlobalSharedVar("resQ", NWTYPE_NUMBER);

openAura:IncludePrefixed("sh_coms.lua");
openAura:IncludePrefixed("sv_hooks.lua");
openAura:IncludePrefixed("cl_hooks.lua");
openAura:IncludePrefixed("cl_theme.lua");

openAura:IncludeDirectory(openAura:GetSchemaFolder().."/gamemode/schema/achievements/");
openAura:IncludeDirectory(openAura:GetSchemaFolder().."/gamemode/schema/upgrades/");

if (SERVER) then
	function openAura.schema:GetResources(faction)
		return self.gangResources[faction] or 0;
	end;
	
	-- A function to give resources to a faction.
	function openAura.schema:GiveResources(faction, resources)
		self.gangResources[faction] = math.max( (self.gangResources[faction] or 0) + resources, 0 );
		
		if (faction == FACTION_MAFIA) then
			openAura:SetSharedVar( "resM", self.gangResources[faction] );
		elseif (faction == FACTION_YAKUZA) then
			openAura:SetSharedVar( "resY", self.gangResources[faction] );
		elseif (faction == FACTION_QAEDA) then
			openAura:SetSharedVar( "resQ", self.gangResources[faction] );
		elseif (faction == FACTION_KINGS) then
			openAura:SetSharedVar( "resK", self.gangResources[faction] );
		end;
	end;
	
	-- A function to get a player's level.
	function openAura.schema:GetLevel(player)
		return player:GetCharacterData("level");
	end;
	
	-- A function to give a player exp.
	function openAura.schema:GiveEXP(player, amount)
		player:SetCharacterData( "curexp", math.Clamp( player:GetCharacterData("curexp") + amount, 0, player:GetCharacterData("reqexp") ) );
		
		if ( player:GetCharacterData("curexp") == player:GetCharacterData("reqexp") ) then
			player:SetCharacterData( "level", math.Clamp(player:GetCharacterData("level") + 1, 0, 40) );
			
			if (player:GetCharacterData("level") == 40) then
				player:SetCharacterData("reqexp", 0);
				player:SetCharacterData("curexp", 0);
			else
				local level = player:GetCharacterData("level");
				local multi = 45 + (5 * level);
				
				player:SetCharacterData("reqexp", (level * 5) * multi);
				player:SetCharacterData("curexp", 0);
				
				umsg.Start("aura_LevelUp");
					umsg.Entity(player);
				umsg.End();
			end;
		end;
	end;
	
	-- A function to get a player's exp.
	function openAura.schema:GetEXP(player)
		return player:GetCharacterData("curexp"), player:GetCharacterData("reqexp");
	end;
else
	function openAura.schema:GetResources(faction)
		if (faction == FACTION_MAFIA) then
			return openAura:GetSharedVar("resM");
		elseif (faction == FACTION_YAKUZA) then
			return openAura:GetSharedVar("resY");
		elseif (faction == FACTION_QAEDA) then
			return openAura:GetSharedVar("resQ");
		elseif (faction == FACTION_KINGS) then
			return openAura:GetSharedVar("resK");
		else
			return 0;
		end;
	end;
	
	-- A function to get a player's level.
	function openAura.schema:GetLevel(player)
		return openAura.Client:GetSharedVar("level");
	end;
	
	-- A function to get the local player's exp.
	function openAura.schema:GetEXP()
		return openAura.Client:GetSharedVar("curEXP"), openAura.Client:GetSharedVar("reqEXP");
	end;
end;

timer.Simple(2, function()
	local weaponList = weapons.GetList();
	
	for k, v in pairs(weaponList) do
		local weaponTable = weapons.GetStored(k);
		
		if (weaponTable) then
			weaponTable.Tracer = 1;
			weaponTable.TracerName = "aura_LaserTracer";
			weaponTable.Primary.Sound = "weapons/fx/nearmiss/bulletltor04.wav";
		end;
	end;
end);