--[[ 
	© CloudSixteen.com
	http://crowlite.com/license
--]]

--[[ Localized Dependencies ]]--
local Crow = Crow;
local CrowNest = Crow.nest;
local CrowPackage = CrowNest:GetLibrary("package");

function Crow:DrawDeathNotice(x, y)
	if (!CrowPackage:CallAll("PreDrawDeathNotice", x, y)) then
		self.BaseClass:DrawDeathNotice(x, y);

		CrowPackage:CallAll("PostDrawDeathNotice", x, y);
	end;
end;

function Crow:HUDDrawTargetID()
	if (!CrowPackage:CallAll("PreHUDDrawTargetID")) then
		self.BaseClass:HUDDrawTargetID();

		CrowPackage:CallAll("PostHUDDrawTargetID");
	end;
end;

function Crow:ScoreboardShow()
	if (!CrowPackage:CallAll("PreScoreboardShow")) then
		self.BaseClass:ScoreboardShow();

		CrowPackage:CallAll("PostScoreboardShow");
	end;
end;

function Crow:ScoreboardHide()
	if (!CrowPackage:CallAll("PreScoreboardHide")) then
		self.BaseClass:ScoreboardHide();

		CrowPackage:CallAll("PostScoreboardHide");
	end;
end;

function Crow:HUDDrawScoreBoard()
	if (!CrowPackage:CallAll("PreHUDDrawScoreBoard")) then
		self.BaseClass:HUDDrawScoreBoard();

		CrowPackage:CallAll("PostHUDDrawScoreBoard");
	end;
end;