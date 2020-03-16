local cax_override = nil;
local didGamenameOverride = false;

function SetModuleNameCAX(description)
	function Clockwork:GetGameDescription()
		return description;
	end;
	
	if (GM) then
		function GM:GetGameDescription()
			return description;
		end;
	end;
	
	if (GAMEMODE) then
		function GAMEMODE:GetGameDescription()
			return description;
		end;
	end;
	
	if (not didGamenameOverride) then
		RunConsoleCommand("sv_gamename_override", description);
		didGamenameOverride = true;
	end;
end;

if (cax_override) then
	Clockwork.Name = cax_override;
	
	hook.Add("Think", "cw.GetGameDescription", function()
		SetModuleNameCAX(cax_override);
	end);
	
	SetModuleNameCAX(cax_override);
else
	hook.Add("Think", "cw.GetGameDescription", function()
		SetModuleNameCAX(Clockwork.kernel:GetSchemaGamemodeName());
	end);
	
	SetModuleNameCAX(Clockwork.kernel:GetSchemaGamemodeName());
end;