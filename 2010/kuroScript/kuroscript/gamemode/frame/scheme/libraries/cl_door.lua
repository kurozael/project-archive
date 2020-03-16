--[[
Name: "cl_door.lua".
Product: "kuroScript".
--]]

kuroScript.door = {};

-- A function to get whether the door panel is open.
function kuroScript.door.IsDoorPanelOpen()
	local panel = kuroScript.door.GetPanel();
	
	-- Check if a statement is true.
	if (panel and panel:IsValid() ) then
		return true;
	end;
end;

-- A function to get whether the door is unsellable.
function kuroScript.door.IsUnsellable()
	return kuroScript.door.unsellable;
end;

-- A function to get the door's access list.
function kuroScript.door.GetAccessList()
	return kuroScript.door.accessList;
end;

-- A function to get the door's name.
function kuroScript.door.GetName()
	return kuroScript.door.name;
end;

-- A function to get the door panel.
function kuroScript.door.GetPanel()
	if ( kuroScript.door.panel and kuroScript.door.panel:IsValid() ) then
		return kuroScript.door.panel;
	end;
end;

-- A function to get the door owner.
function kuroScript.door.GetOwner()
	if ( ValidEntity(kuroScript.door.owner) ) then
		return kuroScript.door.owner;
	end;
end;

-- A function to get the door entity.
function kuroScript.door.GetEntity()
	return kuroScript.door.entity;
end;