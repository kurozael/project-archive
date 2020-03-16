--[[
Name: "sh_attributes.lua".
Product: "nexus".
--]]

nexus.attributes = {};

if (SERVER) then
	function nexus.attributes.Progress(player, attribute, amount, gradual)
		local attributeTable = nexus.attribute.Get(attribute);
		local attributes = player:QueryCharacter("attributes");
		
		if (attributeTable) then
			attribute = attributeTable.uniqueID;
			
			if ( gradual and attributes[attribute] ) then
				if (amount > 0) then
					amount = math.max(amount - ( (amount / attributeTable.maximum) * attributes[attribute].amount ), amount / attributeTable.maximum);
				else
					amount = math.min( (amount / attributeTable.maximum) * attributes[attribute].amount, amount / attributeTable.maximum );
				end;
			end;
			
			amount = amount * nexus.config.Get("scale_attribute_progress"):Get();
			
			if ( attributes[attribute] ) then
				if (attributes[attribute].amount == attributeTable.maximum) then
					if (amount > 0) then
						return false, "You have the maximum of this "..nexus.schema.GetOption("name_attribute", true).."!";
					end;
				end;
			else
				attributes[attribute] = {amount = 0, progress = 0};
			end;
			
			local progress = attributes[attribute].progress + amount;
			local remaining = math.max(progress - 100, 0);
			
			if (progress >= 100) then
				attributes[attribute].progress = 0;
				
				player:UpdateAttribute(attribute, 1);
				
				if (remaining > 0) then
					return player:ProgressAttribute(attribute, remaining);
				end;
			elseif (progress < 0) then
				attributes[attribute].progress = 100;
				
				player:UpdateAttribute(attribute, -1);
				
				if (progress < 0) then
					return player:ProgressAttribute(attribute, progress);
				end;
			else
				attributes[attribute].progress = progress;
			end;
			
			if (attributes[attribute].amount == 0 and attributes[attribute].progress == 0) then
				attributes[attribute] = nil;
			end;
			
			if ( player:HasInitialized() ) then
				if ( attributes[attribute] ) then
					player.attributeProgress[attribute] = math.floor(attributes[attribute].progress);
				else
					player.attributeProgress[attribute] = 0;
				end;
			end;
		else
			return false, "That is not a valid attribute!";
		end;
	end;
	
	-- A function to update a player's attribute.
	function nexus.attributes.Update(player, attribute, amount)
		local attributeTable = nexus.attribute.Get(attribute);
		local attributes = player:QueryCharacter("attributes");
		
		if (attributeTable) then
			attribute = attributeTable.uniqueID;
			
			if ( !attributes[attribute] ) then
				attributes[attribute] = {amount = 0, progress = 0};
			elseif (attributes[attribute].amount == attributeTable.maximum) then
				if (amount and amount > 0) then
					return false, "You have reached the maximum of this "..nexus.schema.GetOption("name_attribute", true).."!";
				end;
			end;
			
			attributes[attribute].amount = math.max(attributes[attribute].amount + (amount or 0), 0);
			
			if (amount and amount > 0) then
				attributes[attribute].progress = 0;
				
				if ( player:HasInitialized() ) then
					player.attributeProgress[attribute] = 0;
					player.attributeProgressTime = 0;
				end;
			end;
			
			umsg.Start("nx_AttributesUpdate", player);
				umsg.Long(attributeTable.index);
				umsg.Long(attributes[attribute].amount);
			umsg.End();
			
			if (attributes[attribute].amount == 0
			and attributes[attribute].progress == 0) then
				attributes[attribute] = nil;
			end;
			
			nexus.mount.Call("PlayerAttributeUpdated", player, attributeTable, amount);
			
			return true;
		else
			return false, "That is not a valid attribute!";
		end;
	end;
	
	-- A function to clear a player's attribute boosts.
	function nexus.attributes.ClearBoosts(player)
		umsg.Start("nx_AttributesBoostClear", player);
		umsg.End();
		
		player.attributeBoosts = {};
	end;
	
	--- A function to get whether a boost is active for a player.
	function nexus.attributes.IsBoostActive(player, identifier, attribute, amount, duration)
		if (player.attributeBoosts) then
			local attributeTable = nexus.attribute.Get(attribute);
			
			if (attributeTable) then
				attribute = attributeTable.uniqueID;
				
				if ( player.attributeBoosts[attribute] ) then
					local attributeBoost = player.attributeBoosts[attribute][identifier];
					
					if (attributeBoost) then
						if (amount and duration) then
							return attributeBoost.amount == amount and attributeBoost.duration == duration;
						elseif (amount) then
							return attributeBoost.amount == amount;
						elseif (duration) then
							return attributeBoost.duration == duration;
						else
							return true;
						end;
					end;
				end;
			end;
		end;
	end;
	
	-- A function to boost a player's attribute.
	function nexus.attributes.Boost(player, identifier, attribute, amount, duration)
		local attributeTable = nexus.attribute.Get(attribute);
		
		if (attributeTable) then
			attribute = attributeTable.uniqueID;
			
			if (amount) then
				if (!identifier) then
					identifier = tostring( {} );
				end;
				
				if ( !player.attributeBoosts[attribute] ) then
					player.attributeBoosts[attribute] = {};
				end;
				
				if ( !nexus.attributes.IsBoostActive(player, identifier, attribute, amount, duration) ) then
					if (duration) then
						player.attributeBoosts[attribute][identifier] = {
							duration = duration,
							endTime = CurTime() + duration,
							default = amount,
							amount = amount,
						};
					else
						player.attributeBoosts[attribute][identifier] = {
							amount = amount
						};
					end;
					
					umsg.Start("nx_AttributesBoost", player);
						umsg.Long(attributeTable.index);
						umsg.Long(player.attributeBoosts[attribute][identifier].amount);
						umsg.Long(player.attributeBoosts[attribute][identifier].duration);
						umsg.Long(player.attributeBoosts[attribute][identifier].endTime);
						umsg.String(identifier);
					umsg.End();
				end;
				
				return identifier;
			elseif (identifier) then
				if ( nexus.attributes.IsBoostActive(player, identifier, attribute) ) then
					if ( player.attributeBoosts[attribute] ) then
						player.attributeBoosts[attribute][identifier] = nil;
					end;
					
					umsg.Start("nx_AttributesBoostClear", player);
						umsg.Long(attributeTable.index);
						umsg.String(identifier);
					umsg.End();
				end;
				
				return true;
			elseif ( player.attributeBoosts[attribute] ) then
				umsg.Start("nx_AttributesBoostClear", player);
					umsg.Long(attributeTable.index);
				umsg.End();
				
				player.attributeBoosts[attribute] = {};
				
				return true;
			end;
		else
			nexus.attributes.ClearBoosts(player);
			
			return true;
		end;
	end;
	
	-- A function to get a player's attribute as a fraction.
	function nexus.attributes.Fraction(player, attribute, fraction, negative)
		local attributeTable = nexus.attribute.Get(attribute);
		
		if (attributeTable) then
			local maximum = attributeTable.maximum;
			local amount = nexus.attributes.Get(player, attribute, nil, negative) or 0;
			
			if (amount < 0 and type(negative) == "number") then
				fraction = negative;
			end;
			
			if ( !attributeTable.cache[amount][fraction] ) then
				attributeTable.cache[amount][fraction] = (fraction / maximum) * amount;
			end;
			
			return attributeTable.cache[amount][fraction];
		end;
	end;
	
	-- A function to get whether a player has an attribute.
	function nexus.attributes.Get(player, attribute, boostless, negative)
		local attributeTable = nexus.attribute.Get(attribute);
		
		if (attributeTable) then
			attribute = attributeTable.uniqueID;
			
			if ( NEXUS:HasObjectAccess(player, attributeTable) ) then
				local maximum = attributeTable.maximum;
				local default = player:QueryCharacter("attributes")[attribute];
				local boosts = player.attributeBoosts[attribute];
				
				if (boostless) then
					if (default) then
						return default.amount, default.progress;
					end;
				else
					local progress = 0;
					local amount = 0;
					
					if (default) then
						amount = amount + default.amount;
						progress = progress + default.progress;
					end;
					
					if (boosts) then
						for k, v in pairs(boosts) do
							amount = amount + v.amount;
						end;
					end;
					
					if (negative) then
						amount = math.Clamp(amount, -maximum, maximum);
					else
						amount = math.Clamp(amount, 0, maximum);
					end;
					
					return math.ceil(amount), progress;
				end;
			end;
		end;
	end;
else
	nexus.attributes.stored = {};
	nexus.attributes.boosts = {};
	
	-- A function to get the attributes panel.
	function nexus.attributes.GetPanel()
		return nexus.attributes.panel;
	end;
	
	-- A function to get the local player's attribute as a fraction.
	function nexus.attributes.Fraction(attribute, fraction, negative)
		local attributeTable = nexus.attribute.Get(attribute);
		
		if (attributeTable) then
			local maximum = attributeTable.maximum;
			local amount = nexus.attributes.Get(attribute, nil, negative) or 0;
			
			if (amount < 0 and type(negative) == "number") then
				fraction = negative;
			end;
			
			if ( !attributeTable.cache[amount][fraction] ) then
				attributeTable.cache[amount][fraction] = (fraction / maximum) * amount;
			end;
			
			return attributeTable.cache[amount][fraction];
		end;
	end;
	
	-- A function to get whether the local player has an attribute.
	function nexus.attributes.Get(attribute, boostless, negative)
		local attributeTable = nexus.attribute.Get(attribute);
		
		if (attributeTable) then
			attribute = attributeTable.uniqueID;
			
			if ( NEXUS:HasObjectAccess(g_LocalPlayer, attributeTable) ) then
				local maximum = attributeTable.maximum;
				local default = nexus.attributes.stored[attribute];
				local boosts = nexus.attributes.boosts[attribute];
				
				if (boostless) then
					if (default) then
						return default.amount, default.progress;
					end;
				else
					local progress = 0;
					local amount = 0;
					
					if (default) then
						amount = amount + default.amount;
						progress = progress + default.progress;
					end;
					
					if (boosts) then
						for k, v in pairs(boosts) do
							amount = amount + v.amount;
						end;
					end;
					
					if (negative) then
						amount = math.Clamp(amount, -maximum, maximum);
					else
						amount = math.Clamp(amount, 0, maximum);
					end;
					
					return math.ceil(amount), progress;
				end;
			end;
		end;
	end;
	
	usermessage.Hook("nx_AttributesBoostClear", function(msg)
		local index = msg:ReadLong();
		local identifier = msg:ReadString();
		local attributeTable = nexus.attribute.Get(index);
		
		if (attributeTable) then
			local attribute = attributeTable.uniqueID;
			
			if (identifier and identifier != "") then
				if ( nexus.attributes.boosts[attribute] ) then
					nexus.attributes.boosts[attribute][identifier] = nil;
				end;
			else
				nexus.attributes.boosts[attribute] = nil;
			end;
		else
			nexus.attributes.boosts = {};
		end;
		
		if ( nexus.menu.GetOpen() ) then
			local panel = nexus.attributes.GetPanel();
			
			if (panel and nexus.menu.GetActivePanel() == panel) then
				panel:Rebuild();
			end;
		end;
	end);
	
	usermessage.Hook("nx_AttributesBoost", function(msg)
		local index = msg:ReadLong();
		local amount = msg:ReadLong();
		local duration = msg:ReadLong();
		local endTime = msg:ReadLong();
		local identifier = msg:ReadString();
		local attributeTable = nexus.attribute.Get(index);
		
		if (attributeTable) then
			local attribute = attributeTable.uniqueID;
			
			if ( !nexus.attributes.boosts[attribute] ) then
				nexus.attributes.boosts[attribute] = {};
			end;
			
			if (amount == 0) then
				nexus.attributes.boosts[attribute][identifier] = nil;
			elseif (duration > 0 and endTime > 0) then
				nexus.attributes.boosts[attribute][identifier] = {
					duration = duration,
					endTime = endTime,
					default = amount,
					amount = amount
				};
			else
				nexus.attributes.boosts[attribute][identifier] = {
					default = amount,
					amount = amount
				};
			end;
			
			if ( nexus.menu.GetOpen() ) then
				local panel = nexus.attributes.GetPanel();
				
				if (panel and nexus.menu.GetActivePanel() == panel) then
					panel:Rebuild();
				end;
			end;
		end;
	end);
	
	usermessage.Hook("nx_AttributeProgress", function(msg)
		local index = msg:ReadLong();
		local amount = msg:ReadShort();
		local attributeTable = nexus.attribute.Get(index);
		
		if (attributeTable) then
			local attribute = attributeTable.uniqueID;
			
			if ( nexus.attributes.stored[attribute] ) then
				nexus.attributes.stored[attribute].progress = amount;
			else
				nexus.attributes.stored[attribute] = {amount = 0, progress = amount};
			end;
		end;
	end);
	
	usermessage.Hook("nx_AttributesUpdate", function(msg)
		local index = msg:ReadLong();
		local amount = msg:ReadLong();
		local attributeTable = nexus.attribute.Get(index);
		
		if (attributeTable) then
			local attribute = attributeTable.uniqueID;
			
			if ( nexus.attributes.stored[attribute] ) then
				nexus.attributes.stored[attribute].amount = amount;
			else
				nexus.attributes.stored[attribute] = {amount = amount, progress = 0};
			end;
		end;
	end);
	
	usermessage.Hook("nx_AttributesClear", function(msg)
		nexus.attributes.stored = {};
		nexus.attributes.boosts = {};
		
		if ( nexus.menu.GetOpen() ) then
			local panel = nexus.attributes.GetPanel();
			
			if (panel and nexus.menu.GetActivePanel() == panel) then
				panel:Rebuild();
			end;
		end;
	end);
end;