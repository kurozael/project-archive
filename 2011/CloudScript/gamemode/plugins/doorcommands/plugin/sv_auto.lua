--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

CloudScript.config:Add("default_doors_hidden", true, nil, nil, nil, nil, true);

-- A function to load the parent data.
function PLUGIN:LoadParentData()
	self.parentData = {};
	
	local parentData = CloudScript:RestoreSchemaData( "plugins/parents/"..game.GetMap() );
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
			if ( CloudScript.entity:IsDoor(entity) and CloudScript.entity:IsDoor(parent) ) then
				CloudScript.entity:SetDoorParent(entity, parent);
				
				self.parentData[entity] = parent;
			end;
		end;
	end;
end;

-- A function to load the door data.
function PLUGIN:LoadDoorData()
	self.doorData = {};
	
	local positions = {};
	local doorData = CloudScript:RestoreSchemaData( "plugins/doors/"..game.GetMap() );
	
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
			if ( CloudScript.entity:IsDoor(entity) ) then
				local data = {
					customName = v.customName,
					position = v.position,
					entity = entity,
					name = v.name,
					text = v.text
				};
				
				if (!data.customName) then
					CloudScript.entity:SetDoorUnownable(data.entity, true);
					CloudScript.entity:SetDoorName(data.entity, data.name);
					CloudScript.entity:SetDoorText(data.entity, data.text);
				else
					CloudScript.entity:SetDoorName(data.entity, data.name);
				end;
				
				self.doorData[data.entity] = data;
			end;
		end;
	end;
	
	if ( CloudScript.config:Get("default_doors_hidden"):Get() ) then
		for k, v in pairs(positions) do
			if ( !self.doorData[v] ) then
				CloudScript.entity:SetDoorHidden(v, true);
			end;
		end;
	end;
end;

-- A function to save the parent data.
function PLUGIN:SaveParentData()
	local parentData = {};
	
	for k, v in pairs(self.parentData) do
		if ( IsValid(k) and IsValid(v) ) then
			parentData[#parentData + 1] = {
				parentPosition = v:GetPos(),
				position = k:GetPos()
			};
		end;
	end;
	
	CloudScript:SaveSchemaData("plugins/parents/"..game.GetMap(), parentData);
end;

-- A function to save the door data.
function PLUGIN:SaveDoorData()
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
	
	CloudScript:SaveSchemaData("plugins/doors/"..game.GetMap(), doorData);
end;