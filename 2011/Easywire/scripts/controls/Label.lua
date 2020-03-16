--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
--]]

-- Called when the size of the control is based on it's contents.
function CONTROL:OnSizeToContents()
	local fontSize = util.GetTextSize( self:GetFont(), self:GetText() );
	return fontSize.w, fontSize.h;
end;

-- Called when the control has initialized.
function CONTROL:OnInitialize(arguments)
	self:SetHorizAlign(4);
	self:SetVertAlign(8);
	self:SetShadowColor( Color(0, 0, 0, 1) );
	self:SetClickable(false);
	self:SetColor( Color(1, 1, 1, 1) );
	self:SetFont("Default");
	self:SetText("");
end;

-- A function to get the selected direction.
function CONTROL:GetSelectedDir()
	local defaultSelected = self:GetDefaultSelected();
	local selected = self:GetSelected();
	
	if (selected and defaultSelected) then
		if ( selected[1] < defaultSelected[1] ) then
			return -1;
		elseif ( selected[2] > defaultSelected[1] ) then
			return 1;
		else
			return 0;
		end;
	end;
	
	return 0;
end;

-- Called when the selected text is deleted.
function CONTROL:OnDeleteSelectedText(text, selected, direction) end;

-- A function to delete the selected text.
function CONTROL:DeleteSelectedText()
	local direction = self:GetSelectedDir();
	local selected = self:GetSelected();
	local text = self:GetText();
	
	if ( selected and selected[1] ~= selected[2] ) then
		local second = string.sub( text, math.min(selected[2] + 1, string.len(text) + 1) );
		local first = string.sub( text, 0, math.max(selected[1], 0) );
		
		self:SetText(first..second, true);
		self:OnDeleteSelectedText(first..second, selected, direction);
	end;
end;

-- A function to move the selected text.
function CONTROL:MoveSelectedText(amount)
	local defaultSelected = self:GetDefaultSelected();
	local textLength = string.len( self:GetText() );
	local selected = self:GetSelected();
	local interest = nil;
	
	if (selected and defaultSelected) then
		if (amount > 0) then
			if ( selected[1] == defaultSelected[1] ) then
				interest = 2;
			else
				interest = 1;
			end;
		elseif ( selected[2] == defaultSelected[1] ) then
			interest = 1;
		else
			interest = 2;
		end;
		
		if (interest) then
			selected[interest] = selected[interest] + amount;
		end;
		
		selected[1] = math.min(math.max(selected[1], 0), textLength);
		selected[2] = math.min(math.max(selected[2], 0), textLength);
		
		if ( selected[1] == selected[2] ) then
			self:SelectText(false);
		end;
	end;
	
	if (selected and interest) then
		return selected[interest];
	end;
end;

-- A function to get the caret position.
function CONTROL:GetCaretPos() end;

-- Called when the text should be modified.
function CONTROL:OnModifyText(text)
	return text;
end;

-- Called when the position should be modified.
function CONTROL:OnModifyPos(x, y)
	return x, y;
end;

-- A function to select text.
function CONTROL:SelectText(start, finish)
	local textLength = string.len( self:GetText() );
	
	if (start and finish) then
		if (finish < start) then
			start = math.min(math.max(start, 0), textLength);
			finish = math.min(math.max(finish, 0), textLength);
			
			self.selected = {finish, start};
			self.defaultSelected = {start, finish};
		else
			start = math.min(math.max(start, 0), textLength);
			finish = math.min(math.max(finish, 0), textLength);
			
			self.selected = {start, finish};
			self.defaultSelected = {start, finish};
		end;
	else
		self.defaultSelected = nil;
		self.selected = nil;
	end;
end;

-- Called when the text is set.
function CONTROL:OnTextSet(text) end;

-- Called when the control should be drawn.
function CONTROL:OnDraw()
	local shadowColor = self:GetShadowColor();
	local horizAlign = self:GetHorizAlign();
	local vertAlign = self:GetVertAlign();
	local caretPos = self:GetCaretPos();
	local selected = self:GetSelected();
	local height = self:GetH();
	local parent = self:GetParent();
	local width = self:GetW();
	local text = self:OnModifyText( self:GetText() );
	local font = self:GetFont();
	local y = self:GetY();
	local x = self:GetX();
	
	if (horizAlign == 5) then
		x = x - (width / 2);
	elseif (horizAlign == 6) then
		x = x + width;
	end;
	
	if (vertAlign == 5) then
		y = y - (height / 2);
	elseif (vertAlign == 2) then
		y = y + height;
	end;

	x, y = self:OnModifyPos(x, y);
	
	if (shadowColor) then
		draw.ShadowedText(font, x, y, text, self.m_color, shadowColor);
	else
		draw.SimpleText(font, x, y, text, self.m_color);
	end;
	
	if (caretPos) then
		local focused = self:IsFocused();
		
		if (parent) then
			focused = parent:IsFocused();
		end;
		
		if (math.abs( math.sin(g_Time:CurTime() * 4) ) <= 0.5 or not focused) then
			local fontSize = util.GetTextSize( font, string.sub(text, 0, caretPos) );
			local realY = self:getY() - (height / 2);
			
			g_Render:DrawLine( x + fontSize.w, realY, x + fontSize.w, realY + fontSize.h, Color(0, 0, 0, 1) );
		end;
	end;
	
	if (selected) then
		local fontSize = util.GetTextSize( font, string.sub( text, selected[1] + 1, selected[2] ) );
		local fontSizeX = util.GetFontSize( font, string.sub( text, 0, selected[1] ) );
		
		g_Render:DrawFill( x + fontSizeX.w, self:GetY() - (height / 2), fontSize.w, fontSize.h, Color(0.2, 0.2, 0.8, 0.4) );
	end;
end;

-- A function to set the text of the control.
function CONTROL:SetText(text, noCallback)
	self.m_sText = text;
	self:SelectText(false);
	self:SizeToContents();
	
	if (not noCallback) then
		self:OnTextSet(text);
	end;
end;

-- A function to get the text of the control.
function CONTROL:GetText()
	return self.m_sText;
end;

-- Create some accessor functions.
util.AddAccessor(CONTROL, "DefaultSelected", "m_defaultSelected");
util.AddAccessor(CONTROL, "ShadowColor", "m_shadowColor");
util.AddAccessor(CONTROL, "HorizAlign", "m_iHorizAlign");
util.AddAccessor(CONTROL, "VertAlign", "m_iVertAlign");
util.AddAccessor(CONTROL, "Selected", "m_bSelected");
util.AddAccessor(CONTROL, "Font", "m_sFont");