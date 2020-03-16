--[[
Name: "cl_autorun.lua".
Product: "HL2 RP".
--]]

kuroScript.game.combineOverlay = Material("effects/combine_binocoverlay");
kuroScript.game.randomDisplayLines = {
	"Transmitting physical transition vector...",
	"Modulating external temperature levels...",
	"Parsing view ports and data arrays...",
	"Translating Protocol practicalities...",
	"Updating unit co-ordinates...",
	"Parsing Nexus protocol messages...",
	"Downloading recent dictionaries...",
	"Pinging connection to network...",
	"Updating mainframe connection...",
	"Synchronizing locational data...",
	"Translating radio messages...",
	"Emptying outgoing pipes...",
	"Sensoring proximity...",
	"Pinging loopback...",
	"Idle connection..."
};

-- Include some prefixed files.
kuroScript.frame:IncludePrefixed("sh_autorun.lua");

-- Add some settings.
kuroScript.setting.AddMultiChoice("HL2 RP", "Donator Icon", "ks_donatoricon", {
	"Exclamation",
	"Speaker",
	"Recycle",
	"Anchor",
	"Wrench",
	"Group",
	"Heart",
	"Bomb",
	"Car"
}, "Choose an icon to have next to your name out-of-character.", function()
	return g_LocalPlayer:GetSharedVar("ks_Donator");
end);

-- Add some settings.
kuroScript.setting.AddCheckBox("HL2 RP", "Hide Display", "ks_hidedisplay", "Whether or not to hide your head-up display.");

-- Add some HTML directory categories.
kuroScript.directory.AddHTMLCategory("Storyline and Timeline", "HL2 RP", "", true);
kuroScript.directory.AddHTMLCategory("The Digital Soul RP", "Community", "http://thedigitalsoul.net", true);
kuroScript.directory.AddHTMLCategory("DSRP Blog", "Community", "http://thedigitalsoul.net/woot/", true);

-- Add some directory categories.
kuroScript.directory.AddCategory("Dispatch Voices", "Voice Commands");
kuroScript.directory.AddCategory("Combine Voices", "Voice Commands");
kuroScript.directory.AddCategory("Voice Commands", "Commands");

-- Sort some tables.
table.sort(kuroScript.game.voices, function(a, b) return a.command < b.command; end);
table.sort(kuroScript.game.dispatchVoices, function(a, b) return a.command < b.command; end);

-- Hook a data stream.
datastream.Hook("ks_RebuildBusiness", function(handler, uniqueID, rawData, procData)
	if (kuroScript.menu.GetOpen() and kuroScript.game.businessPanel) then
		if (kuroScript.menu.GetActiveTab() == kuroScript.game.businessPanel) then
			kuroScript.game.businessPanel:Rebuild();
		end;
	end;
end);

-- Hook a data stream.
datastream.Hook("ks_EditObjectives", function(handler, uniqueID, rawData, procData)
	if ( kuroScript.game.objectivesPanel and kuroScript.game.objectivesPanel:IsValid() ) then
		kuroScript.game.objectivesPanel:Close();
		kuroScript.game.objectivesPanel:Remove();
	end;
	
	-- Set some information.
	kuroScript.game.objectivesPanel = vgui.Create("ks_Objectives");
	kuroScript.game.objectivesPanel:Populate(procData or "");
	kuroScript.game.objectivesPanel:MakePopup();
	
	-- Enable the screen clicker.
	gui.EnableScreenClicker(true);
end);

-- Hook a data stream.
datastream.Hook("ks_EditStaffData", function(handler, uniqueID, rawData, procData)
	if ( kuroScript.game.staffDataPanel and kuroScript.game.staffDataPanel:IsValid() ) then
		kuroScript.game.staffDataPanel:Close();
		kuroScript.game.staffDataPanel:Remove();
	end;
	
	-- Set some information.
	kuroScript.game.staffDataPanel = vgui.Create("ks_StaffData");
	kuroScript.game.staffDataPanel:Populate(procData or "");
	kuroScript.game.staffDataPanel:MakePopup();
	
	-- Enable the screen clicker.
	gui.EnableScreenClicker(true);
end);

-- Hook a data stream.
datastream.Hook("ks_EditData", function(handler, uniqueID, rawData, procData)
	if ( ValidEntity( procData[1] ) ) then
		if ( kuroScript.game.dataPanel and kuroScript.game.dataPanel:IsValid() ) then
			kuroScript.game.dataPanel:Close();
			kuroScript.game.dataPanel:Remove();
		end;
		
		-- Set some information.
		kuroScript.game.dataPanel = vgui.Create("ks_Data");
		kuroScript.game.dataPanel:Populate(procData[1], procData[2] or "");
		kuroScript.game.dataPanel:MakePopup();
		
		-- Enable the screen clicker.
		gui.EnableScreenClicker(true);
	end;
end);

-- Hook a user message.
usermessage.Hook("ks_Stunned", function(msg)
	local duration = msg:ReadFloat();
	local curTime = CurTime();
	
	-- Check if a statement is true.
	if (!duration or duration == 0) then
		duration = 2;
	end;
	
	-- Set some information
	if (!kuroScript.game.stunEffects) then
		kuroScript.game.stunEffects = {};
	end;
	
	-- Set some information.
	kuroScript.game.stunEffects[#kuroScript.game.stunEffects + 1] = {curTime + duration, duration};
	kuroScript.game.flashEffect = {curTime + (duration * 2), duration * 2};
end);

-- Hook a user message.
usermessage.Hook("ks_Flashed", function(msg)
	local curTime = CurTime();
	
	-- Check if a statement is true.
	if (!kuroScript.game.stunEffects) then
		kuroScript.game.stunEffects = {};
	end;
	
	-- Set some information.
	kuroScript.game.stunEffects[#kuroScript.game.stunEffects + 1] = {curTime + 10, 10};
	kuroScript.game.flashEffect = {curTime + 20, 20};
	
	-- Play a sound.
	surface.PlaySound("hl1/fvox/flatline.wav");
end);

-- Hook a user message.
usermessage.Hook("ks_TearGassed", function(msg)
	local curTime = CurTime();
	
	-- Set some information.
	kuroScript.game.tearGassed = curTime + 20;
end);

-- Hook a user message.
usermessage.Hook("ks_ClearEffects", function(msg)
	kuroScript.game.stunEffects = nil;
	kuroScript.game.flashEffect = nil;
	kuroScript.game.tearGassed = nil;
end);

-- Hook a data stream.
datastream.Hook("ks_CombineDisplayLine", function(handler, uniqueID, rawData, procData)
	kuroScript.game:AddCombineDisplayLine( procData[1], procData[2] );
end);

-- Register a chat box class.
kuroScript.chatBox.RegisterClass("request_eavesdrop", "ic", function(info)
	kuroScript.chatBox.Add(info.filtered, nil, "(Request) ", Color(255, 255, 150, 255), info.name..": "..info.text);
end);

-- Register a chat box class.
kuroScript.chatBox.RegisterClass("radio_stationary", "ic", function(info)
	if (info.data.freq) then
		kuroScript.chatBox.Add(info.filtered, nil, "(Stationary Radio - "..info.data.freq..") ", Color(255, 255, 150, 255), info.name..": "..info.text);
	else
		kuroScript.chatBox.Add(info.filtered, nil, "(Stationary Radio) ", Color(255, 255, 150, 255), "Anonymous: "..info.text);
	end;
end);

-- Register a chat box class.
kuroScript.chatBox.RegisterClass("broadcast", "ic", function(info)
	kuroScript.chatBox.Add(info.filtered, nil, "(Broadcast) ", Color(150, 125, 175, 255), info.name..": "..info.text);
end);

-- Register a chat box class.
kuroScript.chatBox.RegisterClass("dispatch", "ic", function(info)
	kuroScript.chatBox.Add(info.filtered, nil, "(Dispatch) ", Color(150, 100, 100, 255), info.text);
end);

-- Register a chat box class.
kuroScript.chatBox.RegisterClass("radio", "ic", function(info)
	if (info.data.freq) then
		kuroScript.chatBox.Add(info.filtered, nil, "(Radio - "..info.data.freq..") ", Color(75, 150, 50, 255), info.name..": "..info.text);
	else
		kuroScript.chatBox.Add(info.filtered, nil, "(Radio) ", Color(75, 150, 50, 255), "Anonymous: "..info.text);
	end;
end);

-- Register a chat box class.
kuroScript.chatBox.RegisterClass("request", "ic", function(info)
	kuroScript.chatBox.Add(info.filtered, nil, "(Request) ", Color(175, 125, 100, 255), info.name..": "..info.text);
end);

-- A function to get a player's scanner entity.
function kuroScript.game:GetScannerEntity(player)
	local scannerEntity = player:GetSharedVar("ks_Scanner");
	
	-- Check if a statement is true.
	if ( ValidEntity(scannerEntity) ) then
		return scannerEntity;
	end;
end;

-- A function to get whether a text entry is being used.
function kuroScript.game:IsTextEntryBeingUsed()
	if (self.textEntryFocused) then
		if ( self.textEntryFocused:IsValid() and self.textEntryFocused:IsVisible() ) then
			return true;
		end;
	end;
end;

-- A function to add a Combine display line.
function kuroScript.game:AddCombineDisplayLine(text, color)
	if ( self:PlayerIsCombine(g_LocalPlayer) ) then
		if (!self.combineDisplayLines) then
			self.combineDisplayLines = {};
		end;
		
		-- Insert some information.
		table.insert( self.combineDisplayLines, {"<:: "..text, CurTime() + 8, 5, color} );
	end;
end;

-- A function to get whether a player is Combine.
function kuroScript.game:PlayerIsCombine(player, human)
	local class = kuroScript.player.GetClass(player);
	
	-- Check if a statement is true.
	if ( self:IsCombineClass(class) ) then
		if (human) then
			if (class == CLASS_CPA) then
				return true;
			end;
		elseif (human == false) then
			if (class == CLASS_CPA) then
				return false;
			else
				return true;
			end;
		else
			return true;
		end;
	end;
end;