--[[
Name: "sv_autorun.lua".
Product: "HL2 RP".
--]]

local MOUNT = MOUNT;

-- Include some prefixed files.
kuroScript.frame:IncludePrefixed("sh_autorun.lua");

-- A function to load the ration machines.
function MOUNT:LoadVendingMachines()
	local machines = kuroScript.frame:RestoreGameData( "mounts/machines/"..game.GetMap() );
	local k, v;
	
	-- Loop through each value in a table.
	for k, v in pairs(machines) do
		local entity = ents.Create("ks_vendingmachine");
		
		-- Set some information.
		entity:SetPos(v.position);
		entity:Spawn();
		
		-- Check if a statement is true.
		if ( ValidEntity(entity) ) then
			entity:SetAngles(v.angles);
			entity:SetStock(v.stock, v.defaultStock);
		end;
	end;
end;

-- A function to save the ration machines.
function MOUNT:SaveVendingMachines()
	local machines = {};
	
	-- Loop through each value in a table.
	for k, v in pairs( ents.FindByClass("ks_vendingmachine") ) do
		machines[#machines + 1] = {
			stock = v:GetStock(),
			angles = v:GetAngles(),
			position = v:GetPos(),
			defaultStock = v:GetDefaultStock()
		};
	end;
	
	-- Save some game data.
	kuroScript.frame:SaveGameData("mounts/machines/"..game.GetMap(), machines);
end;