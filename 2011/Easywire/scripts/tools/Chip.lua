--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
--]]

-- Called when a mouse button is released.
function TOOL:MouseButtonRelease(button)
	if (button == MOUSE_LEFT and self.m_chipData) then
		local rectangle = self.m_chipData.rectangle;
		local editor = self:GetEditor();
		
		editor:AddChip(self.m_image, rectangle, self.m_sChipType.m_sClassName);
			self.m_chipData = nil;
		g_Sounds:PlaySound("confirm", 1);
	end;
end;

-- Called when a mouse button is pressed.
function TOOL:MouseButtonPress(button)
	local editor = self:GetEditor();
	local gridSize = editor:GetGridSize();
	
	if (button == MOUSE_LEFT) then
		local mousePosWorld = util.ScreenToWorld( util.GetMousePos() );
		
		if (mousePosWorld) then
			mousePosWorld = util.SnapToGrid(mousePosWorld, gridSize);
			
			self.m_chipData = {
				rectangle = util.Rectangle(
					mousePosWorld.x,
					mousePosWorld.y,
					self.m_iChipSize,
					self.m_iChipSize
				)
			};
			
			g_Sounds:PlaySound("click", 1);
		end;
	end;
end;

-- Called when the game should be updated.
function TOOL:UpdateGame(deltaTime)
	if (self.m_chipData) then
		local editor = self:GetEditor();
		local rectangle = self.m_chipData.rectangle;
		local gridSize = editor:GetGridSize();
		local mousePos = util.ScreenToWorld( util.GetMousePos() );
		
		if (mousePos) then
			rectangle.x = util.SnapToGrid(
				mousePos.x - (rectangle.w / 2), gridSize
			);
			
			rectangle.y = util.SnapToGrid(
				mousePos.y - (rectangle.h / 2), gridSize
			);
		end;
	end;
end;

-- A function to draw the tool's chip.
function TOOL:DrawChip()
	if (not self.m_chipData) then
		return;
	end;
	
	local rectangle = self.m_chipData.rectangle;
	local color = Color(1, 1, 1, 1);
	
	g_Render:DrawImage(
		self.m_image,
		rectangle.x,
		rectangle.y,
		rectangle.w,
		rectangle.h,
		color
	);
end;

-- Called when the objects should be drawn.
function TOOL:DrawObjects()
	self:DrawChip();
end;

-- A function to create the tool controls.
function TOOL:CreateControls()
	local editor = self:GetEditor();
	
	self.m_frame = controls.Create("Frame");
	self.m_frame:SetDraggable(true);
	self.m_frame:SetTitle("Chip");
	self.m_frame:SetSize(200, 400);
	
	local chipTypeBox = controls.Create("OptionBox", self.m_frame);
	chipTypeBox:SetPos(8, 32);
	chipTypeBox:SetWidth(self.m_frame:GetW() - chipTypeBox:GetX(true) - 8);
	chipTypeBox:SetCallback(function(option)
		self.m_sChipType = chips.GetByName(option);
		self.m_image = self.m_sChipType.m_image;
	end);
	
	for k, v in pairs( chips.GetClasses() ) do
		if (v.m_sClassName ~= "BaseChip") then
			chipTypeBox:AddOption(v.m_sName);
		end;
	end;
	
	chipTypeBox:SelectOption(
		self.m_sChipType.m_sName
	);
	
	self.m_frame:SetHeight(
		chipTypeBox:GetY(true) + chipTypeBox:GetH() + 8
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
		self.m_sChipType = chips.GetTable("AndGate");
		self.m_iChipSize = 32;
		self.m_image = self.m_sChipType.m_image;
	end;
	
	self:CreateControls();
end;