--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

openAura.trophies = {};

if (SERVER) then
	function openAura.trophies:Progress(player, trophy, progress)
		local trophyTable = openAura.trophy:Get(trophy);
		local trophies = player:GetCharacterData("trophies");
		
		if (!progress) then
			progress = 1;
		end;
		
		if (trophyTable) then
			if ( !trophies[trophyTable.uniqueID] ) then
				trophies[trophyTable.uniqueID] = 0;
			end;
			
			local currentTrophy = trophies[trophyTable.uniqueID];
			
			if (currentTrophy < trophyTable.maximum) then
				trophies[trophyTable.uniqueID] = math.Clamp(currentTrophy + progress, 0, trophyTable.maximum);
				
				if (trophies[trophyTable.uniqueID] == trophyTable.maximum) then
					openAura.chatBox:Add(nil, player, "trophy", trophyTable.name);
					
					if (trophyTable.reward) then
						openAura.player:GiveCash(player, trophyTable.reward, trophyTable.name);
					end;
					
					if (trophyTable.OnAchieved) then
						trophyTable:OnAchieved(player);
					end;
				end;
			end;
			
			umsg.Start("aura_TrophiesProgress", player);
				umsg.Long(trophyTable.index);
				umsg.Short( trophies[trophyTable.uniqueID] );
			umsg.End();
		else
			return false, "That is not a valid trophy!";
		end;
	end;
	
	-- A function to get whether a player has a trophy.
	function openAura.trophies:Has(player, trophy)
		local trophyTable = openAura.trophy:Get(trophy);
		
		if (trophyTable) then
			if (openAura.trophies:Get(player, trophy) == trophyTable.maximum) then
				return true;
			end;
		end;
		
		return false;
	end;
	
	-- A function to get a player's trophy.
	function openAura.trophies:Get(player, trophy)
		local trophyTable = openAura.trophy:Get(trophy);
		local trophies = player:GetCharacterData("trophies");
		
		if (trophyTable) then
			return trophies[trophyTable.uniqueID] or 0;
		else
			return 0;
		end;
	end;
else
	openAura.trophies.stored = {};
	
	-- A function to get the trophies panel.
	function openAura.trophies:GetPanel()
		return self.panel;
	end;
	
	-- A function to get the local player's trophy.
	function openAura.trophies:Get(trophy)
		local trophyTable = openAura.trophy:Get(trophy);
		
		if (trophyTable) then
			return self.stored[trophyTable.uniqueID] or 0;
		else
			return 0;
		end;
	end;
	
	-- A function to get whether the local player has a trophy.
	function openAura.trophies:Has(trophy)
		local trophyTable = openAura.trophy:Get(trophy);
		
		if (trophyTable) then
			if (openAura.trophies:Get(trophy) == trophyTable.maximum) then
				return true;
			end;
		end;
		
		return false;
	end;
	
	usermessage.Hook("aura_TrophiesProgress", function(msg)
		local trophy = msg:ReadLong();
		local progress = msg:ReadShort();
		local trophyTable = openAura.trophy:Get(trophy);
		
		if (trophyTable) then
			openAura.trophies.stored[trophyTable.uniqueID] = progress;
			
			if ( openAura.menu:GetOpen() ) then
				local panel = openAura.trophies:GetPanel();
				
				if (panel and openAura.menu:GetActivePanel() == panel) then
					panel:Rebuild();
				end;
			end;
		end;
	end);
	
	usermessage.Hook("aura_TrophiesClear", function(msg)
		openAura.trophies.stored = {};
		
		if ( openAura.menu:GetOpen() ) then
			local panel = openAura.trophies:GetPanel();
			
			if (panel and openAura.menu:GetActivePanel() == panel) then
				panel:Rebuild();
			end;
		end;
	end);
end;