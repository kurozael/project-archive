--[[
	© 2011-2012 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
	Conna Wiles (connawiles@gmail.com)
--]]

CONTROL.m_sBaseClass = "Button";

-- Called when the control's layout should be performed.
function CONTROL:OnPerformLayout()
	self:BaseClass().OnPerformLayout(self);
	
	if (self.m_arrowImage) then
		self.m_arrowImage:SetPos(self:GetW() - 18, 1);
	end;
end;

-- Called when the mouse is released.
function CONTROL:OnMouseButtonRelease(button, x, y)
	self:BaseClass().OnMouseButtonRelease(self, button, x, y);
	
	if (button == MOUSE_LEFT) then
		self:GetParent():Close();
	end;
end;

-- Called when the mouse enters the control.
function CONTROL:OnMouseEnter(x, y)
	self:BaseClass().OnMouseEnter(self, x, y);
	
	if (self.m_subMenu) then
		self:GetParent():OpenSubMenu(self, self.m_subMenu);
	end;
end;

-- A function to set the control's sub menu.
function CONTROL:SetSubMenu(subMenu)
	self.m_subMenu = subMenu;
	
	if (not self.m_arrowImage) then
		self.m_arrowImage = controls.Create("Image", self);
		self.m_arrowImage:SetMaterial("controls/arrow");
		self.m_arrowImage:SetSize(16, 16);
		self.m_arrowImage:SetPos(self:GetW() - 18, 1);
	end;
end;

-- Called when the control has initialized.
function CONTROL:OnInitialize(arguments)
	self:BaseClass().OnInitialize(self, arguments);
	self:SetTextColor(Color(0.4, 0.4, 0.4, 1), Color(1, 1, 1, 1));
	self:SetCentered(false);
	self:SetColor(Color(1, 0.95, 0.7, 1));
end;

-- Called when the control should be drawn.
function CONTROL:OnDraw()
	local height = self:GetH();
	local width = self:GetW();
	local color = self:GetColor();
	local x, y = self:GetX(), self:GetY();
	
	if (self:GetHovered()) then
		color = Color(
			math.min(color.r + 0.1, 1),
			math.min(color.g + 0.1, 1),
			math.min(color.b + 0.1, 1),
			color.a
		);
	end;
	
	render.DrawFill(x, y, width, height, color);
	render.DrawLine(x, y, x + width, y, Color(0.4, 0.4, 0.4, 1));
	render.DrawLine(x, y + 1, x + width, y + 1, Color(1, 1, 1, 1));
end;