--[[
Name: "cl_door.lua".
Product: "nexus".
--]]

nexus.door = {};

-- A function to get whether the door panel is open.
function nexus.door.IsDoorPanelOpen()
	local panel = nexus.door.GetPanel();
	
	if ( IsValid(panel) ) then
		return true;
	end;
end;

-- A function to get whether the door has shared text.
function nexus.door.HasSharedText()
	return nexus.door.sharedText;
end;

-- A function to get whether the door has shared access.
function nexus.door.HasSharedAccess()
	return nexus.door.sharedAccess;
end;

-- A function to get whether the door is a parent.
function nexus.door.IsParent()
	return nexus.door.isParent;
end;

-- A function to get whether the door is unsellable.
function nexus.door.IsUnsellable()
	return nexus.door.unsellable;
end;

-- A function to get the door's access list.
function nexus.door.GetAccessList()
	return nexus.door.accessList;
end;

-- A function to get the door's name.
function nexus.door.GetName()
	return nexus.door.name;
end;

-- A function to get the door panel.
function nexus.door.GetPanel()
	if ( IsValid(nexus.door.panel) ) then
		return nexus.door.panel;
	end;
end;

-- A function to get the door owner.
function nexus.door.GetOwner()
	if ( IsValid(nexus.door.owner) ) then
		return nexus.door.owner;
	end;
end;

-- A function to get the door entity.
function nexus.door.GetEntity()
	return nexus.door.entity;
end;