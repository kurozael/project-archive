--[[
	© 2011-2012 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
	Conna Wiles (connawiles@gmail.com)
--]]

-- Called when the control's layout should be performed.
function CONTROL:OnPerformLayout()
	local width = self:GetW();
	local height = self:GetH();
	local scroll = self.m_iScroll / self.m_iCanvasSize;
	local barSize = math.max(self:GetBarScale() * (height - (width * 2)), 10);

	scroll = scroll * (height - (width * 2) - barSize);

	self.m_buttonUp:SetPos(0, 0, width, width);
	self.m_buttonUp:SetSize(width, width);
	self.m_buttonDown:SetPos(0, height - width, width, width)
	self.m_buttonDown:SetSize(width, width);
	self.m_buttonGrip:SetPos(0, width + scroll);
	self.m_buttonGrip:SetSize(width, barSize);
end;

-- Called when the mouse is pressed.
function CONTROL:OnMouseButtonPress(button, x, y)
	if (button == MOUSE_LEFT) then
		local mousePos = util.GetMousePos();
		
		if (mousePos.y > self.m_buttonGrip:GetY()) then
			self:SetScroll(self.m_iScroll + self.m_iBarSize);
		else
			self:SetScroll(self.m_iScroll - self.m_iBarSize);
		end;
	end;
end;

-- Called when the control has initialized.
function CONTROL:OnInitialize(arguments)
	self.m_iCanvasSize = 1;
	self.m_bDragging = false;
	self.m_iBarSize = 1;
	self.m_iScroll = 0;
	
	self.m_buttonUp = controls.Create("Button", self);
	self.m_buttonUp:SetText("");
	self.m_buttonUp:SetSize(16, 16);
	self.m_buttonUp:SetColor(Color(0.3, 0.3, 0.3, 1));
	self.m_buttonUp:SetCallback(function()
		self:AddScroll(-1);
	end);
	
	self.m_buttonDown = controls.Create("Button", self);
	self.m_buttonDown:SetText("");
	self.m_buttonDown:SetSize(16, 16);
	self.m_buttonDown:SetColor(Color(0.3, 0.3, 0.3, 1));
	self.m_buttonDown:SetCallback(function()
		self:AddScroll(1);
	end);
	
	self.m_buttonGrip = controls.Create("ScrollBarGrip", self);
	self:SetColor(Color(0.4, 0.4, 0.4, 0.75));
end;

-- Called every frame for the control.
function CONTROL:OnUpdate(deltaTime)
	local mousePos = util.GetMousePos();
	
	if (not self.m_bDragging) then
		return;
	end;
	
	local y = (mousePos.y - self:GetY()) - self.m_buttonUp:GetH() - self.m_holdPos;
	local trackSize = self:GetH() - self:GetW() * 2 - self.m_buttonGrip:GetH();
		y = y / trackSize;
	self:SetScroll(y * self.m_iCanvasSize);
end;

-- Called when the control is drawn.
function CONTROL:OnDraw()
	local height = self:GetH();
	local width = self:GetW();
	local color = self:GetColor();
	local x, y = self:GetX(), self:GetY();
	
	render.DrawFill(x, y, width, height, self:GetColor());
end;

-- A function to get the bar scale.
function CONTROL:GetBarScale()
	return self.m_iBarSize / (self.m_iCanvasSize + self.m_iBarSize);
end;

-- A function to set up the control.
function CONTROL:SetUp(barSize, canvasSize)
	self.m_iBarSize = barSize;
	self.m_iCanvasSize = canvasSize - barSize;
	self:InvalidateLayout();
end;

-- A function to add to the control's scroll.
function CONTROL:AddScroll(delta)
	local oldScroll = self.m_iScroll;
		delta = delta * 25;
		self:SetScroll(oldScroll + delta);
	return (oldScroll ~= self.m_iScroll);
end;

-- A function to set the control's scroll.
function CONTROL:SetScroll(scroll)
	self.m_iScroll = math.Clamp(scroll, 0, self.m_iCanvasSize);
	self:InvalidateLayout();
	
	local parent = self:GetParent();
	
	if (parent.OnVerticalScroll) then
		parent:OnVerticalScroll(self:GetOffset());
	else
		parent:InvalidateLayout();
	end;
end;

-- A function to get the control's scroll.
function CONTROL:GetScroll()
	return self.m_iScroll;
end;

-- A function to get the control offset.
function CONTROL:GetOffset()
	return self.m_iScroll * -1;
end;

-- A function to ungrip the control.
function CONTROL:Ungrip()
	self.m_bDragging = false;
end;

-- A function to grip the control.
function CONTROL:Grip()
	local mousePos = util.GetMousePos();
	
    if (self.m_iBarSize == 0) then
		return;
	end;

    self.m_bDragging = true;
    self.m_holdPos = mousePos.y - self.m_buttonGrip:GetY();
end;