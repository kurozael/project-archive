--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PANEL = {};

AccessorFunc(PANEL, "m_bPaintBackground", "PaintBackground");
AccessorFunc(PANEL, "m_bgColor", "BackgroundColor");
AccessorFunc(PANEL, "m_bDisabled", "Disabled");

-- Called when the panel is initialized.
function PANEL:Init()
	self:SetSize(Clockwork.menu:GetWidth(), Clockwork.menu:GetHeight());
	self:SetTitle("");
	self:SetSizable(false);
	self:SetDraggable(false);
	self:ShowCloseButton(false);
	
	self.panelList = vgui.Create("DPanelList", self);
 	self.panelList:SetPadding(2);
 	self.panelList:SetSpacing(3);
 	self.panelList:SizeToContents();
	self.panelList:EnableVerticalScrollbar();
	
	Schema.billboardPanel = self;
	
	self:Rebuild();
end;

-- Called when the panel is painted.
function PANEL:Paint()
	derma.SkinHook("Paint", "Frame", self);
	
	return true;
end;

-- A function to rebuild the panel.
function PANEL:Rebuild()
	self.panelList:Clear(true);
	
	local availableBillboards = {};
	local colorWhite = Clockwork.option:GetColor("white");
	
	for k, v in ipairs(Schema.billboards) do
		if (v.data and IsValid(v.data.owner)) then
			if (v.data.owner == Clockwork.Client) then
				availableBillboards[#availableBillboards + 1] = {
					data = v.data,
					id = k
				};
			end;
		else
			availableBillboards[#availableBillboards + 1] = {
				id = k
			};
		end;
	end;
	
	if (#availableBillboards > 0) then
		local label = vgui.Create("cwInfoText", self);
			label:SetText("Each billboard will cost you "..FORMAT_CASH(60)..".");
			label:SetInfoColor("blue");
		self.panelList:AddItem(label);
		
		for k, v in ipairs(availableBillboards) do
			local collapsibleCategory = vgui.Create("DCollapsibleCategory")
				collapsibleCategory:SetExpanded(false);
				collapsibleCategory:SetLabel("Billboard #"..v.id);
			self.panelList:AddItem(collapsibleCategory);
			
			if (v.data) then
				collapsibleCategory:SetLabel(v.data.title);
			end;
			
			local form = vgui.Create("DForm");
				form:SetName("Change the settings for this billboard");
				form:SetPadding(2);
			collapsibleCategory:SetContents(form);
			
			local colorMixer = vgui.Create("DColorMixer", form);
				colorMixer:SetSize(128, 128);
			form:AddItem(colorMixer);
			
			local takeDownButton = nil;
			local titleEntry = form:TextEntry("Title");
			local button = nil;
			
			-- A function to set the text entry's real value.
			function titleEntry:SetRealValue(text)
				self:SetValue(text);
				self:SetCaretPos(string.len(text));
			end;
			
			-- Called each frame.
			function titleEntry:Think()
				local text = self:GetValue();
				
				if (string.len(text) > 18) then
					self:SetRealValue(string.sub(text, 0, 18));
					
					surface.PlaySound("common/talk.wav");
				end;
			end;
			
			if (v.data) then
				titleEntry:SetText(v.data.title);
			end;
			
			local textEntry = form:TextEntry("Text");
			
			-- A function to set the text entry's real value.
			function textEntry:SetRealValue(text)
				self:SetValue(text);
				self:SetCaretPos(string.len(text));
			end;
			
			-- Called each frame.
			function textEntry:Think()
				local text = self:GetValue();
				
				if (string.len(text) > 80) then
					self:SetRealValue(string.sub(text, 0, 80));
					
					surface.PlaySound("common/talk.wav");
				end;
			end;
			
			if (v.data) then
				textEntry:SetText(v.data.unwrapped);
			end;
			
			if (v.data) then
				takeDownButton = form:Button("Takedown");
				button = form:Button("Update");
				
				function takeDownButton.DoClick(button)
					Clockwork:StartDataStream("TakeDownBillboard", v.id);
				end;
			else
				button = form:Button("Purchase");
			end;
			
			-- Called when the button is clicked.
			function button.DoClick(button)
				Clockwork:StartDataStream("UpdateBillboard", {
					title = titleEntry:GetValue(),
					color = colorMixer:GetColor(),
					text = textEntry:GetValue(),
					id = v.id
				});
			end;
		end;
	else
		local label = vgui.Create("cwInfoText", self);
			label:SetText("There are no available billboards to use.");
			label:SetInfoColor("orange");
		self.panelList:AddItem(label);
	end;
	
	self.panelList:InvalidateLayout(true);
end;

-- Called when the menu is opened.
function PANEL:OnMenuOpened()
	if (Clockwork.menu:GetActivePanel() == self) then
		self:Rebuild();
	end;
end;

-- Called when the panel is selected.
function PANEL:OnSelected() self:Rebuild(); end;

-- Called when the layout should be performed.
function PANEL:PerformLayout()
	self.panelList:StretchToParent(4, 28, 4, 4);
	self:SetSize(self:GetWide(), math.min(self.panelList.pnlCanvas:GetTall() + 32, ScrH() * 0.75));
	
	derma.SkinHook("Layout", "Frame", self);
end;

-- Called each frame.
function PANEL:Think()
	self:InvalidateLayout(true);
end;

vgui.Register("cwBillboards", PANEL, "DFrame");