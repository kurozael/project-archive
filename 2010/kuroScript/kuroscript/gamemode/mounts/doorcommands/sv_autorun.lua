--[[
Name: "sv_autorun.lua".
Product: "kuroScript".
--]]

local MOUNT = MOUNT;

-- Include some prefixed files.
kuroScript.frame:IncludePrefixed("sh_autorun.lua");

-- A function to load the parent data.
function MOUNT:LoadParentData()
	self.parentData = {};
	
	-- Set some information.
	local parentData = kuroScript.frame:RestoreGameData( "mounts/parentdata/"..game.GetMap() );
	local positions = {};
	local k, v;
	
	-- Loop through each value in a table.
	for k, v in ipairs( ents.GetAll() ) do
		if ( ValidEntity(v) ) then
			local position = v:GetPos();
			
			-- Check if a statement is true.
			if (position) then
				positions[ tostring(position) ] = v;
			end;
		end;
	end;
	
	-- Loop through each value in a table.
	for k, v in pairs(parentData) do
		local parent = positions[ tostring(v.parentPosition) ];
		local entity = positions[ tostring(v.position) ];
		
		-- Loop through each value in a table.
		if ( ValidEntity(entity) and ValidEntity(parent) and !self.parentData[entity] ) then
			if ( kuroScript.entity.IsDoor(entity) and kuroScript.entity.IsDoor(parent) ) then
				kuroScript.entity.SetDoorParent(entity, parent);
				
				-- Set some information.
				self.parentData[entity] = parent;
			end;
		end;
	end;
end;

-- A function to load the door data.
function MOUNT:LoadDoorData()
	self.doorData = {};
	
	-- Set some information.
	local positions = {};
	local doorData = kuroScript.frame:RestoreGameData( "mounts/doordata/"..game.GetMap() );
	local k, v;
	
	-- Loop through each value in a table.
	for k, v in ipairs( ents.GetAll() ) do
		if ( ValidEntity(v) ) then
			local position = v:GetPos();
			
			-- Check if a statement is true.
			if (position) then
				positions[ tostring(position) ] = v;
			end;
		end;
	end;
	
	-- Loop through each value in a table.
	for k, v in pairs(doorData) do
		local entity = positions[ tostring(v.position) ];
		
		-- Loop through each value in a table.
		if ( ValidEntity(entity) and !self.doorData[entity] ) then
			if ( kuroScript.entity.IsDoor(entity) ) then
				local data = {
					customName = v.customName,
					position = v.position,
					entity = entity,
					name = v.name,
					text = v.text
				};
				
				-- Check if a statement is true.
				if (!data.customName) then
					kuroScript.entity.SetDoorUnownable(data.entity, true);
					kuroScript.entity.SetDoorName(data.entity, data.name);
					kuroScript.entity.SetDoorText(data.entity, data.text);
				else
					kuroScript.entity.SetDoorName(data.entity, data.name);
				end;
				
				-- Set some information.
				self.doorData[data.entity] = data;
			end;
		end;
	end;
end;

-- A function to save the parent data.
function MOUNT:SaveParentData()
	local parentData = {};
	
	-- Loop through each value in a table.
	for k, v in pairs(self.parentData) do
		if ( ValidEntity(k) and ValidEntity(v) ) then
			parentData[#parentData + 1] = {
				parentPosition = v:GetPos(),
				position = k:GetPos()
			};
		end;
	end;
	
	-- Save some game data.
	kuroScript.frame:SaveGameData("mounts/parentdata/"..game.GetMap(), parentData);
end;

-- A function to save the door data.
function MOUNT:SaveDoorData()
	local doorData = {};
	
	-- Loop through each value in a table.
	for k, v in pairs(self.doorData) do
		local data = {
			customName = v.customName,
			position = v.position,
			name = v.name,
			text = v.text
		};
		
		-- Set some information.
		doorData[#doorData + 1] = data;
	end;
	
	-- Save some game data.
	kuroScript.frame:SaveGameData("mounts/doordata/"..game.GetMap(), doorData);
end;