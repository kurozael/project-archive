--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
--]]

-- Called when the size of the control is based on it's contents.
function CONTROL:OnSizeToContents()
	local fontSize = util.GetTextSize( "Default", self:GetText() );
	return fontSize.w + 8, fontSize.h + 8;
end;

-- Called when the control has initialized.
function CONTROL:OnInitialize(arguments)
	self:SetColor( Color(1, 0.95, 0.7, 0.9) );
	self:SetText("ToolTip");
end;

-- A function to update the control's position.
function CONTROL:UpdatePosition()
	local mousePos = util.GetMousePos();
	self:SetPos( mousePos.x - (self:GetW() * 0.25),
		mousePos.y - self:GetH() - 24
	);
end;

-- Called every frame for the control.
function CONTROL:OnUpdate(deltaTime)
	self:UpdatePosition();
end;

-- Called when the control is drawn.
function CONTROL:OnDraw()
	local whiteColor = Color(1, 1, 1, 1);
	local darkColor = Color(0.4, 0.4, 0.4, 1);
	local height = self:GetH();
	local width = self:GetW();
	local color = self:GetColor();
	local x, y = self:GetX(), self:GetY();
	local text = self:GetText();
	
	if (text and text ~= "") then
		g_Render:DrawFill(x, y, width, height, color);
		g_Render:DrawBox(x, y, width, height, darkColor);
		g_Render:DrawBox(x + 1, y + 1, width - 2, height - 2, whiteColor);
		
		draw.ShadowedText("Default", x + 4, y + 4, text, darkColor, whiteColor);
	end;
end;

-- A function to set the text of the control.
function CONTROL:SetText(text)
	self.m_sText = text;
	self:SizeToContents();
end;

-- A function to get the text of the control.
function CONTROL:GetText()
	return self.m_sText;
end;