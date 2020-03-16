--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local ACCESS_FLAG = "a";

if (CLIENT) then
	SYSTEM = CloudScript.system:New();
	SYSTEM.name = "Color Modify";
	SYSTEM.access = ACCESS_FLAG;
	SYSTEM.toolTip = "Edit the schema's global color to suit your needs.";
	SYSTEM.doesCreateForm = false;
	CloudScript.OverrideColorMod = CloudScript:RestoreSchemaData("color", false);
	
	-- A function to get the key info.
	function SYSTEM:GetKeyInfo(key)
		if (key == "brightness") then
			return {name = "Brightness", minimum = -2, maximum = 2, decimals = 2};
		elseif (key == "contrast") then
			return {name = "Contrast", minimum = 0, maximum = 10, decimals = 2};
		elseif (key == "color") then
			return {name = "Color", minimum = 0, maximum = 5, decimals = 2};
		elseif (key == "addr") then
			return {name = "Add Red", minimum = 0, maximum = 255, decimals = 0};
		elseif (key == "addg") then
			return {name = "Add Green", minimum = 0, maximum = 255, decimals = 0};
		elseif (key == "addb") then
			return {name = "Add Blue", minimum = 0, maximum = 255, decimals = 0};
		elseif (key == "mulr") then
			return {name = "Multiply Red", minimum = 0, maximum = 255, decimals = 0};
		elseif (key == "mulg") then
			return {name = "Multiply Green", minimum = 0, maximum = 255, decimals = 0};
		elseif (key == "mulb") then
			return {name = "Multiply Blue", minimum = 0, maximum = 255, decimals = 0};
		end;
	end;
	
	-- Called when the system should be displayed.
	function SYSTEM:OnDisplay(systemPanel, systemForm)
		local infoText = vgui.Create("cloud_InfoText", systemPanel);
			infoText:SetText("Changing these values will affect the color for all players.");
			infoText:SetInfoColor("blue");
		systemPanel.panelList:AddItem(infoText);
		
		local infoText = vgui.Create("cloud_InfoText", systemPanel);
			infoText:SetText("Please note that this is for advanced users only.");
			infoText:SetInfoColor("orange");
		systemPanel.panelList:AddItem(infoText);
		
		self.colorModForm = vgui.Create("DForm", systemPanel);
			self.colorModForm:SetName("Color");
			self.colorModForm:SetPadding(4);
		systemPanel.panelList:AddItem(self.colorModForm);
		
		local checkBox = self.colorModForm:CheckBox("Enabled");
		checkBox.OnChange = function(checkBox, value)
			if (value != CloudScript.OverrideColorMod.enabled) then
				CloudScript:StartDataStream( "SystemColSet", {key = "enabled", value = value} );
			end;
		end;
		checkBox:SetValue(CloudScript.OverrideColorMod.enabled);
		
		for k, v in pairs(CloudScript.OverrideColorMod) do
			if (k != "enabled") then
				local info = self:GetKeyInfo(k);
				local numSlider = self.colorModForm:NumSlider(info.name, nil, info.minimum, info.maximum, info.decimals);
				numSlider.OnValueChanged = function(numSlider, value)
					if ( value != CloudScript.OverrideColorMod[k] ) then
						local timerName = "Color Set: "..k;
						
						CloudScript:CreateTimer(timerName, 1, 0, function()
							if ( !input.IsMouseDown(MOUSE_LEFT) ) then
								CloudScript:StartDataStream( "SystemColSet", {key = k, value = value} );
								CloudScript:DestroyTimer(timerName);
							end;
						end);
					end;
				end;
				numSlider:SetValue(v);
			end;
		end;
	end;

	CloudScript.system:Register(SYSTEM);
	
	CloudScript:HookDataStream("SystemColSet", function(data)
		CloudScript.OverrideColorMod[data.key] = tonumber(data.value);
		CloudScript:SaveSchemaData("color", CloudScript.OverrideColorMod);
		
		local systemTable = CloudScript.system:Get("Color Modify");
		
		if (systemTable) then
			systemTable:Rebuild();
		end;
	end);
	
	CloudScript:HookDataStream("SystemColGet", function(data)
		CloudScript.OverrideColorMod = data;
		CloudScript:SaveSchemaData("color", CloudScript.OverrideColorMod);
	end);
else
	CloudScript:HookDataStream("SystemColSet", function(player, data)
		if ( CloudScript.player:HasFlags(player, "a") ) then
			CloudScript.OverrideColorMod[data.key] = tonumber(data.value);
			CloudScript:SaveSchemaData("color", CloudScript.OverrideColorMod);
			CloudScript:StartDataStream(nil, "SystemColSet", data);
		end;
	end);
end;

if (!CloudScript.OverrideColorMod) then
	CloudScript.OverrideColorMod = {
		brightness = 0,
		contrast = 1,
		enabled = false,
		color = 1,
		mulr = 0,
		mulg = 0,
		mulb = 0,
		addr = 0,
		addg = 0,
		addb = 0,
	};
end;