cax_include("sh_networking");

cax_include("mods/sh_phys_desc");

cax_include("mods/cl_schema_rename");

cax_include("mods/cl_directory");

cax_include("mods/cl_markup_fix");

hook.Add("Think", "ClockworkSplash", function()
	if (Clockwork.ClockworkSplash) then
		if (file.Exists("materials/clockwork/logo/002.png", "GAME")) then
			Clockwork.ClockworkSplash = Material("materials/clockwork/logo/002.png");
		end;
		
		hook.Remove("Think", "ClockworkSplash");
	end;
end);

function Clockwork:ClockworkLoadShared()
	cax_include("lib/sh_plugin");

	cax_include("lib/cl_player");
	
	cax_include("mods/cl_logo");
	
	cax_include("mods/cl_admin_news");
	
	cax_include("mods/cl_cloud_sixteen");
	
	cax_include("mods/cl_chat_classes");
	
	if (Schema and Schema.author == "kurozael") then
		Schema.author = "kurozael (CloudSixteen.com)";
	end;
end;

function extern_CharModelOnMousePressed(panel)
	if (panel.DoClick) then
		panel:DoClick();
	end;
end;

function extern_SetModelAndSequence(panel, model)
	panel:ClockworkSetModel(model);
	
	local entity = panel.Entity;
	
	if (not IsValid(entity)) then
		return;
	end;
	
	local sequence = entity:LookupSequence("idle");
	local menuSequence = Clockwork.animation:GetMenuSequence(model, true);
	local leanBackAnims = {"LineIdle01", "LineIdle02", "LineIdle03"};
	local leanBackAnim = entity:LookupSequence(
		leanBackAnims[math.random(1, #leanBackAnims)]
	);
	
	if (leanBackAnim > 0) then
		sequence = leanBackAnim;
	end;
	
	if (menuSequence) then
		menuSequence = entity:LookupSequence(menuSequence);
		
		if (menuSequence > 0) then
			sequence = menuSequence;
		end;
	end;
	
	if (sequence <= 0) then
		sequence = entity:LookupSequence("idle_unarmed");
	end;
	
	if (sequence <= 0) then
		sequence = entity:LookupSequence("idle1");
	end;
	
	if (sequence <= 0) then
		sequence = entity:LookupSequence("walk_all");
	end;
	
	if (sequence > 0) then
		entity:ResetSequence(sequence);
	end;
end;

function extern_CharModelInit(panel)
	panel:SetCursor("none");
	panel.ClockworkSetModel = panel.SetModel;
	panel.SetModel = extern_SetModelAndSequence;
	
	Clockwork.kernel:CreateMarkupToolTip(panel);
end;

function extern_CharModelLayoutEntity(panel)
	local screenW = ScrW();
	local screenH = ScrH();
	
	local fractionMX = gui.MouseX() / screenW;
	local fractionMY = gui.MouseY() / screenH;
	
	local entity = panel.Entity;
	local x, y = panel:LocalToScreen(panel:GetWide() / 2);
	local fx = x / screenW;
	
	entity:SetPoseParameter("head_pitch", fractionMY * 80 - 30);
	entity:SetPoseParameter("head_yaw", (fractionMX - fx) * 70);
	entity:SetAngles(Angle(0, 45, 0));
	entity:SetIK(false);
	
	panel:RunAnimation();
end;

local cwOldRunConsoleCommand = RunConsoleCommand;

function RunConsoleCommand(...)
	local arguments = {...};
	
	if (arguments[1] == nil) then
		return;
	end;
	
	cwOldRunConsoleCommand(...);
end;