--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
--]]

CHIP.m_sName = "Or Gate";
CHIP.m_image = util.GetImage("chips/or");

-- Called when the chip's output is needed.
function CHIP:OnGetOutput(key)
	local inputA = self:GetInput("A");
	local inputB = self:GetInput("B");
	
	return (inputA or inputB);
end;