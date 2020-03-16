--[[
Name: "cl_autorun.lua".
Product: "kuroScript".
--]]

include("sh_autorun.lua");

-- Set some information.
g_LocalPlayer = LocalPlayer();

-- Set some information.
surface.CreateFont("Arial", 60, 700, true, true, "ks_IntroTextBig");
surface.CreateFont("Arial", 25, 700, true, true, "ks_IntroTextSmall");
surface.CreateFont("Trebuchet", 30, 700, true, true, "ks_CinematicText");

-- Set some information.
local g_Player = g_Player;
local g_Team = g_Team;
local g_File = g_File;

-- Set some information.
local CurTime = CurTime;
local hook = hook;

-- Set some information.
hook.KuroScriptCall = hook.Call;

-- A function to call a hook.
function hook.Call(name, gamemode, ...)
	if (!gamemode) then
		gamemode = kuroScript.frame;
	end;
	
	-- Set some information.
	local arguments = {...};
	local value = kuroScript.mount.CallCachedHook(name, arguments);
	
	-- Check if a statement is true.
	if (value == nil) then
		return hook.KuroScriptCall( name, gamemode, unpack(arguments) );
	else
		return value;
	end;
end;

-- Set some information.
local KuroScriptAddWorldTip = AddWorldTip;
local KuroScriptScrW = ScrW;
local KuroScriptScrH = ScrH;

-- A function to add a world tip.
function AddWorldTip(entIndex, text, dieTime, position, entity)
	local weapon = g_LocalPlayer:GetActiveWeapon();
	
	-- Check if a statement is true.
	if ( ValidEntity(weapon) ) then
		if (string.lower( weapon:GetClass() ) == "gmod_tool") then
			if (ValidEntity(entity) and entity.GetPlayerName) then
				if ( g_LocalPlayer:Name() == entity:GetPlayerName() ) then
					KuroScriptAddWorldTip(entIndex, text, dieTime, position, entity);
				end;
			end;
		end;
	end;
end;

-- A function to get the screen width.
function ScrW()
	local width = KuroScriptScrW();
	
	-- Check if a statement is true.
	if (width == 160) then
		return kuroScript.frame.LastScreenWidth or width;
	else
		kuroScript.frame.LastScreenWidth = width;
		
		-- Return the width;
		return width;
	end;
end

-- A function to get the screen height.
function ScrH()
	local height = KuroScriptScrH();
	
	-- Check if a statement is true.
	if (height == 27) then
		return kuroScript.frame.LastScreenHeight or height;
	else
		kuroScript.frame.LastScreenHeight = height;
		
		-- Return the height;
		return height;
	end;
end

-- Hook a data stream.
datastream.Hook("ks_RunCommand", function(handler, uniqueID, rawData, procData)
	RunConsoleCommand( unpack(procData) );
end);

-- Hook a data stream.
datastream.Hook("ks_HiddenCommands", function(handler, uniqueID, rawData, procData)
	local k2, v2;
	local k, v;
	
	-- Loop through each value in a table.
	for k, v in pairs(procData) do
		for k2, v2 in pairs(kuroScript.command.stored) do
			if (kuroScript.frame:GetShortCRC(k2) == v) then
				kuroScript.command.SetHidden(k2, true);
				
				-- Break the loop.
				break;
			end;
		end;
	end;
end);

-- Hook a user message.
usermessage.Hook("ks_QuizCompleted", function(msg)
	if ( msg:ReadBool() ) then
		kuroScript.quiz.SetCompleted(true);
		
		-- Check if a statement is true.
		if ( kuroScript.quiz.panel and kuroScript.quiz.panel:IsValid() ) then
			kuroScript.quiz.panel:Remove();
		end;
	elseif ( !kuroScript.quiz.GetCompleted() ) then
		gui.EnableScreenClicker(true);
		
		-- Set some information.
		kuroScript.quiz.panel = vgui.Create("ks_Quiz");
		kuroScript.quiz.panel:Populate();
		kuroScript.quiz.panel:MakePopup();
	end;
end);

-- Hook a user message.
usermessage.Hook("ks_HideCommand", function(msg)
	local index = msg:ReadLong();
	local k, v;

	-- Loop through each value in a table.
	for k, v in pairs(kuroScript.command.stored) do
		if (kuroScript.frame:GetShortCRC(k) == index) then
			kuroScript.command.SetHidden( k, msg:ReadBool() );
			
			-- Break the loop.
			break;
		end;
	end;
end);

-- Hook a user message.
usermessage.Hook("ks_ClearKnownNames", function(msg)
	kuroScript.frame.KnownNames = {};
end);

-- Hook a user message.
usermessage.Hook("ks_KnownName", function(msg)
	local key = msg:ReadLong();
	local status = msg:ReadShort();
	
	-- Check if a statement is true.
	if (status > 0) then
		kuroScript.frame.KnownNames[key] = status;
	else
		kuroScript.frame.KnownNames[key] = nil;
	end;
end);

-- Hook a user message.
usermessage.Hook("ks_Details", function(msg)
	Derma_StringRequest("Details", "What do you want your details to be?", g_LocalPlayer:GetSharedVar("ks_Details"), function(text)
		RunConsoleCommand("ks", "details", text);
	end);
end);

-- Hook a data stream.
datastream.Hook("ks_Alert", function(handler, uniqueID, rawData, procData)
	kuroScript.frame:AddAlert(procData.text, procData.color);
end);

-- Hook a data stream.
datastream.Hook("ks_CinematicText", function(handler, uniqueID, rawData, procData)
	kuroScript.frame:AddCinematicText(procData.text, procData.color, procData.hangTime);
end);

-- Hook a user message to recieve a notification.
usermessage.Hook("ks_Notification", function(msg)
	local text = msg:ReadString();
	local class = msg:ReadShort();
	
	-- The sound of the notification.
	local sound = "ambient/water/drip2.wav";
	
	-- Check if a statement is true.
	if (class == 1) then
		sound = "buttons/button10.wav";
	elseif (class == 2) then
		sound = "buttons/button17.wav";
	elseif (class == 3) then
		sound = "buttons/bell1.wav";
	elseif (class == 4) then
		sound = "buttons/button15.wav";
	end
	
	-- Set some information.
	local info = {class = class, sound = sound, text = text};
	
	-- Call a gamemode hook.
	hook.Call("NotificationAdjustInfo", kuroScript.frame, info);
	
	-- Set some information.
	kuroScript.frame:AddNotify(info.text, info.class, 10);
	
	-- Play a sound.
	surface.PlaySound(info.sound);
	
	-- Print a message.
	print(info.text);
end);

-- Add a console command.
concommand.Add("lua_run_ks", function(player, command, arguments)
	if ( player:IsSuperAdmin() ) then
		RunString( table.concat(arguments, " ") );
	else
		print("You do not have access to this command, "..player:Name()..".");
	end;
end);

-- Override the weapon pickup function.
function kuroScript.frame:HUDWeaponPickedUp(...) end;

-- Override the item pickup function.
function kuroScript.frame:HUDItemPickedUp(...) end;

-- Override the ammo pickup function.
function kuroScript.frame:HUDAmmoPickedUp(...) end;

-- Called when the local player's business is rebuilt.
function kuroScript.frame:PlayerBusinessRebuilt(panel, categories) end;

-- Called when the local player's inventory is rebuilt.
function kuroScript.frame:PlayerInventoryRebuilt(panel, categories) end;

-- Called when kuroScript config has initialized.
function kuroScript.frame:KuroScriptConfigInitialized(key, value) end;

-- Called when a kuroScript ConVar has changed.
function kuroScript.frame:KuroScriptConVarChanged(name, previousValue, newValue) end;

-- Called when kuroScript config has changed.
function kuroScript.frame:KuroScriptConfigChanged(key, data, previousValue, newValue) end;

-- Called when an entity is created.
function kuroScript.frame:OnEntityCreated(entity)
	if (LocalPlayer() == entity) then
		if (kuroScript.config.initialized and !kuroScript.config.sentInitialized) then
			datastream.StreamToServer("ks_ConfigInitialized", true);
			
			-- Set some information.
			kuroScript.config.sentInitialized = true;
		end;
		
		-- Set some information.
		g_LocalPlayer = entity;
	end;
	
	-- Return the base class function.
	return self.BaseClass:OnEntityCreated(entity);
end;

-- Called when the cursor enters a character panel.
function kuroScript.frame:OnCursorEnterCharacterPanel(panel, character) end;

-- Called when the cursor exits a character panel.
function kuroScript.frame:OnCursorExitCharacterPanel(panel, character) end;

-- Called when the client initializes.
function kuroScript.frame:Initialize()
	KS_CONVAR_SHOWKUROSCRIPTLOG = self:CreateClientConVar("ks_showkuroscriptlog", 1, true, true);
	KS_CONVAR_TWELVEHOURCLOCK = self:CreateClientConVar("ks_twelvehourclock", 0, true, true);
	KS_CONVAR_SHOWTIMESTAMPS = self:CreateClientConVar("ks_showtimestamps", 0, true, true);
	KS_CONVAR_SHOWKUROSCRIPT = self:CreateClientConVar("ks_showkuroscript", 1, true, true);
	KS_CONVAR_SHOWDEPARTURE = self:CreateClientConVar("ks_showdeparture", 1, true, true);
	KS_CONVAR_MAXCHATLINES = self:CreateClientConVar("ks_maxchatlines", 5, true, true);
	KS_CONVAR_HEADBOBSCALE = self:CreateClientConVar("ks_headbobscale", 1, true, true);
	KS_CONVAR_SHOWARRIVAL = self:CreateClientConVar("ks_showarrival", 1, true, true);
	KS_CONVAR_SHOWSERVER = self:CreateClientConVar("ks_showserver", 1, true, true);
	KS_CONVAR_SHOWHINTS = self:CreateClientConVar("ks_showhints", 1, true, true);
	KS_CONVAR_SHOWOOC = self:CreateClientConVar("ks_showooc", 1, true, true);
	KS_CONVAR_SHOWIC = self:CreateClientConVar("ks_showic", 1, true, true);
	
	-- Call a gamemode hook.
	hook.Call("KuroScriptInitialized", self);
end;

-- Called when kuroScript has initialized.
function kuroScript.frame:KuroScriptInitialized() end;

-- Called when a player's door access name is needed.
function kuroScript.frame:GetPlayerDoorAccessName(player, door, owner)
	return player:Name();
end;

-- Called when a player should show on the door access list.
function kuroScript.frame:PlayerShouldShowOnDoorAccessList(player, door, owner)
	return true;
end;

-- Called when a player should show on the scoreboard.
function kuroScript.frame:PlayerShouldShowOnScoreboard(player) return true; end;

-- Called when the local player attempts to zoom.
function kuroScript.frame:PlayerCanZoom() return true; end;

-- Called when the local player attempts to see a business item.
function kuroScript.frame:PlayerCanSeeBusinessItem(item) return true; end;

-- Called when a player presses a bind.
function kuroScript.frame:PlayerBindPress(player, bind, press)
	local weapon = g_LocalPlayer:GetActiveWeapon();
	local prefix = kuroScript.config.Get("command_prefix"):Get();
	
	-- Check if a statement is true.
	if ( !g_LocalPlayer:HasInitialized() and string.find(bind, "+jump") ) then
		RunConsoleCommand("retry");
	elseif ( player:GetRagdollState() == RAGDOLL_FALLENOVER and string.find(bind, "+jump") ) then
		RunConsoleCommand("ks", "getup");
	elseif ( string.find(bind, "toggle_zoom") ) then
		return true;
	elseif ( string.find(bind, "+zoom") ) then
		if ( !hook.Call("PlayerCanZoom", self) ) then
			return true;
		end;
	end;
	
	-- Check if a statement is true.
	if ( string.find(bind, "+attack") or string.find(bind, "+attack2") ) then
		if (kuroScript.storage.panel) then
			if ( kuroScript.storage.panel:IsValid() ) then
				return true;
			end;
		end;
	end;
	
	-- Check if a statement is true.
	if ( kuroScript.config.Get("block_inv_binds"):Get() ) then
		if ( string.find(bind, prefix.."inventory") or string.find(bind, "ks inventory") ) then
			return true;
		end;
	end;
	
	-- Return the base class function.
	return self.BaseClass:PlayerBindPress(player, bind, press);
end;

-- Check if a statement is true.
function kuroScript.frame:IsUsingTool()
	if (ValidEntity( g_LocalPlayer:GetActiveWeapon() )
	and g_LocalPlayer:GetActiveWeapon():GetClass() == "gmod_tool") then
		return true;
	else
		return false;
	end;
end;

-- Check if a statement is true.
function kuroScript.frame:IsUsingCamera()
	if (ValidEntity( g_LocalPlayer:GetActiveWeapon() )
	and g_LocalPlayer:GetActiveWeapon():GetClass() == "gmod_camera") then
		return true;
	else
		return false;
	end;
end;

-- Called when the local player attempts to see while unconscious.
function kuroScript.frame:PlayerCanSeeUnconscious() return false; end;

-- Called when the local player's move data is created.
function kuroScript.frame:CreateMove(userCmd)
	local ragdollEyeAngles = self:GetRagdollEyeAngles();
	
	-- Check if a statement is true.
	if (ragdollEyeAngles) then
		local defaultSensitivity = 0.05;
		local sensitivity = defaultSensitivity * (hook.Call("AdjustMouseSensitivity", self, defaultSensitivity) or defaultSensitivity);
		
		-- Check if a statement is true.
		if (sensitivity <= 0) then
			sensitivity = defaultSensitivity;
		end;
		
		-- Check if a statement is true.
		if ( g_LocalPlayer:IsRagdolled() ) then
			ragdollEyeAngles.p = math.Clamp(ragdollEyeAngles.p + (userCmd:GetMouseY() * sensitivity), -48, 48);
			ragdollEyeAngles.y = math.Clamp(ragdollEyeAngles.y - (userCmd:GetMouseX() * sensitivity), -48, 48);
		else
			ragdollEyeAngles.p = math.Clamp(ragdollEyeAngles.p + (userCmd:GetMouseY() * sensitivity), -90, 90);
			ragdollEyeAngles.y = math.Clamp(ragdollEyeAngles.y - (userCmd:GetMouseX() * sensitivity), -90, 90);
		end;
	end
end

-- Called when the view should be calculated.
function kuroScript.frame:CalcView(player, origin, angles, fov)
	if ( g_LocalPlayer:IsRagdolled() ) then
		local ragdollEntity = g_LocalPlayer:GetRagdollEntity();
		local ragdollState = g_LocalPlayer:GetRagdollState();
		
		-- Check if a statement is true.
		if (self.BlackFadeIn == 255) then
			return {origin = Vector(20000, 0, 0), angles = Angle(0, 0, 0), fov = fov};
		else
			local eyes = ragdollEntity:GetAttachment( ragdollEntity:LookupAttachment("eyes") );
			
			-- Check if a statement is true.
			if (eyes) then
				local ragdollEyeAngles = eyes.Ang + self:GetRagdollEyeAngles();
				local physicsObject = ragdollEntity:GetPhysicsObject();
				
				-- Check if a statement is true.
				if ( ValidEntity(physicsObject) ) then
					local velocity = physicsObject:GetVelocity().z;
					
					-- Check if a statement is true.
					if (velocity <= -1000 and g_LocalPlayer:GetMoveType() == MOVETYPE_WALK) then
						ragdollEyeAngles.p = ragdollEyeAngles.p + math.sin( UnPredictedCurTime() ) * math.abs( (velocity + 1000) - 16 );
					end;
				end;
				
				-- Return the view.
				return {origin = eyes.Pos, angles = ragdollEyeAngles, fov = fov};
			else
				return self.BaseClass:CalcView(player, origin, angles, fov);
			end;
		end;
	elseif ( !g_LocalPlayer:Alive() ) then
		return {origin = Vector(20000, 0, 0), angles = Angle(0, 0, 0), fov = fov};
	elseif ( kuroScript.config.Get("enable_headbob"):Get() ) then
		if ( player:IsOnGround() ) then
			local frameTime = FrameTime();
			
			-- Check if a statement is true.
			if (player:GetMoveType() != MOVETYPE_NOCLIP) then
				local approachTime = frameTime * 2;
				local info = {multiplier = 10, pitch = 0.2, yaw = 0.04};
				
				-- Check if a statement is true.
				if (!self.HeadbobAngle) then
					self.HeadbobAngle = 0;
				end;
				
				-- Check if a statement is true.
				if (!self.HeadbobInfo) then
					self.HeadbobInfo = info;
				end;
				
				-- Call a gamemode hook.
				hook.Call("PlayerAdjustHeadbobInfo", self, info);
				
				-- Set some information.
				self.HeadbobInfo.multiplier = math.Approach(self.HeadbobInfo.multiplier, info.multiplier, approachTime);
				self.HeadbobInfo.pitch = math.Approach(self.HeadbobInfo.pitch, info.pitch, approachTime);
				self.HeadbobInfo.yaw = math.Approach(self.HeadbobInfo.yaw, info.yaw, approachTime);
				self.HeadbobAngle = self.HeadbobAngle + (self.HeadbobInfo.multiplier * frameTime);
				
				-- Set some information.
				angles.p = angles.p + (math.sin(self.HeadbobAngle) * self.HeadbobInfo.pitch);
				angles.y = angles.y + (math.cos(self.HeadbobAngle) * self.HeadbobInfo.yaw);
			end;
		end;
	end;
	
	-- Set some information.
	local velocity = g_LocalPlayer:GetVelocity().z;
	
	-- Check if a statement is true.
	if (velocity <= -1000 and g_LocalPlayer:GetMoveType() == MOVETYPE_WALK) then
		angles.p = angles.p + math.sin( UnPredictedCurTime() ) * math.abs( (velocity + 1000) - 16 );
	end;
	
	-- Set some information.
	local weapon = g_LocalPlayer:GetActiveWeapon();
	local view = self.BaseClass:CalcView(player, origin, angles, fov);
	
	-- Check if a statement is true.
	if ( ValidEntity(weapon) ) then
		local weaponRaised = kuroScript.player.GetWeaponRaised(g_LocalPlayer);
		
		-- Check if a statement s true.
		if (!g_LocalPlayer:HasInitialized() or !kuroScript.config.HasInitialized()
		or g_LocalPlayer:GetMoveType() == MOVETYPE_OBSERVER) then
			weaponRaised = nil;
		end;
		
		-- Check if a statement is true.
		if (!weaponRaised) then
			local originalOrigin = Vector(origin.x, origin.y, origin.z);
			local originalAngles = Angle(angles.p, angles.y, angles.r);
			local originMod = Vector(-3.0451, -1.6419, -0.5771);
			local anglesMod = Angle(-12.9015, -47.2118, 5.1173);
			local itemTable = kuroScript.item.GetWeapon(weapon);
			
			-- Check if a statement is true.
			if (itemTable and itemTable.loweredAngles) then
				anglesMod = itemTable.loweredAngles;
			elseif (weapon.LoweredAngles) then
				anglesMod = weapon.LoweredAngles;
			end;
			
			-- Check if a statement is true.
			if (itemTable and itemTable.loweredOrigin) then
				originMod = itemTable.loweredOrigin;
			elseif (weapon.LoweredOrigin) then
				originMod = weapon.LoweredOrigin;
			end;
			
			-- Rotate the angle around an axis.
			originalAngles:RotateAroundAxis(originalAngles:Right(), anglesMod.p);
			originalAngles:RotateAroundAxis(originalAngles:Up(), anglesMod.y);
			originalAngles:RotateAroundAxis(originalAngles:Forward(), anglesMod.r);
			
			-- Set some information.
			originalOrigin = originalOrigin + originMod.x * originalAngles:Right();
			originalOrigin = originalOrigin + originMod.y * originalAngles:Forward();
			originalOrigin = originalOrigin + originMod.z * originalAngles:Up();
			
			-- Set some information.
			view.vm_origin = originalOrigin;
			view.vm_angles = originalAngles;
		end;
	end;
	
	-- Call a gamemode hook.
	hook.Call("CalcViewAdjustTable", self, view);
	
	-- Return the view.
	return view;
end;

-- Called when a HUD element should be drawn.
function kuroScript.frame:HUDShouldDraw(name)
	local blockedElements = {
		"CHudSecondaryAmmo",
		"CHudVoiceStatus",
		"CHudSuitPower",
		"CHudBattery",
		"CHudHealth",
		"CHudAmmo"
	};
	
	-- Check if a statement is true.
	if ( !ValidEntity(g_LocalPlayer) or !g_LocalPlayer:HasInitialized() ) then
		if (name != "CHudGMod") then
			return false;
		end;
	elseif (name == "CHudCrosshair") then
		if ( !ValidEntity(g_LocalPlayer) or g_LocalPlayer:IsRagdolled(RAGDOLL_FALLENOVER) ) then
			return false;
		end;
		
		-- Check if a statement is true.
		if ( self.CharacterLoadingFinishTime and self.CharacterLoadingFinishTime > CurTime() ) then
			return false;
		end;
		
		-- Check if a statement is true.
		if ( !kuroScript.config.Get("enable_crosshair"):Get() ) then
			if ( ValidEntity(g_LocalPlayer) ) then
				local weapon = g_LocalPlayer:GetActiveWeapon();
				
				-- Check if a statement is true.
				if ( ValidEntity(weapon) ) then
					local class = string.lower( weapon:GetClass() );
					
					-- Check if a statement is true.
					if (class != "weapon_physgun" and class != "gmod_physcannon" and class != "gmod_tool") then
						return false;
					end;
				else
					return false;
				end;
			else
				return false;
			end;
		end;
	elseif ( table.HasValue(blockedElements, name) ) then
		return false;
	end;
	
	-- Return the base class function.
	return self.BaseClass:HUDShouldDraw(name);
end

-- Called when the menu is opened.
function kuroScript.frame:MenuOpened()
	for k, v in pairs(kuroScript.menu.panel.propertySheet.Items) do
		if (v.Tab:GetPanel().OnMenuOpened) then
			v.Tab:GetPanel():OnMenuOpened();
		end;
	end;
end;

-- Called when the menu is closed.
function kuroScript.frame:MenuClosed()
	for k, v in pairs(kuroScript.menu.panel.propertySheet.Items) do
		if (v.Tab:GetPanel().OnMenuClosed) then
			v.Tab:GetPanel():OnMenuClosed();
		end;
	end;
	
	-- Close all Derma menus.
	CloseDermaMenus();
end;

-- Called when the character screen's class characters should be sorted.
function kuroScript.frame:CharacterScreenSortClassCharacters(class, a, b)
	return a.name < b.name;
end;

-- Called when the scoreboard's class players should be sorted.
function kuroScript.frame:ScoreboardSortClassPlayers(class, a, b)
	return a:Team() < b:Team();
end;

-- Called when the scoreboard's player info should be adjusted.
function kuroScript.frame:ScoreboardAdjustPlayerInfo(info) end;

-- Called when the menu's property sheet tabs should be adjusted.
function kuroScript.frame:MenuPropertySheetTabsAdd(propertySheetTabs)
	propertySheetTabs:Add("Settings", "ks_Settings", "gui/silkicons/wrench", "Configure the way kuroScript works for you.");
	propertySheetTabs:Add("Business", "ks_Business", "gui/silkicons/box", "Order items for your business.");
	propertySheetTabs:Add("Directory", "ks_Directory", "gui/silkicons/page", "A directory of various topics and information.");
	propertySheetTabs:Add("Vocations", "ks_Vocations", "gui/silkicons/user", "Choose from a list of available vocations.");
	propertySheetTabs:Add("Inventory", "ks_Inventory", "gui/silkicons/application_view_tile", "Manage the items in your inventory.");
	propertySheetTabs:Add("Attributes", "ks_Attributes", "gui/silkicons/plugin", "Check the status of your attributes.");
	propertySheetTabs:Add("Scoreboard", "ks_Scoreboard", "gui/silkicons/newspaper", "See which players are on the server.");
end;

-- Called when the menu's property sheet tabs should be destroyed.
function kuroScript.frame:MenuPropertySheetTabsDestroy(propertySheetTabs) end;

-- Called each tick.
function kuroScript.frame:Tick()
	local curTime = UnPredictedCurTime();
	local k, v;
	local i;
	
	-- Check if a statement is true.
	if ( ValidEntity(g_LocalPlayer) ) then
		if ( g_LocalPlayer:HasInitialized() ) then
			self.TopText.text = {};
			self.TopBars.bars = {};
			self.PlayerInfoText.text[ALIGN_LEFT] = {};
			self.PlayerInfoText.text[ALIGN_RIGHT] = {};
			self.PlayerInfoText.width[ALIGN_LEFT] = 0;
			self.PlayerInfoText.width[ALIGN_RIGHT] = 0;
			self.PlayerInfoText.subText[ALIGN_LEFT] = {};
			self.PlayerInfoText.subText[ALIGN_RIGHT] = {};
			
			-- Call some gamemode hooks.
			hook.Call("GetTopBars", self, self.TopBars);
			hook.Call("GetTopText", self, self.TopText);
			hook.Call("DestroyTopBars", self, self.TopBars);
			hook.Call("DestroyTopText", self, self.TopText);
			hook.Call("GetPlayerInfoText", self, self.PlayerInfoText);
			hook.Call("DestroyPlayerInfoText", self, self.PlayerInfoText);
			
			-- Sort the top text.
			table.sort(self.TopText.text, function(a, b)
				return a.text < b.text;
			end);
			
			-- Loop through a range of values.
			for i = ALIGN_RIGHT, ALIGN_LEFT do
				table.sort(self.PlayerInfoText.text[i], function(a, b)
					return self:ExplodeString(":", a.text)[1] < self:ExplodeString(":", b.text)[1];
				end);
				
				-- Loop through each value in a table.
				for k, v in ipairs( self.PlayerInfoText.text[i] ) do
					if (v.icon) then
						self.PlayerInfoText.width[i] = self:AdjustMaximumWidth(FONT_MAIN_TEXT, v.text, self.PlayerInfoText.width[i], nil, 24);
					else
						self.PlayerInfoText.width[i] = self:AdjustMaximumWidth( FONT_MAIN_TEXT, v.text, self.PlayerInfoText.width[i] );
					end;
				end;
				
				-- Set some information.
				self.PlayerInfoText.width[i] = self.PlayerInfoText.width[i] + 16;
				
				-- Loop through each value in a table.
				for k, v in ipairs( self.PlayerInfoText.subText[i] ) do
					self.PlayerInfoText.width[i] = self:AdjustMaximumWidth(FONT_MAIN_TEXT, v.text, self.PlayerInfoText.width[i], nil, 16);
				end;
			end;
			
			-- Check if a statement is true.
			if ( kuroScript.config.Get("fade_dead_npcs"):Get() ) then
				local k, v;
				
				-- Loop through each value in a table.
				for k, v in pairs( ents.FindByClass("class C_ClientRagdoll") ) do
					if ( !kuroScript.entity.IsDecaying(v) ) then
						kuroScript.entity.Decay(v, 30);
					end;
				end;
			end;
		end;
	end;
end;

-- Called each frame.
function kuroScript.frame:Think()
	self:CallTimerThink( CurTime() );
	
	-- Check if a statement is true.
	if ( self:IsCharacterScreenOpen() ) then
		local activePanel = kuroScript.character.GetActivePanel();
		
		-- Check if a statement is true.
		if (activePanel) then
			activePanel:SetVisible( hook.Call("GetPlayerCharacterScreenVisible", kuroScript.frame, activePanel) );
		end;
	end;
end;

-- Called when the character loading HUD should be painted.
function kuroScript.frame:HUDPaintCharacterLoading(alpha)
	if ( hook.Call("ShouldDrawCharacterLoadingBackground", self, alpha) ) then
		draw.RoundedBox( 0, 0, 0, ScrW(), ScrH(), Color(0, 0, 0, alpha) );
	end;
	
	-- Set some information.
	local cinematicInfo = hook.Call("GetCinematicIntroInfo", self);
	
	-- Check if a statement is true.
	if (cinematicInfo) then
		if (cinematicInfo.title) then
			draw.SimpleText(cinematicInfo.title, FONT_INTRO_TEXT_BIG, ScrW() / 2, ScrH() / 2, Color(255, 255, 255, alpha), 1, 1);
		end;
		
		-- Check if a statement is true.
		if (cinematicInfo.text) then
			draw.SimpleText(cinematicInfo.text, FONT_INTRO_TEXT_SMALL, ScrW() / 2, (ScrH() / 2) + 68, Color(255, 255, 255, alpha), 1, 1);
		end;
		
		-- Draw the cinematic introduction bars.
		self:DrawCinematicIntroBars();
	end;
end;

-- Called when the character selection HUD should be painted.
function kuroScript.frame:HUDPaintCharacterSelection() end;

-- Called when the foreground HUD should be painted.
function kuroScript.frame:HUDPaintForeground()
	local info = hook.Call("GetProgressBarInfo", self);
	
	-- Check if a statement is true.
	if (info) then
		local x, y = kuroScript.frame:GetScreenCenterBounce();
		
		-- Draw a bar.
		self:DrawBar(x - (ScrW() / 4), y + 48, ScrW() / 2, 16, info.color or self.ProgressBarColor, info.text or "Progress Bar", info.percentage or 100, 100, info.flash);
	else
		info = hook.Call("GetPostProgressBarInfo", self);
		
		-- Check if a statement is true.
		if (info) then
			local x, y = kuroScript.frame:GetScreenCenterBounce();
			
			-- Draw a bar.
			self:DrawBar(x - (ScrW() / 4), y + 48, ScrW() / 2, 16, info.color or self.ProgressBarColor, info.text or "Progress Bar", info.percentage or 100, 100, info.flash);
		end;
	end;
end;

-- Called when the important HUD should be painted.
function kuroScript.frame:HUDPaintImportant()
	if ( !kuroScript.config.HasInitialized() ) then
		if (!self.ConfigLoadingAlpha) then
			self.ConfigLoadingAlpha = 255;
		end;
	elseif (self.ConfigLoadingAlpha) then
		self.ConfigLoadingAlpha = math.Approach(self.ConfigLoadingAlpha, 0, FrameTime() * 100);
		
		-- Check if a statement is true.
		if (self.ConfigLoadingAlpha <= 0) then
			self.ConfigLoadingAlpha = nil;
		end;
	end;
	
	-- Check if a statement is true.
	if (self.ConfigLoadingAlpha and self.ConfigLoadingAlpha > 0) then
		draw.RoundedBox( 0, 0, 0, ScrW(), ScrH(), Color(0, 0, 0, self.ConfigLoadingAlpha) );
		draw.SimpleText("Loading kuroScript", FONT_INTRO_TEXT_SMALL, ScrW() / 2, ScrH() / 2, Color(255, 255, 255, self.ConfigLoadingAlpha), 1, 1);
	end;
end;

-- Called when the local player attempts to get up.
function kuroScript.frame:PlayerCanGetUp() return true; end;

-- Called when the local player attempts to see the top text.
function kuroScript.frame:PlayerCanSeeTopText() return true; end;

-- Called when the local player attempts to see the top bars.
function kuroScript.frame:PlayerCanSeeTopBars() return true; end;

-- Called when the local player attempts to see a vocation.
function kuroScript.frame:PlayerCanSeeVocation(vocation) return true; end;

-- Called when the local player attempts to see the player info.
function kuroScript.frame:PlayerCanSeePlayerInfo(alignment) return true; end;

-- Called when the target ID HUD should be drawn.
function kuroScript.frame:HUDDrawTargetID()
	if ( g_LocalPlayer:Alive() ) then
		if ( !g_LocalPlayer:IsRagdolled(RAGDOLL_FALLENOVER) ) then
			local fadeDistance = 128;
			local eyePos = g_LocalPlayer:EyePos();
			local trace = g_LocalPlayer:GetEyeTraceNoCursor();
			
			-- Set some information.
			local newTrace = {
				endpos = eyePos + (g_LocalPlayer:GetAimVector() * 4096),
				filter = g_LocalPlayer,
				start = eyePos,
				mask = CONTENTS_SOLID + CONTENTS_MOVEABLE + CONTENTS_OPAQUE + CONTENTS_DEBRIS + CONTENTS_HITBOX + CONTENTS_MONSTER
			}
			
			-- Set some information.
			newTrace = util.TraceLine(newTrace);
			
			-- Check if a statement is true.
			if (ValidEntity(newTrace.Entity) and !ValidEntity(trace.Entity) and !newTrace.HitWorld) then
				trace = newTrace;
			end;
			
			-- Check if a statement is true.
			if ( ValidEntity(trace.Entity) ) then
				local class = trace.Entity:GetClass();
				local entity = kuroScript.entity.GetPlayer(trace.Entity);
				
				-- Check if a statement is true.
				if (entity and g_LocalPlayer != entity) then
					fadeDistance = hook.Call("GetTargetPlayerFadeDistance", self, entity);
					
					-- Check if a statement is true.
					if (entity:InVehicle() or entity:GetMoveType() != MOVETYPE_NOCLIP) then
						local r, g, b, a = trace.Entity:GetColor();
						
						-- Check if a statement is true.
						if (g_LocalPlayer:GetShootPos():Distance(trace.HitPos) <= fadeDistance) then
							if (trace.Entity:GetMaterial() != "sprites/heatwave" and a != 0) then
								local alpha = self:CalculateAlphaFromDistance(fadeDistance, g_LocalPlayer, trace.HitPos);
								local x, y = self:GetScreenCenterBounce();
								local k, v;
								
								-- Check if a statement is true.
								if ( kuroScript.player.KnowsPlayer(entity, KNOWN_PARTIAL) ) then
									local text = self:ExplodeString( "\n", hook.Call("GetTargetPlayerName", self, entity) );
									
									-- Loop through each value in a table.
									for k, v in ipairs(text) do
										y = self:DrawInfo(v, x, y, g_Team.GetColor( entity:Team() ), alpha);
									end;
								else
									local anonymousName = kuroScript.config.Get("anonymous_name"):Get();
									local teamColor = g_Team.GetColor( entity:Team() );
									local result = hook.Call("PlayerCanShowAnonymous", self, entity, x, y, anonymousName, teamColor, alpha);
									
									-- Check if a statement is true.
									if (result == true) then
										y = self:DrawInfo(anonymousName, x, y, teamColor, alpha);
									elseif ( tonumber(result) ) then
										y = result;
									end;
								end;
								
								-- Set some information.
								for k, v in ipairs(self.TargetPlayerText.text) do
									self.TargetPlayerText.text[k] = nil;
								end;
								
								-- Call some gamemode hooks.
								hook.Call("GetTargetPlayerText", self, entity, self.TargetPlayerText);
								hook.Call("DestroyTargetPlayerText", self, entity, self.TargetPlayerText);
								
								-- Call a gamemode hook.
								y = hook.Call("DrawTargetPlayerStatus", self, entity, alpha, x, y) or y;
								
								-- Sort the target player text.
								table.sort(self.TargetPlayerText.text, function(a, b)
									return a.text < b.text;
								end);
								
								-- Loop through each value in a table.
								for k, v in pairs(self.TargetPlayerText.text) do
									y = self:DrawInfo(v.text, x, y, v.color or COLOR_WHITE, alpha);
								end;
							end;
						end;
					end;
				elseif ( kuroScript.contraband.Get(class) ) then
					if (g_LocalPlayer:GetShootPos():Distance(trace.HitPos) <= fadeDistance) then
						local contraband = kuroScript.contraband.Get(class);
						local alpha = self:CalculateAlphaFromDistance(fadeDistance, g_LocalPlayer, trace.HitPos);
						local owner = kuroScript.entity.GetOwner(trace.Entity);
						local power = trace.Entity:GetSharedVar("ks_Power");
						local x, y = self:GetScreenCenterBounce();
						
						-- Draw some information.
						y = self:DrawInfo(contraband.name, x, y, Color(150, 150, 100, 255), alpha);
						
						-- Check if a statement is true.
						if ( !ValidEntity(owner) ) then
							y = self:DrawInfo("Abandoned", x, y, COLOR_INFORMATION, alpha);
						end;
						
						-- Draw a bar.
						y = self:DrawBar( x - 80, y, 160, 16, self.ProgressBarColor, contraband.powerPlural, power, contraband.power, power < (contraband.power / 5) );
					end;
				elseif ( kuroScript.entity.IsDoor(trace.Entity) ) then
					if (g_LocalPlayer:GetShootPos():Distance(trace.HitPos) <= fadeDistance) then
						local name = hook.Call("GetDoorInfo", self, trace.Entity, DOOR_INFO_NAME);
						local text = hook.Call("GetDoorInfo", self, trace.Entity, DOOR_INFO_TEXT);
						
						-- Set some information.
						local alpha = self:CalculateAlphaFromDistance(fadeDistance, g_LocalPlayer, trace.HitPos);
						local owner = kuroScript.entity.GetOwner(trace.Entity);
						local x, y = self:GetScreenCenterBounce();
						
						-- Check if a statement is true.
						if (name) then
							y = self:DrawInfo(name, x, y, Color(125, 150, 175, 255), alpha);
						end;
						
						-- Check if a statement is true.
						if (text) then
							y = self:DrawInfo(text, x, y, COLOR_WHITE, alpha);
						end;
					end;
				elseif ( trace.Entity:IsWeapon() ) then
					if (g_LocalPlayer:GetShootPos():Distance(trace.HitPos) <= fadeDistance) then
						local active = nil;
						local k, v;
						
						-- Loop through each value in a table.
						for k, v in ipairs( g_Player.GetAll() ) do
							if (v:GetActiveWeapon() == trace.Entity) then
								active = true;
							end;
						end;
						
						-- Check if a statement is true.
						if (!active) then
							local alpha = self:CalculateAlphaFromDistance(fadeDistance, g_LocalPlayer, trace.HitPos);
							local x, y = self:GetScreenCenterBounce();
							
							-- Draw some information.
							y = self:DrawInfo("Weapon", x, y, Color(200, 100, 50, 255), alpha);
							y = self:DrawInfo("Press Use", x, y, COLOR_WHITE, alpha);
						end;
					end;
				elseif (trace.Entity.HUDPaintTargetID) then
					local alpha = self:CalculateAlphaFromDistance(fadeDistance, g_LocalPlayer, trace.HitPos);
					local x, y = self:GetScreenCenterBounce();
					
					-- Call an entity hook.
					trace.Entity:HUDPaintTargetID(x, y, alpha);
				else
					local r, g, b, a = trace.Entity:GetColor();
					local alpha = self:CalculateAlphaFromDistance(fadeDistance, g_LocalPlayer, trace.HitPos);
					local x, y = self:GetScreenCenterBounce();
					
					-- Call a gamemode hook.
					hook.Call( "HUDPaintEntityTargetID", kuroScript.frame, trace.Entity, {
						alpha = math.min(alpha, a),
						x = x,
						y = y
					} );
				end;
			end;
		end;
	end;
end;

-- Called when the target's status should be drawn.
function kuroScript.frame:DrawTargetPlayerStatus(target, alpha, x, y)
	if ( !target:Alive() ) then
		return self:DrawInfo("Deceased", x, y, COLOR_INFORMATION, alpha);
	else
		return y;
	end;
end;

-- Called when the character panel tool tip is needed.
function kuroScript.frame:GetCharacterPanelToolTip(panel, class, character)
	return "There are "..#kuroScript.class.GetPlayers(class).."/"..kuroScript.class.stored[class].limit.." characters with this class.";
end;

-- Called when the post progress bar info is needed.
function kuroScript.frame:GetPostProgressBarInfo() end;

-- Called when the custom character options are needed.
function kuroScript.frame:GetCustomCharacterOptions(character, options, menu) end;

-- Called when the progress bar info is needed.
function kuroScript.frame:GetProgressBarInfo()
	local action, percentage = kuroScript.player.GetAction(g_LocalPlayer, true);
	
	-- Check if a statement is true.
	if (!g_LocalPlayer:Alive() and action == "spawn") then
		return {text = "Spawning", percentage = percentage, flash = percentage < 10};
	end;
	
	-- Check if a statement is true.
	if ( !g_LocalPlayer:IsRagdolled() ) then
		if (action == "lock") then
			return {text = "Locking", percentage = percentage, flash = percentage < 10};
		elseif (action == "unlock") then
			return {text = "Unlocking", percentage = percentage, flash = percentage < 10};
		elseif (action == "holster") then
			return {text = "Holstering", percentage = percentage, flash = percentage < 10};
		elseif (action == "assemble") then
			return {text = "Assembling", percentage = percentage, flash = percentage < 10};
		elseif (action == "disassemble") then
			return {text = "Disassembling", percentage = percentage, flash = percentage < 10};
		end;
	elseif (action == "unragdoll") then
		if (g_LocalPlayer:GetRagdollState() == RAGDOLL_FALLENOVER) then
			return {text = "Stabilisation", percentage = percentage, flash = percentage < 10};
		else
			return {text = "Consciousness", percentage = percentage, flash = percentage < 10};
		end;
	elseif (g_LocalPlayer:GetRagdollState() == RAGDOLL_FALLENOVER) then
		local fallenOver = g_LocalPlayer:GetSharedVar("ks_FallenOver");
		
		-- Check if a statement is true.
		if ( fallenOver and hook.Call("PlayerCanGetUp", self) ) then
			return {text = "Press Jump", percentage = 100};
		end;
	end;
end;

-- Called when the player info text is needed.
function kuroScript.frame:GetPlayerInfoText(playerInfoText)
	local day, hour, minute = self:GetDateInfo();
	local timeInfo = self:GetTimeString(hour, minute);
	local currency = kuroScript.player.GetCurrency();
	local details = kuroScript.player.GetDetails();
	local wages = kuroScript.player.GetWages();
	
	-- Check if a statement is true.
	if (currency > 0) then
		playerInfoText:Add("CURRENCY", NAME_CURRENCY..": "..FORMAT_CURRENCY(currency, true), "gui/silkicons/star");
	end;
	
	-- Check if a statement is true.
	if (wages > 0) then
		playerInfoText:Add("WAGES", g_LocalPlayer:GetWagesName()..": "..FORMAT_CURRENCY(wages), "gui/silkicons/folder_go");
	end;
	
	-- Add some player info text.
	playerInfoText:Add("DATE", "Date: "..self:GetSharedVar("ks_Date"), "gui/silkicons/world", ALIGN_RIGHT);
	playerInfoText:Add("TIME", "Time: "..timeInfo, "gui/silkicons/application_put", ALIGN_RIGHT);
	playerInfoText:Add("DAY", "Day: "..day, "gui/silkicons/application_view_detail", ALIGN_RIGHT);
	
	-- Add some sub player info text.
	playerInfoText:AddSub( "NAME", g_LocalPlayer:Name() );
	playerInfoText:AddSub("DETAILS", details);
end;

-- Called when the target player's fade distance is needed.
function kuroScript.frame:GetTargetPlayerFadeDistance(player)
	return 196;
end;

-- Called when the player info text should be destroyed.
function kuroScript.frame:DestroyPlayerInfoText(playerInfoText) end;

-- Called when the target player's text is needed.
function kuroScript.frame:GetTargetPlayerText(player, targetPlayerText)
	targetPlayerText:Add( "DETAILS", kuroScript.player.GetDetails(player) );
end;

-- Called when the target player's text should be destroyed.
function kuroScript.frame:DestroyTargetPlayerText(entity, targetPlayerText) end;

-- Called when a player's scoreboard text is needed.
function kuroScript.frame:GetPlayerScoreboardText(player)
	if ( kuroScript.player.KnowsPlayer(player, KNOWN_PARTIAL) ) then
		return kuroScript.player.GetDetails(player);
	else
		return g_Team.GetName( player:Team() );
	end;
end;

-- Called when the local player's character screen class is needed.
function kuroScript.frame:GetPlayerCharacterScreenClass(character)
	return character.class;
end;

-- Called to get whether the local player's character screen is visible.
function kuroScript.frame:GetPlayerCharacterScreenVisible(panel)
	if ( !kuroScript.quiz.GetEnabled() or kuroScript.quiz.GetCompleted() ) then
		return true;
	else
		return false;
	end;
end;

-- Called when the local player's character screen is created.
function kuroScript.frame:PlayerCharacterScreenCreated(panel)
	if ( kuroScript.quiz.GetEnabled() ) then
		datastream.StreamToServer("ks_GetQuizStatus", true);
	end;
end;

-- Called when a player's scoreboard class is needed.
function kuroScript.frame:GetPlayerScoreboardClass(player)
	local class = kuroScript.player.GetClass(player);
	
	-- Check if a statement is true.
	if ( kuroScript.class.Get(class) ) then return class; end;
end;

-- Called when a player's scoreboard options are needed.
function kuroScript.frame:GetPlayerScoreboardOptions(player, options, menu)
	if ( kuroScript.command.Get("bancharacter") ) then
		if ( kuroScript.player.HasAccess(g_LocalPlayer, kuroScript.command.Get("bancharacter").access) ) then
			options["Ban Character"] = function()
				RunConsoleCommand( "ks", "bancharacter", player:Name() );
			end;
		end;
	end;
	
	-- Check if a statement is true.
	if ( kuroScript.command.Get("kick") ) then
		if ( kuroScript.player.HasAccess(g_LocalPlayer, kuroScript.command.Get("kick").access) ) then
			options["Kick"] = function()
				Derma_StringRequest(player:Name(), "What is your reason for kicking them?", nil, function(text)
					RunConsoleCommand("ks", "kick", player:Name(), text);
				end);
			end;
		end;
	end;
	
	-- Check if a statement is true.
	if ( kuroScript.command.Get("ban") ) then
		if ( kuroScript.player.HasAccess(g_LocalPlayer, kuroScript.command.Get("ban").access) ) then
			options["Ban"] = function()
				Derma_StringRequest(player:Name(), "How many minutes would you like to ban them for?", nil, function(minutes)
					Derma_StringRequest(player:Name(), "What is your reason for banning them?", nil, function(reason)
						RunConsoleCommand("ks", "ban", player:Name(), minutes, reason);
					end);
				end);
			end;
		end;
	end;
	
	-- Check if a statement is true.
	if ( kuroScript.command.Get("giveaccess") ) then
		if ( kuroScript.player.HasAccess(g_LocalPlayer, kuroScript.command.Get("giveaccess").access) ) then
			options["Give Access"] = function()
				Derma_StringRequest(player:Name(), "What access would you like to give them?", nil, function(text)
					RunConsoleCommand("ks", "giveaccess", player:Name(), text);
				end);
			end;
		end;
	end;
	
	-- Check if a statement is true.
	if ( kuroScript.command.Get("takeaccess") ) then
		if ( kuroScript.player.HasAccess(g_LocalPlayer, kuroScript.command.Get("takeaccess").access) ) then
			options["Take Access"] = function()
				Derma_StringRequest(player:Name(), "What access would you like to take from them?", player:GetSharedVar("ks_Access"), function(text)
					RunConsoleCommand("ks", "takeaccess", player:Name(), text);
				end);
			end;
		end;
	end;
	
	-- Check if a statement is true.
	if ( kuroScript.command.Get("setname") ) then
		if ( kuroScript.player.HasAccess(g_LocalPlayer, kuroScript.command.Get("setname").access) ) then
			options["Set Name"] = function()
				Derma_StringRequest(player:Name(), "What would you like to set their name to?", player:Name(), function(text)
					RunConsoleCommand("ks", "setname", player:Name(), text);
				end);
			end;
		end;
	end;
	
	-- Check if a statement is true.
	if ( kuroScript.command.Get("giveitem") ) then
		if ( kuroScript.player.HasAccess(g_LocalPlayer, kuroScript.command.Get("giveitem").access) ) then
			options["Give Item"] = function()
				Derma_StringRequest(player:Name(), "What item would you like to give them?", nil, function(text)
					RunConsoleCommand("ks", "giveitem", player:Name(), text);
				end);
			end;
		end;
	end;
	
	-- Set some information.
	local unwhitelist;
	local whitelist;
	
	-- Check if a statement is true.
	if ( kuroScript.command.Get("whitelist") ) then
		if ( kuroScript.player.HasAccess(g_LocalPlayer, kuroScript.command.Get("whitelist").access) ) then
			whitelist = true;
		end;
	end;
	
	-- Check if a statement is true.
	if ( kuroScript.command.Get("unwhitelist") ) then
		if ( kuroScript.player.HasAccess(g_LocalPlayer, kuroScript.command.Get("unwhitelist").access) ) then
			unwhitelist = true;
		end;
	end;
	
	-- Check if a statement is true.
	if (whitelist or unwhitelist) then
		local whitelistable;
		local k, v;
		
		-- Loop through a table of values.
		for k, v in pairs(kuroScript.class.stored) do
			if (v.whitelist) then whitelistable = true; end;
		end;
		
		-- Check if a statement is true.
		if (whitelistable) then
			if (whitelist) then options["Whitelist"] = {}; end;
			if (unwhitelist) then options["Unwhitelist"] = {}; end;
			
			-- Loop through a table of values.
			for k, v in pairs(kuroScript.class.stored) do
				if (v.whitelist) then
					if ( options["Whitelist"] ) then
						options["Whitelist"][k] = function()
							RunConsoleCommand("ks", "whitelist", player:Name(), k);
						end;
					end;
					
					-- Check if a statement is true.
					if ( options["Unwhitelist"] ) then
						options["Unwhitelist"][k] = function()
							RunConsoleCommand("ks", "unwhitelist", player:Name(), k);
						end;
					end;
				end;
			end;
		end;
	end;
end;

-- Called when information about a door is needed.
function kuroScript.frame:GetDoorInfo(door, information)
	local owner = kuroScript.entity.GetOwner(door);
	local text = kuroScript.entity.GetDoorText(door);
	local name = kuroScript.entity.GetDoorName(door);
	
	-- Check if a statement is true.
	if (information == DOOR_INFO_NAME) then
		if ( kuroScript.entity.IsDoorHidden(door) ) then
			return false;
		elseif (name == "") then
			return "Door";
		else
			return name;
		end;
	elseif (information == DOOR_INFO_TEXT) then
		if ( kuroScript.entity.IsDoorUnownable(door) ) then
			if ( !kuroScript.entity.IsDoorHidden(door) ) then
				if (text == "") then
					return "Unownable";
				else
					return text;
				end;
			else
				return false;
			end;
		elseif (text != "") then
			if ( kuroScript.entity.HasOwner(door) and !ValidEntity(owner) ) then
				return "Press F2";
			else
				return text;
			end;
		elseif ( ValidEntity(owner) ) then
			return "Purchased";
		else
			return "Press F2";
		end;
	end;
end;

-- Whether or not a post process is permitted.
function kuroScript.frame:PostProcessPermitted(class) return false; end;

-- Called when screen space effects should be rendered.
function kuroScript.frame:RenderScreenspaceEffects()
	local frameTime = FrameTime();
	local drunk = kuroScript.player.GetDrunk();
	local color = 1;
	
	-- Check if a statement is true.
	if ( g_LocalPlayer:HasInitialized() ) then
		if (g_LocalPlayer:Health() <= 75) then
			if ( g_LocalPlayer:Alive() ) then
				color = math.Clamp(color - ( ( (g_LocalPlayer:GetMaxHealth() * 0.75) - g_LocalPlayer:Health() ) * 0.025 ), 0, color);
			else
				color = 0;
			end;
			
			-- Draw the motion blur.
			DrawMotionBlur(math.Clamp(1 - ( ( (g_LocalPlayer:GetMaxHealth() * 0.75) - g_LocalPlayer:Health() ) * 0.025 ), 0.1, 1), 1, 0);
		end;
		
		-- Check if a statement is true.
		if (drunk and self.DrunkBlur) then
			self.DrunkBlur = math.Clamp(self.DrunkBlur - (frameTime / 10), math.max(1 - (drunk / 8), 0.1), 1);
			
			-- Draw the motion blur.
			DrawMotionBlur(self.DrunkBlur, 1, 0);
		elseif (self.DrunkBlur and self.DrunkBlur < 1) then
			self.DrunkBlur = math.Clamp(self.DrunkBlur + (frameTime / 10), 0.1, 1);
			
			-- Draw the motion blur.
			DrawMotionBlur(self.DrunkBlur, 1, 0);
		else
			self.DrunkBlur = 1;
		end;
	end;
	
	-- Set some information.
	self.ColorModify["$pp_colour_brightness"] = 0;
	self.ColorModify["$pp_colour_contrast"] = 1;
	self.ColorModify["$pp_colour_colour"] = color;
	self.ColorModify["$pp_colour_addr"] = 0;
	self.ColorModify["$pp_colour_addg"] = 0;
	self.ColorModify["$pp_colour_addb"] = 0;
	self.ColorModify["$pp_colour_mulr"] = 0;
	self.ColorModify["$pp_colour_mulg"] = 0;
	self.ColorModify["$pp_colour_mulb"] = 0;
	
	-- Call a gamemode hook.
	hook.Call("PlayerAdjustColorModify", kuroScript.frame, self.ColorModify);
	
	-- Draw the modified color.
	DrawColorModify(self.ColorModify);
end;

-- Called when the chat box is opened.
function kuroScript.frame:ChatBoxOpened() end;

-- Called when the chat box is closed.
function kuroScript.frame:ChatBoxClosed(textTyped) end;

-- Called when the chat box text has been typed.
function kuroScript.frame:ChatBoxTextTyped(text)
	if (self.LastChatBoxText) then
		if (self.LastChatBoxText[1] != text) then
			if (#self.LastChatBoxText >= 25) then
				table.remove(self.LastChatBoxText, 25);
			end;
		else
			return;
		end;
	else
		self.LastChatBoxText = {};
	end;
	
	-- Insert some information.
	table.insert(self.LastChatBoxText, 1, text);
end;

-- Called when the calc view table should be adjusted.
function kuroScript.frame:CalcViewAdjustTable(view) end;

-- Called when the chat box info should be adjusted.
function kuroScript.frame:ChatBoxAdjustInfo(info) end;

-- Called when the chat box text has changed.
function kuroScript.frame:ChatBoxTextChanged(previousText, newText) end;

-- Called when the chat box has had a key code typed in.
function kuroScript.frame:ChatBoxKeyCodeTyped(code, text)
	if (code == KEY_UP) then
		if (self.LastChatBoxText) then
			local k, v;
			
			-- Loop through each value in a table.
			for k, v in pairs(self.LastChatBoxText) do
				if ( v == text and self.LastChatBoxText[k + 1] ) then
					return self.LastChatBoxText[k + 1];
				end;
			end;
			
			-- Check if a statement is true.
			if ( self.LastChatBoxText[1] ) then
				return self.LastChatBoxText[1];
			end;
		end;
	end;
end;

-- Called when a notification should be adjusted.
function kuroScript.frame:NotificationAdjustInfo(info) end;

-- Called when the local player's business item should be adjusted.
function kuroScript.frame:PlayerAdjustBusinessItemTable(itemTable) end;

-- Called when the local player's vocation model info should be adjusted.
function kuroScript.frame:PlayerAdjustVocationModelInfo(vocation, info) end;

-- Called when the local player's headbob info should be adjusted.
function kuroScript.frame:PlayerAdjustHeadbobInfo(info)
	local drunk = kuroScript.player.GetDrunk();
	local scale = KS_CONVAR_HEADBOBSCALE:GetInt();
	
	-- Check if a statement is true.
	if ( tonumber(scale) ) then
		scale = math.Clamp(scale, 0, 1);
	else
		scale = 1;
	end;
	
	-- Check if a statement is true.
	if ( g_LocalPlayer:IsRunning() ) then
		if (scale > 0) then
			info.multiplier = (info.multiplier * 0.75) * scale;
			info.pitch = (info.pitch * 2) * scale;
			info.yaw = (info.yaw * 64) * scale;
		end;
	elseif ( g_LocalPlayer:IsJogging() ) then
		if (scale > 0) then
			info.multiplier = (info.multiplier * 0.75) * scale;
			info.pitch = (info.pitch * 2) * scale;
			info.yaw = (info.yaw * 32) * scale;
		end;
	elseif (g_LocalPlayer:GetVelocity():Length() > 0) then
		if (scale > 0) then
			info.multiplier = (info.multiplier * 0.5) * scale;
			info.pitch = (info.pitch * 4) * scale;
			info.yaw = (info.yaw * 16) * scale;
		end;
	else
		info.multiplier = info.multiplier * 0.5;
		info.pitch = info.pitch * 0.5;
		info.yaw = info.yaw * 0.5;
	end;
	
	-- Check if a statement is true.
	if (drunk) then
		info.multiplier = info.multiplier * math.min(drunk * 0.25, 4);
		info.pitch = info.pitch * math.min(drunk, 4);
		info.yaw = info.yaw * math.min(drunk, 4);
	end;
end;

-- Called when the local player's color modify should be adjusted.
function kuroScript.frame:PlayerAdjustColorModify(colorModify) end;

-- Called to get whether the local player's screen should fade black.
function kuroScript.frame:ShouldPlayerScreenFadeBlack()
	if ( !g_LocalPlayer:Alive() or g_LocalPlayer:IsRagdolled(RAGDOLL_FALLENOVER) ) then
		if ( !hook.Call("PlayerCanSeeUnconscious", self) ) then
			return true;
		end;
	end;
	
	-- Return false to break the function.
	return false;
end;

-- Called when the character selection background should be drawn.
function kuroScript.frame:ShouldDrawCharacterSelectionBackground()
	return true;
end;

-- Called when the character selection fault should be drawn.
function kuroScript.frame:ShouldDrawCharacterSelectionFault(fault)
	return true;
end;

-- Called when the character loading background should be drawn.
function kuroScript.frame:ShouldDrawCharacterLoadingBackground(alpha)
	return true;
end;

-- Called when the score board should be drawn.
function kuroScript.frame:HUDDrawScoreBoard()
	self.BaseClass:HUDDrawScoreBoard(player);
	
	-- Set some information.
	local drawCharacterLoading;
	local drawCharacterFault;
	local curTime = UnPredictedCurTime();
	
	-- Check if a statement is true.
	if ( !g_LocalPlayer:HasInitialized() ) then
		if ( !self:IsChoosingCharacter() ) then
			drawCharacterLoading = true;
		else
			if ( hook.Call("ShouldDrawCharacterSelectionBackground", self) ) then
				draw.RoundedBox( 0, 0, 0, ScrW(), ScrH(), Color(0, 0, 0, 255) );
			end;
			
			-- Call a gamemode hook.
			hook.Call("HUDPaintCharacterSelection", self);
			
			-- Set some information.
			local fault = self:GetCharacterFault();
			
			-- Check if a statement is true.
			if (fault) then
				if ( hook.Call("ShouldDrawCharacterSelectionFault", self, fault) ) then
					drawCharacterFault = fault;
				end;
			end;
		end;
	else
		if (!self.CharacterLoadingFinishTime) then
			local loadingTime = hook.Call("GetCharacterLoadingTime", self);
			
			-- Set some information.
			self.CharacterLoadingDelay = loadingTime;
			self.CharacterLoadingFinishTime = curTime + loadingTime;
		end;
		
		-- Calculate the screen fading.
		self:CalculateScreenFading();
		
		-- Check if a statement is true.
		if ( !self:IsUsingCamera() ) then
			hook.Call("HUDPaintForeground", self);
			
			-- Set some information.
			local cinematic = self.Cinematics[1];
			
			-- Check if a statement is true.
			if (cinematic) then
				self:DrawCinematic(cinematic, curTime);
			end;
		end;
		
		-- Check if a statement is true.
		if (self.CharacterLoadingFinishTime > curTime) then
			drawCharacterLoading = true;
		elseif (!self.CinematicScreenDone) then
			self:DrawCinematicIntro(curTime);
		end;
	end;
	
	-- Call a gamemode hook.
	hook.Call("HUDPaintImportant", self);
	
	-- Check if a statement is true.
	if (drawCharacterLoading) then
		local alpha = 255;
		
		-- Check if a statement is true.
		if (self.CharacterLoadingFinishTime) then
			alpha = math.Clamp( (255 / self.CharacterLoadingDelay) * (self.CharacterLoadingFinishTime - curTime), 0, 255);
		end;
		
		-- Call a gamemode hook.
		hook.Call("HUDPaintCharacterLoading", self, alpha);
	elseif (drawCharacterFault) then
		self:DrawSimpleText(drawCharacterFault, ScrW() / 2, 16, Color(255, 50, 50, 255), 1, 1);
	end;
end;

-- Called when the top bars are needed.
function kuroScript.frame:GetTopBars(topBars)
	if (g_LocalPlayer:Health() > 0) then self:DrawHealthBar(); end;
	if (g_LocalPlayer:Armor() > 0) then self:DrawArmorBar(); end;
	
	-- Draw the ammo bars.
	self:DrawAmmoBars();
end;

-- Called when the top bars should be destroyed.
function kuroScript.frame:DestroyTopBars(topBars) end;

-- Called when the top text is needed.
function kuroScript.frame:GetTopText(topText) end;

-- Called when the top text should be destroyed.
function kuroScript.frame:DestroyTopText(topText) end;

-- Called when the chat box position is needed.
function kuroScript.frame:GetChatBoxPosition(rightBox, leftBox)
	if ( (g_LocalPlayer:IsRagdolled(RAGDOLL_FALLENOVER) and self.BlackFadeIn and self.BlackFadeIn == 255) or !leftBox ) then
		return {x = 8, y = ScrH() - 40};
	else
		return {x = 8, y = ScrH() - leftBox.height - 48};
	end;
end;

-- Called when the cinematic intro info is needed.
function kuroScript.frame:GetCinematicIntroInfo() end;

-- Called when the character loading time is needed.
function kuroScript.frame:GetCharacterLoadingTime() return 3; end;

-- Called when a player's HUD should be painted.
function kuroScript.frame:HUDPaintPlayer(player) end;

-- Called when the HUD should be painted.
function kuroScript.frame:HUDPaint()
	if ( g_LocalPlayer:HasInitialized() ) then
		if ( !self:IsUsingCamera() ) then
			self.BaseClass:HUDPaint();
			
			-- Check if a statement is true.
			if ( !self:IsUsingTool() ) then
				self:DrawAlerts();
				self:DrawTopText();
				self:DrawTopBars();
			end;
			
			-- Set some information.
			local rightBox, leftBox = self:DrawPlayerInfo();
			local position = hook.Call("GetChatBoxPosition", self, rightBox, leftBox);
			local k, v;
			
			-- Check if a statement is true.
			if (position and position.x and position.y) then
				if (!kuroScript.chatBox.position) then
					kuroScript.chatBox.position = {};
				end;
				
				-- Set some information.
				kuroScript.chatBox.position.x = position.x;
				kuroScript.chatBox.position.y = position.y;
			end;
			
			-- Check if a statement is true.
			if ( !self:IsScreenFadedBlack() ) then
				for k, v in ipairs( g_Player.GetAll() ) do
					if (v:HasInitialized() and v != g_LocalPlayer) then
						hook.Call("HUDPaintPlayer", self, v);
					end;
				end;
			end;
		end;
	end;
end;

-- Called when a player starts using voice.
function kuroScript.frame:PlayerStartVoice(player)
	if ( kuroScript.config.Get("local_voice"):Get() ) then
		if ( player:IsRagdolled(RAGDOLL_FALLENOVER) or !player:Alive() ) then
			return;
		end;
	end;
	
	-- Check if a statement is true.
	if (self.BaseClass and self.BaseClass.PlayerStartVoice) then
		self.BaseClass:PlayerStartVoice(player);
	end;
end;

-- Called to check if a player does have an access flag.
function kuroScript.frame:PlayerDoesHaveAccessFlag(player, flag)
	if ( string.find(kuroScript.config.Get("default_access"):Get(), flag) ) then
		return true;
	end;
end;

-- Called to check if a player does know another player.
function kuroScript.frame:PlayerDoesKnowPlayer(player, status, simple, default)
	return default;
end;

-- Called when a player's name should be shown as anonymous.
function kuroScript.frame:PlayerCanShowAnonymous(player, x, y, Color, alpha) return true; end;

-- Called when the target player's name is needed.
function kuroScript.frame:GetTargetPlayerName(player) return player:Name(); end;

-- Called when a player begins typing.
function kuroScript.frame:StartChat(team) return true; end;

-- Called when a player says something.
function kuroScript.frame:OnPlayerChat(player, text, teamOnly, playerIsDead)
	if ( ValidEntity(player) ) then
		kuroScript.chatBox.Decode(player, player:Name(), text, {}, "none");
	else
		kuroScript.chatBox.Decode(nil, "Console", text, {}, "chat");
	end;
	
	-- Return true to break the function.
	return true;
end;

-- Called when chat text is received from the server
function kuroScript.frame:ChatText(index, name, text, class)
	if (class == "none") then
		kuroScript.chatBox.Decode(g_Player.GetByID(index), name, text, {}, "none");
	end;
	
	-- Return true to break the function.
	return true;
end;

-- Called when the scoreboard should be created.
function kuroScript.frame:CreateScoreboard() end;

-- Called when the scoreboard should be shown.
function kuroScript.frame:ScoreboardShow()
	if (kuroScript.menu.panel) then
		kuroScript.menu.panel:SetOpen(true);
	else
		kuroScript.menu.Create(true);
	end;
end;

-- Called when the scoreboard should be hidden.
function kuroScript.frame:ScoreboardHide()
	if (kuroScript.menu.panel) then
		kuroScript.menu.panel:SetOpen(false);
	end;
end;

-- Hook a user message.
usermessage.Hook("ks_PlaySound", function(msg)
	surface.PlaySound( msg:ReadString() );
end);

-- Set some information.
local playerMeta = FindMetaTable("Player");
local entityMeta = FindMetaTable("Entity");

-- Set some information.
playerMeta.SteamName = playerMeta.Name;

-- A function to get a player's name.
function playerMeta:Name()
	local name = self:GetSharedVar("ks_Name");
	
	-- Check if a statement is true.
	if (!name or name == "") then
		return self:SteamName();
	else
		return name;
	end;
end;

-- A function to get whether a player is running.
function playerMeta:IsRunning()
	if ( self:KeyDown(IN_SPEED) ) then
		if ( self:Alive() and !self:IsRagdolled() and !self:InVehicle() and !self:Crouching() ) then
			local sprintSpeed = self:GetNetworkedFloat("SprintSpeed");
			local velocity = self:GetVelocity():Length();
			
			-- Check if a statement is true.
			if (velocity >= math.max(sprintSpeed - 25, 25) and velocity > 0) then
				return true;
			end;
		end;
	end;
end;

-- A function to get whether a player is jogging.
function playerMeta:IsJogging()
	if ( !self:IsRunning() and (self:GetSharedVar("ks_Jogging") or testSpeed) ) then
		if ( self:Alive() and !self:IsRagdolled() and !self:InVehicle() and !self:Crouching() ) then
			local walkSpeed = self:GetNetworkedFloat("WalkSpeed");
			local velocity = self:GetVelocity():Length();
			
			-- Check if a statement is true.
			if (velocity >= math.max(walkSpeed - 25, 25) and velocity > 0) then
				return true;
			end;
		end;
	end;
end;

-- A function to get whether a player is ragdolled.
function playerMeta:IsRagdolled(exception, entityless)
	return kuroScript.player.IsRagdolled(self, exception, entityless);
end;

-- A function to get a player's shared variable.
function entityMeta:GetSharedVar(key)
	if ( self:IsPlayer() ) then
		return kuroScript.player.GetSharedVar(self, key);
	else
		return kuroScript.entity.GetSharedVar(self, key);
	end;
end;

-- A function to get whether a player has initialized.
function playerMeta:HasInitialized()
	if ( ValidEntity(self) ) then
		return self:GetSharedVar("ks_Initialized");
	end;
end;

-- A function to get a player's wages name.
function playerMeta:GetWagesName()
	return kuroScript.player.GetWagesName(self);
end;

-- A function to get a player's maximum armor.
function playerMeta:GetMaxArmor(armor)
	local maxArmor = self:GetSharedVar("ks_MaxArmor");
	
	-- Check if a statement is true.
	if (maxArmor > 0) then
		return maxArmor;
	else
		return 100;
	end;
end;

-- A function to get a player's maximum health.
function playerMeta:GetMaxHealth(health)
	local maxHealth = self:GetSharedVar("ks_MaxHealth");
	
	-- Check if a statement is true.
	if (maxHealth > 0) then
		return maxHealth;
	else
		return 100;
	end;
end;

-- A function to get a player's ragdoll state.
function playerMeta:GetRagdollState()
	return kuroScript.player.GetRagdollState(self);
end;

-- A function to get a player's ragdoll entity.
function playerMeta:GetRagdollEntity()
	return kuroScript.player.GetRagdollEntity(self);
end;

-- Set some information.
playerMeta.GetName = playerMeta.Name;
playerMeta.Nick = playerMeta.Name;