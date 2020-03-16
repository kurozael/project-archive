--[[
	� 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self:SetPos(4, 4);
	self:SetSize(self:GetWide() - 8, 24);
	self:SetBackgroundColor( Color(139, 174, 179, 255) );
	
	self.icon = vgui.Create("DImage", self);
	self.icon:SetImage("gui/silkicons/comment");
	self.icon:SizeToContents();
	
	self.label = vgui.Create("DLabel", self);
	self.label:SetText("");
	self.label:SetTextColor( CloudScript.option:GetColor("white") );
	self.label:SetExpensiveShadow( 1, Color(0, 0, 0, 150) );
end;

-- Called when the layout should be performed.
function PANEL:PerformLayout()
	self.icon:SetPos(4, 4);
	
	if (self.textToLeft) then
		if ( self.icon:IsVisible() ) then
			self.label:SetPos(self.icon.x + 8, self:GetTall() / 2 - self.label:GetTall() / 2);
		else
			self.label:SetPos(8, self:GetTall() / 2 - self.label:GetTall() / 2);
		end;
	else
		self.label:SetPos(self:GetWide() / 2 - self.label:GetWide() / 2, self:GetTall() / 2 - self.label:GetTall() / 2);
	end;
	
	derma.SkinHook("Layout", "Panel", self);
end;

-- Called when the panel is painted.
function PANEL:Paint()
	if ( self:GetPaintBackground() ) then
		local width, height = self:GetSize();
		local x, y = 0, 0;
		
		if ( self:IsDepressed() ) then
			height = height - 4;
			width = width - 4;
			x = x + 2;
			y = y + 2;
		end;
		
		CloudScript:DrawSimpleGradientBox( 4, x, y, width, height, self:GetBackgroundColor() );
		
		if ( self:IsButton() and self:IsHovered() ) then
			CloudScript:DrawSimpleGradientBox( 4, x, y, width, height, Color(255, 255, 255, 50) );
		end;
	end	
	
	return true;
end;

-- A function to set the text to the left.
function PANEL:SetTextToLeft()
	self.textToLeft = true;
end;

-- A function to set the text of the panel.
function PANEL:SetText(text)
	self.label:SetText(text);
	self.label:SizeToContents();
end;

-- A function to set whether the panel is a button.
function PANEL:SetButton(isButton)
	self.isButton = isButton;
end;

-- A function to get whether the panel is a button.
function PANEL:IsButton()
	return self.isButton;
end;

-- A function to set whether the panel is depressed.
function PANEL:SetDepressed(isDepressed)
	self.isDepressed = isDepressed;
end;

-- A function to get whether the panel is depressed.
function PANEL:IsDepressed()
	return self.isDepressed;
end;

-- A function to set whether the panel is hovered.
function PANEL:SetHovered(isHovered)
	self.isHovered = isHovered;
end;

-- A function to get whether the panel is hovered.
function PANEL:IsHovered()
	return self.isHovered;
end;

-- A function to set the text color of the panel.
function PANEL:SetTextColor(color)
	self.label:SetTextColor(color);
end;

-- Called when the mouse is pressed on the panel.
function PANEL:OnMousePressed(mouseCode)
	if ( self:IsButton() ) then
		self:SetDepressed(true);
		self:MouseCapture(true);
	end;
end;

-- Called when the mouse is released on the panel.
function PANEL:OnMouseReleased(mouseCode)
	if ( self:IsButton() and self:IsDepressed()
	and self:IsHovered() ) then
		if (self.DoClick) then
			CloudScript.option:PlaySound("click");
			self:DoClick();
		end;
	end;
	
	self:SetDepressed(false);
	self:MouseCapture(false);
end;

-- Called when the mouse has entered the panel.
function PANEL:OnCursorEntered()
	self:SetHovered(true);
end;

-- Called when the mouse has entered the panel.
function PANEL:OnCursorExited()
	self:SetHovered(false);
end;

-- A function to set whether the icon is shown.
function PANEL:SetShowIcon(showIcon)
	self.icon:SetVisible(showIcon);
end;

-- A function to set the icon.
function PANEL:SetIcon(icon)
	self.icon:SetImage(icon);
	self.icon:SizeToContents();
	self.icon:SetVisible(true);
end;

-- A function to set the panel's info color.
function PANEL:SetInfoColor(color)
	if (color == "red") then
		self:SetBackgroundColor( Color(179, 46, 49, 255) );
		self:SetIcon("gui/silkicons/exclamation");
	elseif (color == "orange") then
		self:SetBackgroundColor( Color(223, 154, 72, 255) );
		self:SetIcon("gui/silkicons/error");
	elseif (color == "green") then
		self:SetBackgroundColor( Color(139, 215, 113, 255) );
		self:SetIcon("gui/silkicons/check_on");
	elseif (color == "blue") then
		self:SetBackgroundColor( Color(139, 174, 179, 255) );
		self:SetIcon("gui/silkicons/information");
	else
		self:SetShowIcon(false);
		self:SetBackgroundColor(color);
	end;
end;
	
vgui.Register("cloud_InfoText", PANEL, "DPanel");