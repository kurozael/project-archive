--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PLUGIN = PLUGIN;

openAura:IncludePrefixed("sh_auto.lua");

-- A function to load the cash.
function PLUGIN:LoadCash()
	local cash = openAura:RestoreSchemaData( "plugins/cash/"..game.GetMap() );
	
	for k, v in pairs(cash) do
		local entity = openAura.entity:CreateCash( {key = v.key, uniqueID = v.uniqueID}, v.amount, v.position, v.angles );
		
		if (IsValid(entity) and !v.moveable) then
			local physicsObject = entity:GetPhysicsObject();
			
			if ( IsValid(physicsObject) ) then
				physicsObject:EnableMotion(false);
			end;
		end;
	end;
end;

-- A function to save the cash.
function PLUGIN:SaveCash()
	local cash = {};
	
	for k, v in pairs( ents.FindByClass("aura_cash") ) do
		local physicsObject = v:GetPhysicsObject();
		local moveable;
		
		if ( IsValid(physicsObject) ) then
			moveable = physicsObject:IsMoveable();
		end;
		
		cash[#cash + 1] = {
			key = openAura.entity:QueryProperty(v, "key"),
			angles = v:GetAngles(),
			amount = v:GetDTInt("amount"),
			moveable = moveable,
			uniqueID = openAura.entity:QueryProperty(v, "uniqueID"),
			position = v:GetPos()
		};
	end;
	
	openAura:SaveSchemaData("plugins/cash/"..game.GetMap(), cash);
end;