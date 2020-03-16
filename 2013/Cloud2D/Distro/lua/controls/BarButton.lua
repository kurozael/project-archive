--[[
	© 2011-2012 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
	Conna Wiles (connawiles@gmail.com)
--]]

CONTROL.m_sBaseClass = "Button";

-- Called when the control has initialized.
function CONTROL:OnInitialize(arguments)
	self:BaseClass().OnInitialize(self, arguments);
	self:SetTextColor(Color(0.3, 0.3, 0.3, 1), Color(1, 1, 1, 1));
	self:SetColor(Color(1, 1, 1, 1));
	self.m_label:SetFont("VerdanaTiny");
end;

-- Called when the control should be drawn.
function CONTROL:OnDraw()
	local height = self:GetH();
	local width = self:GetW();
	local color = self:GetColor();
	local x, y = self:GetX(), self:GetY();
	
	if (self:GetHovered()) then
		color = Color(
			math.max(color.r - 0.1, 0),
			math.max(color.g - 0.1, 0),
			math.max(color.b - 0.1, 0),
			color.a
		);
	end;
	
	render.DrawFill(x, y, width, height, color);
end;