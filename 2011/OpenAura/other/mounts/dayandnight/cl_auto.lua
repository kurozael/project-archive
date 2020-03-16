--[[
Name: "cl_auto.lua".
Product: "blueprint".
--]]

local PLUGIN = PLUGIN;

BLUEPRINT:IncludePrefixed("sh_auto.lua");

-- A function to calculate the sky color.
function PLUGIN:CalculateSkyColor()
	local skyColor = BLUEPRINT:GetSharedVar("sh_SkyColor");
	local skyName = BLUEPRINT:GetSharedVar("sh_SkyName");
	local curTime = UnPredictedCurTime();
	
	if ( skyName != "" and (!self.nextSkyColor or curTime >= self.nextSkyColor) ) then
		if (!self.skyMaterials) then
			self.skyMaterials = {};
			self.skyMaterials[1] = Material("skybox/"..skyName.."up");
			self.skyMaterials[2] = Material("skybox/"..skyName.."dn");
			self.skyMaterials[3] = Material("skybox/"..skyName.."lf");
			self.skyMaterials[4] = Material("skybox/"..skyName.."rt");
			self.skyMaterials[5] = Material("skybox/"..skyName.."bk");
			self.skyMaterials[6] = Material("skybox/"..skyName.."ft");
		end;
		
		if (skyColor != self.lastSkyColor) then
			for k, v in pairs(self.skyMaterials) do
				v:SetMaterialVector("$color", skyColor);
			end;
			
			self.lastSkyColor = skyColor;
		end;
	end;
end;