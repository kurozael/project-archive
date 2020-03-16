--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

include("shared.lua");

AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");

-- Called when a player earns cash from the generator.
function ENT:OnEarned(player, cash)
	local entityPosition = self:GetPos();
	local endPosition = entityPosition + (self:GetUp() * 128);
	local traceLine = util.TraceLine({
		endpos = endPosition,
		filter = self,
		start = entityPosition,
		mask = MASK_NPCWORLDSTATIC
	});
	
	local entity = Clockwork.entity:CreateItem(
		player, Clockwork.item:CreateInstance("cocaine"), traceLine.HitPos - (self:GetUp() * 64), self:GetAngles()
	);
	
	if (IsValid(entity)) then
		entity:GetPhysicsObject():SetMass(40);
	end;
	
	if (self:GetPower() == 0) then
		self:Remove();
		self:Explode();
	end;
	
	return true;
end;

-- Called when a player attempts to supply the generator.
function ENT:CanSupply(player)
	return false;
end;