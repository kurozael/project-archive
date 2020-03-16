--[[
	© 2012 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local THEME = Clockwork.theme:Begin();

--[[ Define the main theme color here, for easy access. --]]
local MAIN_COLOR = Color(243, 213, 71, 255);
local BACKGROUND_COLOR = Color(50, 50, 50, 255);
local FOREGROUND_COLOR = Color(125, 125, 125, 255);

-- Called when fonts should be created.
function THEME:CreateFonts()
	surface.CreateFont("Anklada™", GetFontSize3D(), 600, true, false, "test_Large3D2D");
	surface.CreateFont("Anklada™", FontScreenScale(24), 600, true, false, "test_IntroTextSmall");
	surface.CreateFont("Anklada™", FontScreenScale(17), 600, true, false, "test_IntroTextTiny");
	surface.CreateFont("Anklada™", FontScreenScale(22), 600, true, false, "test_CinematicText");
	surface.CreateFont("Anklada™", FontScreenScale(45), 600, true, false, "test_IntroTextBig");
	surface.CreateFont("Anklada™", FontScreenScale(17), 600, true, false, "test_TargetIDText");
	surface.CreateFont("Anklada™", FontScreenScale(11), 600, true, false, "test_SmallBarText");
	surface.CreateFont("Anklada™", FontScreenScale(70), 600, true, false, "test_MenuTextHuge");
	surface.CreateFont("Anklada™", FontScreenScale(45), 600, true, false, "test_MenuTextBig");
	surface.CreateFont("Anklada™", FontScreenScale(14), 600, true, false, "test_PlayerInfoText");
	surface.CreateFont("Anklada™", FontScreenScale(14), 600, true, false, "test_MainText");
end;

-- Called when to initialize theme.
function THEME:Initialize()
	Clockwork.option:SetColor("information", MAIN_COLOR);
	Clockwork.option:SetColor("background", BACKGROUND_COLOR);
	Clockwork.option:SetColor("foreground", FOREGROUND_COLOR);
	Clockwork.option:SetColor("target_id", Color(114, 203, 213, 255));
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

THEME.skin.frameBorder = MAIN_COLOR;
THEME.skin.frameTitle = MAIN_COLOR;

THEME.skin.bgColorBright = MAIN_COLOR;
THEME.skin.bgColorSleep = Color(70, 70, 70, 255);
THEME.skin.bgColorDark = Color(50, 50, 50, 255);
THEME.skin.bgColor = Color(40, 40, 40, 225);

THEME.skin.controlColorHighlight = Color(70, 70, 70, 255);
THEME.skin.controlColorActive = Color(175, 175, 175, 255);
THEME.skin.controlColorBright = Color(100, 100, 100, 255);
THEME.skin.controlColorDark = Color(30, 30, 30, 255);
THEME.skin.controlColor = Color(60, 60, 60, 255);

THEME.skin.colTabTextInactive = MAIN_COLOR;
THEME.skin.colPropertySheet = MAIN_COLOR;
THEME.skin.colTabInactive = BACKGROUND_COLOR;
THEME.skin.colTabShadow = Color(0, 0, 0, 170);
THEME.skin.colTabText = BACKGROUND_COLOR;
THEME.skin.colTab = MAIN_COLOR;

THEME.skin.fontCategoryHeader = "test_MainText";
THEME.skin.fontMenuOption = "test_MainText";
THEME.skin.fontFormLabel = "test_MainText";
THEME.skin.fontButton = "test_MainText";
THEME.skin.fontFrame = "test_MainText";
THEME.skin.fontTab = "test_MainText";

-- A function to draw a generic background.
function THEME.skin:DrawGenericBackground(x, y, w, h, color)
	surface.SetDrawColor(color.r, color.g, color.b, color.a);
	surface.DrawRect(x, y, w, h);
end;

-- Called when a frame is layed out.
function THEME.skin:LayoutFrame(panel)
	panel.lblTitle:SetFont(self.fontFrame);
	panel.lblTitle:SetText(panel.lblTitle:GetText():upper());
	panel.lblTitle:SetTextColor(BACKGROUND_COLOR);
	panel.lblTitle:SizeToContents();
	panel.lblTitle:SetExpensiveShadow(1, Color(255, 255, 255, 200));
	
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
	panel.Label:SetTextColor(MAIN_COLOR);
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
		surface.SetDrawColor(Clockwork:UnpackColor(MAIN_COLOR));
		panel:DrawFilledRect();
	end;
end;
	
-- Called when a list view line is painted.
function THEME.skin:PaintListViewLine(panel)
	local color = Color(50, 50, 50, 255);
	local textColor = MAIN_COLOR;
	
	if (panel:IsSelected()) then
		color = MAIN_COLOR;
		textColor = BACKGROUND_COLOR;
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
	panel:SetTextColor(MAIN_COLOR);
end;

-- Called when a menu is painted.
function THEME.skin:PaintMenu(panel)
	surface.SetDrawColor(BACKGROUND_COLOR);
	panel:DrawFilledRect(0, 0, w, h);
end;

-- Called when a menu is painted over.
function THEME.skin:PaintOverMenu(panel) end;

-- Called when a menu option is schemed.
function THEME.skin:SchemeMenuOption(panel)
	panel:SetFGColor(MAIN_COLOR);
end;

-- Called when a menu option is painted.
function THEME.skin:PaintMenuOption(panel)
	local textColor = MAIN_COLOR;
	
	if (panel.m_bBackground and panel.Hovered) then
		local color = nil;

		if (panel.Depressed) then
			color = Color(225, 225, 225, 255);
		else
			color = MAIN_COLOR;
		end;

		surface.SetDrawColor(color.r, color.g, color.b, color.a);
		surface.DrawRect(0, 0, panel:GetWide(), panel:GetTall());
		textColor = BACKGROUND_COLOR;
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
	local textColor = MAIN_COLOR;
	
	if (panel.m_bBackground) then
		local color = BACKGROUND_COLOR;
		local borderColor = MAIN_COLOR;
		
		if (panel:GetDisabled()) then
			color = self.controlColorDark;
		elseif (panel.Depressed or panel:GetSelected()) then
			color = MAIN_COLOR;
			textColor = BACKGROUND_COLOR;
		elseif (panel.Hovered) then
			color = self.controlColorHighlight;
		end;
		
		self:DrawGenericBackground(1, 1, w - 2, h - 2, color);
	end;
	
	panel:SetFGColor(textColor);
end;

-- Called when a scroll bar grip is painted.
function THEME.skin:PaintScrollBarGrip(panel)
	local w, h = panel:GetSize();
	self:DrawGenericBackground(0, 0, w, h, MAIN_COLOR);
	self:DrawGenericBackground(2, 2, w - 4, h - 4, BACKGROUND_COLOR);
end;

--[[ Change the LabelButton control from the factory. --]]
local cwLabelButton = THEME.factory["cwLabelButton"];

if (cwLabelButton) then
	function cwLabelButton:Paint()
		if (self:GetHovered()) then
			self:SetTextColor(Color(255, 255, 255, 255));
			
			DisableClipping(true);
				draw.RoundedBox(
					0, -4, -2, self:GetWide() + 8, self:GetTall() + 4, Color(125, 125, 125, 200)
				);
			DisableClipping(false);
		elseif (self.OverrideColorNormal) then
			self:SetTextColor(Color(255, 255, 255, 255));
			
			DisableClipping(true);
				draw.RoundedBox(
					0, -4, -2, self:GetWide() + 8, self:GetTall() + 4, Color(
						self.OverrideColorNormal.r,
						self.OverrideColorNormal.g,
						self.OverrideColorNormal.b,
						200
					)
				);
			DisableClipping(false);
		else
			self:SetTextColor(Color(225, 225, 225, 255));
		end;
	end;
end;

--[[ Change the InfoText control from the factory. --]]
local cwInfoText = THEME.factory["cwInfoText"];

if (cwInfoText) then
	function cwInfoText:Paint()
		if (self:GetPaintBackground()) then
			local width, height = self:GetSize();
			local x, y = 0, 0;
			
			if (self:IsDepressed()) then
				height = height - 4;
				width = width - 4;
				x = x + 2;
				y = y + 2;
			end;
			
			Clockwork:DrawSimpleGradientBox(
				0, x, y, width, height, self:GetBackgroundColor(), 50
			);
			
			if (self:IsButton() and self:IsHovered()) then
				Clockwork:DrawSimpleGradientBox(
					0, x, y, width, height, Color(255, 255, 255, 50), 50
				);
			end;
		end	
		
		return true;
	end;
end;

Clockwork.theme:Finish(THEME);