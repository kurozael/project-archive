--[[
	© 2011-2012 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
	Conna Wiles (connawiles@gmail.com)
--]]

ENTITY.m_bForceMaterial = true;
ENTITY.m_sBaseClass = "Brush";
ENTITY.m_bPassable = true;
ENTITY.m_sMaterial = "editor/trigger";
ENTITY.m_bVisible = false;

ENTITY:AddKeyValue("Class", "");

ENTITY:AddOutput("OnEnter", true);
ENTITY:AddOutput("OnLeave", true);

-- Called when the entity begins contact with another entity.
function ENTITY:OnBeginContact(entity, collisionInfo)
	if (entity:GetClass() == self:GetKeyValue("Class")
	or self:GetKeyValue("Class") == "") then
		self:CallOutput("OnEnter", entity);
	end;
end;

-- Called when the entity ends contact with another entity.
function ENTITY:OnEndContact(entity, collisionInfo)
	if (entity:GetClass() == self:GetKeyValue("Class")
	or self:GetKeyValue("Class") == "") then
		self:CallOutput("OnLeave", entity);
	end;
end;