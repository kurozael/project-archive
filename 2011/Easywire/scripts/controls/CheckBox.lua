--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
--]]

-- Called when the size of the control is based on it's contents.
function CONTROL:OnSizeToContents()
	self.m_label:SizeToContents();
	return self.m_label:GetW() + 24, 16;
end;

-- Called when the control has initialized.
function CONTROL:OnInitialize(arguments)
	self.m_button = controls.Create("ImageButton", self);
	self.m_button:SetHoverColor( Color(0.5, 1, 0.5, 0.4) );
	self.m_button:SetCallback(function()
		self:SetChecked( not self:IsChecked() );
	end);
	self.m_button:SetMaterial("controls/unchecked");
	self.m_button:SetSize(16, 16);
	
	self.m_label = controls.Create("Label", self);
	self.m_label:SetVertAlign(5);
	self.m_label:SetText(arguments[1] or "CheckBox");
	self.m_label:SetPos(24, 8);
	
	self.m_bIsChecked = false;
	
	self:SizeToContents();
end;

-- A function to set whether the control is checked.
function CONTROL:IsChecked()
	return self.m_bIsChecked;
end;

-- A function to set whether the control is checked.
function CONTROL:SetChecked(bIsChecked)
	self.m_bIsChecked = bIsChecked;
	
	if (bIsChecked) then
		self.m_button:SetMaterial("controls/checked");
	else
		self.m_button:SetMaterial("controls/unchecked");
	end;
	
	local callback = self:GetCallback();
	
	if (callback) then
		callback(bIsChecked);
	end;
end;

-- A function to get the control's button.
function CONTROL:GetButton()
	return self.m_button;
end;

-- A function to set the control text.
function CONTROL:SetText(text)
	self.m_label:SetText(text);
	self:SizeToContents();
end;

-- A function to get the control's label.
function CONTROL:GetLabel()
	return self.m_label;
end;

util.AddAccessor(CONTROL, "Callback", "m_callback");