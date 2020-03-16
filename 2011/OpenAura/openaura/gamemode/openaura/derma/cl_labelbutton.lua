--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PANEL = {};

-- A function to set whether the panel is disabled.
function PANEL:SetDisabled(disabled)
	self.Disabled = disabled;
end;

-- A function to get whether the panel is disabled.
function PANEL:GetDisabled()
	return self.Disabled;
end;

-- A function to set whether the panel is depressed.
function PANEL:SetDepressed(depressed)
	self.Depressed = depressed;
end;

-- A function to get whether the panel is depressed.
function PANEL:GetDepressed()
	return self.Depressed;
end;

-- A function to set whether the panel is hovered.
function PANEL:SetHovered(hovered)
	self.Hovered = hovered;
end;

-- A function to get whether the panel is hovered.
function PANEL:GetHovered()
	return self.Hovered;
end;

-- Called when the cursor has entered the panel.
function PANEL:OnCursorEntered()
	if ( !self:GetDisabled() ) then
		self:SetHovered(true);
	end;
	
	DLabel.ApplySchemeSettings(self);
end;

-- Called when the cursor has exited the panel.
function PANEL:OnCursorExited()
	self:SetHovered(false);

	DLabel.ApplySchemeSettings(self);
end;

-- Called when the mouse is pressed.
function PANEL:OnMousePressed(code)
	self:MouseCapture(true);
	self:SetDepressed(true);
end;

-- Called when the mouse is released.
function PANEL:OnMouseReleased(code)
	self:MouseCapture(false);
	
	if ( self:GetDepressed() ) then
		self:SetDepressed(false);
		
		if ( !self:GetHovered() ) then
			return;
		end;
		
		if (code == MOUSE_LEFT) then
			if ( self.DoClick and !self:GetDisabled() ) then
				self.DoClick(self);
			end;
		end;
	end;
end;

-- A function to make the panel fade out.
function PANEL:FadeOut(speed, Callback)
	if ( self:GetAlpha() > 0 and ( !self.animation or !self.animation:Active() ) ) then
		self.animation = Derma_Anim("Fade Panel", self, function(panel, animation, delta, data)
			panel:SetAlpha( 255 - (delta * 255) );
			
			if (animation.Finished) then
				panel:SetVisible(false);
			end;
			
			if (animation.Finished and Callback) then
				Callback();
			end;
		end);
		
		if (self.animation) then
			self.animation:Start(speed);
		end;
		
		openAura.option:PlaySound("rollover");
	else
		self:SetVisible(false);
		self:SetAlpha(0);
		
		if (Callback) then
			Callback();
		end;
	end;
end;

-- A function to make the panel fade in.
function PANEL:FadeIn(speed, Callback)
	if ( self:GetAlpha() == 0 and ( !self.animation or !self.animation:Active() ) ) then
		self.animation = Derma_Anim("Fade Panel", self, function(panel, animation, delta, data)
			panel:SetVisible(true);
			panel:SetAlpha(delta * 255);
			
			if (animation.Finished) then
				self.animation = nil;
			end;
			
			if (animation.Finished and Callback) then
				Callback();
			end;
		end);
		
		if (self.animation) then
			self.animation:Start(speed);
		end;
		
		openAura.option:PlaySound("click_release");
	else
		self:SetVisible(true);
		self:SetAlpha(255);
		
		if (Callback) then
			Callback();
		end;
	end;
end;

-- A function to override the text color.
function PANEL:OverrideTextColor(color)
	self.OverrideColorNormal = color;
	self.OverrideColorHover = Color(math.max(color.r - 50, 0), math.max(color.g - 50, 0), math.max(color.b - 50, 0), color.a);
end;

-- Called every frame.
function PANEL:Think()
	if (self.animation) then
		self.animation:Run();
	end;
	
	local colorWhite = openAura.option:GetColor("white");
	local colorDisabled = Color(
		math.max(colorWhite.r - 50, 0),
		math.max(colorWhite.g - 50, 0),
		math.max(colorWhite.b - 50, 0),
		255
	);
	local colorInfo = openAura.option:GetColor("information");
	
	if ( self:GetDisabled() ) then
		self:SetTextColor(self.OverrideColorHover or colorDisabled);
	elseif ( self:GetHovered() ) then
		self:SetTextColor(self.OverrideColorHover or colorInfo);
	else
		self:SetTextColor(self.OverrideColorNormal or colorWhite);
	end;
	
	self:SetExpensiveShadow( 1, Color(0, 0, 0, 150) );
end;

-- A function to set the panel's Callback.
function PANEL:SetCallback(Callback)
	self.DoClick = function(button)
		openAura.option:PlaySound("click");
		Callback(button);
	end;
end;

vgui.Register("aura_LabelButton", PANEL, "DLabel");