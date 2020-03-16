--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

surface.CreateFont("Arial", ScaleToWideScreen(16), 700, true, false, "cloud_MainText");
surface.CreateFont("Arial", ScaleToWideScreen(72), 700, true, false, "cloud_MenuTextBig");
surface.CreateFont("Arial", ScaleToWideScreen(18), 700, true, false, "cloud_MenuTextTiny");
surface.CreateFont("Arial", ScaleToWideScreen(120), 700, true, false, "cloud_MenuTextHuge");
surface.CreateFont("Arial", ScaleToWideScreen(24), 700, true, false, "cloud_MenuTextSmall");
surface.CreateFont("Arial", ScaleToWideScreen(72), 700, true, false, "cloud_IntroTextBig");
surface.CreateFont("Arial", ScaleToWideScreen(18), 700, true, false, "cloud_IntroTextTiny");
surface.CreateFont("Arial", ScaleToWideScreen(24), 700, true, false, "cloud_IntroTextSmall");
surface.CreateFont("Arial", ScaleToWideScreen(2048), 700, true, false, "cloud_Large3D2D");
surface.CreateFont("Trebuchet", ScaleToWideScreen(30), 700, true, false, "cloud_CinematicText");

timer.Destroy("HintSystem_OpeningMenu");
timer.Destroy("HintSystem_Annoy2");
timer.Destroy("HintSystem_Annoy1");

hook.CloudScriptCall = hook.Call;

local CloudScriptAddWorldTip = AddWorldTip;
local CurTime = CurTime;
local hook = hook;

-- A function to call a hook.
function hook.Call(name, gamemode, ...)
	CloudScript.Client = LocalPlayer();
	
	if (!gamemode) then
		gamemode = CloudScript;
	end;
	
	local hookCall = hook.CloudScriptCall;
	local value = CloudScript.plugin:CallCachedHook(name, nil, ...);
	
	if (value == nil) then
		return hookCall(name, gamemode, ...);
	else
		return value;
	end;
end;

-- A function to add a world tip.
function AddWorldTip(entIndex, text, dieTime, position, entity)
	local weapon = CloudScript.Client:GetActiveWeapon();
	
	if ( IsValid(weapon) ) then
		if (string.lower( weapon:GetClass() ) == "gmod_tool") then
			if (IsValid(entity) and entity.GetPlayerName) then
				if ( CloudScript.Client:Name() == entity:GetPlayerName() ) then
					CloudScriptAddWorldTip(entIndex, text, dieTime, position, entity);
				end;
			end;
		end;
	end;
end;

CloudScript:HookDataStream("RunCommand", function(data)
	RunConsoleCommand( unpack(data) );
end);

CloudScript:HookDataStream("HiddenCommands", function(data)
	for k, v in pairs(data) do
		for k2, v2 in pairs(CloudScript.command.stored) do
			if (CloudScript:GetShortCRC(k2) == v) then
				CloudScript.command:SetHidden(k2, true);
				
				break;
			end;
		end;
	end;
end);

usermessage.Hook("cloud_OrderTime", function(msg)
	CloudScript.OrderCooldown = msg:ReadLong();
	
	local activePanel = CloudScript.menu:GetActivePanel();
	
	if (activePanel and activePanel.isBusinessPanel) then
		activePanel:Rebuild();
	end;
end);

usermessage.Hook("cloud_Log", function(msg)
	local logType = msg:ReadShort();
	local text = msg:ReadString();
	
	CloudScript:PrintColoredText(CloudScript:GetLogTypeColor(logType), text);
end);

usermessage.Hook("cloud_StartSound", function(msg)
	local uniqueID = msg:ReadString();
	local sound = msg:ReadString();
	
	if (!CloudScript.ClientSounds) then
		CloudScript.ClientSounds = {};
	end;
	
	if ( CloudScript.ClientSounds[uniqueID] ) then
		CloudScript.ClientSounds[uniqueID]:Stop();
	end;
	
	CloudScript.ClientSounds[uniqueID] = CreateSound(CloudScript.Client, sound);
	CloudScript.ClientSounds[uniqueID]:PlayEx(0.75, 100);
end);

usermessage.Hook("cloud_StopSound", function(msg)
	local uniqueID = msg:ReadString();
	local fadeOut = msg:ReadFloat();
	
	if (!CloudScript.ClientSounds) then
		CloudScript.ClientSounds = {};
	end;
	
	if ( CloudScript.ClientSounds[uniqueID] ) then
		if (fadeOut != 0) then
			CloudScript.ClientSounds[uniqueID]:FadeOut(fadeOut);
		else
			CloudScript.ClientSounds[uniqueID]:Stop();
		end;
		
		CloudScript.ClientSounds[uniqueID] = nil;
	end;
end);

usermessage.Hook("cloud_dsStart", function(msg)
	NX_DS_NAME = msg:ReadString();
	NX_DS_DATA = msg:ReadString();
	NX_DS_INDEX = msg:ReadShort();
	
	if (NX_DS_INDEX == 1) then
		if ( CloudScript.DataStreamHooks[NX_DS_NAME] ) then
			CloudScript.DataStreamHooks[NX_DS_NAME]( glon.decode(NX_DS_DATA) );
		end;
		
		NX_DS_NAME, NX_DS_DATA, NX_DS_INDEX = nil, nil, nil;
	end;
end);

usermessage.Hook("cloud_InfoToggle", function(msg)
	if ( CloudScript.Client:HasInitialized() ) then
		CloudScript.InfoMenuOpen = true;
		CloudScript:RegisterBackgroundBlur( "InfoMenu", SysTime() );
	end;
end);

usermessage.Hook("cloud_PlaySound", function(msg)
	surface.PlaySound( msg:ReadString() );
end);

usermessage.Hook("cloud_dsData", function(msg)
	if (NX_DS_NAME and NX_DS_DATA and NX_DS_INDEX) then
		local data = msg:ReadString();
		local index = msg:ReadShort();
		
		NX_DS_DATA = NX_DS_DATA..data;
		
		if (NX_DS_INDEX == index) then
			if ( CloudScript.DataStreamHooks[NX_DS_NAME] ) then
				CloudScript.DataStreamHooks[NX_DS_NAME]( glon.decode(NX_DS_DATA) );
			end;
			
			NX_DS_NAME, NX_DS_DATA, NX_DS_INDEX = nil, nil, nil;
		end;
	end;
end);

usermessage.Hook("cloud_DataStreaming", function(msg)
	CloudScript:StartDataStream("DataStreamInfoSent", true);
end);

usermessage.Hook("cloud_DataStreamed", function(msg)
	CloudScript.DataHasStreamed = true;
end);

usermessage.Hook("cloud_QuizCompleted", function(msg)
	if ( !msg:ReadBool() ) then
		if ( !CloudScript.quiz:GetCompleted() ) then
			gui.EnableScreenClicker(true);
			
			CloudScript.quiz.panel = vgui.Create("cloud_Quiz");
			CloudScript.quiz.panel:Populate();
			CloudScript.quiz.panel:MakePopup();
		end;
	else
		local characterPanel = CloudScript.character:GetPanel();
		local quizPanel = CloudScript.quiz:GetPanel();
		
		CloudScript.quiz:SetCompleted(true);
		
		if (quizPanel) then
			quizPanel:Remove();
		end;
	end;
end);

usermessage.Hook("cloud_RecogniseMenu", function(msg)
	local menu = CloudScript:AddMenuFromData( nil, {
		["All characters within whispering range."] = function()
			CloudScript:StartDataStream("RecogniseOption", "whisper");
		end,
		["All characters within yelling range."] = function()
			CloudScript:StartDataStream("RecogniseOption", "yell");
		end,
		["All characters within talking range"] = function()
			CloudScript:StartDataStream("RecogniseOption", "talk");
		end
	} );
	
	if ( IsValid(menu) ) then
		menu:SetPos( (ScrW() / 2) - (menu:GetWide() / 2), (ScrH() / 2) - (menu:GetTall() / 2) );
	end;
	
	CloudScript:SetRecogniseMenu(menu);
end);

usermessage.Hook("cloud_CloudScriptIntro", function(msg)
	if (!CloudScript.CloudScriptIntroFadeOut) then
		local introImage = CloudScript.option:GetKey("intro_image");
		local duration = 8;
		local curTime = UnPredictedCurTime();
		
		if (introImage != "") then
			duration = 16;
		end;
		
		CloudScript.CloudScriptIntroWhiteScreen = curTime + (FrameTime() * 8);
		CloudScript.CloudScriptIntroFadeOut = curTime + duration;
		CloudScript.CloudScriptIntroSound = CreateSound(CloudScript.Client, "music/hl2_song25_teleporter.mp3");
		CloudScript.CloudScriptIntroSound:PlayEx(0.75, 100);
		
		timer.Simple(duration - 4, function()
			CloudScript.CloudScriptIntroSound:FadeOut(4);
			CloudScript.CloudScriptIntroSound = nil;
		end);
		
		surface.PlaySound("buttons/button1.wav");
	end;
end);

usermessage.Hook("cloud_SharedVar", function(msg)
	local key = msg:ReadString();
	local sharedVars = CloudScript:GetSharedVars():Player();
	
	if ( sharedVars and sharedVars[key] ) then
		local sharedVarData = sharedVars[key];
		local class = CloudScript:ConvertUserMessageClass(
			sharedVarData.class
		);
		
		if (class) then
			sharedVarData.value = msg["Read"..class](msg);
		end;
	end;
end);

usermessage.Hook("cloud_HideCommand", function(msg)
	local index = msg:ReadLong();
	
	for k, v in pairs(CloudScript.command.stored) do
		if (CloudScript:GetShortCRC(k) == index) then
			CloudScript.command:SetHidden( k, msg:ReadBool() );
			
			break;
		end;
	end;
end);

usermessage.Hook("cloud_ClearRecognisedNames", function(msg)
	CloudScript.RecognisedNames = {};
end);

usermessage.Hook("cloud_RecognisedName", function(msg)
	local key = msg:ReadLong();
	local status = msg:ReadShort();
	
	if (status > 0) then
		CloudScript.RecognisedNames[key] = status;
	else
		CloudScript.RecognisedNames[key] = nil;
	end;
end);

CloudScript:HookDataStream("Hint", function(data)
	CloudScript:AddTopHint(CloudScript:ParseData(data.text), data.delay, data.color, data.noSound);
end);

usermessage.Hook("cloud_PhysDesc", function(msg)
	Derma_StringRequest("Description", "What do you want to change your physical description to?", CloudScript.Client:GetSharedVar("physDesc"), function(text)
		CloudScript:RunCommand("CharPhysDesc", text);
	end);
end);

CloudScript:HookDataStream("CinematicText", function(data)
	CloudScript:AddCinematicText(data.text, data.color, data.barLength, data.hangTime);
end);

usermessage.Hook("cloud_Notification", function(msg)
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
	
	if ( CloudScript.plugin:Call("NotificationAdjustInfo", info) ) then
		CloudScript:AddNotify(info.text, info.class, 10);
		
		surface.PlaySound(info.sound);
		
		print(info.text);
	end;
end);

-- Called when a weapon is picked up and added to the HUD.
function CloudScript:HUDWeaponPickedUp(...) end;

-- Called when an item is picked up and added to the HUD.
function CloudScript:HUDItemPickedUp(...) end;

-- Called when some ammo is picked up and added to the HUD.
function CloudScript:HUDAmmoPickedUp(...) end;

-- Called when the context menu is opened.
function CloudScript:OnContextMenuOpen()
	if ( !self:IsUsingTool() ) then
		return false;
	end;
end;

-- Called when the CloudScript directory is rebuilt.
function CloudScript:CloudScriptDirectoryRebuilt(panel)
	for k, v in pairs(self.command.stored) do
		if ( !self.player:HasFlags(self.Client, v.access) ) then
			self.command:RemoveHelp(v);
		else
			self.command:AddHelp(v);
		end;
	end;
end;

-- Called when a Derma skin should be forced.
function CloudScript:ForceDermaSkin()
	return "CloudScript";
end;

-- Called when the local player's storage is rebuilding.
function CloudScript:PlayerStorageRebuilding(panel) end;

-- Called when the local player's storage is rebuilt.
function CloudScript:PlayerStorageRebuilt(panel, categories) end;

-- Called when the local player's business is rebuilt.
function CloudScript:PlayerBusinessRebuilt(panel, categories) end;

-- Called when the local player's inventory is rebuilt.
function CloudScript:PlayerInventoryRebuilt(panel, categories)
	if ( self.storage:IsStorageOpen() ) then
		self.storage:GetPanel():Rebuild();
	end;
end;

-- Called when a player's bullet info should be adjusted.
function CloudScript:PlayerAdjustBulletInfo(player, bulletInfo) end;

-- Called when CloudScript config has initialized.
function CloudScript:CloudScriptConfigInitialized(key, value)
	if (key == "cash_enabled" and !value) then
		for k, v in pairs( self.item:GetAll() ) do
			v.cost = 0;
		end;
	end;
end;

-- Called when a CloudScript ConVar has changed.
function CloudScript:CloudScriptConVarChanged(name, previousValue, newValue) end;

-- Called when CloudScript config has changed.
function CloudScript:CloudScriptConfigChanged(key, data, previousValue, newValue) end;

-- Called when the a custom business info label is needed.
function CloudScript:GetCustomBusinessInfoLabel(panel, itemTable) end;

-- Called when an entity's menu options are needed.
function CloudScript:GetEntityMenuOptions(entity, options)
	local class = entity:GetClass();
	local generator = self.generator:Get(class);
	
	if (class == "cloud_item") then
		local index = entity:GetDTInt("index");
		
		if (index != 0) then
			local itemTable = self.item:Get(index);
			
			if (itemTable) then
				local useText = itemTable.useText or "Use";
				
				if (itemTable.OnUse) then
					options[useText] = "cloud_itemUse";
				end;
				
				if ( self.item:IsWeapon(itemTable) ) then
					if ( itemTable:HasSecondaryClip()
					or itemTable:HasPrimaryClip() ) then
						options["Ammo"] = {
							arguments = true,
							uniqueID = "cloud_itemAmmo",
							toolTip = "Salvage any ammo from this weapon."
						}
					end;
				end;
				
				options["Take"] = "cloud_itemTake";
				options["Examine"] = {
					arguments = true,
					toolTip = itemTable.description,
					order = 1
				};
			end;
		end;
	elseif (class == "cloud_shipment") then
		options["Open"] = "cloud_shipmentOpen";
	elseif (class == "cloud_cash") then
		options["Take"] = "cloud_cashTake";
	elseif (generator) then
		if ( !entity.CanSupply or entity:CanSupply() ) then
			options["Supply"] = "cloud_generatorSupply";
		end;
	end;
end;

-- Called when the GUI mouse is released.
function CloudScript:GUIMouseReleased(code)
	if ( !self.config:Get("use_opens_entity_menus"):Get() ) then
		if ( vgui.CursorVisible() ) then
			local trace = self.Client:GetEyeTrace();
			
			if (IsValid(trace.Entity) and trace.HitPos:Distance( self.Client:GetShootPos() ) <= 80) then
				self.EntityMenu = self:HandleEntityMenu(trace.Entity);
				
				if ( IsValid(self.EntityMenu) ) then
					self.EntityMenu:SetPos( gui.MouseX() - (self.EntityMenu:GetWide() / 2), gui.MouseY() - (self.EntityMenu:GetTall() / 2) );
				end;
			end;
		end;
	end;
end;

-- Called when a key is released.
function CloudScript:KeyRelease(player, key)
	if ( self.config:Get("use_opens_entity_menus"):Get() ) then
		if (key == IN_USE) then
			local activeWeapon = player:GetActiveWeapon();
			local trace = self.Client:GetEyeTraceNoCursor();
			
			if (IsValid(activeWeapon) and activeWeapon:GetClass() == "weapon_physgun") then
				if ( player:KeyDown(IN_ATTACK) ) then
					return;
				end;
			end;
			
			if (IsValid(trace.Entity) and trace.HitPos:Distance( self.Client:GetShootPos() ) <= 80) then
				self.EntityMenu = self:HandleEntityMenu(trace.Entity);
				
				if ( IsValid(self.EntityMenu) ) then
					self.EntityMenu:SetPos( (ScrW() / 2) - (self.EntityMenu:GetWide() / 2), (ScrH() / 2) - (self.EntityMenu:GetTall() / 2) );
				end;
			end;
		end;
	end;
end;

-- Called when the local player is created.
function CloudScript:LocalPlayerCreated() end;

-- Called when the client initializes.
function CloudScript:Initialize()
	NX_CONVAR_TWELVEHOURCLOCK = self:CreateClientConVar("cloud_twelvehourclock", 0, true, true);
	NX_CONVAR_SHOWTIMESTAMPS = self:CreateClientConVar("cloud_showtimestamps", 0, true, true);
	NX_CONVAR_MAXCHATLINES = self:CreateClientConVar("cloud_maxchatlines", 10, true, true);
	NX_CONVAR_HEADBOBSCALE = self:CreateClientConVar("cloud_headbobscale", 1, true, true);
	NX_CONVAR_SHOWSERVER = self:CreateClientConVar("cloud_showserver", 1, true, true);
	NX_CONVAR_SHOWAURA = self:CreateClientConVar("cloud_showCloudScript", 1, true, true);
	NX_CONVAR_SHOWHINTS = self:CreateClientConVar("cloud_showhints", 1, true, true);
	NX_CONVAR_ADMINESP = self:CreateClientConVar("cloud_adminesp", 0, true, true);
	NX_CONVAR_SHOWLOG = self:CreateClientConVar("cloud_showlog", 1, true, true);
	NX_CONVAR_SHOWOOC = self:CreateClientConVar("cloud_showooc", 1, true, true);
	NX_CONVAR_SHOWIC = self:CreateClientConVar("cloud_showic", 1, true, true);
	
	if ( !self.option:GetKey("top_bars") ) then
		NX_CONVAR_TOPBARS = self:CreateClientConVar("cloud_topbars", 0, true, true);
	else
		self.setting:RemoveByConVar("cloud_topbars");
	end;
	
	self.plugin:Call("CloudScriptCoreLoaded");
	self.plugin:Call("CloudScriptInitialized");
	
	self.theme:CreateFonts();
	self.theme:CopySkin();
	self.theme:Initialize();
end;

-- Called when CloudScript has initialized.
function CloudScript:CloudScriptInitialized() end;

-- Called when an CloudScript item has initialized.
function CloudScript:CloudScriptItemInitialized(itemTable) end;

-- Called when a player's phys desc override is needed.
function CloudScript:GetPlayerPhysDescOverride(player, physDesc) end;

-- Called when a player's door access name is needed.
function CloudScript:GetPlayerDoorAccessName(player, door, owner)
	return player:Name();
end;

-- Called when a player should show on the door access list.
function CloudScript:PlayerShouldShowOnDoorAccessList(player, door, owner)
	return true;
end;

-- Called when a player should show on the scoreboard.
function CloudScript:PlayerShouldShowOnScoreboard(player)
	return true;
end;

-- Called when the local player attempts to zoom.
function CloudScript:PlayerCanZoom() return true; end;

-- Called when the local player attempts to see a business item.
function CloudScript:PlayerCanSeeBusinessItem(item) return true; end;

-- Called when a player presses a bind.
function CloudScript:PlayerBindPress(player, bind, press)
	local weapon = self.Client:GetActiveWeapon();
	local prefix = self.config:Get("command_prefix"):Get();
	
	if ( player:GetRagdollState() == RAGDOLL_FALLENOVER and string.find(bind, "+jump") ) then
		CloudScript:RunCommand("CharGetUp");
	elseif ( string.find(bind, "toggle_zoom") ) then
		return true;
	elseif ( string.find(bind, "+zoom") ) then
		if ( !self.plugin:Call("PlayerCanZoom") ) then
			return true;
		end;
	end;
	
	if ( string.find(bind, "+attack") or string.find(bind, "+attack2") ) then
		if ( self.storage:IsStorageOpen() ) then
			return true;
		end;
	end;
	
	if ( self.config:Get("block_inv_binds"):Get() ) then
		if ( string.find(string.lower(bind), prefix.."invaction")
		or string.find(string.lower(bind), "cloud invaction") ) then
			return true;
		end;
	end;
	
	return self.plugin:Call("TopLevelPlayerBindPress", player, bind, press);
end;

-- Called when a player presses a bind at the top level.
function CloudScript:TopLevelPlayerBindPress(player, bind, press)
	return self.BaseClass:PlayerBindPress(player, bind, press);
end;

-- Called when the local player attempts to see while unconscious.
function CloudScript:PlayerCanSeeUnconscious()
	return false;
end;

-- Called when the local player's move data is created.
function CloudScript:CreateMove(userCmd)
	local ragdollEyeAngles = self:GetRagdollEyeAngles();
	
	if ( ragdollEyeAngles and IsValid(self.Client) ) then
		local defaultSensitivity = 0.05;
		local sensitivity = defaultSensitivity * (self.plugin:Call("AdjustMouseSensitivity", defaultSensitivity) or defaultSensitivity);
		
		if (sensitivity <= 0) then
			sensitivity = defaultSensitivity;
		end;
		
		if ( self.Client:IsRagdolled() ) then
			ragdollEyeAngles.p = math.Clamp(ragdollEyeAngles.p + (userCmd:GetMouseY() * sensitivity), -48, 48);
			ragdollEyeAngles.y = math.Clamp(ragdollEyeAngles.y - (userCmd:GetMouseX() * sensitivity), -48, 48);
		else
			ragdollEyeAngles.p = math.Clamp(ragdollEyeAngles.p + (userCmd:GetMouseY() * sensitivity), -90, 90);
			ragdollEyeAngles.y = math.Clamp(ragdollEyeAngles.y - (userCmd:GetMouseX() * sensitivity), -90, 90);
		end;
	end
end

-- Called when the view should be calculated.
function CloudScript:CalcView(player, origin, angles, fov)
	if ( self.Client:IsRagdolled() ) then
		local ragdollEntity = self.Client:GetRagdollEntity();
		local ragdollState = self.Client:GetRagdollState();
		
		if (self.BlackFadeIn == 255) then
			return {origin = Vector(20000, 0, 0), angles = Angle(0, 0, 0), fov = fov};
		else
			local eyes = ragdollEntity:GetAttachment( ragdollEntity:LookupAttachment("eyes") );
			
			if (eyes) then
				local ragdollEyeAngles = eyes.Ang + self:GetRagdollEyeAngles();
				local physicsObject = ragdollEntity:GetPhysicsObject();
				
				if ( IsValid(physicsObject) ) then
					local velocity = physicsObject:GetVelocity().z;
					
					if (velocity <= -1000 and self.Client:GetMoveType() == MOVETYPE_WALK) then
						ragdollEyeAngles.p = ragdollEyeAngles.p + math.sin( UnPredictedCurTime() ) * math.abs( (velocity + 1000) - 16 );
					end;
				end;
				
				return {origin = eyes.Pos, angles = ragdollEyeAngles, fov = fov};
			else
				return self.BaseClass:CalcView(player, origin, angles, fov);
			end;
		end;
	elseif ( !self.Client:Alive() ) then
		return {origin = Vector(20000, 0, 0), angles = Angle(0, 0, 0), fov = fov};
	elseif ( self.config:Get("enable_headbob"):Get() ) then
		if ( player:IsOnGround() ) then
			local frameTime = FrameTime();
			
			if ( !self.player:IsNoClipping(player) ) then
				local approachTime = frameTime * 2;
				local curTime = UnPredictedCurTime();
				local info = {speed = 1, yaw = 0.5, roll = 0.1};
				
				if (!self.HeadbobAngle) then
					self.HeadbobAngle = 0;
				end;
				
				if (!self.HeadbobInfo) then
					self.HeadbobInfo = info;
				end;
				
				self.plugin:Call("PlayerAdjustHeadbobInfo", info);
				
				self.HeadbobInfo.yaw = math.Approach(self.HeadbobInfo.yaw, info.yaw, approachTime);
				self.HeadbobInfo.roll = math.Approach(self.HeadbobInfo.roll, info.roll, approachTime);
				self.HeadbobInfo.speed = math.Approach(self.HeadbobInfo.speed, info.speed, approachTime);
				self.HeadbobAngle = self.HeadbobAngle + (self.HeadbobInfo.speed * frameTime);
				
				local yawAngle = math.sin(self.HeadbobAngle);
				local rollAngle = math.cos(self.HeadbobAngle);
				
				angles.y = angles.y + (yawAngle * self.HeadbobInfo.yaw);
				angles.r = angles.r + (rollAngle * self.HeadbobInfo.roll);
			end;
		end;
	end;
	
	local velocity = player:GetVelocity();
	local eyeAngles = player:EyeAngles();
	
	if (!self.VelSmooth) then self.VelSmooth = 0; end;
	if (!self.WalkTimer) then self.WalkTimer = 0; end;
	if (!self.LastStrafeRoll) then self.LastStrafeRoll = 0; end;
	
	self.VelSmooth = math.Clamp( self.VelSmooth * 0.9 + velocity:Length() * 0.1, 0, 700 )
	self.WalkTimer = self.WalkTimer + self.VelSmooth * FrameTime() * 0.05
	
	self.LastStrafeRoll = (self.LastStrafeRoll * 3) + (eyeAngles:Right():DotProduct(velocity) * 0.0001 * self.VelSmooth * 0.3);
	self.LastStrafeRoll = self.LastStrafeRoll * 0.25;
	angles.r = angles.r + self.LastStrafeRoll;
	
	if (player:GetGroundEntity() != NULL) then
		angles.p = angles.p + math.cos(self.WalkTimer * 0.5) * self.VelSmooth * 0.000002 * self.VelSmooth;
		angles.r = angles.r + math.sin(self.WalkTimer) * self.VelSmooth * 0.000002 * self.VelSmooth;
		angles.y = angles.y + math.cos(self.WalkTimer) * self.VelSmooth * 0.000002 * self.VelSmooth;
	end;
	
	velocity = self.Client:GetVelocity().z;
	
	if (velocity <= -1000 and self.Client:GetMoveType() == MOVETYPE_WALK) then
		angles.p = angles.p + math.sin( UnPredictedCurTime() ) * math.abs( (velocity + 1000) - 16 );
	end;
	
	local view = self.BaseClass:CalcView(player, origin, angles, fov);
	local weapon = self.Client:GetActiveWeapon();
	local changedAngles = (view.vm_angles != nil);
	local changedOrigin = (view.vm_origin != nil);
	
	if ( IsValid(weapon) ) then
		local weaponRaised = self.player:GetWeaponRaised(self.Client);
		
		if (!self.Client:HasInitialized() or !self.config:HasInitialized()
		or self.Client:GetMoveType() == MOVETYPE_OBSERVER) then
			weaponRaised = nil;
		end;
		
		if (!weaponRaised) then
			local originalOrigin = Vector(origin.x, origin.y, origin.z);
			local originalAngles = Angle(angles.p, angles.y, angles.r);
			local originMod = Vector(-3.0451, -1.6419, -0.5771);
			local anglesMod = Angle(-12.9015, -47.2118, 5.1173);
			local itemTable = self.item:GetWeapon(weapon);
			
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
			
			local viewInfo = {
				origin = originMod,
				angles = anglesMod
			};
			
			self.plugin:Call("GetWeaponLoweredViewInfo", itemTable, weapon, viewInfo);
			
			originalAngles:RotateAroundAxis(originalAngles:Right(), viewInfo.angles.p);
			originalAngles:RotateAroundAxis(originalAngles:Up(), viewInfo.angles.y);
			originalAngles:RotateAroundAxis(originalAngles:Forward(), viewInfo.angles.r);
			
			originalOrigin = originalOrigin + viewInfo.origin.x * originalAngles:Right();
			originalOrigin = originalOrigin + viewInfo.origin.y * originalAngles:Forward();
			originalOrigin = originalOrigin + viewInfo.origin.z * originalAngles:Up();
			
			view.vm_origin = originalOrigin;
			view.vm_angles = originalAngles;
		elseif ( self.config:Get("use_free_aiming"):Get() ) then
			if (!self:IsDefaultWeapon(weapon) and !changedAngles) then
				-- Thanks to BlackOps7799 for this open source example.
				
				if (!self.SmoothViewAngle) then
					self.SmoothViewAngle = angles;
				else
					self.SmoothViewAngle = LerpAngle(RealFrameTime() * 16, self.SmoothViewAngle, angles);
				end;
				
				self.SmoothViewAngle.r = 0;
				
				view.angles = self.SmoothViewAngle;
				view.vm_origin = origin;
				view.vm_angles = angles;
			end;
		end;
	end;
	
	self.plugin:Call("CalcViewAdjustTable", view);
	
	return view;
end;

-- Called when the local player's limb damage is received.
function CloudScript:PlayerLimbDamageReceived() end;

-- Called when the local player's limb damage is reset.
function CloudScript:PlayerLimbDamageReset() end;

-- Called when the local player's limb damage is healed.
function CloudScript:PlayerLimbDamageHealed(hitGroup, amount) end;

-- Called when the local player's limb takes damage.
function CloudScript:PlayerLimbTakeDamage(hitGroup, damage) end;

-- Called when a weapon's lowered view info is needed.
function CloudScript:GetWeaponLoweredViewInfo(itemTable, weapon, viewInfo) end;

-- Called when a HUD element should be drawn.
function CloudScript:HUDShouldDraw(name)
	local blockedElements = {
		"CHudSecondaryAmmo",
		"CHudVoiceStatus",
		"CHudSuitPower",
		"CHudBattery",
		"CHudHealth",
		"CHudAmmo",
		"CHudChat"
	};
	
	if ( !IsValid(self.Client) or !self.Client:HasInitialized() or self:IsChoosingCharacter() ) then
		if (name != "CHudGMod") then
			return false;
		end;
	elseif (name == "CHudCrosshair") then
		if ( !IsValid(self.Client) or self.Client:IsRagdolled(RAGDOLL_FALLENOVER) ) then
			return false;
		end;
		
		if ( self.CharacterLoadingFinishTime
		and self.CharacterLoadingFinishTime > CurTime() ) then
			return false;
		end;
		
		if ( self:UsingCustomCrosshair() ) then
			return false;
		end;
	elseif ( table.HasValue(blockedElements, name) ) then
		return false;
	end;
	
	return self.BaseClass:HUDShouldDraw(name);
end

-- Called when the menu is opened.
function CloudScript:MenuOpened()
	for k, v in pairs( self.menu:GetItems() ) do
		if (v.panel.OnMenuOpened) then
			v.panel:OnMenuOpened();
		end;
	end;
end;

-- Called when the menu is closed.
function CloudScript:MenuClosed()
	for k, v in pairs( self.menu:GetItems() ) do
		if (v.panel.OnMenuClosed) then
			v.panel:OnMenuClosed();
		end;
	end;
	
	self:RemoveActiveToolTip();
	self:CloseActiveDermaMenus();
end;

-- Called when the character screen's faction characters should be sorted.
function CloudScript:CharacterScreenSortFactionCharacters(faction, a, b)
	return a.name < b.name;
end;

-- Called when the scoreboard's class players should be sorted.
function CloudScript:ScoreboardSortClassPlayers(class, a, b)
	local recogniseA = self.player:DoesRecognise(a);
	local recogniseB = self.player:DoesRecognise(b);
	
	if (recogniseA and recogniseB) then
		return a:Team() < b:Team();
	elseif (recogniseA) then
		return true;
	else
		return false;
	end;
end;

-- Called when the scoreboard's player info should be adjusted.
function CloudScript:ScoreboardAdjustPlayerInfo(info) end;

-- Called when the menu's items should be adjusted.
function CloudScript:MenuItemsAdd(menuItems)
	local attributesName = self.option:GetKey("name_attributes");
	local systemName = self.option:GetKey("name_system");
	local directoryName = self.option:GetKey("name_directory");
	local inventoryName = self.option:GetKey("name_inventory");
	local businessName = self.option:GetKey("name_business");
	
	menuItems:Add("Classes", "cloud_Classes", "Choose from a list of available classes.");
	menuItems:Add("Settings", "cloud_Settings", "Configure the way CloudScript works for you.");
	menuItems:Add("Donations", "cloud_Donations", "Check your donation subscriptions.");
	menuItems:Add("Scoreboard", "cloud_Scoreboard", "See which players are on the server.");
	menuItems:Add( systemName, "cloud_System", self.option:GetKey("description_system") );
	menuItems:Add( businessName, "cloud_Business", self.option:GetKey("description_business") );
	menuItems:Add( inventoryName, "cloud_Inventory", self.option:GetKey("description_inventory") );
	menuItems:Add( directoryName, "cloud_Directory", self.option:GetKey("description_directory") );
	menuItems:Add( attributesName, "cloud_Attributes", self.option:GetKey("description_attributes") );
end;

-- Called when the menu's items should be destroyed.
function CloudScript:MenuItemsDestroy(menuItems) end;

-- Called each tick.
function CloudScript:Tick()
	local realCurTime = CurTime();
	local curTime = UnPredictedCurTime();
	local font = self.option:GetFont("player_info_text");
	
	if ( self.character:IsPanelPolling() ) then
		local panel = self.character:GetPanel();
		
		if ( !panel and self.plugin:Call("ShouldCharacterMenuBeCreated") ) then
			self.character:SetPanelPolling(false);
			self.character.isOpen = true;
			
			self.character.panel = vgui.Create("cloud_CharacterMenu");
			self.character.panel:MakePopup();
			self.character.panel:ReturnToMainMenu();
			
			self.plugin:Call("PlayerCharacterScreenCreated", self.character.panel);
		end;
	end;
	
	if ( IsValid(self.Client) and !self:IsChoosingCharacter() ) then
		self.Bars.bars = {};
		self.PlayerInfoText.text = {};
		self.PlayerInfoText.width = ScrW() * 0.15;
		self.PlayerInfoText.subText = {};
		
		self:DrawHealthBar();
		self:DrawArmorBar();
		
		self.plugin:Call("GetBars", self.Bars);
		self.plugin:Call("DestroyBars", self.Bars);
		self.plugin:Call("GetPlayerInfoText", self.PlayerInfoText);
		self.plugin:Call("DestroyPlayerInfoText", self.PlayerInfoText);
		
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
		
		if ( self.config:Get("fade_dead_npcs"):Get() ) then
			for k, v in pairs( ents.FindByClass("class C_ClientRagdoll") ) do
				if ( !self.entity:IsDecaying(v) ) then
					self.entity:Decay(v, 300);
				end;
			end;
		end;
		
		local playedHeartbeatSound = false;
		
		if ( self.Client:Alive() and self.config:Get("enable_heartbeat"):Get() ) then
			local maxHealth = self.Client:GetMaxHealth();
			local health = self.Client:Health();
			
			if (health < maxHealth) then
				if (!self.HeartbeatSound) then
					self.HeartbeatSound = CreateSound(self.Client, "player/heartbeat1.wav");
				end;
				
				if (!self.NextHeartbeat or curTime >= self.NextHeartbeat) then
					self.NextHeartbeat = curTime + ( 0.75 + ( (1.25 / maxHealth) * health ) );
					self.HeartbeatSound:PlayEx(0.75 - ( (0.7 / maxHealth) * health ), 100);
				end;
				
				playedHeartbeatSound = true;
			end;
		end;
		
		if (!playedHeartbeatSound and self.HeartbeatSound) then
			self.HeartbeatSound:Stop();
		end;
	end;
	
	if (!self.NextHandleAttributeBoosts or realCurTime >= self.NextHandleAttributeBoosts) then
		self.NextHandleAttributeBoosts = realCurTime + 3;
		
		for k, v in pairs(self.attributes.boosts) do
			for k2, v2 in pairs(v) do
				if (v2.duration and v2.endTime) then
					if (realCurTime > v2.endTime) then
						self.attributes.boosts[k][k2] = nil;
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
	
	if ( self:IsInfoMenuOpen() and !input.IsKeyDown(KEY_F1) ) then
		self.InfoMenuOpen = false;
		self:RemoveBackgroundBlur("InfoMenu");
		
		if ( IsValid(self.InfoMenuPanel) ) then
			self.InfoMenuPanel:Remove();
		end;
		
		timer.Simple(FrameTime() * 0.5, function()
			self:RemoveActiveToolTip();
		end);
	end;
	
	local menuMusic = self.option:GetKey("menu_music");
	
	if (menuMusic != "") then
		if ( IsValid(self.Client) and self:IsCharacterScreenOpen(true) ) then
			if (!self.MusicSound) then
				self.MusicSound = CreateSound(self.Client, menuMusic);
				self.MusicSound:PlayEx(1, 100);
				self.MusicFading = false;
			end;
		elseif (self.MusicSound and !self.MusicFading) then
			self.MusicSound:FadeOut(8);
			self.MusicFading = true;
			
			timer.Simple(8, function()
				self.MusicSound = nil;
			end);
		end;
	end;
	
	local worldEntity = GetWorldEntity();
	
	for k, v in pairs(self.NetworkProxies) do
		if (IsValid(k) or k == worldEntity) then
			for k2, v2 in pairs(v) do
				local value = nil;
				
				if (k == worldEntity) then
					value = self:GetSharedVar(k2);
				else
					value = k:GetSharedVar(k2);
				end;
				
				if (value != v2.oldValue) then
					v2.Callback(k, k2, v2.oldValue, value);
					v2.oldValue = value;
				end;
			end;
		else
			self.NetworkProxies[k] = nil;
		end;
	end;
end;

-- Called when an entity is created.
function CloudScript:OnEntityCreated(entity)
	if ( entity == LocalPlayer() and IsValid(entity) ) then
		self.Client = entity;
	end;
end;

-- Called each frame.
function CloudScript:Think()
	if (!self.CreatedLocalPlayer) then
		if ( IsValid(self.Client) ) then
			self.plugin:Call("LocalPlayerCreated");
				self:StartDataStream("LocalPlayerCreated", true);
			self.CreatedLocalPlayer = true;
		end;
	end;
	
	self:CallTimerThink( CurTime() );
	self:CalculateHints();
	
	if ( self:IsCharacterScreenOpen() ) then
		local panel = self.character:GetPanel();
		
		if (panel) then
			panel:SetVisible( self.plugin:Call("GetPlayerCharacterScreenVisible", panel) );
			
			if ( panel:IsVisible() ) then
				self.HasCharacterMenuBeenVisible = true;
			end;
		end;
	end;
end;

-- Called when the character loading HUD should be painted.
function CloudScript:HUDPaintCharacterLoading(alpha) end;

-- Called when the character selection HUD should be painted.
function CloudScript:HUDPaintCharacterSelection() end;

-- Called when the important HUD should be painted.
function CloudScript:HUDPaintImportant() end;

-- Called when the top screen HUD should be painted.
function CloudScript:HUDPaintTopScreen(info) end;

local SCREEN_DAMAGE_OVERLAY = surface.GetTextureID("CloudScript/screendamage");
local VIGNETTE_OVERLAY = surface.GetTextureID("CloudScript/vignette");

-- Called when the local player's screen damage should be drawn.
function CloudScript:DrawPlayerScreenDamage(damageFraction)
	surface.SetDrawColor( 255, 255, 255, math.Clamp(255 * damageFraction, 0, 255) );
	surface.SetTexture(SCREEN_DAMAGE_OVERLAY);
	surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() );
end;

-- Called when the local player's vignette should be drawn.
function CloudScript:DrawPlayerVignette()
	local scrW, scrH = ScrW(), ScrH();
	
	surface.SetDrawColor(0, 0, 0, 200);
	surface.SetTexture(VIGNETTE_OVERLAY);
	surface.DrawTexturedRect(0, 0, scrW, scrH);
	surface.DrawTexturedRect(0, 0, scrW, scrH);
end;

-- Called when the foreground HUD should be painted.
function CloudScript:HUDPaintForeground()
	local backgroundColor = self.option:GetColor("background");
	local colorWhite = self.option:GetColor("white");
	local info = self.plugin:Call("GetProgressBarInfo");
	local menu = self:GetRecogniseMenu();
	
	if (info) then
		local x, y = self:GetScreenCenter();
		
		self:DrawBar(x - (ScrW() / 4), y + 48, (ScrW() / 2) - 64, 16, info.color or self.ProgressBarColor, info.text or "Progress Bar", info.percentage or 100, 100, info.flash);
	else
		info = self.plugin:Call("GetPostProgressBarInfo");
		
		if (info) then
			local x, y = self:GetScreenCenter();
			
			self:DrawBar(x - (ScrW() / 4), y + 48, (ScrW() / 2) - 64, 16, info.color or self.ProgressBarColor, info.text or "Progress Bar", info.percentage or 100, 100, info.flash);
		end;
	end;
	
	if ( self.player:IsAdmin(self.Client) ) then
		if ( self.plugin:Call("PlayerCanSeeAdminESP") ) then
			self:DrawAdminESP();
		end;
	end;
	
	local screenTextInfo = self.plugin:Call("GetScreenTextInfo");
	
	if (screenTextInfo) then
		local alpha = screenTextInfo.alpha or 255;
		local y = (ScrH() / 2) - 128;
		local x = ScrW() / 2;
		
		if (screenTextInfo.title) then
			self:OverrideMainFont( self.option:GetFont("menu_text_small") );
				y = self:DrawInfo(screenTextInfo.title, x, y, colorWhite, alpha);
			self:OverrideMainFont(false);
		end;
		
		if (screenTextInfo.text) then
			self:OverrideMainFont( self.option:GetFont("menu_text_tiny") );
				y = self:DrawInfo(screenTextInfo.text, x, y, colorWhite, alpha);
			self:OverrideMainFont(false);
		end;
	end;
	
	if ( IsValid(self.EntityMenu) ) then
		local menuTextTiny = self.option:GetFont("menu_text_tiny");
		local textDisplay = "INTERACT WITH THIS ENTITY";
		
		self:DrawSimpleGradientBox(2, self.EntityMenu.x - 4, self.EntityMenu.y - 4, self.EntityMenu:GetWide() + 8, self.EntityMenu:GetTall() + 8, backgroundColor);
		self:OverrideMainFont(menuTextTiny);
			self:DrawInfo(textDisplay, self.EntityMenu.x, self.EntityMenu.y, colorWhite, 255, true, function(x, y, width, height)
				return x, y - height - 4;
			end);
		self:OverrideMainFont(false);
	end;
	
	if ( IsValid(menu) ) then
		local menuTextTiny = self.option:GetFont("menu_text_tiny");
		local textDisplay = "SELECT WHO CAN RECOGNISE YOU";
		
		self:DrawSimpleGradientBox(2, menu.x - 4, menu.y - 4, menu:GetWide() + 8, menu:GetTall() + 8, backgroundColor);
		self:OverrideMainFont(menuTextTiny);
			self:DrawInfo(textDisplay, menu.x, menu.y, colorWhite, 255, true, function(x, y, width, height)
				return x, y - height - 4;
			end);
		self:OverrideMainFont(false);
	end;
	
	self.chatBox:Paint();
	
	local info = {
		width = ScrW() * 0.3,
		x = 8,
		y = 8
	};
	
	self:DrawBars(info, "top");
	self.plugin:Call("HUDPaintTopScreen", info);
end;

-- Called each frame that an item entity exists.
function CloudScript:CloudScriptItemEntityThink(itemTable, entity) end;

-- Called when an item entity is drawn.
function CloudScript:CloudScriptItemEntityDraw(itemTable, entity) end;

-- Called when a cash entity is drawn.
function CloudScript:CloudScriptCashEntityDraw(entity) end;

-- Called when a generator entity is drawn.
function CloudScript:CloudScriptGeneratorEntityDraw(entity) end;

-- Called when a shipment entity is drawn.
function CloudScript:CloudScriptShipmentEntityDraw(entity) end;

-- Called to get the screen text info.
function CloudScript:GetScreenTextInfo()
	local blackFadeAlpha = self:GetBlackFadeAlpha();
	
	if ( self.Client:GetSharedVar("banned") ) then
		return {
			alpha = blackFadeAlpha,
			title = "THIS CHARACTER IS BANNED",
			text = "Go to the characters menu to make a new one."
		};
	end;
end;

-- Called to get whether a player should move their mouth.
function CloudScript:PlayerShouldMoveMouth(player)
	return player:IsSpeaking();
end;

-- Called after the VGUI has been rendered.
function CloudScript:PostRenderVGUI()
	local cinematic = self.Cinematics[1];
	
	if (cinematic) then
		self:DrawCinematic( cinematic, CurTime() );
	end;
end;

-- Called to get whether the local player can see the admin ESP.
function CloudScript:PlayerCanSeeAdminESP()
	if (NX_CONVAR_ADMINESP:GetInt() == 1) then
		return true;
	else
		return false;
	end;
end;

-- Called when the local player attempts to get up.
function CloudScript:PlayerCanGetUp() return true; end;

-- Called when the local player attempts to see the top bars.
function CloudScript:PlayerCanSeeBars(class)
	if (class == "tab") then
		if (NX_CONVAR_TOPBARS) then
			return ( NX_CONVAR_TOPBARS:GetInt() == 0 and self:IsInfoMenuOpen() );
		else
			return self:IsInfoMenuOpen();
		end;
	elseif (class == "top") then
		if (NX_CONVAR_TOPBARS) then
			return NX_CONVAR_TOPBARS:GetInt() == 1;
		else
			return true;
		end;
	else
		return true;
	end;
end;

-- Called when the local player's limb info is needed.
function CloudScript:GetPlayerLimbInfo(info) end;

-- Called when the local player attempts to see the top hints.
function CloudScript:PlayerCanSeeHints()
	return true;
end;

-- Called when the local player attempts to see their limb damage.
function CloudScript:PlayerCanSeeLimbDamage()
	if ( self:IsInfoMenuOpen() and self.config:Get("limb_damage_system"):Get() ) then
		return true;
	else
		return false;
	end;
end;

-- Called when the local player attempts to see the date and time.
function CloudScript:PlayerCanSeeDateTime()
	return self:IsInfoMenuOpen();
end;

-- Called when the local player attempts to see a class.
function CloudScript:PlayerCanSeeClass(class)
	return true;
end;

-- Called when the local player attempts to see the player info.
function CloudScript:PlayerCanSeePlayerInfo()
	return self:IsInfoMenuOpen();
end;

-- Called when the target ID HUD should be drawn.
function CloudScript:HUDDrawTargetID()
	local targetIDTextFont = self.option:GetFont("target_id_text");
	local traceEntity = NULL;
	local colorWhite = self.option:GetColor("white");
	
	self:OverrideMainFont(targetIDTextFont);
	
	if ( IsValid(self.Client) and self.Client:Alive() and !IsValid(self.EntityMenu) ) then
		if ( !self.Client:IsRagdolled(RAGDOLL_FALLENOVER) ) then
			local fadeDistance = 196;
			local curTime = UnPredictedCurTime();
			local trace = self.player:GetRealTrace(self.Client);
			
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
						self.TargetIDData.fadeTime = curTime + 1;
					end;
					
					local class = trace.Entity:GetClass();
					local entity = self.entity:GetPlayer(trace.Entity);
					
					if (entity) then
						fadeDistance = self.plugin:Call("GetTargetPlayerFadeDistance", entity);
					end;
					
					local alpha = math.Clamp(self:CalculateAlphaFromDistance(fadeDistance, self.Client, trace.HitPos) * 1.5, 0, 255);
					
					if (alpha > 0) then
						alpha = math.min(alpha, math.Clamp(1 - ( (self.TargetIDData.fadeTime - curTime) / 3 ), 0, 1) * 255);
					end;
					
					self.TargetIDData.fadeDistance = fadeDistance;
					self.TargetIDData.player = entity;
					self.TargetIDData.alpha = alpha;
					self.TargetIDData.class = class;
					
					if (entity and self.Client != entity) then
						if ( self.plugin:Call("ShouldDrawPlayerTargetID", entity) ) then
							if ( !self.player:IsNoClipping(entity) ) then
								if (self.Client:GetShootPos():Distance(trace.HitPos) <= fadeDistance) then
									if (self.nextCheckRecognises and self.nextCheckRecognises[2] != entity) then
										self.Client:SetSharedVar("targetRecognises", true);
									end;
									
									local flashAlpha = nil;
									local toScreen = ( trace.HitPos + Vector(0, 0, 16) ):ToScreen();
									local x, y = toScreen.x, toScreen.y;
									
									if ( !self.player:DoesTargetRecognise() ) then
										flashAlpha = math.Clamp(math.sin(curTime * 2) * alpha, 0, 255);
									end;
									
									if ( self.player:DoesRecognise(entity, RECOGNISE_PARTIAL) ) then
										local text = string.Explode( "\n", self.plugin:Call("GetTargetPlayerName", entity) );
										local newY;
										
										for k, v in ipairs(text) do
											newY = self:DrawInfo(v, x, y, _team.GetColor( entity:Team() ), alpha);
											
											if (flashAlpha) then
												self:DrawInfo(v, x, y, colorWhite, flashAlpha);
											end;
											
											if (newY) then
												y = newY;
											end;
										end;
									else
										local unrecognisedName, usedPhysDesc = self.player:GetUnrecognisedName(entity);
										local wrappedTable = {unrecognisedName};
										local teamColor = _team.GetColor( entity:Team() );
										local result = self.plugin:Call("PlayerCanShowUnrecognised", entity, x, y, unrecognisedName, teamColor, alpha, flashAlpha);
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
									
									self.plugin:Call("GetTargetPlayerText", entity, self.TargetPlayerText);
									self.plugin:Call("DestroyTargetPlayerText", entity, self.TargetPlayerText);
									
									y = self.plugin:Call("DrawTargetPlayerStatus", entity, alpha, x, y) or y;
									
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
					elseif ( self.generator:Get(class) ) then
						if (self.Client:GetShootPos():Distance(trace.HitPos) <= fadeDistance) then
							local generator = self.generator:Get(class);
							local toScreen = ( trace.HitPos + Vector(0, 0, 16) ):ToScreen();
							local owner = self.entity:GetOwner(trace.Entity);
							local power = trace.Entity:GetPower();
							local x, y = toScreen.x, toScreen.y;
							
							y = self:DrawInfo(generator.name, x, y, Color(150, 150, 100, 255), alpha);
							y = self:DrawBar( x - 80, y, 160, 16, self.ProgressBarColor, generator.powerPlural, power, generator.power, power < (generator.power / 5) );
						end;
					elseif ( trace.Entity:IsWeapon() ) then
						if (self.Client:GetShootPos():Distance(trace.HitPos) <= fadeDistance) then
							local active = nil;
							for k, v in ipairs( _player.GetAll() ) do
								if (v:GetActiveWeapon() == trace.Entity) then
									active = true;
								end;
							end;
							
							if (!active) then
								local toScreen = ( trace.HitPos + Vector(0, 0, 16) ):ToScreen();
								local x, y = toScreen.x, toScreen.y;
								
								y = self:DrawInfo("An unknown weapon", x, y, Color(200, 100, 50, 255), alpha);
								y = self:DrawInfo("Press use to equip.", x, y, colorWhite, alpha);
							end;
						end;
					elseif (trace.Entity.HUDPaintTargetID) then
						local toScreen = ( trace.HitPos + Vector(0, 0, 16) ):ToScreen();
						local x, y = toScreen.x, toScreen.y;
						
						trace.Entity:HUDPaintTargetID(x, y, alpha);
					else
						local toScreen = ( trace.HitPos + Vector(0, 0, 16) ):ToScreen();
						local x, y = toScreen.x, toScreen.y;
						
						hook.Call( "HUDPaintEntityTargetID", CloudScript, trace.Entity, {
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
function CloudScript:DrawTargetPlayerStatus(target, alpha, x, y)
	local informationColor = self.option:GetColor("information");
	local gender = "He";
	
	if (self.player:GetGender(target) == GENDER_FEMALE) then
		gender = "She";
	end;
	
	if ( !target:Alive() ) then
		return self:DrawInfo(gender.." is clearly deceased.", x, y, informationColor, alpha);
	else
		return y;
	end;
end;

-- Called when the character creation panel has initialized.
function CloudScript:CharacterCreationPanelInitialized(panel) end;

-- Called when the local player's character creation info should be adjusted.
function CloudScript:PlayerAdjustCharacterCreationInfo(panel, info) end;

-- Called when the character panel tool tip is needed.
function CloudScript:GetCharacterPanelToolTip(panel, faction, character)
	return "There are "..#self.faction:GetPlayers(faction).."/"..self.faction:GetLimit(faction).." characters with this faction.";
end;

-- Called when the admin ESP info is needed.
function CloudScript:GetAdminESPInfo(info)
	for k, v in ipairs( _player.GetAll() ) do
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
				color = _team.GetColor( v:Team() ),
				text = v:Name().." ("..v:Health().."/"..v:GetMaxHealth()..")"
			};
		end;
	end;
end;

-- Called when the post progress bar info is needed.
function CloudScript:GetPostProgressBarInfo() end;

-- Called when the custom character options are needed.
function CloudScript:GetCustomCharacterOptions(character, options, menu) end;

-- Called when the custom character buttons are needed.
function CloudScript:GetCustomCharacterButtons(character, buttons) end;

-- Called when the progress bar info is needed.
function CloudScript:GetProgressBarInfo()
	local action, percentage = self.player:GetAction(self.Client, true);
	
	if (!self.Client:Alive() and action == "spawn") then
		return {text = "You will be respawned shortly.", percentage = percentage, flash = percentage < 10};
	end;
	
	if ( !self.Client:IsRagdolled() ) then
		if (action == "lock") then
			return {text = "The entity is being locked.", percentage = percentage, flash = percentage < 10};
		elseif (action == "unlock") then
			return {text = "The entity is being unlocked.", percentage = percentage, flash = percentage < 10};
		end;
	elseif (action == "unragdoll") then
		if (self.Client:GetRagdollState() == RAGDOLL_FALLENOVER) then
			return {text = "You are regaining stability.", percentage = percentage, flash = percentage < 10};
		else
			return {text = "You are regaining conciousness.", percentage = percentage, flash = percentage < 10};
		end;
	elseif (self.Client:GetRagdollState() == RAGDOLL_FALLENOVER) then
		local fallenOver = self.Client:GetSharedVar("fallenOver");
		
		if ( fallenOver and self.plugin:Call("PlayerCanGetUp") ) then
			return {text = "Press 'jump' to get up.", percentage = 100};
		end;
	end;
end;

-- Called just before the local player's information is drawn.
function CloudScript:PreDrawPlayerInfo(boxInfo, information, subInformation) end;

-- Called just after the local player's information is drawn.
function CloudScript:PostDrawPlayerInfo(boxInfo, information, subInformation) end;

-- Called when the player info text is needed.
function CloudScript:GetPlayerInfoText(playerInfoText)
	local cash = self.player:GetCash();
	local wages = self.player:GetWages();
	
	if ( self.config:Get("cash_enabled"):Get() ) then
		if (cash > 0) then
			playerInfoText:Add( "CASH", self.option:GetKey("name_cash")..": "..FORMAT_CASH(cash, true) );
		end;
		
		if (wages > 0) then
			playerInfoText:Add( "WAGES", self.Client:GetWagesName()..": "..FORMAT_CASH(wages) );
		end;
	end;

	playerInfoText:AddSub("NAME", self.Client:Name(), 2);
	playerInfoText:AddSub("CLASS", _team.GetName( self.Client:Team() ), 1);
end;

-- Called when the target player's fade distance is needed.
function CloudScript:GetTargetPlayerFadeDistance(player)
	return 4096;
end;

-- Called when the player info text should be destroyed.
function CloudScript:DestroyPlayerInfoText(playerInfoText) end;

-- Called when the target player's text is needed.
function CloudScript:GetTargetPlayerText(player, targetPlayerText)
	local targetIDTextFont = self.option:GetFont("target_id_text");
	local physDescTable = {};
	local thirdPerson = "him";
	
	if (self.player:GetGender(player) == GENDER_FEMALE) then
		thirdPerson = "her";
	end;
	
	if ( self.player:DoesRecognise(player, RECOGNISE_PARTIAL) ) then
		self:WrapText(self.player:GetPhysDesc(player), targetIDTextFont, math.max(ScrW() / 9, 384), physDescTable);
		
		for k, v in ipairs(physDescTable) do
			targetPlayerText:Add("PHYSDESC_"..k, v);
		end;
	elseif ( player:Alive() ) then
		targetPlayerText:Add("PHYSDESC", "You do not recognise "..thirdPerson..".");
	end;
end;

-- Called when the target player's text should be destroyed.
function CloudScript:DestroyTargetPlayerText(player, targetPlayerText) end;

-- Called when a player's scoreboard text is needed.
function CloudScript:GetPlayerScoreboardText(player)
	local thirdPerson = "him";
	
	if (self.player:GetGender(player) == GENDER_FEMALE) then
		thirdPerson = "her";
	end;
	
	if ( self.player:DoesRecognise(player, RECOGNISE_PARTIAL) ) then
		local physDesc = self.player:GetPhysDesc(player);
		
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
function CloudScript:GetPlayerCharacterScreenFaction(character)
	return character.faction;
end;

-- Called to get whether the local player's character screen is visible.
function CloudScript:GetPlayerCharacterScreenVisible(panel)
	if ( !self.quiz:GetEnabled() or self.quiz:GetCompleted() ) then
		return true;
	else
		return false;
	end;
end;

-- Called to get whether the character menu should be created.
function CloudScript:ShouldCharacterMenuBeCreated()
	if (self.CloudScriptIntroFadeOut) then
		return false;
	end;
	
	return true;
end;

-- Called when the local player's character screen is created.
function CloudScript:PlayerCharacterScreenCreated(panel)
	if ( self.quiz:GetEnabled() ) then
		CloudScript:StartDataStream("GetQuizStatus", true);
	end;
end;

-- Called when a player's scoreboard class is needed.
function CloudScript:GetPlayerScoreboardClass(player)
	return _team.GetName( player:Team() );
end;

-- Called when a player's scoreboard options are needed.
function CloudScript:GetPlayerScoreboardOptions(player, options, menu)
	local charTakeFlags = self.command:Get("CharTakeFlags");
	local charGiveFlags = self.command:Get("CharGiveFlags");
	local charGiveItem = self.command:Get("CharGiveItem");
	local charSetName = self.command:Get("CharSetName");
	local plySetGroup = self.command:Get("PlySetGroup");
	local plyDemote = self.command:Get("PlyDemote");
	local charBan = self.command:Get("CharBan");
	local plyKick = self.command:Get("PlyKick");
	local plyBan = self.command:Get("PlyBan");
	
	if ( charBan and self.player:HasFlags(self.Client, charBan.access) ) then
		options["Ban Character"] = function()
			RunConsoleCommand( "cloud", "CharBan", player:Name() );
		end;
	end;
	
	if ( plyKick and self.player:HasFlags(self.Client, plyKick.access) ) then
		options["Kick Player"] = function()
			Derma_StringRequest(player:Name(), "What is your reason for kicking them?", nil, function(text)
				CloudScript:RunCommand("PlyKick", player:Name(), text);
			end);
		end;
	end;
	
	if ( plyBan and self.player:HasFlags(self.Client, self.command:Get("PlyBan").access) ) then
		options["Ban Player"] = function()
			Derma_StringRequest(player:Name(), "How many minutes would you like to ban them for?", nil, function(minutes)
				Derma_StringRequest(player:Name(), "What is your reason for banning them?", nil, function(reason)
					CloudScript:RunCommand("PlyBan", player:Name(), minutes, reason);
				end);
			end);
		end;
	end;
	
	if ( charGiveFlags and self.player:HasFlags(self.Client, charGiveFlags.access) ) then
		options["Give Flags"] = function()
			Derma_StringRequest(player:Name(), "What flags would you like to give them?", nil, function(text)
				CloudScript:RunCommand("CharGiveFlags", player:Name(), text);
			end);
		end;
	end;
	
	if ( charTakeFlags and self.player:HasFlags(self.Client,charTakeFlags.access) ) then
		options["Take Flags"] = function()
			Derma_StringRequest(player:Name(), "What flags would you like to take from them?", player:GetSharedVar("flags"), function(text)
				CloudScript:RunCommand("CharTakeFlags", player:Name(), text);
			end);
		end;
	end;
	
	if ( charSetName and self.player:HasFlags(self.Client, charSetName.access) ) then
		options["Set Name"] = function()
			Derma_StringRequest(player:Name(), "What would you like to set their name to?", player:Name(), function(text)
				CloudScript:RunCommand("CharSetName", player:Name(), text);
			end);
		end;
	end;
	
	if ( charGiveItem and self.player:HasFlags(self.Client, charGiveItem.access) ) then
		options["Give Item"] = function()
			Derma_StringRequest(player:Name(), "What item would you like to give them?", nil, function(text)
				CloudScript:RunCommand("CharGiveItem", player:Name(), text);
			end);
		end;
	end;
	
	if ( plySetGroup and self.player:HasFlags(self.Client, plySetGroup.access) ) then
		options["Set Group"] = {};
		options["Set Group"]["Super Admin"] = function()
			CloudScript:RunCommand("PlySetGroup", player:Name(), "superadmin");
		end;
		options["Set Group"]["Admin"] = function()
			CloudScript:RunCommand("PlySetGroup", player:Name(), "admin");
		end;
		options["Set Group"]["Operator"] = function()
			CloudScript:RunCommand("PlySetGroup", player:Name(), "operator");
		end;
	end;
	
	if ( plyDemote and self.player:HasFlags(self.Client, plyDemote.access) ) then
		options["Demote"] = function()
			CloudScript:RunCommand( "PlyDemote", player:Name() );
		end;
	end;
	
	local canUwhitelist = false;
	local canWhitelist = false;
	local unwhitelist = self.command:Get("PlyUnwhitelist");
	local whitelist = self.command:Get("PlyWhitelist");
	
	if (whitelist and self.player:HasFlags(self.Client, whitelist.access) ) then
		canWhitelist = true;
	end;
	
	if (unwhitelist and self.player:HasFlags(self.Client, unwhitelist.access) ) then
		canUnwhitelist = true;
	end;
	
	if (canWhitelist or canUwhitelist) then
		local areWhitelistFactions = false;
		
		for k, v in pairs(self.faction.stored) do
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
			
			for k, v in pairs(self.faction.stored) do
				if (v.whitelist) then
					if ( options["Whitelist"] ) then
						options["Whitelist"][k] = function()
							CloudScript:RunCommand("PlyWhitelist", player:Name(), k);
						end;
					end;
					
					if ( options["Unwhitelist"] ) then
						options["Unwhitelist"][k] = function()
							CloudScript:RunCommand("PlyUnwhitelist", player:Name(), k);
						end;
					end;
				end;
			end;
		end;
	end;
end;

-- Called when information about a door is needed.
function CloudScript:GetDoorInfo(door, information)
	local doorCost = self.config:Get("door_cost"):Get();
	local owner = self.entity:GetOwner(door);
	local text = self.entity:GetDoorText(door);
	local name = self.entity:GetDoorName(door);
	
	if (information == DOOR_INFO_NAME) then
		if ( self.entity:IsDoorHidden(door)
		or self.entity:IsDoorFalse(door) ) then
			return false;
		elseif (name == "") then
			return "Door";
		else
			return name;
		end;
	elseif (information == DOOR_INFO_TEXT) then
		if ( self.entity:IsDoorUnownable(door) ) then
			if ( !self.entity:IsDoorHidden(door)
			and !self.entity:IsDoorFalse(door) ) then
				if (text == "") then
					return "This door is unownable.";
				else
					return text;
				end;
			else
				return false;
			end;
		elseif (text != "") then
			if ( self.entity:HasOwner(door) and !IsValid(owner) ) then
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
function CloudScript:PostProcessPermitted(class)
	return false;
end;

-- Called just after the opaque renderables have been drawn.
function CloudScript:PostDrawOpaqueRenderables(drawingDepth, drawingSkybox)
	if (drawingSkybox or drawingDepth) then
		return;
	end;
	
	local colorWhite = self.option:GetColor("white");
	local colorInfo = self.option:GetColor("information");
	local doorFont = self.option:GetFont("large_3d_2d");
	local eyeAngles = EyeAngles();
	local eyePos = EyePos();
	
	if ( !self:IsChoosingCharacter() ) then
		cam.Start3D(eyePos, eyeAngles);
			local entities = ents.FindInSphere(eyePos, 256);
			
			for k, v in pairs(entities) do
				if ( IsValid(v) and self.entity:IsDoor(v) ) then
					self:DrawDoorText(v, eyePos, eyeAngles, doorFont, colorInfo, colorWhite);
				end;
			end;
		cam.End3D();
	end;
end;

-- Called when screen space effects should be rendered.
function CloudScript:RenderScreenspaceEffects()
	if ( IsValid(self.Client) ) then
		local frameTime = FrameTime();
		local motionBlurs = {
			enabled = true,
			blurTable = {}
		};
		local color = 1;
		local drunk = self.player:GetDrunk();
		
		if ( !self:IsChoosingCharacter() ) then
			if ( self.limb:IsActive() and self.event:CanRun("blur", "limb_damage") ) then
				local headDamage = self.limb:GetDamage(HITGROUP_HEAD);
				motionBlurs.blurTable["health"] = math.Clamp(1 - (headDamage * 0.01), 0, 1);
			elseif (self.Client:Health() <= 75) then
				if ( self.event:CanRun("blur", "health") ) then
					motionBlurs.blurTable["health"] = math.Clamp(1 - ( ( self.Client:GetMaxHealth() - self.Client:Health() ) * 0.01 ), 0, 1);
				end;
			end;
			
			if ( self.Client:Alive() ) then
				color = math.Clamp(color - ( ( self.Client:GetMaxHealth() - self.Client:Health() ) * 0.01 ), 0, color);
			else
				color = 0;
			end;
			
			if ( self.event:CanRun("blur", "drunk") ) then
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
		
		if (self.OverrideColorMod and self.OverrideColorMod.enabled) then
			self.ColorModify["$pp_colour_brightness"] = self.OverrideColorMod.brightness;
			self.ColorModify["$pp_colour_contrast"] = self.OverrideColorMod.contrast;
			self.ColorModify["$pp_colour_colour"] = self.OverrideColorMod.color;
			self.ColorModify["$pp_colour_addr"] = self.OverrideColorMod.addr * 0.02;
			self.ColorModify["$pp_colour_addg"] = self.OverrideColorMod.addg * 0.02;
			self.ColorModify["$pp_colour_addb"] = self.OverrideColorMod.addg * 0.02;
			self.ColorModify["$pp_colour_mulr"] = self.OverrideColorMod.mulr * 0.1;
			self.ColorModify["$pp_colour_mulg"] = self.OverrideColorMod.mulg * 0.1;
			self.ColorModify["$pp_colour_mulb"] = self.OverrideColorMod.mulb * 0.1;
		else
			self.plugin:Call("PlayerSetDefaultColorModify", self.ColorModify);
		end;
		
		self.plugin:Call("PlayerAdjustColorModify", self.ColorModify);
		self.plugin:Call("PlayerAdjustMotionBlurs", motionBlurs);
		
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
function CloudScript:ChatBoxOpened() end;

-- Called when the chat box is closed.
function CloudScript:ChatBoxClosed(textTyped) end;

-- Called when the chat box text has been typed.
function CloudScript:ChatBoxTextTyped(text)
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
function CloudScript:CalcViewAdjustTable(view) end;

-- Called when the chat box info should be adjusted.
function CloudScript:ChatBoxAdjustInfo(info) end;

-- Called when the chat box text has changed.
function CloudScript:ChatBoxTextChanged(previousText, newText) end;

-- Called when the chat box has had a key code typed in.
function CloudScript:ChatBoxKeyCodeTyped(code, text)
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
function CloudScript:NotificationAdjustInfo(info)
	return true;
end;

-- Called when the local player's business item should be adjusted.
function CloudScript:PlayerAdjustBusinessItemTable(itemTable) end;

-- Called when the local player's class model info should be adjusted.
function CloudScript:PlayerAdjustClassModelInfo(class, info) end;

-- Called when the local player's headbob info should be adjusted.
function CloudScript:PlayerAdjustHeadbobInfo(info)
	local drunk = self.player:GetDrunk();
	local scale = NX_CONVAR_HEADBOBSCALE:GetFloat() or 1;
	
	if ( self.Client:IsRunning() ) then
		info.speed = (info.speed * 8) * scale;
		info.roll = (info.roll * 4) * scale;
	elseif ( self.Client:IsJogging() ) then
		info.speed = (info.speed * 8) * scale;
		info.roll = (info.roll * 3) * scale;
	elseif (self.Client:GetVelocity():Length() > 0) then
		info.speed = (info.speed * 6) * scale;
		info.roll = (info.roll * 2) * scale;
	else
		info.roll = info.roll * scale;
	end;
	
	if (drunk) then
		info.speed = info.speed * math.min(drunk * 0.25, 4);
		info.yaw = info.yaw * math.min(drunk, 4);
	end;
end;

-- Called when the local player's motion blurs should be adjusted.
function CloudScript:PlayerAdjustMotionBlurs(motionBlurs) end;

-- Called when the local player's item menu should be adjusted.
function CloudScript:PlayerAdjustMenuFunctions(itemTable, menuPanel, itemFunctions) end;

-- Called when the local player's item functions should be adjusted.
function CloudScript:PlayerAdjustItemFunctions(itemTable, itemFunctions) end;

-- Called when the local player's default colorify should be set.
function CloudScript:PlayerSetDefaultColorModify(colorModify) end;

-- Called when the local player's colorify should be adjusted.
function CloudScript:PlayerAdjustColorModify(colorModify) end;

-- Called to get whether a player's target ID should be drawn.
function CloudScript:ShouldDrawPlayerTargetID(player)
	return true;
end;

-- Called to get whether the local player's screen should fade black.
function CloudScript:ShouldPlayerScreenFadeBlack()
	if ( !self.Client:Alive() or self.Client:IsRagdolled(RAGDOLL_FALLENOVER) ) then
		if ( !self.plugin:Call("PlayerCanSeeUnconscious") ) then
			return true;
		end;
	end;
	
	return false;
end;

-- Called when the menu background blur should be drawn.
function CloudScript:ShouldDrawMenuBackgroundBlur()
	return true;
end;

-- Called when the character background blur should be drawn.
function CloudScript:ShouldDrawCharacterBackgroundBlur()
	return true;
end;

-- Called when the character background should be drawn.
function CloudScript:ShouldDrawCharacterBackground()
	return true;
end;

-- Called when the character fault should be drawn.
function CloudScript:ShouldDrawCharacterFault(fault)
	return true;
end;

-- Called when the score board should be drawn.
function CloudScript:HUDDrawScoreBoard()
	self.BaseClass:HUDDrawScoreBoard(player);
	
	local drawPendingScreenBlack = nil;
	local drawCharacterLoading = nil;
	local hasClientInitialized = self.Client:HasInitialized();
	local introTextSmallFont = self.option:GetFont("intro_text_small");
	local colorWhite = self.option:GetColor("white");
	local curTime = UnPredictedCurTime();
	local scrH = ScrH();
	local scrW = ScrW();
	
	if ( self:IsChoosingCharacter() ) then
		if ( self.plugin:Call("ShouldDrawCharacterBackground") ) then
			self:DrawSimpleGradientBox( 0, 0, 0, ScrW(), ScrH(), Color(0, 0, 0, 255) );
		end;
		
		self.plugin:Call("HUDPaintCharacterSelection");
	elseif (!hasClientInitialized) then
		if ( !self.HasCharacterMenuBeenVisible
		and self.plugin:Call("ShouldDrawCharacterBackground") ) then
			drawPendingScreenBlack = true;
		end;
	end;
	
	if (hasClientInitialized) then
		if (!self.CharacterLoadingFinishTime) then
			local loadingTime = self.plugin:Call("GetCharacterLoadingTime");
			
			self.CharacterLoadingDelay = loadingTime;
			self.CharacterLoadingFinishTime = curTime + loadingTime;
		end;
		
		if ( !self:IsChoosingCharacter() ) then
			self:CalculateScreenFading();
			
			if ( !self:IsUsingCamera() ) then
				self.plugin:Call("HUDPaintForeground");
			end;
			
			self.plugin:Call("HUDPaintImportant");
		end;
		
		if (self.CharacterLoadingFinishTime > curTime) then
			drawCharacterLoading = true;
		elseif (!self.CinematicScreenDone) then
			self:DrawCinematicIntro(curTime);
			self:DrawCinematicIntroBars();
		end;
	end;
	
	if ( self.plugin:Call("ShouldDrawBackgroundBlurs") ) then
		self:DrawBackgroundBlurs();
	end;

	if ( !self.player:HasDataStreamed() ) then
		if (!self.DataStreamedAlpha) then
			self.DataStreamedAlpha = 255;
		end;
	elseif (self.DataStreamedAlpha) then
		self.DataStreamedAlpha = math.Approach(self.DataStreamedAlpha, 0, FrameTime() * 100);
		
		if (self.DataStreamedAlpha <= 0) then
			self.DataStreamedAlpha = nil;
		end;
	end;
	
	if (self.CloudScriptIntroFadeOut) then
		local duration = 8;
		local introImage = self.option:GetKey("intro_image");
		
		if (introImage != "") then
			duration = 16;
		end;
		
		local timeLeft = math.Clamp(self.CloudScriptIntroFadeOut - curTime, 0, duration);
		local material = self.CloudScriptIntroOverrideImage or self.CloudScriptSplash;
		local sineWave = math.sin(curTime);
		local height = 256;
		local width = 512;
		local alpha = 255;
		
		if (!self.CloudScriptIntroOverrideImage) then
			if (introImage != "" and timeLeft <= 8) then
				self.CloudScriptIntroWhiteScreen = curTime + (FrameTime() * 8);
				self.CloudScriptIntroOverrideImage = Material(introImage);
				
				surface.PlaySound("buttons/button1.wav");
			end;
		end;
		
		if (timeLeft <= 3) then
			alpha = (255 / 3) * timeLeft;
		end;
		
		if (timeLeft == 0) then
			self.CloudScriptIntroFadeOut = nil;
			self.CloudScriptIntroOverrideImage = nil;
		end;
		
		if (sineWave > 0) then
			width = width - (sineWave * 8);
			height = height - (sineWave * 2);
		end;
		
		if (curTime <= self.CloudScriptIntroWhiteScreen) then
			self:DrawSimpleGradientBox( 0, 0, 0, scrW, scrH, Color(255, 255, 255, alpha) );
		else
			self:DrawSimpleGradientBox( 0, 0, 0, scrW, scrH, Color(0, 0, 0, alpha) );
			self.CloudScriptSplash:SetMaterialFloat("$alpha", alpha / 255);
			
			surface.SetDrawColor(255, 255, 255, alpha);
				surface.SetMaterial(material);
			surface.DrawTexturedRect( (scrW / 2) - (width / 2), (scrH / 2) - (height / 2), width, height );
		end;
		
		drawPendingScreenBlack = nil;
	end;
	
	if (self.DataStreamedAlpha and self.DataStreamedAlpha > 0) then
		local textString = "Please wait while CloudScript initializes.";
		
		if (!self.CreatedLocalPlayer) then
			textString = "Please wait while Source creates the local player.";
		elseif ( !self.config:HasInitialized() ) then
			textString = "Please wait while the server config is retrieved.";
		end;
		
		self:DrawSimpleGradientBox( 0, 0, 0, scrW, scrH, Color(0, 0, 0, self.DataStreamedAlpha) );
		draw.SimpleText(textString, introTextSmallFont, scrW / 2, scrH / 2, Color(colorWhite.r, colorWhite.g, colorWhite.b, self.DataStreamedAlpha), 1, 1);
		
		drawPendingScreenBlack = nil;
	end;
	
	if ( CloudScript:GetSharedVar("noMySQL") ) then
		self:DrawSimpleGradientBox( 0, 0, 0, scrW, scrH, Color(0, 0, 0, 255) );
		draw.SimpleText("The server encountered a problem connecting to MySQL.", introTextSmallFont, scrW / 2, scrH / 2, Color(179, 46, 49, 255), 1, 1);
	end;
	
	if (drawCharacterLoading) then
		self.plugin:Call( "HUDPaintCharacterLoading", math.Clamp( (255 / self.CharacterLoadingDelay) * (self.CharacterLoadingFinishTime - curTime), 0, 255) );
	elseif (drawPendingScreenBlack) then
		self:DrawSimpleGradientBox( 0, 0, 0, ScrW(), ScrH(), Color(0, 0, 0, 255) );
	end;
	
	if (self.CharacterLoadingFinishTime) then
		if (!self.CinematicInfoDrawn) then
			self:DrawCinematicInfo();
		end;
		
		if (!self.CinematicBarsDrawn) then
			self:DrawCinematicIntroBars();
		end;
	end;
	
	self.plugin:Call("PostDrawBackgroundBlurs");
end;

-- Called when the background blurs should be drawn.
function CloudScript:ShouldDrawBackgroundBlurs()
	return true;
end;

-- Called just after the background blurs have been drawn.
function CloudScript:PostDrawBackgroundBlurs()
	local introTextSmallFont = self.option:GetFont("intro_text_small");
	local position = self.plugin:Call("GetChatBoxPosition");
	
	if (position) then
		self.chatBox:SetCustomPosition(position.x, position.y);
	end;
	
	local panelInfo = self.CurrentFactionSelected;
	
	if (panelInfo and IsValid( panelInfo[1] ) and panelInfo[1]:IsVisible() ) then
		local factionTable = self.faction:Get( panelInfo[2] );
		
		if (factionTable and factionTable.material) then
			if ( !panelInfo[3] ) then
				panelInfo[3] = surface.GetTextureID(factionTable.material);
			end;
			
			surface.SetDrawColor( 255, 255, 255, panelInfo[1]:GetAlpha() );
			surface.SetTexture( panelInfo[3] );
			surface.DrawTexturedRect(panelInfo[1].x, panelInfo[1].y + panelInfo[1]:GetTall() + 16, 512, 256);
		end;
	end;
	
	self:DrawDateTime();
end;

-- Called just before a bar is drawn.
function CloudScript:PreDrawBar(barInfo) end;

-- Called just after a bar is drawn.
function CloudScript:PostDrawBar(barInfo) end;

-- Called when the top bars are needed.
function CloudScript:GetBars(bars) end;

-- Called when the top bars should be destroyed.
function CloudScript:DestroyBars(bars) end;

-- Called when the chat box position is needed.
function CloudScript:GetChatBoxPosition()
	return {x = 8, y = ScrH() - 40};
end;

-- Called when the cinematic intro info is needed.
function CloudScript:GetCinematicIntroInfo()
	return {
		credits = "A roleplaying game designed by "..self.schema:GetAuthor()..".",
		title = self.schema:GetName(),
		text = self.schema:GetDescription()
	};
end;

-- Called when the character loading time is needed.
function CloudScript:GetCharacterLoadingTime() return 8; end;

-- Called when a player's HUD should be painted.
function CloudScript:HUDPaintPlayer(player) end;

-- Called when the HUD should be painted.
function CloudScript:HUDPaint()
	if ( !self:IsChoosingCharacter() and !self:IsUsingCamera() ) then
		if ( self.event:CanRun("view", "damage") and self.Client:Alive() ) then
			local maxHealth = self.Client:GetMaxHealth();
			local health = self.Client:Health();
			
			if (health < maxHealth) then
				self.plugin:Call( "DrawPlayerScreenDamage", 1 - ( (1 / maxHealth) * health ) );
			end;
		end;
		
		if ( self.event:CanRun("view", "vignette") and self.config:Get("enable_vignette"):Get() ) then
			self.plugin:Call("DrawPlayerVignette");
		end;
		
		local weapon = self.Client:GetActiveWeapon();
		self.BaseClass:HUDPaint();
		
		if ( !self:IsScreenFadedBlack() ) then
			for k, v in ipairs( _player.GetAll() ) do
				if (v:HasInitialized() and v != self.Client) then
					self.plugin:Call("HUDPaintPlayer", v);
				end;
			end;
		end;
		
		if ( !self:IsUsingTool() ) then
			self:DrawHints();
		end;
		
		if ( ( self.config:Get("enable_crosshair") or self:IsDefaultWeapon(weapon) )
		and (IsValid(weapon) and weapon.DrawCrosshair != false) ) then
			local info = {
				color = Color(255, 255, 255, 255),
				x = ScrW() / 2,
				y = ScrH() / 2
			};
			
			self.plugin:Call("GetPlayerCrosshairInfo", info);
			self.CustomCrosshair = self.plugin:Call("DrawPlayerCrosshair", info.x, info.y, info.color);
		else
			self.CustomCrosshair = false;
		end;
	end;
end;

-- Called when the local player's crosshair info is needed.
function CloudScript:GetPlayerCrosshairInfo(info)
	if ( self.config:Get("use_free_aiming"):Get() ) then
		-- Thanks to BlackOps7799 for this open source example.
		
		local traceLine = util.TraceLine( {
			start = self.Client:EyePos(),
			endpos = self.Client:EyePos() + (self.Client:GetAimVector() * 1024 * 1024),
			filter = self.Client
		} );
		
		local screenPos = traceLine.HitPos:ToScreen();
		
		info.x = screenPos.x;
		info.y = screenPos.y;
	end;
end;

-- Called when the local player's crosshair should be drawn.
function CloudScript:DrawPlayerCrosshair(x, y, color)
	if ( self.config:Get("use_free_aiming"):Get() ) then
		surface.SetDrawColor(color.r, color.g, color.b, color.a);
		surface.DrawRect(x, y, 2, 2);
		surface.DrawRect(x, y + 9, 2, 2);
		surface.DrawRect(x, y - 9, 2, 2);
		surface.DrawRect(x + 9, y, 2, 2);
		surface.DrawRect(x - 9, y, 2, 2);
		
		return true;
	else
		return false;
	end;
end;

-- Called when a player starts using voice.
function CloudScript:PlayerStartVoice(player)
	if ( self.config:Get("local_voice"):Get() ) then
		if ( player:IsRagdolled(RAGDOLL_FALLENOVER) or !player:Alive() ) then
			return;
		end;
	end;
	
	if (self.BaseClass and self.BaseClass.PlayerStartVoice) then
		self.BaseClass:PlayerStartVoice(player);
	end;
end;

-- Called to check if a player does have an flag.
function CloudScript:PlayerDoesHaveFlag(player, flag)
	if ( string.find(self.config:Get("default_flags"):Get(), flag) ) then
		return true;
	end;
end;

-- Called to check if a player does recognise another player.
function CloudScript:PlayerDoesRecognisePlayer(player, status, isAccurate, realValue)
	return realValue;
end;

-- Called when a player's name should be shown as unrecognised.
function CloudScript:PlayerCanShowUnrecognised(player, x, y, color, alpha, flashAlpha)
	return true;
end;

-- Called when the target player's name is needed.
function CloudScript:GetTargetPlayerName(player)
	return player:Name();
end;

-- Called when a player begins typing.
function CloudScript:StartChat(team)
	return true;
end;

-- Called when a player says something.
function CloudScript:OnPlayerChat(player, text, teamOnly, playerIsDead)
	if ( IsValid(player) ) then
		self.chatBox:Decode(player, player:Name(), text, {}, "none");
	else
		self.chatBox:Decode(nil, "Console", text, {}, "chat");
	end;
	
	return true;
end;

-- Called when chat text is received from the server
function CloudScript:ChatText(index, name, text, class)
	if (class == "none") then
		self.chatBox:Decode(_player.GetByID(index), name, text, {}, "none");
	end;
	
	return true;
end;

-- Called when the scoreboard should be created.
function CloudScript:CreateScoreboard() end;

-- Called when the scoreboard should be shown.
function CloudScript:ScoreboardShow()
	if ( self.Client:HasInitialized() ) then
		self.menu:Create();
		self.menu:SetOpen(true);
		self.menu.holdTime = UnPredictedCurTime() + 0.5;
	end;
end;

-- Called when the scoreboard should be hidden.
function CloudScript:ScoreboardHide()
	if (self.Client:HasInitialized() and self.menu.holdTime) then
		if (UnPredictedCurTime() >= self.menu.holdTime) then
			self.menu:SetOpen(false);
		end;
	end;
end;

-- Overriding Garry's "grab ear" animation.
function GM:GrabEarAnimation(player) end;

local entityMeta = FindMetaTable("Entity");
local weaponMeta = FindMetaTable("Weapon");
local playerMeta = FindMetaTable("Player");

entityMeta.CloudScriptFireBullets = entityMeta.FireBullets;
weaponMeta.OldGetPrintName = weaponMeta.GetPrintName;
playerMeta.SteamName = playerMeta.Name;

-- A function to make a player fire bullets.
function entityMeta:FireBullets(bulletInfo)
	if ( self:IsPlayer() ) then
		CloudScript.plugin:Call("PlayerAdjustBulletInfo", self, bulletInfo);
	end;
	
	return self:CloudScriptFireBullets(bulletInfo);
end;

-- A function to get a weapon's print name.
function weaponMeta:GetPrintName()
	local itemTable = CloudScript.item:GetWeapon(self);
	
	if (itemTable and itemTable.weaponCopiesItem) then
		return itemTable.name;
	else
		return self:OldGetPrintName();
	end;
end;

-- A function to get a player's name.
function playerMeta:Name()
	local name = self:GetSharedVar("name");
	
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
		local sprintSpeed = self:GetRunSpeed();
		local walkSpeed = self:GetWalkSpeed();
		local velocity = self:GetVelocity():Length();
		
		if (velocity >= math.max(sprintSpeed - 25, 25) and sprintSpeed > walkSpeed) then
			return true;
		end;
	end;
end;

-- A function to get whether a player is jogging.
function playerMeta:IsJogging(testSpeed)
	if ( !self:IsRunning() and (self:GetSharedVar("jogging") or testSpeed) ) then
		if ( self:Alive() and !self:IsRagdolled() and !self:InVehicle() and !self:Crouching() ) then
			local walkSpeed = self:GetWalkSpeed();
			local velocity = self:GetVelocity():Length();
			
			if ( velocity >= math.max(walkSpeed - 25, 25) ) then
				return true;
			end;
		end;
	end;
end;

-- A function to get a player's forced animation.
function playerMeta:GetForcedAnimation()
	local forcedAnimation = self:GetSharedVar("forcedAnim");
	
	if (forcedAnimation != 0) then
		return {
			animation = forcedAnimation,
		};
	end;
end;

-- A function to get whether a player is ragdolled.
function playerMeta:IsRagdolled(exception, entityless)
	return CloudScript.player:IsRagdolled(self, exception, entityless);
end;

-- A function to set a shared variable for a player.
function playerMeta:SetSharedVar(key, value)
	CloudScript.player:SetSharedVar(self, key, value);
end;

-- A function to get a player's shared variable.
function playerMeta:GetSharedVar(key)
	return CloudScript.player:GetSharedVar(self, key);
end;

-- A function to get whether a player has initialized.
function playerMeta:HasInitialized()
	if ( IsValid(self) ) then
		return self:GetSharedVar("initialized");
	end;
end;

-- A function to get a player's wages name.
function playerMeta:GetWagesName()
	return CloudScript.player:GetWagesName(self);
end;

-- A function to get a player's maximum armor.
function playerMeta:GetMaxArmor(armor)
	local maxArmor = self:GetSharedVar("maxArmor");
	
	if (maxArmor > 0) then
		return maxArmor;
	else
		return 100;
	end;
end;

-- A function to get a player's maximum health.
function playerMeta:GetMaxHealth(health)
	local maxHealth = self:GetSharedVar("maxHealth");
	
	if (maxHealth > 0) then
		return maxHealth;
	else
		return 100;
	end;
end;

-- A function to get a player's ragdoll state.
function playerMeta:GetRagdollState()
	return CloudScript.player:GetRagdollState(self);
end;

-- A function to get a player's ragdoll entity.
function playerMeta:GetRagdollEntity()
	return CloudScript.player:GetRagdollEntity(self);
end;

playerMeta.GetName = playerMeta.Name;
playerMeta.Nick = playerMeta.Name;

concommand.Add("cloud_lua", function(player, command, arguments)
	if ( player:IsSuperAdmin() ) then
		RunString( table.concat(arguments, " ") );
		
		return;
	end;
	
	print("You do not have access to this command, "..player:Name()..".");
end);