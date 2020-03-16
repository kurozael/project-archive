--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

CloudScript.theme = {};

-- A function to begin the theme.
function CloudScript.theme:Begin()
	return {
		module = {},
		hooks = {},
		skin = {}
	};
end;

-- A function to get the theme.
function CloudScript.theme:Get()
	return self.active;
end;

-- A function to copy the theme to the Derma skin.
function CloudScript.theme:CopySkin()
	if (self.active) then
		local skinTable = derma.GetNamedSkin("CloudScript");
		
		if (skinTable) then
			for k, v in pairs(self.active.skin) do
				skinTable[k] = v;
			end;
		end;
		
		derma.RefreshSkins();
	end;
end;

-- A function to create the theme fonts.
function CloudScript.theme:CreateFonts()
	if (self.active and self.active.CreateFonts) then
		self.active:CreateFonts();
	end;
end;

-- A function to initialize the theme.
function CloudScript.theme:Initialize()
	if (self.active and self.active.Initialize) then
		self.active:Initialize();
	end;
end;

-- A function to finish the theme.
function CloudScript.theme:Finish(themeTable)
	CloudScript.plugin:Add("Theme", themeTable.module);
	self.active = themeTable;
end;

-- A function to call a theme hook.
function CloudScript.theme:Call(hookName, ...)
	if ( self.active and self.active.hooks[hookName] ) then
		return self.active.hooks[hookName](self.active.hooks, ...);
	end;
end;

--[[
	The following are available hooks for CloudScript.theme library:
	
	Hooks with a [/] after them mean that returning true
	overrides the default action.
	
	PreCharacterMenuInit(panel) [/]
	PostCharacterMenuInit(panel)
	
	PreCharacterMenuThink(panel) [/]
	PostCharacterMenuThink(panel)
	
	PreCharacterMenuPaint(panel) [/]
	PostCharacterMenuPaint(panel)
	
	PreCharacterMenuOpenPanel(panel, vguiName, childData, Callback) [/]
	PostCharacterMenuOpenPanel(panel)
	
	PreMainMenuInit(panel) [/]
	PostMainMenuInit(panel)
	
	PreMainMenuRebuild(panel) [/]
	PostMainMenuRebuild(panel)
	
	PreMainMenuOpenPanel(panel, panelToOpen) [/]
	PostMainMenuOpenPanel(panel, panelToOpen)
	
	PreMainMenuPaint(panel) [/]
	PostMainMenuPaint(panel)
	
	PreMainMenuThink(panel) [/]
	PostMainMenuThink(panel)
--]]