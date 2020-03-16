--[[
Name: "sh_mounts.lua".
Product: "nexus".
--]]

if (CLIENT) then
	local OVERWATCH = {};

	OVERWATCH.name = "Mounts";
	OVERWATCH.toolTip = "You can load and unload mounts from here.";
	OVERWATCH.doesCreateForm = false;
	
	-- Called to get whether the local player has access to the overwatch.
	function OVERWATCH:HasAccess()
		local unloadTable = nexus.command.Get("MountUnload");
		local loadTable = nexus.command.Get("MountLoad");
		
		if (loadTable and unloadTable) then
			if ( nexus.player.HasFlags(g_LocalPlayer, loadTable.access)
			or nexus.player.HasFlags(g_LocalPlayer, unloadTable.access) ) then
				return true;
			end;
		end;
		
		return false;
	end;

	-- Called when the overwatch should be displayed.
	function OVERWATCH:OnDisplay(overwatchPanel, overwatchForm)
		self.mountButtons = {};
		
		local doneMounts = {};
		local categories = {};
		local mainMounts = {};
		
		for k, v in pairs(nexus.mount.stored) do
			if (v != SCHEMA) then
				categories[v.author] = categories[v.author] or {};
				categories[v.author][#categories[v.author] + 1] = v;
			end;
		end;
		
		for k, v in pairs(categories) do
			table.sort(v, function(a, b)
				return a.name < b.name;
			end);
			
			mainMounts[#mainMounts + 1] = {
				category = k,
				mounts = v
			};
		end;
		
		table.sort(mainMounts, function(a, b)
			return a.category < b.category;
		end);
		
		NEXUS:StartDataStream("OverwatchMntGet", true);
		
		if (#mainMounts > 0) then
			local label = vgui.Create("nx_InfoText", overwatchPanel);
				label:SetText("Mounts colored red are unloaded.");
				label:SetInfoColor("red");
			overwatchPanel.panelList:AddItem(label);
			
			local label = vgui.Create("nx_InfoText", overwatchPanel);
				label:SetText("Mounts colored green are loaded.");
				label:SetInfoColor("green");
			overwatchPanel.panelList:AddItem(label);
			
			local label = vgui.Create("nx_InfoText", overwatchPanel);
				label:SetText("Mounts colored orange are disabled.");
				label:SetInfoColor("orange");
			overwatchPanel.panelList:AddItem(label);
			
			for k, v in ipairs(mainMounts) do
				local mountForm = vgui.Create("DForm", overwatchPanel);
				local panelList = vgui.Create("DPanelList", overwatchPanel);
				
				for k2, v2 in pairs(v.mounts) do
					self.mountButtons[v2.name] = vgui.Create("nx_InfoText", overwatchPanel);
						self.mountButtons[v2.name]:SetText(v2.name);
						self.mountButtons[v2.name]:SetButton(true);
						self.mountButtons[v2.name]:SetToolTip(v2.description);
					panelList:AddItem( self.mountButtons[v2.name] );
					
					if ( nexus.mount.IsDisabled(v2.name) ) then
						self.mountButtons[v2.name]:SetInfoColor("orange");
						self.mountButtons[v2.name]:SetButton(false);
					elseif ( nexus.mount.IsUnloaded(v2.name) ) then
						self.mountButtons[v2.name]:SetInfoColor("red");
					else
						self.mountButtons[v2.name]:SetInfoColor("green");
					end;
					
					-- Called when the button is clicked.
					self.mountButtons[v2.name].DoClick = function(button)
						if ( !nexus.mount.IsDisabled(v2.name) ) then
							if ( nexus.mount.IsUnloaded(v2.name) ) then
								NEXUS:StartDataStream( "OverwatchMntSet", {v2.name, false} );
							else
								NEXUS:StartDataStream( "OverwatchMntSet", {v2.name, true} );
							end;
						end;
					end;
				end;
				
				overwatchPanel.panelList:AddItem(mountForm);
				
				panelList:SetAutoSize(true);
				panelList:SetPadding(4);
				panelList:SetSpacing(4);
				
				mountForm:SetName(v.category);
				mountForm:AddItem(panelList);
				mountForm:SetPadding(4);
			end;
		else
			local label = vgui.Create("nx_InfoText", overwatchPanel);
				label:SetText("There are no mounts installed on the server.");
				label:SetInfoColor("red");
			overwatchPanel.panelList:AddItem(label);
		end;
	end;
	
	-- A function to update the mount buttons.
	function OVERWATCH:UpdateMountButtons()
		for k, v in pairs(self.mountButtons) do
			if ( nexus.mount.IsDisabled(k) ) then
				v:SetInfoColor("orange");
				v:SetButton(false);
			elseif ( nexus.mount.IsUnloaded(k) ) then
				v:SetInfoColor("red");
				v:SetButton(true);
			else
				v:SetInfoColor("green");
				v:SetButton(true);
			end;
		end;
	end;

	nexus.overwatch.Register(OVERWATCH);
	
	NEXUS:HookDataStream("OverwatchMntGet", function(data)
		local overwatchTable = nexus.overwatch.Get("Mounts");
		local unloaded = {};
		
		for k, v in pairs(nexus.mount.stored) do
			if ( unloaded[v.folderName] ) then
				nexus.mount.SetUnloaded(v.name, true);
			else
				nexus.mount.SetUnloaded(v.name, false);
			end;
		end;
		
		if ( overwatchTable and overwatchTable:IsActive() ) then
			overwatchTable:UpdateMountButtons();
		end;
	end);
	
	NEXUS:HookDataStream("OverwatchMntSet", function(data)
		local overwatchTable = nexus.overwatch.Get("Mounts");
		local mount = nexus.mount.Get( data[1] );
		
		if (mount) then
			nexus.mount.SetUnloaded( mount.name, (data[2] == true) );
		end;
		
		if ( overwatchTable and overwatchTable:IsActive() ) then
			overwatchTable:UpdateMountButtons();
		end;
	end);
else
	NEXUS:HookDataStream("OverwatchMntGet", function(player, data)
		NEXUS:StartDataStream(player, "OverwatchMntGet", nexus.mount.unloaded);
	end);
	
	NEXUS:HookDataStream("OverwatchMntSet", function(player, data)
		local unloadTable = nexus.command.Get("MountLoad");
		local loadTable = nexus.command.Get("MountLoad");
		
		if ( data[2] == true and (!loadTable or !nexus.player.HasFlags(player, loadTable.access) ) ) then
			return;
		elseif ( data[2] == false and (!unloadTable or !nexus.player.HasFlags(player, unloadTable.access) ) ) then
			return;
		elseif (type( data[2] ) != "boolean") then
			return;
		end;
		
		local mount = nexus.mount.Get( data[1] );
		
		if (mount) then
			if ( !nexus.mount.IsDisabled(mount.name) ) then
				local success = nexus.mount.SetUnloaded( mount.name, data[2] );
				local recipients = {};
				
				if (success) then
					if ( data[2] ) then
						nexus.player.NotifyAll(player:Name().." has unloaded the "..mount.name.." mount for the next restart.");
					else
						nexus.player.NotifyAll(player:Name().." has loaded the "..mount.name.." mount for the next restart.");
					end;
					
					for k, v in ipairs( g_Player.GetAll() ) do
						if ( v:HasInitialized() ) then
							if ( nexus.player.HasFlags(v, loadTable.access)
							or nexus.player.HasFlags(v, unloadTable.access) ) then
								recipients[#recipients + 1] = v;
							end;
						end;
					end;
					
					if (#recipients > 0) then
						NEXUS:StartDataStream( recipients, "OverwatchMntSet", { mount.name, data[2] } );
					end;
				elseif ( data[2] ) then
					nexus.player.Notify(player, "This mount could not be unloaded!");
				else
					nexus.player.Notify(player, "This mount could not be loaded!");
				end;
			else
				nexus.player.Notify(player, "This mount depends on another mount!");
			end;
		else
			nexus.player.Notify(player, "This mount is not valid!");
		end;
	end);
end;