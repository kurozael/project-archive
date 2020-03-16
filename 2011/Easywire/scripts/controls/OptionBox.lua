--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
--]]

CONTROL.m_sBaseClass = "Button";

-- Called when the control's layout should be performed.
function CONTROL:OnPerformLayout()
	self:BaseClass().OnPerformLayout(self);
	
	self.m_image:SetPos(
		self:GetW() - 18,
		(self:GetH() / 2) - 8
	);
end;

-- Called when the mouse is released.
function CONTROL:OnMouseButtonRelease(button, x, y)
	if (button == MOUSE_LEFT) then
		self:SetSuppressed(false);
		self:OpenMenu();
	end;
end;

-- Called when the mouse is pressed.
function CONTROL:OnMouseButtonPress(button, x, y)
	if (button == MOUSE_LEFT) then
		self:SetSuppressed(true);
	end;
end;

-- Called when the control has initialized.
function CONTROL:OnInitialize(arguments)
	self:BaseClass().OnInitialize(self, arguments);
	
	self.m_image = controls.Create("Image", self);
		self.m_image:SetMaterial("controls/dropdown");
		self.m_image:SetSize(16, 16);
		self.m_image:SetPos(
			self:GetW() - 18,
			(self:GetH() / 2) - 8
		);
	self.m_options = {};
	
	self:SetHeight(20);
	self:SetColor( Color(0.7, 0.7, 0.7, 1) );
	self:SetText("");
end;

-- A function to add an option to the control.
function CONTROL:AddOption(option)
	self.m_options[#self.m_options + 1] = tostring(option);
end;

-- A function to select an option.
function CONTROL:SelectOption(option)
	local callback = self:GetCallback();
	local stringOption = tostring(option);
	
	if (callback) then
		callback(stringOption);
	end;
	
	self:SetText(stringOption);
	self.m_menu = nil;
end;

-- A function to get the control's selected option.
function CONTROL:GetOption()
	return self:GetText();
end;

-- A function to open the control's menu.
function CONTROL:OpenMenu()
	if (#self.m_options == 0) then return; end;
	
	if ( self.m_menu and self.m_menu:IsValid() ) then
		self.m_menu:Close();
		self.m_menu = nil;
		return;
	end;
	
	self.m_menu = controls.Create("SimpleMenu");
	
	for k, v in ipairs(self.m_options) do
		self.m_menu:AddOption(v, function()
			self:SelectOption(v);
		end);
	end;
	
	self.m_menu:SetMinimumWidth( self:GetW() );
	self.m_menu:Open( self:GetX(), self:GetY() + self:GetH() );
end;

-- A function to clear the control.
function CONTROL:Clear()
	self.m_options = {};
	self:SetText("");
	
	if (self.m_menu) then
		self.m_menu:Close();
		self.m_menu = nil;
	end;
end;