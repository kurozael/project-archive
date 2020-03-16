--[[
Name: "cl_labelbutton.lua".
Product: "nexus".
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
			
			if (animation.Finished and Callback) then
				Callback();
			end;
		end);
		
		if (self.animation) then
			self.animation:Start(speed);
		end;
	elseif (Callback) then
		Callback();
	end;
end;

-- A function to make the panel fade in.
function PANEL:FadeIn(speed, Callback)
	if ( self:GetAlpha() == 0 and ( !self.animation or !self.animation:Active() ) ) then
		self.animation = Derma_Anim("Fade Panel", self, function(panel, animation, delta, data)
			panel:SetAlpha(delta * 255);
			
			if (animation.Finished and Callback) then
				Callback();
			end;
		end);
		
		if (self.animation) then
			self.animation:Start(speed);
		end;
	elseif (Callback) then
		Callback();
	end;
end;

-- Called every frame.
function PANEL:Think()
	if (self.animation) then
		self.animation:Run();
	end;
	
	if ( self:GetHovered() or self:GetDisabled() ) then
		self:SetTextColor( Color(200, 200, 200, 255) );
		self:SetExpensiveShadow( 1, Color(0, 0, 0, 150) );
	else
		self:SetTextColor( Color(255, 255, 255, 255) );
		self:SetExpensiveShadow( 1, Color(0, 0, 0, 150) );
	end;
end;

-- A function to set the panel's Callback.
function PANEL:SetCallback(Callback)
	self.DoClick = Callback;
end;

vgui.Register("nx_LabelButton", PANEL, "DLabel");