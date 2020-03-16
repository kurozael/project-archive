--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
--]]

-- Called when a mouse button is released.
function TOOL:MouseButtonRelease(button)
	local editor = self:GetEditor();
	local gridSize = editor:GetGridSize();
	
	if (button == MOUSE_LEFT) then
		local mousePosWorld = util.ScreenToWorld( util.GetMousePos() );
		
		if (mousePosWorld) then
			mousePosWorld = util.SnapToGrid(mousePosWorld, gridSize);
			
			if (not self.m_wireData) then
				local object = editor:GetAtPos(mousePosWorld);
				
				if (object and object:GetClass() == "Chip") then
					local chipObject = object:GetData("Chip");
					local outputs = chipObject:GetOutputs();
					
					if ( chipObject:HasOutputs() ) then
						local menu = controls.Create("SimpleMenu");
						local subMenu = menu:AddSubMenu("Output");
						
						for k, v in ipairs(outputs) do
							subMenu:AddOption(v, function()
								self.m_wireData = {
									output = {
										chip = chipObject,
										key = v
									},
									points = {
										mousePosWorld
									},
									color = self.m_wireColor
								};
								
								g_Sounds:PlaySound("click", 1);
							end);
						end;
						
						menu:Open();
					end;
				end;
			else
				local object = editor:GetAtPos(mousePosWorld);
				
				if (object and object:GetClass() == "Chip") then
					local chipObject = object:GetData("Chip");
					local inputs = chipObject:GetInputs();
					
					if (self.m_wireData.output.chip == chipObject) then
						return;
					end;
					
					if ( chipObject:HasInputs() ) then
						local menu = controls.Create("SimpleMenu");
						local subMenu = menu:AddSubMenu("Input");
						
						self.m_inputMenu = {
							mousePos = mousePosWorld,
							menu = menu
						};
						
						for k, v in ipairs(inputs) do
							subMenu:AddOption(v, function()
								self.m_wireData.input = {
									chip = chipObject,
									key = v
								};
								
								table.insert(self.m_wireData.points, mousePosWorld);
									editor:AddWire(self.m_wireData);
								self.m_wireData = nil;
								
								g_Sounds:PlaySound("confirm", 1);
							end);
						end;
						
						menu:Open();
						
						return;
					end;
				end;
				
				table.insert(self.m_wireData.points, mousePosWorld);
				g_Sounds:PlaySound("click", 1);
			end;
		end;
	end;
end;

-- Called when a mouse button is pressed.
function TOOL:MouseButtonPress(button) end;

-- Called when the game should be updated.
function TOOL:UpdateGame(deltaTime) end;

-- Called when a key is released.
function TOOL:KeyRelease(key)
	if (key == KEY_R and self.m_wireData) then
		table.remove(self.m_wireData.points, #self.m_wireData.points);
		
		if (#self.m_wireData.points == 0) then
			g_Sounds:PlaySound("confirm", 1);
			self.m_wireData = nil;
		else
			g_Sounds:PlaySound("click", 1);
		end;
	end;
end;

-- A function to draw the tool's wire.
function TOOL:DrawWire()
	if (not self.m_wireData) then
		return;
	end;
	
	local pointsList = self.m_wireData.points;
	local editor = self:GetEditor();
	local color = self.m_wireData.color;
	
	for k, v in ipairs(pointsList) do
		local nextPoint = pointsList[k + 1];
		
		if (nextPoint) then
			g_Render:DrawLine(v.x, v.y, nextPoint.x, nextPoint.y, color);
		end;
	end;
	
	local lastWire = pointsList[#pointsList];
	local gridSize = editor:GetGridSize();
	
	if (lastWire) then
		local mousePosWorld = util.ScreenToWorld( util.GetMousePos() );
		
		if (  self.m_inputMenu and self.m_inputMenu.menu:IsValid() ) then
			mousePosWorld = self.m_inputMenu.mousePos;
		end;
		
		if (mousePosWorld) then
			mousePosWorld = util.SnapToGrid(mousePosWorld, gridSize);
			g_Render:DrawLine(lastWire.x, lastWire.y, mousePosWorld.x, mousePosWorld.y, color);
			
			draw.ShadowedText( "Default", mousePosWorld.x, mousePosWorld.y - 16,
				"Press 'r' to go back.", Color(1, 1, 1, 1), Color(0, 0, 0, 0.8), true, true, true);
		end;
	end;
end;

-- Called just before the lighting is drawn.
function TOOL:PreDrawLighting()
	self:DrawWire();
end;

-- A function to create the tool controls.
function TOOL:CreateControls()
	local editor = self:GetEditor();
	local colors = {
		["Red"] = Color(1, 0, 0, 1),
		["Green"] = Color(0, 1, 0, 1),
		["Blue"] = Color(0, 0, 1, 1)
	};
	
	self.m_frame = controls.Create("Frame");
	self.m_frame:SetDraggable(true);
	self.m_frame:SetTitle("Wire");
	self.m_frame:SetSize(200, 400);
	
	local wireColorBox = controls.Create("OptionBox", self.m_frame);
	wireColorBox:SetPos(8, 32);
	wireColorBox:SetWidth(self.m_frame:GetW() - wireColorBox:GetX(true) - 8);
	wireColorBox:SetCallback(function(option)
		self.m_wireColor = colors[option];
	end);
	
	for k, v in pairs(colors) do
		wireColorBox:AddOption(k);
	end;
	
	wireColorBox:SelectOption("Red");
	
	self.m_frame:SetHeight(
		wireColorBox:GetY(true) + wireColorBox:GetH() + 8
	);
	
	editor:AlignFrame(self.m_frame);
end;

-- Called when the tool has become inactive.
function TOOL:OnInactive()
	self.m_frame:Remove();
end;

-- Called when the tool has become active.
function TOOL:OnActive()
	if (not self.m_bInitialized) then
		self.m_bInitialized = true;
		self.m_wireColor = Color(1, 0, 0, 1);
	end;
	
	self:CreateControls();
end;