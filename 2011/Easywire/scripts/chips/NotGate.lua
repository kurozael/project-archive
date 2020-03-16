--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
--]]

CHIP.m_sName = "Not Gate";
CHIP.m_image = util.GetImage("chips/not");

-- Called when the chip has initialized.
function CHIP:OnInitialize()
	self.m_inputs = {"A"};
	self.m_outputs = {"B"};
end;

-- Called when the chip's output is needed.
function CHIP:OnGetOutput(key)
	return (  not self:GetInput("A") );
end;