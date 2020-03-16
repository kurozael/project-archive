--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local ACCESS_FLAG = "a";

if (CLIENT) then
	MODERATOR = openAura.moderator:New();
	MODERATOR.name = "Color Modify";
	MODERATOR.access = ACCESS_FLAG;
	MODERATOR.toolTip = "Edit the schema's global color to suit your needs.";
	MODERATOR.doesCreateForm = false;
	openAura.OverrideColorMod = openAura:RestoreSchemaData("color", false);
	
	-- A function to get the key info.
	function MODERATOR:GetKeyInfo(key)
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
	
	-- Called when the moderator should be displayed.
	function MODERATOR:OnDisplay(moderatorPanel, moderatorForm)
		local infoText = vgui.Create("aura_InfoText", moderatorPanel);
			infoText:SetText("Changing these values will affect the color for all players.");
			infoText:SetInfoColor("blue");
		moderatorPanel.panelList:AddItem(infoText);
		
		local infoText = vgui.Create("aura_InfoText", moderatorPanel);
			infoText:SetText("Please note that this is for advanced users only.");
			infoText:SetInfoColor("orange");
		moderatorPanel.panelList:AddItem(infoText);
		
		self.colorModForm = vgui.Create("DForm", moderatorPanel);
			self.colorModForm:SetName("Color");
			self.colorModForm:SetPadding(4);
		moderatorPanel.panelList:AddItem(self.colorModForm);
		
		local checkBox = self.colorModForm:CheckBox("Enabled");
		checkBox.OnChange = function(checkBox, value)
			if (value != openAura.OverrideColorMod.enabled) then
				openAura:StartDataStream( "ModeratorColSet", {key = "enabled", value = value} );
			end;
		end;
		checkBox:SetValue(openAura.OverrideColorMod.enabled);
		
		for k, v in pairs(openAura.OverrideColorMod) do
			if (k != "enabled") then
				local info = self:GetKeyInfo(k);
				local numSlider = self.colorModForm:NumSlider(info.name, nil, info.minimum, info.maximum, info.decimals);
				numSlider.OnValueChanged = function(numSlider, value)
					if ( value != openAura.OverrideColorMod[k] ) then
						local timerName = "Color Set: "..k;
						
						openAura:CreateTimer(timerName, 1, 0, function()
							if ( !input.IsMouseDown(MOUSE_LEFT) ) then
								openAura:StartDataStream( "ModeratorColSet", {key = k, value = value} );
								openAura:DestroyTimer(timerName);
							end;
						end);
					end;
				end;
				numSlider:SetValue(v);
			end;
		end;
	end;

	openAura.moderator:Register(MODERATOR);
	
	openAura:HookDataStream("ModeratorColSet", function(data)
		openAura.OverrideColorMod[data.key] = tonumber(data.value);
		openAura:SaveSchemaData("color", openAura.OverrideColorMod);
		
		local moderatorTable = openAura.moderator:Get("Color Modify");
		
		if (moderatorTable) then
			moderatorTable:Rebuild();
		end;
	end);
	
	openAura:HookDataStream("ModeratorColGet", function(data)
		openAura.OverrideColorMod = data;
		openAura:SaveSchemaData("color", openAura.OverrideColorMod);
	end);
else
	openAura:HookDataStream("ModeratorColSet", function(player, data)
		if ( openAura.player:HasFlags(player, "a") ) then
			openAura.OverrideColorMod[data.key] = tonumber(data.value);
			openAura:SaveSchemaData("color", openAura.OverrideColorMod);
			openAura:StartDataStream(nil, "ModeratorColSet", data);
		end;
	end);
end;

if (!openAura.OverrideColorMod) then
	openAura.OverrideColorMod = {
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