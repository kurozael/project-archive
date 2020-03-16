--[[
	© 2011-2012 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
	Conna Wiles (connawiles@gmail.com)
--]]

ENTITY.m_iDrawLayer = LAYER_PROPS;
ENTITY.m_sMaterial = "physics";

ENTITY:AddKeyValue("Texture", "physics.png");

-- Called when an entity's key value is set.
function ENTITY:OnKeyValueSet(key, value)
	if (key == "Texture") then
		self:SetMaterial(value, true);
	end;
	
	self:BaseClass().OnKeyValueSet(self, key, value);
end;

-- Called when the entity has initialized.
function ENTITY:OnInitialize(arguments)
	self:SetCollisionType(COLLISION_PHYSICS);
	self:SetFixedRotation(false);
	self:SetMaterial(self:GetKeyValue("Texture", "physics.png"));
	self:SetColor(Color(1, 1, 1, 1));
end;

-- Called when the entity is being saved to a level.
function ENTITY:OnSaveLevel(data)
	self:SetKeyValue("Texture", self:GetMaterial());
end;

-- Called when the entity takes damage.
function ENTITY:OnTakeDamage(damageInfo)
	local damagePos = damageInfo:GetPosition();
	
	if (damageInfo:GetType() == DAMAGE_BULLET) then
		local damageForce = damageInfo:GetForce();
		local degrees = util.AngleBetweenVectors(damagePos, damageInfo:GetInflictor():GetCenter() ):Degrees();
		
		self:ApplyForce(damageForce, damagePos);
		self:EmitSound("props/bullet_hit");
	end;
end;