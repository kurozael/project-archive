--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
--]]

-- Called when the mouse is released.
function CONTROL:OnMouseButtonRelease(button, x, y)
	if (button == MOUSE_LEFT) then
		self:GetParent():Ungrip();
	end;
end;

-- Called when the mouse is pressed.
function CONTROL:OnMouseButtonPress(button, x, y)
	if (button == MOUSE_LEFT) then
		self:GetParent():Grip();
	end;
end;

-- Called when the control has initialized.
function CONTROL:OnInitialize(arguments)
	self:SetColor( Color(0.6, 0.6, 0.6, 1) );
end;

-- Called when the control is drawn.
function CONTROL:OnDraw()
	draw.StyledBox( self:GetX(), self:GetY(), self:GetW(), self:GetH(), self:GetColor() );
end;