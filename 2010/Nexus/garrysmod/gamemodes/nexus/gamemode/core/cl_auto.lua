--[[
Name: "cl_auto.lua".
Product: "nexus".
--]]

include("sh_auto.lua");

surface.CreateFont("Arial", ScaleToWideScreen(16), 700, true, false, "nx_MainText");
surface.CreateFont("Arial", ScaleToWideScreen(45), 700, true, false, "nx_MenuTextBig");
surface.CreateFont("Arial", ScaleToWideScreen(18), 700, true, false, "nx_MenuTextTiny");
surface.CreateFont("Arial", ScaleToWideScreen(24), 700, true, false, "nx_MenuTextSmall");
surface.CreateFont("Arial", ScaleToWideScreen(60), 700, true, false, "nx_IntroTextBig");
surface.CreateFont("Arial", ScaleToWideScreen(18), 700, true, false, "nx_IntroTextTiny");
surface.CreateFont("Arial", ScaleToWideScreen(24), 700, true, false, "nx_IntroTextSmall");
surface.CreateFont("Arial", ScaleToWideScreen(2048), 700, true, false, "nx_Large3D2D");
surface.CreateFont("Trebuchet", ScaleToWideScreen(30), 700, true, false, "nx_CinematicText");

timer.Destroy("HintSystem_OpeningMenu");
timer.Destroy("HintSystem_Annoy2");
timer.Destroy("HintSystem_Annoy1");

hook.NexusCall = hook.Call;

local NexusAddWorldTip = AddWorldTip;
local NexusScrW = ScrW;
local NexusScrH = ScrH;

local g_Player = g_Player;
local g_Team = g_Team;
local g_File = g_File;

local CurTime = CurTime;
local hook = hook;

-- A function to call a hook.
function hook.Call(name, gamemode, ...)
	g_LocalPlayer = LocalPlayer();
	
	if (!gamemode) then
		gamemode = NEXUS;
	end;
	
	local callCachedHook = nexus.mount.CallCachedHook;
	local arguments = {...};
	local hookCall = hook.NexusCall;
	local value = callCachedHook(name, arguments);
	
	if (value == nil) then
		return hookCall( name, gamemode, unpack(arguments) );
	else
		return value;
	end;
end;

-- A function to add a world tip.
function AddWorldTip(entIndex, text, dieTime, position, entity)
	local weapon = g_LocalPlayer:GetActiveWeapon();
	
	if ( IsValid(weapon) ) then
		if (string.lower( weapon:GetClass() ) == "gmod_tool") then
			if (IsValid(entity) and entity.GetPlayerName) then
				if ( g_LocalPlayer:Name() == entity:GetPlayerName() ) then
					NexusAddWorldTip(entIndex, text, dieTime, position, entity);
				end;
			end;
		end;
	end;
end;

-- A function to get the screen width.
function ScrW()
	local width = NexusScrW();
	
	if (width == 160) then
		return NEXUS.LastScreenWidth or width;
	else
		NEXUS.LastScreenWidth = width;
		
		return width;
	end;
end

-- A function to get the screen height.
function ScrH()
	local height = NexusScrH();
	
	if (height == 27) then
		return NEXUS.LastScreenHeight or height;
	else
		NEXUS.LastScreenHeight = height;
		
		return height;
	end;
end

NEXUS:HookDataStream("RunCommand", function(data)
	RunConsoleCommand( unpack(data) );
end);

NEXUS:HookDataStream("HiddenCommands", function(data)
	for k, v in pairs(data) do
		for k2, v2 in pairs(nexus.command.stored) do
			if (NEXUS:GetShortCRC(k2) == v) then
				nexus.command.SetHidden(k2, true);
				
				break;
			end;
		end;
	end;
end);

usermessage.Hook("nx_dsStart", function(msg)
	NX_DS_NAME = msg:ReadString();
	NX_DS_DATA = msg:ReadString();
	NX_DS_INDEX = msg:ReadShort();
	
	if (NX_DS_INDEX == 1) then
		if ( NEXUS.DataStreamHooks[NX_DS_NAME] ) then
			NEXUS.DataStreamHooks[NX_DS_NAME]( glon.decode(NX_DS_DATA) );
		end;
		
		NX_DS_NAME, NX_DS_DATA, NX_DS_INDEX = nil, nil, nil;
	end;
end);

usermessage.Hook("nx_dsData", function(msg)
	if (NX_DS_NAME and NX_DS_DATA and NX_DS_INDEX) then
		local data = msg:ReadString();
		local index = msg:ReadShort();
		
		NX_DS_DATA = NX_DS_DATA..data;
		
		if (NX_DS_INDEX == index) then
			if ( NEXUS.DataStreamHooks[NX_DS_NAME] ) then
				NEXUS.DataStreamHooks[NX_DS_NAME]( glon.decode(NX_DS_DATA) );
			end;
			
			NX_DS_NAME, NX_DS_DATA, NX_DS_INDEX = nil, nil, nil;
		end;
	end;
end);

usermessage.Hook("nx_DataStreaming", function(msg)
	NEXUS:StartDataStream("DataStreamInfoSent", true);
end);

usermessage.Hook("nx_DataStreamed", function(msg)
	NEXUS.DataHasStreamed = true;
end);

usermessage.Hook("nx_QuizCompleted", function(msg)
	if ( !msg:ReadBool() ) then
		if ( !nexus.quiz.GetCompleted() ) then
			gui.EnableScreenClicker(true);
			
			nexus.quiz.panel = vgui.Create("nx_Quiz");
			nexus.quiz.panel:Populate();
			nexus.quiz.panel:MakePopup();
		end;
	else
		local characterPanel = nexus.character.GetPanel();
		local quizPanel = nexus.quiz.GetPanel();
		
		nexus.quiz.SetCompleted(true);
		
		if (quizPanel) then
			quizPanel:Remove();
		end;
	end;
end);

usermessage.Hook("nx_RecogniseMenu", function(msg)
	local menu = NEXUS:AddMenuFromData( nil, {
		["All characters within whispering range."] = function()
			NEXUS:StartDataStream("RecogniseOption", "whisper");
		end,
		["All characters within yelling range."] = function()
			NEXUS:StartDataStream("RecogniseOption", "yell");
		end,
		["All characters within talking range"] = function()
			NEXUS:StartDataStream("RecogniseOption", "talk");
		end
	} );
	
	if ( IsValid(menu) ) then
		menu:SetPos( (ScrW() / 2) - (menu:GetWide() / 2), (ScrH() / 2) - (menu:GetTall() / 2) );
	end;
	
	NEXUS:SetRecogniseMenu(menu);
end);

usermessage.Hook("nx_NexusIntro", function(msg)
	if (!NEXUS.NexusIntroFadeOut) then
		local introImage = nexus.schema.GetOption("intro_image");
		local duration = 16;
		local curTime = UnPredictedCurTime();
		
		if (introImage != "") then
			duration = 32;
		end;
		
		NEXUS.NexusIntroWhiteScreen = curTime + (FrameTime() * 8);
		NEXUS.NexusIntroFadeOut = curTime + duration;
		NEXUS.NexusIntroSound = CreateSound(g_LocalPlayer, "music/hl2_song23_suitsong3.mp3");
		NEXUS.NexusIntroSound:PlayEx(0.75, 100);
		
		timer.Simple(duration - 4, function()
			NEXUS.NexusIntroSound:FadeOut(4);
			NEXUS.NexusIntroSound = nil;
		end);
		
		surface.PlaySound("buttons/button1.wav");
	end;
end);

usermessage.Hook("nx_SharedVar", function(msg)
	local key = msg:ReadString();
	local sharedVarData = nexus.player.sharedVars[key];
	
	if (sharedVarData) then
		local class = NEXUS:ConvertUserMessageClass(sharedVarData.class);
		
		if (class) then
			sharedVarData.value = msg["Read"..class](msg);
		end;
	end;
end);

usermessage.Hook("nx_HideCommand", function(msg)
	local index = msg:ReadLong();
	
	for k, v in pairs(nexus.command.stored) do
		if (NEXUS:GetShortCRC(k) == index) then
			nexus.command.SetHidden( k, msg:ReadBool() );
			
			break;
		end;
	end;
end);

usermessage.Hook("nx_ClearRecognisedNames", function(msg)
	NEXUS.RecognisedNames = {};
end);

usermessage.Hook("nx_RecognisedName", function(msg)
	local key = msg:ReadLong();
	local status = msg:ReadShort();
	
	if (status > 0) then
		NEXUS.RecognisedNames[key] = status;
	else
		NEXUS.RecognisedNames[key] = nil;
	end;
end);

NEXUS:HookDataStream("Hint", function(data)
	NEXUS:AddTopHint(data.text, data.delay, data.color, data.noSound);
end);

usermessage.Hook("nx_PhysDesc", function(msg)
	Derma_StringRequest("PhysDesc", "What do you want to change your physical description to?", g_LocalPlayer:GetSharedVar("sh_PhysDesc"), function(text)
		NEXUS:RunCommand("CharPhysDesc", text);
	end);
end);

NEXUS:HookDataStream("CinematicText", function(data)
	NEXUS:AddCinematicText(data.text, data.color, data.hangTime);
end);

usermessage.Hook("nx_Notification", function(msg)
	local text = msg:ReadString();
	local class = msg:ReadShort();
	local sound = "ambient/water/drip2.wav";
	
	if (class == 1) then
		sound = "buttons/button10.wav";
	elseif (class == 2) then
		sound = "buttons/button17.wav";
	elseif (class == 3) then
		sound = "buttons/bell1.wav";
	elseif (class == 4) then
		sound = "buttons/button15.wav";
	end
	
	local info = {
		class = class,
		sound = sound,
		text = text
	};
	
	if ( nexus.mount.Call("NotificationAdjustInfo", info) ) then
		NEXUS:AddNotify(info.text, info.class, 10);
		
		surface.PlaySound(info.sound);
		
		print(info.text);
	end;
end);

concommand.Add("lua_run_nx", function(player, command, arguments)
	if ( player:IsSuperAdmin() ) then
		RunString( table.concat(arguments, " ") );
		
		return;
	end;
	
	print("You do not have access to this command, "..player:Name()..".");
end);

function NEXUS:HUDWeaponPickedUp(...) end;

function NEXUS:HUDItemPickedUp(...) end;

function NEXUS:HUDAmmoPickedUp(...) end;

-- Called when the nexus directory is rebuilt.
function NEXUS:NexusDirectoryRebuilt(panel)
	for k, v in pairs(nexus.command.stored) do
		if ( !nexus.player.HasFlags(g_LocalPlayer, v.access) ) then
			nexus.command.RemoveHelp(v);
		else
			nexus.command.AddHelp(v);
		end;
	end;
end;

-- Called when the local player's storage is rebuilding.
function NEXUS:PlayerStorageRebuilding(panel) end;

-- Called when the local player's storage is rebuilt.
function NEXUS:PlayerStorageRebuilt(panel, categories) end;

-- Called when the local player's business is rebuilt.
function NEXUS:PlayerBusinessRebuilt(panel, categories) end;

-- Called when the local player's inventory is rebuilt.
function NEXUS:PlayerInventoryRebuilt(panel, categories)
	if ( nexus.storage.IsStorageOpen() ) then
		nexus.storage.GetPanel():Rebuild();
	end;
end;

-- Called when nexus config has initialized.
function NEXUS:NexusConfigInitialized(key, value)
	if (key == "cash_enabled" and !value) then
		for k, v in pairs( nexus.item.GetAll() ) do
			v.cost = 0;
		end;
	end;
end;

-- Called when a nexus ConVar has changed.
function NEXUS:NexusConVarChanged(name, previousValue, newValue) end;

-- Called when nexus config has changed.
function NEXUS:NexusConfigChanged(key, data, previousValue, newValue) end;

-- Called when an entity's menu options are needed.
function NEXUS:GetEntityMenuOptions(entity, options)
	local class = entity:GetClass();
	local generator = nexus.generator.Get(class);
	
	if (class == "nx_item") then
		local index = entity:GetSharedVar("sh_Index");
		
		if (index != 0) then
			local itemTable = nexus.item.Get(index);
			
			if (itemTable) then
				local useText = itemTable.useText or "Use";
				
				if (itemTable.OnUse) then
					options[useText] = "nx_itemUse";
				end;
				
				options["Take"] = "nx_itemTake";
				options["Examine"] = {
					arguments = true,
					toolTip = itemTable.description,
					order = 1
				};
			end;
		end;
	elseif (class == "nx_shipment") then
		options["Open"] = "nx_shipmentOpen";
	elseif (class == "nx_cash") then
		options["Take"] = "nx_cashTake";
	elseif (generator) then
		if ( !entity.CanSupply or entity:CanSupply() ) then
			options["Supply"] = "nx_generatorSupply";
		end;
	end;
end;

-- Called when the GUI mouse is released.
function NEXUS:GUIMouseReleased(code)
	if ( !nexus.config.Get("use_opens_entity_menus"):Get() ) then
		if ( vgui.CursorVisible() ) then
			local trace = g_LocalPlayer:GetEyeTrace();
			
			if (IsValid(trace.Entity) and trace.HitPos:Distance( g_LocalPlayer:GetShootPos() ) <= 80) then
				local menu = self:HandleEntityMenu(trace.Entity);
				
				if ( IsValid(menu) ) then
					menu:SetPos( gui.MouseX() - (menu:GetWide() / 2), gui.MouseY() - (menu:GetTall() / 2) );
				end;
			end;
		end;
	end;
end;

-- Called when a key is released.
function NEXUS:KeyRelease(player, key)
	if ( nexus.config.Get("use_opens_entity_menus"):Get() ) then
		if (key == IN_USE) then
			local activeWeapon = player:GetActiveWeapon();
			local trace = g_LocalPlayer:GetEyeTraceNoCursor();
			
			if (IsValid(activeWeapon) and activeWeapon:GetClass() == "weapon_physgun") then
				if ( player:KeyDown(IN_ATTACK) ) then
					return;
				end;
			end;
			
			if (IsValid(trace.Entity) and trace.HitPos:Distance( g_LocalPlayer:GetShootPos() ) <= 80) then
				local menu = self:HandleEntityMenu(trace.Entity);
				
				if ( IsValid(menu) ) then
					menu:SetPos( (ScrW() / 2) - (menu:GetWide() / 2), (ScrH() / 2) - (menu:GetTall() / 2) );
				end;
			end;
		end;
	end;
end;

-- Called when the local player is created.
function NEXUS:LocalPlayerCreated() end;

-- Called when the client initializes.
function NEXUS:Initialize()
	NX_CONVAR_TWELVEHOURCLOCK = self:CreateClientConVar("nx_twelvehourclock", 0, true, true);
	NX_CONVAR_SHOWTIMESTAMPS = self:CreateClientConVar("nx_showtimestamps", 0, true, true);
	NX_CONVAR_MAXCHATLINES = self:CreateClientConVar("nx_maxchatlines", 10, true, true);
	NX_CONVAR_HEADBOBSCALE = self:CreateClientConVar("nx_headbobscale", 1, true, true);
	NX_CONVAR_SHOWSERVER = self:CreateClientConVar("nx_showserver", 1, true, true);
	NX_CONVAR_SHOWNEXUS = self:CreateClientConVar("nx_shownexus", 1, true, true);
	NX_CONVAR_SHOWHINTS = self:CreateClientConVar("nx_showhints", 1, true, true);
	NX_CONVAR_ADMINESP = self:CreateClientConVar("nx_adminesp", 0, true, true);
	NX_CONVAR_SHOWLOG = self:CreateClientConVar("nx_showlog", 1, true, true);
	NX_CONVAR_SHOWOOC = self:CreateClientConVar("nx_showooc", 1, true, true);
	NX_CONVAR_SHOWIC = self:CreateClientConVar("nx_showic", 1, true, true);
	
	nexus.mount.Call("NexusInitialized");
end;

-- Called when nexus has initialized.
function NEXUS:NexusInitialized() end;

-- Called when a player's phys desc override is needed.
function NEXUS:GetPlayerPhysDescOverride(player, physDesc) end;

-- Called when a player's door access name is needed.
function NEXUS:GetPlayerDoorAccessName(player, door, owner)
	return player:Name();
end;

-- Called when a player should show on the door access list.
function NEXUS:PlayerShouldShowOnDoorAccessList(player, door, owner)
	return true;
end;

-- Called when a player should show on the scoreboard.
function NEXUS:PlayerShouldShowOnScoreboard(player)
	return true;
end;

-- Called when the local player attempts to zoom.
function NEXUS:PlayerCanZoom() return true; end;

-- Called when the local player attempts to see a business item.
function NEXUS:PlayerCanSeeBusinessItem(item) return true; end;

-- Called when a player presses a bind.
function NEXUS:PlayerBindPress(player, bind, press)
	local weapon = g_LocalPlayer:GetActiveWeapon();
	local prefix = nexus.config.Get("command_prefix"):Get();
	
	if ( player:GetRagdollState() == RAGDOLL_FALLENOVER and string.find(bind, "+jump") ) then
		NEXUS:RunCommand("CharGetUp");
	elseif ( string.find(bind, "toggle_zoom") ) then
		return true;
	elseif ( string.find(bind, "+zoom") ) then
		if ( !nexus.mount.Call("PlayerCanZoom") ) then
			return true;
		end;
	end;
	
	if ( string.find(bind, "+attack") or string.find(bind, "+attack2") ) then
		if ( nexus.storage.IsStorageOpen() ) then
			return true;
		end;
	end;
	
	if ( nexus.config.Get("block_inv_binds"):Get() ) then
		if ( string.find(string.lower(bind), prefix.."invaction")
		or string.find(string.lower(bind), "nx invaction") ) then
			return true;
		end;
	end;
	
	return nexus.mount.Call("TopLevelPlayerBindPress", player, bind, press);
end;

-- Called when a player presses a bind at the top level.
function NEXUS:TopLevelPlayerBindPress(player, bind, press)
	return self.BaseClass:PlayerBindPress(player, bind, press);
end;

-- Called when the local player attempts to see while unconscious.
function NEXUS:PlayerCanSeeUnconscious()
	return false;
end;

-- Called when the map has loaded all the entities.
function NEXUS:InitPostEntity()
	nexus.entity.RegisterSharedVars(GetWorldEntity(), self.GlobalSharedVars);
end;

-- Called when the local player's move data is created.
function NEXUS:CreateMove(userCmd)
	local ragdollEyeAngles = self:GetRagdollEyeAngles();
	
	if ( ragdollEyeAngles and IsValid(g_LocalPlayer) ) then
		local defaultSensitivity = 0.05;
		local sensitivity = defaultSensitivity * (nexus.mount.Call("AdjustMouseSensitivity", defaultSensitivity) or defaultSensitivity);
		
		if (sensitivity <= 0) then
			sensitivity = defaultSensitivity;
		end;
		
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
function NEXUS:CalcView(player, origin, angles, fov)
	if ( g_LocalPlayer:IsRagdolled() ) then
		local ragdollEntity = g_LocalPlayer:GetRagdollEntity();
		local ragdollState = g_LocalPlayer:GetRagdollState();
		
		if (self.BlackFadeIn == 255) then
			return {origin = Vector(20000, 0, 0), angles = Angle(0, 0, 0), fov = fov};
		else
			local eyes = ragdollEntity:GetAttachment( ragdollEntity:LookupAttachment("eyes") );
			
			if (eyes) then
				local ragdollEyeAngles = eyes.Ang + self:GetRagdollEyeAngles();
				local physicsObject = ragdollEntity:GetPhysicsObject();
				
				if ( IsValid(physicsObject) ) then
					local velocity = physicsObject:GetVelocity().z;
					
					if (velocity <= -1000 and g_LocalPlayer:GetMoveType() == MOVETYPE_WALK) then
						ragdollEyeAngles.p = ragdollEyeAngles.p + math.sin( UnPredictedCurTime() ) * math.abs( (velocity + 1000) - 16 );
					end;
				end;
				
				return {origin = eyes.Pos, angles = ragdollEyeAngles, fov = fov};
			else
				return self.BaseClass:CalcView(player, origin, angles, fov);
			end;
		end;
	elseif ( !g_LocalPlayer:Alive() ) then
		return {origin = Vector(20000, 0, 0), angles = Angle(0, 0, 0), fov = fov};
	elseif ( nexus.config.Get("enable_headbob"):Get() ) then
		if ( player:IsOnGround() ) then
			local frameTime = FrameTime();
			
			if ( !nexus.player.IsNoClipping(player) ) then
				local approachTime = frameTime * 2;
				local info = {multiplier = 10, pitch = 0.2, yaw = 0.04};
				
				if (!self.HeadbobAngle) then
					self.HeadbobAngle = 0;
				end;
				
				if (!self.HeadbobInfo) then
					self.HeadbobInfo = info;
				end;
				
				nexus.mount.Call("PlayerAdjustHeadbobInfo", info);
				
				self.HeadbobInfo.multiplier = math.Approach(self.HeadbobInfo.multiplier, info.multiplier, approachTime);
				self.HeadbobInfo.pitch = math.Approach(self.HeadbobInfo.pitch, info.pitch, approachTime);
				self.HeadbobInfo.yaw = math.Approach(self.HeadbobInfo.yaw, info.yaw, approachTime);
				self.HeadbobAngle = self.HeadbobAngle + (self.HeadbobInfo.multiplier * frameTime);
				
				angles.p = angles.p + (math.sin(self.HeadbobAngle) * self.HeadbobInfo.pitch);
				angles.y = angles.y + (math.cos(self.HeadbobAngle) * self.HeadbobInfo.yaw);
			end;
		end;
	end;
	
	local velocity = g_LocalPlayer:GetVelocity().z;
	
	if (velocity <= -1000 and g_LocalPlayer:GetMoveType() == MOVETYPE_WALK) then
		angles.p = angles.p + math.sin( UnPredictedCurTime() ) * math.abs( (velocity + 1000) - 16 );
	end;
	
	local weapon = g_LocalPlayer:GetActiveWeapon();
	local view = self.BaseClass:CalcView(player, origin, angles, fov);
	
	if ( IsValid(weapon) ) then
		local weaponRaised = nexus.player.GetWeaponRaised(g_LocalPlayer);
		
		if (!g_LocalPlayer:HasInitialized() or !nexus.config.HasInitialized()
		or g_LocalPlayer:GetMoveType() == MOVETYPE_OBSERVER) then
			weaponRaised = nil;
		end;
		
		if (!weaponRaised) then
			local originalOrigin = Vector(origin.x, origin.y, origin.z);
			local originalAngles = Angle(angles.p, angles.y, angles.r);
			local originMod = Vector(-3.0451, -1.6419, -0.5771);
			local anglesMod = Angle(-12.9015, -47.2118, 5.1173);
			local itemTable = nexus.item.GetWeapon(weapon);
			
			if (itemTable and itemTable.loweredAngles) then
				anglesMod = itemTable.loweredAngles;
			elseif (weapon.LoweredAngles) then
				anglesMod = weapon.LoweredAngles;
			end;
			
			if (itemTable and itemTable.loweredOrigin) then
				originMod = itemTable.loweredOrigin;
			elseif (weapon.LoweredOrigin) then
				originMod = weapon.LoweredOrigin;
			end;
			
			originalAngles:RotateAroundAxis(originalAngles:Right(), anglesMod.p);
			originalAngles:RotateAroundAxis(originalAngles:Up(), anglesMod.y);
			originalAngles:RotateAroundAxis(originalAngles:Forward(), anglesMod.r);
			
			originalOrigin = originalOrigin + originMod.x * originalAngles:Right();
			originalOrigin = originalOrigin + originMod.y * originalAngles:Forward();
			originalOrigin = originalOrigin + originMod.z * originalAngles:Up();
			
			view.vm_origin = originalOrigin;
			view.vm_angles = originalAngles;
		end;
	end;
	
	nexus.mount.Call("CalcViewAdjustTable", view);
	
	return view;
end;

-- Called when a HUD element should be drawn.
function NEXUS:HUDShouldDraw(name)
	local blockedElements = {
		"CHudSecondaryAmmo",
		"CHudVoiceStatus",
		"CHudSuitPower",
		"CHudBattery",
		"CHudHealth",
		"CHudAmmo"
	};
	
	if ( !IsValid(g_LocalPlayer) or !g_LocalPlayer:HasInitialized() or self:IsChoosingCharacter() ) then
		if (name != "CHudGMod") then
			return false;
		end;
	elseif (name == "CHudCrosshair") then
		if ( !IsValid(g_LocalPlayer) or g_LocalPlayer:IsRagdolled(RAGDOLL_FALLENOVER) ) then
			return false;
		end;
		
		if ( self.CharacterLoadingFinishTime and self.CharacterLoadingFinishTime > CurTime() ) then
			return false;
		end;
		
		if ( !nexus.config.Get("enable_crosshair"):Get() ) then
			if ( IsValid(g_LocalPlayer) ) then
				local weapon = g_LocalPlayer:GetActiveWeapon();
				
				if ( IsValid(weapon) ) then
					local class = string.lower( weapon:GetClass() );
					
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
	
	return self.BaseClass:HUDShouldDraw(name);
end

-- Called when the menu is opened.
function NEXUS:MenuOpened()
	for k, v in pairs( nexus.menu.GetItems() ) do
		if (v.panel.OnMenuOpened) then
			v.panel:OnMenuOpened();
		end;
	end;
end;

-- Called when the menu is closed.
function NEXUS:MenuClosed()
	for k, v in pairs( nexus.menu.GetItems() ) do
		if (v.panel.OnMenuClosed) then
			v.panel:OnMenuClosed();
		end;
	end;
	
	self:RemoveActiveToolTip();
	
	self:CloseActiveDermaMenus();
end;

-- Called when the character screen's faction characters should be sorted.
function NEXUS:CharacterScreenSortFactionCharacters(faction, a, b)
	return a.name < b.name;
end;

-- Called when the scoreboard's class players should be sorted.
function NEXUS:ScoreboardSortClassPlayers(class, a, b)
	local recogniseA = nexus.player.DoesRecognise(a);
	local recogniseB = nexus.player.DoesRecognise(b);
	
	if (recogniseA and recogniseB) then
		return a:Team() < b:Team();
	elseif (recogniseA) then
		return true;
	else
		return false;
	end;
end;

-- Called when the scoreboard's player info should be adjusted.
function NEXUS:ScoreboardAdjustPlayerInfo(info) end;

-- Called when the menu's items should be adjusted.
function NEXUS:MenuItemsAdd(menuItems)
	local attributesName = nexus.schema.GetOption("name_attributes");
	local overwatchName = nexus.schema.GetOption("name_overwatch");
	local directoryName = nexus.schema.GetOption("name_directory");
	local inventoryName = nexus.schema.GetOption("name_inventory");
	local businessName = nexus.schema.GetOption("name_business");
	
	menuItems:Add("Classes", "nx_Classes", "Choose from a list of available classes.");
	menuItems:Add("Settings", "nx_Settings", "Configure the way nexus works for you.");
	menuItems:Add("Scoreboard", "nx_Scoreboard", "See which players are on the server.");
	menuItems:Add( businessName, "nx_Business", nexus.schema.GetOption("description_business") );
	menuItems:Add( inventoryName, "nx_Inventory", nexus.schema.GetOption("description_inventory") );
	menuItems:Add( directoryName, "nx_Directory", nexus.schema.GetOption("description_directory") );
	menuItems:Add( overwatchName, "nx_Overwatch", nexus.schema.GetOption("description_overwatch") );
	menuItems:Add( attributesName, "nx_Attributes", nexus.schema.GetOption("description_attributes") );
end;

-- Called when the menu's items should be destroyed.
function NEXUS:MenuItemsDestroy(menuItems) end;

-- Called each tick.
function NEXUS:Tick()
	local realCurTime = CurTime();
	local curTime = UnPredictedCurTime();
	local font = nexus.schema.GetFont("player_info_text");
	
	if ( nexus.character.IsPanelPolling() ) then
		local panel = nexus.character.GetPanel();
		
		if ( !panel and nexus.mount.Call("ShouldCharacterMenuBeCreated") ) then
			nexus.character.SetPanelPolling(false);
			nexus.character.isOpen = true;
			
			nexus.character.panel = vgui.Create("nx_CharacterMenu");
			nexus.character.panel:MakePopup();
			nexus.character.panel:ReturnToMainMenu();
			
			nexus.mount.Call("PlayerCharacterScreenCreated", nexus.character.panel);
		end;
	end;
	
	if ( IsValid(g_LocalPlayer) and !self:IsChoosingCharacter() ) then
		self.Bars.bars = {};
		self.PlayerInfoText.text = {};
		self.PlayerInfoText.width = ScrW() * 0.15;
		self.PlayerInfoText.subText = {};
		
		self:DrawHealthBar();
		self:DrawArmorBar();
		
		nexus.mount.Call("GetBars", self.Bars);
		nexus.mount.Call("DestroyBars", self.Bars);
		nexus.mount.Call("GetPlayerInfoText", self.PlayerInfoText);
		nexus.mount.Call("DestroyPlayerInfoText", self.PlayerInfoText);
		
		table.sort(self.Bars.bars, function(a, b)
			if (a.text == "" and b.text == "") then
				return a.priority > b.priority;
			elseif (a.text == "") then
				return true;
			else
				return a.priority > b.priority;
			end;
		end);
		
		table.sort(self.PlayerInfoText.subText, function(a, b)
			return a.priority > b.priority;
		end);
		
		for k, v in ipairs(self.PlayerInfoText.text) do
			self.PlayerInfoText.width = self:AdjustMaximumWidth(font, v.text, self.PlayerInfoText.width);
		end;
		
		for k, v in ipairs(self.PlayerInfoText.subText) do
			self.PlayerInfoText.width = self:AdjustMaximumWidth(font, v.text, self.PlayerInfoText.width);
		end;
		
		self.PlayerInfoText.width = self.PlayerInfoText.width + 16;
		
		if ( nexus.config.Get("fade_dead_npcs"):Get() ) then
			for k, v in pairs( ents.FindByClass("class C_ClientRagdoll") ) do
				if ( !nexus.entity.IsDecaying(v) ) then
					nexus.entity.Decay(v, 300);
				end;
			end;
		end;
	end;
	
	if (!self.NextHandleAttributeBoosts or realCurTime >= self.NextHandleAttributeBoosts) then
		self.NextHandleAttributeBoosts = realCurTime + 3;
		
		for k, v in pairs(nexus.attributes.boosts) do
			for k2, v2 in pairs(v) do
				if (v2.duration and v2.endTime) then
					if (realCurTime > v2.endTime) then
						nexus.attributes.boosts[k][k2] = nil;
					else
						local timeLeft = v2.endTime - realCurTime;
						
						if (timeLeft >= 0) then
							if (v2.default < 0) then
								v2.amount = math.min( (v2.default / v2.duration) * timeLeft, 0 );
							else
								v2.amount = math.max( (v2.default / v2.duration) * timeLeft, 0 );
							end;
						end;
					end;
				end;
			end;
		end;
	end;
end;

-- Called when an entity is created.
function NEXUS:EntityCreated(entity)
	if ( entity == LocalPlayer() ) then
		g_LocalPlayer = entity;
	end;
end;

-- Called each frame.
function NEXUS:Think()
	if (!self.CreatedLocalPlayer) then
		if ( IsValid(g_LocalPlayer) ) then
			nexus.mount.Call("LocalPlayerCreated");
				self:StartDataStream("LocalPlayerCreated", true);
			self.CreatedLocalPlayer = true;
		end;
	end;
	
	self:CallTimerThink( CurTime() );
	self:CalculateHints();
	
	if ( self:IsCharacterScreenOpen() ) then
		local panel = nexus.character.GetPanel();
		
		if (panel) then
			panel:SetVisible( nexus.mount.Call("GetPlayerCharacterScreenVisible", panel) );
		end;
	end;
end;

-- Called when the character loading HUD should be painted.
function NEXUS:HUDPaintCharacterLoading(alpha)
	if ( nexus.mount.Call("ShouldDrawCharacterLoadingBackground", alpha) ) then
		draw.RoundedBox( 0, 0, 0, ScrW(), ScrH(), Color(0, 0, 0, alpha) );
	end;
	
	local cinematicInfo = nexus.mount.Call("GetCinematicIntroInfo");
	local colorWhite = nexus.schema.GetColor("white");
	
	if (cinematicInfo) then
		if (cinematicInfo.title) then
			local cinematicInfoTitle = string.upper(cinematicInfo.title);
			local introTextBigFont = nexus.schema.GetFont("intro_text_big");
			local textWidth, textHeight = self:GetCachedTextSize(introTextBigFont, cinematicInfoTitle);
			
			draw.SimpleText(cinematicInfoTitle, introTextBigFont, ScrW() / 2, ScrH() / 2, Color(colorWhite.r, colorWhite.g, colorWhite.b, alpha), 1, 1);
		
			if (cinematicInfo.text) then
				draw.SimpleText( string.upper(cinematicInfo.text), nexus.schema.GetFont("intro_text_small"), (ScrW() / 2) - (textWidth / 2), (ScrH() / 2) + (textHeight / 2), Color(colorWhite.r, colorWhite.g, colorWhite.b, alpha) );
			end;
		elseif (cinematicInfo.text) then
			draw.SimpleText(string.upper(cinematicInfo.text), nexus.schema.GetFont("intro_text_small"), ScrW() / 2, (ScrH() / 2) + 40, Color(colorWhite.r, colorWhite.g, colorWhite.b, alpha), 0, 1);
		end;
		
		self:DrawCinematicIntroBars();
	end;
end;

-- Called when the character selection HUD should be painted.
function NEXUS:HUDPaintCharacterSelection() end;

-- Called when the important HUD should be painted.
function NEXUS:HUDPaintImportant() end;

-- Called when the foreground HUD should be painted.
function NEXUS:HUDPaintForeground()
	local colorWhite = nexus.schema.GetColor("white");
	local info = nexus.mount.Call("GetProgressBarInfo");
	local menu = self:GetRecogniseMenu();
	
	if (info) then
		local x, y = NEXUS:GetScreenCenter();
		
		self:DrawBar(x - (ScrW() / 4), y + 48, (ScrW() / 2) - 64, 16, info.color or self.ProgressBarColor, info.text or "Progress Bar", info.percentage or 100, 100, info.flash);
	else
		info = nexus.mount.Call("GetPostProgressBarInfo");
		
		if (info) then
			local x, y = NEXUS:GetScreenCenter();
			
			self:DrawBar(x - (ScrW() / 4), y + 48, (ScrW() / 2) - 64, 16, info.color or self.ProgressBarColor, info.text or "Progress Bar", info.percentage or 100, 100, info.flash);
		end;
	end;
	
	if ( nexus.player.IsAdmin(g_LocalPlayer) ) then
		if ( nexus.mount.Call("PlayerCanSeeAdminESP") ) then
			self:DrawAdminESP();
		end;
	end;
	
	local screenTextInfo = nexus.mount.Call("GetScreenTextInfo");
	
	if (screenTextInfo) then
		local alpha = screenTextInfo.alpha or 255;
		local y = (ScrH() / 2) - 128;
		local x = ScrW() / 2;
		
		if (screenTextInfo.title) then
			self:OverrideMainFont( nexus.schema.GetFont("menu_text_small") );
				y = NEXUS:DrawInfo(screenTextInfo.title, x, y, colorWhite, alpha);
			self:OverrideMainFont(false);
		end;
		
		if (screenTextInfo.text) then
			self:OverrideMainFont( nexus.schema.GetFont("menu_text_tiny") );
				y = NEXUS:DrawInfo(screenTextInfo.text, x, y, colorWhite, alpha);
			self:OverrideMainFont(false);
		end;
	end;
	
	if ( IsValid(menu) ) then
		self:OverrideMainFont( nexus.schema.GetFont("menu_text_tiny") );
			NEXUS:DrawInfo("Select who can recognise you...", menu.x, menu.y, colorWhite, 255, true, function(x, y, width, height)
				return x, y - height - 8;
			end);
		self:OverrideMainFont(false);
	end;
	
	nexus.chatBox.Paint();
end;

-- Called to get the screen text info.
function NEXUS:GetScreenTextInfo()
	local blackFadeAlpha = self:GetBlackFadeAlpha();
	
	if ( g_LocalPlayer:GetSharedVar("sh_Banned") ) then
		return {
			alpha = blackFadeAlpha,
			title = "THIS CHARACTER IS BANNED",
			text = "Go to the characters menu to make a new one."
		};
	end;
end;

-- Called to get whether the local player can see the admin ESP.
function NEXUS:PlayerCanSeeAdminESP()
	if (NX_CONVAR_ADMINESP and NX_CONVAR_ADMINESP:GetInt() == 1) then
		return true;
	else
		return false;
	end;
end;

-- Called when the local player attempts to get up.
function NEXUS:PlayerCanGetUp() return true; end;

-- Called when the local player attempts to see the top bars.
function NEXUS:PlayerCanSeeBars()
	return true;
end;

-- Called when the local player attempts to see the top hints.
function NEXUS:PlayerCanSeeHints()
	return true;
end;

-- Called when the local player attempts to see the date and time.
function NEXUS:PlayerCanSeeDateTime()
	return true;
end;

-- Called when the local player attempts to see a class.
function NEXUS:PlayerCanSeeClass(class)
	return true;
end;

-- Called when the local player attempts to see the player info.
function NEXUS:PlayerCanSeePlayerInfo()
	return nexus.menu.GetOpen();
end;

-- Called when the target ID HUD should be drawn.
function NEXUS:HUDDrawTargetID()
	local targetIDTextFont = nexus.schema.GetFont("target_id_text");
	local traceEntity = NULL;
	local colorWhite = nexus.schema.GetColor("white");
	
	self:OverrideMainFont(targetIDTextFont);
	
	if ( IsValid(g_LocalPlayer) and g_LocalPlayer:Alive() ) then
		if ( !g_LocalPlayer:IsRagdolled(RAGDOLL_FALLENOVER) ) then
			local fadeDistance = 128;
			local curTime = UnPredictedCurTime();
			local trace = nexus.player.GetRealTrace(g_LocalPlayer);
			
			if ( IsValid(trace.Entity) and !trace.Entity:IsEffectActive(EF_NODRAW) ) then
				if (!self.TargetIDData or self.TargetIDData.entity != trace.Entity) then
					self.TargetIDData = {
						showTime = curTime + 0.5,
						entity = trace.Entity
					};
				end;
				
				if (self.TargetIDData) then
					self.TargetIDData.trace = trace;
				end;
				
				if ( !IsValid(traceEntity) ) then
					traceEntity = trace.Entity;
				end;
				
				if (curTime >= self.TargetIDData.showTime) then
					if (!self.TargetIDData.fadeTime) then
						self.TargetIDData.fadeTime = curTime + 3;
					end;
					
					local class = trace.Entity:GetClass();
					local entity = nexus.entity.GetPlayer(trace.Entity);
					
					if (entity) then
						fadeDistance = nexus.mount.Call("GetTargetPlayerFadeDistance", entity);
					end;
					
					local alpha = math.Clamp(self:CalculateAlphaFromDistance(fadeDistance, g_LocalPlayer, trace.HitPos) * 1.5, 0, 255);
					
					if (alpha > 0) then
						alpha = math.min(alpha, math.Clamp(1 - ( (self.TargetIDData.fadeTime - curTime) / 3 ), 0, 1) * 255);
					end;
					
					self.TargetIDData.fadeDistance = fadeDistance;
					self.TargetIDData.player = entity;
					self.TargetIDData.alpha = alpha;
					self.TargetIDData.class = class;
					
					if (entity and g_LocalPlayer != entity) then
						if ( nexus.mount.Call("ShouldDrawPlayerTargetID", entity) ) then
							if ( !nexus.player.IsNoClipping(entity) ) then
								if (g_LocalPlayer:GetShootPos():Distance(trace.HitPos) <= fadeDistance) then
									if (self.nextCheckRecognises and self.nextCheckRecognises[2] != entity) then
										g_LocalPlayer:SetSharedVar("sh_TargetRecognises", true);
									end;
									
									local flashAlpha = nil;
									local toScreen = trace.HitPos:ToScreen();
									local x, y = toScreen.x, toScreen.y;
									
									if ( !nexus.player.DoesTargetRecognise() ) then
										flashAlpha = math.Clamp(math.sin(curTime * 2) * alpha, 0, 255);
									end;
									
									if ( nexus.player.DoesRecognise(entity, RECOGNISE_PARTIAL) ) then
										local text = self:ExplodeString( "\n", nexus.mount.Call("GetTargetPlayerName", entity) );
										local newY;
										
										for k, v in ipairs(text) do
											newY = self:DrawInfo(v, x, y, g_Team.GetColor( entity:Team() ), alpha);
											
											if (flashAlpha) then
												self:DrawInfo(v, x, y, colorWhite, flashAlpha);
											end;
											
											if (newY) then
												y = newY;
											end;
										end;
									else
										local unrecognisedName, usedPhysDesc = nexus.player.GetUnrecognisedName(entity);
										local wrappedTable = {unrecognisedName};
										local teamColor = g_Team.GetColor( entity:Team() );
										local result = nexus.mount.Call("PlayerCanShowUnrecognised", entity, x, y, unrecognisedName, teamColor, alpha, flashAlpha);
										local newY;
										
										if (type(result) == "string") then
											wrappedTable = {};
											
											self:WrapText(result, targetIDTextFont, math.max(ScrW() / 9, 384), wrappedTable);
										elseif (usedPhysDesc) then
											wrappedTable = {};
											
											self:WrapText(unrecognisedName, targetIDTextFont, math.max(ScrW() / 9, 384), wrappedTable);
										end;
										
										if (result == true or type(result) == "string") then
											for k, v in ipairs(wrappedTable) do
												newY = self:DrawInfo(v, x, y, teamColor, alpha);
													
												if (flashAlpha) then
													self:DrawInfo(v, x, y, colorWhite, flashAlpha);
												end;
												
												if (newY) then
													y = newY;
												end;
											end;
										elseif ( tonumber(result) ) then
											y = result;
										end;
									end;
									
									self.TargetPlayerText.text = {};
									
									nexus.mount.Call("GetTargetPlayerText", entity, self.TargetPlayerText);
									nexus.mount.Call("DestroyTargetPlayerText", entity, self.TargetPlayerText);
									
									y = nexus.mount.Call("DrawTargetPlayerStatus", entity, alpha, x, y) or y;
									
									for k, v in pairs(self.TargetPlayerText.text) do
										y = self:DrawInfo(v.text, x, y, v.color or colorWhite, alpha);
									end;
									
									if (!self.nextCheckRecognises or curTime >= self.nextCheckRecognises[1]
									or self.nextCheckRecognises[2] != entity) then
										self:StartDataStream("GetTargetRecognises", entity);
										
										self.nextCheckRecognises = {curTime + 2, entity};
									end;
								end;
							end;
						end;
					elseif ( nexus.generator.Get(class) ) then
						if (g_LocalPlayer:GetShootPos():Distance(trace.HitPos) <= fadeDistance) then
							local generator = nexus.generator.Get(class);
							local toScreen = trace.HitPos:ToScreen();
							local owner = nexus.entity.GetOwner(trace.Entity);
							local power = trace.Entity:GetPower();
							local x, y = toScreen.x, toScreen.y;
							
							y = self:DrawInfo(generator.name, x, y, Color(150, 150, 100, 255), alpha);
							y = self:DrawBar( x - 80, y, 160, 16, self.ProgressBarColor, generator.powerPlural, power, generator.power, power < (generator.power / 5) );
						end;
					elseif ( trace.Entity:IsWeapon() ) then
						if (g_LocalPlayer:GetShootPos():Distance(trace.HitPos) <= fadeDistance) then
							local active = nil;
							for k, v in ipairs( g_Player.GetAll() ) do
								if (v:GetActiveWeapon() == trace.Entity) then
									active = true;
								end;
							end;
							
							if (!active) then
								local toScreen = trace.HitPos:ToScreen();
								local x, y = toScreen.x, toScreen.y;
								
								y = self:DrawInfo("An unknown weapon", x, y, Color(200, 100, 50, 255), alpha);
								y = self:DrawInfo("Press use to equip.", x, y, colorWhite, alpha);
							end;
						end;
					elseif (trace.Entity.HUDPaintTargetID) then
						local toScreen = trace.HitPos:ToScreen();
						local x, y = toScreen.x, toScreen.y;
						
						trace.Entity:HUDPaintTargetID(x, y, alpha);
					else
						-- local x, y = self:GetScreenCenter();
						local toScreen = trace.HitPos:ToScreen();
						local x, y = toScreen.x, toScreen.y;
						
						hook.Call( "HUDPaintEntityTargetID", NEXUS, trace.Entity, {
							alpha = alpha,
							x = x,
							y = y
						} );
					end;
				end;
			end;
		end;
	end;
	
	self:OverrideMainFont(false);
	
	if ( !IsValid(traceEntity) ) then
		if (self.TargetIDData) then
			self.TargetIDData = nil;
		end;
	end;
end;

-- Called when the target's status should be drawn.
function NEXUS:DrawTargetPlayerStatus(target, alpha, x, y)
	local informationColor = nexus.schema.GetColor("information");
	local gender = "He";
	
	if (nexus.player.GetGender(target) == GENDER_FEMALE) then
		gender = "She";
	end;
	
	if ( !target:Alive() ) then
		return self:DrawInfo(gender.." is clearly deceased.", x, y, informationColor, alpha);
	else
		return y;
	end;
end;

-- Called when the character creation panel has initialized.
function NEXUS:CharacterCreationPanelInitialized(panel) end;

-- Called when the local player's character creation info should be adjusted.
function NEXUS:PlayerAdjustCharacterCreationInfo(panel, info) end;

-- Called when the character panel tool tip is needed.
function NEXUS:GetCharacterPanelToolTip(panel, faction, character)
	return "There are "..#nexus.faction.GetPlayers(faction).."/"..nexus.faction.GetLimit(faction).." characters with this faction.";
end;

-- Called when the admin ESP info is needed.
function NEXUS:GetAdminESPInfo(info)
	for k, v in ipairs( g_Player.GetAll() ) do
		if ( v:HasInitialized() ) then
			local bonePosition = v:GetBonePosition( v:LookupBone("ValveBiped.Bip01_Head1") );
			local position;
			
			if ( string.find(v:GetModel(), "vortigaunt") ) then
				bonePosition = v:GetBonePosition( v:LookupBone("ValveBiped.Head") );
			end;
			
			if (bonePosition) then
				position = bonePosition + Vector(0, 0, 16);
			else
				position = v:GetPos() + Vector(0, 0, 80);
			end;
			
			info[#info + 1] = {
				position = position,
				color = g_Team.GetColor( v:Team() ),
				text = v:Name().." ("..v:Health().."/"..v:GetMaxHealth()..")"
			};
		end;
	end;
end;

-- Called when the post progress bar info is needed.
function NEXUS:GetPostProgressBarInfo() end;

-- Called when the custom character options are needed.
function NEXUS:GetCustomCharacterOptions(character, options, menu) end;

-- Called when the custom character buttons are needed.
function NEXUS:GetCustomCharacterButtons(character, buttons) end;

-- Called when the progress bar info is needed.
function NEXUS:GetProgressBarInfo()
	local action, percentage = nexus.player.GetAction(g_LocalPlayer, true);
	
	if (!g_LocalPlayer:Alive() and action == "spawn") then
		return {text = "You are being spawned.", percentage = percentage, flash = percentage < 10};
	end;
	
	if ( !g_LocalPlayer:IsRagdolled() ) then
		if (action == "lock") then
			return {text = "The entity is being locked.", percentage = percentage, flash = percentage < 10};
		elseif (action == "unlock") then
			return {text = "The entity is being unlocked.", percentage = percentage, flash = percentage < 10};
		end;
	elseif (action == "unragdoll") then
		if (g_LocalPlayer:GetRagdollState() == RAGDOLL_FALLENOVER) then
			return {text = "You are regaining stability.", percentage = percentage, flash = percentage < 10};
		else
			return {text = "You are regaining conciousness.", percentage = percentage, flash = percentage < 10};
		end;
	elseif (g_LocalPlayer:GetRagdollState() == RAGDOLL_FALLENOVER) then
		local fallenOver = g_LocalPlayer:GetSharedVar("sh_FallenOver");
		
		if ( fallenOver and nexus.mount.Call("PlayerCanGetUp") ) then
			return {text = "Press 'jump' to get up.", percentage = 100};
		end;
	end;
end;

-- Called just before the local player's information is drawn.
function NEXUS:PreDrawPlayerInfo(boxInfo, information, subInformation) end;

-- Called just after the local player's information is drawn.
function NEXUS:PostDrawPlayerInfo(boxInfo, information, subInformation) end;

-- Called when the player info text is needed.
function NEXUS:GetPlayerInfoText(playerInfoText)
	local cash = nexus.player.GetCash();
	local wages = nexus.player.GetWages();
	
	if ( nexus.config.Get("cash_enabled"):Get() ) then
		if (cash > 0) then
			playerInfoText:Add( "CASH", nexus.schema.GetOption("name_cash")..": "..FORMAT_CASH(cash, true) );
		end;
		
		if (wages > 0) then
			playerInfoText:Add( "WAGES", g_LocalPlayer:GetWagesName()..": "..FORMAT_CASH(wages) );
		end;
	end;

	playerInfoText:AddSub("NAME", g_LocalPlayer:Name(), 2);
	playerInfoText:AddSub("CLASS", g_Team.GetName( g_LocalPlayer:Team() ), 1);
end;

-- Called when the target player's fade distance is needed.
function NEXUS:GetTargetPlayerFadeDistance(player)
	return 8192;
end;

-- Called when the player info text should be destroyed.
function NEXUS:DestroyPlayerInfoText(playerInfoText) end;

-- Called when the target player's text is needed.
function NEXUS:GetTargetPlayerText(player, targetPlayerText)
	local targetIDTextFont = nexus.schema.GetFont("target_id_text");
	local physDescTable = {};
	local thirdPerson = "him";
	
	if (nexus.player.GetGender(player) == GENDER_FEMALE) then
		thirdPerson = "her";
	end;
	
	if ( nexus.player.DoesRecognise(player, RECOGNISE_PARTIAL) ) then
		self:WrapText(nexus.player.GetPhysDesc(player), targetIDTextFont, math.max(ScrW() / 9, 384), physDescTable);
		
		for k, v in ipairs(physDescTable) do
			targetPlayerText:Add("PHYSDESC_"..k, v);
		end;
	elseif ( player:Alive() ) then
		targetPlayerText:Add("PHYSDESC", "You do not recognise "..thirdPerson..".");
	end;
end;

-- Called when the target player's text should be destroyed.
function NEXUS:DestroyTargetPlayerText(player, targetPlayerText) end;

-- Called when a player's scoreboard text is needed.
function NEXUS:GetPlayerScoreboardText(player)
	local thirdPerson = "him";
	
	if (nexus.player.GetGender(player) == GENDER_FEMALE) then
		thirdPerson = "her";
	end;
	
	if ( nexus.player.DoesRecognise(player, RECOGNISE_PARTIAL) ) then
		local physDesc = nexus.player.GetPhysDesc(player);
		
		if (string.len(physDesc) > 64) then
			return string.sub(physDesc, 1, 61).."...";
		else
			return physDesc;
		end;
	else
		return "You do not recognise "..thirdPerson..".";
	end;
end;

-- Called when the local player's character screen faction is needed.
function NEXUS:GetPlayerCharacterScreenFaction(character)
	return character.faction;
end;

-- Called to get whether the local player's character screen is visible.
function NEXUS:GetPlayerCharacterScreenVisible(panel)
	if ( !nexus.quiz.GetEnabled() or nexus.quiz.GetCompleted() ) then
		return true;
	else
		return false;
	end;
end;

-- Called to get whether the character menu should be created.
function NEXUS:ShouldCharacterMenuBeCreated()
	if (self.NexusIntroFadeOut) then
		return false;
	end;
	
	return true;
end;

-- Called when the local player's character screen is created.
function NEXUS:PlayerCharacterScreenCreated(panel)
	if ( nexus.quiz.GetEnabled() ) then
		NEXUS:StartDataStream("GetQuizStatus", true);
	end;
end;

-- Called when a player's scoreboard class is needed.
function NEXUS:GetPlayerScoreboardClass(player)
	return g_Team.GetName( player:Team() );
end;

-- Called when a player's scoreboard options are needed.
function NEXUS:GetPlayerScoreboardOptions(player, options, menu)
	local charTakeFlags = nexus.command.Get("CharTakeFlags");
	local charGiveFlags = nexus.command.Get("CharGiveFlags");
	local charGiveItem = nexus.command.Get("CharGiveItem");
	local charSetName = nexus.command.Get("CharSetName");
	local charBan = nexus.command.Get("CharBan");
	local plyKick = nexus.command.Get("PlyKick");
	local plyBan = nexus.command.Get("PlyBan");
	
	if ( charBan and nexus.player.HasFlags(g_LocalPlayer, charBan.access) ) then
		options["Ban Character"] = function()
			RunConsoleCommand( "nx", "CharBan", player:Name() );
		end;
	end;
	
	if ( plyKick and nexus.player.HasFlags(g_LocalPlayer, plyKick.access) ) then
		options["Kick Player"] = function()
			Derma_StringRequest(player:Name(), "What is your reason for kicking them?", nil, function(text)
				NEXUS:RunCommand("PlyKick", player:Name(), text);
			end);
		end;
	end;
	
	if ( plyBan and nexus.player.HasFlags(g_LocalPlayer, nexus.command.Get("PlyBan").access) ) then
		options["Ban Player"] = function()
			Derma_StringRequest(player:Name(), "How many minutes would you like to ban them for?", nil, function(minutes)
				Derma_StringRequest(player:Name(), "What is your reason for banning them?", nil, function(reason)
					NEXUS:RunCommand("PlyBan", player:Name(), minutes, reason);
				end);
			end);
		end;
	end;
	
	if ( charGiveFlags and nexus.player.HasFlags(g_LocalPlayer, charGiveFlags.access) ) then
		options["Give Flags"] = function()
			Derma_StringRequest(player:Name(), "What flags would you like to give them?", nil, function(text)
				NEXUS:RunCommand("CharGiveFlags", player:Name(), text);
			end);
		end;
	end;
	
	if ( charTakeFlags and nexus.player.HasFlags(g_LocalPlayer,charTakeFlags.access) ) then
		options["Take Flags"] = function()
			Derma_StringRequest(player:Name(), "What flags would you like to take from them?", player:GetSharedVar("sh_Flags"), function(text)
				NEXUS:RunCommand("CharTakeFlags", player:Name(), text);
			end);
		end;
	end;
	
	if ( charSetName and nexus.player.HasFlags(g_LocalPlayer, charSetName.access) ) then
		options["Set Name"] = function()
			Derma_StringRequest(player:Name(), "What would you like to set their name to?", player:Name(), function(text)
				NEXUS:RunCommand("CharSetName", player:Name(), text);
			end);
		end;
	end;
	
	if ( charGiveItem and nexus.player.HasFlags(g_LocalPlayer, charGiveItem.access) ) then
		options["Give Item"] = function()
			Derma_StringRequest(player:Name(), "What item would you like to give them?", nil, function(text)
				NEXUS:RunCommand("CharGiveItem", player:Name(), text);
			end);
		end;
	end;
	
	local canUwhitelist = false;
	local canWhitelist = false;
	local unwhitelist = nexus.command.Get("PlyUnwhitelist");
	local whitelist = nexus.command.Get("PlyWhitelist");
	
	if (whitelist and nexus.player.HasFlags(g_LocalPlayer, whitelist.access) ) then
		canWhitelist = true;
	end;
	
	if (unwhitelist and nexus.player.HasFlags(g_LocalPlayer, unwhitelist.access) ) then
		canUnwhitelist = true;
	end;
	
	if (canWhitelist or canUwhitelist) then
		local areWhitelistFactions = false;
		
		for k, v in pairs(nexus.faction.stored) do
			if (v.whitelist) then
				areWhitelistFactions = true;
			end;
		end;
		
		if (areWhitelistFactions) then
			if (canWhitelist) then
				options["Whitelist"] = {}; 
			end;
			
			if (canUwhitelist) then
				options["Unwhitelist"] = {};
			end;
			
			for k, v in pairs(nexus.faction.stored) do
				if (v.whitelist) then
					if ( options["Whitelist"] ) then
						options["Whitelist"][k] = function()
							NEXUS:RunCommand("PlyWhitelist", player:Name(), k);
						end;
					end;
					
					if ( options["Unwhitelist"] ) then
						options["Unwhitelist"][k] = function()
							NEXUS:RunCommand("PlyUnwhitelist", player:Name(), k);
						end;
					end;
				end;
			end;
		end;
	end;
end;

-- Called when information about a door is needed.
function NEXUS:GetDoorInfo(door, information)
	local doorCost = nexus.config.Get("door_cost"):Get();
	local owner = nexus.entity.GetOwner(door);
	local text = nexus.entity.GetDoorText(door);
	local name = nexus.entity.GetDoorName(door);
	
	if (information == DOOR_INFO_NAME) then
		if ( nexus.entity.IsDoorHidden(door)
		or nexus.entity.IsDoorFalse(door) ) then
			return false;
		elseif (name == "") then
			return "Door";
		else
			return name;
		end;
	elseif (information == DOOR_INFO_TEXT) then
		if ( nexus.entity.IsDoorUnownable(door) ) then
			if ( !nexus.entity.IsDoorHidden(door)
			and !nexus.entity.IsDoorFalse(door) ) then
				if (text == "") then
					return "This door is unownable.";
				else
					return text;
				end;
			else
				return false;
			end;
		elseif (text != "") then
			if ( nexus.entity.HasOwner(door) and !IsValid(owner) ) then
				if (doorCost > 0) then
					return "This door can be purchased.";
				else
					return "This door can be owned.";
				end;
			else
				return text;
			end;
		elseif ( IsValid(owner) ) then
			if (doorCost > 0) then
				return "This door has been purchased.";
			else
				return "This door has been owned.";
			end;
		elseif (doorCost > 0) then
			return "This door can be purchased.";
		else
			return "This door can be owned.";
		end;
	end;
end;

-- Called to get whether or not a post process is permitted.
function NEXUS:PostProcessPermitted(class)
	return false;
end;

-- Called just after the opaque renderables have been drawn.
function NEXUS:PostDrawOpaqueRenderables(drawingDepth, drawingSkybox)
	if (drawingSkybox) then
		return;
	end;
	
	local colorWhite = nexus.schema.GetColor("white");
	local doorFont = nexus.schema.GetFont("large_3d_2d");
	local eyeAngles = EyeAngles();
	local eyePos = EyePos();
	
	if ( !self:IsChoosingCharacter() ) then
		cam.Start3D(eyePos, eyeAngles);
			local entities = ents.FindInSphere(eyePos, 256);
			
			for k, v in pairs(entities) do
				if ( IsValid(v) and nexus.entity.IsDoor(v) ) then
					self:DrawDoorText(v, eyePos, eyeAngles, doorFont, colorWhite);
				end;
			end;
		cam.End3D();
	end;
end;

-- Called when screen space effects should be rendered.
function NEXUS:RenderScreenspaceEffects()
	if ( IsValid(g_LocalPlayer) ) then
		local frameTime = FrameTime();
		local motionBlurs = {
			enabled = true,
			blurTable = {}
		};
		local color = 1;
		local drunk = nexus.player.GetDrunk();
		
		if ( !self:IsChoosingCharacter() ) then
			if (g_LocalPlayer:Health() <= 75) then
				if ( g_LocalPlayer:Alive() ) then
					color = math.Clamp(color - ( ( g_LocalPlayer:GetMaxHealth() - g_LocalPlayer:Health() ) * 0.01 ), 0, color);
				else
					color = 0;
				end;
				
				motionBlurs.blurTable["health"] = math.Clamp(1 - ( ( g_LocalPlayer:GetMaxHealth() - g_LocalPlayer:Health() ) * 0.01 ), 0, 1);
			end;
			
			if (drunk and self.DrunkBlur) then
				self.DrunkBlur = math.Clamp(self.DrunkBlur - (frameTime / 10), math.max(1 - (drunk / 8), 0.1), 1);
				
				DrawMotionBlur(self.DrunkBlur, 1, 0);
			elseif (self.DrunkBlur and self.DrunkBlur < 1) then
				self.DrunkBlur = math.Clamp(self.DrunkBlur + (frameTime / 10), 0.1, 1);
				
				motionBlurs.blurTable["drunk"] = self.DrunkBlur;
			else
				self.DrunkBlur = 1;
			end;
		end;
		
		self.ColorModify["$pp_colour_brightness"] = 0;
		self.ColorModify["$pp_colour_contrast"] = 1;
		self.ColorModify["$pp_colour_colour"] = color;
		self.ColorModify["$pp_colour_addr"] = 0;
		self.ColorModify["$pp_colour_addg"] = 0;
		self.ColorModify["$pp_colour_addb"] = 0;
		self.ColorModify["$pp_colour_mulr"] = 0;
		self.ColorModify["$pp_colour_mulg"] = 0;
		self.ColorModify["$pp_colour_mulb"] = 0;
		
		nexus.mount.Call("PlayerAdjustColorModify", self.ColorModify);
		nexus.mount.Call("PlayerAdjustMotionBlurs", motionBlurs);
		
		if (motionBlurs.enabled) then
			local addAlpha = nil;
			
			for k, v in pairs(motionBlurs.blurTable) do
				if (!addAlpha or v < addAlpha) then
					addAlpha = v;
				end;
			end;
			
			if (addAlpha) then
				DrawMotionBlur(math.Clamp(addAlpha, 0.1, 1), 1, 0);
			end;
		end;
		
		DrawColorModify(self.ColorModify);
	end;
end;

-- Called when the chat box is opened.
function NEXUS:ChatBoxOpened() end;

-- Called when the chat box is closed.
function NEXUS:ChatBoxClosed(textTyped) end;

-- Called when the chat box text has been typed.
function NEXUS:ChatBoxTextTyped(text)
	if (self.LastChatBoxText) then
		if (self.LastChatBoxText[1] == text) then
			return;
		end;
		
		if (#self.LastChatBoxText >= 25) then
			table.remove(self.LastChatBoxText, 25);
		end;
	else
		self.LastChatBoxText = {};
	end;
	
	table.insert(self.LastChatBoxText, 1, text);
end;

-- Called when the calc view table should be adjusted.
function NEXUS:CalcViewAdjustTable(view) end;

-- Called when the chat box info should be adjusted.
function NEXUS:ChatBoxAdjustInfo(info) end;

-- Called when the chat box text has changed.
function NEXUS:ChatBoxTextChanged(previousText, newText) end;

-- Called when the chat box has had a key code typed in.
function NEXUS:ChatBoxKeyCodeTyped(code, text)
	if (code == KEY_UP) then
		if (self.LastChatBoxText) then
			for k, v in pairs(self.LastChatBoxText) do
				if ( v == text and self.LastChatBoxText[k + 1] ) then
					return self.LastChatBoxText[k + 1];
				end;
			end;
			
			if ( self.LastChatBoxText[1] ) then
				return self.LastChatBoxText[1];
			end;
		end;
	elseif (code == KEY_DOWN) then
		if (self.LastChatBoxText) then
			for k, v in pairs(self.LastChatBoxText) do
				if ( v == text and self.LastChatBoxText[k - 1] ) then
					return self.LastChatBoxText[k - 1];
				end;
			end;
			
			if (#self.LastChatBoxText > 0) then
				return self.LastChatBoxText[#self.LastChatBoxText];
			end;
		end;
	end;
end;

-- Called when a notification should be adjusted.
function NEXUS:NotificationAdjustInfo(info)
	return true;
end;

-- Called when the local player's business item should be adjusted.
function NEXUS:PlayerAdjustBusinessItemTable(itemTable) end;

-- Called when the local player's class model info should be adjusted.
function NEXUS:PlayerAdjustClassModelInfo(class, info) end;

-- Called when the local player's headbob info should be adjusted.
function NEXUS:PlayerAdjustHeadbobInfo(info)
	local drunk = nexus.player.GetDrunk();
	local scale = NX_CONVAR_HEADBOBSCALE:GetInt();
	
	if ( tonumber(scale) ) then
		scale = math.Clamp(scale, 0, 1);
	else
		scale = 1;
	end;
	
	if ( g_LocalPlayer:IsRunning() ) then
		if (scale > 0) then
			info.multiplier = (info.multiplier * 0.75) * scale;
			info.pitch = (info.pitch * 16) * scale;
			info.yaw = (info.yaw * 24) * scale;
		end;
	elseif ( g_LocalPlayer:IsJogging() ) then
		if (scale > 0) then
			info.multiplier = (info.multiplier * 0.75) * scale;
			info.pitch = (info.pitch * 8) * scale;
			info.yaw = (info.yaw * 12) * scale;
		end;
	elseif (g_LocalPlayer:GetVelocity():Length() > 0) then
		if (scale > 0) then
			info.multiplier = (info.multiplier * 0.5) * scale;
			info.pitch = (info.pitch * 4) * scale;
			info.yaw = (info.yaw * 8) * scale;
		end;
	else
		info.multiplier = info.multiplier * 0.5;
		info.pitch = info.pitch * 0.5;
		info.yaw = info.yaw * 0.5;
	end;
	
	if (drunk) then
		info.multiplier = info.multiplier * math.min(drunk * 0.25, 4);
		info.pitch = info.pitch * math.min(drunk, 4);
		info.yaw = info.yaw * math.min(drunk, 4);
	end;
end;

-- Called when the local player's motion blurs should be adjusted.
function NEXUS:PlayerAdjustMotionBlurs(motionBlurs) end;

-- Called when the local player's item functions should be adjusted.
function NEXUS:PlayerAdjustItemFunctions(itemTable, itemFunctions) end;

-- Called when the local player's color modify should be adjusted.
function NEXUS:PlayerAdjustColorModify(colorModify) end;

-- Called to get whether a player's target ID should be drawn.
function NEXUS:ShouldDrawPlayerTargetID(player)
	return true;
end;

-- Called to get whether the local player's screen should fade black.
function NEXUS:ShouldPlayerScreenFadeBlack()
	if ( !g_LocalPlayer:Alive() or g_LocalPlayer:IsRagdolled(RAGDOLL_FALLENOVER) ) then
		if ( !nexus.mount.Call("PlayerCanSeeUnconscious") ) then
			return true;
		end;
	end;
	
	return false;
end;

-- Called when the menu background blur should be drawn.
function NEXUS:ShouldDrawMenuBackgroundBlur()
	return true;
end;

-- Called when the character background blur should be drawn.
function NEXUS:ShouldDrawCharacterBackgroundBlur()
	return true;
end;

-- Called when the character background should be drawn.
function NEXUS:ShouldDrawCharacterBackground()
	return true;
end;

-- Called when the character fault should be drawn.
function NEXUS:ShouldDrawCharacterFault(fault)
	return true;
end;

-- Called when the character loading background should be drawn.
function NEXUS:ShouldDrawCharacterLoadingBackground(alpha)
	return true;
end;

-- Called when the score board should be drawn.
function NEXUS:HUDDrawScoreBoard()
	self.BaseClass:HUDDrawScoreBoard(player);
	
	local drawPendingScreenBlack = nil;
	local drawCharacterLoading = nil;
	local introTextSmallFont = nexus.schema.GetFont("intro_text_small");
	local colorWhite = nexus.schema.GetColor("white");
	local curTime = UnPredictedCurTime();
	local scrH = ScrH();
	local scrW = ScrW();
	
	if ( !g_LocalPlayer:HasInitialized() ) then
		if ( self:IsChoosingCharacter() ) then
			if ( nexus.mount.Call("ShouldDrawCharacterBackground") ) then
				self:DrawRoundedGradient( 0, 0, 0, ScrW(), ScrH(), Color(0, 0, 0, 255) );
			end;
			
			nexus.mount.Call("HUDPaintCharacterSelection");
		else
			drawPendingScreenBlack = true;
		end;
	else
		if (!self.CharacterLoadingFinishTime) then
			local loadingTime = nexus.mount.Call("GetCharacterLoadingTime");
			
			self.CharacterLoadingDelay = loadingTime;
			self.CharacterLoadingFinishTime = curTime + loadingTime;
		end;
		
		if ( !self:IsChoosingCharacter() ) then
			self:CalculateScreenFading();
			
			if ( !self:IsUsingCamera() ) then
				nexus.mount.Call("HUDPaintForeground");
				
				local cinematic = self.Cinematics[1];
				
				if (cinematic) then
					self:DrawCinematic(cinematic, curTime);
				end;
			end;
			
			nexus.mount.Call("HUDPaintImportant");
		end;
		
		if (self.CharacterLoadingFinishTime > curTime) then
			drawCharacterLoading = true;
		elseif (!self.CinematicScreenDone) then
			self:DrawCinematicIntro(curTime);
		end;
	end;
	
	if ( nexus.mount.Call("ShouldDrawBackgroundBlurs") ) then
		self:DrawBackgroundBlurs();
	end;

	if ( !nexus.player.HasDataStreamed() ) then
		if (!self.DataStreamedAlpha) then
			self.DataStreamedAlpha = 255;
		end;
	elseif (self.DataStreamedAlpha) then
		self.DataStreamedAlpha = math.Approach(self.DataStreamedAlpha, 0, FrameTime() * 100);
		
		if (self.DataStreamedAlpha <= 0) then
			self.DataStreamedAlpha = nil;
		end;
	end;
	
	if (self.NexusIntroFadeOut) then
		local duration = 16;
		local introImage = nexus.schema.GetOption("intro_image");
		
		if (introImage != "") then
			duration = 32;
		end;
		
		local timeLeft = math.Clamp(self.NexusIntroFadeOut - curTime, 0, duration);
		local material = self.NexusIntroOverrideImage or self.NexusSplash;
		local sineWave = math.sin(curTime);
		local height = 256;
		local width = 512;
		local alpha = 255;
		
		if (!self.NexusIntroOverrideImage) then
			if (introImage != "" and timeLeft <= 16) then
				self.NexusIntroWhiteScreen = curTime + (FrameTime() * 8);
				self.NexusIntroOverrideImage = Material(introImage);
				
				surface.PlaySound("buttons/button1.wav");
			end;
		end;
		
		if (timeLeft <= 3) then
			alpha = (255 / 3) * timeLeft;
		end;
		
		if (timeLeft == 0) then
			self.NexusIntroFadeOut = nil;
			self.NexusIntroOverrideImage = nil;
		end;
		
		if (sineWave > 0) then
			width = width - (sineWave * 8);
			height = height - (sineWave * 2);
		end;
		
		if (curTime <= self.NexusIntroWhiteScreen) then
			self:DrawRoundedGradient( 0, 0, 0, scrW, scrH, Color(255, 255, 255, alpha) );
		else
			self:DrawRoundedGradient( 0, 0, 0, scrW, scrH, Color(0, 0, 0, alpha) );
			
			self.NexusSplash:SetMaterialFloat("$alpha", alpha / 255);
			
			surface.SetDrawColor(255, 255, 255, alpha);
				surface.SetMaterial(material);
			surface.DrawTexturedRect( (scrW / 2) - (width / 2), (scrH / 2) - (height / 2), width, height );
		end;
		
		drawPendingScreenBlack = nil;
	end;
	
	if (self.DataStreamedAlpha and self.DataStreamedAlpha > 0) then
		local textString = "Please wait while nexus streams some data to you.";
		
		if (!self.CreatedLocalPlayer) then
			textString = "Please wait while Source creates the local player.";
		elseif ( !nexus.config.HasInitialized() ) then
			textString = "Please wait while the server config is retrieved.";
		end;
		
		self:DrawRoundedGradient( 0, 0, 0, scrW, scrH, Color(0, 0, 0, self.DataStreamedAlpha) );
		draw.SimpleText(textString, introTextSmallFont, scrW / 2, scrH / 2, Color(colorWhite.r, colorWhite.g, colorWhite.b, self.DataStreamedAlpha), 1, 1);
		
		drawPendingScreenBlack = nil;
	end;
	
	if ( NEXUS:GetSharedVar("sh_NoMySQL") ) then
		local textString = "There server encountered an error connecting to MySQL.\n";
			textString = textString.."The server owner should edit garrysmod/data/nexus/mysql.cfg.";
		
		self:DrawRoundedGradient( 0, 0, 0, scrW, scrH, Color(0, 0, 0, 255) );
		draw.SimpleText(textString, introTextSmallFont, scrW / 2, scrH / 2, Color(179, 46, 49, 255), 1, 1);
	end;
	
	if (drawPendingScreenBlack) then
		self:DrawRoundedGradient( 0, 0, 0, ScrW(), ScrH(), Color(0, 0, 0, 255) );
	end;
	
	if (drawCharacterLoading) then
		local alpha = 255;
		
		if (self.CharacterLoadingFinishTime) then
			alpha = math.Clamp( (255 / self.CharacterLoadingDelay) * (self.CharacterLoadingFinishTime - curTime), 0, 255);
		end;
		
		nexus.mount.Call("HUDPaintCharacterLoading", alpha);
	end;
	
	nexus.mount.Call("PostDrawBackgroundBlurs");
end;

-- Called when the background blurs should be drawn.
function NEXUS:ShouldDrawBackgroundBlurs()
	return true;
end;

-- Called just after the background blurs have been drawn.
function NEXUS:PostDrawBackgroundBlurs()
	local playerInfoBox = self:DrawPlayerInfo();
	local position = nexus.mount.Call("GetChatBoxPosition", playerInfoBox);
	
	if (position) then
		nexus.chatBox.SetCustomPosition(position.x, position.y);
	end;
	
	self.PlayerInfoBox = playerInfoBox;
end;

-- Called just before a bar is drawn.
function NEXUS:PreDrawBar(barInfo) end;

-- Called just after a bar is drawn.
function NEXUS:PostDrawBar(barInfo) end;

-- Called when the top bars are needed.
function NEXUS:GetBars(bars) end;

-- Called when the top bars should be destroyed.
function NEXUS:DestroyBars(bars) end;

-- Called when the chat box position is needed.
function NEXUS:GetChatBoxPosition(playerInfoBox)
	if ( (g_LocalPlayer:IsRagdolled(RAGDOLL_FALLENOVER) and self.BlackFadeIn and self.BlackFadeIn == 255) or !playerInfoBox ) then
		return {x = 8, y = ScrH() - 40};
	else
		return {x = 8, y = ScrH() - playerInfoBox.height - 48};
	end;
end;

-- Called when the cinematic intro info is needed.
function NEXUS:GetCinematicIntroInfo()
	return {
		credits = "A roleplaying game designed by "..SCHEMA.author..".",
		title = SCHEMA.name,
		text = SCHEMA.description
	};
end;

-- Called when the character loading time is needed.
function NEXUS:GetCharacterLoadingTime() return 8; end;

-- Called when a player's HUD should be painted.
function NEXUS:HUDPaintPlayer(player) end;
		
-- Called when the HUD should be painted.
function NEXUS:HUDPaint()
	if ( !self:IsChoosingCharacter() and !self:IsUsingCamera() ) then
		self.BaseClass:HUDPaint();
		
		if ( !self:IsScreenFadedBlack() ) then
			for k, v in ipairs( g_Player.GetAll() ) do
				if (v:HasInitialized() and v != g_LocalPlayer) then
					nexus.mount.Call("HUDPaintPlayer", v);
				end;
			end;
		end;
		
		if ( !self:IsUsingTool() ) then
			self:DrawHints();
			self:DrawDateTime();
		end;
	end;
end;

-- Called when a player starts using voice.
function NEXUS:PlayerStartVoice(player)
	if ( nexus.config.Get("local_voice"):Get() ) then
		if ( player:IsRagdolled(RAGDOLL_FALLENOVER) or !player:Alive() ) then
			return;
		end;
	end;
	
	if (self.BaseClass and self.BaseClass.PlayerStartVoice) then
		self.BaseClass:PlayerStartVoice(player);
	end;
end;

-- Called to check if a player does have an flag.
function NEXUS:PlayerDoesHaveFlag(player, flag)
	if ( string.find(nexus.config.Get("default_flags"):Get(), flag) ) then
		return true;
	end;
end;

-- Called to check if a player does recognise another player.
function NEXUS:PlayerDoesRecognisePlayer(player, status, simple, default)
	return default;
end;

-- Called when a player's name should be shown as unrecognised.
function NEXUS:PlayerCanShowUnrecognised(player, x, y, color, alpha, flashAlpha)
	return true;
end;

-- Called when the target player's name is needed.
function NEXUS:GetTargetPlayerName(player)
	return player:Name();
end;

-- Called when a player begins typing.
function NEXUS:StartChat(team)
	return true;
end;

-- Called when a player says something.
function NEXUS:OnPlayerChat(player, text, teamOnly, playerIsDead)
	if ( IsValid(player) ) then
		nexus.chatBox.Decode(player, player:Name(), text, {}, "none");
	else
		nexus.chatBox.Decode(nil, "Console", text, {}, "chat");
	end;
	
	return true;
end;

-- Called when chat text is received from the server
function NEXUS:ChatText(index, name, text, class)
	if (class == "none") then
		nexus.chatBox.Decode(g_Player.GetByID(index), name, text, {}, "none");
	end;
	
	return true;
end;

-- Called when the scoreboard should be created.
function NEXUS:CreateScoreboard() end;

-- Called when the scoreboard should be shown.
function NEXUS:ScoreboardShow()
	if ( !nexus.character.IsPanelOpen()
	and g_LocalPlayer:HasInitialized() ) then
		if ( nexus.menu.GetPanel() ) then
			nexus.menu.SetOpen(true);
		else
			nexus.menu.Create(true);
		end;
	end;
end;

-- Called when the scoreboard should be hidden.
function NEXUS:ScoreboardHide()
	nexus.menu.SetOpen(false);
end;

usermessage.Hook("nx_PlaySound", function(msg)
	surface.PlaySound( msg:ReadString() );
end);

local playerMeta = FindMetaTable("Player");
local entityMeta = FindMetaTable("Entity");

playerMeta.SteamName = playerMeta.Name;

-- A function to get a player's name.
function playerMeta:Name()
	local name = self:GetSharedVar("sh_Name");
	
	if (!name or name == "") then
		return self:SteamName();
	else
		return name;
	end;
end;

-- A function to get a player's playback rate.
function playerMeta:GetPlaybackRate()
	return self.playbackRate or 1;
end;

-- A function to get whether a player is running.
function playerMeta:IsRunning()
	if ( self:Alive() and !self:IsRagdolled() and !self:InVehicle() and !self:Crouching() ) then
		local sprintSpeed = self:GetNetworkedFloat("SprintSpeed");
		local walkSpeed = self:GetNetworkedFloat("WalkSpeed");
		local velocity = self:GetVelocity():Length();
		
		if (velocity >= math.max(sprintSpeed - 25, 25)
		and sprintSpeed > walkSpeed) then
			return true;
		end;
	end;
end;

-- A function to get whether a player is jogging.
function playerMeta:IsJogging(testSpeed)
	if ( !self:IsRunning() and (self:GetSharedVar("sh_Jogging") or testSpeed) ) then
		if ( self:Alive() and !self:IsRagdolled() and !self:InVehicle() and !self:Crouching() ) then
			local walkSpeed = self:GetNetworkedFloat("WalkSpeed");
			local velocity = self:GetVelocity():Length();
			
			if ( velocity >= math.max(walkSpeed - 25, 25) ) then
				return true;
			end;
		end;
	end;
end;

-- A function to get a player's forced animation.
function playerMeta:GetForcedAnimation()
	local forcedAnimation = self:GetSharedVar("sh_ForcedAnim");
	
	if (forcedAnimation != 0) then
		return {
			animation = forcedAnimation,
		};
	end;
end;

-- A function to get whether a player is ragdolled.
function playerMeta:IsRagdolled(exception, entityless)
	return nexus.player.IsRagdolled(self, exception, entityless);
end;

-- A function to set a shared variable for a player.
function entityMeta:SetSharedVar(key, value)
	if ( self:IsPlayer() ) then
		nexus.player.SetSharedVar(self, key, value);
	else
		nexus.entity.SetSharedVar(self, key, value);
	end;
end;

-- A function to get a player's shared variable.
function entityMeta:GetSharedVar(key)
	if ( self:IsPlayer() ) then
		return nexus.player.GetSharedVar(self, key);
	else
		return nexus.entity.GetSharedVar(self, key);
	end;
end;

-- A function to get whether a player has initialized.
function playerMeta:HasInitialized()
	if ( IsValid(self) ) then
		return self:GetSharedVar("sh_Initialized");
	end;
end;

-- A function to get a player's wages name.
function playerMeta:GetWagesName()
	return nexus.player.GetWagesName(self);
end;

-- A function to get a player's maximum armor.
function playerMeta:GetMaxArmor(armor)
	local maxArmor = self:GetSharedVar("sh_MaxArmor");
	
	if (maxArmor > 0) then
		return maxArmor;
	else
		return 100;
	end;
end;

-- A function to get a player's maximum health.
function playerMeta:GetMaxHealth(health)
	local maxHealth = self:GetSharedVar("sh_MaxHealth");
	
	if (maxHealth > 0) then
		return maxHealth;
	else
		return 100;
	end;
end;

-- A function to get a player's ragdoll state.
function playerMeta:GetRagdollState()
	return nexus.player.GetRagdollState(self);
end;

-- A function to get a player's ragdoll entity.
function playerMeta:GetRagdollEntity()
	return nexus.player.GetRagdollEntity(self);
end;

playerMeta.GetName = playerMeta.Name;
playerMeta.Nick = playerMeta.Name;

nexus.mount.Call("NexusCoreLoaded");