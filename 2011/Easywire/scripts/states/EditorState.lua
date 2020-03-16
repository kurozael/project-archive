--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
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
	self.m_bSelected = false;
	self.m_rectangle = util.Rectangle(0, 0, 0, 0);
	self.m_children = {};
	self.m_image = util.GetImage("missing");
	self.m_data = {};
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

-- A function to set the select menu callback.
function EDITOR_OBJECT:SetOnSelectMenu(Callback)
	self.OnSelectMenu = Callback;
end;

-- A function to set the deletion callback.
function EDITOR_OBJECT:SetOnDeletion(Callback)
	self.OnDeletion = Callback;
end;

-- A function to set whether the object is selected.
function EDITOR_OBJECT:SetSelected(bSelected)
	self.m_bSelected = bSelected;
end;

-- A function to get whether the object is selected.
function EDITOR_OBJECT:IsSelected()
	return self.m_bSelected;
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
	
	if (self.OnDeletion) then
		self:OnDeletion();
	end;
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
	return self.m_data[key];
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
	local position = g_Camera:GetWorldPos();
	local velocity = Vec2(0, 0);
	local speed = 256 * deltaTime;
	
	if ( g_Inputs:IsKeyDown(KEY_UP) ) then
		velocity.y = -speed;
	elseif ( g_Inputs:IsKeyDown(KEY_DOWN) ) then
		velocity.y = speed;
	end;
	
	if ( g_Inputs:IsKeyDown(KEY_LEFT) ) then
		velocity.x = -speed;
	elseif ( g_Inputs:IsKeyDown(KEY_RIGHT) ) then
		velocity.x = speed;
	end;
	
	if (self.m_bPanning) then
		velocity = velocity + ( (util.GetMousePos() - self.m_panPos) * (deltaTime * 4) );
	end;
	
	g_Camera:SetWorldPos(position + velocity);
	g_Camera:SnapToBounds();
end;

-- Called to get whether the lighting should be drawn.
function STATE:ShouldDrawLighting()
	return false;
end;
-- Called just after the lighting is drawn.
function STATE:PostDrawLighting()
	if (self.m_bShowGrid) then
		self:DrawGrid();
	end;
end;

-- Called when the display should be drawn.
function STATE:DrawDisplay()
	local fx, fy, fw, fh = draw.ShadowedText("VerdanaSmall", 8, 8, "FPS: "..g_Time:GetFPS(), Color(1, 0, 0, 1), Color(0, 0, 0, 0.8), true);
	local activeTool = tools.GetActive();
	
	if (activeTool) then
		fx, fy, fw, fh = draw.ShadowedText("VerdanaSmall", fx + fw + 8, fy, "Tool: "..activeTool:GetClass(), Color(0, 1, 0, 1), Color(0, 0, 0, 0.8), true);
	end;
end;

-- Called when the objects should be drawn.
function STATE:DrawObjects()
	for k, v in ipairs(self.m_levelData.wires) do
		local wireObject = v:GetData("Wire");
		local pointsList = v:GetData("Points");
		local color = v:GetData("Color");
		
		if ( v:IsSelected() ) then
			color = Color(1, 1, 1, 1);
		end;
		
		for k2, v2 in ipairs(pointsList) do
			local nextPoint = pointsList[k2 + 1];
			
			if (nextPoint) then
				g_Render:DrawLine(v2.x, v2.y, nextPoint.x, nextPoint.y, color);
			end;
		end;
		
		local wireOutput = wireObject:GetOutput();
		
		if (wireOutput) then
			local outputLineStart = pointsList[1];
			local outputLineEnd = pointsList[2];
			local outputPosition = util.GetPointOnLine(
				outputLineStart, outputLineEnd, 0.25
			);
			local outputKey = wireOutput.key;
			local color = Color(1, 1, 1, 0.75);
			
			if ( wireOutput.chip:GetOutput(outputKey) ) then
				color = Color(0, 1, 1, 0.75);
			end;
			
			draw.ShadowedText("DefaultSmall", outputPosition.x, outputPosition.y - 8,
				"<< "..outputKey, color, Color(0, 0, 0, 0.8), false, true, true);
		end;
		
		local wireInput = wireObject:GetInput();
		
		if (wireInput) then
			local inputLineStart = pointsList[ math.max(#pointsList - 1, 1) ];
			local inputLineEnd = pointsList[#pointsList];
			local inputPosition = util.GetPointOnLine(
				inputLineStart, inputLineEnd, 0.75
			);
			local inputKey = wireInput.key;
			
			draw.ShadowedText("DefaultSmall", inputPosition.x, inputPosition.y + 8,
				">> "..inputKey, Color(1, 1, 1, 0.75), Color(0, 0, 0, 0.8), false, true, true);
		end;
	end;
	
	for k, v in ipairs(self.m_levelData.chips) do
		local chipObject = v:GetData("Chip");
		local rectangle = v:GetWorldRect();
		local image = v:GetImage();
		local color = Color(1, 1, 1, 1);
		
		if (chipObject:OnDraw(v) == false) then
			g_Render:DrawImage(
				image, rectangle.x, rectangle.y,
				rectangle.w, rectangle.h, color
			);
		end;
		
		if ( chipObject:GetDrawLabel() ) then
			draw.ShadowedText("Default", rectangle.x + (rectangle.w / 2), rectangle.y + (rectangle.h / 2),
				chipObject:GetName(), Color(1, 1, 1, 1), Color(0, 0, 0, 0.8), false, true, true);
		end;
	end;
end;

-- A function to add a wire to the state.
function STATE:AddWire(wireData)
	local wireObject = wire.New();
		wireObject:Setup(
			wireData.output.chip,
			wireData.output.key,
			wireData.input.chip,
			wireData.input.key
		);
	
	local minimum = {};
	local maximum = {};
	
	for k, v in ipairs(wireData.points) do
		if (not minimum.x or v.x < minimum.x) then minimum.x = v.x; end;
		if (not minimum.y or v.y < minimum.y) then minimum.y = v.y; end;
		if (not maximum.x or v.x > maximum.x) then maximum.x = v.x; end;
		if (not maximum.y or v.y > maximum.y) then maximum.y = v.y; end;
	end;
	
	local width = maximum.x - minimum.x;
	local height = maximum.y - minimum.y;
	
	local rectangle = util.Rectangle(
		minimum.x - 2,
		minimum.y - 2,
		width + 4,
		height + 4
	);
	
	local editorObject = EditorObject("Wire");
		editorObject:SetOnDeletion(function(editorObject)
			wireObject:Remove();
		end);
		editorObject:SetRect(rectangle);
		editorObject:SetData("Wire", wireObject);
		editorObject:SetData("Color", wireData.color);
		editorObject:SetData("Points", wireData.points);
	editorObject:Add(self.m_levelData.wires);
	
	wireObject:SetEditorObject(editorObject);
end;

-- A function to add a chip to the state.
function STATE:AddChip(image, rectangle, chipType)
	local chipObject = chips.Create(chipType);
	
	if (chipObject) then
		local editorObject = EditorObject("Chip");
			editorObject:SetOnSelectMenu(function(editorObject, menu)
				chipObject:OnEditSelectMenu(menu);
			end);
			editorObject:SetOnDeletion(function(editorObject)
				chipObject:Remove();
			end);
			editorObject:SetImage(image);
			editorObject:SetRect(rectangle);
			editorObject:SetData("Chip", chipObject);
		editorObject:Add(self.m_levelData.chips);
		
		chipObject:SetEditorObject(editorObject);
	end;
end;

-- A function to get an object at a position.
function STATE:GetAtPos(position, objectType)
	if (not objectType or objectType == "Chip") then
		for i = #self.m_levelData.chips, 1, -1 do
			local chipObject = self.m_levelData.chips[i];
			
			if ( util.IsInside(chipObject:GetWorldRect(), position) ) then
				return chipObject;
			end;
		end;
	end;
	
	if (not objectType or objectType == "Wire") then
		for i = #self.m_levelData.wires, 1, -1 do
			local wireObject = self.m_levelData.wires[i];
			local pointsList = wireObject:GetData("Points");
			
			for k, v in ipairs(pointsList) do
				local nextPoint = pointsList[k + 1];
				
				if (nextPoint) then
					local lineStart = Vec2(v.x, v.y);
					local lineEnd = Vec2(nextPoint.x, nextPoint.y);
					local distance = util.LineToPosDist(lineStart, lineEnd, position);
					
					if (distance < 5) then
						return wireObject;
					end;
				end;
			end;
		end;
	end;
end;

-- A function to get the state's chips.
function STATE:GetChips()
	return self.m_levelData.chips;
end;

-- A function to align a frame with the state's frame.
function STATE:AlignFrame(frame)
	if ( self.m_frame:GetX() + self.m_frame:GetW() + 64 > g_Display:GetW() ) then
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
	local cameraPos = g_Camera:GetPos();
	local gridColor = Color(1, 1, 1, 0.2);
	local gridSize = self.m_iGridSize;
	local scrW = g_Display:GetW();
	local scrH = g_Display:GetH();
	
	for x = 0, WORLD_SIZE / gridSize do
		local positionX = x * gridSize;
		
		if (positionX >= cameraPos.x and positionX <= cameraPos.x + scrW) then
			local position = util.SnapToGrid(positionX, gridSize);
			g_Render:DrawLine(position, 0, position, WORLD_SIZE, gridColor);
		end;
	end;
	
	for y = 0, WORLD_SIZE / gridSize do
		local positionY = y * gridSize;
		
		if (positionY >= cameraPos.y and positionY <= cameraPos.y + scrH) then
			local position = util.SnapToGrid(positionY, gridSize);
			g_Render:DrawLine(0, position, WORLD_SIZE, position, gridColor);
		end;
	end;
end;

-- A function to add a tool button to the state.
function STATE:AddToolButton(y, toolName, icon, color)
	local toolButton = controls.Create("Button", self.m_frame);
	toolButton:SetPos(8, y);
	toolButton:SetIcon(icon);
	toolButton:SetText( string.upper(toolName) );
	toolButton:SetSize(self.m_frame:GetW() - 16, 24);
	toolButton:SetColor(color);
	toolButton:SetCallback(function()
		tools.SetActive(toolName);
	end);
	
	return y + toolButton:GetH() + 8;
end;

-- A function to add a checkbox to the state.
function STATE:AddCheckBox(y, text, bIsChecked, Callback)
	local checkBox = controls.Create("CheckBox", self.m_frame);
	checkBox:SetPos(8, y);
	checkBox:SetText(text);
	checkBox:SetChecked(bIsChecked);
	checkBox:SetCallback(Callback);
	
	return y + checkBox:GetH() + 8;
end;

-- Called when the state is unloaded.
function STATE:OnUnload()
	tools.SetActive(nil);
end;

-- Called when the state is loaded.
function STATE:OnLoad()
	self.m_levelData = {
		chips = {},
		wires = {}
	};
	self.m_iGridSize = 8;
	self.m_bShowGrid = true;
	self.m_bPanning = false;
	
	g_Camera:SetWorldBounds(0, 0, WORLD_SIZE, WORLD_SIZE);
	g_Camera:SetWorldPos( Vec2(0, 0) );
	
	self.m_frame = controls.Create("Frame");
	self.m_frame:HideCloseButton();
	self.m_frame:SetDraggable(true);
	self.m_frame:SetTitle("Tools");
	self.m_frame:SetSize(200, 400);
	self.m_frame:SetPos(64, 64);
	
	local y = self:AddToolButton( 32, "Select", "silkicons/wand", Color(0.7, 0.2, 0.2, 0.8) );
	y = self:AddToolButton( y, "Chip", "silkicons/paintbrush", Color(0.2, 0.7, 0.2, 0.8) );
	y = self:AddToolButton( y, "Wire", "silkicons/note", Color(0.2, 0.7, 0.7, 0.8) );
	
	local gridSizeLabel = controls.Create("Label", self.m_frame);
	gridSizeLabel:SetText("Grid Size:");
	gridSizeLabel:SetPos(8, y);
	
	local gridSizeBox = controls.Create("OptionBox", self.m_frame);
	gridSizeBox:SetPos(
		gridSizeLabel:GetX(true) + gridSizeLabel:GetW() + 8,
		gridSizeLabel:GetY(true) - (gridSizeLabel:GetH() * 0.3)
	);
	gridSizeBox:SetWidth(self.m_frame:GetW() - gridSizeBox:GetX(true) - 8);
	gridSizeBox:SelectOption(self.m_iGridSize);
	gridSizeBox:SetCallback(function(option)
		self.m_iGridSize = tonumber(option);
	end);
	
	for k, v in ipairs( {4, 8, 16, 32, 64, 128} ) do
		gridSizeBox:AddOption(v);
	end;
	
	y = gridSizeBox:GetY(true) + gridSizeBox:GetH() + 8;
	
	y = self:AddCheckBox(y, "Show Grid", self.m_bShowGrid, function(bIsChecked)
		self.m_bShowGrid = bIsChecked
	end);
	
	self.m_frame:SetHeight(y);
end;