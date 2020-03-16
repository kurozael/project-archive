--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
--]]

CHIP.m_sName = "Switch";
CHIP.m_image = util.GetImage("switch/off");

-- Called when the chip has initialized.
function CHIP:OnInitialize()
	self.m_bOn = false;
	self.m_inputs = {};
	self.m_outputs = {"On"};
	self.m_onImage = util.GetImage("switch/on");
	self.m_offImage = util.GetImage("switch/off");
end;

--[[
	Called when the chip should be drawn.
	Return true to override default drawing.
--]]
function CHIP:OnDraw(editorObject)
	local rectangle = editorObject:GetWorldRect();
	local color = Color(1, 1, 1, 1);
		
	if (self.m_bOn) then
		g_Render:DrawImage(
			self.m_onImage, rectangle.x, rectangle.y,
			rectangle.w, rectangle.h, color
		);
	else
		g_Render:DrawImage(
			self.m_offImage, rectangle.x, rectangle.y,
			rectangle.w, rectangle.h, color
		);
	end;
	
	return true;
end;

-- Called when the chip's output is needed.
function CHIP:OnGetOutput(key)
	return self.m_bOn;
end;

-- Called when the select menu should be edited.
function CHIP:OnEditSelectMenu(menu)
	menu:AddOption("Toggle", function()
		g_Sounds:PlaySound("click", 1);
		self.m_bOn = not self.m_bOn;
	end);
end;