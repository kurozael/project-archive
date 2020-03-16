--[[
	© 2011-2012 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
	Conna Wiles (connawiles@gmail.com)
--]]

CURSOR_CROSSHAIR = "cursors/crosshair";
CURSOR_FOLLOW = "cursors/follow";
CURSOR_PICKER = "cursors/picker";

-- Called when the state is constructed.
function STATE:__init()
	self.m_bShowBBoxes = false;
	self.m_debugLines = {};
	self.m_tileImage = util.GetImage("textures/liquid/001a");
end;

-- Called when a key is released.
function STATE:KeyRelease(key)
	if (key == KEY_F1) then
		self.m_bShowBBoxes = not self.m_bShowBBoxes;
	elseif (key == KEY_F2) then
		local mousePosWorld = util.ScreenToWorld(util.GetMousePos(), true);
		local playerEntity = entities.GetPlayer();
		local rayData = util.RayCast(playerEntity:GetCenter(), mousePosWorld, {playerEntity});
		
		self.m_debugLines[#self.m_debugLines + 1] = {
			rayData.startPos,
			rayData.hitPos
		};
	end;
end;

-- Called when the game should be updated.
function STATE:UpdateGame(deltaTime)
	if (not entities.GetPlayer()) then return; end;
	
	local mousePosWorld = util.ScreenToWorld(util.GetMousePos());
	
	camera.SetWorldPos(entities.GetPlayer():GetCenter() - Vec2(
		camera.GetW() / 2, camera.GetH() / 2
	));
	camera.SnapToBounds();
	
	if (inputs.Mouse():IsKeyDown(MOUSE_LEFT)) then
		local mousePosWorld = util.ScreenToWorld(util.GetMousePos(), true);
		local playerEntity = entities.GetPlayer();
		local playerCenter = playerEntity:GetCenter();
		local activeWeapon = playerEntity:GetActiveWeapon();
		
		if (playerCenter:Distance(mousePosWorld) > 80 and playerEntity:IsAlive()
		and (activeWeapon and activeWeapon:IsPrimaryAutomatic())) then
			playerEntity:FireWeapon();
		end;
	end;
	
	if (self.m_targetPos and mousePosWorld) then
		self.m_targetPos = mousePosWorld;
	end;
end;

-- Called when a mouse button is pressed.
function STATE:MouseButtonPress(button)
	if (button == MOUSE_RIGHT) then
		local mousePosWorld = util.ScreenToWorld(util.GetMousePos());
		
		if (not self.m_targetPos and mousePosWorld) then
			self.m_targetPos = mousePosWorld;
			cursor.SetDefault(CURSOR_FOLLOW);
			cursor.Set(CURSOR_FOLLOW);
		end;
	end;
end;

-- Called when a mouse button is released.
function STATE:MouseButtonRelease(button)
	if (button == MOUSE_LEFT) then
		local mousePosWorld = util.ScreenToWorld(util.GetMousePos(), true);
		local players = entities.GetByClassName("Player");

		for k, v in pairs(players) do
			if (v:HitTest(mousePosWorld) and v:IsAlive()) then
				sounds.PlaySound("confirm", 1);
				v:MakePlayer();
				
				return;
			end;
		end;
		
		local playerEntity = entities.GetPlayer();
		if (not playerEntity) then return; end;
		
		local playerCenter = playerEntity:GetCenter();
		
		if (playerCenter:Distance(mousePosWorld) > 80 and playerEntity:IsAlive()) then
			playerEntity:FireWeapon();
		end;
	elseif (button == MOUSE_RIGHT) then
		local playerEntity = entities.GetPlayer();
		if (not playerEntity) then return; end;
		
		if (self.m_targetPos) then
			playerEntity:SetTargetPos(self.m_targetPos);
			sounds.PlaySound("click", 1);
		end;
		
		cursor.SetDefault(CURSOR_CROSSHAIR);
		cursor.Set(CURSOR_CROSSHAIR);
		
		self.m_targetPos = nil;
	end;
end;

-- Called when the display should be drawn.
function STATE:DrawDisplay()
	local fx, fy, fw, fh = draw.ShadowedText("VerdanaSmall", 8, 8, "FPS: "..time.GetFPS(), Color(1, 0, 0, 1), Color(0, 0, 0, 0.8), true);
	fx, fy, fw, fh = draw.ShadowedText("VerdanaSmall", fx + fw + 8, fy, "F1: Bounding Boxes", Color(0, 1, 0, 1), Color(0, 0, 0, 0.8), true);
	fx, fy, fw, fh = draw.ShadowedText("VerdanaSmall", fx + fw + 8, fy, "F2: Project Traceline", Color(0, 1, 1, 1), Color(0, 0, 0, 0.8), true);
	fx, fy, fw, fh = draw.ShadowedText("VerdanaSmall", fx + fw + 8, fy, "Entities: "..entities.GetCount(), Color(1, 1, 0, 1), Color(0, 0, 0, 0.8), true);
	fx, fy, fw, fh = draw.ShadowedText("VerdanaSmall", fx + fw + 8, fy, "X: "..util.GetMousePos().x.." Y: "..util.GetMousePos().y, Color(1, 1, 1, 1), Color(0, 0, 0, 0.8), true);
end;

-- Called just after the lighting is drawn.
function STATE:PostDrawLighting()
	if (not entities.GetPlayer()) then return; end;
	
	camera.Begin();
	
	local playerEntity = entities.GetPlayer();
	local playerCenter = playerEntity:GetCenter();
	local targetPos = self.m_targetPos;
	
	if (targetPos) then
		render.DrawLine(playerCenter.x, playerCenter.y, targetPos.x, targetPos.y, Color(0, 1, 0, 1));
		render.DrawLine(targetPos.x - 8, targetPos.y - 8, targetPos.x + 8, targetPos.y + 8, Color(0, 1, 0, 1));
		render.DrawLine(targetPos.x - 8, targetPos.y + 8, targetPos.x + 8, targetPos.y - 8, Color(0, 1, 0, 1));
	end;
	
	local mousePosWorld = util.ScreenToWorld(util.GetMousePos(), true);
	local players = entities.GetByClassName("Player");
	
	for k, v in ipairs(players) do
		if (v:HitTest(mousePosWorld)) then
			if (not v.m_bCursorChanged) then
				cursor.Set(CURSOR_PICKER);
				v.m_bCursorChanged = true;
			end;
		elseif (v.m_bCursorChanged) then
			cursor.MakeDefault();
			v.m_bCursorChanged = nil;
		end;
		
		local boxPosition = v:GetPos() - Vec2(8, 8);
		local boxWidth = 32;
		local boxHeight = 4;
		
		render.DrawFill(boxPosition.x, boxPosition.y, (boxWidth / v:GetMaxHealth()) * v:GetHealth(), boxHeight, Color(1, 0, 0, 1));
		render.DrawBox(boxPosition.x, boxPosition.y, boxWidth, boxHeight, Color(0, 0, 0, 1));
	end;
	
	for k, v in ipairs(self.m_debugLines) do
		render.DrawLine(v[1].x, v[1].y, v[2].x, v[2].y, v[3] or Color(1, 1, 0, 1));
	end;
	
	if (self.m_bShowBBoxes) then
		for k, v in ipairs(entities.GetAll()) do
			v:DrawBBox(true);
		end;
	end;
	
	camera.Finish();
end;

-- Called when the objects should be drawn.
function STATE:DrawObjects()
	if (not entities.GetPlayer()) then return; end;
	
	camera.Begin();
	
	for k, v in ipairs(entities.GetAll()) do
		if (v:GetTeam() == TEAM_MONSTERS) then
			local boxPosition = v:GetPos() - Vec2(8, 8);
			local boxWidth = 32;
			local boxHeight = 4;
			
			render.DrawFill(boxPosition.x, boxPosition.y, (boxWidth / v:GetMaxHealth()) * v:GetHealth(), boxHeight, Color(0, 1, 0, 1));
			render.DrawBox(boxPosition.x, boxPosition.y, boxWidth, boxHeight, Color(0, 0, 0, 1));
			
			if (v.m_targetQueue) then
				for k2, v2 in ipairs(v.m_targetQueue) do
					render.DrawBox(v2.x, v2.y, 2, 2, Color(1, 0, 0, 1));
				end;
			end;
		end;
	end;
	
	camera.Finish();
end;

-- Called when the state is unloaded.
function STATE:OnUnload()
	cursor.SetDefault(CURSOR_ARROW);
	cursor.Set(CURSOR_ARROW);
end;

-- Called when the state is loaded.
function STATE:OnLoad()	
	cursor.Add("CURSOR_CROSSHAIR", "cursors/crosshair");
	cursor.Add("CURSOR_FOLLOW", "cursors/follow");
	cursor.Add("CURSOR_PICKER", "cursors/picker");
	
	cursor.SetDefault(CURSOR_CROSSHAIR);
	cursor.Set(CURSOR_CROSSHAIR);
	
	camera.SetScreenBounds(0, 0, display.GetW(), display.GetH());
	camera.SetWorldBounds(0, 0, WORLD_SIZE, WORLD_SIZE);
end;