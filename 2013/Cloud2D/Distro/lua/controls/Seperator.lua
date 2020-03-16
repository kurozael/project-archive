--[[
	© 2011-2012 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
	Conna Wiles (connawiles@gmail.com)
--]]

-- Called when the control should be drawn.
function CONTROL:OnDraw()
	local height = self:GetH();
	local width = self:GetW();
	local x, y = self:GetX(), self:GetY();
	
	render.DrawLine(x, y, x + width, y + 1, Color(1, 1, 1, 0.8));
	render.DrawLine(x, y + 1, x + width, y + 2, Color(0, 0, 0, 0.8));
end;

-- Called when the control has initialized.
function CONTROL:OnInitialize(arguments) end;