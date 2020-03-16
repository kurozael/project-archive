--[[
Name: "cl_auto.lua".
Product: "nexus".
--]]

local MOUNT = MOUNT;

NEXUS:IncludePrefixed("sh_auto.lua");

MOUNT.activeDisplays = {};
MOUNT.expiredDisplays = NEXUS:RestoreSchemaData( "mounts/displays/"..game.GetMap() );

nexus.setting.AddCheckBox("nexus", "Enable the area display.", "nx_showareas", "Whether or not to show areas as you enter them.");

NEXUS:HookDataStream("AreaDisplays", function(data)
	for k, v in pairs(data) do
		if ( MOUNT:HasExpired(v) ) then
			data[k] = nil;
		end;
	end;
	
	MOUNT.areaDisplays = data;
end);

NEXUS:HookDataStream("AreaAdd", function(data)
	if ( !MOUNT:HasExpired(data) ) then
		MOUNT.areaDisplays[#MOUNT.areaDisplays + 1] = data;
		MOUNT:AddAreaDisplayDisplay(data);
	end;
end);

NEXUS:HookDataStream("AreaRemove", function(data)
	for k, v in pairs(MOUNT.areaDisplays) do
		if (v.name == data.name and v.minimum == data.minimum
		and v.maximum == data.maximum) then
			MOUNT.areaDisplays[k] = nil;
		end;
	end;
end);

-- A function to add an area name display.
function MOUNT:AddAreaDisplayDisplay(areaTable)
	local uniqueID = tostring(areaTable.position);
	local curTime = UnPredictedCurTime();
	
	if ( !self.activeDisplays[uniqueID] ) then
		self.activeDisplays[uniqueID] = {
			areaTable = areaTable,
			fadeTime = curTime + 4,
			target = 255,
			alpha = 0,
		};
	end;
end;

-- A function to get whether an area display has expired.
function MOUNT:HasExpired(areaDisplay)
	if (areaDisplay and areaDisplay.expires) then
		local position = tostring(areaDisplay.position);
		
		if (self.expiredDisplays[position] == areaDisplay.name) then
			return true;
		end;
	end;
	
	return false;
end;

-- A function to set an area display as expired.
function MOUNT:SetExpired(index)
	local areaDisplay = self.areaDisplays[index];
	
	if (areaDisplay and areaDisplay.expires) then
		local position = tostring(areaDisplay.position);
		local name = areaDisplay.name;
		
		self.areaDisplays[index] = nil;
		self.expiredDisplays[position] = name;
		
		NEXUS:SaveSchemaData("mounts/displays/"..game.GetMap(), self.expiredDisplays);
	end;
end;