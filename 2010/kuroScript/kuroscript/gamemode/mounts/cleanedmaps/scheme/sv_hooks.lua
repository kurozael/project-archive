--[[
Name: "sv_hooks.lua".
Product: "kuroScript".
--]]

local MOUNT = MOUNT;

-- Called when the map has loaded all the entities.
function MOUNT:InitPostEntity()
	local position = Vector(-1836.6316, 244.3225, 724.9510);
	local k, v;
	
	-- Check if a statement is true.
	if (string.lower( game.GetMap() ) == "rp_tb_city45_v02n") then
		for k, v in ipairs( ents.FindInSphere(Vector(226.2188, 4550, 238.0313), 32) ) do
			if ( kuroScript.entity.IsDoor(v) ) then
				v:Remove(); break;
			end;
		end;
		
		-- Loop through each value in a table.
		for k, v in ipairs( ents.FindInSphere(Vector(2773, 1409, 239), 1024) ) do
			if ( string.find(tostring(v), "func_movelinear") ) then
				v:Remove();
			end;
		end;
		
		-- Loop through each value in a table.
		for k, v in ipairs( ents.FindInSphere(Vector(3589.3997, -6775.1030, 155.1662), 1024) ) do
			if ( string.find(tostring(v), "func_button") ) then
				v:Remove();
			end;
		end;
	end;
	
	-- Check if a statement is true.
	if ( kuroScript.config.Get("remove_map_physics"):Get() ) then
		for k, v in ipairs( kuroScript.frame:GetPhysicsEntities() ) do
			v:Remove();
		end;
	end;
	
	-- Loop through each value in a table.
	for k, v in ipairs(self.removeEntities) do
		for k2, v2 in ipairs( ents.FindByClass(v) ) do
			v2:Remove();
		end;
	end;
	
	-- Loop through each value in a table.
	for k, v in ipairs(ents.FindInSphere(position), 512) do
		if (v:GetModel() == "models/props_interiors/vendingmachinesoda01a.mdl") then
			v:Remove();
		end;
	end;
	
	-- Set some information.
	timer.Simple(1, function()
		local coreOne = ents.FindByName("core_refract");
		local coreTwo = ents.FindByName("core_refract2");
		
		-- Check if a statement is true.
		if ( coreOne and ValidEntity( coreOne[1] ) ) then coreOne[1]:Remove(); end;
		if ( coreTwo and ValidEntity( coreTwo[1] ) ) then coreTwo[1]:Remove(); end;
	end);
	
	-- Check if a statement is true.
	if (string.lower( game.GetMap() ) == "rp_evocity_v2d") then
		local entities = {
			ents.Create("prop_physics"),
			ents.Create("prop_physics"),
			ents.Create("prop_physics")
		};
		
		-- Loop through each value in a table.
		for k, v in ipairs(entities) do
			v:SetModel("models/props_buildings/building_002a.mdl");
			
			-- Check if a statement is true.
			if (k == 3) then
				v:SetPos( Vector(3746.9451, 12137.5527, 847.3724) );
				v:SetAngles( Angle(-0.042, -177.904, 0.374) );
			elseif (k == 2) then
				v:SetPos( Vector(3733.2605, 13399.5029, 847.9582) );
				v:SetAngles( Angle(-0.042, 177.916, 0.374) );
			elseif (k == 1) then
				v:SetPos( Vector(3799.7908, 14593.2178, 800.7903) );
				v:SetAngles( Angle(-0.042, 179.016, 0.374) );
			end;
		end;
		
		-- Loop through each value in a table.
		for k, v in ipairs(entities) do
			v:Spawn();
			
			-- Set some information.
			v.PhysgunDisabled = true;
			v.CanTool = function(entity, player, trace, tool)
				return false;
			end;
			
			-- Check if a statement is true.
			if ( ValidEntity( v:GetPhysicsObject() ) ) then
				v:GetPhysicsObject():EnableMotion(false);
			end;
		end;
	end;
end;