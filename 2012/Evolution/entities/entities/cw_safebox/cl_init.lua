--[[
	© 2012 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

Clockwork.kernel:IncludePrefixed("shared.lua")

-- Called when the entity should draw.
function ENT:Draw()
	Clockwork.outline:RenderFromFade(self, Color(0, 200, 0, 255), 1024);
	self:DrawModel();
end;