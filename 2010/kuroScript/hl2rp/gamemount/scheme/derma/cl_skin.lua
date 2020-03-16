--[[
	Steam - Flat Default
	Derma Skin
	Ryan 'Joudoki' Lewellen
	Friday, July 11, 2008
]]--

local surface = surface;
local draw 	= draw;
local Color 	= Color;

local SKIN 	= {};

SKIN.PrintName 			= "Steam - Default Flat";
SKIN.Author 					= "Ryan Lewellen";
SKIN.DermaVersion	= 1;

SKIN.fontFrame					= "Default";
SKIN.fontTab						= "Default";
SKIN.fontCategoryHeader	= "TabLarge";
SKIN.fontButton					= "Default";

/*---------------------------------------------------------
   DrawGenericBackground
---------------------------------------------------------*/
function SKIN:DrawGenericBackground( x, y, w, h, color )

	draw.RoundedBox( 4, x, y, w, h, color )

end

function SKIN:SetDrawColor( col )
	if ( ! col ) then
		surface.SetDrawColor( 255,0,255,255 );
		return false
	end
	surface.SetDrawColor( col.r, col.g, col.b, col.a );
	return true
end

function SKIN:DrawTitledBox( x,y,w,h,back,border,title )
	self:SetDrawColor( title );
	surface.DrawRect( x,y+1,w,21 );
	surface.DrawRect( x+1, y, w-2,1 );
	
	self:SetDrawColor( back );
	surface.DrawRect( x+1,y+22,w-2,h-23 );
	
	self:SetDrawColor( border );
	surface.DrawRect( x,y+22,1,h-23 ); -- Left
	surface.DrawRect( x+1,y+h-1,w-2,1 ); -- Bottom
	surface.DrawRect( x+w-1,y+22,1,h-23 ); -- Right
end

function SKIN:DrawBorder( x,y,w,h,border,back,top,left,bottom,right )
	if ( !top ) then top = true end
	if ( !left ) then left = true end
	if ( !bottom ) then bottom = true end
	if ( !right ) then right = true end
	
	self:SetDrawColor( border );
		if ( top == true ) then surface.DrawRect( x+1, y, w-2, 1 ); end -- Top
		if ( left == true ) then surface.DrawRect( x, y+1, 1, h-2 ); end -- Left
		if ( bottom== true ) then surface.DrawRect( x+1, y+h-1, w-2, 1 ); end -- Bottom
		if ( right == true ) then surface.DrawRect( x+w-1, y+1, 1, h-2 ); end -- Right
	
	if ( back != nil and back != false ) then
		local cornerColor = Color( ( back.r + border.r ) / 2, ( back.g + border.g ) / 2, ( back.b + border.b ) / 2, ( back.a + border.a ) / 2 );
		self:SetDrawColor( cornerColor );
			if ( top == true and left == true ) then surface.DrawRect( x+1,y+1,1,1 ); end -- Upper Left
			if ( top == true and right == true ) then surface.DrawRect( x+w-2,y+1,1,1 ); end -- Upper Right
			if ( bottom == true and left == true ) then surface.DrawRect( x+1,y+h-2,1,1 ); end -- Lower Left
			if ( bottom == true and right == true ) then surface.DrawRect( x+w-2,y+h-2,1,1 ); end -- Lower Right
	end
end

function SKIN:DrawBorderedBox( x,y,w,h,back,border,top,left,bottom,right )
	self:SetDrawColor( back );
	surface.DrawRect( x+1,y+1,w-2,h-2 );

	self:DrawBorder( x,y,w,h,border,back,top,left,bottom,right );
end

/*---------------------------------------------------------
	Frame
---------------------------------------------------------*/
function SKIN:PaintFrame( panel )
	
	self:DrawTitledBox( 0,0,panel:GetWide(), panel:GetTall(), Color( 70,70,70,255 ), Color( 104,106,101, 255 ), Color( 90, 106, 80, 255 ) );
	
	--surface.SetDrawColor( 0, 0, 0, 150 )
	--surface.DrawRect( 0, 22, panel:GetWide(), 1 )

end

function SKIN:LayoutFrame( panel )

	panel.lblTitle:SetFont( self.fontFrame )
	
	panel.btnClose:SetPos( panel:GetWide() - 22, 4 )
	panel.btnClose:SetSize( 18, 18 )
	
	panel.lblTitle:SetPos( 8, 2 )
	panel.lblTitle:SetSize( panel:GetWide() - 25, 20 )

end


/*---------------------------------------------------------
	Button
---------------------------------------------------------*/
function SKIN:PaintButton( panel )
	local w, h = panel:GetSize();
	
	-- We have to do text color updates here since scheme button isn't called on hover
	if ( panel:GetDisabled() != true ) then
		if ( panel.Hovered || panel.Depressed || panel:GetSelected() ) then
			panel:SetTextColor( Color( 196,181,80,255 ) );
		else
			panel:SetTextColor( Color( 255,255,255,255 ) );
		end
	end
	
	if ( panel.m_bBackground ) then
		if ( panel.m_bIsListViewHeader and panel.m_bIsListViewHeader == true ) then
			-- Just draw a background
			surface.SetDrawColor( 104,106,101,255 );
			surface.DrawRect( 0,0,w,h );
			return
		end
	
		local col = Color( 85,88,82,255 );		
		
		if ( panel:GetDisabled() ) then
			col = Color( 70,70,70,255 );
		end
		surface.SetDrawColor( col.r, col.g, col.b, col.a );
		surface.DrawRect( 1,1,w-2,h-2 );
	end
end

function SKIN:PaintOverButton( panel )
	local w, h = panel:GetSize();
	if ( panel.m_bBorder ) then
		local col = Color( 7,4,12,255 );
		local backColor  = Color( 85,88,82,255 );
		
		if ( panel:GetDisabled() ) then
			col = Color( 53,53,53,255 );
			backColor = Color( 70,70,70,255 );
		elseif ( panel.Depressed || panel:GetSelected() ) then
			col = Color( 196, 181, 80, 255 );
		end
		
		self:DrawBorder( 0,0,w,h,col,backColor );
	end
end

function SKIN:SchemeButton( panel )
	panel:SetFont( self.fontButton );
	
	if ( panel:GetDisabled() ) then
		panel:SetTextColor( Color( 128,134,126,255 ) );
	else
		panel:SetTextColor( Color( 255,255,255,255 ) );
	end
	
	DLabel.ApplySchemeSettings( panel );

end

/*---------------------------------------------------------
	Panel
---------------------------------------------------------*/
function SKIN:PaintPanel( panel )
	if ( panel.m_bPaintBackground ) then
		local w, h = panel:GetSize();
		self:DrawBorderedBox( 0,0,w,h, Color( 85,85,85,255 ), Color( 7,4,12,255 ) );
	end
end

/*---------------------------------------------------------
	SysButton
---------------------------------------------------------*/
function SKIN:PaintSysButton( panel )
	if ( panel.m_bDrawBackground ) then
		self:DrawBorderedBox( 1,1,panel:GetWide()-2, panel:GetTall()-2, Color( 85,85,85,255 ), Color( 7,4,12,255 ) );
	end
end

function SKIN:SchemeSysButton( panel )
	panel:SetFont( "Marlett" )
	panel:SetTextColor( Color( 216, 222, 211, 255 ) );
	--DLabel.ApplySchemeSettings( panel )	
end


/*---------------------------------------------------------
	ImageButton
---------------------------------------------------------*/
function SKIN:PaintImageButton( panel )
	self:PaintButton( panel );
end

function SKIN:PaintOverImageButton( panel )
	self:PaintOverButton( panel );
end
function SKIN:LayoutImageButton( panel )
	if ( panel.m_bBorder ) then
		panel.m_Image:SetPos( 1, 1 )
		panel.m_Image:SetSize( panel:GetWide()-2, panel:GetTall()-2 )
	else
		panel.m_Image:SetPos( 0, 0 )
		panel.m_Image:SetSize( panel:GetWide(), panel:GetTall() )
	end
end

/*---------------------------------------------------------
	PanelList
---------------------------------------------------------*/
function SKIN:PaintPanelList( panel )
	if ( panel.m_bBackground ) then		
		self:DrawBorderedBox( 0,0,panel:GetWide(), panel:GetTall(), Color( 60,60,60,255 ), Color( 7,4,12,255 ) );
	end
end

/*---------------------------------------------------------
	ScrollBar
---------------------------------------------------------*/
function SKIN:PaintVScrollBar( panel )
	surface.SetDrawColor( 70,70,70,255 );
	surface.DrawRect( 0, 0, panel:GetWide(), panel:GetTall() );
end

function SKIN:LayoutVScrollBar( panel )
	local Wide = panel:GetWide();
	local Scroll = panel:GetScroll() / panel.CanvasSize;
	local BarSize = panel:BarScale() * (panel:GetTall() - (Wide * 2));
	local Track = panel:GetTall() - (Wide * 2) - BarSize;
	Track = Track + 1;
	
	Scroll = Scroll * Track;
	
	panel.btnGrip:SetPos( 0, Wide + Scroll );
	panel.btnGrip:SetSize( Wide, BarSize );
	
	panel.btnUp:SetPos( 0, 0, Wide, Wide );
	panel.btnUp:SetSize( Wide, Wide );
	panel.btnUp.m_scrollbarButton = true;
	
	panel.btnDown:SetPos( 0, panel:GetTall() - Wide, Wide, Wide );
	panel.btnDown:SetSize( Wide, Wide );
	panel.btnDown.m_scrollbarButton = true;
end

function SKIN:PaintScrollBarGrip( panel )
	self:DrawBorderedBox( 1,1,panel:GetWide()-2, panel:GetTall()-2, Color( 85,85,85,255 ), Color( 7,4,12,255 ) );
end


/*---------------------------------------------------------
	Menu and Menu Options
---------------------------------------------------------*/
function SKIN:PaintMenu( panel )
	surface.SetDrawColor( 47,49,45,255 );
	surface.DrawRect( 1,1,panel:GetWide()-2,panel:GetTall()-2 );
end

function SKIN:PaintOverMenu( panel )
	self:DrawBorder( 0,0,panel:GetWide(),panel:GetTall(), Color( 104,106,101,255 ), Color( 47,49,45,255 ) );
end

function SKIN:LayoutMenu( panel )
	local w = panel:GetMinimumWidth();
	
	// Find the widest one
	for k, pnl in pairs( panel.Panels ) do	
		pnl:PerformLayout();
		w = math.max( w, pnl:GetWide() );	
	end

	panel:SetWide( w );
	
	local y = 0;
	
	for k, pnl in pairs( panel.Panels ) do	
		pnl:SetWide( w );
		pnl:SetPos( 0, y );
		pnl:InvalidateLayout( true );
		
		y = y + pnl:GetTall();
	end
	
	panel:SetTall( y );
end

function SKIN:PaintMenuOption( panel )
	-- Hovering Color for Text
	if ( panel.Hovered ) then	
		panel:SetFGColor( 255,255,255,255 );
		if ( panel.m_bBackground ) then
			surface.SetDrawColor( 145,134,60,255 );
			surface.DrawRect( 1, 1, panel:GetWide()-2, panel:GetTall()-2 );
		end
	else
		panel:SetFGColor( 216,222,211,255 );
	end
end

function SKIN:LayoutMenuOption( panel )
	// This is totally messy. :/
	panel:SizeToContents()
	panel:SetWide( panel:GetWide() + 30 )
	
	local w = math.max( panel:GetParent():GetWide(), panel:GetWide() )
	panel:SetSize( w, 18 )
	
	if ( panel.SubMenuArrow ) then	
		panel.SubMenuArrow:SetSize( panel:GetTall(), panel:GetTall() );
		panel.SubMenuArrow:CenterVertical();
		panel.SubMenuArrow:AlignRight();
	end	
end

function SKIN:SchemeMenuOption( panel )
	panel:SetFGColor( 216,222,211,255 );
end

/*---------------------------------------------------------
	TextEntry
---------------------------------------------------------*/
function SKIN:PaintTextEntry( panel )
	if ( panel.m_bBackground ) then	
		surface.SetDrawColor( 94,94,94,255 );
		surface.DrawRect( 1, 1, panel:GetWide()-2, panel:GetTall()-2 );
	end
	
	panel:DrawTextEntryText( panel.m_colText, panel.m_colHighlight, panel.m_colCursor );
	
	if ( panel.m_bBorder ) then
		self:DrawBorder( 0,0,panel:GetWide(),panel:GetTall(), Color( 7,4,12,255 ), Color( 94,94,94,255 ) );
	end	
end

function SKIN:SchemeTextEntry( panel )
	panel:SetTextColor( Color( 255,255,255,255 ) );
	panel:SetHighlightColor( Color( 255,255,255,255 ) );
	panel:SetCursorColor( Color( 255,255,255,255 ) );
end

/*---------------------------------------------------------
	Label
---------------------------------------------------------*/
function SKIN:PaintLabel( panel )
	return false
end

function SKIN:SchemeLabel( panel )
	col = Color( 216,222,211,255 );
	if ( panel.Hovered == true ) then
		col = Color( 196,181,80,255 );
	end
	
	-- Check if a statement is true.
	if (panel.isColored and panel.GetTextColor and panel:GetTextColor()) then
		col = panel:GetTextColor();
	end;
	panel:SetFGColor( col.r, col.g, col.b, col.a );
end

function SKIN:LayoutLabel( panel )
	panel:ApplySchemeSettings();
	
	if ( panel.m_bAutoStretchVertical ) then
		panel:SizeToContentsY();
	end	
end

/*---------------------------------------------------------
	CategoryHeader
---------------------------------------------------------*/
function SKIN:PaintCategoryHeader( panel )
	-- If the fucker is going to be changing color on me all the time
	-- I'll just overrule it every goddamned frame
	
	local w,h = panel:GetSize();
	surface.SetDrawColor( 196,181,80,255 );
	
	local expanderPos = { x=0, y=0 };
	local expanderSize = 8;
	local expanderWidth = 2;
	expanderPos.y = h / 2;
	expanderPos.x = expanderPos.y;
	
	surface.DrawRect( expanderPos.x - expanderSize/2, expanderPos.y - expanderWidth/2, expanderSize, expanderWidth  ); -- Dash
	if ( panel:GetParent():GetExpanded() == false ) then
		surface.DrawRect( expanderPos.x - expanderWidth/2, expanderPos.y - expanderSize/2, expanderWidth, expanderSize ); -- -|-
	end
	
	--surface.DrawRect( 0,0,panel:GetWide(),panel:GetTall() );
end

function SKIN:SchemeCategoryHeader( panel )
	local w,h = panel:GetSize();
	panel:SetTextInset( h + 2 );
	panel:SetFont( self.fontCategoryHeader );
	
	
	if ( panel:GetParent():GetExpanded() ) then
		
	else
		--panel:SetTextColor( self.colCategoryTextInactive )
	end
end


/*---------------------------------------------------------
	CollapsibleCategory
---------------------------------------------------------*/
function SKIN:PaintCollapsibleCategory( panel )
	self:DrawBorderedBox( 0,0,panel:GetWide(),panel:GetTall(),Color( 43,45,41,255 ), Color( 104,106,101 ) );
end

/*---------------------------------------------------------
	Tab
---------------------------------------------------------*/
function SKIN:PaintTab( panel )
	local backCol = Color( 70,70,70,255 );
	if ( panel:GetPropertySheet():GetActiveTab() == panel ) then
		backCol = Color( 104,106,101,255 );
	end
	self:DrawBorderedBox( 0,0,panel:GetWide(),panel:GetTall(),backCol,Color( 116,116,116,255 ), true,true,false,true );
end
function SKIN:SchemeTab( panel )
	panel:SetFont( self.fontTab );
	
	local ExtraInset = 10;
	if ( panel.Image ) then
		ExtraInset = ExtraInset + panel.Image:GetWide();
	end
	
	panel:SetTextInset( ExtraInset );
	panel:SizeToContents();
	panel:SetSize( panel:GetWide() + 10, panel:GetTall() + 8 );
	
	local Active = panel:GetPropertySheet():GetActiveTab() == panel;
	
	if ( Active ) then
		panel:SetTextColor( Color( 196,181,80,255 ) );
	else
		panel:SetTextColor( Color( 216,222,211,255 ) );
	end
	
	panel.BaseClass.ApplySchemeSettings( panel );		
end

function SKIN:LayoutTab( panel )
	panel:SetTall( 22 );

	if ( panel.Image ) then	
		local Active = panel:GetPropertySheet():GetActiveTab() == panel;
		
		local Diff = panel:GetTall() - panel.Image:GetTall();
		panel.Image:SetPos( 7, Diff * 0.6 );
		
		if ( !Active ) then
			panel.Image:SetImageColor( Color( 170, 170, 170, 155 ) );
		else
			panel.Image:SetImageColor( Color( 255, 255, 255, 255 ) );
		end
	end;	
end

/*---------------------------------------------------------
	PropertySheet
---------------------------------------------------------*/
function SKIN:PaintPropertySheet( panel )
	local ActiveTab = panel:GetActiveTab();
	local Offset = 0;
	if ( ActiveTab ) then Offset = ActiveTab:GetTall() end
	
	surface.SetDrawColor( 104,106,101,255 );
	surface.DrawRect( 0, Offset, panel:GetWide(), panel:GetTall()-Offset );
end


/*---------------------------------------------------------
	ListViewLine
---------------------------------------------------------*/
function SKIN:PaintListViewLine( panel )
	local newColor = nil;
	if ( panel:IsSelected() or panel.Hovered ) then
		self:DrawBorderedBox( 0,0,panel:GetWide(),panel:GetTall(),Color( 0,0,0,0 ), Color( 196,181,80,255 ) );
	end
end

-- This doesn't appear to be called at all
function SKIN:LayoutListViewLabel( panel )
	panel:SetTextInset( 10 );
	
	if ( panel.Line and panel.Line:IsSelected() ) then
		panel:SetTextColor( Color( 196,181,80,255 ) );	
	else
		panel:SetTextColor( Color( 230,236,234,255 ) );	
	end
end

function SKIN:SchemeListViewColumn( panel )
	panel.Header.m_bIsListViewHeader = true;
end


/*---------------------------------------------------------
	Form
---------------------------------------------------------*/
function SKIN:PaintForm( panel )
	self:DrawBorderedBox( 0,0,panel:GetWide(),panel:GetTall(),Color( 43,45,41,255 ), Color( 104,106,101 ) );
end
function SKIN:SchemeForm( panel )
	panel.Label:SetFont( "TabLarge" );
	panel.Label:SetTextColor( Color( 255, 255, 255, 255 ) );
end
function SKIN:LayoutForm( panel )

end


/*---------------------------------------------------------
	MultiChoice
---------------------------------------------------------*/
function SKIN:LayoutMultiChoice( panel )
	panel.TextEntry:SetSize( panel:GetWide(), panel:GetTall() );
	
	panel.DropButton:SetSize( panel:GetTall(), panel:GetTall() );
	panel.DropButton:SetPos( panel:GetWide() - panel:GetTall(), 0 );
	
	panel.DropButton:SetZPos( 1 );
	panel.DropButton:SetDrawBackground( false );
	panel.DropButton:SetDrawBorder( false );
	
	panel.DropButton:SetTextColor( Color( 30, 100, 200, 255 ) );
	panel.DropButton:SetTextColorHovered( Color( 196,181,80,255 ) );
end


/*---------------------------------------------------------
NumberWangIndicator
---------------------------------------------------------*/
function SKIN:DrawNumberWangIndicatorText( panel, wang, x, y, number, alpha )

	local alpha = math.Clamp( alpha ^ 0.5, 0, 1 ) * 255
	local col = self.text_dark
	
	// Highlight round numbers
	local dec = (wang:GetDecimals() + 1) * 10
	if ( number / dec == math.ceil( number / dec ) ) then
		col = self.text_highlight
	end

	draw.SimpleText( number, "Default", x, y, Color( col.r, col.g, col.b, alpha ) )
	
end

function SKIN:PaintNumberWangIndicator( panel )
	
	/*
	
		Please excuse the crudeness of this code.
	
	*/

	if ( panel.m_bTop ) then
		surface.SetMaterial( self.texGradientUp )
	else
		surface.SetMaterial( self.texGradientDown )
	end
	
	surface.SetDrawColor( self.colNumberWangBG )
	surface.DrawTexturedRect( 0, 0, panel:GetWide(), panel:GetTall() )
	
	local wang = panel:GetWang()
	local CurNum = math.floor( wang:GetFloatValue() )
	local Diff = CurNum - wang:GetFloatValue()
		
	local InsetX = 3
	local InsetY = 5
	local Increment = wang:GetTall()
	local Offset = Diff * Increment
	local EndPoint = panel:GetTall()
	local Num = CurNum
	local NumInc = 1
	
	if ( panel.m_bTop ) then
	
		local Min = wang:GetMin()
		local Start = panel:GetTall() + Offset
		local End = Increment * -1
		
		CurNum = CurNum + NumInc
		for y = Start, Increment * -1, End do
	
			CurNum = CurNum - NumInc
			if ( CurNum < Min ) then break end
					
			self:DrawNumberWangIndicatorText( panel, wang, InsetX, y + InsetY, CurNum, y / panel:GetTall() )
		
		end
	
	else
	
		local Max = wang:GetMax()
		
		for y = Offset - Increment, panel:GetTall(), Increment do
			
			self:DrawNumberWangIndicatorText( panel, wang, InsetX, y + InsetY, CurNum, 1 - ((y+Increment) / panel:GetTall()) )
			
			CurNum = CurNum + NumInc
			if ( CurNum > Max ) then break end
		
		end
	
	end
	

end

function SKIN:LayoutNumberWangIndicator( panel )

	panel.Height = 200

	local wang = panel:GetWang()
	local x, y = wang:LocalToScreen( 0, wang:GetTall() )
	
	if ( panel.m_bTop ) then
		y = y - panel.Height - wang:GetTall()
	end
	
	panel:SetPos( x, y )
	panel:SetSize( wang:GetWide() - wang.Wanger:GetWide(), panel.Height)

end

/*---------------------------------------------------------
	CheckBox
---------------------------------------------------------*/
function SKIN:PaintCheckBox( panel )
	local w, h = panel:GetSize();
	self:DrawBorderedBox( 0,0,w,h,Color( 70,70,70,255 ), Color( 7,4,12,255 ) );
	if ( panel.Hovered ) then
	
	else
	
	end
end

function SKIN:SchemeCheckBox( panel )
	panel:SetTextColor( Color( 255, 100, 255, 255 ) );
	DSysButton.ApplySchemeSettings( panel );
end


/*---------------------------------------------------------
	Slider
---------------------------------------------------------*/
function SKIN:PaintSlider( panel )
	--surface.SetDrawColor( 255,100,255,255 );
	--surface.DrawRect( 0,0,panel:GetWide(),panel:GetTall() );
end


/*---------------------------------------------------------
	NumSlider
---------------------------------------------------------*/
function SKIN:PaintNumSlider( panel )
	local w, h = panel:GetSize();
	--self:DrawGenericBackground( 0, 0, w, h, Color( 255,0,0,255 ) );
	
	self:DrawBorderedBox( 2, h/4, w-4, h/2, Color( 70,70,70,255 ), Color( 125,128,120,255 ) );
end


/*---------------------------------------------------------
	ComboBox
---------------------------------------------------------*/
function SKIN:PaintComboBox( panel )
	self:DrawBorderedBox( 0,0,panel:GetWide(),panel:GetTall(), Color( 104,106,101,255 ), Color( 47,49,45,255 ) );
end


/*---------------------------------------------------------
	ComboBoxItem
---------------------------------------------------------*/
function SKIN:PaintComboBoxItem( panel )
	local w,h = panel:GetSize();
	if ( panel:GetSelected() ) then	
		surface.SetDrawColor( 196,181,80,255 );
		surface.DrawRect( 0,0,2,h );
	elseif ( panel.Hovered ) then
		surface.SetDrawColor( 196,181,80,255 );
	else
		surface.SetDrawColor( 217,223,212,255 );
	end
end

function SKIN:SchemeComboBoxItem( panel )
	print( "Sceming ComboBoxItem" );
	panel:SetTextColor( 217,223,212,255 );
end


/*---------------------------------------------------------
	Bevel
---------------------------------------------------------*/
function SKIN:PaintBevel( panel )

	local w, h = panel:GetSize()

	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.DrawOutlinedRect( 0, 0, w-1, h-1)
	
	surface.SetDrawColor( 0, 0, 0, 255 )
	surface.DrawOutlinedRect( 1, 1, w-1, h-1)

end


/*---------------------------------------------------------
	Tree
---------------------------------------------------------*/
function SKIN:PaintTree( panel )
	if ( panel.m_bBackground ) then
		surface.SetDrawColor( 50,50,50,255 );
		surface.DrawRect( 0,0,panel:GetWide(), panel:GetTall() );
		--self:DrawBorderedBox( 0,0,panel:GetWide(),panel:GetTall(),Color( 50,50,50,255 ),Color( 104,106,101,255 ) );
	end
end


/*---------------------------------------------------------
	TinyButton
---------------------------------------------------------*/
function SKIN:PaintTinyButton( panel )
	-- First, determine if it's a treeview expander
	--if ( panel:GetParent():GetClassName() == "DTree_Node" ) then
		local Col = Color( 220,236,224,255 );
		if ( panel.Hovered == true ) then
			Col = Color( 196,181,80,255 );
		end
		panel:SetTextColor( Col );
		w,h = panel:GetSize();
		--surface.DrawRect( 1, ( h / 2 ) - 1, w -2, 2 );
		--if ( panel:GetParent().m_bExpanded == true ) then
			--surface.DrawRect( ( w / 2) - 1, 1, 2, h - 2 );
		--end
	--[[else
		if ( panel.m_bBackground ) then
			surface.SetDrawColor( 255, 255, 255, 255 )
			panel:DrawFilledRect()
		end
		
		if ( panel.m_bBorder ) then
			surface.SetDrawColor( 0, 0, 0, 255 )
			panel:DrawOutlinedRect()
		end
	end]]--
end

function SKIN:SchemeTinyButton( panel )
	panel:SetFont( "Default" )
	
	if ( panel:GetDisabled() ) then
		panel:SetTextColor( Color( 0, 0, 0, 50 ) )
	else
		panel:SetTextColor( Color( 0, 0, 0, 255 ) )
	end
	
	DLabel.ApplySchemeSettings( panel )
	
	panel:SetFont( "DefaultSmall" )
end


/*---------------------------------------------------------
	Tree Nodes
---------------------------------------------------------*/
function SKIN:PaintTreeNodeButton( panel )
	if ( panel.m_bSelected ) then
		panel:SetTextColor( 196,181,80,255 );
		self:DrawBorderedBox( 0,0,panel:GetWide(),panel:GetTall(), Color(0,0,0,0), Color( 196,181,80,255 ) );
	elseif ( panel.Hovered ) then
		panel:SetTextColor( 196,181,80,255 );
	else
		panel:SetTextColor( 230,236,224,255 );
	end
	
	if ( panel:GetParent().m_bExpanded == true and panel.m_bSelected == false ) then
		-- Expanded
		surface.SetDrawColor( 121,126,121,255 );
		surface.DrawRect( panel:GetParent():GetIndentSize(), panel:GetTall() - 2, panel:GetWide(), 1 );
	end
end

function SKIN:SchemeTreeNodeButton( panel )
	DLabel.ApplySchemeSettings( panel );
end

/*---------------------------------------------------------
	Tooltip
---------------------------------------------------------*/
function SKIN:PaintTooltip( panel )
	local w, h = panel:GetSize();
	DisableClipping( true );	
	self:DrawBorderedBox( 0,0,panel:GetWide(),panel:GetTall(), Color( 47,49,45,255 ), Color( 104,106,101,255 ) );	
	panel:DrawArrow( 0, 0 );
	DisableClipping( false );
end

derma.DefineSkin( "steam_flat", "Steam Flat - Default", SKIN );