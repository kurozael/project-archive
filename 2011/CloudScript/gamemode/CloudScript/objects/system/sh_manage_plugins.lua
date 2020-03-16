--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

if (CLIENT) then
	SYSTEM = CloudScript.system:New();
	SYSTEM.name = "Manage Plugins";
	SYSTEM.toolTip = "You can load and unload plugins from here.";
	SYSTEM.doesCreateForm = false;
	
	-- Called to get whether the local player has access to the system.
	function SYSTEM:HasAccess()
		local unloadTable = CloudScript.command:Get("PluginUnload");
		local loadTable = CloudScript.command:Get("PluginLoad");
		
		if (loadTable and unloadTable) then
			if ( CloudScript.player:HasFlags(CloudScript.Client, loadTable.access)
			or CloudScript.player:HasFlags(CloudScript.Client, unloadTable.access) ) then
				return true;
			end;
		end;
		
		return false;
	end;

	-- Called when the system should be displayed.
	function SYSTEM:OnDisplay(systemPanel, systemForm)
		self.pluginButtons = {};
		
		local donePlugins = {};
		local categories = {};
		local mainPlugins = {};
		
		for k, v in pairs(CloudScript.plugin.stored) do
			if (v != CloudScript.schema) then
				categories[v.author] = categories[v.author] or {};
				categories[v.author][#categories[v.author] + 1] = v;
			end;
		end;
		
		for k, v in pairs(categories) do
			table.sort(v, function(a, b)
				return a.name < b.name;
			end);
			
			mainPlugins[#mainPlugins + 1] = {
				category = k,
				plugins = v
			};
		end;
		
		table.sort(mainPlugins, function(a, b)
			return a.category < b.category;
		end);
		
		CloudScript:StartDataStream("SystemPluginGet", true);
		
		if (#mainPlugins > 0) then
			local label = vgui.Create("cloud_InfoText", systemPanel);
				label:SetText("Plugins colored red are unloaded.");
				label:SetInfoColor("red");
			systemPanel.panelList:AddItem(label);
			
			local label = vgui.Create("cloud_InfoText", systemPanel);
				label:SetText("Plugins colored green are loaded.");
				label:SetInfoColor("green");
			systemPanel.panelList:AddItem(label);
			
			local label = vgui.Create("cloud_InfoText", systemPanel);
				label:SetText("Plugins colored orange are disabled.");
				label:SetInfoColor("orange");
			systemPanel.panelList:AddItem(label);
			
			for k, v in ipairs(mainPlugins) do
				local pluginForm = vgui.Create("DForm", systemPanel);
				local panelList = vgui.Create("DPanelList", systemPanel);
				
				for k2, v2 in pairs(v.plugins) do
					self.pluginButtons[v2.name] = vgui.Create("cloud_InfoText", systemPanel);
						self.pluginButtons[v2.name]:SetText(v2.name);
						self.pluginButtons[v2.name]:SetButton(true);
						self.pluginButtons[v2.name]:SetToolTip(v2.description);
					panelList:AddItem( self.pluginButtons[v2.name] );
					
					if ( CloudScript.plugin:IsDisabled(v2.name) ) then
						self.pluginButtons[v2.name]:SetInfoColor("orange");
						self.pluginButtons[v2.name]:SetButton(false);
					elseif ( CloudScript.plugin:IsUnloaded(v2.name) ) then
						self.pluginButtons[v2.name]:SetInfoColor("red");
					else
						self.pluginButtons[v2.name]:SetInfoColor("green");
					end;
					
					-- Called when the button is clicked.
					self.pluginButtons[v2.name].DoClick = function(button)
						if ( !CloudScript.plugin:IsDisabled(v2.name) ) then
							if ( CloudScript.plugin:IsUnloaded(v2.name) ) then
								CloudScript:StartDataStream( "SystemPluginSet", {v2.name, false} );
							else
								CloudScript:StartDataStream( "SystemPluginSet", {v2.name, true} );
							end;
						end;
					end;
				end;
				
				systemPanel.panelList:AddItem(pluginForm);
				
				panelList:SetAutoSize(true);
				panelList:SetPadding(4);
				panelList:SetSpacing(4);
				
				pluginForm:SetName(v.category);
				pluginForm:AddItem(panelList);
				pluginForm:SetPadding(4);
			end;
		else
			local label = vgui.Create("cloud_InfoText", systemPanel);
				label:SetText("There are no plugins installed on the server.");
				label:SetInfoColor("red");
			systemPanel.panelList:AddItem(label);
		end;
	end;
	
	-- A function to update the plugin buttons.
	function SYSTEM:UpdatePluginButtons()
		for k, v in pairs(self.pluginButtons) do
			if ( CloudScript.plugin:IsDisabled(k) ) then
				v:SetInfoColor("orange");
				v:SetButton(false);
			elseif ( CloudScript.plugin:IsUnloaded(k) ) then
				v:SetInfoColor("red");
				v:SetButton(true);
			else
				v:SetInfoColor("green");
				v:SetButton(true);
			end;
		end;
	end;

	CloudScript.system:Register(SYSTEM);
	
	CloudScript:HookDataStream("SystemPluginGet", function(data)
		local systemTable = CloudScript.system:Get("Manage Plugins");
		local unloaded = data;
		
		for k, v in pairs(CloudScript.plugin.stored) do
			if ( unloaded[v.folderName] ) then
				CloudScript.plugin:SetUnloaded(v.name, true);
			else
				CloudScript.plugin:SetUnloaded(v.name, false);
			end;
		end;
		
		if ( systemTable and systemTable:IsActive() ) then
			systemTable:UpdatePluginButtons();
		end;
	end);
	
	CloudScript:HookDataStream("SystemPluginSet", function(data)
		local systemTable = CloudScript.system:Get("Manage Plugins");
		local plugin = CloudScript.plugin:Get( data[1] );
		
		if (plugin) then
			CloudScript.plugin:SetUnloaded( plugin.name, (data[2] == true) );
		end;
		
		if ( systemTable and systemTable:IsActive() ) then
			systemTable:UpdatePluginButtons();
		end;
	end);
else
	CloudScript:HookDataStream("SystemPluginGet", function(player, data)
		CloudScript:StartDataStream(player, "SystemPluginGet", CloudScript.plugin.unloaded);
	end);
	
	CloudScript:HookDataStream("SystemPluginSet", function(player, data)
		local unloadTable = CloudScript.command:Get("PluginLoad");
		local loadTable = CloudScript.command:Get("PluginLoad");
		
		if ( data[2] == true and (!loadTable or !CloudScript.player:HasFlags(player, loadTable.access) ) ) then
			return;
		elseif ( data[2] == false and (!unloadTable or !CloudScript.player:HasFlags(player, unloadTable.access) ) ) then
			return;
		elseif (type( data[2] ) != "boolean") then
			return;
		end;
		
		local plugin = CloudScript.plugin:Get( data[1] );
		
		if (plugin) then
			if ( !CloudScript.plugin:IsDisabled(plugin.name) ) then
				local success = CloudScript.plugin:SetUnloaded( plugin.name, data[2] );
				local recipients = {};
				
				if (success) then
					if ( data[2] ) then
						CloudScript.player:NotifyAll(player:Name().." has unloaded the "..plugin.name.." plugin for the next restart.");
					else
						CloudScript.player:NotifyAll(player:Name().." has loaded the "..plugin.name.." plugin for the next restart.");
					end;
					
					for k, v in ipairs( _player.GetAll() ) do
						if ( v:HasInitialized() ) then
							if ( CloudScript.player:HasFlags(v, loadTable.access)
							or CloudScript.player:HasFlags(v, unloadTable.access) ) then
								recipients[#recipients + 1] = v;
							end;
						end;
					end;
					
					if (#recipients > 0) then
						CloudScript:StartDataStream( recipients, "SystemPluginSet", { plugin.name, data[2] } );
					end;
				elseif ( data[2] ) then
					CloudScript.player:Notify(player, "This plugin could not be unloaded!");
				else
					CloudScript.player:Notify(player, "This plugin could not be loaded!");
				end;
			else
				CloudScript.player:Notify(player, "This plugin depends on another plugin!");
			end;
		else
			CloudScript.player:Notify(player, "This plugin is not valid!");
		end;
	end);
end;