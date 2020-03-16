--[[
	© 2012 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local MAT_WIREFRAME	= Material("models/wireframe");

-- Called when the effect has initialized.
function EFFECT:Init(data)
	self.Time = data:GetScale();
	self.LifeTime = CurTime() + self.Time
	
	local entity = data:GetEntity();
	if (!IsValid(entity)) then return; end;
	
	self:SetModel(entity:GetModel())	
	self:SetAngles(entity:GetAngles())
	self:SetPos(entity:GetPos())
	self:SetParent(entity)
	self.ParentEntity = entity;
	
	self.ParentEntity.RenderOverride = self.RenderParent;
	self.ParentEntity.SpawnEffect = self;
end;

-- Called each frame.
function EFFECT:Think()
	if (!IsValid(self.ParentEntity)) then
		return false;
	end;
	
	local parentPos = self.ParentEntity:GetPos();
	self:SetPos(parentPos + (EyePos() - parentPos):GetNormal());
	
	if (self.LifeTime > CurTime()) then
		return true;
	end;
	
	self.ParentEntity.RenderOverride = nil;
	self.ParentEntity.SpawnEffect = nil;
	
	return false;
end;

-- Called when the effect should be rendered.
function EFFECT:Render() end;

-- Called when an entity's overlay should be rendered.
function EFFECT:RenderOverlay(entity)
	local fraction = (self.LifeTime - CurTime()) / self.Time;
	fraction = math.Clamp(fraction, 0, 1);
	
	local eyeNormal = entity:GetPos() - EyePos();
	local distance = eyeNormal:Length();
	eyeNormal:Normalize();
	
	local position = EyePos() + eyeNormal * distance * 0.01;
	local bClipping = self:StartClip(entity, 1, true);
	
	cam.Start3D(position, EyeAngles());
		if (render.GetDXLevel() >= 80) then
			render.UpdateRefractTexture()
			
			MAT_WIREFRAME:SetMaterialFloat("$alpha", fraction);
		
			SetMaterialOverride(MAT_WIREFRAME);
				entity:DrawModel();
			SetMaterialOverride(false);
		end;
	cam.End3D();
	
	render.PopCustomClipPlane();
	render.EnableClipping(bClipping);
end;

-- Called when the effect's parent should be rendered.
function EFFECT:RenderParent()
	local bClipping = self.SpawnEffect:StartClip(self, 1);
		self:DrawModel();
	render.PopCustomClipPlane();
	render.EnableClipping(bClipping);
	
	self.SpawnEffect:RenderOverlay(self);
end;

-- Called to start clipping the model.
function EFFECT:StartClip(model, fSpeed, bOverlay)
	local minB, maxB = model:GetRenderBounds();
	local angBottom =  model:GetPos() + minB;
	local angTop = model:GetPos() + maxB;
	local angUp = (maxB - minB):GetNormal();
	
	--[[ Work out how far along we are... --]]
	local fraction = (self.LifeTime - CurTime()) / self.Time;
	fraction = math.Clamp(fraction / fSpeed, 0, 1);
	
	--[[ If it is an overlay then reverse the direction! --]]
	local normalVec = -angUp 
	if (bOverlay) then
		normalVec = angUp;
	end;
	
	local lerpedVec = LerpVector(fraction, angTop, angBottom);
	local distance = normalVec:Dot(lerpedVec);
	local bEnabled = render.EnableClipping(true);
		render.PushCustomClipPlane(normalVec, distance);
	return bEnabled;
end;