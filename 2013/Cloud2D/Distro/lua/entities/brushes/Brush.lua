--[[
	© 2011-2012 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
	Conna Wiles (connawiles@gmail.com)
--]]

ENTITY.m_bForceMaterial = false;
ENTITY.m_bDrawShadow = false;
ENTITY.m_iDrawLayer = LAYER_BRUSH;
ENTITY.m_bUseSprite = false;
ENTITY.m_bPassable = false;
ENTITY.m_sMaterial = "editor/brush";
ENTITY.m_bVisible = true;

ENTITY:AddKeyValue("Texture", "editor/brush", KEYVALUE_TEXTURE);
ENTITY:AddKeyValue("TextureSize", 32);

-- Called when an entity's key value type can be forced.
function ENTITY:OnForceKeyValueType(key)
	if (key == "Texture" and self:DoesForceMaterial()) then
		return KEYVALUE_NIL;
	end;
end;

-- Called when an entity's key value is set.
function ENTITY:OnKeyValueSet(key, value)
	if (key == "Texture" and not self:DoesForceMaterial()) then
		self.m_image = util.GetImage(value);
		self:SetMaterial(value);
	end;
end;

-- Called when the entity has initialized.
function ENTITY:OnInitialize(arguments)
	if (self:DoesForceMaterial()) then
		self:SetMaterial(self.m_sMaterial);
		self.m_image = util.GetImage(self.m_sMaterial);
	else
		self.m_image = util.GetImage(self:GetKeyValue("Texture"));
		self:SetMaterial(self:GetKeyValue("Texture"));
	end;
	
	if (self.m_bPassable) then
		self:SetCollisionType(COLLISION_NONE);
	else
		self:SetCollisionType(COLLISION_STATIC);
	end;
end;

-- Called when the entity changes material.
function ENTITY:OnChangeMaterial(material)
	self.m_image = util.GetImage(material);
end;

-- Called when the entity is being saved to a level.
function ENTITY:OnSaveLevel(data)
	self:SetKeyValue("Texture", self:GetMaterial());
end;

-- A function to get whether the entity forces a material.
function ENTITY:DoesForceMaterial()
	return self.m_bForceMaterial;
end;

-- A function to get whether the entity is passable.
function ENTITY:IsPassable()
	return self.m_bPassable;
end;

-- A function to draw the sprite.
function ENTITY:DrawSprite()
	if ((not self:GetNotDrawn() and self.m_bVisible)
	or states.IsEditor()) then
		local position = self:GetPos();
		local tileSize = self:GetKeyValue("TextureSize");
		
		draw.TiledImage(
			self.m_image,
			position.x,
			position.y,
			self:GetW(),
			self:GetH(),
			self.m_color,
			tileSize
		);
	end;
end;