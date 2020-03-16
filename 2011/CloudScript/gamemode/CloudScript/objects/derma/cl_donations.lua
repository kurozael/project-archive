--[[
	� 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self:SetSize( CloudScript.menu:GetWidth(), CloudScript.menu:GetHeight() );
	self:SetTitle("Donations");
	self:SetSizable(false);
	self:SetDraggable(false);
	self:ShowCloseButton(false);
	
	self.panelList = vgui.Create("DPanelList", self);
 	self.panelList:SetPadding(2);
 	self.panelList:SetSpacing(3);
 	self.panelList:SizeToContents();
	self.panelList:EnableVerticalScrollbar();
	
	self:Rebuild();
end;

-- A function to get whether the button is visible.
function PANEL:IsButtonVisible()
	if ( CloudScript.donation:HasDonated() ) then
		return true;
	else
		return false;
	end;
end;

-- A function to rebuild the panel.
function PANEL:Rebuild()
	self.panelList:Clear(true);
	
	local donations = {};
	
	for k, v in pairs(CloudScript.donation.stored) do
		local expireTime = CloudScript.donation:IsSubscribed(k);
		
		if (expireTime) then
			donations[#donations + 1] = {
				friendlyName = v.friendlyName,
				description = v.description,
				expireTime = expireTime,
				imageName = v.imageName
			};
		end;
	end;
	
	table.sort(donations, function(a, b)
		return a.expireTime < b.expireTime;
	end);
	
	if (#donations > 0) then
		local label = vgui.Create("cloud_InfoText", self);
			label:SetText("Some subscriptions can expire and will have to be donated for again.");
			label:SetInfoColor("blue");
		self.panelList:AddItem(label);
		
		for k, v in ipairs(donations) do
			self.donationTable = v;
			self.panelList:AddItem( vgui.Create("cloud_DonationItem", self) );
		end;
	else
		local label = vgui.Create("cloud_InfoText", self);
			label:SetText("You do not have any active donations!");
			label:SetInfoColor("red");
		self.panelList:AddItem(label);
	end;
	
	self.panelList:InvalidateLayout(true);
end;

-- Called when the menu is opened.
function PANEL:OnMenuOpened()
	if (CloudScript.menu:GetActivePanel() == self) then
		self:Rebuild();
	end;
end;

-- Called when the panel is selected.
function PANEL:OnSelected() self:Rebuild(); end;

-- Called when the layout should be performed.
function PANEL:PerformLayout()
	self.panelList:StretchToParent(4, 28, 4, 4);
	self:SetSize( self:GetWide(), math.min(self.panelList.pnlCanvas:GetTall() + 32, ScrH() * 0.75) );
	
	derma.SkinHook("Layout", "Frame", self);
end;

-- Called when the panel is painted.
function PANEL:Paint()
	derma.SkinHook("Paint", "Frame", self);
	
	return true;
end;

-- Called each frame.
function PANEL:Think()
	self:InvalidateLayout(true);
end;

vgui.Register("cloud_Donations", PANEL, "DFrame");

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	local colorWhite = CloudScript.option:GetColor("white");
	local unixTime = os.clock();
	
	self.donationTable = self:GetParent().donationTable;
	self:SetSize(self:GetParent():GetWide(), 32);
	
	self.nameLabel = vgui.Create("DLabel", self);
	self.nameLabel:SetText(self.donationTable.friendlyName);
	self.nameLabel:SetTextColor(colorWhite);
	
	self.information = vgui.Create("DLabel", self);
	self.information:SetText(self.donationTable.description);
	self.information:SetTextColor(colorWhite);
	self.information:SizeToContents();
	
	self.donationImage = vgui.Create("DImage", self);
	
	if (self.donationTable.expireTime > 0
	and unixTime > self.donationTable.expireTime) then
		self.donationImage:SetImage("CloudScript/donations/expired");
		self.hasExpired = true;
	else
		self.hasExpired = false;
		
		if (self.donationTable.imageName) then
			self.donationImage:SetImage(self.donationTable.imageName);
		else
			self.donationImage:SetImage("CloudScript/donations/subscribed");
		end;
	end;
	
	self.donationImage:SetSize(32, 32);
end;

-- Called each frame.
function PANEL:Think()
	if (self.donationTable) then
		local expireTime = self.donationTable.expireTime;
		local unixTime = os.clock();
		
		if (expireTime == 0) then
			self.donationImage:SetToolTip("This subscription will never expire.");
		elseif (unixTime > expireTime) then
			self.donationImage:SetToolTip("This subscription has expired!");
			
			if (!self.hasExpired) then
				self.donationImage:SetImage("CloudScript/donations/expired");
				self.hasExpired = true;
			end;
		else
			self.donationImage:SetToolTip("This donation will expire in "..math.ceil(expireTime - unixTime).." second(s).");
		end;
	end;
	
	self.donationImage:SetPos(1, 1);
	self.donationImage:SetSize(30, 30);
end;

-- Called when the layout should be performed.
function PANEL:PerformLayout()
	self.nameLabel:SizeToContents();
	self.information:SizeToContents();

	self.donationImage:SetPos(1, 1);
	self.nameLabel:SetPos(40, 2);
	self.donationImage:SetSize(30, 30);
	self.information:SetPos( 40, 30 - self.information:GetTall() );
end;
	
vgui.Register("cloud_DonationItem", PANEL, "DPanel");