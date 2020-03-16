--[[
	© 2011-2012 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
	Conna Wiles (connawiles@gmail.com)
--]]

EDITOR_OBJECT = {};
EDITOR_OBJECT.__index = EDITOR_OBJECT;

-- A function to get a new editor object.
function EditorObject(className, parentObject)
	local object = {};
		setmetatable(object, EDITOR_OBJECT);
		object:__init(className, parentObject);
	return object;
end;

-- Called when the object is constructed.
function EDITOR_OBJECT:__init(className, parentObject)
	self.m_parentObject = parentObject;
	self.m_sClassName = className;
	self.m_rectangle = util.Rectangle(0, 0, 0, 0);
	self.m_children = {};
	self.m_image = util.GetImage("missing");
	self.m_data = {};
end;

-- A function to create a duplicate of the object.
function EDITOR_OBJECT:Duplicate(parentObject)
	if (not parentObject) then
		parentObject = self.m_parentObject;
	end;
	
	local object = EditorObject(self.m_sClassName, parentObject);
	local sourceTable = self.m_sourceTable;
	
	if (parentObject) then
		sourceTable = parentObject:GetChildren();
	end;
	
	object:SetRect(self.m_rectangle);
	object:SetImage(self.m_image);
	
	for k, v in ipairs(self.m_children) do
		v:Duplicate(object);
	end;
	
	for k, v in pairs(self.m_data) do
		object:SetData(k, v);
	end;
	
	object:Add(sourceTable);
	
	return object;
end;

-- A function to get the object's world rectangle.
function EDITOR_OBJECT:GetWorldRect()
	if (self.m_parentObject) then
		local parentRect = self.m_parentObject:GetWorldRect();
		
		return util.Rectangle(
			parentRect.x + self.m_rectangle.x,
			parentRect.y + self.m_rectangle.y,
			self.m_rectangle.w,
			self.m_rectangle.h
		);
	else
		return self.m_rectangle;
	end;
end;

-- A function to get the object's parent object.
function EDITOR_OBJECT:GetParentObject()
	return self.m_parentObject;
end;

-- A function to set the object's parent object.
function EDITOR_OBJECT:SetParentObject(parentObject)
	self.m_parentObject = parentObject;
end;

-- A function to get the object's source table.
function EDITOR_OBJECT:GetSourceTable()
	return self.m_sourceTable;
end;

-- A function to get the object's clip rectangle.
function EDITOR_OBJECT:GetClipRect()
	local rectangle = self:GetWorldRect();
	
	return Rect(
		rectangle.x, rectangle.y,
		rectangle.x + rectangle.w,
		rectangle.y + rectangle.h
	);
end;

-- A function to get the object's children.
function EDITOR_OBJECT:GetChildren()
	return self.m_children;
end;

-- A function to remove the object from the source table.
function EDITOR_OBJECT:Remove()
	table.RemoveValue(self.m_sourceTable, self);
end;

-- A function to add the object to the source table.
function EDITOR_OBJECT:Add(sourceTable, index)
	if (not sourceTable and self.m_parentObject) then
		sourceTable = self.m_parentObject:GetChildren();
	end;
	
	if (sourceTable) then
		self.m_sourceTable = sourceTable;
		
		if (index) then
			table.insert(self.m_sourceTable, index, self);
		else
			table.insert(self.m_sourceTable, self);
		end;
	end;
end;

-- A function to send the object to the front.
function EDITOR_OBJECT:SendToFront()
	self:Remove(); self:Add(self.m_sourceTable);
end;

-- A function to send the object to the back.
function EDITOR_OBJECT:SendToBack()
	self:Remove(); self:Add(self.m_sourceTable, 1);
end;

-- A function to get the object's local rectangle.
function EDITOR_OBJECT:GetLocalRect()
	return self.m_rectangle;
end;

-- A function to set the object's rectangle.
function EDITOR_OBJECT:SetRect(rectangle)
	self.m_rectangle.x = rectangle.x;
	self.m_rectangle.y = rectangle.y;
	self.m_rectangle.w = rectangle.w;
	self.m_rectangle.h = rectangle.h;
end;

-- A function to set the object's size.
function EDITOR_OBJECT:SetSize(width, height)
	self.m_rectangle.w = width;
	self.m_rectangle.h = height;
end;

-- A function to get the object's size.
function EDITOR_OBJECT:GetSize()
	return self.m_rectangle.w, self.m_rectangle.h;
end;

-- A function to get the class of the object.
function EDITOR_OBJECT:GetClass()
	return self.m_sClassName;
end;

-- A function to set the object's image.
function EDITOR_OBJECT:SetImage(image)
	self.m_image = image;
end;

-- A function to get the object's image.
function EDITOR_OBJECT:GetImage()
	return self.m_image;
end;

-- A function to set the object's position.
function EDITOR_OBJECT:SetPos(x, y)
	self.m_rectangle.x = x;
	self.m_rectangle.y = y;
end;

-- A function to get the object's position.
function EDITOR_OBJECT:GetPos()
	return self.m_rectangle.x, self.m_rectangle.y;
end;

-- A function to set data for the object.
function EDITOR_OBJECT:SetData(key, value)
	self.m_data[key] = value;
end;

-- A function to get data for the object.
function EDITOR_OBJECT:GetData(key)
	return (key and self.m_data[key] or self.m_data);
end;

-- Called when a mouse button is released.
function STATE:MouseButtonRelease(button)
	if (button == MOUSE_RIGHT) then
		self.m_bPanning = false;
		self.m_panPos = nil;
	end;
end;

-- Called when a mouse button is pressed.
function STATE:MouseButtonPress(button)
	if (button == MOUSE_RIGHT) then
		self.m_bPanning = true;
		self.m_panPos = util.GetMousePos();
	end;
end;

-- Called when the game should be updated.
function STATE:UpdateGame(deltaTime)
	local position = camera.GetWorldPos();
	local velocity = Vec2(0, 0);
	local speed = 256 * deltaTime;
	
	if (inputs.IsKeyDown(KEY_UP)) then
		velocity.y = -speed;
	elseif (inputs.IsKeyDown(KEY_DOWN)) then
		velocity.y = speed;
	end;
	
	if (inputs.IsKeyDown(KEY_LEFT)
	and not controls:GetFocused()) then
		velocity.x = -speed;
	elseif (inputs.IsKeyDown(KEY_RIGHT)
	and not controls:GetFocused()) then
		velocity.x = speed;
	end;
	
	if (self.m_bPanning) then
		velocity = velocity + ((util.GetMousePos() - self.m_panPos) * (deltaTime * 4));
	end;
	
	camera.SetWorldPos(position + velocity);
	camera.SnapToBounds();
end;

-- Called to get whether the lighting should be drawn.
function STATE:ShouldDrawLighting()
	return self.m_bDrawLighting;
end;

-- Called just before the lighting is drawn.
function STATE:PreDrawLighting()
	for k, v in ipairs(self.m_levelData.textures) do
		local rectangle = v:GetWorldRect();
		local tileSize = v:GetData("TileSize");
		local image = v:GetImage();
		local color = v:GetData("Color");
		
		draw.TiledImage(
			image, rectangle.x, rectangle.y,
			rectangle.w, rectangle.h, color,
			tileSize
		);
	end;
	
	for k, v in ipairs(self.m_levelData.decals) do
		local rectangle = v:GetWorldRect();
		local image = v:GetImage();
		local color = v:GetData("Color");
		
		render.DrawImage(
			image, rectangle.x, rectangle.y,
			rectangle.w, rectangle.h, color
		);
	end;
	
	for k, v in ipairs(self.m_levelData.entities) do
		local entity = v:GetObject();
		local rectangle = v:GetWorldRect();
		local image = v:GetImage();
		local color = Color(1, 1, 1, 1);
		
		render.DrawImage(
			image, rectangle.x, rectangle.y,
			rectangle.w, rectangle.h, color
		);
	end;
end;

-- Called just after the lighting is drawn.
function STATE:PostDrawLighting()
	if (self.m_bShowGrid) then
		self:DrawGrid();
	end;
end;

-- Called when the display should be drawn.
function STATE:DrawDisplay()
	local fx, fy, fw, fh = draw.ShadowedText("VerdanaSmall", 8, 32, "FPS: "..time.GetFPS(), Color(1, 0, 0, 1), Color(0, 0, 0, 0.8), true);
	local activeTool = tools.GetActive();
	
	if (activeTool) then
		fx, fy, fw, fh = draw.ShadowedText("VerdanaSmall", fx + fw + 8, fy, "Tool: "..activeTool:GetClass(), Color(0, 1, 0, 1), Color(0, 0, 0, 0.8), true);
	end;
end;

-- Called when the objects should be drawn.
function STATE:DrawObjects()
	local graphics = display.Graphics();
	
	for k, v in ipairs(self.m_levelData.brushes) do
		local brushColor = v:GetData("Color");
		local brushImage = v:GetImage();
		local brushRect = v:GetWorldRect();
		local tileSize = v:GetData("TileSize");
		
		draw.TiledImage(
			brushImage, brushRect.x,
			brushRect.y, brushRect.w,
			brushRect.h, brushColor,
			tileSize
		);
		
		graphics:PushClipRect(v:GetClipRect());
			for k2, v2 in ipairs(v:GetChildren()) do
				local decalColor = v:GetData("Color");
				local decalImage = v2:GetImage();
				local decalRect = v2:GetWorldRect();
				
				render.DrawImage(
					decalImage, decalRect.x,
					decalRect.y, decalRect.w,
					decalRect.h, decalColor
				);
			end;
		graphics:PopClipRect();
	end;
end;
	
-- A function to add a texture to the state.
function STATE:AddTexture(image, rectangle, tileSize)
	local textureObject = EditorObject("Texture");
		textureObject:SetData("TileSize", tileSize);
		textureObject:SetData("Color", Color(1, 1, 1, 1));
		textureObject:SetImage(image);
		textureObject:SetRect(rectangle);
	textureObject:Add(self.m_levelData.textures);
end;

-- A function to add an entity to the state.
function STATE:AddEntity(class, data, position)
	local entityTable = entities.GetTable(class);
	
	if (entityTable) then
		local image = util.GetImage(entityTable:GetMaterial());
		local rectangle = util.Rectangle(
			position.x, position.y,
			image:GetW(), image:GetH()
		);
		
		local entityObject = EditorObject("Entity");
			entityObject:SetImage(image);
			entityObject:SetRect(rectangle);
			entityObject:SetData("Data", data);
			entityObject:SetData("Class", class);
		entityObject:Add(self.m_levelData.entities);
	end;
end;

-- A function to add a brush to the state.
function STATE:AddBrush(class, image, rectangle, tileSize)
	local entityTable = entities.GetTable(class);
	
	if (entityTable) then
		local brushObject = EditorObject("Brush");
			brushObject:SetData("IsPassable", entityTable:IsPassable());
			brushObject:SetData("TileSize", tileSize);
			brushObject:SetData("Class", class);
			brushObject:SetData("Color", Color(1, 1, 1, 1));
			brushObject:SetImage(image);
			brushObject:SetRect(rectangle);
		brushObject:Add(self.m_levelData.brushes);
	end;
end;

-- A function to add a decal to the state.
function STATE:AddDecal(image, rectangle, brushObject)
	if (brushObject) then
		local brushRect = brushObject:GetWorldRect();
		
		if (util.DoesOverlap(rectangle, brushRect)) then
			rectangle.x = rectangle.x - brushRect.x;
			rectangle.y = rectangle.y - brushRect.y;
			
			local decalObject = EditorObject("Decal", brushObject);
				decalObject:SetImage(image);
				decalObject:SetRect(rectangle);
				decalObject:SetData("Color", Color(1, 1, 1, 1));
			decalObject:Add();
		end;
	else
		local decalObject = EditorObject("Decal");
			decalObject:SetImage(image);
			decalObject:SetRect(rectangle);
			decalObject:SetData("Color", Color(1, 1, 1, 1));
		decalObject:Add(self.m_levelData.decals);
	end;
end;

-- A function to get an object at a position.
function STATE:GetAtPos(position, objectType)
	if (not objectType or objectType == "Decal") then
		for i = #self.m_levelData.decals, 1, -1 do
			local decalObject = self.m_levelData.decals[i];
			
			if (util.IsInside(decalObject:GetWorldRect(), position)) then
				return decalObject;
			end;
		end;
	end;
	
	for i = #self.m_levelData.brushes, 1, -1 do
		local brushObject = self.m_levelData.brushes[i];
		
		if (not objectType or objectType == "Decal") then
			local childrenTable = brushObject:GetChildren();
			
			for j = #childrenTable, 1, -1 do
				local childObject = childrenTable[j];
				local rectangle = childObject:GetWorldRect();
				
				if (util.IsInside(rectangle, position)) then
					return childObject;
				end;
			end;
		end;
		
		if (not objectType or objectType == "Brush") then
			if (util.IsInside(brushObject:GetWorldRect(), position)) then
				return brushObject;
			end;
		end;
	end;
	
	if (not objectType or objectType == "Entity") then
		for i = #self.m_levelData.entities, 1, -1 do
			local entityObject = self.m_levelData.entities[i];
			
			if (util.IsInside(entityObject:GetWorldRect(), position)) then
				return entityObject;
			end;
		end;
	end;
	
	if (not objectType or objectType == "Texture") then
		for i = #self.m_levelData.textures, 1, -1 do
			local textureObject = self.m_levelData.textures[i];
			
			if (util.IsInside(textureObject:GetWorldRect(), position)) then
				return textureObject;
			end;
		end;
	end;
end;

-- A function to get the state's textures.
function STATE:GetTextures()
	return self.m_levelData.textures;
end;

-- A function to get the state's entities.
function STATE:GetEntities()
	return self.m_levelData.entities;
end;

-- A function to get the state's brushes.
function STATE:GetBrushes()
	return self.m_levelData.brushes;
end;

-- A function to get the state's decals.
function STATE:GetDecals()
	return self.m_levelData.decals;
end;

-- A function to save the level.
function STATE:SaveLevel()
	local levelData = {
		textures = {}, brushes = {}, entities = {}
	};
	
	for k, v in ipairs(self.m_levelData.textures) do
		local rectangle = v:GetWorldRect();
		local tileSize = v:GetData("TileSize");
		local color = v:GetData("Color");
		
		levelData.textures[k] = {
			tileSize = tileSize,
			position = Vec2(rectangle.x, rectangle.y),
			height = rectangle.h,
			image = util.GetImagePath(v:GetImage()),
			width = rectangle.w,
			color = color
		};
	end;
	
	for k, v in ipairs(self.m_levelData.brushes) do
		local rectangle = v:GetWorldRect();
		local image = v:GetImage();
		local color = v:GetData("Color");
		local class = v:GetData("Class");
		
		levelData.brushes[k] = {
			position = Vec2(rectangle.x, rectangle.y),
			height = rectangle.h,
			width = rectangle.w,
			image = util.GetImagePath(image),
			class = class,
			color = color,
			data = v:GetData()
		};
	end;
	
	for k, v in ipairs(self.m_levelData.entities) do
		local rectangle = v:GetWorldRect();
		local image = v:GetImage();
		local color = v:GetData("Color");
		local class = v:GetData("Class");
		local data = v:GetData("Data");
		
		levelData.entities[k] = {
			position = Vec2(rectangle.x, rectangle.y),
			angle = Angle(0, ANGLE_DEGREES),
			class = class,
			data = data
		};
	end;
	
	files.Write("levels/TestLevel.lev", json.Encode(levelData));
end;

-- A function to align a frame with the state's frame.
function STATE:AlignFrame(frame)
	if (self.m_frame:GetX() + self.m_frame:GetW() + 64 > display.GetW()) then
		frame:MoveLeftOf(self.m_frame, 8);
	else
		frame:MoveRightOf(self.m_frame, 8);
	end;
	
	frame:AlignWithVertically(self.m_frame);
end;

-- A function to get the state's grid size.
function STATE:GetGridSize()
	return self.m_iGridSize;
end;

-- A function to get the state's frame.
function STATE:GetFrame()
	return self.m_frame;
end;

-- A function to draw the state's grid.
function STATE:DrawGrid()
	local cameraPos = camera.GetPos();
	local gridColor = Color(1, 1, 1, 0.3);
	local gridSize = self.m_iGridSize;
	local scrW = display.GetW();
	local scrH = display.GetH();
	
	for x = 0, WORLD_SIZE / gridSize do
		local positionX = x * gridSize;
		
		if (positionX >= cameraPos.x and positionX <= cameraPos.x + scrW) then
			local position = util.SnapToGrid(positionX, gridSize);
			render.DrawLine(position, 0, position, WORLD_SIZE, gridColor);
		end;
	end;
	
	for y = 0, WORLD_SIZE / gridSize do
		local positionY = y * gridSize;
		
		if (positionY >= cameraPos.y and positionY <= cameraPos.y + scrH) then
			local position = util.SnapToGrid(positionY, gridSize);
			render.DrawLine(0, position, WORLD_SIZE, position, gridColor);
		end;
	end;
end;

-- A function to add a tool button to the state.
function STATE:AddToolButton(y, toolName, icon, color)
	local toolButton = controls.Create("Button", self.m_frame);
	toolButton:SetPos(8, y);
	toolButton:SetIcon(icon);
	toolButton:SetText(string.upper(toolName));
	toolButton:SetSize(self.m_frame:GetW() - 16, 24);
	toolButton:SetColor(color);
	toolButton:SetCallback(function()
		tools.SetActive(toolName);
	end);
	
	return y + toolButton:GetH() + 8;
end;

-- A function to add a checkbox to the state.
function STATE:AddCheckBox(text, bIsChecked, Callback)
	local checkBox = controls.Create("CheckBox", self.m_frame);
		checkBox:SetText(text);
		checkBox:SetFont("VerdanaTiny");
		checkBox:SetChecked(bIsChecked);
		checkBox:SetCallback(Callback);
	return checkBox;
end;

-- A function to add styled panel.
function STATE:AddStyledPanel(label, panel, frame)
	local itemList = controls.Create("ItemList", frame);
		local labelPnl = controls.Create("Label");
			labelPnl:SetVertAlign(8);
			labelPnl:SetFont("VerdanaTiny");
			labelPnl:SetText(label);
		itemList:SetPadding(4);
		itemList:SetSpacing(6);
		itemList:AddItem(labelPnl);
		
		if (type(panel) == "table") then
			for k, v in ipairs(panel) do
				itemList:AddItem(v);
			end;
		else
			itemList:AddItem(panel);
		end;
		
		itemList:SizeToContents();
	return itemList;
end;

-- Called when the state is unloaded.
function STATE:OnUnload()
	tools.SetActive(nil);
	lighting.Destroy();
end;

-- Called when the state is loaded.
function STATE:OnLoad()
	self.m_levelData = {
		textures = {},
		entities = {},
		brushes = {},
		decals = {}
	};
	self.m_iGridSize = 16;
	self.m_bShowGrid = true;
	self.m_bPanning = false;
	self.m_bDrawLighting = false;
	
	camera.SetScreenBounds(0, 20, display.GetW(), display.GetH() - 20);
	camera.SetWorldBounds(0, 0, WORLD_SIZE, WORLD_SIZE);
	camera.SetWorldPos(Vec2(0, 0));
	
	lighting.Init(Color(0.03, 0.03, 0.03, 1));
	
	self.m_menuBar = controls.Create("MenuBar");
	self.m_menuBar:SetSize(display.GetW(), 20);
	self.m_menuBar:SetPos(0, 0);
	self.m_menuBar:AddItem("File", function(simpleMenu)
		simpleMenu:AddOption("Exit", function()
			game.SetRunning(false);
		end);
	end);
	self.m_menuBar:AddItem("Save", function(simpleMenu)
		self:SaveLevel();
	end);
	self.m_menuBar:AddItem("Test", function(simpleMenu)
		self:SaveLevel();
		controls.Clear(); entities.Clear();
			states.SetActive("PlayState");
		levels.Load("TestLevel");
	end);
	
	self.m_frame = controls.Create("Frame");
	self.m_frame:HideCloseButton();
	self.m_frame:SetDraggable(true);
	self.m_frame:SetTitle("Tools");
	self.m_frame:SetSize(200, 400);
	self.m_frame:SetPos(64, 64);
	
	local y = self:AddToolButton(32, "Select", "silkicons/wand", Color(0.7, 0.2, 0.2, 0.8));
		y = self:AddToolButton(y, "Texture", "silkicons/palette", Color(0.2, 0.2, 0.7, 0.8));
		y = self:AddToolButton(y, "Brush", "silkicons/paintbrush", Color(0.2, 0.7, 0.2, 0.8));
		y = self:AddToolButton(y, "Entity", "silkicons/note", Color(0.4, 0.7, 1.0, 0.8));
		y = self:AddToolButton(y, "Decal", "silkicons/note", Color(0.2, 0.7, 0.7, 0.8));
	local seperator = controls.Create("Seperator", self.m_frame);
		seperator:SetPos(8, y);
		seperator:SetWidth(self.m_frame:GetW() - 16);
	y = y + 8;
	
	local gridSizeBox = controls.Create("OptionBox", self.m_frame);
		gridSizeBox:SetCallback(function(option)
			self.m_iGridSize = tonumber(option);
		end);
	local itemList = self:AddStyledPanel("Grid Size", gridSizeBox, self.m_frame);
		itemList:SetWidth(self.m_frame:GetW() - 16);
		itemList:SetPos(8, y);
	y = y + itemList:GetH() + 8;
	
	for k, v in ipairs({4, 8, 16, 32, 64, 128}) do
		gridSizeBox:AddOption(v);
	end;
	
	local pnlShowGrid = self:AddCheckBox("Show Grid", self.m_bShowGrid, function(bIsChecked)
		self.m_bShowGrid = bIsChecked
	end);
	local pnlDrawLighting = self:AddCheckBox("Draw Lighting", self.m_bDrawLighting, function(bIsChecked)
		self.m_bDrawLighting = bIsChecked
	end);
	
	local itemList = self:AddStyledPanel("Options", {pnlShowGrid, pnlDrawLighting}, self.m_frame);
		itemList:SetWidth(self.m_frame:GetW() - 16);
		itemList:SetPos(8, y);
	y = y + itemList:GetH() + 8;
	
	self.m_frame:SetHeight(y);
end;