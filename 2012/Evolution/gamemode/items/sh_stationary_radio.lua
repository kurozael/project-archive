--[[
	© 2012 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = Clockwork.item:New();
ITEM.name = "Stationary Radio";
ITEM.cost = 175;
ITEM.batch = 1;
ITEM.model = "models/props_lab/citizenradio.mdl";
ITEM.weight = 3;
ITEM.category = "Entities";
ITEM.business = true;
ITEM.description = "A stationary radio used to communicate with other stations.\n<color=100,255,100>You can pack it away into your inventory at any time!</color>";

--[[ The active frequency of the radio. --]]
ITEM:AddData("Frequency", "", true);

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	local trace = player:GetEyeTraceNoCursor();
	
	if (trace.HitPos:Distance(player:GetShootPos()) <= 192) then
		local entity = ents.Create("cw_radio");
			Clockwork.player:GiveProperty(player, entity);
		entity:SetItemTable(self);
		entity:SetModel(self("model"));
		entity:SetPos(trace.HitPos);
		entity:Spawn();
		
		if (IsValid(itemEntity)) then
			local physicsObject = itemEntity:GetPhysicsObject();
			
			entity:SetPos(itemEntity:GetPos());
			entity:SetAngles(itemEntity:GetAngles());
			
			if (IsValid(physicsObject) and !physicsObject:IsMoveable()) then
				physicsObject = entity:GetPhysicsObject();
				
				if (IsValid(physicsObject)) then
					physicsObject:EnableMotion(false);
				end;
			end;
		else
			Clockwork.entity:MakeFlushToGround(
				entity, trace.HitPos, trace.HitNormal
			);
		end;
	else
		Clockwork.player:Notify(player, "You cannot drop a radio that far away!");
		return false;
	end;
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

if (CLIENT) then
	function ITEM:GetClientSideInfo()
		local frequency = self:GetData("Frequency");
		
		if (frequency != "") then
			return Clockwork:AddMarkupLine("", "Frequency: "..frequency);
		end;
	end;
end;

Clockwork.item:Register(ITEM);