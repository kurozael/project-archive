local oldRCC = RunConsoleCommand;

function RunConsoleCommand(...)
	local arg = {...};
	
	if (arg[1] == "changelevel") then
		return;
	end;
	
	return oldRCC(...);
end;