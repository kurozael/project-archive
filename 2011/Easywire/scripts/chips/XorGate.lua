--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
--]]

CHIP.m_sName = "Xor Gate";
CHIP.m_image = util.GetImage("chips/xor");

-- Called when the chip's output is needed.
function CHIP:OnGetOutput(key)
	local inputA = self:GetInput("A");
	local inputB = self:GetInput("B");
	
	if ( (inputA or inputB) and not (inputA and inputB) ) then
		return true;
	else
		return false;
	end;
end;