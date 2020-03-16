--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
--]]

-- Called when the mouse is released.
function CONTROL:OnMouseButtonRelease(button, x, y)
	self.m_dragPos = nil;
end;

-- Called when the mouse is pressed.
function CONTROL:OnMouseButtonPress(button, x, y)
	if ( button == MOUSE_LEFT and self:GetDraggable() ) then
		local tX, tY = self:GetTopParent():GetPos(true);
		
		self.m_dragPos = {
			x = tX - x,
			y = tY - y
		};
	end;
end;

-- Called when the control has initialized.
function CONTROL:OnInitialize(arguments)
	self:SetDraggable(false);
	self:SetColor( Color(0.4, 0.4, 0.4, 1) );
end;

-- Called every frame for the control.
function CONTROL:OnUpdate(deltaTime)
	if (self.m_dragPos) then
		local mousePos = util.GetMousePos();
		local x = mousePos.x + self.m_dragPos.x;
		local y = mousePos.y + self.m_dragPos.y;
		
		self:GetTopParent():SetPos(x, y);
	end
end;

-- Called when the control is drawn.
function CONTROL:OnDraw()
	g_Render:DrawFill( self:GetX(), self:GetY(), self:GetW(), self:GetH(), self:GetColor() );
end;

util.AddAccessor(CONTROL, "Draggable", "m_bDraggable");