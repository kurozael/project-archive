--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

ENT.Type = "anim";
ENT.Base = "base_gmodentity";
ENT.Author = "kurozael";
ENT.PrintName = "Radio";
ENT.Spawnable = false;
ENT.AdminSpawnable = false;

-- A function to get whether the entity is off.
function ENT:IsOff()
	return self:GetSharedVar("Off");
end;