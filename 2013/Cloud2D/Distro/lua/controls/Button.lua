--[[
	© 2011-2012 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
	Conna Wiles (connawiles@gmail.com)
--]]

-- Called when the size of the control is based on it's contents.
function CONTROL:OnSizeToContents()
	local textInset = self.m_iTextInset;
	local height = self.m_label:GetH() + 16;
	
	if (self.m_icon) then
		textInset = textInset + self.m_icon:GetW() + 8;
		
		if (self.m_icon:GetH() > height) then
			height = self.m_icon:GetH() + 4;
		end;
	end;
	
	return self.m_label:GetW() + textInset + 16, height;
end;

-- Called when the control's layout should be performed.
function CONTROL:OnPerformLayout()
	local textInset = self.m_iTextInset;
	
	if (self.m_icon) then
		self.m_icon:SetPos(8, (self:GetH() / 2) - (self.m_icon:GetH() / 2));
		textInset = textInset + self.m_icon:GetW() + 8;
	end;
	
	if (not self.m_bCentered) then
		self.m_label:SetPos(textInset, self:GetH() / 2);
	else
		self.m_label:SetPos(self:GetW() / 2, self:GetH() / 2);
	end;
end;

-- Called when the mouse is released.
function CONTROL:OnMouseButtonRelease(button, x, y)
	if (button == MOUSE_LEFT) then
		self:SetSuppressed(false);
		
		local callback = self:GetCallback();
		
		if (callback) then
			callback();
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
	self.m_label = controls.Create("Label", self);
	self.m_label:SetVertAlign(5);
	self.m_label:SetText("Button");
	self.m_label:SetPos(8, 8);
	
	self:SetDrawBackground(true);
	self:SetTextInset(8);
	self:SetCentered(true);
	self:SetColor(Color(0.6, 0.6, 0.6, 1));
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
	
	if (self:GetSuppressed()) then
		x = x + 1; y = y + 1;
		height = height - 2;
		width = width - 2;
	end;
	
	draw.StyledBox(x, y, width, height, color);
end;

-- A function to set the control's text color.
function CONTROL:SetTextColor(color, shadowColor)
	self.m_label:SetShadowColor(shadowColor);
	self.m_label:SetColor(color);
end;

-- A function to set whether the control's text is centered.
function CONTROL:SetCentered(bCentered)
	if (bCentered) then
		self.m_label:SetHorizAlign(5);
	else
		self.m_label:SetHorizAlign(4);
	end;
	
	self.m_bCentered = bCentered;
end;

-- A function to get whether the control's text is centered.
function CONTROL:IsCentered()
	return self.m_bCentered;
end;

-- A function to set the control icon.
function CONTROL:SetIcon(material)
	self.m_icon = controls.Create("Image", self);
	self.m_icon:SetMaterial(material, true);
	
	self:InvalidateLayout();
end;

-- A function to set the control text.
function CONTROL:SetText(text)
	self.m_label:SetText(text);
end;

-- A function to get the control text.
function CONTROL:GetText()
	return self.m_label:GetText();
end;

-- A function to set the control font.
function CONTROL:SetFont(font)
	self.m_label:SetFont(font);
end;

-- A function to get the control's label.
function CONTROL:GetLabel()
	return self.m_label;
end;

util.AddAccessor(CONTROL, "DrawBackground", "m_bDrawBackground");
util.AddAccessor(CONTROL, "Suppressed", "m_bSuppressed");
util.AddAccessor(CONTROL, "TextInset", "m_iTextInset");
util.AddAccessor(CONTROL, "Callback", "m_callback");
util.AddAccessor(CONTROL, "Hovered", "m_bHovered");