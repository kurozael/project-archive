--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

include("sh_init.lua");

-- Called when the entity should draw.
function ENT:Draw()
	if (openAura.plugin:Call("OpenAuraGeneratorEntityDraw", self) != false) then
		self:DrawModel();
	end;
end;