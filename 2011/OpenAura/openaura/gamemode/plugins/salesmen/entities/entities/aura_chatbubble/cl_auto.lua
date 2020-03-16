--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

openAura:IncludePrefixed("sh_auto.lua")

-- Called when the entity is drawn.
function ENT:Draw()
	self:SetModelScale( Vector(0.6, 0.6, 0.6) );
	self:DrawModel();
end;

-- Called every frame.
function ENT:Think()
	if (!self.OriginalPos) then
		self.OriginalPos = self:GetPos();
	end;
	
	self:SetPos( self.OriginalPos + Vector(0, 0, math.sin( UnPredictedCurTime() ) * 2.5) );
	
	if ( self.NextChangeAngle <= UnPredictedCurTime() ) then
		self:SetAngles( self:GetAngles() + Angle(0, 0.25, 0) );
		self.NextChangeAngle = self.NextChangeAngle + (1 / 60);
	end;
end;

-- Called when the entity initializes.
function ENT:Initialize()
	self.NextChangeAngle = UnPredictedCurTime();
end;