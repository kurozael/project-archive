--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.name = "Broadcaster";
ITEM.cost = 400;
ITEM.model = "models/props_lab/citizenradio.mdl";
ITEM.weight = 3;
ITEM.classes = {CLASS_BLACKMARKET};
ITEM.category = "Communication";
ITEM.business = true;
ITEM.description = "An antique broadcaster, do you think this'll still work?";

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	local trace = player:GetEyeTraceNoCursor();
	
	if (trace.HitPos:Distance( player:GetShootPos() ) <= 192) then
		local entity = ents.Create("aura_broadcaster");
		
		openAura.player:GiveProperty(player, entity);
		
		entity:SetModel(self.model);
		entity:SetPos(trace.HitPos);
		entity:Spawn();
		
		if ( IsValid(itemEntity) ) then
			local physicsObject = itemEntity:GetPhysicsObject();
			
			entity:SetPos( itemEntity:GetPos() );
			entity:SetAngles( itemEntity:GetAngles() );
			
			if ( IsValid(physicsObject) ) then
				if ( !physicsObject:IsMoveable() ) then
					physicsObject = entity:GetPhysicsObject();
					
					if ( IsValid(physicsObject) ) then
						physicsObject:EnableMotion(false);
					end;
				end;
			end;
		else
			openAura.entity:MakeFlushToGround(entity, trace.HitPos, trace.HitNormal);
		end;
	else
		openAura.player:Notify(player, "You cannot drop a broadcaster that far away!");
		
		return false;
	end;
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

openAura.item:Register(ITEM);