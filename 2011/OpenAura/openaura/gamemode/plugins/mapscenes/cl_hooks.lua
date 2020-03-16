--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PLUGIN = PLUGIN;

-- Called when the character background should be drawn.
function PLUGIN:ShouldDrawCharacterBackground()
	if (self.mapScene) then
		return false;
	end;
end;

-- Called when the view should be calculated.
function PLUGIN:CalcView(player, origin, angles, fov)
	if (openAura:IsChoosingCharacter() and self.mapScene) then
		return {
			vm_origin = self.mapScene.position + Vector(0, 0, 2048),
			vm_angles = Angle(0, 0, 0),
			origin = self.mapScene.position,
			angles = self.mapScene.angles,
			fov = fov
		};
	end;
end;