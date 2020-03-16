--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PLUGIN = PLUGIN;

-- Called when the bars are needed.
function PLUGIN:GetBars(bars)
	local stamina = openAura.Client:GetSharedVar("stamina");
	
	if (!self.stamina) then
		self.stamina = stamina;
	else
		self.stamina = math.Approach(self.stamina, stamina, 1);
	end;
	
	if (self.stamina < 75) then
		bars:Add("STAMINA", Color(100, 175, 100, 255), "", self.stamina, 100, self.stamina < 10);
	end;
end;

-- Called to get whether a player's target ID should be drawn.
function PLUGIN:ShouldDrawPlayerTargetID(player)
	if (player:GetMaterial() == "sprites/heatwave") then
		return false;
	end;
end;

-- Called when screen space effects should be rendered.
function PLUGIN:RenderScreenspaceEffects()
	local thermalVision = openAura.Client:GetSharedVar("thermal");
	local modulation = {1, 1, 1};
	
	if (thermalVision) then
		modulation = {1, 0, 0};
		
		local colorModify = {};
			colorModify["$pp_colour_brightness"] = 0;
			colorModify["$pp_colour_contrast"] = 1;
			colorModify["$pp_colour_colour"] = 0.1;
			colorModify["$pp_colour_addr"] = 0;
			colorModify["$pp_colour_addg"] = 0;
			colorModify["$pp_colour_addb"] = 0.1;
			colorModify["$pp_colour_mulr"] = 25;
			colorModify["$pp_colour_mulg"] = 0;
			colorModify["$pp_colour_mulb"] = 25;
		DrawColorModify(colorModify);
	end;
	
	cam.Start3D( EyePos(), EyeAngles() );
		for k, v in ipairs( _player.GetAll() ) do
			if (v:Alive() and !v:IsRagdolled() and v:GetMoveType() == MOVETYPE_WALK) then
				if ( v:HasInitialized() ) then
					if ( thermalVision or (v:GetMaterial() == "sprites/heatwave"
					and v:GetVelocity():Length() > 1) ) then
						local material = self.heatwaveMaterial;
						
						if (thermalVision) then
							material = self.shinyMaterial;
						end;
						
						render.SuppressEngineLighting(true);
						render.SetColorModulation( unpack(modulation) );
						
						SetMaterialOverride(material);
							v:DrawModel();
						SetMaterialOverride(false)
						
						render.SetColorModulation(1, 1, 1);
						render.SuppressEngineLighting(false);
					end;
				end;
			end;
		end;
	cam.End3D();
end;