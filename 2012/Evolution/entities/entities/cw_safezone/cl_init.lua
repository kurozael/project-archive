--[[
	© 2012 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

Clockwork.kernel:IncludePrefixed("shared.lua")

--[[ Some customizable materials for the Safe Zone... --]]
local MATERIAL_SAFEZONE = Material("phoenix_storms/stripes");
local MATERIAL_BORDER = Material("cable/redlaser");

-- Called when the entity should draw.
function ENT:Draw()
	Clockwork.outline:RenderFromFade(
		self, Clockwork.option:GetColor("information"), 1024
	);
	
	self:DrawModel();
end;

-- A function to render the entity's box.
function ENT:RenderBox()
	local informationColor = Clockwork.option:GetColor("information");
	local vBorderColor = MATERIAL_BORDER:GetMaterialVector("$color");
	local fBorderAlpha = MATERIAL_BORDER:GetMaterialFloat("$alpha");
	local fWallAlpha = MATERIAL_SAFEZONE:GetMaterialFloat("$alpha");
	local vWallColor = MATERIAL_SAFEZONE:GetMaterialVector("$color");
	local colorWhite = Clockwork.option:GetColor("white");
	local position = self:GetPos() - Vector(0, 0, 80);
	local boxSize = self.dt.Size;
	local halfSize = boxSize * 0.5;
	local vTall = Vector(0, 0, halfSize);
	local alpha = Clockwork:CalculateAlphaFromDistance(
		boxSize * 2, Clockwork.Client, self
	);
	
	MATERIAL_SAFEZONE:SetMaterialVector("$color", Vector(1, 0, 0));
	MATERIAL_SAFEZONE:SetMaterialFloat("$alpha", (0.5 / 255) * alpha);
	MATERIAL_BORDER:SetMaterialVector("$color", Vector(
		informationColor.r / 255, informationColor.g / 255, informationColor.b / 255)
	);
	MATERIAL_BORDER:SetMaterialFloat("$alpha", (1 / 255) * alpha);
	
	local vFrontCenter = position - Vector(boxSize, 0, -(boxSize / 4));
	local vFrontBottomL = position - Vector(boxSize, -boxSize, 0);
	local vFrontBottomR = position - Vector(boxSize, boxSize, 0);
	local vRightCenter = position - Vector(0, -boxSize, -(boxSize / 4));
	local vRightBottomL = position - Vector(-boxSize, -boxSize, 0);
	local vRightBottomR = position - Vector(boxSize, -boxSize, 0);
	local vBackCenter = position - Vector(-boxSize, 0, -(boxSize / 4));
	local vBackBottomL = position - Vector(-boxSize, -boxSize, 0);
	local vBackBottomR = position - Vector(-boxSize, boxSize, 0);
	local vLeftCenter = position - Vector(0, boxSize, -(boxSize / 4));
	local vLeftBottomL = position - Vector(-boxSize, boxSize, 0);
	local vLeftBottomR = position - Vector(boxSize, boxSize, 0);
	local vFrontTopL = vFrontBottomL + vTall;
	local vFrontTopR = vFrontBottomR + vTall;
	local vRightTopL = vRightBottomL + vTall;
	local vRightTopR = vRightBottomR + vTall;
	local vBackTopL = vBackBottomL + vTall;
	local vBackTopR = vBackBottomR + vTall;
	local vLeftTopL = vLeftBottomL + vTall;
	local vLeftTopR = vLeftBottomR + vTall;
	
	render.SuppressEngineLighting(true);
	render.SetMaterial(MATERIAL_BORDER);
	
	render.DrawBeam(vFrontBottomL, vFrontBottomR, 32, 1, 1, Color(255, 255, 255, 255));
	render.DrawBeam(vBackBottomL, vBackBottomR, 32, 1, 1, Color(255, 255, 255, 255));
	render.DrawBeam(vLeftBottomL, vLeftBottomR, 32, 1, 1, Color(255, 255, 255, 255));
	render.DrawBeam(vRightBottomL, vRightBottomR, 32, 1, 1, Color(255, 255, 255, 255));
	
	render.DrawBeam(vFrontTopL, vFrontTopR, 32, 1, 1, Color(255, 255, 255, 255));
	render.DrawBeam(vBackTopL, vBackTopR, 32, 1, 1, Color(255, 255, 255, 255));
	render.DrawBeam(vLeftTopL, vLeftTopR, 32, 1, 1, Color(255, 255, 255, 255));
	render.DrawBeam(vRightTopL, vRightTopR, 32, 1, 1, Color(255, 255, 255, 255));
	
	render.DrawBeam(vFrontTopR, vFrontBottomR, 32, 1, 1, Color(255, 255, 255, 255));
	render.DrawBeam(vBackTopL, vBackBottomL, 32, 1, 1, Color(255, 255, 255, 255));
	render.DrawBeam(vLeftTopL, vLeftBottomL, 32, 1, 1, Color(255, 255, 255, 255));
	render.DrawBeam(vRightTopR, vRightBottomR, 32, 1, 1, Color(255, 255, 255, 255));
	
	render.SetMaterial(MATERIAL_SAFEZONE);
	
	--[[ Red front of the box. --]]
	render.DrawQuadEasy(
		vFrontCenter, Vector(1, 0, 0), boxSize / 2, boxSize * 2, Color(255, 0, 0, 150 ), 270
	);
	
	--[[ Red back of the box. --]]
	render.DrawQuadEasy(
		vBackCenter, Vector(-1, 0, 0), boxSize / 2, boxSize * 2, Color(255, 0, 0, 150 ), 270
	);
	
	--[[ Red left of the box. --]]
	render.DrawQuadEasy(
		vLeftCenter, Vector(0, 1, 0), boxSize / 2, boxSize * 2, Color(255, 0, 0, 150 ), 270
	);
	
	--[[ Red right of the box.  --]]
	render.DrawQuadEasy(
		vRightCenter, Vector(0, -1, 0), boxSize / 2, boxSize * 2, Color(255, 0, 0, 150 ), 270
	);
	
	MATERIAL_SAFEZONE:SetMaterialVector("$color", Vector(
		informationColor.r / 255, informationColor.g / 255, informationColor.b / 255)
	)
	
	--[[ Green front of the box. --]]
	render.DrawQuadEasy(
		vFrontCenter, Vector(-1, 0, 0), boxSize / 2, boxSize * 2, Color(0, 255, 0, 150 ), 270
	);
	
	--[[ Green back of the box. --]]
	render.DrawQuadEasy(
		vBackCenter, Vector(1, 0, 0), boxSize / 2, boxSize * 2, Color(0, 255, 0, 150 ), 270
	);
	
	--[[ Green left of the box. --]]
	render.DrawQuadEasy(
		vLeftCenter, Vector(0, -1, 0), boxSize / 2, boxSize * 2, Color(0, 255, 0, 150 ), 270
	);

	--[[ Green right of the box. --]]
	render.DrawQuadEasy(
		vRightCenter, Vector(0, 1, 0), boxSize / 2, boxSize * 2, Color(0, 255, 0, 150 ), 270
	);
	
	render.SuppressEngineLighting(false);
	
	MATERIAL_SAFEZONE:SetMaterialVector("$color", vWallColor);
	MATERIAL_SAFEZONE:SetMaterialFloat("$alpha", fWallAlpha);
	MATERIAL_BORDER:SetMaterialVector("$color", vBorderColor);
	MATERIAL_BORDER:SetMaterialFloat("$alpha", fBorderAlpha);
	
	local large3D2DFont = Clockwork.option:GetFont("large_3d_2d");
	local eyeAngles = EyeAngles();
	local position = self:GetPos() + Vector(0, 0, 128) + eyeAngles:Up();
	local textY = 0;
	
	eyeAngles:RotateAroundAxis(eyeAngles:Forward(), 90);
	eyeAngles:RotateAroundAxis(eyeAngles:Right(), 90);
	Clockwork:OverrideMainFont(large3D2DFont);
	
	cam.Start3D2D(position, Angle(0, eyeAngles.y, 90), 0.3);
		textY = Clockwork:DrawInfo(self:GetNetworkedString("Name"), 0, textY, informationColor, alpha, nil, nil, 4);
	cam.End3D2D();
	
	cam.Start3D2D(position, Angle(0, eyeAngles.y, 90), 0.1);
		textY = Clockwork:DrawInfo("YOU CANNOT BE KILLED HERE.", 0, textY * 2.5, colorWhite, alpha, nil, nil, 4);
	cam.End3D2D();
	
	self:SetRenderAngles(Angle(0, EyeAngles().y, 0));
	self:DestroyShadow();
	
	Clockwork:OverrideMainFont(false);
end;