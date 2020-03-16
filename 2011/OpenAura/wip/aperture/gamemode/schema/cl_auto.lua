--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

openAura.schema.lastHeartbeatAmount = 0;
openAura.schema.nextHeartbeatCheck = 0;
openAura.schema.heartbeatGradient = Material("gui/gradient_down");
openAura.schema.heartbeatOverlay = Material("effects/combine_binocoverlay");
openAura.schema.heatwaveMaterial = Material("sprites/heatwave");
openAura.schema.heatwaveMaterial:SetMaterialFloat("$refractamount", 0);
openAura.schema.heartbeatPoints = {};
openAura.schema.nextGetSnipers = 0;
openAura.schema.fishEyeTexture = Material("models/props_c17/fisheyelens");
openAura.schema.heartbeatPoint = Material("sprites/glow04_noz");
openAura.schema.shinyMaterial = Material("models/shiny");
openAura.schema.targetOutlines = {};
openAura.schema.damageNotify = {};
openAura.schema.laserSprite = Material("sprites/glow04_noz");
openAura.schema.hotkeyItems = openAura:RestoreSchemaData("hotkeys");
openAura.schema.stunEffects = {};

openAura:IncludePrefixed("sh_auto.lua");

openAura.config:AddModerator("intro_text_small", "The small text displayed for the introduction.");
openAura.config:AddModerator("intro_text_big", "The big text displayed for the introduction.");
openAura.config:AddModerator("guild_cost", "The amount of cash it costs to create an guild.", 0, 10000);

usermessage.Hook("aura_Frequency", function(msg)
	Derma_StringRequest("Frequency", "What would you like to set the frequency to?", msg:ReadString(), function(text)
		openAura:RunCommand("SetFreq", text);
	end);
end);

openAura:HookDataStream("Notepad", function(data)
	if ( openAura.schema.notepadPanel and openAura.schema.notepadPanel:IsValid() ) then
		openAura.schema.notepadPanel:Close();
		openAura.schema.notepadPanel:Remove();
	end;
	
	openAura.schema.notepadPanel = vgui.Create("aura_Notepad");
	openAura.schema.notepadPanel:Populate(data or "");
	openAura.schema.notepadPanel:MakePopup();
	
	gui.EnableScreenClicker(true);
end);

usermessage.Hook("aura_HotkeyMenu", function(msg)
	local hotkeyItems = {};
	
	for k, v in pairs(openAura.schema.hotkeyItems) do
		local itemTable = openAura.item:Get(v);
		
		if (itemTable and itemTable.OnUse) then
			hotkeyItems[#hotkeyItems + 1] = itemTable;
		end;
	end;
	
	if (hotkeyItems) then
		local options = {};
		
		for k, v in ipairs(hotkeyItems) do
			options[k..". "..v.name] = function()
				if (v.OnHandleUse) then
					v:OnHandleUse(function()
						openAura:RunCommand("InvAction", v.uniqueID, "use");
					end);
				else
					openAura:RunCommand("InvAction", v.uniqueID, "use");
				end;
			end;
		end;
		
		openAura.schema.hotkeyMenu = openAura:AddMenuFromData(nil, options);
		
		if ( IsValid(openAura.schema.hotkeyMenu) ) then
			openAura.schema.hotkeyMenu:SetPos(
				(ScrW() / 2) - (openAura.schema.hotkeyMenu:GetWide() / 2),
				(ScrH() / 2) - (openAura.schema.hotkeyMenu:GetTall() / 2)
			);
		end;
	end;
end);

usermessage.Hook("aura_TargetOutline", function(msg)
	local curTime = CurTime();
	local player = msg:ReadEntity();
	
	openAura.schema.targetOutlines[player] = curTime + 60;
end);

usermessage.Hook("aura_DealDmg", function(msg)
	local duration = 2;
	local curTime = UnPredictedCurTime();
	local entity = msg:ReadEntity();
	local amount = msg:ReadShort();
	
	if ( IsValid(entity) and entity:IsPlayer() ) then
		openAura.schema.damageNotify[#openAura.schema.damageNotify + 1] = {
			position = entity:GetShootPos() + ( Vector() * math.random(-5, 5) ),
			duration = duration,
			endTime = curTime + duration,
			color = Color(179, 46, 49, 255),
			text = amount.."dmg"
		};
	end;
end);

usermessage.Hook("aura_TakeDmg", function(msg)
	local duration = 2;
	local curTime = UnPredictedCurTime();
	local entity = msg:ReadEntity();
	local amount = msg:ReadShort();
	
	if ( IsValid(entity) and entity:IsPlayer() ) then
		openAura.schema.damageNotify[#openAura.schema.damageNotify + 1] = {
			position = entity:GetShootPos() + ( Vector() * math.random(-5, 5) ),
			duration = duration,
			endTime = curTime + duration,
			color = Color(139, 174, 179, 255),
			text = amount.."dmg"
		};
	end;
end);

usermessage.Hook("aura_Disguise", function(msg)
	Derma_StringRequest("Disguise", "Enter part of the character's name that you'd like to disguise as.", "", function(text)
		openAura:RunCommand("DisguiseSet", text);
	end);
end);

openAura:HookDataStream("InviteGuild", function(data)
	Derma_Query("Do you want to join the '"..data.."' guild?", "Join Guild", "Yes", function()
		openAura:StartDataStream("JoinGuild", data);
		
		gui.EnableScreenClicker(false);
	end, "No", function()
		gui.EnableScreenClicker(false);
	end);
	
	gui.EnableScreenClicker(true);
end);

openAura:HookDataStream("GuildKick", function(data)
	data:SetSharedVar("guild", "");
	data:SetSharedVar("rank", RANK_RCT);
	
	if ( IsValid(openAura.schema.guildPanel) ) then
		openAura.schema.guildPanel:Rebuild();
	end;
end);

openAura:HookDataStream("GuildSetRank", function(data)
	data[1]:SetSharedVar( "rank", data[2] );
	
	if ( IsValid(openAura.schema.guildPanel) ) then
		openAura.schema.guildPanel:Rebuild();
	end;
end);

usermessage.Hook("aura_CreateGuild", function(msg)
	Derma_StringRequest("Guild", "What is the name of the guild?", nil, function(text)
		openAura:StartDataStream("CreateGuild", text);
	end);
end);

usermessage.Hook("aura_Death", function(msg)
	local weapon = msg:ReadEntity();
	
	if ( !IsValid(weapon) ) then
		openAura.schema.deathType = "UNKNOWN CAUSES";
	else
		local itemTable = openAura.item:GetWeapon(weapon);
		local class = weapon:GetClass();
		
		if (itemTable) then
			openAura.schema.deathType = "A "..string.upper(itemTable.name);
		elseif (class == "aura_hands") then
			openAura.schema.deathType = "BEING PUNCHED TO DEATH";
		else
			openAura.schema.deathType = "UNKNOWN CAUSES";
		end;
	end;
end);

usermessage.Hook("aura_ShotEffect", function(msg)
	local duration = msg:ReadFloat();
	local curTime = CurTime();
	
	if (!duration or duration == 0) then
		duration = 0.5;
	end;
	
	openAura.schema.shotEffect = {curTime + duration, duration};
end);

usermessage.Hook("aura_TearGassed", function(msg)
	openAura.schema.tearGassed = CurTime() + 20;
end);

usermessage.Hook("aura_Flashed", function(msg)
	local curTime = CurTime();
	
	openAura.schema.stunEffects[#openAura.schema.stunEffects + 1] = {curTime + 10, 10};
	openAura.schema.flashEffect = {curTime + 20, 20};
	
	surface.PlaySound("hl1/fvox/flatline.wav");
end);

usermessage.Hook("aura_ClearEffects", function(msg)
	openAura.schema.stunEffects = {};
	openAura.schema.flashEffect = nil;
	openAura.schema.tearGassed = nil;
	openAura.schema.shotEffect = nil;
end);

openAura.chatBox:RegisterClass("radio", "ic", function(info)
	openAura.chatBox:Add(info.filtered, nil, Color(75, 150, 50, 255), info.name.." radios in \""..info.text.."\"");
end);

openAura.chatBox:RegisterClass("trophy", "ooc", function(info)
	openAura.chatBox:Add(info.filtered, "gui/silkicons/star", info.speaker, " has achieved the ", Color(139, 174, 179, 255), info.text, " trophy!");
end);

openAura.chatBox:RegisterClass("bounty", "ooc", function(info)
	openAura.chatBox:Add(info.filtered, nil, info.speaker, " has been given a new bounty. Their total bounty is ", Color(139, 174, 179, 255), tostring( FORMAT_CASH(tonumber(info.text), nil, true) ), "!");
end);

openAura.chatBox:RegisterClass("killed", "ooc", function(info)
	local victim = info.data.victim;
	
	if ( IsValid(victim) ) then
		openAura.chatBox:Add(info.filtered, nil, victim, " has been killed by ", info.speaker, " (investigate the death).");
	end;
end);

local playerMeta = FindMetaTable("Player");

-- A function to get whether a player is good.
function playerMeta:IsGood()
	return self:GetSharedVar("karma") >= 50;
end;

-- A function to get whether a player is bad.
function playerMeta:IsBad()
	return self:GetSharedVar("karma") < 50;
end;

-- A function to get a player's bounty.
function playerMeta:GetBounty()
	return self:GetSharedVar("bounty");
end;

-- A function to get whether a player is wanted.
function playerMeta:IsWanted()
	return self:GetSharedVar("bounty") > 0;
end;

-- A function to get whether a player is a leader.
function playerMeta:IsLeader()
	return self:GetSharedVar("rank") == RANK_MAJ;
end;

-- A function to get a player's rank.
function playerMeta:GetRank(bString)
	local rank = self:GetSharedVar("rank");
	
	if (bString) then
		if (rank == RANK_PVT) then
			return "Pvt";
		elseif (rank == RANK_SGT) then
			return "Sgt";
		elseif (rank == RANK_LT) then
			return "Lt";
		elseif (rank == RANK_CPT) then
			return "Cpt";
		elseif (rank == RANK_MAJ) then
			return "Maj";
		else
			return "Rct";
		end;
	else
		return rank;
	end;
end;

-- A function to get a player's guild.
function playerMeta:GetGuild()
	local guild = self:GetSharedVar("guild");
	
	if (guild != "") then
		return guild;
	end;
end;

-- A function to get whether a text entry is being used.
function openAura.schema:IsTextEntryBeingUsed()
	if (self.textEntryFocused) then
		if ( self.textEntryFocused:IsValid() and self.textEntryFocused:IsVisible() ) then
			return true;
		end;
	end;
end;

local OUTLINE_MATERIAL = Material("white_outline");

-- A function to draw a basic outline.
function openAura.schema:DrawBasicOutline(entity, forceColor, throughWalls)
	local r, g, b, a = entity:GetColor();
	local outlineColor = forceColor or Color(255, 0, 255, 255);
	
	if (throughWalls) then
		cam.IgnoreZ(true);
	end;
	
	render.SuppressEngineLighting(true);
	render.SetColorModulation(outlineColor.r / 255, outlineColor.g / 255, outlineColor.b / 255);
	render.SetAmbientLight(1, 1, 1);
	render.SetBlend(outlineColor.a / 255);
	entity:SetModelScale(Vector() * 1.025);
	
	SetMaterialOverride(OUTLINE_MATERIAL);
		entity:DrawModel();
	SetMaterialOverride(nil);
	
	entity:SetModelScale( Vector() );
	render.SetBlend(1);
	render.SetColorModulation(r / 255, g / 255, b / 255);
	render.SuppressEngineLighting(false);
	
	if (!throughWalls) then
		entity:DrawModel();
	else
		cam.IgnoreZ(false);
	end;
end;