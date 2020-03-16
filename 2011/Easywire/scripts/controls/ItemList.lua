--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
--]]

CONTROL.m_sBaseClass = "Panel";

-- Called when the size of the control is based on it's contents.
function CONTROL:OnSizeToContents()
	return self.m_canvasPanel:GetW(), self.m_canvasPanel:GetH();
end;

-- Called when the control's layout should be performed.
function CONTROL:OnPerformLayout()
	local width = self:GetW();
	local height = self:GetH();
	local offsetY = 0;

	if ( self.m_scrollBar and self.m_scrollBar:IsValid() ) then
		self.m_scrollBar:SetSize(16, height);
		self.m_scrollBar:SetPos(width - 16, 0);
		self.m_scrollBar:SetUp( height, self.m_canvasPanel:GetH() );
			offsetY = self.m_scrollBar:GetOffset();
		width = width - 16;
	end;

	self.m_canvasPanel:SetPos(0, offsetY);
	self.m_canvasPanel:SetWidth(width);
	
	if (self.m_bAutoSize) then
		self:Rebuild(); self:SetHeight( self.m_canvasPanel:GetH() );
		self.m_canvasPanel:SetPos(0, 0);
	else
		self:Rebuild();
	end;
end;

-- Called when the control has initialized.
function CONTROL:OnInitialize(arguments)
	self.m_canvasPanel = controls.Create("Panel", self);
	self.m_canvasPanel:SetColor( Color(0, 0, 0, 0) );
	self.m_items = {};
	
	self:SetDraggable(false);
	self:SetAutoSize(false);
	self:SetSpacing(0);
	self:SetPadding(0);
	self:SetColor( Color(0.3, 0.3, 0.3, 1) );
end;

-- A function to enable the scrollbar.
function CONTROL:EnableScrollBar()
	if (not self.m_scrollBar) then
		self.m_scrollBar = controls.Create("VScrollBar", self);
		self:InvalidateLayout();
	end;
end;

-- A function to disable the scrollbar.
function CONTROL:DisableScrollBar()
	if (self.m_scrollBar) then
		self.m_scrollBar:Remove();
		self.m_scrollBar = nil;
		self:InvalidateLayout();
	end;
end;

-- Called when the control has been vertically scrolled.
function CONTROL:OnVerticalScroll(offsetY)
	self.m_canvasPanel:SetPos(0, offsetY);
end;

-- Called every frame for the control.
function CONTROL:OnUpdate(deltaTime)
	if ( self.m_canvasPanel:GetH() > self:GetH() ) then
		self:EnableScrollBar();
	else
		self:DisableScrollBar();
	end;
end;

-- Called when the control is drawn.
function CONTROL:OnDraw()
	draw.StyledBox( self:GetX() - 2, self:GetY() - 2, self:GetW() + 4, self:GetH() + 4, self:GetColor() );
end;

-- A function to get the control's canvas.
function CONTROL:GetCanvas()
	return self.m_canvasPanel;
end;

-- A function to get the control's items.
function CONTROL:GetItems()
	return self.m_items;
end;

-- A function to add an item to the control.
function CONTROL:AddItem(item)
	if ( item and item:IsValid() ) then
		item:SetVisible(true);
		item:SetParent(self.m_canvasPanel);
		
		self.m_items[#self.m_items + 1] = item;
		self:InvalidateLayout();
	end;
end;

-- A function to rebuild the control.
function CONTROL:Rebuild()
	if (self.m_bHorizontal) then
		local x, y = self.m_iPadding, self.m_iPadding;
		local wrapX = self:GetW();
		local offsetY = 0
		
		if ( self.m_scrollBar and self.m_scrollBar:IsValid() ) then
			wrapX = wrapX - 16;
		end;

		for k, v in ipairs(self.m_items) do
			if ( v:IsVisible() ) then
				local width = v:GetW()
				local height = v:GetH()
				
				if (x + width > wrapX) then
					x = self.m_iPadding;
					y = y + height + self.m_iSpacing;
				end;
				
				v:SetPos(x, y);
				
				x = x + width + self.m_iSpacing;
				offsetY = y + height + self.m_iSpacing;
			end;
		end;

		self.m_canvasPanel:SetHeight(offsetY + (self.m_iPadding) - self.m_iSpacing);
	else
		local offsetY = 0
		
		for k, v in ipairs(self.m_items) do
			if ( v:IsVisible() ) then
				v:SetPos(self.m_iPadding, self.m_iPadding + offsetY);
				v:SetSize( self.m_canvasPanel:GetW() - self.m_iPadding * 2, v:GetH() );
				
				offsetY = offsetY + v:GetH() + self.m_iSpacing;
			end;
		end;

		self.m_canvasPanel:SetHeight( (offsetY + self.m_iPadding) + (self.m_iPadding) - self.m_iSpacing );
	end;
end;

-- A function to clear the control's items.
function CONTROL:Clear()
	for k, v in ipairs(self.m_items) do
		v:Remove();
	end;
	
	self.m_items = {}; self:InvalidateLayout();
end;

util.AddAccessor(CONTROL, "SizeToContents", "m_bSizeToContents");
util.AddAccessor(CONTROL, "Horizontal", "m_bHorizontal");
util.AddAccessor(CONTROL, "AutoSize", "m_bAutoSize");
util.AddAccessor(CONTROL, "Padding", "m_iPadding");
util.AddAccessor(CONTROL, "Spacing", "m_iSpacing");