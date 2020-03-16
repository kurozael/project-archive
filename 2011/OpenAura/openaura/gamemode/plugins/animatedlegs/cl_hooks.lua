--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PLUGIN = PLUGIN;

-- Called when the local player's animation is updated.
function PLUGIN:UpdateAnimation(player, velocity, maxSeqGroundSpeed)
	if (openAura.Client == player) then
		if ( IsValid(self.legsEntity) ) then
			self:LegsThink(maxSeqGroundSpeed);
		else
			self:CreateLegs();
		end;
	end;
end;

-- Called when the screenspace effects are rendered.
function PLUGIN:RenderScreenspaceEffects()
	cam.Start3D( EyePos(), EyeAngles() );
		if ( self:ShouldDrawLegs() ) then
			self.RenderPos = openAura.Client:GetPos();
			
			if ( openAura.Client:InVehicle() ) then
				self.RenderAngle = openAura.Client:GetVehicle():GetAngles();
				self.RenderAngle:RotateAroundAxis(self.RenderAngle:Up(), 90);
			else
				self.BiaisAngles = openAura.Client:EyeAngles();
				self.RenderAngle = Angle(0, self.BiaisAngles.y, 0)
				self.RadAngle = math.rad(self.BiaisAngles.y);
				self.ForwardOffset = -12 + (1 - (math.Clamp(self.BiaisAngles.p - 45, 0, 45) / 45) * 7);
				self.RenderPos.x = self.RenderPos.x + math.cos(self.RadAngle) * self.ForwardOffset;
				self.RenderPos.y = self.RenderPos.y + math.sin(self.RadAngle) * self.ForwardOffset;
				
				if (openAura.Client:GetGroundEntity() == NULL) then
					self.RenderPos.z = self.RenderPos.z + 8;
					
					if ( openAura.Client:KeyDown(IN_DUCK) ) then
						self.RenderPos.z = self.RenderPos.z - 28;
					end;
				end;
			end;
			
			self.RenderColor.r, self.RenderColor.g, self.RenderColor.b, self.RenderColor.a = openAura.Client:GetColor();
			
			render.EnableClipping(true);
			render.PushCustomClipPlane( self.ClipVector, self.ClipVector:Dot( EyePos() ) );
			render.SetColorModulation(self.RenderColor.r / 255, self.RenderColor.g / 255, self.RenderColor.b / 255);
			render.SetBlend(self.RenderColor.a / 255);
			
			self.legsEntity:SetRenderOrigin(self.RenderPos);
			self.legsEntity:SetRenderAngles(self.RenderAngle);
			self.legsEntity:SetupBones();
			self.legsEntity:DrawModel();
			self.legsEntity:SetRenderOrigin();
			self.legsEntity:SetRenderAngles();
			
			render.SetBlend(1);
			render.SetColorModulation(1, 1, 1);
			render.PopCustomClipPlane();
			render.EnableClipping(false);
		end;
	cam.End3D();
end;