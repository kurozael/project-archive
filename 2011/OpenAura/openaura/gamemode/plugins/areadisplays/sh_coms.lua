--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PLUGIN = PLUGIN;

-- Called when the command has been run.
COMMAND = openAura.command:New();
COMMAND.tip = "Add an area.";
COMMAND.text = "<string Name> [number Scale] [bool Expires]";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "s";
COMMAND.arguments = 1;
COMMAND.optionalArguments = 2;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local areaPointData = player.areaPointData;
	local trace = player:GetEyeTraceNoCursor();
	local name = arguments[1];
	
	if (!areaPointData or areaPointData.name != name) then
		player.areaPointData = {
			name = name,
			scale = tonumber( arguments[2] ),
			minimum = trace.HitPos
		};
		
		if ( openAura:ToBool( arguments[3] ) ) then
			player.areaPointData.expires = true;
		end;
		
		openAura.player:Notify(player, "You have added the minimum point, now add the maximum point.");
	elseif (!areaPointData.maximum) then
		areaPointData.maximum = trace.HitPos;
		
		openAura.player:Notify(player, "You have added the minimum point, now add the text point.");
	elseif (!areaPointData.position) then
		local data = {
			name = areaPointData.name,
			scale = areaPointData.scale,
			angles = trace.HitNormal:Angle(),
			expires = areaPointData.expires,
			minimum = areaPointData.minimum,
			maximum = areaPointData.maximum,
			position = trace.HitPos + (trace.HitNormal * 1.25)
		};
		
		data.angles:RotateAroundAxis(data.angles:Forward(), 90);
		data.angles:RotateAroundAxis(data.angles:Right(), 270);
		
		openAura:StartDataStream( nil, "AreaAdd", data );
		
		PLUGIN.areaDisplays[#PLUGIN.areaDisplays + 1] = data;
		PLUGIN:SaveAreaDisplays();
		
		openAura.player:Notify(player, "You have added the '"..areaPointData.name.."' area display.");
		
		player.areaPointData = nil;
	end;
end;

openAura.command:Register(COMMAND, "AreaAdd");

COMMAND = openAura.command:New();
COMMAND.tip = "Remove an area.";
COMMAND.text = "<string Name>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "s";
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local position = player:GetEyeTraceNoCursor().HitPos;
	local removed = 0;
	local name = string.lower( arguments[1] );
	
	for k, v in pairs(PLUGIN.areaDisplays) do
		if (string.lower(v.name) == name) then
			if (v.minimum:Distance(position) <= 256
			or v.maximum:Distance(position) <= 256
			or v.position:Distance(position) <= 256) then
				openAura:StartDataStream( nil, "AreaRemove", {
					name = v.name,
					minimum = v.minimum,
					maximum = v.maximum
				} );
				
				PLUGIN.areaDisplays[k] = nil;
				
				removed = removed + 1;
			end;
		end;
	end;
	
	if (removed > 0) then
		if (removed == 1) then
			openAura.player:Notify(player, "You have removed "..removed.." area display.");
		else
			openAura.player:Notify(player, "You have removed "..removed.." area displays.");
		end;
	else
		openAura.player:Notify(player, "There were no area displays near this position.");
	end;
	
	PLUGIN:SaveAreaDisplays();
end;

openAura.command:Register(COMMAND, "AreaRemove");