--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
--]]

-- Called when a mouse button is released.
function TOOL:MouseButtonRelease(button)
	if (button == MOUSE_LEFT) then
		local mousePosWorld = util.ScreenToWorld( util.GetMousePos() );
		local editor = self:GetEditor();
		local object = nil;
		
		if (mousePosWorld) then
			object = editor:GetAtPos(mousePosWorld);
		end;
		
		if (self.m_selection) then
			self.m_selection:SetSelected(false);
			self.m_selection = nil;
		end;
		
		if (object) then
			self.m_selection = object;
				self.m_selection:SetSelected(true);
			g_Sounds:PlaySound("click", 1);
		end;
	elseif (button == MOUSE_RIGHT and self.m_selection) then
		local menu = controls.Create("SimpleMenu");
			if (self.m_selection.OnSelectMenu) then
				self.m_selection:OnSelectMenu(menu);
			end;
			
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
		menu:Open();
	end;
end;

-- Called when a key is released.
function TOOL:KeyRelease(key)
	if (key == KEY_DELETE) then
		self:RemoveSelection();
	end;
end;

-- A function to remove the current selection.
function TOOL:RemoveSelection()
	if (not self.m_selection) then
		return;
	end;
	
	self.m_selection:SetSelected(false);
	self.m_selection:Remove();
	self.m_selection = nil;
end;

-- A function to send the current selection to the front.
function TOOL:SendToFront()
	if (self.m_selection) then
		self.m_selection:SendToFront();
	end;
end;

-- A function to send the current selection to the back.
function TOOL:SendToBack()
	if (self.m_selection) then
		self.m_selection:SendToBack();
	end;
end;

-- Called just after the lighting is drawn.
function TOOL:PostDrawLighting()
	if (self.m_selection) then
		local rectangle = self.m_selection:GetWorldRect();
		
		g_Render:DrawBox(
			rectangle.x,
			rectangle.y,
			rectangle.w,
			rectangle.h,
			Color(1, 0, 1, 0.5)
		);
	end;
end;

-- Called when the tool has become inactive.
function TOOL:OnInactive()
	if (self.m_selection) then
		self.m_selection:SetSelected(false);
		self.m_selection = nil;
	end;
end;

-- Called when the tool has become active.
function TOOL:OnActive()
	if (self.m_selection) then
		self.m_selection:SetSelected(false);
		self.m_selection = nil;
	end;
end;