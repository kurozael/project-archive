CLOUD_SIXTEEN_FORUMS = {};

function CLOUD_SIXTEEN_FORUMS:MenuItemsAdd(menuItems)
	if (tonumber(Clockwork.kernel:GetVersion()) >= 0.97) then
		menuItems:Add(L("MenuNameCommunity"), "cwCloudSixteenForums", L("MenuDescCommunity"), Clockwork.option:GetKey("icon_data_plugin_center"));
	else
		menuItems:Add("Community", "cwCloudSixteenForums", "Browse the official Clockwork forums and community.", Clockwork.option:GetKey("icon_data_community"));
	end;
end;

Clockwork.plugin:Add("CloudSixteenForums", CLOUD_SIXTEEN_FORUMS);

local PANEL = {};

function PANEL:Init()
	self:SetSize(Clockwork.menu:GetWidth(), Clockwork.menu:GetHeight());
	
	self.htmlPanel = vgui.Create("DHTML");
 	self.htmlPanel:SetParent(self);
	
	self:Rebuild();
end;

function PANEL:IsButtonVisible()
	return true;
end;

function PANEL:Rebuild()
	self.htmlPanel:OpenURL("https://eden.cloudsixteen.com");
end;

function PANEL:OnMenuOpened()
	self:Rebuild();
end;

function PANEL:OnSelected() self:Rebuild(); end;

function PANEL:PerformLayout(w, h)
	self.htmlPanel:StretchToParent(4, 4, 4, 4);
end;

function PANEL:Paint(w, h)
	Clockwork.kernel:DrawSimpleGradientBox(0, 0, 0, w, h, Color(0, 0, 0, 255));
	draw.SimpleText("Please wait...", Clockwork.option:GetFont("menu_text_big"), w / 2, h / 2, Color(255, 255, 255, 255), 1, 1);
	
	return true;
end;

function PANEL:Think()
	self:InvalidateLayout(true);
end;

vgui.Register("cwCloudSixteenForums", PANEL, "EditablePanel");