include('shared.lua')

// Draw

function ENT:Draw()
	if (LocalPlayer():GetEyeTrace().Entity == self.Entity && EyePos():Distance(self.Entity:GetPos()) < 512) then
		self:DrawEntityOutline(1.0)
		
		self.Entity:DrawModel()
		
		if (self:GetOverlayText() != "") then
			AddWorldTip(self.Entity:EntIndex(), self:GetOverlayText(), 0.5, self.Entity:GetPos(), self.Entity)
		end
		
		return
	end

	self.Entity:DrawModel()
end