--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

openAura.door = {};

-- A function to get whether the door panel is open.
function openAura.door:IsDoorPanelOpen()
	local panel = self:GetPanel();
	
	if ( IsValid(panel) ) then
		return true;
	end;
end;

-- A function to get whether the door has shared text.
function openAura.door:HasSharedText()
	return self.sharedText;
end;

-- A function to get whether the door has shared access.
function openAura.door:HasSharedAccess()
	return self.sharedAccess;
end;

-- A function to get whether the door is a parent.
function openAura.door:IsParent()
	return self.isParent;
end;

-- A function to get whether the door is unsellable.
function openAura.door:IsUnsellable()
	return self.unsellable;
end;

-- A function to get the door's access list.
function openAura.door:GetAccessList()
	return self.accessList;
end;

-- A function to get the door's name.
function openAura.door:GetName()
	return self.name;
end;

-- A function to get the door panel.
function openAura.door:GetPanel()
	if ( IsValid(self.panel) ) then
		return self.panel;
	end;
end;

-- A function to get the door owner.
function openAura.door:GetOwner()
	if ( IsValid(self.owner) ) then
		return self.owner;
	end;
end;

-- A function to get the door entity.
function openAura.door:GetEntity()
	return self.entity;
end;