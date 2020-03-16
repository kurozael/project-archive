--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PLUGIN = PLUGIN;

-- Called when the command has been run.
COMMAND = openAura.command:New();
COMMAND.tip = "Add a dynamic advert.";
COMMAND.text = "<string URL> <number Width> < number Height> [number Scale]";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "a";
COMMAND.arguments = 3;
COMMAND.optionalArguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local trace = player:GetEyeTraceNoCursor();
	local scale = tonumber( arguments[4] );
	local width = tonumber( arguments[2] ) or 256;
	local height = tonumber( arguments[3] ) or 256;
	
	if (scale) then
		scale = scale * 0.25;
	end;
	
	local data = {
		url = arguments[1],
		scale = scale,
		width = width,
		height = height,
		angles = trace.HitNormal:Angle(),
		position = trace.HitPos + (trace.HitNormal * 1.25)
	};
	
	data.angles:RotateAroundAxis(data.angles:Forward(), 90);
	data.angles:RotateAroundAxis(data.angles:Right(), 270);
	
	openAura:StartDataStream( nil, "DynamicAdvertAdd", data );
	
	PLUGIN.dynamicAdverts[#PLUGIN.dynamicAdverts + 1] = data;
	PLUGIN:SaveDynamicAdverts();
	
	openAura.player:Notify(player, "You have added a dynamic advert.");
end;

openAura.command:Register(COMMAND, "AdvertAdd");

COMMAND = openAura.command:New();
COMMAND.tip = "Remove a dynamic advert.";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "a";

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local position = player:GetEyeTraceNoCursor().HitPos;
	local removed = 0;
	
	for k, v in pairs(PLUGIN.dynamicAdverts) do
		if (v.position:Distance(position) <= 256) then
			openAura:StartDataStream( nil, "DynamicAdvertRemove", v.position );
			
			PLUGIN.dynamicAdverts[k] = nil;
			
			removed = removed + 1;
		end;
	end;
	
	if (removed > 0) then
		if (removed == 1) then
			openAura.player:Notify(player, "You have removed "..removed.." dynamic advert.");
		else
			openAura.player:Notify(player, "You have removed "..removed.." dynamic adverts.");
		end;
	else
		openAura.player:Notify(player, "There were no dynamic adverts near this position.");
	end;
	
	PLUGIN:SaveDynamicAdverts();
end;

openAura.command:Register(COMMAND, "AdvertRemove");