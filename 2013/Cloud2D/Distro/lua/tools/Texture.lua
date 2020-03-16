--[[
	© 2011-2012 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
	Conna Wiles (connawiles@gmail.com)
--]]

-- Called when a mouse button is released.
function TOOL:MouseButtonRelease(button)
	if (button == MOUSE_LEFT and self.m_textureData) then
		local editor = self:GetEditor();
		local rectangle = self.m_textureData.rectangle;
		local tileSize = self.m_iTileSize;
		
		if (rectangle.w > 1 and rectangle.h > 1) then
			editor:AddTexture(
				self.m_image,
				rectangle,
				tileSize
			);
		end;
		
		self.m_textureData = nil;
	end;
end;

-- Called when a mouse button is pressed.
function TOOL:MouseButtonPress(button)
	local editor = self:GetEditor();
	local gridSize = editor:GetGridSize();
	
	if (button == MOUSE_LEFT) then
		local mousePosWorld = util.ScreenToWorld(util.GetMousePos());
		
		if (mousePosWorld) then
			mousePosWorld = util.SnapToGrid(mousePosWorld, gridSize);
			
			self.m_textureData = {
				rectangle = util.Rectangle(
					mousePosWorld.x, mousePosWorld.y, 1, 1
				),
				origin = mousePosWorld
			}
		end;
	end;
end;

-- Called when the game should be updated.
function TOOL:UpdateGame(deltaTime)
	local editor = self:GetEditor();
	local gridSize = editor:GetGridSize();
	
	if (self.m_textureData) then
		local mousePosWorld = util.ScreenToWorld(util.GetMousePos());
		local rectangle = self.m_textureData.rectangle;
		local origin = self.m_textureData.origin;
		
		if (mousePosWorld) then
			mousePosWorld = util.SnapToGrid(mousePosWorld, gridSize);
			
			rectangle.w = util.SnapToGrid(math.abs(mousePosWorld.x - origin.x), gridSize);
			rectangle.h = util.SnapToGrid(math.abs(mousePosWorld.y - origin.y), gridSize);
			rectangle.x = math.min(mousePosWorld.x, origin.x);
			rectangle.y = math.min(mousePosWorld.y, origin.y);
		end;
	end;
end;

-- Called just before the lighting is drawn.
function TOOL:PreDrawLighting()
	if (self.m_textureData) then
		local rectangle = self.m_textureData.rectangle;
		local tileSize = self.m_iTileSize;
		local color = Color(1, 1, 1, 1);
		
		draw.TiledImage(
			self.m_image,
			rectangle.x,
			rectangle.y,
			rectangle.w,
			rectangle.h,
			color,
			tileSize
		);
	end;
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
	self.m_frame:SetTitle("Texture");
	self.m_frame:SetSize(200, 400);
	
	local tileSizeLabel = controls.Create("Label", self.m_frame);
	tileSizeLabel:SetText("Tile Size:");
	tileSizeLabel:SetPos(8, 32);
	
	local tileSizeBox = controls.Create("OptionBox", self.m_frame);
	tileSizeBox:SetPos(
		tileSizeLabel:GetX(true) + tileSizeLabel:GetW() + 8,
		tileSizeLabel:GetY(true) - (tileSizeLabel:GetH() * 0.3)
	);
	tileSizeBox:SetWidth(self.m_frame:GetW() - tileSizeBox:GetX(true) - 8);
	tileSizeBox:SetCallback(function(option)
		self.m_iTileSize = tonumber(option);
	end);
	
	for k, v in ipairs({4, 8, 16, 32, 64, 128, 256, 512}) do
		tileSizeBox:AddOption(v);
	end;
	
	self.m_folderNav = controls.Create("FolderNav", self.m_frame);
	self.m_folderNav:SetCallback(function(searchPath, files)
		self:PopulateItems(searchPath, files);
	end);
	self.m_folderNav:SetFolder("materials/textures");
	self.m_folderNav:SetSize(self.m_frame:GetW() - 16, 125);
	self.m_folderNav:SetPos(8, tileSizeBox:GetY(true) + tileSizeBox:GetH() + 8);
	
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
	
	tileSizeBox:SelectOption(self.m_iTileSize);
	editor:AlignFrame(self.m_frame);
end;

-- Called when the tool has become inactive.
function TOOL:OnInactive()
	self.m_textureData = nil;
	self.m_frame:Remove();
end;

-- Called when the tool has become active.
function TOOL:OnActive()
	if (not self.m_bInitialized) then
		self.m_bInitialized = true;
		self.m_iTileSize = 32;
		self.m_image = util.GetImage("editor/texture");
	end;
	
	self:CreateControls();
end;