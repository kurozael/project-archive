--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

openAura.achievements = {};

if (SERVER) then
	function openAura.achievements:Progress(player, achievement, progress)
		local achievementTable = openAura.achievement:Get(achievement);
		local achievements = player:GetCharacterData("achievements");
		
		if (!progress) then
			progress = 1;
		end;
		
		if (achievementTable) then
			if ( !achievements[achievementTable.uniqueID] ) then
				achievements[achievementTable.uniqueID] = 0;
			end;
			
			local currentAchievement = achievements[achievementTable.uniqueID];
			
			if (currentAchievement < achievementTable.maximum) then
				achievements[achievementTable.uniqueID] = math.Clamp(currentAchievement + progress, 0, achievementTable.maximum);
				
				if (achievements[achievementTable.uniqueID] == achievementTable.maximum) then
					openAura.chatBox:Add(nil, player, "achievement", achievementTable.name);
					
					if (achievementTable.reward) then
						openAura.player:GiveCash(player, achievementTable.reward, achievementTable.name);
					end;
					
					if (achievementTable.OnAchieved) then
						achievementTable:OnAchieved(player);
					end;
				end;
			end;
			
			umsg.Start("aura_AchievementsProgress", player);
				umsg.Long(achievementTable.index);
				umsg.Short( achievements[achievementTable.uniqueID] );
			umsg.End();
		else
			return false, "That is not a valid achievement!";
		end;
	end;
	
	-- A function to get whether a player has a achievement.
	function openAura.achievements:Has(player, achievement)
		local achievementTable = openAura.achievement:Get(achievement);
		
		if (achievementTable) then
			if (self:Get(player, achievement) == achievementTable.maximum) then
				return true;
			end;
		end;
		
		return false;
	end;
	
	-- A function to get a player's achievement.
	function openAura.achievements:Get(player, achievement)
		local achievementTable = openAura.achievement:Get(achievement);
		local achievements = player:GetCharacterData("achievements");
		
		if (achievementTable) then
			return achievements[achievementTable.uniqueID] or 0;
		else
			return 0;
		end;
	end;
else
	openAura.achievements.stored = {};
	
	-- A function to get the achievements panel.
	function openAura.achievements:GetPanel()
		return self.panel;
	end;
	
	-- A function to get the local player's achievement.
	function openAura.achievements:Get(achievement)
		local achievementTable = openAura.achievement:Get(achievement);
		
		if (achievementTable) then
			return self.stored[achievementTable.uniqueID] or 0;
		else
			return 0;
		end;
	end;
	
	-- A function to get whether the local player has a achievement.
	function openAura.achievements:Has(achievement)
		local achievementTable = openAura.achievement:Get(achievement);
		
		if (achievementTable) then
			if (self:Get(achievement) == achievementTable.maximum) then
				return true;
			end;
		end;
		
		return false;
	end;
	
	usermessage.Hook("aura_AchievementsProgress", function(msg)
		local achievement = msg:ReadLong();
		local progress = msg:ReadShort();
		local achievementTable = openAura.achievement:Get(achievement);
		
		if (achievementTable) then
			openAura.achievements.stored[achievementTable.uniqueID] = progress;
			
			if ( openAura.menu:GetOpen() ) then
				local panel = openAura.achievements:GetPanel();
				
				if (panel and openAura.menu:GetActivePanel() == panel) then
					panel:Rebuild();
				end;
			end;
		end;
	end);
	
	usermessage.Hook("aura_AchievementsClear", function(msg)
		openAura.achievements.stored = {};
		
		if ( openAura.menu:GetOpen() ) then
			local panel = openAura.achievements:GetPanel();
			
			if (panel and openAura.menu:GetActivePanel() == panel) then
				panel:Rebuild();
			end;
		end;
	end);
end;