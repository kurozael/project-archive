--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

CloudScript:HookDataStream("SurfaceTexts", function(data)
	CloudScript.plugin:Get("Surface Texts").surfaceTexts = data;
end);

CloudScript:HookDataStream("SurfaceTextAdd", function(data)
	local PLUGIN = CloudScript.plugin:Get("Surface Texts");
	
	if (PLUGIN) then
		PLUGIN.surfaceTexts[#PLUGIN.surfaceTexts + 1] = data;
	end;
end);

CloudScript:HookDataStream("SurfaceTextRemove", function(data)
	local PLUGIN = CloudScript.plugin:Get("Surface Texts");
	
	for k, v in pairs(PLUGIN.surfaceTexts) do
		if (v.position == data) then
			PLUGIN.surfaceTexts[k] = nil;
		end;
	end;
end);