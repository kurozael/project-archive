--[[ TETA_BONITA MADE THE FADING EFFECT. THANKS TETA_BONITA IF YOU'RE STILL ALIVE. --]]

include("shared.lua")

local iScreenWidth = surface.ScreenWidth()
local iScreenHeight = surface.ScreenHeight()
local SCOPEFADE_TIME = 1

function SWEP:DrawHUD()
	if self.UseScope then
		local bScope = self.Weapon:GetNetworkedBool("Scope")

		if bScope ~= self.bLastScope then
		
			self.bLastScope = bScope
			self.fScopeTime = CurTime()
				
		elseif 	bScope then
			local fScopeZoom = self.Weapon:GetNetworkedFloat("ScopeZoom")

			if fScopeZoom ~= self.fLastScopeZoom then
			
				self.fLastScopeZoom = fScopeZoom
				self.fScopeTime = CurTime()
			end
		end
				
		local fScopeTime = self.fScopeTime or 0

		if fScopeTime > CurTime() - SCOPEFADE_TIME then
			local Mul = 3.0

			Mul = 1 - math.Clamp((CurTime() - fScopeTime)/SCOPEFADE_TIME, 0, 1)
				
			if  self.Weapon:GetNetworkedBool("Scope") then
				self.Owner:DrawViewModel(false)
			else
				self.Owner:DrawViewModel(true)
			end
			
			surface.SetDrawColor(0, 0, 0, 255*Mul)
			surface.DrawRect(0,0,iScreenWidth,iScreenHeight)
		end

		if (bScope) then 
		
			// Draw the crosshair
			if not (self.ScopeReddot or self.ScopeMs) then
				surface.SetDrawColor(0, 0, 0, 255)
				surface.DrawLine(self.CrossHairTable.x11, self.CrossHairTable.y11, self.CrossHairTable.x12, self.CrossHairTable.y12)
				surface.DrawLine(self.CrossHairTable.x21, self.CrossHairTable.y21, self.CrossHairTable.x22, self.CrossHairTable.y22)
			end


			// Put the texture
			surface.SetDrawColor(0, 0, 0, 255)
			
			if (self.Scope1) then
				surface.SetTexture(surface.GetTextureID("ph_scope/ph_scope_lens"))
			elseif (self.Scope2) then
				surface.SetTexture(surface.GetTextureID("ph_scope/ph_scope_lens2"))
			elseif (self.Scope3) then
				surface.SetTexture(surface.GetTextureID("ph_scope/ph_scope_lens3"))
			elseif (self.Scope4) then
				surface.SetTexture(surface.GetTextureID("ph_scope/ph_scope_lens4"))
			elseif (self.Scope5) then
				surface.SetTexture(surface.GetTextureID("ph_scope/ph_scope_lens5"))
			elseif (self.Scope6) then
				surface.SetTexture(surface.GetTextureID("ph_scope/ph_scope_lens6"))
			end

			surface.DrawTexturedRect(0, 0, iScreenWidth,  iScreenHeight)		    
		end
	end
end