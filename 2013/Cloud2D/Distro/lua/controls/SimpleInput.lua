--[[
	© 2011-2012 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
	Conna Wiles (connawiles@gmail.com)
--]]

-- Called when the size of the control is based on it's contents.
function CONTROL:OnSizeToContents()
	local height = self.m_label:GetH() + 16;
	return self:GetW(), height;
end;

-- Called when the control's layout should be performed.
function CONTROL:OnPerformLayout()
	self.m_label:SetPos(8, self:GetH() / 2);
end;

-- Called when the mouse enters the control.
function CONTROL:OnMouseEnter(x, y)
	cursor.Set(CURSOR_IBEAM);
	self:SetHovered(true);
end;

-- Called when the mouse leaves. the control.
function CONTROL:OnMouseLeave(x, y)
	cursor.MakeDefault();
	self:SetHovered(false);
end;

-- Called when the control is removed.
function CONTROL:OnRemove()
	if (self:GetHovered() or self:IsFocused()) then
		cursor.MakeDefault();
	end;
end;

-- Called when the control has initialized.
function CONTROL:OnInitialize(arguments)
	self.m_label = controls.Create("Label", self);
	self.m_label.m_iCaretPos = 0;
	self.m_label.GetCaretPos = function(label)
		if (string.len(label:GetText()) >= self.m_label.m_iCaretPos) then
			return self.m_label.m_iCaretPos;
		end;
		
		return string.len(label:GetText());
	end;
	self.m_label.OnGetClipBoundries = function(label)
		local boundries = {
			x = self:GetX() + 7,
			y = (label:GetY() - label:GetH() / 2),
			w = label:GetW(),
			h = label:GetH()
		};
		
		return boundries;
	end;
	self.m_label:SetVertAlign(5);
	self.m_label:SetShadowColor(Color(0, 0, 0, 0.8));
	self.m_label:SetColor(Color(1, 1, 1, 1));
	self.m_label:SetText("");
	self.m_label:SetPos(8, 8);
	
	self:SetDrawBackground(true);
	self:SetColor(Color(0.5, 0.5, 0.5, 1));
	self:SetHeight(26);
	self.m_fNextType = time.CurTime() + 1;
end;

-- Called when a key is released.
function CONTROL:OnKeyRelease(key, str)
	local bIsCtrl = inputs.IsKeyDown(KEY_LCONTROL);
	
	if (bIsCtrl and key == KEY_X) then
		self.m_label:SetText("");
		return true;
	elseif (bIsCtrl and key == KEY_A) then
		self.m_label:SelectText(0, string.len(self.m_label:GetText()));
		return true;
	end;
	
	if (key == KEY_ENTER or key == KEY_NUMPAD_ENTER) then
		self:SetFocused(false);
		return true;
	end;
	
	local keyName = util.GetKeyByID(key, inputs.IsKeyDown(KEY_LSHIFT));
	
	if (keyName and (not self.m_bNumbersOnly or (tonumber(keyName) or keyName == "."))) then
		if (self.m_label:GetSelected()) then
			self.m_label:DeleteSelectedText();
			self.m_label:SetSelected(nil);
		end;
		
		self.m_label:SetText(string.sub(self.m_label:GetText(), 0, self.m_label:GetCaretPos()) .. keyName .. string.sub(self.m_label:GetText(), self.m_label:GetCaretPos() + 1));
		self.m_label.m_iCaretPos = math.min(self.m_label:GetCaretPos() + 1, string.len(self.m_label:GetText()));
		self.m_fNextType = time.CurTime() + 0.1;
		
		return true;
	end;
end;

-- Called when a key is pressed.
function CONTROL:OnKeyPress(key, str)
	if ((key == KEY_BACKSPACE or key == KEY_DELETE) and self.m_label:GetCaretPos() > 0) then
		if (self.m_label:GetSelected()) then
			self.m_label:DeleteSelectedText();
			self.m_label:SetSelected(nil);
			return;
		end;
		
		self.m_label:SetText(string.sub(self.m_label:GetText(), 0, self.m_label:GetCaretPos() - 1)..string.sub(self.m_label:GetText(), self.m_label:GetCaretPos() + 1));
		
		if (self.m_label:GetCaretPos() == string.len(self.m_label:GetText())) then
			self.m_label.m_iCaretPos = math.max(self.m_label:GetCaretPos(), 0);
		else
			self.m_label.m_iCaretPos = math.max(self.m_label:GetCaretPos() - 1, 0);
		end;
		
		return true;
	elseif (key == KEY_LEFT) then
		if (inputs.IsKeyDown(KEY_LSHIFT) and self.m_label:GetCaretPos() > 0) then
			if (self.m_label:GetSelected()) then
				self.m_label:MoveSelectedText(-1);
			else
				self.m_label:SelectText(self.m_label:GetCaretPos(), self.m_label:GetCaretPos() - 1);
			end;
		else
			local selected = self.m_label:GetSelected();
			if (selected) then
				self.m_label.m_iCaretPos = math.min(selected[1] + 1, string.len(self.m_label:GetText()));
			end;
			
			self.m_label:SetSelected(nil);
		end;
		
		self.m_label.m_iCaretPos = math.max(self.m_label:GetCaretPos() - 1, 0);
		
		return true;
	elseif (key == KEY_RIGHT) then
		if (inputs.IsKeyDown(KEY_LSHIFT) and self.m_label:GetCaretPos() < string.len(self.m_label:GetText())) then
			if (self.m_label:GetSelected()) then
				self.m_label:MoveSelectedText(1);
			else
				self.m_label:SelectText(self.m_label:GetCaretPos(), self.m_label:GetCaretPos() + 1);
			end;
		else
			local selected = self.m_label:GetSelected();
			if (selected) then
				self.m_label.m_iCaretPos = math.max(selected[2] - 1, 0);
			end;
			
			self.m_label:SetSelected(nil);
		end;
		
		self.m_label.m_iCaretPos = math.min(self.m_label:GetCaretPos() + 1, string.len(self.m_label:GetText()));
	end;
	
	return true;
end;

-- Called when a mouse button  is pressed.
function CONTROL:OnMouseButtonPress(button, x, y)
	self.m_label:SetSelected(nil);
end;

-- Called when the control loses focus.
function CONTROL:OnLoseFocus()
	if (self:GetText() == "" and self.m_sHint) then
		self:SetText(self.m_sHint);
	end;
	
	if (self.m_callback) then
		if (not self:IsHint()) then
			self.m_callback(self:GetText());
		else
			self.m_callback("");
		end;
	end;
	
	self.m_label:SetSelected(nil);
end;

-- Called when the control gets focus.
function CONTROL:OnGetFocus()
	if (self:GetText() == self.m_sHint) then
		self:SetText("");
	end;
	
	self.m_label.m_iCaretPos = string.len(self.m_label:GetText());
	self.m_label:SelectText(0, self.m_label.m_iCaretPos);
end;

-- Called when the control should be drawn.
function CONTROL:OnDraw()
	local height = self:GetH();
	local width = self:GetW();
	local color = self:GetColor();
	local x, y = self:GetX(), self:GetY();
	
	if (not self:IsFocused() and self.m_sHint) then
		self.m_label:SetOverrideAlpha(0.8);
		
		if (self:GetText() == "") then
			self:SetText(self.m_sHint);
		end;
	else
		self.m_label:SetOverrideAlpha(nil);
	end;
	
	if (self:IsFocused()) then
		color = Color(
			math.min(color.r + 0.01, 1),
			math.min(color.g + 0.15, 1),
			math.min(color.b + 0.2, 1),
			color.a
		);
	elseif (self:GetHovered()) then
		color = Color(
			math.min(color.r + 0.1, 1),
			math.min(color.g + 0.1, 1),
			math.min(color.b + 0.1, 1),
			color.a
		);
	end;
	
	draw.StyledBox(x, y, width, height, color);
	
	if (self:IsFocused()) then
		local labelW = self.m_label:GetW() + 2;
		
		if (labelW > self:GetW() - 16) then
			self.m_label:SetX(-(labelW - (self:GetW() - 8)));
		else
			self.m_label:SetX(8);
		end;
	end;
end;

-- A function to set the control's text color.
function CONTROL:SetTextColor(color, shadowColor, bOverride)
	self.m_label:SetShadowColor(shadowColor);
	self.m_label:SetColor(color);
end;

-- A function to set the control text.
function CONTROL:SetText(text)
	self.m_label:SetText(text);
end;

-- A function to get whether the control contains the default value.
function CONTROL:IsHint()
	return (self:GetText() == self.m_sHint);
end;

-- A function to get the control's value.
function CONTROL:GetValue()
	if (self.m_bNumbersOnly) then
		return tonumber(self:GetText()) or 0;
	else
		return self:GetText();
	end;
end;

-- A function to get the control text.
function CONTROL:GetText()
	return self.m_label:GetText();
end;

-- A function to get the control's label.
function CONTROL:GetLabel()
	return self.m_label;
end;

util.AddAccessor(CONTROL, "DrawBackground", "m_bDrawBackground");
util.AddAccessor(CONTROL, "NumbersOnly", "m_bNumbersOnly");
util.AddAccessor(CONTROL, "Callback", "m_callback");
util.AddAccessor(CONTROL, "Hovered", "m_bHovered");
util.AddAccessor(CONTROL, "Hint", "m_sHint");