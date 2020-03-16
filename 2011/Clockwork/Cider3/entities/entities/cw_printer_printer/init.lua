--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

include("shared.lua");

AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");

-- Called when a player earns cash from the generator.
function ENT:OnEarned(player, cash)
	if (cash > 0) then
		local entityPosition = self:GetPos();
		local endPosition = entityPosition + (self:GetUp() * 128);
		local traceLine = util.TraceLine({
			endpos = endPosition,
			filter = self,
			start = entityPosition,
			mask = MASK_NPCWORLDSTATIC
		});
		
		Clockwork.entity:CreateCash(player, cash, traceLine.HitPos - (self:GetUp() * 64), self:GetAngles());
		return true;
	end;
end;