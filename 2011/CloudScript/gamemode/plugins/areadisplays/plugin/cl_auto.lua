--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

PLUGIN.activeDisplays = {};
PLUGIN.expiredDisplays = CloudScript:RestoreSchemaData( "plugins/displays/"..game.GetMap() );

CloudScript.setting:AddCheckBox("Framework", "Enable the area display.", "cloud_showareas", "Whether or not to show areas as you enter them.");

CloudScript:HookDataStream("AreaDisplays", function(data)
	local PLUGIN = CloudScript.plugin:Get("Area Displays");
		for k, v in pairs(data) do
			if ( PLUGIN:HasExpired(v) ) then
				data[k] = nil;
			end;
		end;
	PLUGIN.areaDisplays = data;
end);

CloudScript:HookDataStream("AreaAdd", function(data)
	local PLUGIN = CloudScript.plugin:Get("Area Displays");
	
	if ( !PLUGIN:HasExpired(data) ) then
		PLUGIN.areaDisplays[#PLUGIN.areaDisplays + 1] = data;
		PLUGIN:AddAreaDisplayDisplay(data);
	end;
end);

CloudScript:HookDataStream("AreaRemove", function(data)
	local PLUGIN = CloudScript.plugin:Get("Area Displays");
	
	for k, v in pairs(PLUGIN.areaDisplays) do
		if (v.name == data.name and v.minimum == data.minimum
		and v.maximum == data.maximum) then
			PLUGIN.areaDisplays[k] = nil;
		end;
	end;
end);

-- A function to add an area name display.
function PLUGIN:AddAreaDisplayDisplay(areaTable)
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
function PLUGIN:HasExpired(areaDisplay)
	if (areaDisplay and areaDisplay.expires) then
		local position = tostring(areaDisplay.position);
		
		if (self.expiredDisplays[position] == areaDisplay.name) then
			return true;
		end;
	end;
	
	return false;
end;

-- A function to set an area display as expired.
function PLUGIN:SetExpired(index)
	local areaDisplay = self.areaDisplays[index];
	
	if (areaDisplay and areaDisplay.expires) then
		local position = tostring(areaDisplay.position);
		local name = areaDisplay.name;
		
		self.areaDisplays[index] = nil;
		self.expiredDisplays[position] = name;
		
		CloudScript:SaveSchemaData("plugins/displays/"..game.GetMap(), self.expiredDisplays);
	end;
end;