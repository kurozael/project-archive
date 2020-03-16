--[[
Name: "sv_auto.lua".
Product: "nexus".
--]]

local MOUNT = MOUNT;

NEXUS:IncludePrefixed("sh_auto.lua");

-- A function to load the cash.
function MOUNT:LoadCash()
	local cash = NEXUS:RestoreSchemaData( "mounts/cash/"..game.GetMap() );
	
	for k, v in pairs(cash) do
		local entity = nexus.entity.CreateCash( {key = v.key, uniqueID = v.uniqueID}, v.amount, v.position, v.angles );
		
		if (IsValid(entity) and !v.moveable) then
			local physicsObject = entity:GetPhysicsObject();
			
			if ( IsValid(physicsObject) ) then
				physicsObject:EnableMotion(false);
			end;
		end;
	end;
end;

-- A function to save the cash.
function MOUNT:SaveCash()
	local cash = {};
	
	for k, v in pairs( ents.FindByClass("nx_cash") ) do
		local physicsObject = v:GetPhysicsObject();
		local moveable;
		
		if ( IsValid(physicsObject) ) then
			moveable = physicsObject:IsMoveable();
		end;
		
		cash[#cash + 1] = {
			key = nexus.entity.QueryProperty(v, "key"),
			angles = v:GetAngles(),
			amount = v:GetSharedVar("sh_Amount"),
			moveable = moveable,
			uniqueID = nexus.entity.QueryProperty(v, "uniqueID"),
			position = v:GetPos()
		};
	end;
	
	NEXUS:SaveSchemaData("mounts/cash/"..game.GetMap(), cash);
end;