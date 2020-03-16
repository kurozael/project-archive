local UPDATE_COUNT = 1;

for i = 1, CLOUDAUTHX_VERSION - 1 do
	local fileName = "cloudauthx_"..i;
	
	if (system.IsLinux()) then
		fileName = "gmsv_cloudauthx_"..fileName.."_linux.dll";
	else
		fileName = "gmsv_cloudauthx_"..fileName.."_win32.dll";
	end;
	
	fileName = "lua/bin/"..fileName;
	
	if (file.Exists(fileName, "GAME")) then
		fileio.Delete(fileName);
	end;
end;