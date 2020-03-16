--[[
	© 2011-2012 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
	Conna Wiles (connawiles@gmail.com)
--]]

-- Called when a mouse button is released.
function TOOL:MouseButtonRelease(button)
	if (button == MOUSE_LEFT and self.m_decalData) then
		local brushObject = self.m_decalData.brushObject;
		local rectangle = self.m_decalData.rectangle;
		
		local editor = self:GetEditor();
			editor:AddDecal(self.m_image, rectangle, brushObject);
		self.m_decalData = nil;
	end;
end;

-- Called when a mouse button is pressed.
function TOOL:MouseButtonPress(button)
	local editor = self:GetEditor();
	local gridSize = editor:GetGridSize();
	
	if (button == MOUSE_LEFT) then
		local mousePosWorld = util.ScreenToWorld(util.GetMousePos());
		
		if (mousePosWorld) then
			local brushObject = editor:GetAtPos(mousePosWorld, "Brush");
			mousePosWorld = util.SnapToGrid(mousePosWorld, gridSize);
			
			self.m_decalData = {
				rectangle = util.Rectangle(
					mousePosWorld.x,
					mousePosWorld.y,
					self.m_iDecalSize,
					self.m_iDecalSize
				),
				brushObject = brushObject
			};
		end;
	end;
end;

-- Called when the game should be updated.
function TOOL:UpdateGame(deltaTime)
	if (self.m_decalData) then
		local editor = self:GetEditor();
		local rectangle = self.m_decalData.rectangle;
		local gridSize = editor:GetGridSize();
		local mousePos = util.ScreenToWorld(util.GetMousePos());
		
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

-- Called just before the lighting is drawn.
function TOOL:PreDrawLighting()
	if (self.m_decalData) then
		local rectangle = self.m_decalData.rectangle;
		local color = Color(1, 1, 1, 1);
		
		self.m_image:Draw(
			rectangle.x,
			rectangle.y,
			rectangle.w,
			rectangle.h,
			color
		);
	end;
end;

-- A function to draw the tool's decal.
function TOOL:DrawDecal(bBrushOnly)
	if (not self.m_decalData or (bBrushOnly
	and not self.m_decalData.brushObject)) then
		return;
	end;
	
	local brushObject = self.m_decalData.brushObject;
	local rectangle = self.m_decalData.rectangle;
	local graphics = display.Graphics();
	local brushes = self:GetEditor():GetBrushes();
	local color = Color(1, 1, 1, 1);
	
	if (brushObject) then
		graphics:PushClipRect(brushObject:GetClipRect());
			render.DrawImage(
				self.m_image,
				rectangle.x,
				rectangle.y,
				rectangle.w,
				rectangle.h,
				color
			);
		graphics:PopClipRect();
	else
		render.DrawImage(
			self.m_image,
			rectangle.x,
			rectangle.y,
			rectangle.w,
			rectangle.h,
			color
		);
	end;
end;

-- Called just before the lighting is drawn.
function TOOL:PreDrawLighting()
	self:DrawDecal();
end;

-- Called when the objects should be drawn.
function TOOL:DrawObjects()
	self:DrawDecal(true);
end;

-- A function to populate the tool's items.
function TOOL:PopulateItems(searchPath, files)
	self.m_textureList:Clear();
	
	for k, v in ipairs(files) do
		if (util.IsImage(v)) then
			local imageButton = controls.Create("ImageButton");
				imageButton:SetCallback(function()
					self.m_image = util.GetImage(imageButton:GetMaterial());
				end);
				imageButton:SetBorderColor(Color(1, 1, 1, 1));
				imageButton:SetMaterial(searchPath..v);
				imageButton:SetToolTip(searchPath..v);
				imageButton:SetSize(32, 32);
			self.m_textureList:AddItem(imageButton);
		end;
	end;
	
	self.m_folderNav:SetHeight(
		math.min(self.m_folderNav:GetCanvas():GetH(), 125)
	);
	
	self.m_textureList:SetPos(8,
		self.m_folderNav:GetY(true) + self.m_folderNav:GetH() + 8
	);
	
	self.m_frame:SetHeight(
		self.m_textureList:GetY(true) + self.m_textureList:GetH() + 8
	);
end;

-- A function to create the tool controls.
function TOOL:CreateControls()
	local editor = self:GetEditor();
	
	self.m_frame = controls.Create("Frame");
	self.m_frame:SetDraggable(true);
	self.m_frame:SetTitle("Decal");
	self.m_frame:SetSize(200, 400);
	
	local decalSizeLabel = controls.Create("Label", self.m_frame);
	decalSizeLabel:SetText("Decal Size:");
	decalSizeLabel:SetPos(8, 32);
	
	local decalSizeBox = controls.Create("OptionBox", self.m_frame);
	decalSizeBox:SetPos(
		decalSizeLabel:GetX(true) + decalSizeLabel:GetW() + 8,
		decalSizeLabel:GetY(true) - (decalSizeLabel:GetH() * 0.3)
	);
	decalSizeBox:SetWidth(self.m_frame:GetW() - decalSizeBox:GetX(true) - 8);
	decalSizeBox:SetCallback(function(option)
		self.m_iDecalSize = tonumber(option);
	end);
	
	for k, v in ipairs({4, 8, 16, 32, 64, 128, 256, 512}) do
		decalSizeBox:AddOption(v);
	end;
	
	self.m_folderNav = controls.Create("FolderNav", self.m_frame);
	self.m_folderNav:SetCallback(function(searchPath, files)
		self:PopulateItems(searchPath, files);
	end);
	self.m_folderNav:SetFolder("materials/decals");
	self.m_folderNav:SetSize(self.m_frame:GetW() - 16, 125);
	self.m_folderNav:SetPos(8, decalSizeBox:GetY(true) + decalSizeBox:GetH() + 8);
	
	self.m_textureList = controls.Create("ItemList", self.m_frame);
	self.m_textureList:SetPos(8,
		self.m_folderNav:GetY(true) + self.m_folderNav:GetH() + 8
	);
	self.m_textureList:SetSize(self.m_frame:GetW() - 16, 125);
	self.m_textureList:SetPadding(4);
	self.m_textureList:SetSpacing(4);
	self.m_textureList:SetHorizontal(true);
	
	self.m_frame:SetHeight(
		self.m_textureList:GetY(true) + self.m_textureList:GetH() + 8
	);
	
	self.m_folderNav:Populate();
	
	decalSizeBox:SelectOption(self.m_iDecalSize);
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
		self.m_iDecalSize = 64;
		self.m_image = util.GetImage("editor/decal");
	end;
	
	self:CreateControls();
end;