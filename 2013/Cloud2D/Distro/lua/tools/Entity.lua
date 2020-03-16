--[[
	© 2011-2012 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
	Conna Wiles (connawiles@gmail.com)
--]]

-- Called when a mouse button is released.
function TOOL:MouseButtonRelease(button)
	if (button == MOUSE_LEFT and self.m_rectangle) then
		local editor = self:GetEditor();
			editor:AddEntity(self.m_entity);
		self.m_rectangle = nil;
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
			
			self.m_entity = entities.FromKeyValues(self.m_sClassName, self.m_data);
			if (not self.m_entity) then return; end;
			
			self.m_entity:SetFixedRotation(true);
			self.m_entity:SetCollisionType(COLLISION_NONE);
			
			self.m_brushOrigin = mousePosWorld;
			self.m_rectangle = util.Rectangle(
				mousePosWorld.x,
				mousePosWorld.y,
				self.m_entity:GetW(),
				self.m_entity:GetH()
			);
			
			self.m_entity:SetSize(self.m_rectangle.w, self.m_rectangle.h);
			self.m_entity:SetPos(Vec2(self.m_rectangle.x, self.m_rectangle.y));
		end;
	end;
end;

-- Called when the game should be updated.
function TOOL:UpdateGame(deltaTime)
	if (self.m_rectangle) then
		local origin = self.m_brushOrigin;
		local editor = self:GetEditor();
		local gridSize = editor:GetGridSize();
		local mousePos = util.ScreenToWorld(util.GetMousePos());
		
		if (not self.m_bShowBrushes) then
			if (mousePos) then
				self.m_rectangle.x = util.SnapToGrid(
					mousePos.x - (self.m_rectangle.w / 2), gridSize
				);
				
				self.m_rectangle.y = util.SnapToGrid(
					mousePos.y - (self.m_rectangle.h / 2), gridSize
				);
			end;
			
			self.m_entity:SetPos(Vec2(self.m_rectangle.x, self.m_rectangle.y));
		elseif (mousePos) then
			mousePos = util.SnapToGrid(mousePos, gridSize);
			
			self.m_rectangle.w = util.SnapToGrid(math.abs(mousePos.x - origin.x), gridSize);
			self.m_rectangle.h = util.SnapToGrid(math.abs(mousePos.y - origin.y), gridSize);
			self.m_rectangle.x = math.min(mousePos.x, origin.x);
			self.m_rectangle.y = math.min(mousePos.y, origin.y);
			
			self.m_entity:SetSize(self.m_rectangle.w, self.m_rectangle.h);
			self.m_entity:SetPos(Vec2(self.m_rectangle.x, self.m_rectangle.y));
		end;
	end;
end;

ENTITY_CONTROLS = {};
ENTITY_CONTROLS.__index = ENTITY_CONTROLS;

-- A function to create a new set of entity controls.
function EntityControls(framePanel, data, Callback)
	local object = {};
		setmetatable(object, ENTITY_CONTROLS);
		object:__init(framePanel, data, Callback);
	return object;
end;

-- Called when the object is constructed.
function ENTITY_CONTROLS:__init(framePanel, data, Callback)
	self.m_itemList = controls.Create("ItemList", framePanel);
	self.m_itemList:SetDrawBackground(false);
	self.m_itemList:SetPadding(4);
	self.m_itemList:SetSpacing(8);
	self.m_itemList:SetHeight(framePanel:GetH());
	self.m_itemList:SetWidth(framePanel:GetW() - 8);
	self.m_itemList:SetPos(4, 28);
	self.m_callback = Callback;
	self.m_data = data;
	
	framePanel:SetHeight(framePanel:GetH() + 32);
end;

-- A function to create a checkbox control.
function ENTITY_CONTROLS:CheckBox(key, label, bIsChecked)
	local checkBox = controls.Create("CheckBox");
		checkBox:SetText(label);
		checkBox:SetFont("VerdanaTiny");
		checkBox:SetChecked(bIsChecked == true);
		checkBox:SetCallback(function(bIsChecked)
			if (self.m_callback) then
				self.m_callback(key, bIsChecked);
			end;
			
			self.m_data[key] = bIsChecked;
		end);
	self.m_itemList:AddItem(checkBox);
	
	self.m_data[key] = (bIsChecked == true);
end;

-- A function to create a checkbox control.
function ENTITY_CONTROLS:TexturePicker(key, label, material)
	local texturePick = controls.Create("TexturePick");
		texturePick:SetLabel(label);
		texturePick:SetMaterial(material);
		texturePick:SetCallback(function(value)
			if (self.m_callback) then
				self.m_callback(key, value);
			end;
			
			self.m_data[key] = value;
		end);
	self.m_itemList:AddItem(texturePick);
	
	self.m_data[key] = material;
end;

-- A function to create an input control.
function ENTITY_CONTROLS:OptionBox(key, label, options)
	local itemList = controls.Create("ItemList");
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
			optionBox:SetCallback(function(option)
				if (self.m_callback) then
					self.m_callback(key, option);
				end;
				
				self.m_data[key] = option;
			end);
		itemList:AddItem(optionBox);
		itemList:SizeToContents();
	self.m_itemList:AddItem(itemList);
	
	self.m_data[key] = optionBox:GetOption();
end;

-- A function to create an input control.
function ENTITY_CONTROLS:Input(key, label, value, hint, bNumbersOnly)
	local itemList = controls.Create("ItemList");
		local labelPnl = controls.Create("Label");
			labelPnl:SetVertAlign(8);
			labelPnl:SetFont("VerdanaTiny");
			labelPnl:SetText(label);
		itemList:SetPadding(4);
		itemList:SetSpacing(6);
		itemList:AddItem(labelPnl);
		
		local simpleInput = controls.Create("SimpleInput");
			simpleInput:SetText(value or "");
			simpleInput:SetHint(hint);
			simpleInput:SetNumbersOnly(bNumbersOnly);
			simpleInput:SetCallback(function(text)
				text = tonumber(text) or text;
				
				if (self.m_callback) then
					self.m_callback(key, text);
				end;
				
				self.m_data[key] = text;
			end);
		itemList:AddItem(simpleInput);
		itemList:SizeToContents();
	self.m_itemList:AddItem(itemList);
	
	self.m_data[key] = tonumber(value) or value or "";
end;

-- A function to get the tool's entity class.
function TOOL:GetEntityClass()
	return self.m_sClassName;
end;

-- A function to create the tool controls.
function TOOL:CreateControls(sDefaultOption, dataCache)
	local editor = self:GetEditor();
	
	self.m_frame = controls.Create("Frame");
	self.m_frame:SetDraggable(true);
	self.m_frame:SetTitle(self.m_bShowBrushes and "Brush" or "Entity");
	self.m_frame:SetSize(200, 400);
	
	local entityClassBox = controls.Create("OptionBox", self.m_frame);
	
	entityClassBox:SetCallback(function(option)
		if (option == "<Class Name>") then return; end;
		
		local entityTable = entities.GetTable(option);
		
		if (entityTable) then
			local frameX, frameY = self.m_frame:GetPos();

			self.m_sClassName = option;
			self.m_sMaterial = entityTable:GetMaterial();
			self.m_dataCache[option] = self.m_dataCache[option] or table.CreateCopy(entityTable:GetKeyValues());
			self.m_data = self.m_dataCache[option];
			
			self.m_frame:Remove();
			self.m_frame = controls.Create("Frame");
			self.m_frame:SetDraggable(true);
			self.m_frame:SetTitle(option);
			self.m_frame:SetSize(200, 300);
			self.m_frame:SetPos(frameX, frameY);
			
			local entityControls = EntityControls(self.m_frame, self.m_data);
			local controlTable = {};
			
			for k, v in pairs(self.m_data) do
				table.insert(controlTable, {key = k, value = v});
			end;
			
			table.sort(controlTable, function(a, b)
				local keyValueTypeA = entityTable:GetKeyValueType(a.key);
				local keyValueTypeB = entityTable:GetKeyValueType(b.key);
				
				if (keyValueTypeA == keyValueTypeB) then
					return a.key < b.key;
				end;
				
				return keyValueTypeA > keyValueTypeB;
			end);
			for k, v in pairs(controlTable) do
				local keyValueType = entityTable:GetKeyValueType(v.key);
				
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
		end;
	end);
	
	if (self.m_bShowBrushes) then
		for k, v in pairs(entities.GetClasses()) do
			if (k ~= "BaseEntity" and (k == "Brush"
			or v.m_sBaseClass == "Brush")) then
				entityClassBox:AddOption(k);
			end;
		end;

	else
		for k, v in pairs(entities.GetClasses()) do
			if (k ~= "BaseEntity" and k ~= "Brush"
			and v.m_sBaseClass ~= "Brush") then
				entityClassBox:AddOption(k);
			end;
		end;
	end;
	
	entityClassBox:SelectOption("<Class Name>");
	
	if (sDefaultOption) then
		if (dataCache) then
			self.m_dataCache[sDefaultOption] = table.CreateCopy(dataCache);
		end;
		
		entityClassBox:SelectOption(sDefaultOption);
	end;
	
	local itemList = editor:AddStyledPanel("Classname", entityClassBox, self.m_frame);
	itemList:SetPos(8, 32);
	itemList:SetWidth(self.m_frame:GetW() - 16);
	
	self.m_frame:SetHeight(
		itemList:GetY(true) + itemList:GetH() + 8
	);
	
	editor:AlignFrame(self.m_frame);
end;

-- Called when the objects should be drawn.
function TOOL:DrawObjects()
	if (self.m_entity and self.m_entity:IsValid()) then
		self.m_entity:__draw();
	end;
end;

-- Called when the tool has become inactive.
function TOOL:OnInactive()
	self.m_frame:Remove();
end;

-- Called when the tool has become active.
function TOOL:OnActive(bShowBrushes)
	if (not self.m_bInitialized) then
		self.m_bInitialized = true;
		self.m_dataCache = {};
	end;
	
	self.m_bShowBrushes = bShowBrushes;
	self:CreateControls();
end;