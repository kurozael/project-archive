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
	
	if (self.m_sClassName == "Entity") then
		object:SetUserData(entities.Duplicate(self.m_userData));
	end;
	
	object:SetRect(self:GetLocalRect());
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
	if (self.m_sClassName == "Entity") then
		self.m_rectangle = self:GetLocalRect();
	end;
	
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
	if (self.m_sClassName == "Entity") then
		self.m_userData:Remove();
	end;
	
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

-- A function to set the object's user data.
function EDITOR_OBJECT:SetUserData(userData)
	self.m_userData = userData;
end;

-- A function to get the object's user data.
function EDITOR_OBJECT:GetUserData()	
	return self.m_userData;
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
	if (self.m_sClassName == "Entity") then
		local position = self.m_userData:GetPos();
		local height = self.m_userData:GetH();
		local width = self.m_userData:GetW();
		
		self.m_rectangle = util.Rectangle(
			position.x, position.y,
			width, height
		);
	end;
	
	return self.m_rectangle;
end;

-- A function to set the object's rectangle.
function EDITOR_OBJECT:SetRect(rectangle)
	self.m_rectangle.x = rectangle.x;
	self.m_rectangle.y = rectangle.y;
	self.m_rectangle.w = rectangle.w;
	self.m_rectangle.h = rectangle.h;
	
	if (self.m_sClassName == "Entity") then
		self.m_userData:SetSize(rectangle.w, rectangle.h);
		self.m_userData:SetPos(Vec2(rectangle.x, rectangle.y));
	end;
end;

-- A function to move the object.
function EDITOR_OBJECT:Move(position)
	self.m_rectangle.x = position.x;
	self.m_rectangle.y = position.y;
	
	if (self.m_sClassName == "Entity") then
		self.m_userData:SetPos(position);
	end;
end;

-- A function to resize the object.
function EDITOR_OBJECT:Resize(width, height)
	self.m_rectangle.w = width;
	self.m_rectangle.h = height;
	
	if (self.m_sClassName == "Entity") then
		self.m_userData:SetSize(width, height);
	end;
end;

-- A function to set the object's size.
function EDITOR_OBJECT:SetSize(width, height)
	self:Resize(width, height);
end;

-- A function to get the object's size.
function EDITOR_OBJECT:GetSize()
	if (self.m_sClassName == "Entity") then
		return self.m_userData:GetW(), self.m_userData:GetH();
	end;
	
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
	
	if (self.m_sClassName == "Entity") then
		self.m_userData:SetPos(self.m_rectangle.x, self.m_rectangle.y);
	end;
end;

-- A function to get the object's position.
function EDITOR_OBJECT:GetPos()
	if (self.m_sClassName == "Entity") then
		local position = self.m_userData:GetPos();
		return position.x, position.y;
	end;
	
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
	local speed = 200 * deltaTime;
	
	if (inputs.IsKeyDown(KEY_UP)
	and not controls:GetFocused()) then
		velocity.y = -speed;
	elseif (inputs.IsKeyDown(KEY_DOWN)
	and not controls:GetFocused()) then
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
	if (tools.GetActiveName() == "Select") then
		local entity = tools.GetActive():GetSelectedEntity();
		
		if (entity and entity:IsValid() and entity:GetClass() == "Light") then
			return true;
		end;
	elseif (tools.GetActiveName() == "Light") then
		return true;
	end;
	
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
end;

-- Called just after the lighting is drawn.
function STATE:PostDrawLighting()
	if (self.m_bShowGrid) then
		self:DrawGrid();
	end;
end;

-- Called when the display should be drawn.
function STATE:DrawDisplay()
	local fx, fy, fw, fh = draw.ShadowedText("VerdanaSmall", 64, 32, "FPS: "..time.GetFPS(), Color(1, 0, 0, 1), Color(0, 0, 0, 0.8), true);
	local activeTool = tools.GetActive();
	
	if (activeTool) then
		fx, fy, fw, fh = draw.ShadowedText("VerdanaSmall", fx + fw + 8, fy, "Tool: "..activeTool:GetClass(), Color(0, 1, 0, 1), Color(0, 0, 0, 0.8), true);
	end;
end;

-- Called when the objects should be drawn.
function STATE:DrawObjects()
	for k, v in ipairs(self.m_levelData.entities) do
		local entity = v:GetUserData();
		entity:__draw();
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
function STATE:AddEntity(entity)
	local entityObject = EditorObject("Entity");
		entityObject:SetUserData(entity);
	entityObject:Add(self.m_levelData.entities);
end;

-- A function to add a link to the state.
function STATE:AddLink(outputEntity, outputName, inputEntity, inputName, argString)
	if (outputEntity and inputEntity and outputEntity:IsValid() and (type(inputEntity) == "string" or inputEntity:IsValid())) then
		local outputIndex = outputEntity:EntIndex();
		local inputIndex = inputEntity;
		
		if (type(inputEntity) ~= "string") then
			inputIndex = inputEntity:EntIndex();
		end;
		
		self.m_levelData.links[outputIndex] = self.m_levelData.links[outputIndex] or {};
		self.m_levelData.links[outputIndex][outputName] = self.m_levelData.links[outputIndex][outputName] or {};
		self.m_levelData.links[outputIndex][outputName][inputIndex] = self.m_levelData.links[outputIndex][outputName][inputIndex] or {};
		
		table.insert(self.m_levelData.links[outputIndex][outputName][inputIndex], {
			inputName = inputName,
			argString = argString
		});
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

-- A function to get the state's decals.
function STATE:GetDecals()
	return self.m_levelData.decals;
end;

-- A function to get the state's links.
function STATE:GetLinks(entity)
	if (entity) then
		return self.m_levelData.links[entity:EntIndex()];
	else
		return self.m_levelData.links;
	end;
end;

-- A function to convert the links to a saveable state.
function STATE:GetSaveableLinks()
	local linkTable = {};
	local oldLinks = self.m_levelData.links;
	
	for outputIndex, outputTab in pairs(oldLinks) do
		for outputName, inputTab in pairs(outputTab) do
			for inputIndex, linksTab in pairs(inputTab) do
				for linkIndex, linkTab in pairs(linksTab) do
					table.insert(linkTable, {
						outputIndex = outputIndex,
						outputName = outputName,
						inputIndex = inputIndex,
						inputName = linkTab.inputName,
						argString = linkTab.argString or ""
					});
				end;
			end;
		end;
	end;
	
	return linkTable;
end;

-- A function to load a level.
function STATE:LoadLevel(levelName)
	if (not files.Exists("levels/"..levelName..".lev")) then
		print("[Editor] Warning! The level "..levelName.." does not exist.");
		print("[Editor] Cannot continue...");
		return;
	end;
	
	print("[Editor] Loading level "..levelName.." for editing, please wait...");
	
	local levelText = files.Read("levels/"..levelName..".lev");
	local levelData = json.Decode(levelText);
	local newIndexes = {};
	local iNumTextures = 0;
	local iNumBrushes = 0;
	local iNumEntities = 0;
	
	self.m_levelData = {
		textures = {},
		entities = {},
		brushes = {},
		decals = {},
		links = {}
	};
	
	for k, v in ipairs(levelData.textures) do
		local rectangle = util.Rectangle(v.position.x, v.position.y, v.width, v.height);
		self:AddTexture(util.GetImage(v.image), rectangle, v.tileSize);
		iNumTextures = iNumTextures + 1;
	end;
	
	for k, v in ipairs(levelData.brushes) do
		local entity = entities.FromKeyValues(v.class, v.keyValues);
			entity:SetFixedRotation(true);
			entity:SetCollisionType(COLLISION_NONE);
			entity:SetAngle(v.angle);
			entity:SetSize(v.width, v.height);
			entity:SetPos(v.position);
		self:AddEntity(entity);
		
		newIndexes[v.entIndex] = entity:EntIndex();
		iNumBrushes = iNumBrushes + 1;
	end;
	
	for k, v in ipairs(levelData.entities) do
		local entity = entities.FromKeyValues(v.class, v.keyValues);
			entity:SetFixedRotation(true);
			entity:SetCollisionType(COLLISION_NONE);
			entity:SetAngle(v.angle);
			entity:SetSize(v.width, v.height);
			entity:SetPos(v.position);
		self:AddEntity(entity);
		
		newIndexes[v.entIndex] = entity:EntIndex();
		iNumEntities = iNumEntities + 1;
	end;
	
	print("[Editor] Loaded "..iNumEntities.." entities...");
	print("[Editor] Loaded "..iNumTextures.." textures...");
	print("[Editor] Loaded "..iNumBrushes.." brushes...");
	
	levels.RestoreLinks(levelData.links, newIndexes, function(outputEntity, outputName, inputEntity, inputName, argString)
		self:AddLink(outputEntity, outputName, inputEntity, inputName, argString);
	end);
	
	self.m_sLevelName = levelName;
end;

-- A function to save the level.
function STATE:SaveLevel(levelName, bNoDebug)
	if (not bNoDebug) then print("[Editor] Saving level "..levelName..", please wait..."); end;
	
	local levelData = {
		textures = {}, brushes = {}, entities = {}, links = self:GetSaveableLinks()
	};
	local iNumTextures = 0;
	local iNumBrushes = 0;
	local iNumEntities = 0;
	
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
		
		iNumTextures = iNumTextures + 1;
	end;
	
	for k, v in ipairs(self.m_levelData.entities) do
		local entity = v:GetUserData();
		local data = {};
		
		entity:OnSaveLevel(data);
		
		if (entity:GetClass() == "Brush" or entity:IsDerivedFrom("Brush")) then
			levelData.brushes[k] = {
				keyValues = entity:GetKeyValues(),
				position = entity:GetPos(),
				entIndex = entity:EntIndex(),
				height = entity:GetH(),
				width = entity:GetW(),
				angle = entity:GetAngle(),
				class = entity:GetClass(),
				data = data
			};
			
			iNumBrushes = iNumBrushes + 1;
		else
			levelData.entities[k] = {
				keyValues = entity:GetKeyValues(),
				position = entity:GetPos(),
				entIndex = entity:EntIndex(),
				height = entity:GetH(),
				width = entity:GetW(),
				angle = entity:GetAngle(),
				class = entity:GetClass(),
				data = data
			};
			
			iNumEntities = iNumEntities + 1;
		end;
	end;
	
	if (not bNoDebug) then print("[Editor] Saved "..iNumEntities.." entities..."); end;
	if (not bNoDebug) then print("[Editor] Saved "..iNumTextures.." textures..."); end;
	if (not bNoDebug) then print("[Editor] Saved "..iNumBrushes.." brushes..."); end;
	
	files.Write("levels/"..levelName..".lev", json.Encode(levelData));
	self.m_sLevelName = levelName;
end;

-- A function to align a frame with the state's frame.
function STATE:AlignFrame(frame)
	if (self.m_frame:GetX() + self.m_frame:GetW() + 64 > display.GetW()) then
		frame:MoveLeftOf(self.m_frame, 32);
	else
		frame:MoveRightOf(self.m_frame, 32);
	end;
	
	frame:AlignWithVertically(self.m_frame, 48);
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

-- A function to set the active tool.
function STATE:SetActiveTool(toolName)
	if (tools.GetActiveName() == toolName) then
		tools.SetActive();
		return;
	end;
	
	tools.SetActive(
		toolName == "Brush" and "Entity" or toolName,
		toolName == "Brush" and true or nil
	);
end;

-- A function to add a tool button to the state.
function STATE:AddToolButton(y, toolName, icon, color)
	local toolButton = controls.Create("Button", self.m_frame);
	toolButton:SetPos(8, y);
	toolButton:SetIcon(icon);
	toolButton:SetText("");
	toolButton:SetSize(32, 24);
	toolButton:SetColor(color);
	toolButton:SetToolTip(toolName);
	toolButton:SetCallback(function()
		self:SetActiveTool(toolName);
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
	self.m_menuBar:Remove();
	self.m_frame:Remove();
	
	tools.SetActive(nil);
	lighting.Destroy();
end;

local TOOLS = {
	"Select",
	"Linker",
	"Texture",
	"Brush",
	"Entity"
};

-- A function to create an input prompt.
function STATE:CreateInputPrompt(title, label, value, Callback)
	local frame = controls.Create("Frame");
		frame:HideCloseButton();
		frame:SetDraggable(false);
		frame:SetTitle(title);
		frame:SetSize(256, 96);
		frame:SetPos((display.GetW() / 2) - 128, (display.GetH() / 2) - 40);
	local itemList = controls.Create("ItemList", frame);
		local labelPnl = controls.Create("Label");
			labelPnl:SetVertAlign(8);
			labelPnl:SetFont("VerdanaTiny");
			labelPnl:SetText(label);
		itemList:SetPadding(4);
		itemList:SetSpacing(6);
		itemList:AddItem(labelPnl);
		local simpleInput = controls.Create("SimpleInput");
			simpleInput:SetText(value or "");
			simpleInput:SetCallback(function(text)
				if (frame and frame:IsValid()) then
					frame:Remove();
				end;
				
				Callback(text);
			end);
		itemList:AddItem(simpleInput);
		itemList:SizeToContents();
	itemList:SetWidth(240);
	itemList:SetPos(8, 32);
	
	simpleInput:SetFocused(true);
end;

-- A function to create a choice prompt.
function STATE:CreateChoicePrompt(title, label, options, value, Callback)
	local frame = controls.Create("Frame");
		frame:HideCloseButton();
		frame:SetDraggable(false);
		frame:SetTitle(title);
		frame:SetSize(256, 96);
		frame:SetPos((display.GetW() / 2) - 128, (display.GetH() / 2) - 40);
	local itemList = controls.Create("ItemList", frame);
		local labelPnl = controls.Create("Label");
			labelPnl:SetVertAlign(8);
			labelPnl:SetFont("VerdanaTiny");
			labelPnl:SetText(label);
		itemList:SetPadding(4);
		itemList:SetSpacing(6);
		itemList:AddItem(labelPnl);
		local optionBox = controls.Create("OptionBox");
			for k, v in ipairs(options) do
				optionBox:AddOption(v);
			end;
			optionBox:SelectOption(value or "<Select Option>");
			optionBox:SetCallback(function(option)
				if (frame and frame:IsValid()) then
					frame:Remove();
				end;
				
				Callback(option);
			end);
		itemList:AddItem(optionBox);
		itemList:SizeToContents();
	itemList:SetWidth(240);
	itemList:SetPos(8, 32);
end;

-- Called when the state is loaded.
function STATE:OnLoad()
	self.m_levelData = {
		textures = {},
		entities = {},
		brushes = {},
		decals = {},
		links = {}
	};
	self.m_iGridSize = 16;
	self.m_bShowGrid = true;
	self.m_bPanning = false;
	self.m_bDrawLighting = false;
	
	camera.SetScreenBounds(48, 20, display.GetW() - 48, display.GetH() - 20);
	camera.SetWorldBounds(0, 0, WORLD_SIZE, WORLD_SIZE);
	camera.SetWorldPos(Vec2(0, 0));
	
	lighting.Init(Color(0.05, 0.05, 0.05, 1));
	
	self.m_menuBar = controls.Create("MenuBar");
	self.m_menuBar:SetSize(display.GetW(), 20);
	self.m_menuBar:SetPos(0, 0);
	self.m_menuBar:AddItem("File", function(simpleMenu)
		simpleMenu:AddOption("Save", function()
			self:CreateInputPrompt("Save Level", "Choose a name for this level...", self.m_sLevelName, function(levelName)
				self:SaveLevel(levelName);
			end);
		end);
		simpleMenu:AddOption("Load", function()
			self:CreateInputPrompt("Load Level", "Choose the level to load...", self.m_sLevelName, function(levelName)
				self:LoadLevel(levelName);
			end);
		end);
		simpleMenu:AddOption("Test", function()
			if (not self.m_sLevelName) then
				self:CreateInputPrompt("Test Level", "Choose a name for this level...", self.m_sLevelName, function(levelName)
					self:SaveLevel(levelName);
						states.SetActive("PlayState");
					levels.Load(levelName);
				end);
			else
				local levelName = self.m_sLevelName;
				self:SaveLevel(levelName);
					states.SetActive("PlayState");
				levels.Load(levelName);
			end;
		end);
		simpleMenu:AddOption("Exit", function()
			game.SetRunning(false);
		end);
	end);
	self.m_menuBar:AddItem("Tools", function(simpleMenu)
		simpleMenu:AddOption("<None>", function()
			tools.SetActive();
		end);
			
		for k, v in ipairs(TOOLS) do
			simpleMenu:AddOption(v, function()
				self:SetActiveTool(v);
			end);
		end;
	end);
	self.m_menuBar:AddItem("View", function(simpleMenu)
		simpleMenu:AddOption("Toggle Grid", function()
			self.m_bShowGrid = not self.m_bShowGrid;
		end);
		simpleMenu:AddOption("Draw Lighting", function()
			self.m_bDrawLighting = not self.m_bDrawLighting;
		end);
	end);
	
	self.m_frame = controls.Create("Frame");
	self.m_frame:HideCloseButton();
	self.m_frame:SetDraggable(false);
	self.m_frame:SetTitle("Tools");
	self.m_frame:SetSize(48, display.GetH());
	self.m_frame:SetPos(0, 21);
	
	local y = self:AddToolButton(32, "Select", "silkicons/wand", Color(0.7, 0.2, 0.2, 0.8));
		y = self:AddToolButton(y, "Linker", "silkicons/link_edit", Color(0.2, 0.7, 0.7, 0.8));
		y = self:AddToolButton(y, "Texture", "silkicons/palette", Color(0.2, 0.2, 0.7, 0.8));
		y = self:AddToolButton(y, "Brush", "silkicons/paintbrush", Color(0.2, 0.7, 0.2, 0.8));
		y = self:AddToolButton(y, "Entity", "silkicons/note", Color(0.4, 0.7, 1.0, 0.8));
		--y = self:AddToolButton(y, "Decal", "silkicons/note", Color(0.2, 0.7, 0.7, 0.8));
	y = y + 8;
end;