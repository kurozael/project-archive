--[[
Name: "sh_coms.lua".
Product: "nexus".
--]]

local MOUNT = MOUNT;
local COMMAND;

-- Called when the command has been run.
COMMAND = {};
COMMAND.tip = "Add some text.";
COMMAND.text = "<string Text> [number Scale]";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "a";
COMMAND.arguments = 1;
COMMAND.optionalArguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local trace = player:GetEyeTraceNoCursor();
	local scale = tonumber( arguments[2] );
	
	if (scale) then
		scale = scale * 0.25;
	end;
	
	local data = {
		text = arguments[1],
		scale = scale,
		angles = trace.HitNormal:Angle(),
		position = trace.HitPos + (trace.HitNormal * 1.25)
	};
	
	data.angles:RotateAroundAxis(data.angles:Forward(), 90);
	data.angles:RotateAroundAxis(data.angles:Right(), 270);
	
	NEXUS:StartDataStream( nil, "SurfaceTextAdd", data );
	
	MOUNT.surfaceTexts[#MOUNT.surfaceTexts + 1] = data;
	MOUNT:SaveSurfaceTexts();
	
	nexus.player.Notify(player, "You have added some surface text.");
end;

nexus.command.Register(COMMAND, "TextAdd");

COMMAND = {};
COMMAND.tip = "Remove some text.";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "a";

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local position = player:GetEyeTraceNoCursor().HitPos;
	local removed = 0;
	
	for k, v in pairs(MOUNT.surfaceTexts) do
		if (v.position:Distance(position) <= 256) then
			NEXUS:StartDataStream( nil, "SurfaceTextRemove", v.position );
			
			MOUNT.surfaceTexts[k] = nil;
			
			removed = removed + 1;
		end;
	end;
	
	if (removed > 0) then
		if (removed == 1) then
			nexus.player.Notify(player, "You have removed "..removed.." surface text.");
		else
			nexus.player.Notify(player, "You have removed "..removed.." surface texts.");
		end;
	else
		nexus.player.Notify(player, "There were no surface texts near this position.");
	end;
	
	MOUNT:SaveSurfaceTexts();
end;

nexus.command.Register(COMMAND, "TextRemove");