--[[
	© 2011-2012 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
	Conna Wiles (connawiles@gmail.com)
--]]

-- Called when a mouse button is released.
function TOOL:MouseButtonRelease(button)
	if (button == MOUSE_LEFT) then
		local mousePosWorld = util.ScreenToWorld(util.GetMousePos());
		local worldObject = nil;
		local editor = self:GetEditor();
		
		if (mousePosWorld) then
			worldObject = editor:GetAtPos(mousePosWorld, "Entity");
		end;
		
		-- We need a world object to continue...
		if (not worldObject) then
			self.m_selection = nil;
			return;
		end;
		
		if (self.m_selection and self.m_selection.output) then
			local outputEntity = self.m_selection.entity;
			local inputEntity = worldObject:GetUserData();
			local outputName = self.m_selection.output;
			
			if (table.Count(inputEntity.m_inputs) > 0) then
				local menu = controls.Create("SimpleMenu");
				local subMenu = menu:AddSubMenu("Input");
				
				-- We don't need this anymore!
				self.m_selection.output = nil;
				
				for k, v in pairs(inputEntity.m_inputs) do
					subMenu:AddOption(k, function()
						editor:CreateInputPrompt(k.." Input", "Add an optional parameter...", "", function(argString)
							editor:AddLink(
								outputEntity, outputName, inputEntity, k, argString
							);
							self:ShowLinkerOptions();
						end);
					end);
				end;
				
				menu:Open();
			end;
			
			return;
		end;
		
		self.m_selection = {
			object = worldObject,
			entity = worldObject:GetUserData()
		};
		
		self:ShowLinkerOptions();
	elseif (button == MOUSE_RIGHT and self.m_selection) then
		local mousePosWorld = util.ScreenToWorld(util.GetMousePos());
		local selectedObject = self.m_selection.object;
		local rectangle = selectedObject:GetWorldRect();
		local editor = self:GetEditor();
		
		if (mousePosWorld and util.IsInside(rectangle, mousePosWorld)) then
			local menu = controls.Create("SimpleMenu");
			local entity = self.m_selection.entity;
			
			if (table.Count(entity.m_outputs) > 0) then
				local subMenu = menu:AddSubMenu("Add Output");
				subMenu:SetMinimumWidth(32);
				
				for k, v in pairs(entity.m_outputs) do
					if (v.hasActivator) then
						local outputMenu = subMenu:AddSubMenu(k);
						local entityList = {};
						
						for k2, v2 in pairs(entities.GetClasses()) do
							entityList[#entityList + 1] = k2;
						end;
						
						outputMenu:AddOption("Activator", function()
							editor:CreateChoicePrompt("Activator Class", "Select the class of the activator.", entityList, "<Class Name>", function(option)
								if (option == "<Class Name>") then return; end;
								
								local entityTable = entities.GetTable(option);
								local entityClass = option;
								
								if (entityTable) then
									local inputs = {};
									
									for k2, v2 in pairs(entityTable.m_inputs) do
										inputs[#inputs + 1] = k2;
									end;
									
									editor:CreateChoicePrompt(entityClass.." Input", "Select the entity input...", inputs, "<Input Name>", function(option)
										if (option == "<Input Name>") then return; end;
										
										if (entityTable.m_inputs[option]) then
											editor:CreateInputPrompt(entityClass.." Input", "Add an optional parameter...", "", function(argString)
												editor:AddLink(
													entity, k, entityClass, option, argString
												);
												self:ShowLinkerOptions();
											end);
										end;
									end);
								end;
							end);
						end);
						
						outputMenu:AddOption("Select Target...", function()
							self.m_selection.output = k;
						end);
					else
						subMenu:AddOption(k, function()
							self.m_selection.output = k;
						end);
					end;
				end;
			end;
			
			menu:Open();
		end;
	end;
end;

-- A function to open the Linker options.
function TOOL:ShowLinkerOptions()
	if (self.m_frame) then
		self.m_frame:Remove();
		self.m_frame = nil;
	end;
	
	if (not self.m_selection) then return; end;
	
	local bDeleteFrame = true;
	local editor = self:GetEditor();
	local entity = self.m_selection.entity;
	local links = editor:GetLinks(entity);
	if (not links) then return; end;
	
	self.m_frame = controls.Create("Frame");
	self.m_frame:SetDraggable(true);
	self.m_frame:SetTitle(entity:GetClass().." Links");
	self.m_frame:SetSize(200, 400);
	self.m_frame:SetPos(frameX, frameY);
	
	local itemList = controls.Create("ItemList", self.m_frame);
	itemList:SetDrawBackground(false);
	itemList:SetPadding(4);
	itemList:SetSpacing(8);
	itemList:SetHeight(self.m_frame:GetH());
	itemList:SetWidth(self.m_frame:GetW() - 8);
	itemList:SetPos(4, 28);
	
	for outputName, inputTable in pairs(links) do
		for inputIndex, linksTable in pairs(inputTable) do
			for linkID, linkTable in pairs(linksTable) do
				local button = controls.Create("Button");
				
				if (type(inputIndex) == "string") then
					button:SetText(outputName.." Activator("..inputIndex..")");
				else
					inputIndex = entities.GetByIndex(inputIndex);
					
					if (inputIndex) then
						button:SetText(outputName.." -> "..inputIndex:GetClass());
					end;
				end;
				
				if (inputIndex) then
					button:SetToolTip("Input: "..linkTable.inputName.." Args: "..(linkTable.argString == "" and "<None>" or linkTable.argString));
					button:SetCallback(function()
						table.remove(linksTable, linkID);
						self:ShowLinkerOptions();
					end);
					button:SetHeight(24);
					linkTable.button = button;
					itemList:AddItem(button);
					bDeleteFrame = false;
				else
					button:Remove();
				end;
			end;
		end;
	end;
	
	self.m_frame:SetHeight(self.m_frame:GetH() + 32);
	editor:AlignFrame(self.m_frame);
	
	if (bDeleteFrame) then
		self.m_frame:Remove();
		self.m_frame = nil;
	end;
end;

-- Called when a mouse button is pressed.
function TOOL:MouseButtonPress(button)
	local editor = self:GetEditor();
	local gridSize = editor:GetGridSize();
	
	if (button == MOUSE_LEFT) then
	end;
end;

-- Called when the game should be updated.
function TOOL:UpdateGame(deltaTime)
	local editor = self:GetEditor();
	local gridSize = editor:GetGridSize();
	
	local mousePosWorld = util.ScreenToWorld(util.GetMousePos());
	local object = (mousePosWorld and editor:GetAtPos(mousePosWorld, "Entity"));
	
	if (mousePosWorld and object) then
		mousePosWorld = util.SnapToGrid(mousePosWorld, gridSize);
		self.m_targetObject = object;
	else
		self.m_targetObject = nil;
	end;
end;

-- Called just before the lighting is drawn.
function TOOL:PreDrawLighting() end;

-- Called just after the lighting is drawn.
function TOOL:PostDrawLighting()
	local mousePosWorld = util.ScreenToWorld(util.GetMousePos());
	
	for outputIdx, v in pairs(self:GetEditor():GetLinks()) do
		local outputEntity = entities.GetByIndex(tonumber(outputIdx));
		
		if (outputEntity) then
			local outputPos = outputEntity:GetCenter();
			
			for outputName, v2 in pairs(v) do
				for inputIdx, v3 in pairs(v2) do
					local inputEntity = entities.GetByIndex(tonumber(inputIdx));
					
					if (inputEntity) then
						local inputPos = inputEntity:GetCenter();
						
						for inputKey, inputTab in pairs(v3) do
							if (mousePosWorld) then
								local distance = util.LineToPosDist(outputPos, inputPos, mousePosWorld);
								
								if (distance <= 4 or (inputTab.button and inputTab.button:IsValid() and inputTab.button:GetHovered())) then
									render.DrawLine(outputPos.x, outputPos.y, inputPos.x, inputPos.y, Color(1, 1, 0, 1));
									
									draw.ShadowedText("VerdanaTiny", outputPos.x, outputPos.y - 24,
										outputEntity:GetClass()..":"..outputName,
										Color(1, 1, 1, 1), Color(0, 0, 0, 0.8), true, true, true
									);
									
									draw.ShadowedText("VerdanaTiny", inputPos.x, inputPos.y - 24,
										inputEntity:GetClass().."->"..inputTab.inputName.."("..inputTab.argString..")",
										Color(1, 1, 1, 1), Color(0, 0, 0, 0.8), true, true, true
									);
								else
									render.DrawLine(outputPos.x, outputPos.y, inputPos.x, inputPos.y, Color(1, 1, 1, 1));
								end;
							end;
						end;
					end;
				end;
			end;
		end;
	end;
	
	if (self.m_targetObject) then
		local rectangle = self.m_targetObject:GetWorldRect();
		
		render.DrawBox(
			rectangle.x,
			rectangle.y,
			rectangle.w,
			rectangle.h,
			Color(0, 0, 1, 1)
		);
	end;
	
	if (not self.m_selection) then return; end;
	
	local object = self.m_selection.object;
	local rectangle = object:GetWorldRect();
	
	render.DrawBox(
		rectangle.x,
		rectangle.y,
		rectangle.w,
		rectangle.h,
		Color(0, 1, 0, 1)
	);
	
	if (self.m_selection.output) then
		local outputEntity = self.m_selection.entity;
		local outputPos = outputEntity:GetCenter();
		
		if (mousePosWorld) then
			render.DrawLine(outputPos.x, outputPos.y, mousePosWorld.x, mousePosWorld.y, Color(0, 1, 0, 1));
			
			draw.ShadowedText("VerdanaTiny", mousePosWorld.x, mousePosWorld.y - 24,
				"Select an entity to output to...", Color(1, 1, 1, 1), Color(0, 0, 0, 0.8), true, true, true);
		end;
	end;
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