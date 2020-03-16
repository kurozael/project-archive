--[[
Name: "cl_hooks.lua".
Product: "HL2 RP".
--]]

local MOUNT = MOUNT;

-- Called when an entity's target ID HUD should be painted.
function MOUNT:HUDPaintEntityTargetID(entity, info)
	if ( kuroScript.entity.IsPhysicsEntity(entity) ) then
		local model = string.lower( entity:GetModel() );
		
		-- Loop through each value in a table.
		if ( self.containers[model] ) then
			if (entity:GetNetworkedString("ks_StorageName") != "") then
				info.y = kuroScript.frame:DrawInfo(entity:GetNetworkedString("ks_StorageName"), info.x, info.y, Color(125, 150, 175, 255), info.alpha);
			else
				info.y = kuroScript.frame:DrawInfo(self.containers[model][2], info.x, info.y, Color(125, 150, 175, 255), info.alpha);
			end;
			
			-- Draw some information.
			info.y = kuroScript.frame:DrawInfo("Press F2", info.x, info.y, COLOR_WHITE, info.alpha);
		end;
	end;
end;