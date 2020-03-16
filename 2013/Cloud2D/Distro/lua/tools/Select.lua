--[[
	© 2011-2012 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
	Conna Wiles (connawiles@gmail.com)
--]]

-- Called when a mouse button is released.
function TOOL:MouseButtonRelease(button)
	if (button == MOUSE_LEFT) then
		if (self.m_selection and self.m_selection.resize) then
			self.m_selection.resize = nil;
			return;
		end;
		
		if (self.m_selection and self.m_selection.isMoving) then
			self.m_selection.isMoving = false;
			self.m_selection.dragPos = nil;
			
			local selectedObject = self.m_selection.object;
			local parentObject = selectedObject:GetParentObject();
			local rectangle = selectedObject:GetWorldRect();
			
			if (parentObject and not util.DoesOverlap(rectangle, parentObject:GetWorldRect())) then
				self:RemoveSelection();
			end;
		else
			local mousePosWorld = util.ScreenToWorld(util.GetMousePos());
			local editor = self:GetEditor();
			local object = nil;
			
			if (mousePosWorld) then
				object = editor:GetAtPos(mousePosWorld);
			end;
			
			if (object) then
				self.m_selection = {
					isMoving = false,
					dragPos = nil,
					object = object,
				};
				
				if (object:GetClass() == "Entity") then
					self:ShowProperties(object:GetUserData());
				elseif (self.m_frame) then
					self.m_frame:Remove();
					self.m_frame = nil;
				end;
			else
				self.m_selection = nil;
			end;
		end;
	elseif (button == MOUSE_RIGHT and self.m_selection) then
		local mousePosWorld = util.ScreenToWorld(util.GetMousePos());
		local selectedObject = self.m_selection.object;
		local rectangle = selectedObject:GetWorldRect();
		
		if (mousePosWorld and util.IsInside(rectangle, mousePosWorld)) then
			local menu = controls.Create("SimpleMenu");
				local subMenu = menu:AddSubMenu("Send To");
					subMenu:AddOption("Front", function()
						self:SendToFront();
					end);
					subMenu:AddOption("Back", function()
						self:SendToBack();
					end);
				menu:AddOption("Delete", function()
					self:RemoveSelection();
				end);
				menu:AddOption("Duplicate", function()
					self:CreateDuplicate();
				end);
			menu:Open();
		end;
	end;
end;

-- A function to show an entity's properties.
function TOOL:ShowProperties(entity)
	if (self.m_frame) then
		self.m_frame:Remove();
		self.m_frame = nil;
	end;
	
	local editor = self:GetEditor();
	
	self.m_frame = controls.Create("Frame");
	self.m_frame:SetDraggable(true);
	self.m_frame:SetTitle(entity:GetClass().." Properties");
	self.m_frame:SetSize(200, 300);
	self.m_frame:SetPos(frameX, frameY);
	self.m_data = entity:GetKeyValues();
	
	local entityControls = EntityControls(self.m_frame, self.m_data, function(key, value)
		entity:SetKeyValue(key, value);
	end);
	local controlTable = {};
	
	for k, v in pairs(self.m_data) do
		table.insert(controlTable, {key = k, value = v});
	end;
	
	table.sort(controlTable, function(a, b)
		local keyValueTypeA = entity:GetKeyValueType(a.key);
		local keyValueTypeB = entity:GetKeyValueType(b.key);
		
		if (keyValueTypeA == keyValueTypeB) then
			return a.key < b.key;
		end;
		
		return keyValueTypeA > keyValueTypeB;
	end);
	
	for k, v in pairs(controlTable) do
		local keyValueType = entity:GetKeyValueType(v.key);
		
		if (keyValueType == KEYVALUE_TEXTURE) then
			entityControls:TexturePicker(v.key, v.key, v.value);
		elseif (keyValueType == KEYVALUE_BOOLEAN) then
			entityControls:CheckBox(v.key, v.key, v.value);
		elseif (keyValueType == KEYVALUE_STRING) then
			entityControls:Input(v.key, v.key, (v.value == "" and nil or v.value), "["..v.key.."]");
		elseif (keyValueType == KEYVALUE_NUMBER) then
			entityControls:Input(v.key, v.key, (v.value == nil and nil or tostring(v.value)), "{"..v.key.."}", true);
		elseif (keyValueType == KEYVALUE_ARRAY) then
			entityControls:OptionBox(v.key, v.key, v.value);
		elseif (keyValueType == KEYVALUE_COLOR) then
			-- Do nothing yet! No Color control.
		end;
	end;
	
	editor:AlignFrame(self.m_frame);
end;

-- A function to get the selected entity.
function TOOL:GetSelectedEntity()
	if (not self.m_selection or self.m_selection.object:GetClass() ~= "Entity") then
		return;
	end;
	
	return self.m_selection.object:GetUserData();
end;

RESIZE_UP = 0;
RESIZE_RIGHT = 1;
RESIZE_DOWN = 2;
RESIZE_LEFT = 3;

-- A function to get whether an object can be resized.
function TOOL:GetResizableFromHere(mousePos, object)
	local rectangle = object:GetLocalRect();
	local resizable = nil;
	
	if (object:GetClass() == "Entity" or object:GetClass() == "Texture") then
		if (mousePos.x >= rectangle.x
		and mousePos.y >= rectangle.y - 8
		and mousePos.x <= rectangle.x + rectangle.w
		and mousePos.y <= rectangle.y + (rectangle.h * 0.05)) then
			resizable = resizable or {};
			resizable[RESIZE_UP] = {rectangle.y, rectangle.h};
		end;
		
		if (mousePos.x >= rectangle.x + rectangle.w - (rectangle.w * 0.05)
		and mousePos.y >= rectangle.y
		and mousePos.x <= rectangle.x + rectangle.w + 8
		and mousePos.y <= rectangle.y + rectangle.h) then
			resizable = resizable or {};
			resizable[RESIZE_RIGHT] = rectangle.w;
		end;
		
		if (mousePos.x >= rectangle.x
		and mousePos.y >= rectangle.y + rectangle.h - (rectangle.h * 0.05)
		and mousePos.x <= rectangle.x + rectangle.w
		and mousePos.y <= rectangle.y + rectangle.h + 8) then
			resizable = resizable or {};
			resizable[RESIZE_DOWN] = rectangle.h;
		end;
		
		if (mousePos.x >= rectangle.x - 8
		and mousePos.y >= rectangle.y
		and mousePos.x <= rectangle.x + (rectangle.w * 0.05)
		and mousePos.y <= rectangle.y + rectangle.h) then
			resizable = resizable or {};
			resizable[RESIZE_LEFT] = {rectangle.x, rectangle.w};
		end;
	end;
	
	return resizable;
end;

-- Called when a mouse button is pressed.
function TOOL:MouseButtonPress(button)
	local editor = self:GetEditor();
	local gridSize = editor:GetGridSize();
	
	if (button == MOUSE_LEFT and self.m_selection) then
		local mousePosWorld = util.ScreenToWorld(util.GetMousePos());
		
		if (mousePosWorld) then
			mousePosWorld = util.SnapToGrid(mousePosWorld, gridSize);
			self.m_selection.resize = self:GetResizableFromHere(mousePosWorld, self.m_selection.object);
			
			if (self.m_selection.resize) then return; end;
			local object = editor:GetAtPos(mousePosWorld);
			
			if (object and self.m_selection.object == object) then
				
				if (not self.m_selection.resize) then
					local rectangle = object:GetLocalRect();
					
					rectangle.x = util.SnapToGrid(rectangle.x, gridSize);
					rectangle.y = util.SnapToGrid(rectangle.y, gridSize);
					
					self.m_selection.isMoving = true;
					self.m_selection.dragPos = {
						x = rectangle.x - mousePosWorld.x,
						y = rectangle.y - mousePosWorld.y,
					};
				end;
			end;
		end;
	end;
end;

-- Called when a key is released.
function TOOL:KeyRelease(key)
	if (key == KEY_DELETE) then
		self:RemoveSelection();
	end;
end;

-- A function to create a duplicate of the current selection.
function TOOL:CreateDuplicate()
	if (not self.m_selection) then return; end;
	
	self.m_selection.object = self.m_selection.object:Duplicate();
end;

-- A function to remove the current selection.
function TOOL:RemoveSelection()
	if (not self.m_selection) then return; end;
	
	self.m_selection.object:Remove();
	self.m_selection = nil;
end;

-- A function to send the current selection to the front.
function TOOL:SendToFront()
	if (self.m_selection) then
		self.m_selection.object:SendToFront();
	end;
end;

-- A function to send the current selection to the back.
function TOOL:SendToBack()
	if (self.m_selection) then
		self.m_selection.object:SendToBack();
	end;
end;

-- Called when the game should be updated.
function TOOL:UpdateGame(deltaTime)
	local editor = self:GetEditor();
	local gridSize = editor:GetGridSize();
	
	if (not self.m_selection) then
		if (self.m_frame) then
			self.m_frame:Remove();
			self.m_frame = nil;
		end;
		
		self.m_data = nil;
		return;
	end;
	
	local mousePosWorld = util.ScreenToWorld(util.GetMousePos());

	if (mousePosWorld) then
		mousePosWorld = util.SnapToGrid(mousePosWorld, gridSize);
		local object = self.m_selection.object;
		local rectangle = object:GetLocalRect();
		
		if (self.m_selection.resize) then
			if (self.m_selection.resize[RESIZE_UP]) then
				rectangle.y = math.min(
					mousePosWorld.y, (self.m_selection.resize[RESIZE_UP][1] + self.m_selection.resize[RESIZE_UP][2]) - gridSize
				);
				rectangle.h = self.m_selection.resize[RESIZE_UP][2] + (self.m_selection.resize[RESIZE_UP][1] - rectangle.y);
			end;
			
			if (self.m_selection.resize[RESIZE_LEFT]) then
				rectangle.x = math.min(
					mousePosWorld.x, (self.m_selection.resize[RESIZE_LEFT][1] + self.m_selection.resize[RESIZE_LEFT][2]) - gridSize
				);
				rectangle.w = self.m_selection.resize[RESIZE_LEFT][2] + (self.m_selection.resize[RESIZE_LEFT][1] - rectangle.x);
			end;
			
			if (self.m_selection.resize[RESIZE_RIGHT]) then
				rectangle.w = math.max(gridSize, mousePosWorld.x - rectangle.x);
			end;
			
			if (self.m_selection.resize[RESIZE_DOWN]) then
				rectangle.h = math.max(gridSize, mousePosWorld.y - rectangle.y);
			end;
			
			object:SetRect(rectangle);
		else
			local dragPos = self.m_selection.dragPos;
			
			if (self.m_selection.isMoving) then
				object:Move(Vec2(mousePosWorld.x + dragPos.x, mousePosWorld.y + dragPos.y));
			end;
		end;
	end;
end;

-- Called just before the lighting is drawn.
function TOOL:PreDrawLighting() end;

local ARROW_SPRITE = sprites.AddMaterial("arrow", true);

-- Called just after the lighting is drawn.
function TOOL:PostDrawLighting()
	if (not self.m_selection) then return; end;
	
	local object = self.m_selection.object;
	local rectangle = object:GetWorldRect();
	
	if (self.m_selection.isMoving) then
		render.DrawBox(
			rectangle.x,
			rectangle.y,
			rectangle.w,
			rectangle.h,
			Color(1, 1, 0, 1)
		);
	elseif (self.m_selection.resize) then
		render.DrawBox(
			rectangle.x,
			rectangle.y,
			rectangle.w,
			rectangle.h,
			Color(0, 1, 1, 1)
		);
		
		render.DrawBox(
			rectangle.x + 1,
			rectangle.y + 1,
			rectangle.w - 2,
			rectangle.h - 2,
			Color(0, 1, 0, 1)
		);
	else
		render.DrawBox(
			rectangle.x,
			rectangle.y,
			rectangle.w,
			rectangle.h,
			Color(1, 0, 1, 1)
		);
	end;
	
	local editor = self:GetEditor();
	local gridSize = editor:GetGridSize();
	local mousePosWorld = util.ScreenToWorld(util.GetMousePos());
	if (not mousePosWorld) then return; end;
	
	local resizable = self.m_selection.resize;
	local color = Color(1, 1, 1, 1);
	
	if (not resizable) then
		resizable = self:GetResizableFromHere(mousePosWorld, self.m_selection.object);
		color = Color(1, 1, 1, 0.8);
	end;
	
	if (not resizable) then
		resizable = {};
	end;
	
	ARROW_SPRITE:Draw(
		rectangle.x + (rectangle.w / 2) - 16,
		rectangle.y - 32,
		32, 32,
		Angle(-90, ANGLE_DEGREES),
		(resizable[RESIZE_UP] and color) or Color(1, 1, 1, 0.3)
	);
	
	ARROW_SPRITE:Draw(
		rectangle.x + rectangle.w,
		rectangle.y + (rectangle.h / 2) - 16,
		32, 32,
		Angle(0, ANGLE_DEGREES),
		(resizable[RESIZE_RIGHT] and color) or Color(1, 1, 1, 0.3)
	);
	
	ARROW_SPRITE:Draw(
		rectangle.x + (rectangle.w / 2) - 16,
		rectangle.y + rectangle.h,
		32, 32,
		Angle(90, ANGLE_DEGREES),
		(resizable[RESIZE_DOWN] and color) or Color(1, 1, 1, 0.3)
	);
	
	ARROW_SPRITE:Draw(
		rectangle.x - 32,
		rectangle.y + (rectangle.h / 2) - 16,
		32, 32,
		Angle(180, ANGLE_DEGREES),
		(resizable[RESIZE_LEFT] and color) or Color(1, 1, 1, 0.3)
	);
end;

-- A function to create the tool controls.
function TOOL:CreateControls() end;

-- Called when the tool has become inactive.
function TOOL:OnInactive()
	self.m_selection = nil;
	
	if (self.m_frame) then
		self.m_frame:Remove();
		self.m_frame = nil;
	end;
end;

-- Called when the tool has become active.
function TOOL:OnActive()
	if (not self.m_bInitialized) then
		self.m_bInitialized = true;
	end;
	
	self:CreateControls();
end;