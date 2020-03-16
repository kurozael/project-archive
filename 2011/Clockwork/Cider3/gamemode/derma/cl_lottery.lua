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
	self:SetTitle("Lottery");
	self:SetSizable(false);
	self:SetDraggable(false);
	self:ShowCloseButton(false);
	
	self.panelList = vgui.Create("DPanelList", self);
 	self.panelList:SetPadding(2);
 	self.panelList:SetSpacing(3);
 	self.panelList:SizeToContents();
	self.panelList:EnableVerticalScrollbar();
	
	Schema.cwLotteryPanel = self;
	
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
	
	local nextLotteryTime = Clockwork:GetSharedVar("Lottery");
	local lotteryTicket = Clockwork.Client:GetSharedVar("Lottery");
	local colorWhite = Clockwork.option:GetColor("white");
	local curTime = CurTime();
	
	if (nextLotteryTime > curTime) then
		self.timeLabel = vgui.Create("cwInfoText", self);
			self.timeLabel:SetText("The lottery draw will begin in "..math.Round(nextLotteryTime - curTime).." second(s).");
			self.timeLabel:SetInfoColor("green");
		self.panelList:AddItem(self.timeLabel);
		
		if (!lotteryTicket) then
			local form = vgui.Create("DForm");
				form:SetName("Ticket");
				form:SetPadding(2);
			self.panelList:AddItem(form);
			
			form:Help("The lottery will cost you "..FORMAT_CASH(40).." for a ticket.");
			
			local sliderOne = form:NumSlider("Lottery number one.", nil, 1, 10, 0);
			local sliderTwo = form:NumSlider("Lottery number two.", nil, 1, 10, 0);
			local sliderThree = form:NumSlider("Lottery number three.", nil, 1, 10, 0);
			local lotterySubmit = form:Button("Purchase your ticket.");
			
			sliderOne:SetValue(1);
			sliderTwo:SetValue(1);
			sliderThree:SetValue(1);
			
			function lotterySubmit.DoClick(button)
				local numberOne = sliderOne:GetValue();
				local numberTwo = sliderTwo:GetValue();
				local numberThree = sliderThree:GetValue();
				
				Clockwork:StartDataStream("PurchaseLottery", {numberOne, numberTwo, numberThree});
			end;
		else
			local form = vgui.Create("DForm");
				form:SetName("Ticket");
				form:SetPadding(2);
			self.panelList:AddItem(form);
			
			form:Help("When the time is up, the lottery winners will be drawn and announced. The chance of winning isn't too high, but the cash prize is usually very large.");
		end;
	else
		local label = vgui.Create("cwInfoText", self);
			label:SetText("The lottery is currently in progress, please wait.");
			label:SetInfoColor("blue");
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
	
	if (IsValid(self.timeLabel)) then
		local nextLotteryTime = Clockwork:GetSharedVar("Lottery");
		local curTime = CurTime();
		
		if (nextLotteryTime > curTime) then
			self.timeLabel:SetText("The lottery draw will begin in "..math.Round(nextLotteryTime - curTime).." second(s).");
		end;
	end;
end;

vgui.Register("cwLottery", PANEL, "DFrame");