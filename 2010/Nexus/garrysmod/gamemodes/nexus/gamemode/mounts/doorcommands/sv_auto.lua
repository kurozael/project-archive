--[[
Name: "sv_auto.lua".
Product: "nexus".
--]]

local MOUNT = MOUNT;

NEXUS:IncludePrefixed("sh_auto.lua");

-- Whether or not doors are hidden by default.
nexus.config.Add("default_doors_hidden", true, nil, nil, nil, nil, true);

-- A function to load the parent data.
function MOUNT:LoadParentData()
	self.parentData = {};
	
	local parentData = NEXUS:RestoreSchemaData( "mounts/parents/"..game.GetMap() );
	local positions = {};
	
	for k, v in ipairs( ents.GetAll() ) do
		if ( IsValid(v) ) then
			local position = v:GetPos();
			
			if (position) then
				positions[ tostring(position) ] = v;
			end;
		end;
	end;
	
	for k, v in pairs(parentData) do
		local parent = positions[ tostring(v.parentPosition) ];
		local entity = positions[ tostring(v.position) ];
		
		if ( IsValid(entity) and IsValid(parent) and !self.parentData[entity] ) then
			if ( nexus.entity.IsDoor(entity) and nexus.entity.IsDoor(parent) ) then
				nexus.entity.SetDoorParent(entity, parent);
				
				self.parentData[entity] = parent;
			end;
		end;
	end;
end;

-- A function to load the door data.
function MOUNT:LoadDoorData()
	self.doorData = {};
	
	local positions = {};
	local doorData = NEXUS:RestoreSchemaData( "mounts/doors/"..game.GetMap() );
	
	for k, v in ipairs( ents.GetAll() ) do
		if ( IsValid(v) ) then
			local position = v:GetPos();
			
			if (position) then
				positions[ tostring(position) ] = v;
			end;
		end;
	end;
	
	for k, v in pairs(doorData) do
		local entity = positions[ tostring(v.position) ];
		
		if ( IsValid(entity) and !self.doorData[entity] ) then
			if ( nexus.entity.IsDoor(entity) ) then
				local data = {
					customName = v.customName,
					position = v.position,
					entity = entity,
					name = v.name,
					text = v.text
				};
				
				if (!data.customName) then
					nexus.entity.SetDoorUnownable(data.entity, true);
					nexus.entity.SetDoorName(data.entity, data.name);
					nexus.entity.SetDoorText(data.entity, data.text);
				else
					nexus.entity.SetDoorName(data.entity, data.name);
				end;
				
				self.doorData[data.entity] = data;
			end;
		end;
	end;
	
	if ( nexus.config.Get("default_doors_hidden"):Get() ) then
		for k, v in pairs(positions) do
			if ( !self.doorData[v] ) then
				nexus.entity.SetDoorHidden(v, true);
			end;
		end;
	end;
end;

-- A function to save the parent data.
function MOUNT:SaveParentData()
	local parentData = {};
	
	for k, v in pairs(self.parentData) do
		if ( IsValid(k) and IsValid(v) ) then
			parentData[#parentData + 1] = {
				parentPosition = v:GetPos(),
				position = k:GetPos()
			};
		end;
	end;
	
	NEXUS:SaveSchemaData("mounts/parents/"..game.GetMap(), parentData);
end;

-- A function to save the door data.
function MOUNT:SaveDoorData()
	local doorData = {};
	
	for k, v in pairs(self.doorData) do
		local data = {
			customName = v.customName,
			position = v.position,
			name = v.name,
			text = v.text
		};
		
		doorData[#doorData + 1] = data;
	end;
	
	NEXUS:SaveSchemaData("mounts/doors/"..game.GetMap(), doorData);
end;