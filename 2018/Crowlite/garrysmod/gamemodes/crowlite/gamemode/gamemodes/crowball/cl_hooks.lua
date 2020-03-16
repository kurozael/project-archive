--[[ 
	© CloudSixteen.com
	http://crowlite.com/license
--]]

--[[ Localized Dependencies ]]--
local Crow = Crow;
local CrowNest = Crow.nest;
local CrowPackage = CrowNest:GetLibrary("package");

surface.CreateFont("CrowBall3DLarge", 
{
	font = "Alte DIN 1451 Mittelschrift",
	size = 95,
	weight = 800,
	antialiase	= true,
	additive 	= false
});

surface.CreateFont("CrowBall3DNormal", 
{
	font = "Alte DIN 1451 Mittelschrift",
	size = 30,
	weight = 800,
	antialiase	= true,
	additive 	= false
});

surface.CreateFont("CrowBallHUDNormal", 
{
	font = "Alte DIN 1451 Mittelschrift",
	size = 50,
	weight = 800,
	antialiase	= true,
	additive 	= false,
	outline = true
});

surface.CreateFont("CrowBallHUDSmall", 
{
	font = "Alte DIN 1451 Mittelschrift",
	size = 25,
	weight = 800,
	antialiase	= true,
	additive 	= false,
	outline = true
});

surface.CreateFont("CrowBallHUDTiny", 
{
	font = "Alte DIN 1451 Mittelschrift",
	size = 16,
	weight = 900,
	antialiase	= true,
	additive 	= false,
	outline = true
});

jsonstream.Receive("CrowBallImmunityPing", function(data)
	LocalPlayer().immuneTime = CurTime() + data[1];
end);

jsonstream.Receive("CrowBallRoundWinner", function(data)
	CrowBall.winner = data[1] or nil;

	if (CrowBall.winner == LocalPlayer():Team()) then
		CrowBall:AddInfoToFeed("Round Won", 100);
	end;
end);

jsonstream.Receive("PostCrowBallKillEffects", function(data)
	data.ball = Entity(data.ball);
	data.entity = Entity(data.entity);
	data.chainOrigin = Entity(data.chainOrigin);

	CrowBall:AddToFeed(data);
end);

jsonstream.Receive("CrowBallShowTeam", function(data)
	CrowBall:ShowTeamFrame();
end);

jsonstream.Receive("CrowBallImmunityPuntPing", function(data)
	surface.PlaySound("buttons/button16.wav");
end);

local crowballMat = Material("crowlite/crowball/sprites/ball");
local colorRed = Color(180, 30, 30, 255);
local darkRed = Color(140, 10, 10, 255);
local colorBlack = Color(0, 0, 0, 255);
local blurBlack = Color(0, 0, 0, 75);
local blurRed = Color(140, 10, 10, 75);
local blurWhite = Color(200, 200, 200, 75);

local check = {
	CHudAmmo = true,
	CHudCrosshair = true,
	CHudHealth = true,
	CHudGeiger = true,
	CHudPoisonDamageIndicator = true,
	CHudSecondaryAmmo = true,
	CHudSquadStatus = true,
	CHudWeaponSelection = true,
	CHudZoom = true
};

function CrowBall:HUDShouldDraw(HUDType)
	if (check[HUDType]) then
		return false;
	end;
end;

function CrowBall:SpawnMenuOpen()
	return false;
end;

function CrowBall:PreDrawDeathNotice()
--	return true;
end;

function CrowBall:HUDDrawTargetID()
	return true;
end;

CrowBall.comboFeed = CrowBall.comboFeed or {};

local comboTable = {
	{"Kill", 10},
	{"Doublekill Bonus", 20},
	{"Triplekill Bonus", 30},
	{"Quadrakill Bonus", 40},
	{"Pentakill Bonus", 50},
	{"Hexakill Bonus", 60},
	{"Heptakill Bonus", 70},
	{"Octakill Bonus", 80}
};

function CrowBall:AddToFeed(killInfo)
	local suicide = false;

	if (killInfo.entity and killInfo.entity == LocalPlayer()) then
		suicide = true;
	end;

	if (!suicide) then
		if (killInfo.combo > 1) then
			table.insert(CrowBall.comboFeed, 1, {
				text = comboTable[1][1],
				points = comboTable[1][2],
				time = CurTime()
			});
		end;

		local combo = comboTable[killInfo.combo] or comboTable[#comboTable];

		table.insert(CrowBall.comboFeed, 1, {
			text = combo[1],
			points = combo[2],
			time = CurTime()
		});
	end;
end;

function CrowBall:AddInfoToFeed(text, points)
	table.insert(CrowBall.comboFeed, 1, {
		text = text,
		points = points,
		time = CurTime()
	});
end;

local colorWhite = Color(255, 255, 255, 255);
local immunityMat = Material("crowlite/crowball/immunity.png");

function CrowBall:PostDrawTranslucentRenderables()
	local client = LocalPlayer();

	for k, v in pairs(_player.GetAll()) do
		if (v != client and v:Health() > 0 and v:GetMoveType() != MOVETYPE_OBSERVER) then
			local angle = client:EyeAngles();

			angle:RotateAroundAxis(angle:Forward(), 90);
			angle:RotateAroundAxis(angle:Right(), 90);

			cam.Start3D();
				cam.Start3D2D(v:GetPos() + Vector(0, 0, 80), angle, 0.2);
					local kills = v:Frags();
					local textX = 80;
					local oX, oY;

					if (kills != 0) then
						oX, oY = draw.SimpleText(kills, "CrowBall3DLarge", 70, -15, colorWhite, TEXT_ALIGN_LEFT);
					end;
					
					if (oX) then
						textX = textX + oX;
					end;
	
					draw.SimpleText(v:Name(), "CrowBall3DNormal", textX, 0, colorWhite);
					draw.SimpleText("Example Title", "CrowBall3DNormal", textX, 33, colorWhite);

					CrowBall:DrawAvatar(v);

					if (v:GetCollisionGroup() == COLLISION_GROUP_WORLD) then
						surface.SetDrawColor(255, 255, 255, 255);
						surface.SetMaterial(immunityMat);
						surface.DrawTexturedRect(0, 0, 64, 64);
					end;
					
				cam.End3D2D();
			cam.End3D();
		end;
	end;
end;

function CrowBall:CreateAvatar(player, x, y, size)
	player.avatar = vgui.Create("AvatarImage");
	player.avatar:SetPlayer(player, size or 64);
	player.avatar:SetSize(size or 64, size or 64);
	player.avatar:SetPos(x or 0, y or 0);
end;

function CrowBall:DrawAvatar(player, x, y, size)
	if (!size) then size = 64; end;
	if (!x) then x = 0; end;
	if (!y) then y = 0; end;

	local borderSize = size * 1.3125;
	local borderInfo = {
		borderSize = borderSize,
		backColor = colorWhite,
		foreColor = colorWhite,
		backMat = "",
		foreMat = "",
		size = size
	};

	CrowPackage:CallAll("GetAvatarBorderInfo", v, borderInfo);

	local diff = borderSize - size;

	if (borderInfo and borderInfo.backMat != "") then
		surface.SetDrawColor(borderInfo.backColor);
		surface.SetMaterial(borderInfo.backMat);
		surface.DrawTexturedRect(x - diff * 0.5, y - diff * 0.5, borderSize, borderSize);
	elseif (borderInfo) then
		draw.RoundedBox(6, x - diff * 0.5, y - diff * 0.5, borderSize, borderSize, team.GetColor(player:Team()));
	end;

	if (!player.avatar) then
		self:CreateAvatar(player, x, y);
	else
		player.avatar:SetPaintedManually(false);
			render.PushFilterMin(TEXFILTER.ANISOTROPIC);
				render.PushFilterMag(TEXFILTER.ANISOTROPIC);
					player.avatar:PaintManual();
				render.PopFilterMag();
			render.PopFilterMin();
		player.avatar:SetPaintedManually(true);
	end;

	if (borderInfo and borderInfo.foreMat != "") then
		surface.SetDrawColor(borderInfo.foreColor);
		surface.SetMaterial(borderInfo.foreMat);
		surface.DrawTexturedRect(x - diff * 0.5, y - diff * 0.5, borderSize, borderSize);
	end;
end;

local borderMat = Material("crowlite/testborder.png");

function CrowBall:GetAvatarBorderInfo(player, borderInfo)
--	borderInfo.foreMat = borderMat;
end;

if (LocalPlayer().avatar) then
	LocalPlayer().avatar:Remove();
	LocalPlayer().avatar = nil;
end;

local blurMat = Material("pp/blurscreen");

function CrowBall:DrawBlurRect(x, y, w, h, color, blurAmount, outlineColor)
	local scrW, scrH = ScrW(), ScrH();

	surface.SetDrawColor(255, 255, 255, 255);
	surface.SetMaterial(blurMat);

	for i = 1, blurAmount or 4 do
		blurMat:SetFloat("$blur", (i / 3) * (5));
		blurMat:Recompute();

		render.UpdateScreenEffectTexture();

		render.SetScissorRect(x, y, x + w, y + h, true);
			surface.DrawTexturedRect(0, 0, scrW, scrH);
		render.SetScissorRect(0, 0, 0, 0, false);
	end;
   
   draw.RoundedBox(0, x, y, w, h, color);

   surface.SetDrawColor(outlineColor or colorBlack);
   surface.DrawOutlinedRect(x, y, w, h);
end;

function CrowBall:DrawComboHUD(x, y)
	local comboTime = self._COMBO_TIME or 3;

	for k, v in ipairs(self.comboFeed) do
		if (v.time + comboTime > CurTime()) then
			y = self:DrawComboLine(x, y, v.text, v.time, v.points);
		end;
	end;
end;

function CrowBall:DrawComboLine(x, y, text, time, points)
	local color = table.Copy(colorWhite);
	local comboTime = self._COMBO_TIME or 3;
	local fadeout = (time + comboTime) - CurTime()	
	local alpha = math.Clamp(fadeout * 255, 0, 255);
	local oX, oY = 0, 0;

	color.a = alpha;

	oX, oY = draw.SimpleText(text.." +"..points, "CrowBallHUDSmall", x, y, color, TEXT_ALIGN_CENTER);

	return y + oY;
end;

function CrowBall:HUDPaint()
	local scrW = ScrW();
	local scrH = ScrH();
	local client = LocalPlayer();
	local curTime = CurTime();
	local HUDColor = colorRed;
	local LeftStatColor = blurBlack;
	local RightStatColor = blurBlack;
	local isTeamBased = CrowRounds:GetTeamBased();
	local clientTeam = client:Team();
	local roundFont = "CrowBallHUDSmall";
	local roundName = CrowRounds:GetName();
	local roundType = CrowRounds:GetCurrentRound();
	local isRound = (roundName == "Round");
	local isSpectator = (client:Team() == TEAM_SPECTATOR);

	if (isTeamBased) then
		HUDColor = team.GetColor(client:Team());
	end;

	if (isSpectator) then
		clientTeam = self._TEAM_BLUE;
	end;

	CrowBall:DrawComboHUD(scrW * 0.7, scrH * 0.65);

	draw.SimpleText("CrowBall "..self.build.." v"..self:GetVersion().string, "CrowBallHUDSmall", 10, 10, colorWhite, TEXT_ALIGN_LEFT);

	if (client.immuneTime) then
		if (client.immuneTime >= curTime) then
			local immunityTime = math.Round(client.immuneTime - curTime);

			if (immunityTime <= 0) then	
				immunityTime = 0;
			end;

			local size = 64;

			surface.SetDrawColor(255, 255, 255, 255);
			surface.SetMaterial(immunityMat);
			surface.DrawTexturedRect(scrW / 2 - size / 2, scrH / 2 - size / 2, size, size);

			draw.SimpleText(immunityTime, "CrowBallHUDNormal", scrW / 2, scrH * 0.5, colorWhite, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER);

			draw.SimpleText("You are immune!", "CrowBallHUDSmall", scrW / 2, scrH * 0.55, colorWhite, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER);
		else
			client.immuneTime = nil;
		end;	
	end;

	local width = 250;

	CrowBall:DrawBlurRect(scrW / 2 - width / 2, scrH * 0.01, width, 90, Color(HUDColor.r, HUDColor.g, HUDColor.b, 75), 6);

	local timerFont = "CrowBallHUDNormal";

	surface.SetFont(timerFont);

	local timeLeft = string.ToMinutesSeconds(tostring(CrowRounds:GetTimeLeft()));
	local timerW, timerH = surface.GetTextSize(timeLeft);
	local textY = scrH * 0.012;

	if (roundName and roundName != "N/A") then
		surface.SetFont(roundFont);

		if (isRound) then
			roundName = CrowRounds:GetRoundName();

			if (!roundName) then
				roundName = "CrowBall";
			end;
		elseif (roundName == "Post-Round") then
			local winnerText = "The round ended in a tie!";
			local winnerColor = colorWhite;

			if (self.winner and self.winner != "tied") then
				winnerColor = team.GetColor(self.winner);
				winnerText = team.GetName(self.winner).." wins the round!";
			end;

			draw.SimpleText(winnerText, timerFont, scrW / 2, scrH * 0.1, winnerColor, TEXT_ALIGN_CENTER);
		elseif (roundName == "Warmup") then
			local oX = 0; 
			local oY = 0;
			local y = scrH * 0.1;

			if (roundType) then
				if (roundType.name) then
					oX, oY = draw.SimpleText(roundType.name, timerFont, scrW / 2, y, winnerColor, TEXT_ALIGN_CENTER);

					y = y + oY;	
				end;

				if (roundType.desc) then
					oX, oY = draw.SimpleText(roundType.desc, roundFont, scrW / 2, y, winnerColor, TEXT_ALIGN_CENTER);

					y = y + oY;	
				end;			
			end;

			if (clientTeam and !isSpectator) then
				oX, oY = draw.SimpleText("You are on the "..team.GetName(clientTeam), timerFont, scrW / 2, y, HUDColor, TEXT_ALIGN_CENTER);
			elseif (isSpectator) then
				oX, oY = draw.SimpleText("You are spectating!", timerFont, scrW / 2, y, HUDColor, TEXT_ALIGN_CENTER);
			end;
		end;

		draw.SimpleText(roundName, roundFont, scrW / 2, textY + timerH, colorWhite, TEXT_ALIGN_CENTER);
	else
		local waitingFor = self._MINIMUM_PLAYERS - #_player.GetAll();

		roundName = "Waiting for "..waitingFor.." player";

		if (waitingFor != 1) then
			roundName = roundName.."s...";
		else
			roundName = roundName.."...";
		end;
	end;

	draw.SimpleText(timeLeft, timerFont, scrW / 2 - timerW / 2, textY, colorWhite);

	local statWidth = 80;
	local leftX = scrW / 2 - width / 2 - statWidth / 2;
	local titleY = scrH * 0.015;
	local textY = scrH * 0.025;
	local rightX = scrW / 2 + width / 2 + statWidth / 2;
	local enemyTeam = self._TEAM_BLUE;
	local titleFont = "CrowBallHUDTiny";

	if (clientTeam == enemyTeam) then
		enemyTeam = self._TEAM_RED;
	end;

	if (isRound) then
		self:DrawBlurRect(scrW / 2 - width / 2 - statWidth, scrH * 0.01, statWidth, 65, Color(LeftStatColor.r, LeftStatColor.g, LeftStatColor.b, 100), 6);
		self:DrawBlurRect(scrW / 2 + width / 2, scrH * 0.01, statWidth, 65, Color(RightStatColor.r, RightStatColor.g, RightStatColor.b, 100), 6);

		if (!CrowPackage:CallAll("DrawLeftStatBox", client, enemyTeam, clientTeam, leftX, titleY, textY)) then
			draw.SimpleText(team.TotalFrags(clientTeam), timerFont, leftX, textY, colorWhite, TEXT_ALIGN_CENTER);
			draw.SimpleText(string.gsub(team.GetName(clientTeam), "Team", "Kills"), titleFont, leftX, titleY, colorWhite, TEXT_ALIGN_CENTER);
		end;

		if (!CrowPackage:CallAll("DrawRightStatBox", client, enemyTeam, clientTeam, rightX, titleY, textY)) then
			draw.SimpleText(team.TotalFrags(enemyTeam), timerFont, rightX, textY, colorWhite, TEXT_ALIGN_CENTER);
			draw.SimpleText(string.gsub(team.GetName(enemyTeam), "Team", "Kills"), titleFont, rightX, titleY, colorWhite, TEXT_ALIGN_CENTER);
		end;
	end;

	if (self._DEBUG) then
		for k, v in pairs(ents.FindByClass("dball_dodgeball")) do
			local toScreen = v:GetPos():ToScreen();
			local crowOwner = v:GetBallOwner();
			local bounces = v:GetBounces();
			local font = "CenterPrintText";	
			local x, y = 0, 0;

			if (v:GetBallColor() == Vector(0, 1, 0)) then
				crowOwner = "N/A";
			end;

			local oX, oY = draw.SimpleText("Owner: "..tostring(crowOwner), font, toScreen.x, toScreen.y + y, colorWhite);
	
			y = y + oY;

			oX, oY = draw.SimpleText("Bounces: "..tostring(bounces), font, toScreen.x, toScreen.y + y, colorWhite);

			y = y + oY;

			oX, oY = draw.SimpleText("Chain Number: "..tostring(v:GetChainNumber()), font, toScreen.x, toScreen.y + y, colorWhite);

			y = y + oY;

			oX, oY = draw.SimpleText("Chain Origin: "..tostring(v:GetChainOrigin()), font, toScreen.x, toScreen.y + y, colorWhite);			
		end;
	end;
end;

function CrowBall:ChangeTeam(id)
	net.Start("CrowBallChangeTeam");
	net.WriteInt(id, 32);
	net.SendToServer();
end;

--[[---------------------------------------------------------
   Name: gamemode:ShowTeam()
   Desc:
-----------------------------------------------------------]]
function CrowBall:ShowTeamFrame()
	if (IsValid(self.TeamSelectFrame)) then return; end;
	
	-- Simple team selection box
	self.TeamSelectFrame = vgui.Create("DFrame");
	self.TeamSelectFrame:SetTitle("Pick Team");
	
	local AllTeams = team.GetAllTeams();
	local y = 30;

	for ID, TeamInfo in pairs (AllTeams) do
		if (ID != TEAM_CONNECTING && ID != TEAM_UNASSIGNED) then
			local Team = vgui.Create("DButton", self.TeamSelectFrame);

			function Team.DoClick() 
			--	jsonstream.Send("CrowBallSwitchTeam", {ID});
				self:ChangeTeam(ID);

				self:HideTeamFrame();
			end;

			Team:SetPos(10, y);
			Team:SetSize(130, 20);
			Team:SetText(TeamInfo.Name);
			
			if (IsValid(LocalPlayer()) and LocalPlayer():Team() == ID) then
				Team:SetDisabled(true);
			end;
			
			y = y + 30;
		end;
	end;
	
	self.TeamSelectFrame:SetSize(150, y);
	self.TeamSelectFrame:Center();
	self.TeamSelectFrame:MakePopup();
	self.TeamSelectFrame:SetKeyboardInputEnabled(false);
end;

function CrowBall:HideTeamFrame()
	if (IsValid(self.TeamSelectFrame)) then
		self.TeamSelectFrame:Remove();
		self.TeamSelectFrame = nil;
	end;
end;
