--[[
Name: "sh_attributes.lua".
Product: "kuroScript".
--]]

kuroScript.attributes = {};

-- A function to get the default attributes.
function kuroScript.attributes.GetDefault(player, character)
	local attributes = {};
	local default = {};
	local k, v;
	
	-- Loop through each value in a table.
	for k, v in pairs(kuroScript.attribute.stored) do
		if (v.default) then
			attributes[k] = v.default;
		end;
	end;
	
	-- Check if a statement is true.
	if (player) then
		hook.Call("GetPlayerDefaultAttributes", kuroScript.frame, player, character or player._Character, attributes);
	end;
	
	-- Loop through each value in a table.
	for k, v in pairs(attributes) do
		local attributeTable = kuroScript.attribute.Get(k);
		
		-- Check if a statement is true.
		if (attributeTable) then
			local attribute = attributeTable.uniqueID;
			
			-- Set some information.
			if ( !default[attribute] ) then
				default[attribute] = {
					amount = math.min(v, attributeTable.maximum),
					progress = 0
				};
			else
				default[attribute].amount = math.min(default[attribute].amount + v, attributeTable.maximum);
			end;
		end;
	end;
	
	-- Return the default attributes.
	return default;
end;

-- Check if a statement is true.
if (SERVER) then
	function kuroScript.attributes.Progress(player, attribute, amount, gradual)
		local attributeTable = kuroScript.attribute.Get(attribute);
		local attributes = player:QueryCharacter("attributes");
		
		-- Check if a statement is true.
		if (attributeTable) then
			attribute = attributeTable.uniqueID;
			
			-- Check if a statement is true.
			if ( gradual and attributes[attribute] ) then
				if (amount > 0) then
					amount = math.max(amount - ( (amount / attributeTable.maximum) * attributes[attribute].amount ), amount / attributeTable.maximum);
				else
					amount = math.min( (amount / attributeTable.maximum) * attributes[attribute].amount, amount / attributeTable.maximum );
				end;
			end;
			
			-- Set some information.
			amount = amount * kuroScript.config.Get("scale_attribute_progress"):Get();
			
			-- Check if a statement is true.
			if ( !attributes[attribute] ) then
				local defaultAttributes = kuroScript.attributes.GetDefault(player);
				
				-- Check if a statement is true.
				if ( defaultAttributes[attribute] ) then
					attributes[attribute] = defaultAttributes[attribute];
				else
					attributes[attribute] = {amount = 0, progress = 0};
				end;
			elseif (attributes[attribute].amount == attributeTable.maximum) then
				if (amount > 0) then
					return false, "You have reached this attribute's maximum!";
				end;
			end;
			
			-- Set some information.
			local progress = attributes[attribute].progress + amount;
			
			-- Check if a statement is true.
			if (progress >= 100) then
				attributes[attribute].progress = 0;
				
				-- Update the player's attribute status.
				kuroScript.attributes.Update(player, attribute, 1);
				
				-- Set some information.
				local remaining = math.max(progress - 100, 0);
				
				-- Check if a statement is true.
				if (remaining > 0) then
					return kuroScript.attributes.Progress(player, attribute, remaining);
				end;
			elseif (progress < 0) then
				attributes[attribute].progress = 100;
				
				-- Update the player's attribute status.
				kuroScript.attributes.Update(player, attribute, -1);
				
				-- Check if a statement is true.
				if (progress < 0) then
					return kuroScript.attributes.Progress(player, attribute, progress);
				end;
			else
				attributes[attribute].progress = progress;
			end;
			
			-- Check if a statement is true.
			if (attributes[attribute].amount == 0 and attributes[attribute].progress == 0) then
				attributes[attribute] = nil;
			end;
			
			-- Check if a statement is true.
			if ( player:HasInitialized() ) then
				if ( attributes[attribute] ) then
					player._AttributeProgress[attribute] = math.floor(attributes[attribute].progress);
				else
					player._AttributeProgress[attribute] = 0;
				end;
			end;
		else
			return false, "That is not a valid attribute!";
		end;
	end;
	
	-- A function to update a player's attribute status.
	function kuroScript.attributes.Update(player, attribute, amount)
		local attributeTable = kuroScript.attribute.Get(attribute);
		local attributes = player:QueryCharacter("attributes");
		
		-- Check if a statement is true.
		if (attributeTable) then
			attribute = attributeTable.uniqueID;
			
			-- Check if a statement is true.
			if ( !attributes[attribute] ) then
				local defaultAttributes = kuroScript.attributes.GetDefault(player);
				
				-- Check if a statement is true.
				if ( defaultAttributes[attribute] ) then
					attributes[attribute] = defaultAttributes[attribute];
				else
					attributes[attribute] = {amount = 0, progress = 0};
				end;
			elseif (attributes[attribute].amount == attributeTable.maximum) then
				if (amount and amount > 0) then
					return false, "You have reached this attribute's maximum!";
				end;
			end;
			
			-- Set some information.
			attributes[attribute].amount = math.max(attributes[attribute].amount + (amount or 0), 0);
			
			-- Check if a statement is true.
			if (amount) then
				if (amount < 0) then
					kuroScript.player.Alert( player, "- "..math.abs(amount).." "..attributeTable.name, Color(0, 100, 255, 255) );
					
					-- Print a debug message.
					kuroScript.frame:PrintDebug(player:Name().." has lost "..math.abs(amount).." "..attributeTable.name..".");
				elseif (amount > 0) then
					kuroScript.player.Alert( player, "+ "..math.abs(amount).." "..attributeTable.name, Color(255, 150, 0, 255) );
					
					-- Print a debug message.
					kuroScript.frame:PrintDebug(player:Name().." has gained "..math.abs(amount).." "..attributeTable.name..".");
				end;
				
				-- Check if a statement is true.
				if (amount > 0) then
					attributes[attribute].progress = 0;
					
					-- Check if a statement is true.
					if ( player:HasInitialized() ) then
						player._AttributeProgress[attribute] = 0;
						player._AttributeProgressTime = 0;
					end;
				end;
			end;
			
			-- Start a user message.
			umsg.Start("ks_AttributesUpdate", player);
				umsg.Long(attributeTable.index);
				umsg.Long(attributes[attribute].amount);
			umsg.End();
			
			-- Check if a statement is true.
			if (attributes[attribute].amount == 0 and attributes[attribute].progress == 0) then
				attributes[attribute] = nil;
			end;
			
			-- Call a gamemode hook.
			hook.Call("PlayerAttributeUpdated", kuroScript.frame, player, attributeTable, amount);
			
			-- Return true to break the function.
			return true;
		else
			return false, "That is not a valid attribute!";
		end;
	end;
	
	-- A function to clear a player's attribute boosts.
	function kuroScript.attributes.ClearBoosts(player)
		umsg.Start("ks_AttributesBoostClear", player);
		umsg.End();
		
		-- Set some information.
		player._AttributeBoosts = {};
	end;
	
	--- A function to get whether a boost is active for a player.
	function kuroScript.attributes.IsBoostActive(player, identifier, attribute, amount, expire)
		if (player._AttributeBoosts) then
			local attributeTable = kuroScript.attribute.Get(attribute);
			
			-- Check if a statement is true.
			if (attributeTable) then
				attribute = attributeTable.uniqueID;
				
				-- Check if a statement is true.
				if ( player._AttributeBoosts[attribute] ) then
					local attributeBoost = player._AttributeBoosts[attribute][identifier];
					
					-- Check if a statement is true.
					if (attributeBoost) then
						if (amount and expire) then
							return attributeBoost.amount == amount and attributeBoost.expire == expire;
						elseif (amount) then
							return attributeBoost.amount == amount;
						elseif (expire) then
							return attributeBoost.expire == expire;
						else
							return true;
						end;
					end;
				end;
			end;
		end;
	end;
	
	-- A function to boost a player's attribute status.
	function kuroScript.attributes.Boost(player, identifier, attribute, amount, expire, silent)
		local attributeTable = kuroScript.attribute.Get(attribute);
		
		-- Check if a statement is true.
		if (attributeTable) then
			attribute = attributeTable.uniqueID;
			
			-- Check if a statement is true.
			if (amount) then
				if (!identifier) then
					identifier = tostring( {} );
				end;
				
				-- Check if a statement is true.
				if ( !player._AttributeBoosts[attribute] ) then
					player._AttributeBoosts[attribute] = {};
				end;
				
				-- Check if a statement is true.
				if ( !kuroScript.attributes.IsBoostActive(player, identifier, attribute, amount, expire) ) then
					if (expire) then
						player._AttributeBoosts[attribute][identifier] = {
							amount = amount,
							expire = expire,
							finish = CurTime() + expire
						};
					else
						player._AttributeBoosts[attribute][identifier] = {
							amount = amount
						};
					end;
					
					-- Check if a statement is true.
					if (!silent) then
						if (amount > 0) then
							kuroScript.player.Alert( player, "+ "..math.abs(amount).." Temporary "..attributeTable.name, Color(255, 0, 255, 255) );
						elseif (amount < 0) then
							kuroScript.player.Alert( player, "- "..math.abs(amount).." Temporary "..attributeTable.name, Color(0, 255, 255, 255) );
						end;
					end;
					
					-- Start a user message.
					umsg.Start("ks_AttributesBoost", player);
						umsg.Long(attributeTable.index);
						umsg.Long(player._AttributeBoosts[attribute][identifier].amount);
						umsg.Long(player._AttributeBoosts[attribute][identifier].expire);
						umsg.Long(player._AttributeBoosts[attribute][identifier].finish);
						umsg.String(identifier);
					umsg.End();
				end;
					
				-- Return the identifier.
				return identifier;
			elseif (identifier) then
				if ( kuroScript.attributes.IsBoostActive(player, identifier, attribute) ) then
					if ( player._AttributeBoosts[attribute] ) then
						player._AttributeBoosts[attribute][identifier] = nil;
					end;
					
					-- Start a user message.
					umsg.Start("ks_AttributesBoostClear", player);
						umsg.Long(attributeTable.index);
						umsg.String(identifier);
					umsg.End();
				end;
				
				-- Return true to break the function.
				return true;
			elseif ( player._AttributeBoosts[attribute] ) then
				umsg.Start("ks_AttributesBoostClear", player);
					umsg.Long(attributeTable.index);
				umsg.End();
				
				-- Set some information.
				player._AttributeBoosts[attribute] = {};
				
				-- Return true to break the function.
				return true;
			end;
		else
			kuroScript.attributes.ClearBoosts(player);
			
			-- Return true to break the function.
			return true;
		end;
	end;
	
	-- A function to get whether a player has an attribute.
	function kuroScript.attributes.Get(player, attribute, boostless)
		local attributeTable = kuroScript.attribute.Get(attribute);
		
		-- Check if a statement is true.
		if (attributeTable) then
			attribute = attributeTable.uniqueID;
			
			-- Check if a statement is true.
			if ( kuroScript.frame:HasObjectAccess(player, attributeTable) ) then
				local default = player:QueryCharacter("attributes")[attribute];
				local boosts = player._AttributeBoosts[attribute];
				
				-- Check if a statement is true.
				if (boostless) then
					if (default) then
						return default.amount, default.progress;
					end;
				else
					local progress = 0;
					local amount = 0;
					local k, v;
					
					-- Check if a statement is true.
					if (default) then
						amount = amount + default.amount;
						progress = progress + default.progress;
					end;
					
					-- Check if a statement is true.
					if (boosts) then
						for k, v in pairs(boosts) do
							amount = amount + v.amount;
						end;
					end;
					
					-- Set some information.
					amount = math.Clamp(amount, 0, attributeTable.maximum);
					
					-- Check if a statement is true.
					if (amount > 0) then
						return amount, progress;
					end;
				end;
			end;
		end;
	end;
	
	-- Add a hook.
	hook.Add("PlayerSetSharedVars", "kuroScript.attributes.PlayerSetSharedVars", function(player, curTime)
		local k, v;
		
		-- Check if a statement is true.
		if (curTime >= player._AttributeProgressTime) then
			player._AttributeProgressTime = curTime + 10;
			
			-- Loop through each value in a table.
			for k, v in pairs(player._AttributeProgress) do
				local attributeTable = kuroScript.attribute.Get(k);
				
				-- Check if a statement is true.
				if (attributeTable) then
					umsg.Start("ks_AttributeProgress", player);
						umsg.Long(attributeTable.index);
						umsg.Short(v);
					umsg.End();
				end;
			end;
		end;
	end);
	
	-- Add a hook.
	hook.Add("PlayerThink", "kuroScript.attributes.PlayerThink", function(player, curTime, infoTable)
		local k, v;
		
		-- Loop through each value in a table.
		for k, v in pairs(player._AttributeBoosts) do
			for k2, v2 in pairs(v) do
				if (v2.expire and v2.finish) then
					if (curTime >= v2.finish) then
						kuroScript.attributes.Boost(player, k2, k, false);
					else
						local timeLeft = v2.finish - curTime;
						
						-- Check if a statement is true.
						if (timeLeft >= 0) then
							if (!v2.default) then
								v2.default = v2.amount;
							end;
							
							-- Check if a statement is true.
							if (v2.amount < 0) then
								v2.amount = math.max( (math.abs(v2.default) / v2.expire) * timeLeft, 0 );
							else
								v2.amount = math.max( (v2.default / v2.expire) * timeLeft, 0 );
							end;
						end;
					end;
				end;
			end;
		end;
	end);
	
	-- Add a hook.
	hook.Add("PlayerInitialized", "kuroScript.attributes.PlayerInitialized", function(player)
		local k, v;
		
		-- Set some information.
		player._AttributeProgress = {};
		player._AttributeProgressTime = 0;
		
		-- Loop through each value in a table.
		for k, v in pairs(kuroScript.attribute.stored) do
			kuroScript.attributes.Update(player, k);
		end;
		
		-- Loop through each value in a table.
		for k, v in pairs( player:QueryCharacter("attributes") ) do
			player._AttributeProgress[k] = math.floor(v.progress);
		end;
	end);
else
	kuroScript.attributes.stored = {};
	kuroScript.attributes.boosts = {};
	
	-- A function to get whether the local player has an attribute.
	function kuroScript.attributes.Get(attribute, boostless)
		local attributeTable = kuroScript.attribute.Get(attribute);
		
		-- Check if a statement is true.
		if (attributeTable) then
			attribute = attributeTable.uniqueID;
			
			-- Check if a statement is true.
			if ( kuroScript.frame:HasObjectAccess(g_LocalPlayer, attributeTable) ) then
				local default = kuroScript.attributes.stored[attribute];
				local boosts = kuroScript.attributes.boosts[attribute];
				
				-- Check if a statement is true.
				if (boostless) then
					if (default) then
						return default.amount, default.progress;
					end;
				else
					local progress = 0;
					local amount = 0;
					local k, v;
					
					-- Check if a statement is true.
					if (default) then
						amount = amount + default.amount;
						progress = progress + default.progress;
					end;
					
					-- Check if a statement is true.
					if (boosts) then
						for k, v in pairs(boosts) do
							amount = amount + v.amount;
						end;
					end;
					
					-- Set some information.
					amount = math.Clamp(amount, 0, attributeTable.maximum);
					
					-- Check if a statement is true.
					if (amount > 0) then
						return amount, progress;
					end;
				end;
			end;
		end;
	end;
	
	-- Hook a user message.
	usermessage.Hook("ks_AttributesBoostClear", function(msg)
		local index = msg:ReadLong();
		local identifier = msg:ReadString();
		local attributeTable = kuroScript.attribute.Get(index);
		
		-- Check if a statement is true.
		if (attributeTable) then
			local attribute = attributeTable.uniqueID;
			
			-- Check if a statement is true.
			if (identifier and identifier != "") then
				if ( kuroScript.attributes.boosts[attribute] ) then
					kuroScript.attributes.boosts[attribute][identifier] = nil;
				end;
			else
				kuroScript.attributes.boosts[attribute] = nil;
			end;
		else
			kuroScript.attributes.boosts = {};
		end;
		
		-- Check if a statement is true.
		if (kuroScript.menu.GetOpen() and kuroScript.attributes.panel) then
			if (kuroScript.menu.GetActiveTab() == kuroScript.attributes.panel) then
				kuroScript.attributes.panel:Rebuild();
			end;
		end;
	end);
	
	-- Hook a user message.
	usermessage.Hook("ks_AttributesBoost", function(msg)
		local index = msg:ReadLong();
		local amount = msg:ReadLong();
		local expire = msg:ReadLong();
		local finish = msg:ReadLong();
		local identifier = msg:ReadString();
		local attributeTable = kuroScript.attribute.Get(index);
		
		-- Check if a statement is true.
		if (attributeTable) then
			local attribute = attributeTable.uniqueID;
			
			-- Check if a statement is true.
			if ( !kuroScript.attributes.boosts[attribute] ) then
				kuroScript.attributes.boosts[attribute] = {};
			end;
			
			-- Set some information.
			if (amount == 0) then
				kuroScript.attributes.boosts[attribute][identifier] = nil;
			elseif (expire > 0 and finish > 0) then
				kuroScript.attributes.boosts[attribute][identifier] = {
					amount = amount,
					expire = expire,
					finish = finish
				};
			else
				kuroScript.attributes.boosts[attribute][identifier] = {
					amount = amount
				};
			end;
			
			-- Check if a statement is true.
			if (kuroScript.menu.GetOpen() and kuroScript.attributes.panel) then
				if (kuroScript.menu.GetActiveTab() == kuroScript.attributes.panel) then
					kuroScript.attributes.panel:Rebuild();
				end;
			end;
		end;
	end);
	
	-- Hook a user message.
	usermessage.Hook("ks_AttributeProgress", function(msg)
		local index = msg:ReadLong();
		local amount = msg:ReadShort();
		local attributeTable = kuroScript.attribute.Get(index);
		
		-- Check if a statement is true.
		if (attributeTable) then
			local attribute = attributeTable.uniqueID;
			
			-- Check if a statement is true.
			if ( kuroScript.attributes.stored[attribute] ) then
				kuroScript.attributes.stored[attribute].progress = amount;
			else
				kuroScript.attributes.stored[attribute] = {amount = 0, progress = amount};
			end;
		end;
	end);
	
	-- Hook a user message.
	usermessage.Hook("ks_AttributesUpdate", function(msg)
		local index = msg:ReadLong();
		local amount = msg:ReadLong();
		local attributeTable = kuroScript.attribute.Get(index);
		
		-- Check if a statement is true.
		if (attributeTable) then
			local attribute = attributeTable.uniqueID;
			
			-- Check if a statement is true.
			if ( kuroScript.attributes.stored[attribute] ) then
				kuroScript.attributes.stored[attribute].amount = amount;
			else
				kuroScript.attributes.stored[attribute] = {amount = amount, progress = 0};
			end;
		end;
	end);
end;