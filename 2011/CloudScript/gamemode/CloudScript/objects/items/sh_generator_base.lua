--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = CloudScript.item:New();
ITEM.name = "Generator Base";
ITEM.color = Color(0, 255, 255, 255);
ITEM.model = "models/props_combine/combine_mine01.mdl";
ITEM.batch = 1;
ITEM.weight = 3;
ITEM.category = "Generators";
ITEM.isBaseItem = true;

-- Called when the item's shipment entity should be created.
function ITEM:OnCreateShipmentEntity(player, batch, position)
	return CloudScript.entity:CreateGenerator(player, self.generator.uniqueID, position);
end;

-- Called when the item's drop entity should be created.
function ITEM:OnCreateDropEntity(player, position)
	return CloudScript.entity:CreateGenerator(player, self.generator.uniqueID, position);
end;

-- Called when the item should be setup.
function ITEM:OnSetup()
	if (self.generator) then
		CloudScript.generator:Register(
			self.generator.name,
			self.generator.power,
			self.generator.health,
			self.generator.maximum,
			self.generator.cash,
			self.generator.uniqueID,
			self.generator.powerName,
			self.generator.powerPlural
		);
	end;
end;

-- Called when a player attempts to order the item.
function ITEM:CanOrder(player)
	if (self.PreOrder) then
		self:PreOrder(player);
	end;
	
	if (self.generator) then
		local generator = CloudScript.generator:Get(self.generator.uniqueID);
		local maximum = generator.maximum;
		
		if (self.OnGetMaximum) then
			maximum = self:OnGetMaximum(player, maximum);
		end;
		
		if (generator) then
			if (CloudScript.player:GetPropertyCount(player, self.generator.uniqueID) >= maximum) then
				CloudScript.player:Notify(player, "You have reached the maximum amount of this item!");
				
				return false;
			end;
		end;
	end;
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position)
	if (self.PreDrop) then
		self:PreDrop(player);
	end;
	
	if (self.generator) then
		local generator = CloudScript.generator:Get(self.generator.uniqueID);
		local maximum = generator.maximum;
		
		if (self.OnGetMaximum) then
			maximum = self:OnGetMaximum(player, maximum);
		end;
		
		if (generator) then
			if (CloudScript.player:GetPropertyCount(player, self.generator.uniqueID) == maximum) then
				CloudScript.player:Notify(player, "You have reached the maximum amount of this item!");
				
				return false;
			end;
		end;
	end;
end;

CloudScript.item:Register(ITEM);