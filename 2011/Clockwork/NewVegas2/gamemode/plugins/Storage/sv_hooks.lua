--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PLUGIN = PLUGIN;

-- Called when Clockwork has loaded all of the entities.
function PLUGIN:ClockworkInitPostEntity()
	self:LoadStorage();
	self.randomItems = {};
	
	for k, v in pairs(Clockwork.item:GetAll()) do
		if (!v("isRareItem") and !v("isBaseItem")) then
			self.randomItems[#self.randomItems + 1] = {
				v("uniqueID"),
				v("weight")
			};
		end;
	end;
end;

-- Called when data should be saved.
function PLUGIN:SaveData()
	self:SaveStorage();
end;

-- Called when an entity attempts to be auto-removed.
function PLUGIN:EntityCanAutoRemove(entity)
	if (self.storage[entity] or entity:GetNetworkedString("Name") != "") then
		return false;
	end;
end;

-- Called when an entity's menu option should be handled.
function PLUGIN:EntityHandleMenuOption(player, entity, option, arguments)
	local class = entity:GetClass();
	
	if (arguments == "cwContainerOpen") then
		if (Clockwork.entity:IsPhysicsEntity(entity)) then
			local model = string.lower(entity:GetModel());
			
			if (self.containers[model]) then
				local containerWeight = self.containers[model][1];
				
				if (entity.cwPassword) then
					umsg.Start("cwContainerPassword", player);
						umsg.Entity(entity);
					umsg.End();
				else
					self:OpenContainer(player, entity, containerWeight);
				end;
			end;
		end;
	end;
end;

-- Called when a player's prop cost info should be adjusted.
function PLUGIN:PlayerAdjustPropCostInfo(player, entity, info)
	local model = string.lower(entity:GetModel());
	
	if (self.containers[model]) then
		info.name = self.containers[model][2];
	end;
end;