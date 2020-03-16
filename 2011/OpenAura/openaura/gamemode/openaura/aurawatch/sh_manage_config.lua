--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

if (CLIENT) then
	MODERATOR = openAura.moderator:New();
	MODERATOR.name = "Manage Config";
	MODERATOR.toolTip = "An easier way of editing the OpenAura config.";
	MODERATOR.doesCreateForm = false;
	
	-- Called to get whether the local player has access to the moderator.
	function MODERATOR:HasAccess()
		local commandTable = openAura.command:Get("CfgSetVar");
		
		if ( commandTable and openAura.player:HasFlags(openAura.Client, commandTable.access) ) then
			return true;
		else
			return false;
		end;
	end;

	-- Called when the moderator should be displayed.
	function MODERATOR:OnDisplay(moderatorPanel, moderatorForm)
		local adminValues = nil;
		
		self.infoText = vgui.Create("aura_InfoText", moderatorPanel);
			self.infoText:SetText("Click on a config key to begin editing the config value.");
			self.infoText:SetInfoColor("blue");
		moderatorPanel.panelList:AddItem(self.infoText);
		
		self.configForm = vgui.Create("DForm", moderatorPanel);
			self.configForm:SetName("Config");
			self.configForm:SetPadding(4);
		moderatorPanel.panelList:AddItem(self.configForm);
		
		if (!self.activeKey) then
			openAura:StartDataStream("ModeratorCfgKeys", true);
		else
			adminValues = openAura.config:GetModerator(self.activeKey.name);
			
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
						openAura:StartDataStream( "ModeratorCfgSet", {
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
						openAura:StartDataStream( "ModeratorCfgSet", {
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
						openAura:StartDataStream( "ModeratorCfgSet", {
							key = self.activeKey.name,
							value = checkBox:GetChecked(),
							useMap = mapEntry:GetValue()
						} );
					end;
				end;
			end;
		end;
	end;
	
	-- A function to populate the moderator's combo box.
	function MODERATOR:PopulateComboBox()
		if (self.configKeys) then
			local defaultConfigItem = nil;
			
			for k, v in ipairs(self.configKeys) do
				local adminValues = openAura.config:GetModerator(v);
				
				if (adminValues) then
					local comboBoxItem = self.comboBox:AddItem(v);
						comboBoxItem:SetToolTip(adminValues.help);
						
					-- Called when the combo box item is clicked.
					function comboBoxItem.DoClick(comboBoxItem)
						openAura:StartDataStream("ModeratorCfgValue", v);
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

	openAura.moderator:Register(MODERATOR);
	
	openAura:HookDataStream("ModeratorCfgKeys", function(data)
		local moderatorTable = openAura.moderator:Get("Manage Config");
		
		if (moderatorTable) then
			moderatorTable.configKeys = data;
			moderatorTable:PopulateComboBox();
		end;
	end);
	
	openAura:HookDataStream("ModeratorCfgValue", function(data)
		local moderatorTable = openAura.moderator:Get("Manage Config");
		
		if (moderatorTable) then
			moderatorTable.activeKey = { name = data[1], value = data[2] };
			moderatorTable:Rebuild();
		end;
	end);
else
	openAura:HookDataStream("ModeratorCfgSet", function(player, data)
		local commandTable = openAura.command:Get("CfgSetVar");
		
		if ( commandTable and openAura.player:HasFlags(player, commandTable.access) ) then
			local configObject = openAura.config:Get(data.key);
			
			if ( configObject:IsValid() ) then
				local keyPrefix = "";
				local useMap = data.useMap;
				
				if (useMap == "") then
					useMap = nil;
				end;
				
				if (useMap) then
					useMap = string.lower( openAura:Replace(useMap, ".bsp", "") );
					keyPrefix = useMap.."'s ";
					
					if ( !file.Exists("../maps/"..useMap..".bsp") ) then
						openAura.player:Notify(player, useMap.." is not a valid map!");
						
						return;
					end;
				end;
				
				if ( !configObject:Query("isStatic") ) then
					value = configObject:Set(data.value, useMap);
					
					if (value != nil) then
						local printValue = tostring(value);
						
						if ( configObject:Query("isPrivate") ) then
							if ( configObject:Query("needsRestart") ) then
								openAura.player:NotifyAll(player:Name().." set "..keyPrefix..data.key.." to '"..string.rep( "*", string.len(printValue) ).."' for the next restart.");
							else
								openAura.player:NotifyAll(player:Name().." set "..keyPrefix..data.key.." to '"..string.rep( "*", string.len(printValue) ).."'.");
							end;
						elseif ( configObject:Query("needsRestart") ) then
							openAura.player:NotifyAll(player:Name().." set "..keyPrefix..data.key.." to '"..printValue.."' for the next restart.");
						else
							openAura.player:NotifyAll(player:Name().." set "..keyPrefix..data.key.." to '"..printValue.."'.");
						end;
						
						openAura:StartDataStream( player, "ModeratorCfgValue", { data.key, configObject:Get() } );
					else
						openAura.player:Notify(player, data.key.." was unable to be set!");
					end;
				else
					openAura.player:Notify(player, data.key.." is a static config key!");
				end;
			else
				openAura.player:Notify(player, data.key.." is not a valid config key!");
			end;
		end;
	end);
	
	openAura:HookDataStream("ModeratorCfgKeys", function(player, data)
		local configKeys = {};
		
		for k, v in pairs( openAura.config:GetStored() ) do
			if (!v.isStatic) then
				configKeys[#configKeys + 1] = k;
			end;
		end;
		
		table.sort(configKeys, function(a, b)
			return a < b;
		end);
		
		openAura:StartDataStream(player, "ModeratorCfgKeys", configKeys);
	end);
	
	openAura:HookDataStream("ModeratorCfgValue", function(player, data)
		local configObject = openAura.config:Get(data);
		
		if ( configObject:IsValid() ) then
			if ( type( configObject:Get() ) == "string" and configObject:Query("isPrivate") ) then
				openAura:StartDataStream( player, "ModeratorCfgValue", {data, "****"} );
			else
				openAura:StartDataStream( player, "ModeratorCfgValue", {
					data, configObject:GetNext( configObject:Get() )
				} );
			end;
		end;
	end);
end;