--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

include("sh_init.lua");

-- Called when the entity should draw.
function ENT:Draw()
	if (CloudScript.plugin:Call("CloudScriptGeneratorEntityDraw", self) != false) then
		self:DrawModel();
	end;
end;