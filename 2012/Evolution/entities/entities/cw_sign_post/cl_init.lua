--[[
	© 2012 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

Clockwork.kernel:IncludePrefixed("shared.lua")

--[[ A small hack defined here incase people enter a color wrong. --]]
function Color(r, g, b, a)
    return {
		r = math.min(tonumber(r) or 255, 255),
		g = math.min(tonumber(g) or 255, 255),
		b = math.min(tonumber(b) or 255, 255),
		a = math.min(tonumber(a) or 255, 255)
	};
end

-- Called when the entity should draw.
function ENT:Draw()
	local menuTextSmallFont = Clockwork.option:GetFont("menu_text_small");
	local menuTextTinyFont = Clockwork.option:GetFont("menu_text_tiny");
	local mainTextFont = Clockwork.option:GetFont("main_text");
	local position = self:GetPos() + (self:GetUp() * 47) + (self:GetForward() * 2);
	local eyeAngles = EyeAngles();
	local eyePos = EyePos();
	
	local angles = self:GetAngles();
		angles:RotateAroundAxis(angles:Forward(), 90);
		angles:RotateAroundAxis(angles:Right(), 270);
	self:DrawModel();
	
	if (self.cwForceTinyFont) then
		menuTextSmallFont = menuTextTinyFont;
	end;
	
	if (self.cwForceMainText) then
		menuTextSmallFont = mainTextFont;
	end;
	
	cam.Start3D(eyePos, eyeAngles);
		cam.Start3D2D(position + (self:GetRight() * 22), angles, 0.2);
			draw.RoundedBox(0, 0, 0, 220, 218, Color(50, 50, 50, 255));
			
			if (self:GetNetworkedString("Text") != "") then
				if (!self.cwMarkupObject) then
					self.cwMarkupObject = markup.Parse(
						"<font="..menuTextSmallFont..">"..self:GetNetworkedString("Text").."</font>"
					, 214);
					Clockwork:OverrideMarkupDraw(self.cwMarkupObject);
				end;
				
				if (self.cwMarkupObject:GetHeight() > 218 and !self.cwForceTinyFont) then
					self.cwForceTinyFont = true;
					self.cwMarkupObject = nil;
				elseif (self.cwMarkupObject:GetHeight() > 218 and !self.cwForceMainText) then
					self.cwForceMainText = true;
					self.cwMarkupObject = nil;
				else
					self.cwMarkupObject:Draw(8, 8);
				end;
			end;
		cam.End3D2D();
	cam.End3D();
end;