--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

openAura.schema.lastHeartbeatAmount = 0;
openAura.schema.nextHeartbeatCheck = 0;
openAura.schema.heartbeatGradient = Material("gui/gradient_down");
openAura.schema.heartbeatOverlay = Material("effects/combine_binocoverlay");
openAura.schema.heartbeatPoints = {};
openAura.schema.nextGetSnipers = 0;
openAura.schema.heartbeatPoint = Material("sprites/glow04_noz");
openAura.schema.laserSprite = Material("sprites/glow04_noz");
openAura.schema.highDistance = 0;
openAura.schema.highEffects = {};
openAura.schema.stunEffects = {};
openAura.schema.highTarget = 5;
openAura.schema.blacklist = {};

openAura:IncludePrefixed("sh_auto.lua");

openAura.config:AddModerator("using_star_system", "Whether or not the star system is being used.");
openAura.config:AddModerator("intro_text_small", "The small text displayed for the introduction.");
openAura.config:AddModerator("intro_text_big", "The big text displayed for the introduction.");

usermessage.Hook("aura_Frequency", function(msg)
	Derma_StringRequest("Frequency", "What would you like to set the frequency to?", msg:ReadString(), function(text)
		openAura:RunCommand("SetFreq", text);
	end);
end);

usermessage.Hook("aura_Disguise", function(msg)
	Derma_StringRequest("Disguise", "Enter part of the character's name that you'd like to disguise as.", "", function(text)
		openAura:RunCommand("DisguiseSet", text);
	end);
end);

usermessage.Hook("aura_GiveStar", function(msg)
	openAura.schema.currentCrime = {
		crime = msg:ReadShort(),
		fadeOut = CurTime() + 6
	};
	
	surface.PlaySound("buttons/button9.wav");
end);

openAura:HookDataStream("Billboards", function(data)
	for k, v in ipairs(data) do
		local wrappedTable = {};
		local unwrapped = v.data.text;
			openAura:WrapText(unwrapped, "cid_BillboardSmall", 384, wrappedTable);
		v.data.text = wrappedTable;
		v.data.unwrapped = unwrapped;
		
		openAura.schema.billboards[v.id].data = v.data;
	end;
	
	if ( openAura.menu:GetOpen() ) then
		if (openAura.menu:GetActivePanel() == openAura.schema.billboardPanel) then
			openAura.schema.billboardPanel:Rebuild();
		end;
	end;
end);

openAura:HookDataStream("BillboardAdd", function(data)
	local wrappedTable = {};
	local unwrapped = data.data.text;
		openAura:WrapText(unwrapped, "cid_BillboardSmall", 384, wrappedTable);
	data.data.text = wrappedTable;
	data.data.unwrapped = unwrapped;
	
	openAura.schema.billboards[data.id].data = data.data;
	
	if ( openAura.menu:GetOpen() ) then
		if (openAura.menu:GetActivePanel() == openAura.schema.billboardPanel) then
			openAura.schema.billboardPanel:Rebuild();
		end;
	end;
end);

openAura:HookDataStream("BillboardRemove", function(data)
	if (type(data) == "table") then
		for k, v in ipairs(data) do
			openAura.schema.billboards[v] = nil;
		end;
	else
		openAura.schema.billboards[data] = nil;
	end;
	
	if ( openAura.menu:GetOpen() ) then
		if (openAura.menu:GetActivePanel() == openAura.schema.billboardPanel) then
			openAura.schema.billboardPanel:Rebuild();
		end;
	end;
end);

openAura:HookDataStream("GetBlacklist", function(data)
	openAura.schema.blacklist = data;
end);

openAura:HookDataStream("SetBlacklisted", function(data)
	if ( data[2] ) then
		if ( !table.HasValue( openAura.schema.blacklist, data[1] ) ) then
			table.insert( openAura.schema.blacklist, data[1] );
		end;
	else
		for k, v in ipairs(openAura.schema.blacklist) do
			if ( v == data[1] ) then
				table.remove(openAura.schema.blacklist, k);
				
				break;
			end;
		end;
	end;
end);

openAura:HookDataStream("InviteAlliance", function(data)
	Derma_Query("Do you want to join the '"..data.."' alliance?", "Join Alliance", "Yes", function()
		openAura:StartDataStream("JoinAlliance", data);
		
		gui.EnableScreenClicker(false);
	end, "No", function()
		gui.EnableScreenClicker(false);
	end);
	
	gui.EnableScreenClicker(true);
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

usermessage.Hook("aura_CreateAlliance", function(msg)
	Derma_StringRequest("Alliance", "What is the name of the alliance?", nil, function(text)
		openAura:StartDataStream("CreateAlliance", text);
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

usermessage.Hook("aura_Stunned", function(msg)
	local duration = msg:ReadFloat();
	local curTime = CurTime();
	
	if (!duration or duration == 0) then
		duration = 2;
	end;
	
	openAura.schema.stunEffects[#openAura.schema.stunEffects + 1] = {curTime + duration, duration};
	openAura.schema.flashEffect = {curTime + (duration * 2), duration * 2};
end);

usermessage.Hook("aura_Flashed", function(msg)
	local curTime = CurTime();
	
	openAura.schema.stunEffects[#openAura.schema.stunEffects + 1] = {curTime + 10, 10};
	openAura.schema.flashEffect = {curTime + 20, 20};
	
	surface.PlaySound("hl1/fvox/flatline.wav");
end);

usermessage.Hook("aura_TearGassed", function(msg)
	openAura.schema.tearGassed = CurTime() + 20;
end);

usermessage.Hook("aura_GetHigh", function(msg)
	openAura.schema.highEffects[#openAura.schema.highEffects + 1] = CurTime() + msg:ReadLong();
end);

usermessage.Hook("aura_ClearEffects", function(msg)
	openAura.schema.highEffects = {};
	openAura.schema.stunEffects = {};
	openAura.schema.flashEffect = nil;
	openAura.schema.tearGassed = nil;
end);

openAura.chatBox:RegisterClass("call_eavesdrop", "ic", function(info)
	if (info.shouldHear) then
		openAura.chatBox:Add(info.filtered, nil, Color(255, 255, 175, 255), info.name.." talks on their cell, \""..info.text.."\"");
	end;
end);

openAura.chatBox:RegisterClass("call", "ic", function(info)
	if (openAura.Client == info.speaker) then
		openAura.chatBox:Add(info.filtered, nil, Color(125, 255, 100, 255), info.name.." talks on their cell, \""..info.text.."\"");
	elseif (info.data.anon) then
		openAura.chatBox:Add(info.filtered, nil, Color(125, 255, 100, 255), "You are called by somebody, \""..info.text.."\"");
	else
		openAura.chatBox:Add(info.filtered, nil, Color(125, 255, 100, 255), "You are called by "..info.data.id..", \""..info.text.."\"");
	end;
end);

openAura.chatBox:RegisterClass("912_eavesdrop", "ic", function(info)
	if (info.shouldHear) then
		openAura.chatBox:Add(info.filtered, nil, Color(255, 255, 175, 255), info.name.." calls the secretaries, \""..info.text.."\"");
	end;
end);

openAura.chatBox:RegisterClass("912", "ic", function(info)
	if (info.data.anon) then
		openAura.chatBox:Add(info.filtered, nil, Color(125, 175, 50, 255), "Somebody calls the secretaries, \""..info.text.."\"");
	else
		openAura.chatBox:Add(info.filtered, nil, Color(125, 175, 50, 255), info.data.id.." calls the secretaries, \""..info.text.."\"");
	end;
end);

openAura.chatBox:RegisterClass("911_eavesdrop", "ic", function(info)
	if (info.shouldHear) then
		openAura.chatBox:Add(info.filtered, nil, Color(255, 255, 175, 255), info.name.." calls the police, \""..info.text.."\"");
	end;
end);

openAura.chatBox:RegisterClass("911", "ic", function(info)
	if (info.data.anon) then
		openAura.chatBox:Add(info.filtered, nil, Color(125, 175, 50, 255), "Somebody calls the police, \""..info.text.."\"");
	else
		openAura.chatBox:Add(info.filtered, nil, Color(125, 175, 50, 255), info.data.id.." calls the police, \""..info.text.."\"");
	end;
end);

openAura.chatBox:RegisterClass("headset_eavesdrop", "ic", function(info)
	if (info.shouldHear) then
		openAura.chatBox:Add(info.filtered, nil, Color(255, 255, 175, 255), info.name.." talks into their headset, \""..info.text.."\"");
	end;
end);

openAura.chatBox:RegisterClass("headset", "ic", function(info)
	openAura.chatBox:Add(info.filtered, nil, Color(125, 175, 50, 255), info.name.." talks into their headset, \""..info.text.."\"");
end);

openAura.chatBox:RegisterClass("lottery", "ooc", function(info)
	openAura.chatBox:Add(info.filtered, nil, Color(150, 100, 255, 255), info.text);
end);

openAura.chatBox:RegisterClass("advert", "ic", function(info)
	openAura.chatBox:Add(info.filtered, nil, Color(175, 150, 200, 255), "You notice an advert, it says \""..info.text.."\"");
end);

openAura.chatBox:RegisterClass("radio", "ic", function(info)
	openAura.chatBox:Add(info.filtered, nil, Color(75, 150, 50, 255), info.name.." radios in \""..info.text.."\"");
end);

openAura.chatBox:RegisterClass("president", "ic", function(info)
	openAura.chatBox:Add(info.filtered, nil, Color(200, 75, 125, 255), info.name.." broadcasts \""..info.text.."\"");
end);

openAura.chatBox:RegisterClass("killed", "ooc", function(info)
	local victim = info.data.victim;
	
	if ( IsValid(victim) ) then
		openAura.chatBox:Add(info.filtered, nil, victim, " has been killed by ", info.speaker, " (investigate the death).");
	end;
end);

openAura.chatBox:RegisterClass("broadcast", "ic", function(info)
	if ( IsValid(info.data.entity) ) then
		local name = info.data.entity:GetNetworkedString("name");
		
		if (name != "") then
			info.name = name;
		end;
	end;
	
	openAura.chatBox:Add(info.filtered, nil, Color(150, 125, 175, 255), info.name.." broadcasts \""..info.text.."\"");
end);

-- A function to get whether a text entry is being used.
function openAura.schema:IsTextEntryBeingUsed()
	if (self.textEntryFocused) then
		if ( self.textEntryFocused:IsValid() and self.textEntryFocused:IsVisible() ) then
			return true;
		end;
	end;
end;