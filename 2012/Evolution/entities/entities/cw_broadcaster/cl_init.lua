--[[
	© 2012 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

Clockwork.kernel:IncludePrefixed("shared.lua")

--[[ The material used to display whether it is on. --]]
local GLOW_MATERIAL = Material("sprites/glow04_noz");

-- Called when the target ID HUD should be painted.
function ENT:HUDPaintTargetID(x, y, alpha)
	local colorTargetID = Clockwork.option:GetColor("target_id");
	local colorWhite = Clockwork.option:GetColor("white");
	local listeners = 0;
	local position = self:GetPos();
	local name = self:GetNetworkedString("Name");
	
	if (name != "") then
		y = Clockwork:DrawInfo(name, x, y, colorTargetID, alpha);
	else
		y = Clockwork:DrawInfo("Broadcaster", x, y, colorTargetID, alpha);
	end;
	
	for k, v in ipairs(_player.GetAll()) do
		local playerPosition = v:GetPos();
		local bListening = true;
		local distance = playerPosition:Distance(position);
		
		if (v:HasInitialized() and distance <= 4096) then
			for k2, v2 in ipairs(ents.FindByClass("cw_broadcaster")) do
				if (playerPosition:Distance(v2:GetPos()) < distance
				and v2 != self and !v2:IsOff()) then
					bListening = false;
					break;
				end;
			end;
			
			if (bListening) then
				listeners = listeners + 1;
			end;
		end;
	end;
	
	y = Clockwork:DrawInfo("There are "..listeners.." listeners.", x, y, colorWhite, alpha);
end;

-- Called when the entity should draw.
function ENT:Draw()
	self:DrawModel();
	
	local r, g, b, a = self:GetColor();
	local glowColor = Color(0, 255, 0, a);
	local position = self:GetPos();
	local forward = self:GetForward() * 9;
	local right = self:GetRight() * 5;
	local up = self:GetUp() * 8;
	
	if (self:IsOff()) then
		glowColor = Color(255, 0, 0, a);
	end;
	
	cam.Start3D(EyePos(), EyeAngles());
		render.SetMaterial(GLOW_MATERIAL);
		render.DrawSprite(position + forward + right + up, 16, 16, glowColor);
	cam.End3D();
end;