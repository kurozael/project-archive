--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PLUGIN = PLUGIN;

openAura:IncludePrefixed("sh_auto.lua");

-- A function to load the ration machines.
function PLUGIN:LoadVendingMachines()
	local machines = openAura:RestoreSchemaData( "plugins/machines/"..game.GetMap() );
	
	for k, v in pairs(machines) do
		local entity = ents.Create("aura_vendingmachine");
		
		entity:SetPos(v.position);
		entity:Spawn();
		
		if ( IsValid(entity) ) then
			entity:SetAngles(v.angles);
			entity:SetStock(v.stock, v.defaultStock);
		end;
	end;
end;

-- A function to save the ration machines.
function PLUGIN:SaveVendingMachines()
	local machines = {};
	
	for k, v in pairs( ents.FindByClass("aura_vendingmachine") ) do
		machines[#machines + 1] = {
			stock = v:GetStock(),
			angles = v:GetAngles(),
			position = v:GetPos(),
			defaultStock = v:GetDefaultStock()
		};
	end;
	
	openAura:SaveSchemaData("plugins/machines/"..game.GetMap(), machines);
end;