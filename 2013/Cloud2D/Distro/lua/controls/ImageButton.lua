--[[
	© 2011-2012 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
	Conna Wiles (connawiles@gmail.com)
--]]

-- Called when the mouse is released.
function CONTROL:OnMouseButtonRelease(button, x, y)
	if (button == MOUSE_LEFT) then
		self:SetSuppressed(false);
		
		if (self:IsPosInside(x, y)) then
			local callback = self:GetCallback();
			
			if (callback) then
				callback();
			end;
		end;
	end;
end;

-- Called when the mouse is pressed.
function CONTROL:OnMouseButtonPress(button, x, y)
	if (button == MOUSE_LEFT) then
		self:SetSuppressed(true);
	end;
end;

-- Called when the mouse enters the control.
function CONTROL:OnMouseEnter(x, y)
	self:SetHovered(true);
end;

-- Called when the mouse leaves. the control.
function CONTROL:OnMouseLeave(x, y)
	self:SetHovered(false);
end;

-- Called when the control has initialized.
function CONTROL:OnInitialize(arguments)
	self:SetMaterial("missing");
	self:SetSize(32, 32);
end;

-- Called when the control should be drawn.
function CONTROL:OnDraw()
	local borderColor = self:GetBorderColor();
	local hoverColor = self:GetHoverColor();
	local height = self:GetH();
	local width = self:GetW();
	local color = self:GetColor();
	local x, y = self:GetX(), self:GetY();
	
	if (self:GetSuppressed()) then
		x = x + 2; y = y + 2;
		height = height - 4;
		width = width - 4;
	end;
	
	render.DrawImage(self.m_image, x, y,
		width, height, color
	);
	
	if (self:GetHovered() and hoverColor) then
		render.DrawImage(self.m_image, x, y,
			width, height, hoverColor
		);
	end;
	
	if (borderColor) then
		render.DrawBox(x, y, width, height, borderColor);
	end;
end;

-- A function to set the control's material.
function CONTROL:SetMaterial(material)
	self.m_image = util.GetImage(material);
	self.m_sMaterial = material;
end;

-- A function to get the control's material.
function CONTROL:GetMaterial()
	return self.m_sMaterial;
end;

util.AddAccessor(CONTROL, "BorderColor", "m_borderColor");
util.AddAccessor(CONTROL, "Suppressed", "m_bSuppressed");
util.AddAccessor(CONTROL, "HoverColor", "m_hoverColor");
util.AddAccessor(CONTROL, "Callback", "m_callback");
util.AddAccessor(CONTROL, "Hovered", "m_bHovered");