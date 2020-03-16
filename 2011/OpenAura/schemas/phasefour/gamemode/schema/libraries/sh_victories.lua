--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

openAura.victories = {};

if (SERVER) then
	function openAura.victories:Progress(player, victory, progress)
		local victoryTable = openAura.victory:Get(victory);
		local victories = player:GetCharacterData("victories");
		
		if (!progress) then
			progress = 1;
		end;
		
		if (victoryTable) then
			if ( !victories[victoryTable.uniqueID] ) then
				victories[victoryTable.uniqueID] = 0;
			end;
			
			local currentVictory = victories[victoryTable.uniqueID];
			
			if (currentVictory < victoryTable.maximum) then
				victories[victoryTable.uniqueID] = math.Clamp(currentVictory + progress, 0, victoryTable.maximum);
				
				if (victories[victoryTable.uniqueID] == victoryTable.maximum) then
					openAura.chatBox:Add(nil, player, "victory", victoryTable.name);
					
					if (victoryTable.reward) then
						openAura.player:GiveCash(player, victoryTable.reward, victoryTable.name);
					end;
					
					if (victoryTable.OnAchieved) then
						victoryTable:OnAchieved(player);
					end;
				end;
			end;
			
			umsg.Start("aura_VictoriesProgress", player);
				umsg.Long(victoryTable.index);
				umsg.Short( victories[victoryTable.uniqueID] );
			umsg.End();
		else
			return false, "That is not a valid victory!";
		end;
	end;
	
	-- A function to get whether a player has a victory.
	function openAura.victories:Has(player, victory)
		local victoryTable = openAura.victory:Get(victory);
		
		if (victoryTable) then
			if (openAura.victories:Get(player, victory) == victoryTable.maximum) then
				return true;
			end;
		end;
		
		return false;
	end;
	
	-- A function to get a player's victory.
	function openAura.victories:Get(player, victory)
		local victoryTable = openAura.victory:Get(victory);
		local victories = player:GetCharacterData("victories");
		
		if (victoryTable) then
			return victories[victoryTable.uniqueID] or 0;
		else
			return 0;
		end;
	end;
else
	openAura.victories.stored = {};
	
	-- A function to get the victories panel.
	function openAura.victories:GetPanel()
		return self.panel;
	end;
	
	-- A function to get the local player's victory.
	function openAura.victories:Get(victory)
		local victoryTable = openAura.victory:Get(victory);
		
		if (victoryTable) then
			return self.stored[victoryTable.uniqueID] or 0;
		else
			return 0;
		end;
	end;
	
	-- A function to get whether the local player has a victory.
	function openAura.victories:Has(victory)
		local victoryTable = openAura.victory:Get(victory);
		
		if (victoryTable) then
			if (openAura.victories:Get(victory) == victoryTable.maximum) then
				return true;
			end;
		end;
		
		return false;
	end;
	
	usermessage.Hook("aura_VictoriesProgress", function(msg)
		local victory = msg:ReadLong();
		local progress = msg:ReadShort();
		local victoryTable = openAura.victory:Get(victory);
		
		if (victoryTable) then
			openAura.victories.stored[victoryTable.uniqueID] = progress;
			
			if ( openAura.menu:GetOpen() ) then
				local panel = openAura.victories:GetPanel();
				
				if (panel and openAura.menu:GetActivePanel() == panel) then
					panel:Rebuild();
				end;
			end;
		end;
	end);
	
	usermessage.Hook("aura_VictoriesClear", function(msg)
		openAura.victories.stored = {};
		
		if ( openAura.menu:GetOpen() ) then
			local panel = openAura.victories:GetPanel();
			
			if (panel and openAura.menu:GetActivePanel() == panel) then
				panel:Rebuild();
			end;
		end;
	end);
end;