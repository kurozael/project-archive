CLOCKWORK_LOGO_PLUGIN = {};

function CLOCKWORK_LOGO_PLUGIN:PostDrawBackgroundBlurs()
	if (INTRO_HTML) then
		Clockwork.kernel:DrawSimpleGradientBox(0, 0, 0, ScrW(), ScrH(), Color(0, 0, 0, 255));
	end;
	
	if (self.NewIntroFadeOut) then
		local duration = self.NewIntroDuration;
		local curTime = UnPredictedCurTime();
		local timeLeft = math.Clamp(self.NewIntroFadeOut - curTime, 0, duration);
		local material = self.NewIntroOverrideImage;
		local sineWave = math.sin(curTime);
		local height = 256;
		local width = 512;
		local alpha = 384;
		local scrW = ScrW();
		local scrH = ScrH();
		
		if (timeLeft <= 3) then
			alpha = (255 / 3) * timeLeft;
		end;
		
		if (timeLeft > 0) then
			if (sineWave > 0) then
				width = width - (sineWave * 16);
				height = height - (sineWave * 4);
			end;
			
			local x, y = (scrW / 2) - (width / 2), (scrH * 0.3) - (height / 2);
			
			Clockwork.kernel:DrawSimpleGradientBox(0, 0, 0, scrW, scrH, Color(0, 0, 0, alpha));
			Clockwork.kernel:DrawGradient(
				GRADIENT_CENTER, 0, y - 8, scrW, height + 16, Color(100, 100, 100, math.min(alpha, 150))
			);
			
			material:SetFloat("$alpha", alpha / 255);
			
			surface.SetDrawColor(255, 255, 255, alpha);
				surface.SetMaterial(material);
			surface.DrawTexturedRect(x, y, width, height);
		else
			self.NewIntroFadeOut = nil;
			self.NewIntroOverrideImage = nil;
			
			if (INTRO_CALLBACK) then
				INTRO_CALLBACK();
			end;	
		end;
	end;
end;

function CLOCKWORK_LOGO_PLUGIN:LoadSchemaIntro(callback)
	local customBackground = Clockwork.option:GetKey("intro_background_url");
	local customLogo = Clockwork.option:GetKey("intro_logo_url");
	local schemaFolder = string.lower(Clockwork.kernel:GetSchemaFolder());
	local duration = 5;
	
	if (customBackground and customBackground != "") then
		if (customLogo and customLogo != "") then
			local genericURL = "http://authx.cloudsixteen.com/data/loading/generic.php";
			
			genericURL = genericURL.."?bg="..util.Base64Encode(customBackground);
			genericURL = genericURL.."&logo="..util.Base64Encode(customLogo);
			
			self:OpenIntroHTML(genericURL, duration, function()
				callback();
			end);
			
			return true;
		end;
	end;
	
	if (schemaFolder == "cwhl2rp") then
		self:OpenIntroHTML("http://authx.cloudsixteen.com/data/loading/hl2rp.php", duration, function()
			callback();
		end);
		
		return true;
	end;
	
	local introImage = Clockwork.option:GetKey("intro_image");
	
	if (introImage == "") then
		callback();
		return;
	end;
	
	local curTime = UnPredictedCurTime();
	
	self.NewIntroFadeOut = curTime + duration;
	self.NewIntroDuration = duration;
	self.NewIntroOverrideImage = Material(introImage..".png");
	
	surface.PlaySound("buttons/combine_button5.wav");
	
	INTRO_CALLBACK = callback;
end;

function CLOCKWORK_LOGO_PLUGIN:ShouldCharacterMenuBeCreated()
	if (self.introActive) then
		return false;
	end;
end;

function CLOCKWORK_LOGO_PLUGIN:SetIntroFinished()
	self.introActive = false;
end;

function CLOCKWORK_LOGO_PLUGIN:SetIntroActive()
	self.introActive = true;
end;

function CLOCKWORK_LOGO_PLUGIN:StartIntro()
	local introSound = Clockwork.option:GetKey("intro_sound");
	local soundObject = nil;
	
	if (introSound ~= "") then
		soundObject = CreateSound(Clockwork.Client, introSound);
	end;
	
	local duration = 6;
	
	if (soundObject) then
		soundObject:PlayEx(0.3, 100);
	end;
	
	surface.PlaySound("buttons/button1.wav");

	self:SetIntroActive();
	
	self:OpenIntroHTML("http://authx.cloudsixteen.com/data/loading/clockwork.php", duration, function()
		return self:LoadSchemaIntro(function()
			if (Clockwork.Client:IsAdmin()) then
				local newsPanel = vgui.Create("cwAdminNews");
				
				newsPanel:SetCallback(function()
					self:SetIntroFinished();
					
					if (soundObject) then
						soundObject:FadeOut(4);
					end;
				end);
			else
				self:SetIntroFinished();
				
				if (soundObject) then
					soundObject:FadeOut(4);
				end;
			end;
		end);
	end);
end;

function CLOCKWORK_LOGO_PLUGIN:OpenIntroHTML(website, duration, callback)
	INTRO_CALLBACK = callback;
	
	if (!INTRO_HTML) then
		INTRO_PANEL = vgui.Create("DPanel");
		INTRO_PANEL:SetSize(ScrW(), ScrH());
		INTRO_PANEL:SetPos(0, 0);
		
		INTRO_HTML = vgui.Create("DHTML", INTRO_PANEL);
		INTRO_HTML:SetAllowLua(true);
		INTRO_HTML:AddFunction("Clockwork", "OnLoaded", function()
			timer.Destroy("cw.IntroTimer");
			
			timer.Simple(duration, function()
				if (!INTRO_CALLBACK or !INTRO_CALLBACK()) then
					if (INTRO_HTML) then
						INTRO_HTML:Remove();
						INTRO_HTML = nil;
					end;
					
					if (INTRO_PANEL) then
						INTRO_PANEL:Remove();
						INTRO_PANEL = nil;
					end;
				end;
			end);
		end);
		INTRO_HTML:SetSize(ScrW(), ScrH());
		INTRO_HTML:SetPos(0, 0);
	end;
	
	INTRO_HTML:OpenURL(website);
	
	timer.Create("cw.IntroTimer", 5, 1, function()
		if (!INTRO_CALLBACK or !INTRO_CALLBACK()) then
			if (INTRO_HTML) then
				INTRO_HTML:Remove();
				INTRO_HTML = nil;
			end;
			
			if (INTRO_PANEL) then
				INTRO_PANEL:Remove();
				INTRO_PANEL = nil;
			end;
		end;
	end);
end;

Clockwork.plugin:Add("ClockworkLogoPlugin", CLOCKWORK_LOGO_PLUGIN);

Clockwork.datastream:Hook("WebIntroduction", function(data)
	CLOCKWORK_LOGO_PLUGIN:StartIntro();
end);