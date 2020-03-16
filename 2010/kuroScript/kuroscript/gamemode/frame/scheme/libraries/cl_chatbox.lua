--[[
name: "cl_chatbox.lua".
Product: "kuroScript".
--]]

kuroScript.chatBox = {};
kuroScript.chatBox.classes = {};
kuroScript.chatBox.messages = {};
kuroScript.chatBox.spaceWidths = {};
kuroScript.chatBox.historyPosition = 0;
kuroScript.chatBox.historyMessages = {};

-- Set some information.
chat.KuroScriptAddText = chat.AddText;

-- A function to add text to the chat box.
function chat.AddText(...)
	local currentColor;
	local text = {};
	local k, v;
	
	-- Loop through each value in a table.
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
	
	-- Add a chat box message.
	kuroScript.chatBox.Add( nil, nil, unpack(text) );
end;

-- Hook a user message.
usermessage.Hook("ks_ChatBoxDeathCode", function(msg)
	local code = msg:ReadLong();
	
	-- Check if a statement is true.
	if ( kuroScript.chatBox.IsOpen() ) then
		local text = kuroScript.chatBox.textEntry:GetValue();
		
		-- Check if a statement is true.
		if (text != "") then
			if (string.sub(text, 1, 2) != "//" and string.sub(text, 1, 3) != ".//") then
				RunConsoleCommand("ks_deathcode", code);
				
				-- Set some information.
				kuroScript.chatBox.textEntry:SetRealValue(string.sub(text, 0, string.len(text) - 1).."-");
				kuroScript.chatBox.textEntry:OnEnter();
			end;
		end;
	end;
end);

-- Hook a data stream.
datastream.Hook("ks_ChatBoxPlayerMessage", function(handler, uniqueID, rawData, procData)
	if ( procData.speaker:IsPlayer() ) then
		kuroScript.chatBox.Decode(procData.speaker, procData.speaker:Name(), procData.text, procData.data, procData.class);
	end;
end);

-- Hook a data stream.
datastream.Hook("ks_ChatBoxMessage", function(handler, uniqueID, rawData, procData)
	kuroScript.chatBox.Decode(nil, nil, procData.text, procData.data, procData.class);
end);

-- A function to register a chat box class.
function kuroScript.chatBox.RegisterClass(class, filter, callback)
	kuroScript.chatBox.classes[class] = {
		callback = callback,
		filter = filter
	};
end;

-- A function to get the position of the chat area.
function kuroScript.chatBox.GetPosition()
	local x, y = 8, ScrH() - (ScrH() / 4);
	
	-- Check if a statement is true.
	if (kuroScript.chatBox.position) then
		x = kuroScript.chatBox.position.x;
		y = kuroScript.chatBox.position.y;
	end;
	
	-- Return the x and y position.
	return x, y;
end;

-- A function to get the x position of the chat area.
function kuroScript.chatBox.GetX()
	local x, y = kuroScript.chatBox.GetPosition();
	
	-- Return the x position.
	return x;
end;

-- A function to get the y position of the chat area.
function kuroScript.chatBox.GetY()
	local x, y = kuroScript.chatBox.GetPosition();
	
	-- Return the y position.
	return y;
end;

-- A function to get the spacing between messages.
function kuroScript.chatBox.GetSpacing() return 20; end;

-- A function to create all of the derma.
function kuroScript.chatBox.CreateDermaAll()
	kuroScript.chatBox.CreateDermaPanel();
	kuroScript.chatBox.CreateDermaTextEntry();

	-- Hide the main chat panel.
	kuroScript.chatBox.panel.Hide();
end;

-- A function to create a derma text entry.
function kuroScript.chatBox.CreateDermaTextEntry()
	if (!kuroScript.chatBox.textEntry) then
		kuroScript.chatBox.textEntry = vgui.Create("DTextEntry", kuroScript.chatBox.panel);
		kuroScript.chatBox.textEntry:SetPos(34, 4);
		kuroScript.chatBox.textEntry:SetTabPosition(1);
		
		-- Called each frame.
		function kuroScript.chatBox.textEntry:Think()
			local text = self:GetValue();
			
			-- Check if a statement is true.
			if (string.len(text) > 126) then
				self:SetRealValue( string.sub(text, 0, 126) );
				
				-- Play a sound.
				surface.PlaySound("common/talk.wav");
			elseif ( kuroScript.chatBox.IsOpen() ) then
				if (text != self.previousText) then
					hook.Call("ChatBoxTextChanged", kuroScript.frame, self.previousText or "", text);
				end;
			end;
			
			-- Set some information.
			self.previousText = text;
		end;
		
		-- Called when enter has been pressed.
		function kuroScript.chatBox.textEntry:OnEnter()
			local text = self:GetValue();
			
			-- Check if a statement is true.
			if (text and text != "") then
				kuroScript.chatBox.historyPosition = #kuroScript.chatBox.historyMessages;
				
				-- Run a console command.
				RunConsoleCommand( "say", string.Replace(text, "\"", "~") );
				
				-- Call a gamemode hook.
				hook.Call("ChatBoxTextTyped", kuroScript.frame, text);
				
				-- Set some information.
				self:SetRealValue("");
			end;
			
			-- Check if a statement is true.
			if (text and text != "") then
				kuroScript.chatBox.panel.Hide(true);
			else
				kuroScript.chatBox.panel.Hide();
			end;
		end;
		
		-- A function to set the text entry's real value.
		function kuroScript.chatBox.textEntry:SetRealValue(text, limit)
			self:SetValue(text);
			
			-- Check if a statement is true.
			if (limit) then
				if ( self:GetCaretPos() > string.len(text) ) then
					self:SetCaretPos( string.len(text) );
				end;
			else
				self:SetCaretPos( string.len(text) );
			end;
		end;
		
		-- Called when a key code has been typed.
		function kuroScript.chatBox.textEntry:OnKeyCodeTyped(code)
			if ( code == KEY_ENTER and !self:IsMultiline() and self:GetEnterAllowed() ) then
				self:FocusNext(); self:OnEnter();
			elseif (code == KEY_TAB) then
				local text = self:GetValue();
				local prefix = kuroScript.config.Get("command_prefix"):Get();
				
				-- Check if a statement is true.
				if (string.sub( text, 1, string.len(prefix) ) == prefix) then
					local exploded = kuroScript.frame:ExplodeString(" ", text);
					
					-- Check if a statement is true.
					if ( !exploded[2] ) then
						local commands = kuroScript.frame:GetSortedCommands();
						local command = string.sub(exploded[1], string.len(prefix) + 1);
						local useNext;
						local first;
						local k, v;
						
						-- Set some information.
						command = string.lower(command);
						
						-- Loop through each value in a table.
						for k, v in pairs(commands) do
							v = string.lower(v);
							
							-- Check if a statement is true.
							if (!first) then first = v; end;
							
							-- Check if a statement is true.
							if ( (string.len(command) < string.len(v) and string.find(v, command) == 1) or useNext ) then
								self:SetRealValue(prefix..v); return;
							elseif ( v == string.lower(command) ) then
								useNext = true;
							end
						end
						
						-- Check if a statement is true.
						if (useNext and first) then
							self:SetRealValue(prefix..first); return;
						end
					end;
				end;
				
				-- Set some information.
				text = hook.Call("OnChatTab", kuroScript.frame, text);
				
				-- Check if a statement is true.
				if (text and type(text) == "string") then
					self:SetRealValue(text)
				end;
			else
				local text = hook.Call( "ChatBoxKeyCodeTyped", kuroScript.frame, code, self:GetValue() );
				
				-- Check if a statement is true.
				if (text and type(text) == "string") then
					self:SetRealValue(text)
				end;
			end;
		end;
	end;
end;

-- A function to create the derma panel.
function kuroScript.chatBox.CreateDermaPanel()
	if (!kuroScript.chatBox.panel) then
		kuroScript.chatBox.panel = vgui.Create("EditablePanel");
		
		-- A function to show the chat panel.
		kuroScript.chatBox.panel.Show = function()
			kuroScript.chatBox.panel:SetKeyboardInputEnabled(true);
			kuroScript.chatBox.panel:SetMouseInputEnabled(true);
			kuroScript.chatBox.panel:SetVisible(true);
			kuroScript.chatBox.panel:MakePopup();
			
			-- Set some information.
			kuroScript.chatBox.textEntry:RequestFocus();
			kuroScript.chatBox.scroll:SetVisible(true);
			
			-- Set some information.
			kuroScript.chatBox.historyPosition = #kuroScript.chatBox.historyMessages;
			
			-- Call a gamemode hook.
			hook.Call("ChatBoxOpened", kuroScript.frame);
		end;
		
		-- A function to hide the chat panel.
		kuroScript.chatBox.panel.Hide = function(textTyped)
			kuroScript.chatBox.panel:SetKeyboardInputEnabled(false);
			kuroScript.chatBox.panel:SetMouseInputEnabled(false);
			kuroScript.chatBox.panel:SetVisible(false);
			
			-- Set some information.
			kuroScript.chatBox.textEntry:SetText("");
			kuroScript.chatBox.scroll:SetVisible(false);
			
			-- Call a gamemode hook.
			hook.Call("ChatBoxClosed", kuroScript.frame, textTyped);
		end;
		
		-- Called each time the panel should be painted.
		function kuroScript.chatBox.panel:Paint()
			local backgroundColor = COLOR_BACKGROUND;
			local foregroundColor = COLOR_FOREGROUND;
			local cornerSize = 4;
			
			-- Draw some rounded boxes.
			draw.RoundedBox(cornerSize, 0, 0, self:GetWide(), self:GetTall(), backgroundColor);
			draw.RoundedBox(cornerSize, 2, 2, self:GetWide() - 4, self:GetTall() - 4, foregroundColor);
		end;
		
		-- Called eveyr frame.
		function kuroScript.chatBox.panel:Think()
			local panelWidth = ScrW() / 4;
			local x, y = kuroScript.chatBox.GetPosition();
			
			-- Set some information.
			kuroScript.chatBox.panel:SetPos(x, y + 6);
			kuroScript.chatBox.panel:SetSize(panelWidth + 8, 24);
			kuroScript.chatBox.textEntry:SetPos(4, 4);
			kuroScript.chatBox.textEntry:SetSize(panelWidth, 16);
			
			-- Check if a statement is true.
			if ( self:IsVisible() and input.IsKeyDown(KEY_ESCAPE) ) then
				kuroScript.chatBox.panel.Hide();
			end;
		end;
		
		-- Set some information.
		kuroScript.chatBox.scroll = vgui.Create("Panel");
		kuroScript.chatBox.scroll:SetPos(0, 0);
		kuroScript.chatBox.scroll:SetSize(0, 0);
		
		-- Called when the panel is scrolled with the mouse wheel.
		function kuroScript.chatBox.scroll:OnMouseWheeled(delta)
			local isOpen = kuroScript.chatBox.IsOpen();
			local maximumLines = math.Clamp(KS_CONVAR_MAXCHATLINES:GetInt(), 1, 8);
			
			-- Check if a statement is true.
			if (isOpen) then
				if (delta > 0) then
					delta = math.Clamp(delta, 1, maximumLines);
					
					-- Check if a statement is true.
					if ( kuroScript.chatBox.historyMessages[kuroScript.chatBox.historyPosition - maximumLines] ) then
						kuroScript.chatBox.historyPosition = kuroScript.chatBox.historyPosition - delta;
					end;
				else
					if ( !kuroScript.chatBox.historyMessages[kuroScript.chatBox.historyPosition - delta] ) then
						delta = -1;
					end;
					
					-- Check if a statement is true.
					if ( kuroScript.chatBox.historyMessages[kuroScript.chatBox.historyPosition - delta] ) then
						kuroScript.chatBox.historyPosition = kuroScript.chatBox.historyPosition - delta;
					end;
				end;
			end;
		end;
	end;
end;

-- A function to get whether the chat box is open.
function kuroScript.chatBox.IsOpen()
	return kuroScript.chatBox.panel and kuroScript.chatBox.panel:IsVisible();
end;

-- A function to decode a message.
function kuroScript.chatBox.Decode(speaker, name, text, data, class)
	local filtered = nil;
	local filter;
	local icon;
	
	-- Check if a statement is true.
	if ( kuroScript.chatBox.classes[class] ) then
		filter = kuroScript.chatBox.classes[class].filter;
	elseif (class == "pm" or class == "ooc" or class == "looc") then
		filtered = (KS_CONVAR_SHOWOOC:GetInt() == 0);
		filter = "ooc";
	else
		filtered = (KS_CONVAR_SHOWIC:GetInt() == 0);
		filter = "ic";
	end;
	
	-- Set some information.
	text = string.Replace(text, " ' ", "'");
	
	-- Check if a statement is true.
	if ( ValidEntity(speaker) ) then
		if ( !kuroScript.frame:IsChoosingCharacter() ) then
			if (speaker:Name() != "") then
				local vocationIndex = speaker:Team();
				local vocationColor = g_Team.GetColor(vocationIndex);
				local anonymous;
				
				-- Check if a statement is true.
				if ( speaker:IsSuperAdmin() ) then
					icon = {"gui/silkicons/shield", "^"};
				elseif ( speaker:IsAdmin() ) then
					icon = {"gui/silkicons/star", "*"};
				elseif ( speaker:IsUserGroup("operator") ) then
					icon = {"gui/silkicons/emoticon_smile", "@"};
				else
					local class = kuroScript.player.GetClass(speaker);
					
					-- Check if a statement is true.
					if ( class and kuroScript.class.stored[class] ) then
						if (kuroScript.class.stored[class].whitelist) then
							icon = {"gui/silkicons/add", "+"};
						end;
					end;
					
					-- Check if a statement is true.
					if (!icon) then
						icon = {"gui/silkicons/user", "-"};
					end;
				end;
				
				-- Check if a statement is true.
				if (!kuroScript.player.KnowsPlayer(speaker, KNOWN_TOTAL) and filter == "ic") then
					anonymous = true;
				end;
				
				-- Set some information.
				local info = {
					anonymous = anonymous,
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
				
				-- Call a gamemode hook.
				hook.Call("ChatBoxAdjustInfo", kuroScript.frame, info);
				
				-- Check if a statement is true.
				if (!info.visible) then
					return;
				end;
				
				-- Check if a statement is true.
				if (info.filter == "ic") then
					if ( !g_LocalPlayer:Alive() ) then
						return;
					end;
				end;
				
				-- Check if a statement is true.
				if (info.anonymous) then
					info.name = kuroScript.config.Get("anonymous_name"):Get();
				end;
				
				-- Check if a statement is true.
				if ( kuroScript.chatBox.classes[info.class] ) then
					kuroScript.chatBox.classes[info.class].callback(info);
				elseif (info.class == "radio_eavesdrop") then
					kuroScript.chatBox.Add(info.filtered, nil, "(Radio) ", Color(255, 255, 150, 255), info.name..": "..info.text);
				elseif (info.class == "whisper") then
					kuroScript.chatBox.Add(info.filtered, nil, "(Whisper) ", Color(255, 255, 150, 255), info.name..": "..info.text);
				elseif (info.class == "me_info") then
					if (string.sub(info.text, 1, 1) == "'") then
						kuroScript.chatBox.Add(info.filtered, nil, "(Info) ", Color(255, 255, 150, 255), "** "..info.name..info.text);
					else
						kuroScript.chatBox.Add(info.filtered, nil, "(Info) ", Color(255, 255, 150, 255), "** "..info.name.." "..info.text);
					end;
				elseif (info.class == "event") then
					kuroScript.chatBox.Add(info.filtered, nil, "(Event) ", Color(200, 100, 50, 255), info.text);
				elseif (info.class == "radio") then
					kuroScript.chatBox.Add(info.filtered, nil, "(Radio) ", Color(75, 150, 50, 255), info.name..": "..info.text);
				elseif (info.class == "yell") then
					kuroScript.chatBox.Add(info.filtered, nil, "(Yell) ", Color(255, 255, 150, 255), info.name..": "..info.text);
				elseif (info.class == "info") then
					kuroScript.chatBox.Add(info.filtered, nil, "(Info) ", Color(255, 255, 150, 255), info.name..": "..info.text);
				elseif (info.class == "chat") then
					kuroScript.chatBox.Add(info.filtered, nil, vocationColor, info.name, ": ", info.text, nil, info.filtered);
				elseif (info.class == "looc") then
					kuroScript.chatBox.Add(info.filtered, nil, Color(225, 50, 50, 255), "(Local OOC) ", Color(255, 255, 150, 255), info.name..": "..info.text);
				elseif (info.class == "ooc") then
					kuroScript.chatBox.Add(info.filtered, info.icon, Color(225, 50, 50, 255), "(OOC) ", vocationColor, info.name, ": ", info.text);
				elseif (info.class == "pm") then
					kuroScript.chatBox.Add(info.filtered, nil, "(PM) ", Color(125, 150, 75, 255), info.name..": "..info.text);
				elseif (info.class == "me") then
					if (string.sub(info.text, 1, 1) == "'") then
						kuroScript.chatBox.Add(info.filtered, nil, Color(255, 255, 200, 255), "** "..info.name..info.text);
					else
						kuroScript.chatBox.Add(info.filtered, nil, Color(255, 255, 200, 255), "** "..info.name.." "..info.text);
					end;
				elseif (info.class == "it") then
					kuroScript.chatBox.Add(info.filtered, nil, Color(255, 255, 200, 255), "** "..info.text);
				elseif (info.class == "ic") then
					kuroScript.chatBox.Add(info.filtered, nil, Color(255, 255, 150, 255), info.name..": "..info.text);
				end;
			end;
		end;
	else
		if (name == "Console" and class == "chat") then
			icon = {"gui/silkicons/shield", "^"};
		end;
		
		-- Set some information.
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
		
		-- Call a gamemode hook.
		hook.Call("ChatBoxAdjustInfo", kuroScript.frame, info);
		
		-- Check if a statement is true.
		if (!info.visible) then return; end;
		
		-- Check if a statement is true.
		if ( kuroScript.chatBox.classes[info.class] ) then
			kuroScript.chatBox.classes[info.class].callback(info);
		elseif (info.class == "notify_all") then
			local filtered = (KS_CONVAR_SHOWKUROSCRIPT:GetInt() == 0) or info.filtered;
			
			-- Add a chat box message.
			kuroScript.chatBox.Add(filtered, nil, Color(125, 150, 175, 255), info.text);
		elseif (info.class == "departure") then
			local filtered = (KS_CONVAR_SHOWDEPARTURE:GetInt() == 0) or info.filtered;
			
			-- Add a chat box message.
			kuroScript.chatBox.Add(filtered, nil, Color(225, 150, 75, 255), info.text);
		elseif (info.class == "arrival") then
			local filtered = (KS_CONVAR_SHOWARRIVAL:GetInt() == 0) or info.filtered;
			
			-- Add a chat box message.
			kuroScript.chatBox.Add(filtered, nil, Color(225, 200, 50, 255), info.text);
		elseif (info.class == "notify") then
			local filtered = (KS_CONVAR_SHOWKUROSCRIPT:GetInt() == 0) or info.filtered;
			
			-- Add a chat box message.
			kuroScript.chatBox.Add(filtered, nil, Color(175, 200, 255, 255), info.text);
		elseif (info.class == "chat") then
			kuroScript.chatBox.Add(info.filtered, info.icon, Color(225, 50, 50, 255), "(OOC) ", Color(150, 150, 150, 255), name, ": ", info.text);
		else
			local yellowColor = Color(255, 255, 150, 255);
			local blueColor = Color(125, 150, 175, 255);
			local redColor = Color(200, 25, 25, 255);
			local filtered = (KS_CONVAR_SHOWSERVER:GetInt() == 0) or info.filtered;
			local prefix;
			
			-- Add a chat box message.
			kuroScript.chatBox.Add(filtered, nil, yellowColor, info.text);
		end;
	end;
end;

-- A function to print a message to the console.
function kuroScript.chatBox.Print(message)
	local text = "";
	local k, v;
	
	-- Check if a statement is true.
	if (message.icon) then
		text = text.."("..message.icon[2]..") ";
	end;
	
	-- Loop through each value in a table.
	for k, v in ipairs(message.text) do
		text = text..v.text;
	end;
	
	-- Print the text.
	print(text);
end;

-- A function to add and wrap text to a message.
function kuroScript.chatBox.AddWrappedText(newLine, message, color, text)
	local maximumWidth = ScrW() * 0.75;
	local singleWidth = kuroScript.frame:GetTextSize(FONT_MAIN_TEXT, "U");
	local width = kuroScript.frame:GetTextSize(FONT_MAIN_TEXT, text);
	
	-- Check if a statement is true.
	if (message.currentWidth + width > maximumWidth) then
		local characters = math.ceil( (maximumWidth - message.currentWidth) / singleWidth ) + 1;
		local secondText = string.sub(text, characters + 1);
		local firstText = string.sub(text, 0, characters);
		
		-- Check if a statement is true.
		if (firstText and firstText != "") then
			kuroScript.chatBox.AddWrappedText(true, message, color, firstText);
		end;
		
		-- Check if a statement is true.
		if (secondText and secondText != "") then
			kuroScript.chatBox.AddWrappedText(nil, message, color, secondText);
		end;
	else
		message.text[#message.text + 1] = {
			newLine = newLine,
			width = width,
			color = color,
			text = text
		};
		
		-- Check if a statement is true.
		if (newLine) then
			message.currentWidth = 0;
			message.lines = message.lines + 1;
		else
			message.currentWidth = message.currentWidth + width;
		end;
	end;
end;

-- A function to add a message to the chat box.
function kuroScript.chatBox.Add(filtered, icon, ...)
	if (ScrW() == 160 or ScrH() == 27) then
		return;
	end;
	
	-- Check if a statement is true.
	if (!filtered) then
		local maximumLines = math.Clamp(KS_CONVAR_MAXCHATLINES:GetInt(), 1, 8);
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
		
		-- Set some information.
		local currentColor;
		local text = {...};
		local k, v;
		
		-- Check if a statement is true.
		if (KS_CONVAR_SHOWTIMESTAMPS:GetInt() == 1) then
			local timeInfo = "("..os.date("%H:%M")..") ";
			local color = Color(150, 150, 150, 255);
			
			-- Check if a statement is true.
			if (KS_CONVAR_TWELVEHOURCLOCK:GetInt() == 1) then
				timeInfo = "("..string.lower( os.date("%I:%M%p") )..") ";
			end;
			
			-- Check if a statement is true.
			if (text) then
				table.insert(text, 1, color);
				table.insert(text, 2, timeInfo);
			else
				text = {timeInfo, color};
			end;
		end;
		
		-- Check if a statement is true.
		if (text) then
			message.currentWidth = 0;
			message.text = {};
			
			-- Loop through each value in a table.
			for k, v in ipairs(text) do
				if (type(v) == "string" or type(v) == "number" or type(v) == "boolean") then
					kuroScript.chatBox.AddWrappedText( nil, message, currentColor or COLOR_WHITE, tostring(v) );
					
					-- Set some information.
					currentColor = nil;
				elseif (type(v) == "table") then
					currentColor = Color(v.r or 255, v.g or 255, v.b or 255);
				end;
			end;
		end;
		
		-- Print the message to the console.
		kuroScript.chatBox.Print(message);
		
		-- Check if a statement is true.
		if (kuroScript.chatBox.historyPosition == #kuroScript.chatBox.historyMessages) then
			kuroScript.chatBox.historyPosition = #kuroScript.chatBox.historyMessages + 1;
		end;
		
		-- Set some information.
		kuroScript.chatBox.historyMessages[#kuroScript.chatBox.historyMessages + 1] = message;
		
		-- Check if a statement is true.
		if (#kuroScript.chatBox.messages == maximumLines) then
			table.remove(kuroScript.chatBox.messages, maximumLines);
		end;
		
		-- Insert some information.
		table.insert(kuroScript.chatBox.messages, 1, message);
		
		-- Play a sound.
		surface.PlaySound("common/talk.wav");
	end;
end;

-- Add a hook.
hook.Add("HUDPaintForeground", "kuroScript.chatBox.HUDPaintForeground", function()
	if ( !kuroScript.chatBox.spaceWidths[FONT_MAIN_TEXT] ) then
		kuroScript.chatBox.spaceWidths[FONT_MAIN_TEXT] = kuroScript.frame:GetTextSize(FONT_MAIN_TEXT, " ");
	end;
	
	-- Set some information.
	local maximumLines = math.Clamp(KS_CONVAR_MAXCHATLINES:GetInt(), 1, 8);
	local spaceWidth = kuroScript.chatBox.spaceWidths[FONT_MAIN_TEXT];
	local isOpen = kuroScript.chatBox.IsOpen();
	local messages = kuroScript.chatBox.messages;
	local x, y = kuroScript.chatBox.GetPosition();
	local box = {width = 0, height = 0};
	local i;
	
	-- Check if a statement is true.
	if (isOpen) then
		messages = {};
		
		-- Loop through a range of values.
		for i = 0, (maximumLines - 1) do
			messages[#messages + 1] = kuroScript.chatBox.historyMessages[kuroScript.chatBox.historyPosition - i];
		end;
	elseif (#kuroScript.chatBox.historyMessages > 100) then
		local amount = #kuroScript.chatBox.historyMessages - 100;
		
		-- Loop through a range of values.
		for i = 1, amount do
			table.remove(kuroScript.chatBox.historyMessages, 1);
		end;
	end;
	
	-- Set some information.
	local k2, v2;
	local k, v;
	
	-- Loop through each value in a table.
	for k, v in pairs(messages) do
		if ( messages[k - 1] ) then
			y = y - messages[k - 1].spacing;
		end;
		
		-- Check if a statement is true.
		if (!isOpen and k == 1) then
			y = y - ( (kuroScript.chatBox.GetSpacing() + v.spacing) * (v.lines - 1) ) + 14;
		else
			y = y - ( (kuroScript.chatBox.GetSpacing() + v.spacing) * v.lines );
			
			-- Check if a statement is true.
			if (k == 1) then y = y + 2; end;
		end;
		
		-- Set some information.
		local messageX = x;
		local messageY = y;
		local alpha = v.alpha;
		
		-- Check if a statement is true.
		if (isOpen) then
			alpha = 255;
		end;
		
		-- Check if a statement is true.
		if (v.icon) then
			surface.SetTexture( surface.GetTextureID( v.icon[1] ) );
			surface.SetDrawColor(255, 255, 255, alpha);
			surface.DrawTexturedRect(messageX, messageY - 1, 16, 16);
			
			-- Set some information.
			messageX = messageX + 16 + spaceWidth;
		end;
		
		-- Loop through each value in a table.
		for k2, v2 in pairs(v.text) do
			local textColor = Color(v2.color.r, v2.color.g, v2.color.b, alpha);
			local newLine;
			
			-- Draw some simple text.
			kuroScript.frame:DrawSimpleText(v2.text, messageX, messageY, textColor);
			
			-- Set some information.
			messageX = messageX + v2.width;
			
			-- Check if a statement is true.
			if (kuroScript.chatBox.GetY() - y > box.height) then
				box.height = kuroScript.chatBox.GetY() - y;
			end;
			
			-- Check if a statement is true.
			if (messageX - 8 > box.width) then
				box.width = messageX - 8;
			end;
			
			-- Check if a statement is true.
			if (v2.newLine) then
				messageY = messageY + kuroScript.chatBox.GetSpacing() + v.spacing;
				messageX = x;
			end;
		end;
	end;
	
	-- Set some information.
	kuroScript.chatBox.scroll:SetSize(box.width, box.height);
	kuroScript.chatBox.scroll:SetPos(x, y);
end);

-- Add a hook.
hook.Add("PlayerBindPress", "kuroScript.chatBox.PlayerBindPress", function(player, bind, press)
	if ( (bind == "messagemode" or bind == "messagemode2") and press ) then
		if ( g_LocalPlayer:HasInitialized() ) then
			kuroScript.chatBox.panel.Show();
		end;
		
		-- Return true to break the function.
		return true;
	elseif (bind == "toggleconsole") then
		kuroScript.chatBox.panel.Hide();
	end;
end);

-- Add a hook.
hook.Add("Think", "kuroScript.chatBox.Think", function()
	local curTime = UnPredictedCurTime();
	local k, v;
	
	-- Loop though our messages.
	for k, v in ipairs(kuroScript.chatBox.messages) do
		if (curTime >= v.timeFade) then
			local fadeTime = v.timeFinish - v.timeFade;
			local timeLeft = v.timeFinish - curTime;
			local alpha = math.Clamp( (255 / fadeTime) * timeLeft, 0, 255 );
			
			-- Check if a statement is true.
			if (alpha == 0) then
				table.remove(kuroScript.chatBox.messages, k);
			else
				v.alpha = alpha;
			end;
		end;
	end;
end);

-- Set some information.
kuroScript.chatBox.CreateDermaAll();