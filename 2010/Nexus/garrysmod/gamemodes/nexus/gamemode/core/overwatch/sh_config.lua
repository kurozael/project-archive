--[[
Name: "sh_config.lua".
Product: "nexus".
--]]

if (CLIENT) then
	local OVERWATCH = {};

	OVERWATCH.name = "Config";
	OVERWATCH.toolTip = "An easier way of editing the nexus config.";
	OVERWATCH.doesCreateForm = false;
	
	-- Called to get whether the local player has access to the overwatch.
	function OVERWATCH:HasAccess()
		local commandTable = nexus.command.Get("CfgSetVar");
		
		if ( commandTable and nexus.player.HasFlags(g_LocalPlayer, commandTable.access) ) then
			return true;
		else
			return false;
		end;
	end;

	-- Called when the overwatch should be displayed.
	function OVERWATCH:OnDisplay(overwatchPanel, overwatchForm)
		local overwatchValues = nil;
		
		self.infoText = vgui.Create("nx_InfoText", overwatchPanel);
			self.infoText:SetText("Click on a config key to begin editing the config value.");
			self.infoText:SetInfoColor("blue");
		overwatchPanel.panelList:AddItem(self.infoText);
		
		self.configForm = vgui.Create("DForm", overwatchPanel);
			self.configForm:SetName("Config");
			self.configForm:SetPadding(4);
		overwatchPanel.panelList:AddItem(self.configForm);
		
		if (!self.activeKey) then
			NEXUS:StartDataStream("OverwatchCfgKeys", true);
		else
			overwatchValues = nexus.config.GetOverwatch(self.activeKey.name);
			
			self.infoText:SetText("Now you can start to edit the config value, or click another config key.");
		end;
		
		self.comboBox = self.configForm:ComboBox("Key");
		self.comboBox:SetHeight(256);
		self.comboBox:SetMultiple(false);
		self:PopulateComboBox();
		
		if (overwatchValues) then
			self.configForm:SetName(self.activeKey.name);
			
			for k, v in ipairs( NEXUS:ExplodeString("\n", overwatchValues.help) ) do
				self.configForm:Help(v);
			end;
			
			self.comboBox:SetText(self.activeKey.name);
			
			if (self.activeKey.value != nil) then
				local mapEntry = self.configForm:TextEntry("Map");
				local valueType = type(self.activeKey.value);
				
				if (valueType == "string") then
					local textEntry = self.configForm:TextEntry("Value");
						textEntry:SetValue(self.activeKey.value);
					local okayButton = self.configForm:Button("Okay");
						
					-- Called when the button is clicked.
					function okayButton.DoClick(okayButton)
						NEXUS:StartDataStream( "OverwatchCfgSet", {
							key = self.activeKey.name,
							value = textEntry:GetValue(),
							useMap = mapEntry:GetValue()
						} );
					end;
				elseif (valueType == "number") then
					local numSlider = self.configForm:NumSlider("Value", nil, overwatchValues.minimum,
					overwatchValues.maximum, overwatchValues.decimals);
						numSlider:SetValue(self.activeKey.value);
					local okayButton = self.configForm:Button("Okay");
						
					-- Called when the button is clicked.
					function okayButton.DoClick(okayButton)
						NEXUS:StartDataStream( "OverwatchCfgSet", {
							key = self.activeKey.name,
							value = numSlider:GetValue(),
							useMap = mapEntry:GetValue()
						} );
					end;
				elseif (valueType == "boolean") then
					local checkBox = self.configForm:CheckBox("On");
						checkBox:SetValue(self.activeKey.value);
					local okayButton = self.configForm:Button("Okay");
						
					-- Called when the button is clicked.
					function okayButton.DoClick(okayButton)
						NEXUS:StartDataStream( "OverwatchCfgSet", {
							key = self.activeKey.name,
							value = checkBox:GetChecked(),
							useMap = mapEntry:GetValue()
						} );
					end;
				end;
			end;
		end;
	end;
	
	-- A function to populate the overwatch's combo box.
	function OVERWATCH:PopulateComboBox()
		if (self.configKeys) then
			local defaultConfigItem = nil;
			
			for k, v in ipairs(self.configKeys) do
				local overwatchValues = nexus.config.GetOverwatch(v);
				
				if (overwatchValues) then
					local comboBoxItem = self.comboBox:AddItem(v);
						comboBoxItem:SetToolTip(overwatchValues.help);
						
					-- Called when the combo box item is clicked.
					function comboBoxItem.DoClick(comboBoxItem)
						NEXUS:StartDataStream("OverwatchCfgValue", v);
					end;
					
					if (self.activeKey and self.activeKey.name == v) then
						defaultConfigItem = comboBoxItem;
					end;
				end;
			end;
			
			if (defaultConfigItem) then
				self.comboBox:SelectItem(defaultConfigItem, true);
			end;
		end;
	end;

	nexus.overwatch.Register(OVERWATCH);
	
	NEXUS:HookDataStream("OverwatchCfgKeys", function(data)
		local overwatchTable = nexus.overwatch.Get("Config");
		
		if (overwatchTable) then
			overwatchTable.configKeys = data;
			overwatchTable:PopulateComboBox();
		end;
	end);
	
	NEXUS:HookDataStream("OverwatchCfgValue", function(data)
		local overwatchTable = nexus.overwatch.Get("Config");
		
		if (overwatchTable) then
			overwatchTable.activeKey = { name = data[1], value = data[2] };
			overwatchTable:Rebuild();
		end;
	end);
else
	NEXUS:HookDataStream("OverwatchCfgSet", function(player, data)
		local commandTable = nexus.command.Get("CfgSetVar");
		
		if ( commandTable and nexus.player.HasFlags(player, commandTable.access) ) then
			local configObject = nexus.config.Get(data.key);
			
			if ( configObject:IsValid() ) then
				local keyPrefix = "";
				local useMap = data.useMap;
				
				if (useMap == "") then
					useMap = nil;
				end;
				
				if (useMap) then
					useMap = string.lower( string.Replace(useMap, ".bsp", "") );
					keyPrefix = useMap.."'s ";
					
					if ( !file.Exists("../maps/"..useMap..".bsp") ) then
						nexus.player.Notify(player, useMap.." is not a valid map!");
						
						return;
					end;
				end;
				
				if ( !configObject:Query("isStatic") ) then
					value = configObject:Set(data.value, useMap);
					
					if (value != nil) then
						local printValue = tostring(value);
						
						if ( configObject:Query("isPrivate") ) then
							if ( configObject:Query("needsRestart") ) then
								nexus.player.NotifyAll(player:Name().." set "..keyPrefix..data.key.." to '"..string.rep( "*", string.len(printValue) ).."' for the next restart.");
							else
								nexus.player.NotifyAll(player:Name().." set "..keyPrefix..data.key.." to '"..string.rep( "*", string.len(printValue) ).."'.");
							end;
						elseif ( configObject:Query("needsRestart") ) then
							nexus.player.NotifyAll(player:Name().." set "..keyPrefix..data.key.." to '"..printValue.."' for the next restart.");
						else
							nexus.player.NotifyAll(player:Name().." set "..keyPrefix..data.key.." to '"..printValue.."'.");
						end;
						
						NEXUS:StartDataStream( player, "OverwatchCfgValue", { data.key, configObject:Get() } );
					else
						nexus.player.Notify(player, data.key.." was unable to be set!");
					end;
				else
					nexus.player.Notify(player, data.key.." is a static config key!");
				end;
			else
				nexus.player.Notify(player, data.key.." is not a valid config key!");
			end;
		end;
	end);
	
	NEXUS:HookDataStream("OverwatchCfgKeys", function(player, data)
		local configKeys = {};
		
		for k, v in pairs( nexus.config.GetStored() ) do
			if (!v.isStatic) then
				configKeys[#configKeys + 1] = k;
			end;
		end;
		
		table.sort(configKeys, function(a, b)
			return a < b;
		end);
		
		NEXUS:StartDataStream(player, "OverwatchCfgKeys", configKeys);
	end);
	
	NEXUS:HookDataStream("OverwatchCfgValue", function(player, data)
		local configObject = nexus.config.Get(data);
		
		if ( configObject:IsValid() ) then
			if ( type( configObject:Get() ) == "string" and configObject:Query("isPrivate") ) then
				NEXUS:StartDataStream( player, "OverwatchCfgValue", {data, "****"} );
			else
				NEXUS:StartDataStream( player, "OverwatchCfgValue", {
					data, configObject:GetNext( configObject:Get() )
				} );
			end;
		end;
	end);
end;