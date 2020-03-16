--[[
Name: "sh_breach.lua".
Product: "HL2 RP".
--]]

local ITEM = {};

-- Set some information.
ITEM.name = "Breach";
ITEM.cost = 25;
ITEM.model = "models/props_wasteland/prison_padlock001a.mdl";
ITEM.plural = "Breaches";
ITEM.weight = 1.5;
ITEM.access = "V";
ITEM.useText = "Place";
ITEM.classes = {CLASS_CPA, CLASS_OTA};
ITEM.business = true;
ITEM.blacklist = {VOC_CPA_RCT};
ITEM.description = "A small device which looks similiar to a padlock.";

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	local trace = player:GetEyeTraceNoCursor();
	local entity = trace.Entity;
	
	-- Check if a statement is true.
	if ( ValidEntity(entity) ) then
		if (entity:GetPos():Distance( player:GetShootPos() ) <= 192) then
			if ( !ValidEntity(entity._Breach) ) then
				if ( kuroScript.mount.Call("PlayerCanBreachEntity", player, entity) ) then
					local breach = ents.Create("ks_breach"); breach:Spawn();
					
					-- Set some information.
					breach:SetBreachEntity(entity, trace);
				else
					kuroScript.player.Notify(player, "This entity cannot be breached!");
					
					-- Return false to break the function.
					return false;
				end;
			else
				kuroScript.player.Notify(player, "This entity already has a breach!");
				
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