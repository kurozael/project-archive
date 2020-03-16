--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

CloudScript.door = {};

-- A function to get whether the door panel is open.
function CloudScript.door:IsDoorPanelOpen()
	local panel = self:GetPanel();
	
	if ( IsValid(panel) ) then
		return true;
	end;
end;

-- A function to get whether the door has shared text.
function CloudScript.door:HasSharedText()
	return self.sharedText;
end;

-- A function to get whether the door has shared access.
function CloudScript.door:HasSharedAccess()
	return self.sharedAccess;
end;

-- A function to get whether the door is a parent.
function CloudScript.door:IsParent()
	return self.isParent;
end;

-- A function to get whether the door is unsellable.
function CloudScript.door:IsUnsellable()
	return self.unsellable;
end;

-- A function to get the door's access list.
function CloudScript.door:GetAccessList()
	return self.accessList;
end;

-- A function to get the door's name.
function CloudScript.door:GetName()
	return self.name;
end;

-- A function to get the door panel.
function CloudScript.door:GetPanel()
	if ( IsValid(self.panel) ) then
		return self.panel;
	end;
end;

-- A function to get the door owner.
function CloudScript.door:GetOwner()
	if ( IsValid(self.owner) ) then
		return self.owner;
	end;
end;

-- A function to get the door entity.
function CloudScript.door:GetEntity()
	return self.entity;
end;