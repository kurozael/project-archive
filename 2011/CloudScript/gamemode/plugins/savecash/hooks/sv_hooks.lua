--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PLUGIN = PLUGIN;

-- Called when CloudScript has loaded all of the entities.
function PLUGIN:CloudScriptInitPostEntity()
	if ( CloudScript.config:Get("cash_enabled"):Get() ) then
		self:LoadCash();
	end;
end;

-- Called just after data should be saved.
function PLUGIN:PostSaveData()
	self:SaveCash();
end;