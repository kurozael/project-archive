--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

openAura.augments = {};

if (SERVER) then
	function openAura.augments:Give(player, augment)
		local augmentTable = openAura.augment:Get(augment);
		local augments = player:GetCharacterData("augments");
		
		if (augmentTable) then
			augments[augmentTable.uniqueID] = true;
			
			umsg.Start("aura_AugmentsGive", player);
				umsg.Long(augmentTable.index);
			umsg.End();
			
			if (augmentTable.OnGiven) then
				augmentTable:OnGiven(player);
			end;
			
			if (table.Count(augments) >= 5) then
				openAura.victories:Progress(player, VIC_TESTSUBJECT);
			end;
		else
			return false, "That is not a valid augment!";
		end;
	end;
	
	-- A function to get whether a player has an augment.
	function openAura.augments:Has(player, augment)
		local augmentTable = openAura.augment:Get(augment);
		local augments = player:GetCharacterData("augments");
		
		if (augmentTable) then
			if ( augments[augmentTable.uniqueID] ) then
				if (augmentTable.honor == "perma") then
					return true;
				elseif (augmentTable.honor == "good") then
					return player:IsGood();
				else
					return player:IsBad();
				end;
			else
				return false;
			end;
		else
			return false;
		end;
	end;
else
	openAura.augments.stored = {};
	
	-- A function to get the augments panel.
	function openAura.augments:GetPanel()
		return self.panel;
	end;
	
	-- A function to get whether the local player has an augment.
	function openAura.augments:Has(augment, regardless)
		local augmentTable = openAura.augment:Get(augment);
		
		if (augmentTable) then
			if ( self.stored[augmentTable.uniqueID] ) then
				if (regardless) then
					return true;
				end;
				
				if (augmentTable.honor == "perma") then
					return true;
				elseif (augmentTable.honor == "good") then
					return openAura.Client:IsGood();
				else
					return openAura.Client:IsBad();
				end;
			else
				return false;
			end;
		else
			return false;
		end;
	end;
	
	usermessage.Hook("aura_AugmentsGive", function(msg)
		local augment = msg:ReadLong();
		local augmentTable = openAura.augment:Get(augment);
		
		if (augmentTable) then
			openAura.augments.stored[augmentTable.uniqueID] = true;
			
			if ( openAura.menu:GetOpen() ) then
				local panel = openAura.augments:GetPanel();
				
				if (panel and openAura.menu:GetActivePanel() == panel) then
					panel:Rebuild();
				end;
			end;
		end;
	end);
	
	usermessage.Hook("aura_AugmentsClear", function(msg)
		openAura.augments.stored = {};
		
		if ( openAura.menu:GetOpen() ) then
			local panel = openAura.augments:GetPanel();
			
			if (panel and openAura.menu:GetActivePanel() == panel) then
				panel:Rebuild();
			end;
		end;
	end);
end;