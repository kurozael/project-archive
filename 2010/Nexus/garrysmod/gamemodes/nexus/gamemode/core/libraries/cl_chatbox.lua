--[[
name: "cl_chatbox.lua".
Product: "nexus".
--]]

nexus.chatBox = {};
nexus.chatBox.classes = {};
nexus.chatBox.messages = {};
nexus.chatBox.spaceWidths = {};
nexus.chatBox.historyPosition = 0;
nexus.chatBox.historyMessages = {};

chat.NexusAddText = chat.AddText;

-- A function to add text to the chat box.
function chat.AddText(...)
	local currentColor;
	local text = {};
	
	for k, v in ipairs( {...} ) do
		if (type(v) == "Player") then
			text[#text + 1] = g_Team.GetColor( v:Team() );
			text[#text + 1] = v:Name();
		elseif (type(v) == "table") then
			currentColor = v;
		elseif (currentColor) then
			text[#text + 1] = currentColor;
			text[#text + 1] = v;
		else
			text[#text + 1] = v;
		end;
	end;
	
	nexus.chatBox.Add( nil, nil, unpack(text) );
end;

usermessage.Hook("nx_ChatBoxDeathCode", function(msg)
	local code = msg:ReadLong();
	
	if ( nexus.chatBox.IsOpen() ) then
		local text = nexus.chatBox.textEntry:GetValue();
		
		if (text != "") then
			if (string.sub(text, 1, 2) != "//" and string.sub(text, 1, 3) != ".//") then
				RunConsoleCommand("nx_deathCode", code);
				
				nexus.chatBox.textEntry:SetRealValue(string.sub(text, 0, string.len(text) - 1).."-");
				nexus.chatBox.textEntry:OnEnter();
			end;
		end;
	end;
end);

NEXUS:HookDataStream("ChatBoxPlayerMessage", function(data)
	if ( data.speaker:IsPlayer() ) then
		nexus.chatBox.Decode(data.speaker, data.speaker:Name(), data.text, data.data, data.class);
	end;
end);

NEXUS:HookDataStream("ChatBoxMessage", function(data)
	nexus.chatBox.Decode(nil, nil, data.text, data.data, data.class);
end);

-- A function to register a chat box class.
function nexus.chatBox.RegisterClass(class, filter, Callback)
	nexus.chatBox.classes[class] = {
		Callback = Callback,
		filter = filter
	};
end;

-- A function to set the chat box's custom position.
function nexus.chatBox.SetCustomPosition(x, y)
	nexus.chatBox.position = {
		x = x,
		y = y
	};
end;

-- A function to get the chat box's custom position.
function nexus.chatBox.GetCustomPosition()
	return nexus.chatBox.position;
end;

-- A function to reset the chat box's custom position.
function nexus.chatBox.ResetCustomPosition()
	nexus.chatBox.position = nil;
end;

-- A function to get the position of the chat area.
function nexus.chatBox.GetPosition(addX, addY)
	local customPosition = nexus.chatBox.GetCustomPosition();
	local x, y = 8, ScrH() * 0.75;
	
	if (customPosition) then
		x = customPosition.x;
		y = customPosition.y;
	end;
	
	return x + (addX or 0), y + (addY or 0);
end;

-- A function to get the chat box panel.
function nexus.chatBox.GetPanel()
	if ( IsValid(nexus.chatBox.panel) ) then
		return nexus.chatBox.panel;
	end;
end;

-- A function to get the x position of the chat area.
function nexus.chatBox.GetX()
	local x, y = nexus.chatBox.GetPosition();
	
	return x;
end;

-- A function to get the y position of the chat area.
function nexus.chatBox.GetY()
	local x, y = nexus.chatBox.GetPosition();
	
	return y;
end;

-- A function to get the current text.
function nexus.chatBox.GetCurrentText()
	local textEntry = nexus.chatBox.textEntry;
	
	if ( textEntry:IsVisible() and nexus.chatBox.IsOpen() ) then
		return textEntry:GetValue();
	else
		return "";
	end;
end;

-- A function to get whether the player is typing a command.
function nexus.chatBox.IsTypingCommand()
	local currentText = nexus.chatBox.GetCurrentText();
	local prefix = nexus.config.Get("command_prefix"):Get();
	
	if (string.sub( currentText, 1, string.len(prefix) ) == prefix) then
		return true;
	else
		return false;
	end;
end;

-- A function to get the spacing between messages.
function nexus.chatBox.GetSpacing()
	local chatBoxTextFont = nexus.schema.GetFont("chat_box_text");
	local textWidth, textHeight = NEXUS:GetCachedTextSize(chatBoxTextFont, "U");
	
	if (textWidth and textHeight) then
		return textHeight + 4;
	end;
end;

-- A function to create all of the derma.
function nexus.chatBox.CreateDermaAll()
	nexus.chatBox.CreateDermaPanel();
	nexus.chatBox.CreateDermaTextEntry();

	nexus.chatBox.panel:Hide();
end;

-- A function to create a derma text entry.
function nexus.chatBox.CreateDermaTextEntry()
	if (!nexus.chatBox.textEntry) then
		nexus.chatBox.textEntry = vgui.Create("DTextEntry", nexus.chatBox.panel);
		nexus.chatBox.textEntry:SetPos(34, 4);
		nexus.chatBox.textEntry:SetTabPosition(1);
		
		-- Called each frame.
		function nexus.chatBox.textEntry:Think()
			local text = self:GetValue();
			
			if (string.len(text) > 126) then
				self:SetRealValue( string.sub(text, 0, 126) );
				
				surface.PlaySound("common/talk.wav");
			elseif ( nexus.chatBox.IsOpen() ) then
				if (text != self.previousText) then
					nexus.mount.Call("ChatBoxTextChanged", self.previousText or "", text);
				end;
			end;
			
			self.previousText = text;
		end;
		
		-- Called when enter has been pressed.
		function nexus.chatBox.textEntry:OnEnter()
			local text = self:GetValue();
			
			if (text and text != "") then
				nexus.chatBox.historyPosition = #nexus.chatBox.historyMessages;
				
				RunConsoleCommand( "say", string.Replace(text, "\"", "~") );
				
				nexus.mount.Call("ChatBoxTextTyped", text);
				
				self:SetRealValue("");
			end;
			
			if (text and text != "") then
				nexus.chatBox.panel:Hide(true);
			else
				nexus.chatBox.panel:Hide();
			end;
		end;
		
		-- A function to set the text entry's real value.
		function nexus.chatBox.textEntry:SetRealValue(text, limit)
			self:SetValue(text);
			
			if (limit) then
				if ( self:GetCaretPos() > string.len(text) ) then
					self:SetCaretPos( string.len(text) );
				end;
			else
				self:SetCaretPos( string.len(text) );
			end;
		end;
		
		-- Called when a key code has been typed.
		function nexus.chatBox.textEntry:OnKeyCodeTyped(code)
			if ( code == KEY_ENTER and !self:IsMultiline() and self:GetEnterAllowed() ) then
				self:FocusNext();
				self:OnEnter();
			elseif (code == KEY_TAB) then
				local text = self:GetValue();
				local prefix = nexus.config.Get("command_prefix"):Get();
				
				if (string.sub( text, 1, string.len(prefix) ) == prefix) then
					local exploded = NEXUS:ExplodeString(" ", text);
					
					if ( !exploded[2] ) then
						local commands = NEXUS:GetSortedCommands();
						local command = string.sub(exploded[1], string.len(prefix) + 1);
						local useNext = nil;
						local first = nil;
						
						command = string.lower(command);
						
						for k, v in pairs(commands) do
							v = string.lower(v);
							
							if (!first) then first = v; end;
							
							if ( (string.len(command) < string.len(v) and string.find(v, command) == 1) or useNext ) then
								self:SetRealValue(prefix..v);
								
								return;
							elseif ( v == string.lower(command) ) then
								useNext = true;
							end
						end
						
						if (useNext and first) then
							self:SetRealValue(prefix..first);
							
							return;
						end
					end;
				end;
				
				text = nexus.mount.Call("OnChatTab", text);
				
				if (text and type(text) == "string") then
					self:SetRealValue(text)
				end;
			else
				local text = hook.Call( "ChatBoxKeyCodeTyped", NEXUS, code, self:GetValue() );
				
				if (text and type(text) == "string") then
					self:SetRealValue(text)
				end;
			end;
		end;
	end;
end;

-- A function to create the derma panel.
function nexus.chatBox.CreateDermaPanel()
	if (!nexus.chatBox.panel) then
		nexus.chatBox.panel = vgui.Create("EditablePanel");
		
		-- A function to show the chat panel.
		function nexus.chatBox.panel:Show()
			nexus.chatBox.panel:SetKeyboardInputEnabled(true);
			nexus.chatBox.panel:SetMouseInputEnabled(true);
			nexus.chatBox.panel:SetVisible(true);
			nexus.chatBox.panel:MakePopup();
			
			nexus.chatBox.textEntry:RequestFocus();
			nexus.chatBox.scroll:SetVisible(true);
			
			nexus.chatBox.historyPosition = #nexus.chatBox.historyMessages;
			
			if ( IsValid(g_LocalPlayer) ) then
				nexus.mount.Call("ChatBoxOpened");
			end;
		end;
		
		-- A function to hide the chat panel.
		function nexus.chatBox.panel:Hide(textTyped)
			nexus.chatBox.panel:SetKeyboardInputEnabled(false);
			nexus.chatBox.panel:SetMouseInputEnabled(false);
			nexus.chatBox.panel:SetVisible(false);
			
			nexus.chatBox.textEntry:SetText("");
			nexus.chatBox.scroll:SetVisible(false);
			
			if ( IsValid(g_LocalPlayer) ) then
				nexus.mount.Call("ChatBoxClosed", textTyped);
			end;
		end;
		
		-- Called each time the panel should be painted.
		function nexus.chatBox.panel:Paint()
			local backgroundColor = nexus.schema.GetColor("background");
			local cornerSize = 4;
			
			NEXUS:DrawRoundedGradient(cornerSize, 0, 0, self:GetWide(), self:GetTall(), backgroundColor);
		end;
		
		-- Called eveyr frame.
		function nexus.chatBox.panel:Think()
			local panelWidth = ScrW() / 4;
			local x, y = nexus.chatBox.GetPosition();
			
			nexus.chatBox.panel:SetPos(x, y + 6);
			nexus.chatBox.panel:SetSize(panelWidth + 8, 24);
			nexus.chatBox.textEntry:SetPos(4, 4);
			nexus.chatBox.textEntry:SetSize(panelWidth, 16);
			
			if ( self:IsVisible() and input.IsKeyDown(KEY_ESCAPE) ) then
				nexus.chatBox.panel:Hide();
			end;
		end;
		
		nexus.chatBox.scroll = vgui.Create("Panel");
		nexus.chatBox.scroll:SetPos(0, 0);
		nexus.chatBox.scroll:SetSize(0, 0);
		
		-- Called when the panel is scrolled with the mouse wheel.
		function nexus.chatBox.scroll:OnMouseWheeled(delta)
			local isOpen = nexus.chatBox.IsOpen();
			local maximumLines = math.Clamp(NX_CONVAR_MAXCHATLINES:GetInt(), 1, 10);
			
			if (isOpen) then
				if (delta > 0) then
					delta = math.Clamp(delta, 1, maximumLines);
					
					if ( nexus.chatBox.historyMessages[nexus.chatBox.historyPosition - maximumLines] ) then
						nexus.chatBox.historyPosition = nexus.chatBox.historyPosition - delta;
					end;
				else
					if ( !nexus.chatBox.historyMessages[nexus.chatBox.historyPosition - delta] ) then
						delta = -1;
					end;
					
					if ( nexus.chatBox.historyMessages[nexus.chatBox.historyPosition - delta] ) then
						nexus.chatBox.historyPosition = nexus.chatBox.historyPosition - delta;
					end;
				end;
			end;
		end;
	end;
end;

-- A function to get whether the chat box is open.
function nexus.chatBox.IsOpen()
	return nexus.chatBox.panel and nexus.chatBox.panel:IsVisible();
end;

-- A function to decode a message.
function nexus.chatBox.Decode(speaker, name, text, data, class)
	local filtered = nil;
	local filter;
	local icon;
	
	if ( nexus.chatBox.classes[class] ) then
		filter = nexus.chatBox.classes[class].filter;
	elseif (class == "pm" or class == "ooc"
	or class == "roll" or class == "looc") then
		filtered = (NX_CONVAR_SHOWOOC:GetInt() == 0);
		filter = "ooc";
	else
		filtered = (NX_CONVAR_SHOWIC:GetInt() == 0);
		filter = "ic";
	end;
	
	text = string.Replace(text, " ' ", "'");
	
	if ( IsValid(speaker) ) then
		if ( !NEXUS:IsChoosingCharacter() ) then
			if (speaker:Name() != "") then
				local unrecognised = false;
				local classIndex = speaker:Team();
				local classColor = g_Team.GetColor(classIndex);
				local focusedOn = false;
				
				if ( speaker:IsSuperAdmin() ) then
					icon = {"gui/silkicons/shield", "^"};
				elseif ( speaker:IsAdmin() ) then
					icon = {"gui/silkicons/star", "*"};
				elseif ( speaker:IsUserGroup("operator") ) then
					icon = {"gui/silkicons/emoticon_smile", "@"};
				else
					local faction = nexus.player.GetFaction(speaker);
					
					if ( faction and nexus.faction.stored[faction] ) then
						if (nexus.faction.stored[faction].whitelist) then
							icon = {"gui/silkicons/add", "/"};
						end;
					end;
					
					if (!icon) then
						icon = {"gui/silkicons/user", "o"};
					end;
				end;
				
				if (!nexus.player.DoesRecognise(speaker, RECOGNISE_TOTAL) and filter == "ic") then
					unrecognised = true;
				end;
				
				if (nexus.player.GetRealTrace(g_LocalPlayer).Entity == speaker) then
					focusedOn = true;
				end;
				
				local info = {
					unrecognised = unrecognised,
					shouldHear = nexus.player.CanHearPlayer(g_LocalPlayer, speaker),
					focusedOn = focusedOn,
					filtered = filtered,
					speaker = speaker,
					visible = true;
					filter = filter,
					class = class,
					icon = icon,
					name = name,
					text = text,
					data = data
				};
				
				nexus.mount.Call("ChatBoxAdjustInfo", info);
				
				if (info.visible) then
					if (info.filter == "ic") then
						if ( !g_LocalPlayer:Alive() ) then
							return;
						end;
					end;
					
					if (info.unrecognised) then
						local unrecognisedName, usedPhysDesc = nexus.player.GetUnrecognisedName(info.speaker);
						
						if (usedPhysDesc and string.len(unrecognisedName) > 24) then
							unrecognisedName = string.sub(unrecognisedName, 1, 21).."...";
						end;
						
						info.name = "["..unrecognisedName.."]";
					end;
					
					if ( nexus.chatBox.classes[info.class] ) then
						nexus.chatBox.classes[info.class].Callback(info);
					elseif (info.class == "radio_eavesdrop") then
						if (info.shouldHear) then
							local color = Color(255, 255, 175, 255);
							
							if (info.focusedOn) then
								color = Color(175, 255, 175, 255);
							end;
							
							nexus.chatBox.Add(info.filtered, nil, color, info.name.." radios in \""..info.text.."\"");
						end;
					elseif (info.class == "whisper") then
						if (info.shouldHear) then
							local color = Color(255, 255, 175, 255);
							
							if (info.focusedOn) then
								color = Color(175, 255, 175, 255);
							end;
							
							nexus.chatBox.Add(info.filtered, nil, color, info.name.." whispers \""..info.text.."\"");
						end;
					elseif (info.class == "event") then
						nexus.chatBox.Add(info.filtered, nil, Color(200, 100, 50, 255), info.text);
					elseif (info.class == "radio") then
						nexus.chatBox.Add(info.filtered, nil, Color(75, 150, 50, 255), info.name.." radios in \""..info.text.."\"");
					elseif (info.class == "yell") then
						local color = Color(255, 255, 175, 255);
						
						if (info.focusedOn) then
							color = Color(175, 255, 175, 255);
						end;
						
						nexus.chatBox.Add(info.filtered, nil, color, info.name.." yells \""..info.text.."\"");
					elseif (info.class == "chat") then
						nexus.chatBox.Add(info.filtered, nil, classColor, info.name, ": ", info.text, nil, info.filtered);
					elseif (info.class == "looc") then
						nexus.chatBox.Add(info.filtered, nil, Color(225, 50, 50, 255), "[LOOC] ", Color(255, 255, 150, 255), info.name..": "..info.text);
					elseif (info.class == "roll") then
						if (info.shouldHear) then
							nexus.chatBox.Add(info.filtered, nil, Color(150, 75, 75, 255), "** "..info.name.." "..info.text);
						end;
					elseif (info.class == "ooc") then
						nexus.chatBox.Add(info.filtered, info.icon, Color(225, 50, 50, 255), "[OOC] ", classColor, info.name, ": ", info.text);
					elseif (info.class == "pm") then
						nexus.chatBox.Add(info.filtered, nil, "[PM] ", Color(125, 150, 75, 255), info.name..": "..info.text);
					elseif (info.class == "me") then
						local color = Color(255, 255, 175, 255);
						
						if (info.focusedOn) then
							color = Color(175, 255, 175, 255);
						end;
						
						if (string.sub(info.text, 1, 1) == "'") then
							nexus.chatBox.Add(info.filtered, nil, color, "** "..info.name..info.text);
						else
							nexus.chatBox.Add(info.filtered, nil, color, "** "..info.name.." "..info.text);
						end;
					elseif (info.class == "it") then
						local color = Color(255, 255, 175, 255);
						
						if (info.focusedOn) then
							color = Color(175, 255, 175, 255);
						end;
						
						nexus.chatBox.Add(info.filtered, nil, color, "** "..info.text);
					elseif (info.class == "ic") then
						if (info.shouldHear) then
							local color = Color(255, 255, 150, 255);
							
							if (info.focusedOn) then
								color = Color(175, 255, 150, 255);
							end;
							
							nexus.chatBox.Add(info.filtered, nil, color, info.name.." says \""..info.text.."\"");
						end;
					end;
				end;
			end;
		end;
	else
		if (name == "Console" and class == "chat") then
			icon = {"gui/silkicons/shield", "^"};
		end;
		
		local info = {
			filtered = filtered,
			visible = true;
			filter = filter,
			class = class,
			icon = icon,
			name = name,
			text = text,
			data = data
		};
		
		nexus.mount.Call("ChatBoxAdjustInfo", info);
		
		if (!info.visible) then return; end;
		
		if ( nexus.chatBox.classes[info.class] ) then
			nexus.chatBox.classes[info.class].Callback(info);
		elseif (info.class == "notify_all") then
			if ( nexus.menu.GetOpen() ) then
				nexus.menu.SetNotice(info.text);
			end;
			
			local filtered = (NX_CONVAR_SHOWNEXUS:GetInt() == 0) or info.filtered;
			
			if (string.sub(info.text, -1) == "!") then
				nexus.chatBox.Add(filtered, {"gui/silkicons/error", "X"}, Color(200, 175, 200, 255), info.text);
			else
				nexus.chatBox.Add(filtered, {"gui/silkicons/comment", "/"}, Color(125, 150, 175, 255), info.text);
			end;
		elseif (info.class == "disconnect") then
			local filtered = (NX_CONVAR_SHOWNEXUS:GetInt() == 0) or info.filtered;
			
			nexus.chatBox.Add(filtered, {"gui/silkicons/user_delete", "-"}, Color(200, 150, 200, 255), info.text);
		elseif (info.class == "notify") then
			if ( nexus.menu.GetOpen() ) then
				nexus.menu.SetNotice(info.text);
			end;
			
			local filtered = (NX_CONVAR_SHOWNEXUS:GetInt() == 0) or info.filtered;
			
			if (string.sub(info.text, -1) == "!") then
				nexus.chatBox.Add(filtered, {"gui/silkicons/error", "X"}, Color(200, 175, 200, 255), info.text);
			else
				nexus.chatBox.Add(filtered, {"gui/silkicons/comment", "/"}, Color(175, 200, 255, 255), info.text);
			end;
		elseif (info.class == "connect") then
			local filtered = (NX_CONVAR_SHOWNEXUS:GetInt() == 0) or info.filtered;
			
			nexus.chatBox.Add(filtered, {"gui/silkicons/user_add", "+"}, Color(150, 150, 200, 255), info.text);
		elseif (info.class == "chat") then
			nexus.chatBox.Add(info.filtered, info.icon, Color(225, 50, 50, 255), "[OOC] ", Color(150, 150, 150, 255), name, ": ", info.text);
		else
			local yellowColor = Color(255, 255, 150, 255);
			local blueColor = Color(125, 150, 175, 255);
			local redColor = Color(200, 25, 25, 255);
			local filtered = (NX_CONVAR_SHOWSERVER:GetInt() == 0) or info.filtered;
			local prefix;
			
			nexus.chatBox.Add(filtered, nil, yellowColor, info.text);
		end;
	end;
end;

-- A function to print a message to the console.
function nexus.chatBox.Print(message)
	local text = "";
	
	if (message.icon) then
		text = text.."("..message.icon[2]..") ";
	end;
	
	for k, v in ipairs(message.text) do
		text = text..v.text;
	end;
	
	print(text);
end;

-- A function to add and wrap text to a message.
function nexus.chatBox.WrappedText(newLine, message, color, text)
	local chatBoxTextFont = nexus.schema.GetFont("chat_box_text");
	local maximumWidth = ScrW() * 0.75;
	local singleWidth = NEXUS:GetTextSize(chatBoxTextFont, "U");
	local width = NEXUS:GetTextSize(chatBoxTextFont, text);
	
	if (message.currentWidth + width > maximumWidth) then
		local characters = math.ceil( (maximumWidth - message.currentWidth) / singleWidth ) + 1;
		local secondText = string.sub(text, characters + 1);
		local firstText = string.sub(text, 0, characters);
		
		if (firstText and firstText != "") then
			nexus.chatBox.WrappedText(true, message, color, firstText);
		end;
		
		if (secondText and secondText != "") then
			nexus.chatBox.WrappedText(nil, message, color, secondText);
		end;
	else
		message.text[#message.text + 1] = {
			newLine = newLine,
			width = width,
			color = color,
			text = text
		};
		
		if (newLine) then
			message.currentWidth = 0;
			message.lines = message.lines + 1;
		else
			message.currentWidth = message.currentWidth + width;
		end;
	end;
end;

-- A function to paint the chat box.
function nexus.chatBox.Paint()
	local menuTextTinyFont = nexus.schema.GetFont("menu_text_tiny");
	local chatBoxTextFont = nexus.schema.GetFont("chat_box_text");
	local isOpen = nexus.chatBox.IsOpen();
	
	if (isOpen) then
		local backgroundColor = nexus.schema.GetColor("background");
		local panelHeight = nexus.chatBox.scroll:GetTall();
		local cornerSize = 4;
		local panelWidth = nexus.chatBox.scroll:GetWide();
		local panelY = nexus.chatBox.scroll.y;
		local panelX = nexus.chatBox.scroll.x;
		
		if (panelWidth > 8 or panelHeight > 8) then
			NEXUS:DrawRoundedGradient(cornerSize, panelX, panelY, panelWidth, panelHeight, backgroundColor);
		end;
	end;
	
	NEXUS:OverrideMainFont(chatBoxTextFont);
		if ( !nexus.chatBox.spaceWidths[chatBoxTextFont] ) then
			nexus.chatBox.spaceWidths[chatBoxTextFont] = NEXUS:GetTextSize(chatBoxTextFont, " ");
		end;
		
		local isTypingCommand = nexus.chatBox.IsTypingCommand();
		local chatBoxSpacing = nexus.chatBox.GetSpacing();
		local maximumLines = math.Clamp(NX_CONVAR_MAXCHATLINES:GetInt(), 1, 10);
		local origX, origY = nexus.chatBox.GetPosition(4);
		local spaceWidth = nexus.chatBox.spaceWidths[chatBoxTextFont];
		local fontHeight = chatBoxSpacing - 4;
		local messages = nexus.chatBox.messages;
		local x, y = origX, origY;
		local box = {width = 0, height = 0};

		if (!isOpen) then
			if (#nexus.chatBox.historyMessages > 100) then
				local amount = #nexus.chatBox.historyMessages - 100;
				
				for i = 1, amount do
					table.remove(nexus.chatBox.historyMessages, 1);
				end;
			end;
		else
			messages = {};
			
			for i = 0, (maximumLines - 1) do
				messages[#messages + 1] = nexus.chatBox.historyMessages[nexus.chatBox.historyPosition - i];
			end;
		end;
		
		for k, v in pairs(messages) do
			if ( messages[k - 1] ) then
				y = y - messages[k - 1].spacing;
			end;
			
			if (!isOpen and k == 1) then
				y = y - ( (chatBoxSpacing + v.spacing) * (v.lines - 1) ) + 14;
			else
				y = y - ( (chatBoxSpacing + v.spacing) * v.lines );
				
				if (k == 1) then
					y = y + 2;
				end;
			end;
			
			local messageX = x;
			local messageY = y;
			local alpha = v.alpha;
			
			if (isTypingCommand) then
				alpha = 25;
			elseif (isOpen) then
				alpha = 255;
			end;
			
			if (v.icon) then
				surface.SetTexture( surface.GetTextureID( v.icon[1] ) );
				surface.SetDrawColor(255, 255, 255, alpha);
				surface.DrawTexturedRect(messageX, messageY + (fontHeight / 2) - 8, 16, 16);
				
				messageX = messageX + 16 + spaceWidth;
			end;
			
			for k2, v2 in pairs(v.text) do
				local textColor = Color(v2.color.r, v2.color.g, v2.color.b, alpha);
				local newLine = false;
				
				NEXUS:DrawSimpleText(v2.text, messageX, messageY, textColor);
				
				messageX = messageX + v2.width;
				
				if (origY - y > box.height) then
					box.height = origY - y;
				end;
				
				if (messageX - 8 > box.width) then
					box.width = messageX - 8;
				end;
				
				if (v2.newLine) then
					messageY = messageY + chatBoxSpacing + v.spacing;
					messageX = origX;
				end;
			end;
		end;
	NEXUS:OverrideMainFont(false);
	
	if (isTypingCommand) then
		local currentText = nexus.chatBox.GetCurrentText();
		local colorWhite = nexus.schema.GetColor("white");
		local commands = {};
		local oX, oY = origX, origY;
		local command = NEXUS:ExplodeString( " ", string.sub(currentText, 2) )[1];
		local prefix = nexus.config.Get("command_prefix"):Get();
		
		if (command) then
			for k, v in pairs(nexus.command.stored) do
				if ( string.sub( k, 1, string.len(command) ) == string.lower(command) ) then
					if ( nexus.player.HasFlags(g_LocalPlayer, v.access) ) then
						commands[#commands + 1] = v;
					end;
				end;
				
				if (#commands == 4) then
					break;
				end;
			end;
			
			if (#commands > 0) then
				local singleCommand = (#commands == 1);
				
				NEXUS:OverrideMainFont(menuTextTinyFont);
					for k, v in ipairs(commands) do
						local totalText = prefix..v.name;
						
						if (singleCommand) then
							totalText = totalText.." "..v.text;
						end;
						
						local tWidth, tHeight = NEXUS:GetCachedTextSize(menuTextTinyFont, totalText);
						
						if (k == 1) then
							oY = oY - tHeight;
						end;
						
						NEXUS:DrawSimpleText(totalText, oX, oY, colorWhite);
						
						if (k < #commands) then oY = oY - tHeight; end;
						if (oY < y) then y = oY; end;
						
						if (origY - oY > box.height) then
							box.height = origY - oY;
						end;
						
						if (origX + tWidth - 8 > box.width) then
							box.width = origX + tWidth - 8;
						end;
					end;
				NEXUS:OverrideMainFont(false);
			end;
		end;
	end;
	
	nexus.chatBox.scroll:SetSize(box.width + 8, box.height + 8);
	nexus.chatBox.scroll:SetPos(x - 4, y - 4);
end;

-- A function to add a message to the chat box.
function nexus.chatBox.Add(filtered, icon, ...)
	if (ScrW() == 160 or ScrH() == 27) then
		return;
	end;
	
	if (!filtered) then
		local maximumLines = math.Clamp(NX_CONVAR_MAXCHATLINES:GetInt(), 1, 10);
		local colorWhite = nexus.schema.GetColor("white");
		local curTime = UnPredictedCurTime();
		local message = {
			timeFinish = curTime + 11,
			timeStart = curTime,
			timeFade = curTime + 10,
			spacing = 0,
			alpha = 255,
			lines = 1,
			icon = icon
		};
		
		local currentColor;
		local text = {...};
		
		if (NX_CONVAR_SHOWTIMESTAMPS:GetInt() == 1) then
			local timeInfo = "("..os.date("%H:%M")..") ";
			local color = Color(150, 150, 150, 255);
			
			if (NX_CONVAR_TWELVEHOURCLOCK:GetInt() == 1) then
				timeInfo = "("..string.lower( os.date("%I:%M%p") )..") ";
			end;
			
			if (text) then
				table.insert(text, 1, color);
				table.insert(text, 2, timeInfo);
			else
				text = {timeInfo, color};
			end;
		end;
		
		if (text) then
			message.currentWidth = 0;
			message.text = {};
			
			for k, v in ipairs(text) do
				if (type(v) == "string" or type(v) == "number" or type(v) == "boolean") then
					nexus.chatBox.WrappedText( nil, message, currentColor or colorWhite, tostring(v) );
					
					currentColor = nil;
				elseif (type(v) == "Player") then
					nexus.chatBox.WrappedText( nil, message, g_Team.GetColor( v:Team() ), v:Name() );
					
					currentColor = nil;
				elseif (type(v) == "table") then
					currentColor = Color(v.r or 255, v.g or 255, v.b or 255);
				end;
			end;
		end;
		
		nexus.chatBox.Print(message);
		
		if (nexus.chatBox.historyPosition == #nexus.chatBox.historyMessages) then
			nexus.chatBox.historyPosition = #nexus.chatBox.historyMessages + 1;
		end;
		
		nexus.chatBox.historyMessages[#nexus.chatBox.historyMessages + 1] = message;
		
		if (#nexus.chatBox.messages == maximumLines) then
			table.remove(nexus.chatBox.messages, maximumLines);
		end;
		
		table.insert(nexus.chatBox.messages, 1, message);
		
		surface.PlaySound("common/talk.wav");
	end;
end;

hook.Add("PlayerBindPress", "nexus.chatBox.PlayerBindPress", function(player, bind, press)
	if ( ( string.find(bind, "messagemode") or string.find(bind, "messagemode2") ) and press ) then
		if ( g_LocalPlayer:HasInitialized() ) then
			nexus.chatBox.panel:Show();
		end;
		
		return true;
	end;
end);

hook.Add("Think", "nexus.chatBox.Think", function()
	local curTime = UnPredictedCurTime();
	
	for k, v in ipairs(nexus.chatBox.messages) do
		if (curTime >= v.timeFade) then
			local fadeTime = v.timeFinish - v.timeFade;
			local timeLeft = v.timeFinish - curTime;
			local alpha = math.Clamp( (255 / fadeTime) * timeLeft, 0, 255 );
			
			if (alpha == 0) then
				table.remove(nexus.chatBox.messages, k);
			else
				v.alpha = alpha;
			end;
		end;
	end;
end);