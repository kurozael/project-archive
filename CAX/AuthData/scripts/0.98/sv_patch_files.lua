if (not CW_RESTART_LEVEL) then
	local NEW_INIT_CODE = [[
	local caxVersion = file.Read("cax.txt", "DATA");
	local requireName = "cloudauthx";

	if (caxVersion != "" and tonumber(caxVersion)) then
		local fileName = caxVersion;
		
		if (system.IsLinux()) then
			fileName = "gmsv_cloudauthx_"..fileName.."_linux.dll";
		else
			fileName = "gmsv_cloudauthx_"..fileName.."_win32.dll";
		end;
		
		if (file.Exists("lua/bin/"..fileName, "GAME")) then
			requireName = "cloudauthx_"..caxVersion;
		end;
	end;

	require(requireName);]];

	local patchTable = {};

	function AddPatch(fileName, search, replace)
		fileName = "gamemodes/clockwork/"..fileName;
		
		patchTable[fileName] = patchTable[fileName] or {};
		
		table.insert(patchTable[fileName], {search = search, replace = replace});
	end;

	THINK_NAME = "Think";

	if (Clockwork.KernelVersion == "0.925") then
		AddPatch("framework/libraries/sv_player.lua", "ErrorNoHalt(\"[Clockwork:PlayerSharedVars] ", "--ErrorNoHalt(\"");
	end;

	AddPatch("framework/derma/cl_menu.lua", "return (a.iconData and not b.iconData) or (a.text < b.text);", "return (a.text < b.text);");
	AddPatch("framework/cl_kernel.lua", "local width = 768;", "local width = 512; --Patched");
	AddPatch("framework/sv_kernel.lua", "hook.ClockworkCall = hook.Call;", "hook.ClockworkCall = hook.ClockworkCall or hook.Call;");
	AddPatch("framework/sv_kernel.lua", "FrameTime() * 64", "FrameTime()");
	AddPatch("framework/sv_kernel.lua", "FrameTime() * 8", "FrameTime()");
	AddPatch("framework/sv_kernel.lua", [[if (name == "Think") then Clockwork:ExplicitThink(); end;]], "");
	AddPatch("framework/sv_kernel.lua", [[if (value == nil) then]], [[if (value == nil or name == THINK_NAME) then]]);
	AddPatch("framework/sv_kernel.lua", "function Clockwork:ExplicitThink()", "function Clockwork:Think()");
	AddPatch("framework/libraries/sh_plugin.lua", "Schema = self:New();", "PLUGIN = self:New(); Schema = PLUGIN;");
	AddPatch("gamemode/init.lua", [[require("cloudauthx");]], NEW_INIT_CODE);
	AddPatch("gamemode/init.lua", [["lua/bin"..fileName]], [["lua/bin/"..fileName]]);

	for k, v in pairs(patchTable) do
		local fileContent = fileio.Read(k);
		local fileChanged = false;
		
		for k2, v2 in ipairs(v) do
			if (string.find(fileContent, v2.search, 0, true)) then
				fileContent = string.Replace(fileContent, v2.search, v2.replace);
				fileChanged = true;
			end;
		end;
		
		if (fileChanged) then
			fileio.Write(k, fileContent);
			
			AddRestartMessage("Patching Files");
		end;
	end;

	if (file.Exists("gamemodes/clockwork/plugins/charactercustomization", "GAME")) then
		fileio.Delete("gamemodes/clockwork/plugins/charactercustomization");
		
		AddRestartMessage("Deleting Character Customization");
	end;
	
	if (file.Exists("gamemodes/clockwork/plugins/handsfix", "GAME")) then
		fileio.Delete("gamemodes/clockwork/plugins/handsfix");
		
		AddRestartMessage("Deleting Handsfix");
	end;
else
	ErrorNoHalt("[CloudAuthX] Already restarting level, no need to try and patch files!");
end;