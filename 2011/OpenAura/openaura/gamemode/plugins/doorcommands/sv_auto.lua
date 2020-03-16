--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PLUGIN = PLUGIN;

openAura:IncludePrefixed("sh_auto.lua");

-- Whether or not doors are hidden by default.
openAura.config:Add("default_doors_hidden", true, nil, nil, nil, nil, true);

-- A function to load the parent data.
function PLUGIN:LoadParentData()
	self.parentData = {};
	
	local parentData = openAura:RestoreSchemaData( "plugins/parents/"..game.GetMap() );
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
			if ( openAura.entity:IsDoor(entity) and openAura.entity:IsDoor(parent) ) then
				openAura.entity:SetDoorParent(entity, parent);
				
				self.parentData[entity] = parent;
			end;
		end;
	end;
end;

-- A function to load the door data.
function PLUGIN:LoadDoorData()
	self.doorData = {};
	
	local positions = {};
	local doorData = openAura:RestoreSchemaData( "plugins/doors/"..game.GetMap() );
	
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
			if ( openAura.entity:IsDoor(entity) ) then
				local data = {
					customName = v.customName,
					position = v.position,
					entity = entity,
					name = v.name,
					text = v.text
				};
				
				if (!data.customName) then
					openAura.entity:SetDoorUnownable(data.entity, true);
					openAura.entity:SetDoorName(data.entity, data.name);
					openAura.entity:SetDoorText(data.entity, data.text);
				else
					openAura.entity:SetDoorName(data.entity, data.name);
				end;
				
				self.doorData[data.entity] = data;
			end;
		end;
	end;
	
	if ( openAura.config:Get("default_doors_hidden"):Get() ) then
		for k, v in pairs(positions) do
			if ( !self.doorData[v] ) then
				openAura.entity:SetDoorHidden(v, true);
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
	
	openAura:SaveSchemaData("plugins/parents/"..game.GetMap(), parentData);
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
	
	openAura:SaveSchemaData("plugins/doors/"..game.GetMap(), doorData);
end;