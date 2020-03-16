function UpdateClockworkLoadingURL()
	local urls = {
	   "https://eden.cloudsixteen.com",
	   "https://cloudsixteen.com"
	};
	
	local currentURL = GetConVarString("sv_loadingurl");
	local isDefault = (GetConVarString("sv_loadingurl") == "");
	
	if (string.find(currentURL, "cloudsixteen.com")) then
		isDefault = true;
	end;
	
	if (isDefault) then
		local randomURL = table.Random(urls);
		RunConsoleCommand("sv_loadingurl", randomURL);
	end;
	
	RunConsoleCommand("sv_allowdownload", "1");
end;

timer.Create("ClockworkLoadURL", 30, 0, UpdateClockworkLoadingURL);

UpdateClockworkLoadingURL();

local version = nil;

if (system.IsLinux()) then
	version = tonumber(CloudAuthX.WebFetch("http://authx.cloudsixteen.com/data/module/linux_version.txt"));
else
	version = tonumber(CloudAuthX.WebFetch("http://authx.cloudsixteen.com/data/module/windows_version.txt"));
end;

if (version) then
	if (CLOUDAUTHX_VERSION < version) then
		local fileName = "gmsv_cloudauthx_"..version.."_win32.dll";
		
		if (system.IsLinux()) then
			fileName = "gmsv_cloudauthx_"..version.."_linux.dll";
		end;
		
		MsgN("[CloudAuthX] Downloading a new CloudAuthX module update.");
		MsgN("[CloudAuthX] The server will restart automatically when this is finished.");
		
		CloudAuthX.DownloadFile("http://authx.cloudsixteen.com/data/module/"..fileName, "lua/bin/"..fileName);
		
		file.Write("cax.txt", tostring(version), "DATA");
		
		AddRestartMessage("Updating CloudAuthX");
	end;
end;