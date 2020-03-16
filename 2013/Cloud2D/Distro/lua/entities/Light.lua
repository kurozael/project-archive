--[[
	© 2011-2012 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
	Conna Wiles (connawiles@gmail.com)
--]]

ENTITY.m_iDrawLayer = LAYER_ITEMS;
ENTITY.m_sMaterial = "light";
ENTITY.m_bVisible = false;

ENTITY:AddKeyValue("BrushShadowsOnly", false);
ENTITY:AddKeyValue("IsStaticLight", false);
ENTITY:AddKeyValue("RayDistance", 128);
ENTITY:AddKeyValue("TintRed", 0.5);
ENTITY:AddKeyValue("TintGreen", 0.5);
ENTITY:AddKeyValue("TintBlue", 0.2);
ENTITY:AddKeyValue("Intensity", 0.9);
ENTITY:AddKeyValue("StartOn", true);

ENTITY:AddInput("Toggle");
ENTITY:AddInput("TurnOn");
ENTITY:AddInput("TurnOff");

-- Called when the entity is given an input.
function ENTITY:OnInput(inputName, argString)
	if (inputName == "TurnOn") then
		self:TurnOn();
	elseif (inputName == "TurnOff") then
		self:TurnOn();
	elseif (inputName == "Toggle") then
		if (self:IsOn()) then
			self:TurnOff();
		else
			self:TurnOn();
		end;
	end;
	
	self:BaseClass().OnInput(self, inputName, argString);
end;

-- Called when an entity's key value is set.
function ENTITY:OnKeyValueSet(key, value)
	if (key == "BrushShadowsOnly") then
		self.m_light:setBrushOnly(value);
	elseif (key == "IsStaticLight") then
		self.m_light:setStaticLight(value);
	elseif (key == "TintRed" or key == "TintGreen"
	or key == "TintBlue" or key == "Intensity") then
		self:SetColor(Color(
			math.Clamp(self:GetKeyValue("TintRed"), 0, 1),
			math.Clamp(self:GetKeyValue("TintGreen"), 0, 1),
			math.Clamp(self:GetKeyValue("TintBlue"), 0, 1),
			math.Clamp(self:GetKeyValue("Intensity"), 0, 1)
		));
	elseif (key == "RayDistance") then
		self.m_iRayDistance = value;
	end;
end;

-- Called when the entity has initialized.
function ENTITY:OnInitialize(arguments)
	local rayDistance = self:GetKeyValue("RayDistance", 128, KEYVALUE_NUMBER);
	local tintRed = self:GetKeyValue("TintRed", 0.5, KEYVALUE_NUMBER);
	local tintGreen = self:GetKeyValue("TintGreen", 0.5, KEYVALUE_NUMBER);
	local tintBlue = self:GetKeyValue("TintBlue", 0.2, KEYVALUE_NUMBER);
	local intensity = self:GetKeyValue("Intensity", 0.9, KEYVALUE_NUMBER);
	local color = Color(
		math.Clamp(tintRed, 0, 1),
		math.Clamp(tintGreen, 0, 1),
		math.Clamp(tintBlue, 0, 1),
		math.Clamp(intensity, 0, 1)
	);
	
	self.m_iRayDistance = rayDistance;
	self:SetCollisionType(COLLISION_NONE);
	self:SetSize(32, 32);
	self:SetColor(color);
	
	self.m_light = lighting.AddPoint(color, rayDistance, self:GetCenter());
	self.m_light:setStaticLight(self:GetKeyValue("IsStaticLight"));
	self.m_light:setBrushOnly(self:GetKeyValue("BrushShadowsOnly"));
	
	if (not self:GetKeyValue("StartOn")) then
		self:TurnOff();
	end;
end;

-- Called when the entity changes material.
function ENTITY:OnChangeMaterial(material)
	--self.m_light:SetMaterial(material);
end;

-- A function to set the intensity of the entity.
function ENTITY:SetIntensity(intensity)
	--self.m_light:SetIntensity(intensity);
end;

-- A function to get the intensity of the entity.
function ENTITY:GetIntensity()
	--return self.m_light:GetIntensity();
end;

-- A function to get whether the entity is on.
function ENTITY:IsOn()
	return self.m_light:isActive();
end;

-- A function to turn on the entity.
function ENTITY:TurnOn()
	self.m_light:setActive(true);
end;

-- A function to turn off the entity.
function ENTITY:TurnOff()
	self.m_light:setActive(false);
end;

-- Called when the entity is removed.
function ENTITY:OnRemove()
	self.m_light:remove();
end;

-- Called every frame for the entity.
function ENTITY:OnUpdate(deltaTime)
	self:UpdateSprite(deltaTime);
end;

local LIGHT_IMAGE = util.GetImage("light");

-- Called when the entity is drawn.
function ENTITY:OnDraw()
	self.m_light:setColor(self:GetColor());
	self.m_light:setPosition(self:GetCenter());
	self.m_light:setDistance(self.m_iRayDistance);
	
	if (states.IsEditor()) then
		self:DrawSprite(1);
	end;
end;
