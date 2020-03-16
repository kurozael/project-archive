--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

CloudScript.quickmenu = {};
CloudScript.quickmenu.stored = {};
CloudScript.quickmenu.categories = {};

-- A function to add a quick menu callback.
function CloudScript.quickmenu:AddCallback(name, category, GetInfo, OnCreateMenu)
	if (category) then
		if ( !self.categories[category] ) then
			self.categories[category] = {};
		end;
		
		self.categories[category][name] = {
			OnCreateMenu = OnCreateMenu,
			GetInfo = GetInfo,
			name = name
		};
	else
		self.stored[name] = {
			OnCreateMenu = OnCreateMenu,
			GetInfo = GetInfo,
			name = name
		};
	end;
	
	return name;
end;

-- A function to add a command quick menu callback.
function CloudScript.quickmenu:AddCommand(name, category, command, options)
	return self:AddCallback(name, category, function()
		local commandTable = CloudScript.command:Get(command);
		
		if (commandTable) then
			return {
				toolTip = commandTable.tip,
				Callback = function(option)
					CloudScript:RunCommand(command, option);
				end,
				options = options
			};
		else
			return false;
		end;
	end);
end;

CloudScript.quickmenu:AddCallback("Fall Over", nil, function()
	local commandTable = CloudScript.command:Get("CharFallOver");
	
	if (commandTable) then
		return {
			toolTip = commandTable.tip,
			Callback = function(option)
				CloudScript:RunCommand("CharFallOver");
			end
		};
	else
		return false;
	end;
end);

CloudScript.quickmenu:AddCallback("Description", nil, function()
	local commandTable = CloudScript.command:Get("CharPhysDesc");
	
	if (commandTable) then
		return {
			toolTip = commandTable.tip,
			Callback = function(option)
				CloudScript:RunCommand("CharPhysDesc");
			end
		};
	else
		return false;
	end;
end);