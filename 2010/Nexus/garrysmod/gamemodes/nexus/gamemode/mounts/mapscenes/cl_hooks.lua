--[[
Name: "cl_hooks.lua".
Product: "nexus".
--]]

local MOUNT = MOUNT;

-- Called when the character background should be drawn.
function MOUNT:ShouldDrawCharacterBackground()
	if (self.mapScene) then
		return false;
	end;
end;

-- Called when the view should be calculated.
function MOUNT:CalcView(player, origin, angles, fov)
	if (NEXUS:IsChoosingCharacter() and self.mapScene) then
		return {
			vm_origin = self.mapScene.position + Vector(0, 0, 2048),
			vm_angles = Angle(0, 0, 0),
			origin = self.mapScene.position,
			angles = self.mapScene.angles,
			fov = fov
		};
	end;
end;