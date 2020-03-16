--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

openAura.upgrades = {};

if (SERVER) then
	function openAura.upgrades:Give(player, upgrade)
		local upgradeTable = openAura.upgrade:Get(upgrade);
		local upgrades = player:GetCharacterData("upgrades");
		
		if (upgradeTable) then
			upgrades[upgradeTable.uniqueID] = true;
			
			umsg.Start("aura_UpgradesGive", player);
				umsg.Long(upgradeTable.index);
			umsg.End();
			
			if (upgradeTable.OnGiven) then
				upgradeTable:OnGiven(player);
			end;
		else
			return false, "That is not a valid upgrade!";
		end;
	end;
	
	-- A function to get whether a player has an upgrade.
	function openAura.upgrades:Has(player, upgrade)
		local upgradeTable = openAura.upgrade:Get(upgrade);
		local upgrades = player:GetCharacterData("upgrades");
		
		if (upgradeTable) then
			if ( upgrades[upgradeTable.uniqueID] ) then
				if (upgradeTable.honor == "perma") then
					return true;
				elseif (upgradeTable.honor == "good") then
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
	openAura.upgrades.stored = {};
	
	-- A function to get the upgrades panel.
	function openAura.upgrades:GetPanel()
		return self.panel;
	end;
	
	-- A function to get whether the local player has an upgrade.
	function openAura.upgrades:Has(upgrade, regardless)
		local upgradeTable = openAura.upgrade:Get(upgrade);
		
		if (upgradeTable) then
			if ( self.stored[upgradeTable.uniqueID] ) then
				if (regardless) then
					return true;
				end;
				
				if (upgradeTable.honor == "perma") then
					return true;
				elseif (upgradeTable.honor == "good") then
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
	
	usermessage.Hook("aura_UpgradesGive", function(msg)
		local upgrade = msg:ReadLong();
		local upgradeTable = openAura.upgrade:Get(upgrade);
		
		if (upgradeTable) then
			openAura.upgrades.stored[upgradeTable.uniqueID] = true;
			
			if ( openAura.menu:GetOpen() ) then
				local panel = openAura.upgrades:GetPanel();
				
				if (panel and openAura.menu:GetActivePanel() == panel) then
					panel:Rebuild();
				end;
			end;
		end;
	end);
	
	usermessage.Hook("aura_UpgradesClear", function(msg)
		openAura.upgrades.stored = {};
		
		if ( openAura.menu:GetOpen() ) then
			local panel = openAura.upgrades:GetPanel();
			
			if (panel and openAura.menu:GetActivePanel() == panel) then
				panel:Rebuild();
			end;
		end;
	end);
end;