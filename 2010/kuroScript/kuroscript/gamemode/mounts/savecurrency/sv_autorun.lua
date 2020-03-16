--[[
Name: "sv_autorun.lua".
Product: "kuroScript".
--]]

local MOUNT = MOUNT;

-- Include some prefixed files.
kuroScript.frame:IncludePrefixed("sh_autorun.lua");

-- A function to load the currency.
function MOUNT:LoadCurrency()
	local currency = kuroScript.frame:RestoreGameData( "mounts/currency/"..game.GetMap() );
	local k, v;
	
	-- Loop through each value in a table.
	for k, v in pairs(currency) do
		local entity = kuroScript.entity.CreateCurrency( {key = v.key, uniqueID = v.uniqueID}, v.amount, v.position, v.angles );
		
		-- Check if a statement is true.
		if (ValidEntity(entity) and !v.moveable) then
			local physicsObject = entity:GetPhysicsObject();
			
			-- Check if a statement is true.
			if ( ValidEntity(physicsObject) ) then
				physicsObject:EnableMotion(false);
			end;
		end;
	end;
end;

-- A function to save the currency.
function MOUNT:SaveCurrency()
	local currency = {};
	
	-- Loop through each value in a table.
	for k, v in pairs( ents.FindByClass("ks_currency") ) do
		local physicsObject = v:GetPhysicsObject();
		local moveable;
		
		-- Check if a statement is true.
		if ( ValidEntity(physicsObject) ) then
			moveable = physicsObject:IsMoveable();
		end;
		
		-- Set some information.
		currency[#currency + 1] = {
			key = kuroScript.entity.QueryProperty(v, "key"),
			angles = v:GetAngles(),
			amount = v:GetSharedVar("ks_Amount"),
			moveable = moveable,
			uniqueID = kuroScript.entity.QueryProperty(v, "uniqueID"),
			position = v:GetPos()
		};
	end;
	
	-- Save some game data.
	kuroScript.frame:SaveGameData("mounts/currency/"..game.GetMap(), currency);
end;