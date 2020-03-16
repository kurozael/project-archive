--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

openAura.schema.lastHeartbeatAmount = 0;
openAura.schema.nextHeartbeatCheck = 0;
openAura.schema.thirdPersonAmount = 0;
openAura.schema.heartbeatGradient = Material("gui/gradient_down");
openAura.schema.heartbeatOverlay = Material("effects/combine_binocoverlay");
openAura.schema.heartbeatPoints = {};
openAura.schema.fishEyeTexture = Material("models/props_c17/fisheyelens");
openAura.schema.heartbeatPoint = Material("sprites/glow04_noz");
openAura.schema.targetOutlines = {};
openAura.schema.crackTexture = surface.GetTextureID("gangwars2/crack");
openAura.schema.visorTexture = Material("gangwars2/visor");
openAura.schema.damageCracks = {};
openAura.schema.damageNotify = {};
openAura.schema.killNotices = {};
openAura.schema.stunEffects = {};
openAura.schema.killPhrases = {
	"you have violenty taken care of %n",
	"you have annihilated %n",
	"you made %n in to mince meat",
	"you supressed %n's puny life",
	"you have terminated %n",
	"%n was destroyed by your hands",
	"you took %n to school",
	"%n's existence was halted by you"
};

openAura:IncludePrefixed("sh_auto.lua");

openAura.config:AddAuraWatch("intro_text_small", "The small text displayed for the introduction.");
openAura.config:AddAuraWatch("intro_text_big", "The big text displayed for the introduction.");

openAura.setting:RemoveByConVar("aura_topbars");

usermessage.Hook("aura_TargetOutline", function(msg)
	local curTime = CurTime();
	local player = msg:ReadEntity();
	
	openAura.schema.targetOutlines[player] = curTime + 60;
end);

usermessage.Hook("aura_OverrideThirdPerson", function(msg)
	openAura.schema.overrideThirdPerson = UnPredictedCurTime() + msg:ReadShort();
end);

usermessage.Hook("aura_Killed", function(msg)
	local player = msg:ReadEntity();
	local curTime = UnPredictedCurTime();
	
	if ( IsValid(player) ) then
		if (#openAura.schema.killNotices > 8) then
			table.remove(openAura.schema.killNotices, 1);
		end;
		
		local phrase = openAura.schema.killPhrases[ math.random(1, #openAura.schema.killPhrases) ];
		local text = string.Replace( phrase, "%n", player:Name() );
		
		table.insert( openAura.schema.killNotices, {
			fadeUp = curTime + 4,
			fadeIn = curTime + 1,
			text = player:Name(),
		} );
	end;
end);

usermessage.Hook("aura_LevelUp", function(msg)
	local duration = 2;
	local curTime = UnPredictedCurTime();
	local entity = msg:ReadEntity();
	
	if ( IsValid(entity) and entity:IsPlayer() ) then
		openAura.schema.damageNotify[#openAura.schema.damageNotify + 1] = {
			position = entity:GetShootPos() + ( Vector() * math.random(-5, 5) ),
			duration = duration,
			endTime = curTime + duration,
			color = Color(255, 50, 50, 255),
			text = "level up"
		};
	end;
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
	
	local x = math.random(0, ScrW() - 256);
	local y = math.random(0, ScrH() - 256);
	
	openAura.schema.damageCracks[#openAura.schema.damageCracks + 1] = {
		health = math.max(openAura.Client:Health(), 0),
		x = x,
		y = y
	};
	
	surface.PlaySound("physics/glass/glass_impact_bullet"..math.random(1, 4)..".wav");
end);

usermessage.Hook("aura_Death", function(msg)
	local weapon = msg:ReadEntity();
	local attacker = msg:ReadEntity();
	
	if ( IsValid(attacker) ) then
		openAura.schema.deathName = string.upper( attacker:Name() );
	else
		openAura.schema.deathName = "THE VOID";
	end;
	
	if ( !IsValid(weapon) ) then
		openAura.schema.deathType = "unknown causes";
	else
		local itemTable = openAura.item:GetWeapon(weapon);
		local class = weapon:GetClass();
		
		if (itemTable) then
			openAura.schema.deathType = "a "..string.lower(itemTable.name);
		elseif (class == "aura_hands") then
			openAura.schema.deathType = "being beaten senseless";
		else
			openAura.schema.deathType = "unknown causes";
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

usermessage.Hook("aura_Flashed", function(msg)
	local curTime = CurTime();
	
	openAura.schema.stunEffects[#openAura.schema.stunEffects + 1] = {curTime + 10, 10};
	openAura.schema.flashEffect = {curTime + 20, 20};
	
	surface.PlaySound("hl1/fvox/flatline.wav");
end);

usermessage.Hook("aura_ClearEffects", function(msg)
	openAura.schema.damageCracks = {};
	openAura.schema.stunEffects = {};
	openAura.schema.flashEffect = nil;
	openAura.schema.shotEffect = nil;
end);

openAura.chatBox:RegisterClass("radio", "ic", function(info)
	openAura.chatBox:Add(info.filtered, nil, Color(75, 150, 50, 255), info.name.." radios in \""..info.text.."\"");
end);

openAura.chatBox:RegisterClass("achievement", "ooc", function(info)
	openAura.chatBox:Add(info.filtered, {"gui/silkicons/star", "*"}, info.speaker, " has achieved the ", Color(139, 174, 179, 255), info.text, " achievement!");
end);

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