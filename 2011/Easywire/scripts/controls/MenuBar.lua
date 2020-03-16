--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
--]]

-- Called when the control's layout should be performed.
function CONTROL:OnPerformLayout()
	local buttonX = 0;
	
	for k, v in ipairs(self.m_items) do
		v:SetPos(buttonX, 0);
		buttonX = buttonX + v:GetW() + 1;
	end;
end;

-- Called when the control has initialized.
function CONTROL:OnInitialize(arguments)
	self:SetColor( Color(0.5, 0.5, 0.5, 0.9) );
	self.m_items = {};
end;

-- A function to add an item to the menu bar.
function CONTROL:AddItem(text, Callback)
	local button = controls.Create("BarButton", self);
		button:SetCallback(function()
			local simpleMenu = controls.Create("SimpleMenu");
				Callback(simpleMenu);
			simpleMenu:Open( button:GetX(), button:GetY() + button:GetH() );
		end);
		button:SetText(text);
		button:SetSize(64, self:GetH() - 2);
		button:SetPos(0, 0);
	self.m_items[#self.m_items + 1] = button;
	
	self:InvalidateLayout();
end;

-- Called when the control is drawn.
function CONTROL:OnDraw()
	local height = self:GetH();
	local width = self:GetW();
	local color = self:GetColor();
	local x, y = self:GetX(), self:GetY();
	
	g_Render:DrawFill(x, y, width, height, color);
	g_Render:DrawFill( x, y + height - 1, width, 2, Color(1, 1, 1, 1) );
end;