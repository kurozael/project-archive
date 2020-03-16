--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
--]]

CHIP.m_sName = "Diode";
CHIP.m_image = util.GetImage("diode/off");
CHIP.m_spotlight = util.GetImage("lights/spotlight");

-- Called when the chip has initialized.
function CHIP:OnInitialize()
	self.m_color = Color(1, 0, 0, 1);
	self.m_inputs = {"On"};
	self.m_outputs = {};
	self.m_onImage = util.GetImage("diode/red.png");
end;

--[[
	Called when the chip should be drawn.
	Return true to override default drawing.
--]]
function CHIP:OnDraw(editorObject)
	local rectangle = editorObject:GetWorldRect();
		
	if ( self:GetInput("On") ) then
		g_Render:DrawImage(
			self.m_spotlight, rectangle.x - 32, rectangle.y - 32,
			rectangle.w + 64, rectangle.h + 64, self.m_color
		);
		
		g_Render:DrawImage(
			self.m_onImage, rectangle.x, rectangle.y,
			rectangle.w, rectangle.h, Color(1, 1, 1, 1)
		);
		
		return true;
	end;
	
	return false;
end;

-- Called when the select menu should be edited.
function CHIP:OnEditSelectMenu(menu)
	local subMenu = menu:AddSubMenu("Color");
	
	subMenu:AddOption("Red", function()
		self.m_color = Color(1, 1, 1, 1);
		self.m_onImage = util.GetImage("diode/red.png");
	end);
	
	subMenu:AddOption("Green", function()
		self.m_color = Color(0, 1, 0, 1);
		self.m_onImage = util.GetImage("diode/green.png");
	end);
	
	subMenu:AddOption("Blue", function()
		self.m_color = Color(0, 0, 1, 1);
		self.m_onImage = util.GetImage("diode/blue.png");
	end);
end;