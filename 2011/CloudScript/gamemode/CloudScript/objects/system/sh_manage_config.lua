--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

if (CLIENT) then
	SYSTEM = CloudScript.system:New();
	SYSTEM.name = "Manage Config";
	SYSTEM.toolTip = "An easier way of editing the CloudScript config.";
	SYSTEM.doesCreateForm = false;
	
	-- Called to get whether the local player has access to the system.
	function SYSTEM:HasAccess()
		local commandTable = CloudScript.command:Get("CfgSetVar");
		
		if ( commandTable and CloudScript.player:HasFlags(CloudScript.Client, commandTable.access) ) then
			return true;
		else
			return false;
		end;
	end;

	-- Called when the system should be displayed.
	function SYSTEM:OnDisplay(systemPanel, systemForm)
		local adminValues = nil;
		
		self.infoText = vgui.Create("cloud_InfoText", systemPanel);
			self.infoText:SetText("Click on a config key to begin editing the config value.");
			self.infoText:SetInfoColor("blue");
		systemPanel.panelList:AddItem(self.infoText);
		
		self.configForm = vgui.Create("DForm", systemPanel);
			self.configForm:SetName("Config");
			self.configForm:SetPadding(4);
		systemPanel.panelList:AddItem(self.configForm);
		
		if (!self.activeKey) then
			CloudScript:StartDataStream("SystemCfgKeys", true);
		else
			adminValues = CloudScript.config:GetSystem(self.activeKey.name);
			
			self.infoText:SetText("Now you can start to edit the config value, or click another config key.");
		end;
		
		self.comboBox = self.configForm:ComboBox("Key");
		self.comboBox:SetHeight(256);
		self.comboBox:SetMultiple(false);
		self:PopulateComboBox();
		
		if (adminValues) then
			self.configForm:SetName(self.activeKey.name);
			
			for k, v in ipairs( string.Explode("\n", adminValues.help) ) do
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
						CloudScript:StartDataStream( "SystemCfgSet", {
							key = self.activeKey.name,
							value = textEntry:GetValue(),
							useMap = mapEntry:GetValue()
						} );
					end;
				elseif (valueType == "number") then
					local numSlider = self.configForm:NumSlider("Value", nil, adminValues.minimum,
					adminValues.maximum, adminValues.decimals);
						numSlider:SetValue(self.activeKey.value);
					local okayButton = self.configForm:Button("Okay");
						
					-- Called when the button is clicked.
					function okayButton.DoClick(okayButton)
						CloudScript:StartDataStream( "SystemCfgSet", {
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
						CloudScript:StartDataStream( "SystemCfgSet", {
							key = self.activeKey.name,
							value = checkBox:GetChecked(),
							useMap = mapEntry:GetValue()
						} );
					end;
				end;
			end;
		end;
	end;
	
	-- A function to populate the system's combo box.
	function SYSTEM:PopulateComboBox()
		if (self.configKeys) then
			local defaultConfigItem = nil;
			
			for k, v in ipairs(self.configKeys) do
				local adminValues = CloudScript.config:GetSystem(v);
				
				if (adminValues) then
					local comboBoxItem = self.comboBox:AddItem(v);
						comboBoxItem:SetToolTip(adminValues.help);
						
					-- Called when the combo box item is clicked.
					function comboBoxItem.DoClick(comboBoxItem)
						CloudScript:StartDataStream("SystemCfgValue", v);
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

	CloudScript.system:Register(SYSTEM);
	
	CloudScript:HookDataStream("SystemCfgKeys", function(data)
		local systemTable = CloudScript.system:Get("Manage Config");
		
		if (systemTable) then
			systemTable.configKeys = data;
			systemTable:PopulateComboBox();
		end;
	end);
	
	CloudScript:HookDataStream("SystemCfgValue", function(data)
		local systemTable = CloudScript.system:Get("Manage Config");
		
		if (systemTable) then
			systemTable.activeKey = { name = data[1], value = data[2] };
			systemTable:Rebuild();
		end;
	end);
else
	CloudScript:HookDataStream("SystemCfgSet", function(player, data)
		local commandTable = CloudScript.command:Get("CfgSetVar");
		
		if ( commandTable and CloudScript.player:HasFlags(player, commandTable.access) ) then
			local configObject = CloudScript.config:Get(data.key);
			
			if ( configObject:IsValid() ) then
				local keyPrefix = "";
				local useMap = data.useMap;
				
				if (useMap == "") then
					useMap = nil;
				end;
				
				if (useMap) then
					useMap = string.lower( CloudScript:Replace(useMap, ".bsp", "") );
					keyPrefix = useMap.."'s ";
					
					if ( !file.Exists("../maps/"..useMap..".bsp") ) then
						CloudScript.player:Notify(player, useMap.." is not a valid map!");
						
						return;
					end;
				end;
				
				if ( !configObject:Query("isStatic") ) then
					value = configObject:Set(data.value, useMap);
					
					if (value != nil) then
						local printValue = tostring(value);
						
						if ( configObject:Query("isPrivate") ) then
							if ( configObject:Query("needsRestart") ) then
								CloudScript.player:NotifyAll(player:Name().." set "..keyPrefix..data.key.." to '"..string.rep( "*", string.len(printValue) ).."' for the next restart.");
							else
								CloudScript.player:NotifyAll(player:Name().." set "..keyPrefix..data.key.." to '"..string.rep( "*", string.len(printValue) ).."'.");
							end;
						elseif ( configObject:Query("needsRestart") ) then
							CloudScript.player:NotifyAll(player:Name().." set "..keyPrefix..data.key.." to '"..printValue.."' for the next restart.");
						else
							CloudScript.player:NotifyAll(player:Name().." set "..keyPrefix..data.key.." to '"..printValue.."'.");
						end;
						
						CloudScript:StartDataStream( player, "SystemCfgValue", { data.key, configObject:Get() } );
					else
						CloudScript.player:Notify(player, data.key.." was unable to be set!");
					end;
				else
					CloudScript.player:Notify(player, data.key.." is a static config key!");
				end;
			else
				CloudScript.player:Notify(player, data.key.." is not a valid config key!");
			end;
		end;
	end);
	
	CloudScript:HookDataStream("SystemCfgKeys", function(player, data)
		local configKeys = {};
		
		for k, v in pairs( CloudScript.config:GetStored() ) do
			if (!v.isStatic) then
				configKeys[#configKeys + 1] = k;
			end;
		end;
		
		table.sort(configKeys, function(a, b)
			return a < b;
		end);
		
		CloudScript:StartDataStream(player, "SystemCfgKeys", configKeys);
	end);
	
	CloudScript:HookDataStream("SystemCfgValue", function(player, data)
		local configObject = CloudScript.config:Get(data);
		
		if ( configObject:IsValid() ) then
			if ( type( configObject:Get() ) == "string" and configObject:Query("isPrivate") ) then
				CloudScript:StartDataStream( player, "SystemCfgValue", {data, "****"} );
			else
				CloudScript:StartDataStream( player, "SystemCfgValue", {
					data, configObject:GetNext( configObject:Get() )
				} );
			end;
		end;
	end);
end;