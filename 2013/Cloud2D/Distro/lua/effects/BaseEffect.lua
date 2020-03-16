--[[
	© 2011-2012 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
	Conna Wiles (connawiles@gmail.com)
--]]

EFFECT.m_iEntIndex = 0;
EFFECT.m_sUniqueID = "fx:0";

-- Called when the effect is constructed.
function EFFECT:__init(arguments)
	self.m_data = {};
	self.m_sUniqueID = "fx:"..self.m_iEntIndex;
	self:OnInitialize(arguments);
end;

-- Called when the effect is updated.
function EFFECT:__update(deltaTime)
	return self:OnUpdate(deltaTime);
end;

-- Called when the effect is removed.
function EFFECT:__remove()
	self:OnRemove();
end;

-- Called when the effect is drawn.
function EFFECT:__draw()
	self:OnDraw();
end;

-- Called when the effect has initialized.
function EFFECT:OnInitialize(arguments) end;

-- Called every frame for the effect.
function EFFECT:OnUpdate(deltaTime)
	return true;
end;

-- Called when the effect is dispatched.
function EFFECT:OnDispatch() end;

-- Called when the effect is removed.
function EFFECT:OnRemove() end;

-- Called when the effect is drawn.
function EFFECT:OnDraw() end;

-- A function to dispatch the effect.
function EFFECT:Dispatch()
	if (not self.m_bDispatched) then
		effects.m_spawned[#effects.m_spawned + 1] = self;
		self.m_bDispatched = true;
		self:OnDispatch();
	end;
end;

-- A function to set effect data.
function EFFECT:SetData(key, value)
	self.m_data[key] = value;
end;

-- A function to get effect data.
function EFFECT:GetData(key, default)
	if (self.m_data[key] ~= nil) then
		return self.m_data[key];
	end;
	
	return default;
end;

-- A function to get the effect's class.
function EFFECT:GetClass()
	return self.m_sClassName;
end;

-- A function to get the entity index.
function EFFECT:EntIndex()
	return self.m_iEntIndex;
end;

-- A function to get the effect's unique ID.
function EFFECT:GetUniqueID()
	return self.m_sUniqueID;
end;