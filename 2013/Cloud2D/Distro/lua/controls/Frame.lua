--[[
	© 2011-2012 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
	Conna Wiles (connawiles@gmail.com)
--]]

CONTROL.m_sBaseClass = "Panel";

-- Called when the control's layout should be performed.
function CONTROL:OnPerformLayout()
	self.m_button:SetPos(self:GetW() - 21, 5);
end;

-- Called when the control has initialized.
function CONTROL:OnInitialize(arguments)
	self:SetDraggable(true);
	self:SetColor(Color(0.1, 0.1, 0.1, 1));
	
	self.m_button = controls.Create("ImageButton", self);
	self.m_button:SetHoverColor(Color(1, 0, 0, 0.2));
	self.m_button:SetCallback(function() self:Remove(); end);
	self.m_button:SetMaterial("controls/close");
	self.m_button:SetSize(16, 16);
	
	self.m_label = controls.Create("Label", self);
	self.m_label:SetVertAlign(5);
	self.m_label:SetText(arguments[1] or "Frame");
	self.m_label:SetPos(8, 11);
end;

-- Called when the control is drawn.
function CONTROL:OnDraw()
	local height = self:GetH();
	local width = self:GetW();
	local color = self:GetColor();
	local x, y = self:GetX(), self:GetY();
	
	draw.StyledBox(x, y, width, height, color);
	draw.StyledBox(x + 2, y + 2, width - 4, 23, Color(0.2, 0.2, 0, 0.5), true);
	render.DrawLine(x + 1, y + 23, x + width - 2, y + 23, Color(0, 0, 0, 0.5));
	render.DrawLine(x + 1, y + 24, x + width - 2, y + 24, Color(1, 1, 1, 0.4));
end;

-- A function to hide the close button.
function CONTROL:HideCloseButton()
	self.m_button:SetVisible(false);
end;

-- A function to set the control title.
function CONTROL:SetTitle(title)
	self.m_label:SetText(title);
end;