--[[
Name: "sv_autorun.lua".
Product: "kuroScript".
--]]

local MOUNT = MOUNT;

-- Include some prefixed files.
kuroScript.frame:IncludePrefixed("sh_autorun.lua");

-- Whether or not to only display typing notices when visible.
kuroScript.config.Add("inflation_scale", 1, true);

-- A function to update the costs for a player.
function MOUNT:UpdateCosts(player)
	if (self.economy and self.characters) then
		umsg.Start("ks_InflationCost", player);
			umsg.Long(self.characters);
			umsg.Long(self.economy);
		umsg.End();
	end;
end;

-- A function to calculate the default currency inflation.
function MOUNT:CalculateDefaultCurrencyInflation()
	if (self.economy and self.characters) then
		kuroScript.config.Get("default_currency"):Set(self:ConvertCurrency(self.defaultCurrency), nil, nil, true);
	end;
end;

-- A function to calculate the door inflation.
function MOUNT:CalculateDoorInflation()
	if (self.economy and self.characters) then
		kuroScript.config.Get("door_cost"):Set(self:ConvertCurrency(self.doorCost), nil, nil, true);
	end;
end;

-- A function to calculate the inflation.
function MOUNT:CalculateInflation()
	local charactersTable = kuroScript.config.Get("mysql_characters_table"):Get();
	local game = GAME_FOLDER;
	
	-- Perform a threaded query.
	tmysql.query("SELECT SUM(_Currency), COUNT(_Currency) FROM "..charactersTable.." WHERE _Game = \""..game.."\"", function(result)
		if ( result[1] ) then
			local economy = tonumber( result[1][1] );
			local characters = tonumber( result[1][2] );
			
			-- Check if a statement is true.
			if (!economy or economy == 0) then
				economy = 1;
			end;
			
			-- Check if a statement is true.
			if (!characters or characters == 0) then
				characters = 1;
			end;
			
			-- Set some information.
			self.characters = characters;
			self.economy = economy;
			
			-- Loop through each value in a table.
			for k, v in pairs(kuroScript.item.stored) do
				if (v.cost) then
					if (!v.originalCost) then
						v.originalCost = v.cost;
					end;
					
					-- Set some information.
					v.cost = self:ConvertCurrency(v.originalCost);
				end;
			end;
			
			-- Loop through each value in a table.
			for k, v in pairs(kuroScript.contraband.stored) do
				if (v.currency) then
					if (!v.originalCurrency) then
						v.originalCurrency = v.currency;
					end;
					
					-- Set some information.
					v.currency = self:ConvertCurrency(v.originalCurrency);
				end;
			end;
			
			-- Call a gamemode hook.
			hook.Call("InflationRatesCalculated", kuroScript.frame, function(originalCost)
				return self:ConvertCurrency(originalCost);
			end);
			
			-- Calculate some inflation.
			self:CalculateDefaultCurrencyInflation();
			self:CalculateDoorInflation();
			
			-- Check if a statement is true.
			if (self.characters and self.economy) then
				self:UpdateCosts();
			end;
		else
			timer.Simple(1, function()
				self:CalculateInflation();
			end);
		end;
	end);
end;