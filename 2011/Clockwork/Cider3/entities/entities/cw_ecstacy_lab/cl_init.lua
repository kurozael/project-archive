--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

include("shared.lua");

-- Called when the local player attempts to supply the generator.
function ENT:CanSupply()
	return false;
end;