--[[
Name: "sh_combine_lock.lua".
Product: "HL2 RP".
--]]

local ITEM = {};

-- Set some information.
ITEM.name = "Combine Lock";
ITEM.cost = 150;
ITEM.model = "models/props_combine/combine_lock01.mdl";
ITEM.weight = 4;
ITEM.useText = "Place";
ITEM.business = true;
ITEM.vocations = {VOC_CPA_EPU, VOC_OTA_OWC};
ITEM.description = "A Combine device to effectively lock a door.";

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	local trace = player:GetEyeTraceNoCursor();
	local entity = trace.Entity;
	
	-- Check if a statement is true.
	if ( ValidEntity(entity) ) then
		if (entity:GetPos():Distance( player:GetPos() ) <= 192) then
			if ( !ValidEntity(entity._CombineLock) ) then
				if ( !kuroScript.entity.IsDoorHidden(entity) ) then
					local angles = trace.HitNormal:Angle() + Angle(0, 270, 0);
					local position;
					
					-- Check if a statement is true.
					if (string.lower( entity:GetClass() ) == "prop_door_rotating") then
						position = trace;
					else
						position = trace.HitPos + (trace.HitNormal * 4);
					end;
					
					-- Check if a statement is true.
					if ( !ValidEntity( kuroScript.game:ApplyCombineLock(entity, position, angles) ) ) then
						return false;
					elseif ( ValidEntity(entity._Breach) ) then
						entity._Breach:CreateDummyBreach();
						entity._Breach:Explode();
						entity._Breach:Remove();
					end;
				end;
			else
				kuroScript.player.Notify(player, "This entity already has a Combine lock!");
				
				-- Return false to break the function.
				return false;
			end;
		else
			kuroScript.player.Notify(player, "You are not close enough to the entity!");
			
			-- Return false to break the function.
			return false;
		end;
	else
		kuroScript.player.Notify(player, "That is not a valid entity!");
		
		-- Return false to break the function.
		return false;
	end;
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

-- Register the item.
kuroScript.item.Register(ITEM);