--[[
Name: "cl_donate.lua".
Product: "HL2 RP".
--]]

local PANEL = {};

-- Store the services in a string.
PANEL.services = [[
> Please goto to donate!
When donating you can choose from a variety of different services. When you donate money you must include the character's name (exactly) who you want to have the service, your Steam ID and the service number(s) that you are purchasing. Please accept that it can take up to 3 days to gain you service(s). If you put your Steam name instead of your Steam ID then I will not accept it and you will not be refunded!
[Service #1 ($5)]
> 30 Day Donator Status.
- Half the waiting time for respawning.
- Half the waiting time for becoming conscious.
- Access to the majority of GMod's standard tools.
- Doube the wages and ration tokens you'd usually get.
- Choose from a list of icons to have next to your name out-of-character.
[Service #2 ($10)]
> In-Game Currency.
- You will get ^(7500)^.
[Service #3 ($10)]
> Extra Inventory Weight.
- You will be given 2 extra small bags.
- These bags will give you extra space even if you already have the maximum amount of bags.
[Service #4 ($20)]
> Price Saver Deal.
- You will get ^(15000)^.
- You will get donator status for 30 days.
- You will save $5 with this service.
]];

-- Called when the panel is initialized.
function PANEL:Init()
	self:SetSize(kuroScript.menu.width, kuroScript.menu.height);
	
	-- Set some information.
	self.panelList = vgui.Create("DPanelList", self);
 	self.panelList:SetPadding(2);
 	self.panelList:SetSpacing(3);
 	self.panelList:SizeToContents();
	self.panelList:EnableVerticalScrollbar();
	
	-- Rebuild the panel.
	self:Rebuild();
end;

-- A function to rebuild the panel.
function PANEL:Rebuild()
	self.panelList:Clear();
	
	-- Set some information.
	self.lastMenuWidth = kuroScript.menu.width;
	
	-- Set some information.
	local exploded = kuroScript.frame:ExplodeString("\n", self.services);
	local services = {};
	local key = 0;
	
	-- Loop through each value in a table.
	for k, v in pairs(exploded) do
		if (k < #exploded or v != "") then
			if (string.sub(v, 1, 1) == "[" and string.sub(v, -1) == "]") then
				key = key + 1;
				
				-- Set some information.
				services[key] = { service = string.sub(v, 2, -2), bonuses = {} };
			else
				if (key == 0) then
					key = key + 1; services[key] = { service = "Donate", bonuses = {} };
				end;
				
				-- Check if a statement is true.
				if ( services[key] ) then
					local wrapped = {};
					
					-- Wrap the text into a table.
					kuroScript.frame:WrapText(v, "Default", self:GetWide() - 16, 0, wrapped);
					
					-- Loop through each value in a table.
					for k2, v2 in pairs(wrapped) do
						services[key].bonuses[#services[key].bonuses + 1] = kuroScript.frame:ParseData( kuroScript.config.Parse(v2) );
					end;
				end;
			end;
		end;
	end;
	
	-- Loop through each value in a table.
	for k, v in pairs(services) do
		local form = vgui.Create("DForm");
		local text = vgui.Create("ks_DonateText", self);
		
		-- Add an item to the panel list.
		self.panelList:AddItem(form);
		
		-- Set some information.
		form:SetName(v.service);
		form:SetPadding(5);
		text:SetText(v.bonuses);
		
		-- Add an item to the form.
		form:AddItem(text);
	end;
end;

-- Called when the layout should be performed.
function PANEL:PerformLayout()
	self:StretchToParent(0, 22, 0, 0);
	self.panelList:StretchToParent(0, 0, 0, 0);
end;

-- Called each frame.
function PANEL:Think()
	if (kuroScript.menu.width != self.lastMenuWidth) then
		self:Rebuild();
	end;
end;

-- Register the panel.
vgui.Register("ks_Donate", PANEL, "Panel");

-- Set some information.
local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self.labels = {};
end;

-- Set some information.
function PANEL:SetText(text)
	for k, v in pairs(self.labels) do
		v:Remove();
	end;
	
	-- Set some information.
	local y = 5;
	
	-- Loop through each value in a table.
	for k, v in pairs(text) do
		local label = vgui.Create("DLabel", self);
		
		-- Set some information.
		label:SetText( string.Replace(v, "> ", "") );
		label:SetTextColor(COLOR_WHITE);
		label:SizeToContents();
		
		-- Check if a statement is true.
		if ( string.find(v, "> ") ) then
			label:SetTextColor( Color(150, 255, 100, 255) );
		end;
		
		-- Set some information.
		self.labels[#self.labels + 1] = label;
		
		-- Set some information.
		y = y + label:GetTall() + 8
	end;
	
	-- Set some information.
	self:SetSize(kuroScript.menu.width, y);
end;

-- Called when the layout should be performed.
function PANEL:PerformLayout()
	local y = 5;
	
	-- Loop through each value in a table.
	for k, v in pairs(self.labels) do
		self.labels[k]:SetPos(8, y);
		
		-- Set some information.
		y = y + self.labels[k]:GetTall() + 8
	end;
end;
	
-- Register the panel.
vgui.Register("ks_DonateText", PANEL, "DPanel");