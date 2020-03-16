--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

include("sh_boot");

-- A function to get whether a text entry is being used.
function Schema:IsTextEntryBeingUsed()
	if (self.textEntryFocused) then
		if (self.textEntryFocused:IsValid() and self.textEntryFocused:IsVisible()) then
			return true;
		end;
	end;
end;

Clockwork.config:AddToSystem("using_star_system", "Whether or not the star system is being used.");
Clockwork.config:AddToSystem("intro_text_small", "The small text displayed for the introduction.");
Clockwork.config:AddToSystem("intro_text_big", "The big text displayed for the introduction.");

Clockwork.chatBox:RegisterClass("call_eavesdrop", "ic", function(info)
	if (info.shouldHear) then
		Clockwork.chatBox:Add(info.filtered, nil, Color(255, 255, 175, 255), info.name.." talks on their cell, \""..info.text.."\"");
	end;
end);

Clockwork.chatBox:RegisterClass("call", "ic", function(info)
	if (Clockwork.Client == info.speaker) then
		Clockwork.chatBox:Add(info.filtered, nil, Color(125, 255, 100, 255), info.name.." talks on their cell, \""..info.text.."\"");
	elseif (info.data.anon) then
		Clockwork.chatBox:Add(info.filtered, nil, Color(125, 255, 100, 255), "You are called by somebody, \""..info.text.."\"");
	else
		Clockwork.chatBox:Add(info.filtered, nil, Color(125, 255, 100, 255), "You are called by "..info.data.id..", \""..info.text.."\"");
	end;
end);

Clockwork.chatBox:RegisterClass("912_eavesdrop", "ic", function(info)
	if (info.shouldHear) then
		Clockwork.chatBox:Add(info.filtered, nil, Color(255, 255, 175, 255), info.name.." calls the secretaries, \""..info.text.."\"");
	end;
end);

Clockwork.chatBox:RegisterClass("912", "ic", function(info)
	if (info.data.anon) then
		Clockwork.chatBox:Add(info.filtered, nil, Color(125, 175, 50, 255), "Somebody calls the secretaries, \""..info.text.."\"");
	else
		Clockwork.chatBox:Add(info.filtered, nil, Color(125, 175, 50, 255), info.data.id.." calls the secretaries, \""..info.text.."\"");
	end;
end);

Clockwork.chatBox:RegisterClass("911_eavesdrop", "ic", function(info)
	if (info.shouldHear) then
		Clockwork.chatBox:Add(info.filtered, nil, Color(255, 255, 175, 255), info.name.." calls the police, \""..info.text.."\"");
	end;
end);

Clockwork.chatBox:RegisterClass("911", "ic", function(info)
	if (info.data.anon) then
		Clockwork.chatBox:Add(info.filtered, nil, Color(125, 175, 50, 255), "Somebody calls the police, \""..info.text.."\"");
	else
		Clockwork.chatBox:Add(info.filtered, nil, Color(125, 175, 50, 255), info.data.id.." calls the police, \""..info.text.."\"");
	end;
end);

Clockwork.chatBox:RegisterClass("headset_eavesdrop", "ic", function(info)
	if (info.shouldHear) then
		Clockwork.chatBox:Add(info.filtered, nil, Color(255, 255, 175, 255), info.name.." talks into their headset, \""..info.text.."\"");
	end;
end);

Clockwork.chatBox:RegisterClass("headset", "ic", function(info)
	Clockwork.chatBox:Add(info.filtered, nil, Color(125, 175, 50, 255), info.name.." talks into their headset, \""..info.text.."\"");
end);

Clockwork.chatBox:RegisterClass("lottery", "ooc", function(info)
	Clockwork.chatBox:Add(info.filtered, nil, Color(150, 100, 255, 255), info.text);
end);

Clockwork.chatBox:RegisterClass("advert", "ic", function(info)
	Clockwork.chatBox:Add(info.filtered, nil, Color(175, 150, 200, 255), "You notice an advert, it says \""..info.text.."\"");
end);

Clockwork.chatBox:RegisterClass("radio", "ic", function(info)
	Clockwork.chatBox:Add(info.filtered, nil, Color(75, 150, 50, 255), info.name.." radios in \""..info.text.."\"");
end);

Clockwork.chatBox:RegisterClass("president", "ic", function(info)
	Clockwork.chatBox:Add(info.filtered, nil, Color(200, 75, 125, 255), info.name.." broadcasts \""..info.text.."\"");
end);

Clockwork.chatBox:RegisterClass("killed", "ooc", function(info)
	local victim = info.data.victim;
	
	if (IsValid(victim)) then
		Clockwork.chatBox:Add(info.filtered, nil, victim, " has been killed by ", info.speaker, " (investigate the death).");
	end;
end);

Clockwork.chatBox:RegisterClass("broadcast", "ic", function(info)
	if (IsValid(info.data.entity)) then
		local name = info.data.entity:GetNetworkedString("Name");
		
		if (name != "") then
			info.name = name;
		end;
	end;
	
	Clockwork.chatBox:Add(info.filtered, nil, Color(150, 125, 175, 255), info.name.." broadcasts \""..info.text.."\"");
end);

usermessage.Hook("cwFrequency", function(msg)
	Derma_StringRequest("Frequency", "What would you like to set the frequency to?", msg:ReadString(), function(text)
		Clockwork:RunCommand("SetFreq", text);
	end);
end);

usermessage.Hook("cwDisguise", function(msg)
	Derma_StringRequest("Disguise", "Enter part of the character's name that you'd like to disguise as.", "", function(text)
		Clockwork:RunCommand("DisguiseSet", text);
	end);
end);

usermessage.Hook("cwGiveStar", function(msg)
	Schema.currentCrime = {
		crime = msg:ReadShort(),
		fadeOut = CurTime() + 6
	};
	
	surface.PlaySound("buttons/button9.wav");
end);

Clockwork:HookDataStream("Billboards", function(data)
	for k, v in ipairs(data) do
		local wrappedTable = {};
		local unwrapped = v.data.text;
			Clockwork:WrapText(unwrapped, "cid_BillboardSmall", 384, wrappedTable);
		v.data.text = wrappedTable;
		v.data.unwrapped = unwrapped;
		
		Schema.billboards[v.id].data = v.data;
	end;
	
	if (Clockwork.menu:GetOpen()) then
		if (Clockwork.menu:GetActivePanel() == Schema.billboardPanel) then
			Schema.billboardPanel:Rebuild();
		end;
	end;
end);

Clockwork:HookDataStream("BillboardAdd", function(data)
	local wrappedTable = {};
	local unwrapped = data.data.text;
		Clockwork:WrapText(unwrapped, "cid_BillboardSmall", 384, wrappedTable);
	data.data.text = wrappedTable;
	data.data.unwrapped = unwrapped;
	
	Schema.billboards[data.id].data = data.data;
	
	if (Clockwork.menu:GetOpen()) then
		if (Clockwork.menu:GetActivePanel() == Schema.billboardPanel) then
			Schema.billboardPanel:Rebuild();
		end;
	end;
end);

Clockwork:HookDataStream("BillboardRemove", function(data)
	if (type(data) == "table") then
		for k, v in ipairs(data) do
			Schema.billboards[v] = nil;
		end;
	else
		Schema.billboards[data] = nil;
	end;
	
	if (Clockwork.menu:GetOpen()) then
		if (Clockwork.menu:GetActivePanel() == Schema.billboardPanel) then
			Schema.billboardPanel:Rebuild();
		end;
	end;
end);

Clockwork:HookDataStream("GetBlacklist", function(data)
	Schema.blacklist = data;
end);

Clockwork:HookDataStream("SetBlacklisted", function(data)
	if (data[2]) then
		if (!table.HasValue(Schema.blacklist, data[1])) then
			table.insert(Schema.blacklist, data[1]);
		end;
	else
		for k, v in ipairs(Schema.blacklist) do
			if (v == data[1]) then
				table.remove(Schema.blacklist, k);
				
				break;
			end;
		end;
	end;
end);

Clockwork:HookDataStream("InviteAlliance", function(data)
	Derma_Query("Do you want to join the '"..data.."' alliance?", "Join Alliance", "Yes", function()
		Clockwork:StartDataStream("JoinAlliance", data);
		gui.EnableScreenClicker(false);
	end, "No", function()
		gui.EnableScreenClicker(false);
	end);
	
	gui.EnableScreenClicker(true);
end);

Clockwork:HookDataStream("Notepad", function(data)
	if (Schema.notepadPanel and Schema.notepadPanel:IsValid()) then
		Schema.notepadPanel:Close();
		Schema.notepadPanel:Remove();
	end;
	
	Schema.notepadPanel = vgui.Create("cwNotepad");
	Schema.notepadPanel:Populate(data or "");
	Schema.notepadPanel:MakePopup();
	
	gui.EnableScreenClicker(true);
end);

usermessage.Hook("cwCreateAlliance", function(msg)
	Derma_StringRequest("Alliance", "What is the name of the alliance?", nil, function(text)
		Clockwork:StartDataStream("CreateAlliance", text);
	end);
end);

usermessage.Hook("cwDeath", function(msg)
	local weapon = msg:ReadEntity();
	
	if (!IsValid(weapon)) then
		Schema.deathType = "UNKNOWN CAUSES";
	else
		local itemTable = Clockwork.item:GetByWeapon(weapon);
		local class = weapon:GetClass();
		
		if (itemTable) then
			Schema.deathType = "A "..string.upper(itemTable("name"));
		elseif (class == "cw_hands") then
			Schema.deathType = "BEING PUNCHED TO DEATH";
		else
			Schema.deathType = "UNKNOWN CAUSES";
		end;
	end;
end);

usermessage.Hook("cwStunned", function(msg)
	local duration = msg:ReadFloat();
	local curTime = CurTime();
	
	if (!duration or duration == 0) then
		duration = 2;
	end;
	
	Schema.stunEffects[#Schema.stunEffects + 1] = {curTime + duration, duration};
	Schema.flashEffect = {curTime + (duration * 2), duration * 2};
end);

usermessage.Hook("cwFlashed", function(msg)
	local curTime = CurTime();
	
	Schema.stunEffects[#Schema.stunEffects + 1] = {curTime + 10, 10};
	Schema.flashEffect = {curTime + 20, 20};
	
	surface.PlaySound("hl1/fvox/flatline.wav");
end);

usermessage.Hook("cwTearGassed", function(msg)
	Schema.tearGassed = CurTime() + 20;
end);

usermessage.Hook("cwGetHigh", function(msg)
	Schema.highEffects[#Schema.highEffects + 1] = CurTime() + msg:ReadLong();
end);

usermessage.Hook("cwClearEffects", function(msg)
	Schema.highEffects = {};
	Schema.stunEffects = {};
	Schema.flashEffect = nil;
	Schema.tearGassed = nil;
end);

--[[
	The schema must be registered so that the kernel information
	can be included (entities, effects, weapons, etc). This must
	be done at the end of the init.lua and cl_init.lua files.
--]]

Schema:Register();