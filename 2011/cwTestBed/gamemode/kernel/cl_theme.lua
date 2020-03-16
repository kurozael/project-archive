--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local THEME = Clockwork.theme:Begin();

-- Called when fonts should be created.
function THEME:CreateFonts()
	surface.CreateFont("Traveling _Typewriter", ScaleToWideScreen(2048), 600, true, false, "test_Large3D2D");
	surface.CreateFont("Traveling _Typewriter", ScaleToWideScreen(36), 600, true, false, "test_IntroTextSmall");
	surface.CreateFont("Traveling _Typewriter", ScaleToWideScreen(26), 600, true, false, "test_IntroTextTiny");
	surface.CreateFont("Traveling _Typewriter", ScaleToWideScreen(36), 600, true, false, "test_CinematicText");
	surface.CreateFont("Traveling _Typewriter", ScaleToWideScreen(78), 600, true, false, "test_IntroTextBig");
	surface.CreateFont("Traveling _Typewriter", ScaleToWideScreen(26), 600, true, false, "test_TargetIDText");
	surface.CreateFont("Traveling _Typewriter", ScaleToWideScreen(16), 600, true, false, "test_SmallBarText");
	surface.CreateFont("Traveling _Typewriter", ScaleToWideScreen(126), 600, true, false, "test_MenuTextHuge");
	surface.CreateFont("Traveling _Typewriter", ScaleToWideScreen(78), 600, true, false, "test_MenuTextBig");
	surface.CreateFont("Traveling _Typewriter", ScaleToWideScreen(22), 600, true, false, "test_PlayerInfoText");
	surface.CreateFont("Traveling _Typewriter", ScaleToWideScreen(24), 600, true, false, "test_MainText");
end;

-- Called when to initialize theme.
function THEME:Initialize()
	Clockwork.option:SetColor("information", Color(172, 231, 101, 255));
	Clockwork.option:SetColor("background", Color(0, 0, 0, 255));
	Clockwork.option:SetColor("target_id", Color(167, 213, 114, 255));
	Clockwork.option:SetFont("bar_text", "test_TargetIDText");
	Clockwork.option:SetFont("main_text", "test_MainText");
	Clockwork.option:SetFont("hints_text", "test_IntroTextTiny");
	Clockwork.option:SetFont("large_3d_2d", "test_Large3D2D");
	Clockwork.option:SetFont("target_id_text", "test_TargetIDText");
	Clockwork.option:SetFont("cinematic_text", "test_CinematicText");
	Clockwork.option:SetFont("date_time_text", "test_IntroTextSmall");
	Clockwork.option:SetFont("menu_text_big", "test_MenuTextBig");
	Clockwork.option:SetFont("menu_text_huge", "test_MenuTextHuge");
	Clockwork.option:SetFont("menu_text_tiny", "test_IntroTextTiny");
	Clockwork.option:SetFont("intro_text_big", "test_IntroTextBig");
	Clockwork.option:SetFont("menu_text_small", "test_IntroTextSmall");
	Clockwork.option:SetFont("intro_text_tiny", "test_IntroTextTiny");
	Clockwork.option:SetFont("intro_text_small", "test_IntroTextSmall");
	Clockwork.option:SetFont("player_info_text", "test_PlayerInfoText");
end;

-- Called after the character menu has initialized.
function THEME.hooks:PostCharacterMenuInit(panel) end;

-- Called every frame that the character menu is open.
function THEME.hooks:PostCharacterMenuThink(panel) end;

-- Called after the character menu is painted.
function THEME.hooks:PostCharacterMenuPaint(panel) end;

-- Called after a character menu panel is opened.
function THEME.hooks:PostCharacterMenuOpenPanel(panel) end;

-- Called after the main menu has initialized.
function THEME.hooks:PostMainMenuInit(panel) end;

-- Called after the main menu is rebuilt.
function THEME.hooks:PostMainMenuRebuild(panel) end;

-- Called after a main menu panel is opened.
function THEME.hooks:PostMainMenuOpenPanel(panel, panelToOpen) end;

-- Called after the main menu is painted.
function THEME.hooks:PostMainMenuPaint(panel) end;

-- Called every frame that the main menu is open.
function THEME.hooks:PostMainMenuThink(panel) end;

THEME.skin.frameBorder = Color(172, 231, 101, 255);
THEME.skin.frameTitle = Color(172, 231, 101, 255);

THEME.skin.bgColorBright = Color(172, 231, 101, 255);
THEME.skin.bgColorSleep = Color(70, 70, 70, 255);
THEME.skin.bgColorDark = Color(50, 50, 50, 255);
THEME.skin.bgColor = Color(40, 40, 40, 225);

THEME.skin.controlColorHighlight = Color(70, 70, 70, 255);
THEME.skin.controlColorActive = Color(175, 175, 175, 255);
THEME.skin.controlColorBright = Color(100, 100, 100, 255);
THEME.skin.controlColorDark = Color(30, 30, 30, 255);
THEME.skin.controlColor = Color(60, 60, 60, 255);

THEME.skin.colTabTextInactive = Color(172, 231, 101, 255);
THEME.skin.colPropertySheet = Color(172, 231, 101, 255);
THEME.skin.colTabInactive = Color(0, 0, 0, 255);
THEME.skin.colTabShadow = Color(0, 0, 0, 170);
THEME.skin.colTabText = Color(0, 0, 0, 255);
THEME.skin.colTab = Color(172, 231, 101, 255);

THEME.skin.fontCategoryHeader = "hl2_ThickArial";
THEME.skin.fontMenuOption = "hl2_ThickArial";
THEME.skin.fontFormLabel = "hl2_ThickArial";
THEME.skin.fontButton = "hl2_ThickArial";
THEME.skin.fontFrame = "hl2_ThickArial";
THEME.skin.fontTab = "hl2_ThickArial";

-- A function to draw a generic background.
function THEME.skin:DrawGenericBackground(x, y, w, h, color)
	Clockwork:DrawSimpleGradientBox(2, x, y, w, h, color, 125);
end;

-- Called when a frame is layed out.
function THEME.skin:LayoutFrame(panel)
	panel.lblTitle:SetFont(self.fontFrame);
	panel.lblTitle:SetText(panel.lblTitle:GetText():upper());
	panel.lblTitle:SetTextColor(Color(0, 0, 0, 255));
	panel.lblTitle:SizeToContents();
	panel.lblTitle:SetExpensiveShadow(nil);
	
	panel.btnClose:SetDrawBackground(true);
	panel.btnClose:SetPos(panel:GetWide() - 22, 2);
	panel.btnClose:SetSize(18, 18);
	panel.lblTitle:SetPos(8, 2);
	panel.lblTitle:SetSize(panel:GetWide() - 25, 20);
end;

-- Called when a form is schemed.
function THEME.skin:SchemeForm(panel)
	panel.Label:SetFont(self.fontFormLabel);
	panel.Label:SetText(panel.Label:GetText():upper());
	panel.Label:SetTextColor(Color(172, 231, 101, 255));
	panel.Label:SetExpensiveShadow(1, Color(0, 0, 0, 200));
end;

-- Called when a tab is painted.
function THEME.skin:PaintTab(panel)
	if (panel:GetPropertySheet():GetActiveTab() == panel) then
		self:DrawGenericBackground(1, 1, panel:GetWide() - 2, panel:GetTall() + 8, self.colTab);
	else
		self:DrawGenericBackground(1, 2, panel:GetWide() - 2, panel:GetTall() + 8, self.colTabInactive);
	end;
end;

-- Called when a list view is painted.
function THEME.skin:PaintListView(panel)
	if (panel.m_bBackground) then
		surface.SetDrawColor(172, 231, 101, 255);
		panel:DrawFilledRect();
	end;
end;
	
-- Called when a list view line is painted.
function THEME.skin:PaintListViewLine(panel)
	local color = Color(50, 50, 50, 255);
	local textColor = Color(172, 231, 101, 255);
	
	if (panel:IsSelected()) then
		color = Color(172, 231, 101, 255);
		textColor = Color(0, 0, 0, 255);
	elseif (panel.Hovered) then
		color = Color(100, 100, 100, 255);
	elseif (panel.m_bAlt) then
		color = Color(75, 75, 75, 255);
	end;
	
	for k, v in pairs(panel.Columns) do
		v:SetTextColor(textColor);
	end;
 
	surface.SetDrawColor(color.r, color.g, color.b, color.a);
	surface.DrawRect(0, 0, panel:GetWide(), panel:GetTall());
end;

-- Called when a list view label is schemed.
function THEME.skin:SchemeListViewLabel(panel)
	panel:SetTextInset(3);
	panel:SetTextColor(Color(172, 231, 101, 255));
end;

-- Called when a menu is painted.
function THEME.skin:PaintMenu(panel)
	surface.SetDrawColor(Color(0, 0, 0, 255));
	panel:DrawFilledRect(0, 0, w, h);
end;

-- Called when a menu is painted over.
function THEME.skin:PaintOverMenu(panel) end;

-- Called when a menu option is schemed.
function THEME.skin:SchemeMenuOption(panel)
	panel:SetFGColor(172, 231, 101, 255);
end;

-- Called when a menu option is painted.
function THEME.skin:PaintMenuOption(panel)
	local textColor = Color(172, 231, 101, 255);
	
	if (panel.m_bBackground and panel.Hovered) then
		local color = nil;

		if (panel.Depressed) then
			color = Color(225, 225, 225, 255);
		else
			color = Color(172, 231, 101, 255);
		end;

		surface.SetDrawColor(color.r, color.g, color.b, color.a);
		surface.DrawRect(0, 0, panel:GetWide(), panel:GetTall());
		
		textColor = Color(0, 0, 0, 255);
	end;
	
	panel:SetFGColor(textColor);
end;

-- Called when a menu option is layed out.
function THEME.skin:LayoutMenuOption(panel)
	panel:SetFont(self.fontMenuOption);
	panel:SizeToContents();
	panel:SetWide(panel:GetWide() + 30);
	panel:SetSize(math.max(panel:GetParent():GetWide(), panel:GetWide()), 18);
	
	if (panel.SubMenuArrow) then
		panel.SubMenuArrow:SetSize(panel:GetTall(), panel:GetTall());
		panel.SubMenuArrow:CenterVertical();
		panel.SubMenuArrow:AlignRight();
	end;
end;

-- Called when a button is painted.
function THEME.skin:PaintButton(panel)
	local w, h = panel:GetSize();
	local textColor = Color(172, 231, 101, 255);
	
	if (panel.m_bBackground) then
		local color = Color(0, 0, 0, 255);
		local borderColor = Color(172, 231, 101, 255);
		
		if (panel:GetDisabled()) then
			color = self.controlColorDark;
		elseif (panel.Depressed or panel:GetSelected()) then
			color = Color(172, 231, 101, 255);
			textColor = Color(0, 0, 0, 255);
		elseif (panel.Hovered) then
			color = self.controlColorHighlight;
		end;

		self:DrawGenericBackground(0, 0, w, h, borderColor);
		self:DrawGenericBackground(1, 1, w - 2, h - 2, color);
	end;
	
	panel:SetFGColor(textColor);
end;

-- Called when a scroll bar grip is painted.
function THEME.skin:PaintScrollBarGrip(panel)
	local w, h = panel:GetSize();
	local color = Color(172, 231, 101, 255);

	self:DrawGenericBackground(0, 0, w, h, color);
	self:DrawGenericBackground(2, 2, w - 4, h - 4, Color(0, 0, 0, 255));
end;

Clockwork.theme:Finish(THEME);