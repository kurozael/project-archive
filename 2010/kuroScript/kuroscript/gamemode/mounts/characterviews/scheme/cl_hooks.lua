--[[
Name: "cl_hooks.lua".
Product: "kuroScript".
--]]

local MOUNT = MOUNT;

-- Called when the character selection background should be drawn.
function MOUNT:ShouldDrawCharacterSelectionBackground()
	if (self.characterView) then return false; end;
end;

-- Called when the cursor enters a character panel.
function MOUNT:OnCursorEnterCharacterPanel(panel, character)
	if (self.characterName and self.characterName == character.name) then
		kuroScript.frame:DestroyTimer("Default Character View");
		
		-- Return to break the function.
		return;
	elseif (self.characterViews) then
		if ( self.characterViews[character.class] ) then
			kuroScript.frame:CreateTimer("Default Character View", FrameTime() * 10, 1, function()
				local data = self.characterViews[character.class];
				
				-- Set some information.
				self.characterView = data[ math.random(1, #data) ];
				self.characterName = character.name;
			end);
		end;
	end;
end;

-- Called when the cursor exits a character panel.
function MOUNT:OnCursorExitCharacterPanel(panel, character)
	if (self.characterViews) then
		if ( self.characterViews["none"] ) then
			kuroScript.frame:CreateTimer("Default Character View", FrameTime() * 10, 1, function()
				local data = self.characterViews["none"];
				
				-- Set some information.
				self.characterView = data[ math.random(1, #data) ];
				self.characterName = nil;
			end);
		end;
	end;
end;

-- Called when the view should be calculated.
function MOUNT:CalcView(player, origin, angles, fov)
	if ( kuroScript.frame:IsChoosingCharacter() ) then
		if (self.characterView and !ValidEntity( g_LocalPlayer:GetActiveWeapon() ) ) then
			return {origin = self.characterView.position, angles = self.characterView.angles, fov = fov};
		end;
	end;
end;