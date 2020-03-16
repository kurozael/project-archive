--[[
Name: "sh_paper.lua".
Product: "HL2 RP".
--]]

local ITEM = {};

-- Set some information.
ITEM.name = "Paper";
ITEM.cost = 5;
ITEM.model = "models/props_c17/paper01.mdl";
ITEM.weight = 0.1;
ITEM.access = "i2";
ITEM.business = true;
ITEM.vocations = {VOC_CPA_EPU, VOC_OTA_OWC};
ITEM.description = "A scrap piece of paper, it's tattered and dirty.";

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	local trace = player:GetEyeTraceNoCursor();
	
	-- Check if a statement is true.
	if (trace.HitPos:Distance( player:GetShootPos() ) <= 192) then
		local entity = ents.Create("ks_paper");
		
		-- Give the property to the player.
		kuroScript.player.GiveProperty(player, entity);
		
		-- Set some information.
		entity:SetPos(trace.HitPos);
		entity:Spawn();
		
		-- Check if a statement is true.
		if ( ValidEntity(itemEntity) ) then
			local physicsObject = itemEntity:GetPhysicsObject();
			
			-- Set some information.
			entity:SetPos( itemEntity:GetPos() );
			entity:SetAngles( itemEntity:GetAngles() );
			
			-- Check if a statement is true.
			if ( ValidEntity(physicsObject) ) then
				if ( !physicsObject:IsMoveable() ) then
					physicsObject = entity:GetPhysicsObject();
					
					-- Check if a statement is true.
					if ( ValidEntity(physicsObject) ) then
						physicsObject:EnableMotion(false);
					end;
				end;
			end;
		else
			kuroScript.entity.MakeFlushToGround(entity, trace.HitPos, trace.HitNormal);
		end;
	else
		kuroScript.player.Notify(player, "You cannot drop paper that far away!");
		
		-- Return false to break the function.
		return false;
	end;
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

-- Register the item.
kuroScript.item.Register(ITEM);