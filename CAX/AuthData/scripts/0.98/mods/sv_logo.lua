if (not file.Exists("materials/clockwork/logo/002.png", "GAME")) then
	CloudAuthX.DownloadFile("http://cloudsixteen.com/clockwork.png", "materials/clockwork/logo/002.png");
end;

Clockwork.kernel:AddFile("materials/clockwork/logo/002.png");

CLOCKWORK_LOGO_PLUGIN = {};

function CLOCKWORK_LOGO_PLUGIN:PlayerDataLoaded(player)
	Clockwork.datastream:Start(player, "WebIntroduction", true);
	player:SetData("ClockworkIntro", true);
end;

Clockwork.plugin:Add("ClockworkLogoPlugin", CLOCKWORK_LOGO_PLUGIN);