--[[
Name: "cl_door.lua".
Product: "kuroScript".
--]]

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self:SetTitle( kuroScript.door.GetName() );
	self:SetBackgroundBlur(true);
	self:SetDeleteOnClose(false);
	
	-- Called when the button is clicked.
	function self.btnClose.DoClick(button)
		self:Close(); self:Remove();
		
		-- Disable the screen clicker.
		gui.EnableScreenClicker(false);
	end;
	
	-- Set some information.
	self.settingsPanel = vgui.Create("DPanelList");
 	self.settingsPanel:SetPadding(2);
 	self.settingsPanel:SetSpacing(3);
 	self.settingsPanel:SizeToContents();
	self.settingsPanel:EnableVerticalScrollbar();
	
	-- Set some information.
	self.playersPanel = vgui.Create("DPanelList");
 	self.playersPanel:SetPadding(2);
 	self.playersPanel:SetSpacing(3);
 	self.playersPanel:SizeToContents();
	self.playersPanel:EnableVerticalScrollbar();
	
	-- Set some information.
	self.settingsForm = vgui.Create("DForm");
	self.settingsForm:SetPadding(4);
	self.settingsForm:SetName("Settings");
	
	-- Add an item to the panel list.
	self.settingsPanel:AddItem(self.settingsForm);
	
	-- Set some information.
	self.textEntry = self.settingsForm:TextEntry("Text");
	
	-- Called when enter has been pressed.
	function self.textEntry.OnEnter(textEntry)
		datastream.StreamToServer( "ks_Door", { kuroScript.door.GetEntity(), "Text", textEntry:GetValue() } );
	end;
	
	-- Check if a statement is true.
	if (kuroScript.door.GetOwner() == g_LocalPlayer) then
		if ( !kuroScript.door.IsUnsellable() ) then
			local button = self.settingsForm:Button("Sell");
			local doorCost = kuroScript.config.Get("door_cost"):Get();
			
			-- Called when the button is clicked.
			function button.DoClick(button)
				if (doorCost > 0) then
					Derma_Query("Are you sure that you want to sell this door?", "Sell Door", "Yes", function()
						datastream.StreamToServer( "ks_Door", {kuroScript.door.GetEntity(), "Sell"} );
						
						-- Enable the screen clicker.
						gui.EnableScreenClicker(false);
						
						-- Close and remove the panel.
						self:Close(); self:Remove();
					end, "No", function()
						gui.EnableScreenClicker(false);
					end);
				else
					Derma_Query("Are you sure that you want to unown this door?", "Unown Door", "Yes", function()
						datastream.StreamToServer( "ks_Door", {kuroScript.door.GetEntity(), "Sell"} );
						
						-- Enable the screen clicker.
						gui.EnableScreenClicker(false);
						
						-- Close and remove the panel.
						self:Close(); self:Remove();
					end, "No", function()
						gui.EnableScreenClicker(false);
					end);
				end;
				
				-- Enable the screen clicker.
				gui.EnableScreenClicker(true);
			end;
		end;
	end;
	
	-- Set some information.
	self.propertySheet = vgui.Create("DPropertySheet", self);
	self.propertySheet:AddSheet("Players", self.playersPanel, "gui/silkicons/user", nil, nil, "View players with or without access to this door.");
	self.propertySheet:AddSheet("Settings", self.settingsPanel, "gui/silkicons/wrench", nil, nil, "View this door's settings.");
end;

-- A function to rebuild the panel.
function PANEL:Rebuild()
	self.playersPanel:Clear();
	
	-- Set some information.
	local accessList = kuroScript.door.GetAccessList();
	local categories = {};
	local owner = kuroScript.door.GetOwner();
	local door = kuroScript.door.GetEntity();
	local k2, v2;
	local k, v;
	
	-- Loop through each value in a table.
	for k, v in pairs( g_Player.GetAll() ) do
		if ( v:HasInitialized() ) then
			if (g_LocalPlayer != v and owner != v) then
				local access = accessList[v] or false;
				
				-- Check if a statement is true.
				if ( hook.Call("PlayerShouldShowOnDoorAccessList", kuroScript.frame, v, door, owner) ) then
					local name = hook.Call("GetPlayerDoorAccessName", kuroScript.frame, v, door, owner);
					local index;
					
					-- Check if a statement is true.
					if (access == DOOR_ACCESS_COMPLETE) then
						index = 1;
					elseif (access == DOOR_ACCESS_BASIC) then
						index = 2;
					else
						index = 3;
					end;
					
					-- Check if a statement is true.
					if ( !categories[index] ) then
						categories[index] = {};
					end;
					
					-- Set some information.
					categories[index][#categories[index] + 1] = {v, name};
				end;
			end;
		end;
	end;
	
	-- Check if a statement is true.
	if (table.Count(categories) > 0) then
		for k, v in pairs(categories) do
			local collapsibleCategory = vgui.Create("DCollapsibleCategory", self.playersPanel);
			local panelList = vgui.Create("DPanelList", self.playersPanel);
			
			-- Add an item to the panel list.
			self.playersPanel:AddItem(collapsibleCategory);
			
			-- Sort the items.
			table.sort(v, function(a, b)
				return a[2] < b[2];
			end);
			
			-- Loop through each value in a table.
			for k2, v2 in pairs(v) do
				local button = vgui.Create("DButton", self.playersPanel);
				local access = false;
				local player = v2[1];
				
				-- Check if a statement is true.
				if (k == 1) then
					access = DOOR_ACCESS_COMPLETE;
				elseif (k == 2) then
					access = DOOR_ACCESS_BASIC;
				end;
				
				-- Called when the button is clicked.
				function button.DoClick(button)
					local options;
					
					-- Check if a statement is true.
					if (access == DOOR_ACCESS_COMPLETE) then
						options = {
							["Take Complete Access"] = function()
								datastream.StreamToServer( "ks_Door", {door, "Access", player, access} );
							end
						};
					elseif (access == DOOR_ACCESS_BASIC) then
						options = {
							["Take Basic Access"] = function()
								datastream.StreamToServer( "ks_Door", {door, "Access", player, access} );
							end,
							["Give Complete Access"] = function()
								datastream.StreamToServer( "ks_Door", {door, "Access", player, DOOR_ACCESS_COMPLETE} );
							end
						};
					else
						options = {
							["Give Basic Access"] = function()
								datastream.StreamToServer( "ks_Door", {door, "Access", player, DOOR_ACCESS_BASIC} );
							end,
							["Give Complete Access"] = function()
								datastream.StreamToServer( "ks_Door", {door, "Access", player, DOOR_ACCESS_COMPLETE} );
							end
						};
					end;
					
					-- Check if a statement is true.
					if (options) then
						kuroScript.frame:AddMenuFromData(nil, options);
					end;
				end;
				
				-- Set some information.
				button:SetText( v2[2] );
				
				-- Add an item to the panel list.
				panelList:AddItem(button);
			end;
			
			-- Set some information.
			panelList:SetAutoSize(true);
			panelList:SetPadding(4);
			panelList:SetSpacing(4);
			
			-- Set some information.
			collapsibleCategory:SetPadding(4);
			collapsibleCategory:SetContents(panelList);
			
			-- Check if a statement is true.
			if (k == 1) then
				collapsibleCategory:SetLabel("Complete Access");
				collapsibleCategory:SetCookieName("ks_Door_Complete");
			elseif (k == 2) then
				collapsibleCategory:SetLabel("Basic Access");
				collapsibleCategory:SetCookieName("ks_Door_Basic");
			else
				collapsibleCategory:SetLabel("Zero Access");
				collapsibleCategory:SetCookieName("ks_Door_Zero");
			end;
		end;
	end;
end;
-- Called each frame.
function PANEL:Think()
	local entity = kuroScript.door.GetEntity();
	local scrW = ScrW();
	local scrH = ScrH();
	
	-- Set some information.
	self:SetSize(scrW * 0.5, scrH * 0.75);
	self:SetPos( (scrW / 2) - (self:GetWide() / 2), (scrH / 2) - (self:GetTall() / 2) );
	
	-- Check if a statement is true.
	if (!ValidEntity(entity) or entity:GetPos():Distance( g_LocalPlayer:GetPos() ) > 192) then
		self:Close(); self:Remove();
		
		-- Disable the screen clicker.
		gui.EnableScreenClicker(false);
	end;
end;

-- Called when the layout should be performed.
function PANEL:PerformLayout()
	self.playersPanel:StretchToParent(0, 0, 0, 0);
	self.settingsPanel:StretchToParent(0, 0, 0, 0);
	self.propertySheet:StretchToParent(4, 28, 4, 4);
	
	-- Perform the layour.
	DFrame.PerformLayout(self);
end;

-- Register the panel.
vgui.Register("ks_Door", PANEL, "DFrame");

-- Hook a data stream.
datastream.Hook("ks_PurchaseDoor", function(handler, uniqueID, rawData, procData)
	local doorCost = kuroScript.config.Get("door_cost"):Get();
	
	-- Check if a sttaement is true.
	if (doorCost > 0) then
		Derma_Query("Do you want to purchase this door for "..FORMAT_CURRENCY(kuroScript.config.Get("door_cost"):Get(), nil, true).."?", "Purchase Door", "Yes", function()
			datastream.StreamToServer( "ks_Door", {procData, "Purchase"} );
			
			-- Enable the screen clicker.
			gui.EnableScreenClicker(false);
		end, "No", function()
			gui.EnableScreenClicker(false);
		end);
	else
		Derma_Query("Do you want to own this door?", "Own Door", "Yes", function()
			datastream.StreamToServer( "ks_Door", {procData, "Purchase"} );
			
			-- Enable the screen clicker.
			gui.EnableScreenClicker(false);
		end, "No", function()
			gui.EnableScreenClicker(false);
		end);
	end;

	-- Enable the screen clicker.
	gui.EnableScreenClicker(true);
end);

-- Hook a data stream.
datastream.Hook("ks_DoorAccess", function(handler, uniqueID, rawData, procData)
	if ( kuroScript.door.GetPanel() ) then
		local accessList = kuroScript.door.GetAccessList();
		
		-- Check if a statement is true.
		if ( ValidEntity( procData[1] ) ) then
			if ( procData[2] ) then
				accessList[ procData[1] ] = procData[2];
			else
				accessList[ procData[1] ] = nil;
			end;
			
			-- Rebuild the panel.
			kuroScript.door.GetPanel():Rebuild();
		end;
	end;
end);

-- Hook a data stream.
datastream.Hook("ks_Door", function(handler, uniqueID, rawData, procData)
	if ( kuroScript.door.GetPanel() ) then
		kuroScript.door.GetPanel():Remove();
	end;
	
	-- Enable the screen clicker.
	gui.EnableScreenClicker(true);
	
	-- Set some information.
	kuroScript.door.unsellable = procData.unsellable;
	kuroScript.door.accessList = procData.accessList;
	kuroScript.door.entity = procData.entity;
	kuroScript.door.owner = procData.owner;
	kuroScript.door.name = kuroScript.entity.GetDoorName(procData.entity);
	
	-- Check if a statement is true.
	if (kuroScript.door.name == "") then
		kuroScript.door.name = "Door";
	end;
	
	-- Set some information.
	kuroScript.door.panel = vgui.Create("ks_Door");
	kuroScript.door.panel:MakePopup();
	kuroScript.door.panel:Rebuild();
	
	-- Check if a statement is true.
	if ( !kuroScript.entity.HasOwner(procData.entity) or ValidEntity(procData.owner) ) then
		kuroScript.door.panel.textEntry:SetValue( kuroScript.entity.GetDoorText(procData.entity) );
	end;
end);