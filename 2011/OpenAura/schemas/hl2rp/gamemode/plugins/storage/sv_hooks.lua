--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PLUGIN = PLUGIN;

-- Called when OpenAura has loaded all of the entities.
function PLUGIN:OpenAuraInitPostEntity()
	self:LoadStorage();
	self.randomItems = {};
	
	for k, v in pairs( openAura.item:GetAll() ) do
		if (!v.isRareItem and !v.isBaseItem) then
			self.randomItems[#self.randomItems + 1] = {
				v.uniqueID,
				v.weight
			};
		end;
	end;
end;

-- Called when data should be saved.
function PLUGIN:SaveData()
	self:SaveStorage();
end;

-- Called when a player attempts to breach an entity.
function PLUGIN:PlayerCanBreachEntity(player, entity)
	if (entity.inventory and entity.password) then
		return true;
	end;
end;

-- Called when an entity attempts to be auto-removed.
function PLUGIN:EntityCanAutoRemove(entity)
	if (self.storage[entity] or entity:GetNetworkedString("name") != "") then
		return false;
	end;
end;

-- Called when an entity's menu option should be handled.
function PLUGIN:EntityHandleMenuOption(player, entity, option, arguments)
	local class = entity:GetClass();
	
	if (class == "aura_locker" and arguments == "aura_containerOpen") then
		self:OpenContainer(player, entity);
	elseif (arguments == "aura_containerOpen") then
		if ( openAura.entity:IsPhysicsEntity(entity) ) then
			local model = string.lower( entity:GetModel() );
			
			if ( self.containers[model] ) then
				local containerWeight = self.containers[model][1];
				
				if (!entity.password or entity.breached) then
					self:OpenContainer(player, entity, containerWeight);
				else
					umsg.Start("aura_ContainerPassword", player);
						umsg.Entity(entity);
					umsg.End();
				end;
			end;
		end;
	end;
end;

-- Called when an entity has been breached.
function PLUGIN:EntityBreached(entity, activator)
	if (entity.inventory and entity.password) then
		entity.breached = true;
		
		openAura:CreateTimer("reset_breach_"..entity:EntIndex(), 120, 1, function()
			if ( IsValid(entity) ) then
				entity.breached = nil;
			end;
		end);
	end;
end;

-- Called when an entity is removed.
function PLUGIN:EntityRemoved(entity)
	if (IsValid(entity) and !entity.areBelongings) then
		if (entity.inventory and table.Count(entity.inventory) > 0) then
			for k, v in pairs(entity.inventory) do
				if (v > 0) then
					for i = 1, v do
						local item = openAura.entity:CreateItem( nil, k, entity:GetPos() + Vector( 0, 0, math.random(1, 48) ), entity:GetAngles() );
						
						openAura.entity:CopyOwner(entity, item);
					end;
				end;
			end;
		end;
			
		if (entity.cash and entity.cash > 0) then
			openAura.entity:CreateCash( nil, entity.cash, entity:GetPos() + Vector( 0, 0, math.random(1, 48) ) );
		end;
			
		entity.inventory = nil;
		entity.cash = nil;
	end;
end;

-- Called when a player's prop cost info should be adjusted.
function PLUGIN:PlayerAdjustPropCostInfo(player, entity, info)
	local model = string.lower( entity:GetModel() );
	
	if ( self.containers[model] ) then
		info.name = self.containers[model][2];
	end;
end;