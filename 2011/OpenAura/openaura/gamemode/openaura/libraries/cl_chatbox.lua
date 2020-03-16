--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

openAura.chatBox = {};
openAura.chatBox.classes = {};
openAura.chatBox.messages = {};
openAura.chatBox.spaceWidths = {};
openAura.chatBox.historyPosition = 0;
openAura.chatBox.historyMessages = {};

chat.OpenAuraAddText = chat.AddText;

-- A function to add text to the chat box.
function chat.AddText(...)
	local currentColor = nil;
	local text = {};
	
	for k, v in ipairs( {...} ) do
		if (type(v) == "Player") then
			text[#text + 1] = _team.GetColor( v:Team() );
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
	openAura.chatBox:Add( nil, nil, unpack(text) );
end;

usermessage.Hook("aura_ChatBoxDeathCode", function(msg)
	local code = msg:ReadLong();
	
	if ( openAura.chatBox:IsOpen() ) then
		local text = openAura.chatBox.textEntry:GetValue();
		
		if (text != "") then
			if (string.sub(text, 1, 2) != "//" and string.sub(text, 1, 3) != ".//"
			and string.sub(text, 1, 2) != "[[") then
				RunConsoleCommand("aura_deathcode", code);
				
				openAura.chatBox.textEntry:SetRealValue(string.sub(text, 0, string.len(text) - 1).."-");
				openAura.chatBox.textEntry:OnEnter();
			end;
		end;
	end;
end);

openAura:HookDataStream("ChatBoxPlayerMessage", function(data)
	if ( data.speaker:IsPlayer() ) then
		openAura.chatBox:Decode(data.speaker, data.speaker:Name(), data.text, data.data, data.class);
	end;
end);

openAura:HookDataStream("ChatBoxMessage", function(data)
	openAura.chatBox:Decode(nil, nil, data.text, data.data, data.class);
end);

-- A function to register a chat box class.
function openAura.chatBox:RegisterClass(class, filter, Callback)
	self.classes[class] = {
		Callback = Callback,
		filter = filter
	};
end;

-- A function to set the chat box's custom position.
function openAura.chatBox:SetCustomPosition(x, y)
	self.position = {
		x = x,
		y = y
	};
end;

-- A function to get the chat box's custom position.
function openAura.chatBox:GetCustomPosition()
	return self.position;
end;

-- A function to reset the chat box's custom position.
function openAura.chatBox:ResetCustomPosition()
	self.position = nil;
end;

-- A function to get the position of the chat area.
function openAura.chatBox:GetPosition(addX, addY)
	local customPosition = openAura.chatBox:GetCustomPosition();
	local x, y = 8, ScrH() * 0.75;
	
	if (customPosition) then
		x = customPosition.x;
		y = customPosition.y;
	end;
	
	return x + (addX or 0), y + (addY or 0);
end;

-- A function to get the chat box panel.
function openAura.chatBox:GetPanel()
	if ( IsValid(self.panel) ) then
		return self.panel;
	end;
end;

-- A function to get the x position of the chat area.
function openAura.chatBox:GetX()
	local x, y = openAura.chatBox:GetPosition();
	
	return x;
end;

-- A function to get the y position of the chat area.
function openAura.chatBox:GetY()
	local x, y = openAura.chatBox:GetPosition();
	
	return y;
end;

-- A function to get the current text.
function openAura.chatBox:GetCurrentText()
	local textEntry = self.textEntry;
	
	if ( textEntry:IsVisible() and openAura.chatBox:IsOpen() ) then
		return textEntry:GetValue();
	else
		return "";
	end;
end;

-- A function to get whether the player is typing a command.
function openAura.chatBox:IsTypingCommand()
	local currentText = openAura.chatBox:GetCurrentText();
	local prefix = openAura.config:Get("command_prefix"):Get();
	
	if (string.sub( currentText, 1, string.len(prefix) ) == prefix) then
		return true;
	else
		return false;
	end;
end;

-- A function to get the spacing between messages.
function openAura.chatBox:GetSpacing()
	local chatBoxTextFont = openAura.option:GetFont("chat_box_text");
	local textWidth, textHeight = openAura:GetCachedTextSize(chatBoxTextFont, "U");
	
	if (textWidth and textHeight) then
		return textHeight + 4;
	end;
end;

-- A function to create all of the derma.
function openAura.chatBox:CreateDermaAll()
	openAura.chatBox:CreateDermaPanel();
	openAura.chatBox:CreateDermaTextEntry();

	self.panel:Hide();
end;

-- A function to create a derma text entry.
function openAura.chatBox:CreateDermaTextEntry()
	if (!self.textEntry) then
		self.textEntry = vgui.Create("DTextEntry", self.panel);
		self.textEntry:SetPos(34, 4);
		self.textEntry:SetTabPosition(1);
		self.textEntry:SetAllowNonAsciiCharacters(true);
		
		-- Called each frame.
		self.textEntry.Think = function(textEntry)
			local text = textEntry:GetValue();
			
			if (string.len(text) > 126) then
				textEntry:SetRealValue( string.sub(text, 0, 126) );
				
				surface.PlaySound("common/talk.wav");
			elseif ( self:IsOpen() ) then
				if (text != textEntry.previousText) then
					openAura.plugin:Call("ChatBoxTextChanged", textEntry.previousText or "", text);
				end;
			end;
			
			textEntry.previousText = text;
		end;
		
		-- Called when enter has been pressed.
		self.textEntry.OnEnter = function(textEntry)
			local text = textEntry:GetValue();
			
			if (text and text != "") then
				self.historyPosition = #self.historyMessages;
				
				local replaceText = openAura:Replace(text, "\"", "~");
				RunConsoleCommand("say", replaceText);
				
				openAura.plugin:Call("ChatBoxTextTyped", text);
				textEntry:SetRealValue("");
			end;
			
			if (text and text != "") then
				self.panel:Hide(true);
			else
				self.panel:Hide();
			end;
		end;
		
		-- A function to set the text entry's real value.
		self.textEntry.SetRealValue = function(textEntry, text, limit)
			textEntry:SetValue(text);
			
			if (limit) then
				if ( textEntry:GetCaretPos() > string.len(text) ) then
					textEntry:SetCaretPos( string.len(text) );
				end;
			else
				textEntry:SetCaretPos( string.len(text) );
			end;
		end;
		
		-- Called when a key code has been typed.
		self.textEntry.OnKeyCodeTyped = function(textEntry, code)
			if ( code == KEY_ENTER and !textEntry:IsMultiline() and textEntry:GetEnterAllowed() ) then
				textEntry:FocusNext();
				textEntry:OnEnter();
			elseif (code == KEY_TAB) then
				local text = textEntry:GetValue();
				local prefix = openAura.config:Get("command_prefix"):Get();
				
				if (string.sub( text, 1, string.len(prefix) ) == prefix) then
					local exploded = string.Explode(" ", text);
					
					if ( !exploded[2] ) then
						local commands = openAura:GetSortedCommands();
						local command = string.sub(exploded[1], string.len(prefix) + 1);
						local useNext = nil;
						local first = nil;
						
						command = string.lower(command);
						
						for k, v in pairs(commands) do
							v = string.lower(v);
							if (!first) then first = v; end;
							
							if ( (string.len(command) < string.len(v) and string.find(v, command) == 1) or useNext ) then
								textEntry:SetRealValue(prefix..v);
								
								return;
							elseif ( v == string.lower(command) ) then
								useNext = true;
							end
						end
						
						if (useNext and first) then
							textEntry:SetRealValue(prefix..first);
							
							return;
						end
					end;
				end;
				
				text = openAura.plugin:Call("OnChatTab", text);
				
				if (text and type(text) == "string") then
					textEntry:SetRealValue(text)
				end;
			else
				local text = hook.Call( "ChatBoxKeyCodeTyped", openAura, code, textEntry:GetValue() );
				
				if (text and type(text) == "string") then
					textEntry:SetRealValue(text)
				end;
			end;
		end;
	end;
end;

-- A function to create the derma panel.
function openAura.chatBox:CreateDermaPanel()
	if (!self.panel) then
		self.panel = vgui.Create("EditablePanel");
		
		-- A function to show the chat panel.
		self.panel.Show = function(editablePanel)
			editablePanel:SetKeyboardInputEnabled(true);
			editablePanel:SetMouseInputEnabled(true);
			editablePanel:SetVisible(true);
			editablePanel:MakePopup();
			
			self.textEntry:RequestFocus();
			self.scroll:SetVisible(true);
			self.historyPosition = #self.historyMessages;
			
			if ( IsValid(openAura.Client) ) then
				openAura.plugin:Call("ChatBoxOpened");
			end;
		end;
		
		-- A function to hide the chat panel.
		self.panel.Hide = function(editablePanel, textTyped)
			editablePanel:SetKeyboardInputEnabled(false);
			editablePanel:SetMouseInputEnabled(false);
			editablePanel:SetVisible(false);
			
			self.textEntry:SetText("");
			self.scroll:SetVisible(false);
			
			if ( IsValid(openAura.Client) ) then
				openAura.plugin:Call("ChatBoxClosed", textTyped);
			end;
		end;
		
		-- Called each time the panel should be painted.
		self.panel.Paint = function(editablePanel)
			openAura:DrawSimpleGradientBox( 2, 0, 0, editablePanel:GetWide(), editablePanel:GetTall(), openAura.option:GetColor("background") );
		end;
		
		-- Called every frame.
		self.panel.Think = function(editablePanel)
			local panelWidth = ScrW() / 4;
			local x, y = self:GetPosition();
			
			editablePanel:SetPos(x, y + 6);
			editablePanel:SetSize(panelWidth + 8, 24);
			self.textEntry:SetPos(4, 4);
			self.textEntry:SetSize(panelWidth, 16);
			
			if ( editablePanel:IsVisible() and input.IsKeyDown(KEY_ESCAPE) ) then
				editablePanel:Hide();
			end;
		end;
		
		self.scroll = vgui.Create("Panel");
		self.scroll:SetPos(0, 0);
		self.scroll:SetSize(0, 0);
		self.scroll:SetMouseInputEnabled(true);
		
		-- Called when the panel is scrolled with the mouse wheel.
		self.scroll.OnMouseWheeled = function(panel, delta)
			local isOpen = self:IsOpen();
			local maximumLines = math.Clamp(NX_CONVAR_MAXCHATLINES:GetInt(), 1, 10);
			
			if (isOpen) then
				if (delta > 0) then
					delta = math.Clamp(delta, 1, maximumLines);
					
					if ( self.historyMessages[self.historyPosition - maximumLines] ) then
						self.historyPosition = self.historyPosition - delta;
					end;
				else
					if ( !self.historyMessages[self.historyPosition - delta] ) then
						delta = -1;
					end;
					
					if ( self.historyMessages[self.historyPosition - delta] ) then
						self.historyPosition = self.historyPosition - delta;
					end;
				end;
			end;
		end;
	end;
end;

-- A function to get whether the chat box is open.
function openAura.chatBox:IsOpen()
	return self.panel and self.panel:IsVisible();
end;

-- A function to decode a message.
function openAura.chatBox:Decode(speaker, name, text, data, class)
	local filtered = nil;
	local filter = nil;
	local icon = nil;
	
	if ( self.classes[class] ) then
		filter = self.classes[class].filter;
	elseif (class == "pm" or class == "ooc"
	or class == "roll" or class == "looc") then
		filtered = (NX_CONVAR_SHOWOOC:GetInt() == 0);
		filter = "ooc";
	else
		filtered = (NX_CONVAR_SHOWIC:GetInt() == 0);
		filter = "ic";
	end;
	
	text = openAura:Replace(text, " ' ", "'");
	
	if ( IsValid(speaker) ) then
		if ( !openAura:IsChoosingCharacter() ) then
			if (speaker:Name() != "") then
				local unrecognised = false;
				local classIndex = speaker:Team();
				local classColor = _team.GetColor(classIndex);
				local focusedOn = false;
				
				if ( speaker:IsSuperAdmin() ) then
					icon = "gui/silkicons/shield";
				elseif ( speaker:IsAdmin() ) then
					icon = "gui/silkicons/star";
				elseif ( speaker:IsUserGroup("operator") ) then
					icon = "gui/silkicons/emoticon_smile";
				else
					local faction = openAura.player:GetFaction(speaker);
					
					if ( faction and openAura.faction.stored[faction] ) then
						if (openAura.faction.stored[faction].whitelist) then
							icon = "gui/silkicons/add";
						end;
					end;
					
					if (!icon) then
						icon = "gui/silkicons/user";
					end;
				end;
				
				if (!openAura.player:DoesRecognise(speaker, RECOGNISE_TOTAL) and filter == "ic") then
					unrecognised = true;
				end;
				
				if (openAura.player:GetRealTrace(openAura.Client).Entity == speaker) then
					focusedOn = true;
				end;
				
				local info = {
					unrecognised = unrecognised,
					shouldHear = openAura.player:CanHearPlayer(openAura.Client, speaker),
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
				
				openAura.plugin:Call("ChatBoxAdjustInfo", info);
				
				if (info.visible) then
					if (info.filter == "ic") then
						if ( !openAura.Client:Alive() ) then
							return;
						end;
					end;
					
					if (info.unrecognised) then
						local unrecognisedName, usedPhysDesc = openAura.player:GetUnrecognisedName(info.speaker);
						
						if (usedPhysDesc and string.len(unrecognisedName) > 24) then
							unrecognisedName = string.sub(unrecognisedName, 1, 21).."...";
						end;
						
						info.name = "["..unrecognisedName.."]";
					end;
					
					if ( self.classes[info.class] ) then
						self.classes[info.class].Callback(info);
					elseif (info.class == "radio_eavesdrop") then
						if (info.shouldHear) then
							local color = Color(255, 255, 175, 255);
							
							if (info.focusedOn) then
								color = Color(175, 255, 175, 255);
							end;
							
							openAura.chatBox:Add(info.filtered, nil, color, info.name.." radios in \""..info.text.."\"");
						end;
					elseif (info.class == "whisper") then
						if (info.shouldHear) then
							local color = Color(255, 255, 175, 255);
							
							if (info.focusedOn) then
								color = Color(175, 255, 175, 255);
							end;
							
							openAura.chatBox:Add(info.filtered, nil, color, info.name.." whispers \""..info.text.."\"");
						end;
					elseif (info.class == "event") then
						openAura.chatBox:Add(info.filtered, nil, Color(200, 100, 50, 255), info.text);
					elseif (info.class == "radio") then
						openAura.chatBox:Add(info.filtered, nil, Color(75, 150, 50, 255), info.name.." radios in \""..info.text.."\"");
					elseif (info.class == "yell") then
						local color = Color(255, 255, 175, 255);
						
						if (info.focusedOn) then
							color = Color(175, 255, 175, 255);
						end;
						
						openAura.chatBox:Add(info.filtered, nil, color, info.name.." yells \""..info.text.."\"");
					elseif (info.class == "chat") then
						openAura.chatBox:Add(info.filtered, nil, classColor, info.name, ": ", info.text, nil, info.filtered);
					elseif (info.class == "looc") then
						openAura.chatBox:Add(info.filtered, nil, Color(225, 50, 50, 255), "[LOOC] ", Color(255, 255, 150, 255), info.name..": "..info.text);
					elseif (info.class == "roll") then
						if (info.shouldHear) then
							openAura.chatBox:Add(info.filtered, nil, Color(150, 75, 75, 255), "** "..info.name.." "..info.text);
						end;
					elseif (info.class == "ooc") then
						openAura.chatBox:Add(info.filtered, info.icon, Color(225, 50, 50, 255), "[OOC] ", classColor, info.name, ": ", info.text);
					elseif (info.class == "pm") then
						openAura.chatBox:Add(info.filtered, nil, "[PM] ", Color(125, 150, 75, 255), info.name..": "..info.text);
					elseif (info.class == "me") then
						local color = Color(255, 255, 175, 255);
						
						if (info.focusedOn) then
							color = Color(175, 255, 175, 255);
						end;
						
						if (string.sub(info.text, 1, 1) == "'") then
							openAura.chatBox:Add(info.filtered, nil, color, "** "..info.name..info.text);
						else
							openAura.chatBox:Add(info.filtered, nil, color, "** "..info.name.." "..info.text);
						end;
					elseif (info.class == "it") then
						local color = Color(255, 255, 175, 255);
						
						if (info.focusedOn) then
							color = Color(175, 255, 175, 255);
						end;
						
						openAura.chatBox:Add(info.filtered, nil, color, "** "..info.text);
					elseif (info.class == "ic") then
						if (info.shouldHear) then
							local color = Color(255, 255, 150, 255);
							
							if (info.focusedOn) then
								color = Color(175, 255, 150, 255);
							end;
							
							openAura.chatBox:Add(info.filtered, nil, color, info.name.." says \""..info.text.."\"");
						end;
					end;
				end;
			end;
		end;
	else
		if (name == "Console" and class == "chat") then
			icon = "gui/silkicons/shield";
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
		
		openAura.plugin:Call("ChatBoxAdjustInfo", info);
		
		if (!info.visible) then return; end;
		
		if ( self.classes[info.class] ) then
			self.classes[info.class].Callback(info);
		elseif (info.class == "notify_all") then
			if ( openAura:GetNoticePanel() ) then
				openAura:AddCinematicText(info.text, Color(255, 255, 255, 255), 32, 6, openAura.option:GetFont("menu_text_tiny"), true);
			end;
			
			local filtered = (NX_CONVAR_SHOWAURA:GetInt() == 0) or info.filtered;
			
			if (string.sub(info.text, -1) == "!") then
				openAura.chatBox:Add(filtered, "gui/silkicons/error", Color(200, 175, 200, 255), info.text);
			else
				openAura.chatBox:Add(filtered, "gui/silkicons/comment", Color(125, 150, 175, 255), info.text);
			end;
		elseif (info.class == "disconnect") then
			local filtered = (NX_CONVAR_SHOWAURA:GetInt() == 0) or info.filtered;
			
			openAura.chatBox:Add(filtered, "gui/silkicons/user_delete", Color(200, 150, 200, 255), info.text);
		elseif (info.class == "notify") then
			if ( openAura:GetNoticePanel() ) then
				openAura:AddCinematicText(info.text, Color(255, 255, 255, 255), 32, 6, openAura.option:GetFont("menu_text_tiny"), true);
			end;
			
			local filtered = (NX_CONVAR_SHOWAURA:GetInt() == 0) or info.filtered;
			
			if (string.sub(info.text, -1) == "!") then
				openAura.chatBox:Add(filtered, "gui/silkicons/error", Color(200, 175, 200, 255), info.text);
			else
				openAura.chatBox:Add(filtered, "gui/silkicons/comment", Color(175, 200, 255, 255), info.text);
			end;
		elseif (info.class == "connect") then
			local filtered = (NX_CONVAR_SHOWAURA:GetInt() == 0) or info.filtered;
			
			openAura.chatBox:Add(filtered, "gui/silkicons/user_add", Color(150, 150, 200, 255), info.text);
		elseif (info.class == "chat") then
			openAura.chatBox:Add(info.filtered, info.icon, Color(225, 50, 50, 255), "[OOC] ", Color(150, 150, 150, 255), name, ": ", info.text);
		else
			local yellowColor = Color(255, 255, 150, 255);
			local blueColor = Color(125, 150, 175, 255);
			local redColor = Color(200, 25, 25, 255);
			local filtered = (NX_CONVAR_SHOWSERVER:GetInt() == 0) or info.filtered;
			local prefix;
			
			openAura.chatBox:Add(filtered, nil, yellowColor, info.text);
		end;
	end;
end;

-- A function to add and wrap text to a message.
function openAura.chatBox:WrappedText(newLine, message, color, text)
	local chatBoxTextFont = openAura.option:GetFont("chat_box_text");
	local maximumWidth = ScrW() * 0.75;
	local singleWidth = openAura:GetTextSize(chatBoxTextFont, "U");
	local width = openAura:GetTextSize(chatBoxTextFont, text);
	
	if (message.currentWidth + width > maximumWidth) then
		local characters = math.ceil( (maximumWidth - message.currentWidth) / singleWidth ) + 1;
		local secondText = string.sub(text, characters + 1);
		local firstText = string.sub(text, 0, characters);
		
		if (firstText and firstText != "") then
			openAura.chatBox:WrappedText(true, message, color, firstText);
		end;
		
		if (secondText and secondText != "") then
			openAura.chatBox:WrappedText(nil, message, color, secondText);
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
function openAura.chatBox:Paint()
	local menuTextTinyFont = openAura.option:GetFont("menu_text_tiny");
	local chatBoxTextFont = openAura.option:GetFont("chat_box_text");
	local isOpen = openAura.chatBox:IsOpen();
	
	openAura:OverrideMainFont(chatBoxTextFont);
		if ( !self.spaceWidths[chatBoxTextFont] ) then
			self.spaceWidths[chatBoxTextFont] = openAura:GetTextSize(chatBoxTextFont, " ");
		end;
		
		local isTypingCommand = openAura.chatBox:IsTypingCommand();
		local chatBoxSpacing = openAura.chatBox:GetSpacing();
		local maximumLines = math.Clamp(NX_CONVAR_MAXCHATLINES:GetInt(), 1, 10);
		local origX, origY = openAura.chatBox:GetPosition(4);
		local spaceWidth = self.spaceWidths[chatBoxTextFont];
		local fontHeight = chatBoxSpacing - 4;
		local messages = self.messages;
		local x, y = origX, origY;
		local box = {width = 0, height = 0};

		if (!isOpen) then
			if (#self.historyMessages > 100) then
				local amount = #self.historyMessages - 100;
				
				for i = 1, amount do
					table.remove(self.historyMessages, 1);
				end;
			end;
		else
			messages = {};
			
			for i = 0, (maximumLines - 1) do
				messages[#messages + 1] = self.historyMessages[self.historyPosition - i];
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
				surface.SetTexture( surface.GetTextureID(v.icon) );
				surface.SetDrawColor(255, 255, 255, alpha);
				surface.DrawTexturedRect(messageX, messageY + (fontHeight / 2) - 8, 16, 16);
				
				messageX = messageX + 16 + spaceWidth;
			end;
			
			for k2, v2 in pairs(v.text) do
				local textColor = Color(v2.color.r, v2.color.g, v2.color.b, alpha);
				local newLine = false;
				
				openAura:DrawSimpleText(v2.text, messageX, messageY, textColor);
				
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
	openAura:OverrideMainFont(false);
	
	if (isTypingCommand) then
		local currentText = openAura.chatBox:GetCurrentText();
		local colorWhite = openAura.option:GetColor("white");
		local commands = {};
		local oX, oY = origX, origY;
		local command = string.Explode( " ", string.sub(currentText, 2) )[1];
		local prefix = openAura.config:Get("command_prefix"):Get();
		
		if (command) then
			for k, v in pairs(openAura.command.stored) do
				if ( string.sub( k, 1, string.len(command) ) == string.lower(command) ) then
					if ( openAura.player:HasFlags(openAura.Client, v.access) ) then
						commands[#commands + 1] = v;
					end;
				end;
				
				if (#commands == 4) then
					break;
				end;
			end;
			
			if (#commands > 0) then
				local singleCommand = (#commands == 1);
				
				openAura:OverrideMainFont(menuTextTinyFont);
					for k, v in ipairs(commands) do
						local totalText = prefix..v.name;
						
						if (singleCommand) then
							totalText = totalText.." "..v.text;
						end;
						
						local tWidth, tHeight = openAura:GetCachedTextSize(menuTextTinyFont, totalText);
						
						if (k == 1) then
							oY = oY - tHeight;
						end;
						
						openAura:DrawSimpleText(totalText, oX, oY, colorWhite);
						
						if (k < #commands) then oY = oY - tHeight; end;
						if (oY < y) then y = oY; end;
						
						if (origY - oY > box.height) then
							box.height = origY - oY;
						end;
						
						if (origX + tWidth - 8 > box.width) then
							box.width = origX + tWidth - 8;
						end;
					end;
				openAura:OverrideMainFont(false);
			end;
		end;
	end;
	
	self.scroll:SetSize(box.width + 8, box.height + 8);
	self.scroll:SetPos(x - 4, y - 4);
end;

-- A function to add a message to the chat box.
function openAura.chatBox:Add(filtered, icon, ...)
	if (ScrW() == 160 or ScrH() == 27) then
		return;
	end;
	
	if (!filtered) then
		local maximumLines = math.Clamp(NX_CONVAR_MAXCHATLINES:GetInt(), 1, 10);
		local colorWhite = openAura.option:GetColor("white");
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
		
		local currentColor = nil;
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
					openAura.chatBox:WrappedText( nil, message, currentColor or colorWhite, tostring(v) );
					currentColor = nil;
				elseif (type(v) == "Player") then
					openAura.chatBox:WrappedText( nil, message, _team.GetColor( v:Team() ), v:Name() );
					currentColor = nil;
				elseif (type(v) == "table") then
					currentColor = Color(v.r or 255, v.g or 255, v.b or 255);
				end;
			end;
		end;
		
		if (self.historyPosition == #self.historyMessages) then
			self.historyPosition = #self.historyMessages + 1;
		end;
		
		self.historyMessages[#self.historyMessages + 1] = message;
		
		if (#self.messages == maximumLines) then
			table.remove(self.messages, maximumLines);
		end;
		
		table.insert(self.messages, 1, message);
		
		surface.PlaySound("common/talk.wav");
		
		openAura:PrintColoredText(...);
	end;
end;

hook.Add("PlayerBindPress", "openAura.chatBox:PlayerBindPress", function(player, bind, press)
	if ( ( string.find(bind, "messagemode") or string.find(bind, "messagemode2") ) and press ) then
		if ( openAura.Client:HasInitialized() ) then
			openAura.chatBox.panel:Show();
		end;
		
		return true;
	end;
end);

hook.Add("Think", "openAura.chatBox:Think", function()
	local curTime = UnPredictedCurTime();
	
	for k, v in ipairs(openAura.chatBox.messages) do
		if (curTime >= v.timeFade) then
			local fadeTime = v.timeFinish - v.timeFade;
			local timeLeft = v.timeFinish - curTime;
			local alpha = math.Clamp( (255 / fadeTime) * timeLeft, 0, 255 );
			
			if (alpha == 0) then
				table.remove(openAura.chatBox.messages, k);
			else
				v.alpha = alpha;
			end;
		end;
	end;
end);