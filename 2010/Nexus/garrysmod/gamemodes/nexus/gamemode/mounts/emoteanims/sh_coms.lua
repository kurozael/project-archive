--[[
Name: "sh_coms.lua".
Product: "nexus".
--]]

local MOUNT = MOUNT;
local COMMAND = {};

COMMAND = {};
COMMAND.tip = "Put your character into a threatening stance.";
COMMAND.text = "[bool ArmsCrossed]"
COMMAND.flags = CMD_DEFAULT;
COMMAND.optionalArguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local curTime = CurTime();
	
	if (!player.nextStanceOrGesture or curTime >= player.nextStanceOrGesture) then
		player.nextStanceOrGesture = curTime + 2;
		
		local modelClass = nexus.animation.GetModelClass( player:GetModel() );
		local position = player:GetPos();
		
		if (modelClass == "civilProtection") then
			local forcedAnimation = player:GetForcedAnimation();
			local animation = "plazathreat1";
			
			if ( NEXUS:ToBool( arguments[1] ) ) then
				animation = "plazathreat2";
			end;
			
			if ( forcedAnimation and (forcedAnimation.animation == "plazathreat1" or forcedAnimation.animation == "plazathreat2") ) then
				MOUNT:MakePlayerExitStance(player);
			elseif ( !forcedAnimation or !MOUNT.stances[forcedAnimation.animation] ) then
				if ( player:Crouching() ) then
					nexus.player.Notify(player, "You cannot do this while you are crouching!");
				elseif ( player:IsOnGround() or IsValid( player:GetGroundEntity() ) ) then
					player:SetSharedVar( "sh_StancePosition", player:GetPos() );
					player:SetSharedVar( "sh_StanceAngles", player:GetAngles() );
					player:SetSharedVar( "sh_StanceIdle", true );
					player:SetForcedAnimation(animation, 0, nil, function()
						MOUNT:MakePlayerExitStance(player);
					end);
				else
					nexus.player.Notify(player, "You must be standing on the ground!");
				end;
			end;
		else
			nexus.player.Notify(player, "The model that you are using cannot perform this action!");
		end;
	else
		nexus.player.Notify(player, "You cannot do another stance or gesture yet!");
	end;
end;

nexus.command.Register(COMMAND, "AnimThreat");

COMMAND = {};
COMMAND.tip = "Make your character motion to something in a direction.";
COMMAND.text = "<string Left|Right|Behind>";
COMMAND.flags = CMD_DEFAULT;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local curTime = CurTime();
	
	if (!player.nextStanceOrGesture or curTime >= player.nextStanceOrGesture) then
		player.nextStanceOrGesture = curTime + 2.5;
		
		local modelClass = nexus.animation.GetModelClass( player:GetModel() );
		local action = string.lower(arguments[1] or "");
		
		if (modelClass == "civilProtection") then
			local forcedAnimation = player:GetForcedAnimation();
			local animation = "luggage";
			
			if (action == "left") then
				animation = "motionleft";
			elseif (action == "right") then
				animation = "motionright";
			end;
			
			if ( forcedAnimation and MOUNT.stances[forcedAnimation.animation] ) then
				nexus.player.Notify(player, "You don't have permission to do this right now!");
			else
				player:SetForcedAnimation(animation, 2.5);
				player:SetSharedVar( "sh_StancePosition", player:GetPos() );
				player:SetSharedVar( "sh_StanceAngles", player:GetAngles() );
				player:SetSharedVar( "sh_StanceIdle", false );
			end;
		else
			nexus.player.Notify(player, "The model that you are using cannot perform this action!");
		end;
	else
		nexus.player.Notify(player, "You cannot do another stance or gesture yet!");
	end;
end;

nexus.command.Register(COMMAND, "AnimMotion");

COMMAND = {};
COMMAND.tip = "Make your character stick his hand out to deny access.";
COMMAND.flags = CMD_DEFAULT;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local curTime = CurTime();
	
	if (!player.nextStanceOrGesture or curTime >= player.nextStanceOrGesture) then
		player.nextStanceOrGesture = curTime + 2;
		
		local modelClass = nexus.animation.GetModelClass( player:GetModel() );
		
		if (modelClass == "civilProtection") then
			local forcedAnimation = player:GetForcedAnimation();
			
			if ( forcedAnimation and MOUNT.stances[forcedAnimation.animation] ) then
				nexus.player.Notify(player, "You don't have permission to do this right now!");
			else
				player:SetForcedAnimation("harassfront2", 1.5);
				player:SetSharedVar( "sh_StancePosition", player:GetPos() );
				player:SetSharedVar( "sh_StanceAngles", player:GetAngles() );
				player:SetSharedVar( "sh_StanceIdle", false );
			end;
		else
			nexus.player.Notify(player, "The model that you are using cannot perform this action!");
		end;
	else
		nexus.player.Notify(player, "You cannot do another stance or gesture yet!");
	end;
end;

nexus.command.Register(COMMAND, "AnimDeny");

COMMAND = {};
COMMAND.tip = "Make your character cheer in happiness.";
COMMAND.flags = CMD_DEFAULT;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local curTime = CurTime();
	
	if (!player.nextStanceOrGesture or curTime >= player.nextStanceOrGesture) then
		player.nextStanceOrGesture = curTime + 2.5;
		
		local modelClass = nexus.animation.GetModelClass( player:GetModel() );
		
		if (modelClass == "maleHuman" or modelClass == "femaleHuman") then
			local forcedAnimation = player:GetForcedAnimation();
			
			if ( forcedAnimation and MOUNT.stances[forcedAnimation.animation] ) then
				nexus.player.Notify(player, "You don't have permission to do this right now!");
			else
				if (modelClass == "femaleHuman" or math.random(1, 2) == 1) then
					player:SetForcedAnimation("cheer1", 2);
				else
					player:SetForcedAnimation("cheer2", 2);
				end;
				
				player:SetSharedVar( "sh_StancePosition", player:GetPos() );
				player:SetSharedVar( "sh_StanceAngles", player:GetAngles() );
				player:SetSharedVar( "sh_StanceIdle", false );
			end;
		else
			nexus.player.Notify(player, "The model that you are using cannot perform this action!");
		end;
	else
		nexus.player.Notify(player, "You cannot do another stance or gesture yet!");
	end;
end;

nexus.command.Register(COMMAND, "AnimCheer");

COMMAND = {};
COMMAND.tip = "Make your character wave at another character.";
COMMAND.text = "[string Close|Normal|Far]";
COMMAND.flags = CMD_DEFAULT;
COMMAND.optionalArguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local curTime = CurTime();
	
	if (!player.nextStanceOrGesture or curTime >= player.nextStanceOrGesture) then
		player.nextStanceOrGesture = curTime + 2.5;
		
		local modelClass = nexus.animation.GetModelClass( player:GetModel() );
		
		if (modelClass == "maleHuman" or modelClass == "femaleHuman") then
			local forcedAnimation = player:GetForcedAnimation();
			local action = string.lower(arguments[1] or "");
			
			if ( forcedAnimation and MOUNT.stances[forcedAnimation.animation] ) then
				nexus.player.Notify(player, "You don't have permission to do this right now!");
			else
				if (action == "close") then
					player:SetForcedAnimation("wave_close", 2);
				elseif (action == "far") then
					player:SetForcedAnimation("wave_smg1", 1.75);
				else
					player:SetForcedAnimation("wave", 2);
				end;
				
				player:SetSharedVar( "sh_StancePosition", player:GetPos() );
				player:SetSharedVar( "sh_StanceAngles", player:GetAngles() );
				player:SetSharedVar( "sh_StanceIdle", false );
			end;
		else
			nexus.player.Notify(player, "The model that you are using cannot perform this action!");
		end;
	else
		nexus.player.Notify(player, "You cannot do another stance or gesture yet!");
	end;
end;

nexus.command.Register(COMMAND, "AnimWave");

COMMAND = {};
COMMAND.tip = "Make your character pant up against a wall.";
COMMAND.flags = CMD_DEFAULT;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local curTime = CurTime();
	
	if (!player.nextStanceOrGesture or curTime >= player.nextStanceOrGesture) then
		player.nextStanceOrGesture = curTime + 2;
		
		local modelClass = nexus.animation.GetModelClass( player:GetModel() );
		local eyePos = player:EyePos();
		
		if (modelClass == "maleHuman" or modelClass == "femaleHuman") then
			local forcedAnimation = player:GetForcedAnimation();
			local angles = player:GetAngles():Forward();
			
			if ( forcedAnimation and (forcedAnimation.animation == "d2_coast03_postbattle_idle01" or forcedAnimation.animation == "d2_coast03_postbattle_idle01_entry") ) then
				MOUNT:MakePlayerExitStance(player);
			elseif ( !forcedAnimation or !MOUNT.stances[forcedAnimation] ) then
				if ( player:Crouching() ) then
					nexus.player.Notify(player, "You cannot do this while you are crouching!");
				else
					local traceLine = util.TraceLine( {
						start = eyePos,
						endpos = eyePos + (angles * 18),
						filter = player
					} );
					
					if (traceLine.Hit) then
						player:SetForcedAnimation("d2_coast03_postbattle_idle01_entry", 1.5, nil, function(player)
							player:SetForcedAnimation("d2_coast03_postbattle_idle01", 0, nil, function()
								MOUNT:MakePlayerExitStance(player);
							end);
						end);
						
						player:SnapEyeAngles( traceLine.HitNormal:Angle() + Angle(0, 180, 0) );
						player:SetSharedVar( "sh_StancePosition", player:GetPos() );
						player:SetSharedVar( "sh_StanceAngles", player:GetAngles() );
						player:SetSharedVar( "sh_StanceIdle", false );
					else
						nexus.player.Notify(player, "You must be facing, and near a wall!");
					end;
				end;
			end;
		else
			nexus.player.Notify(player, "The model that you are using cannot perform this action!");
		end;
	else
		nexus.player.Notify(player, "You cannot do another stance or gesture yet!");
	end;
end;

nexus.command.Register(COMMAND, "AnimPantWall");

COMMAND = {};
COMMAND.tip = "Make your character look out of a window.";
COMMAND.flags = CMD_DEFAULT;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local curTime = CurTime();
	
	if (!player.nextStanceOrGesture or curTime >= player.nextStanceOrGesture) then
		player.nextStanceOrGesture = curTime + 2;
		
		local modelClass = nexus.animation.GetModelClass( player:GetModel() );
		local eyePos = player:EyePos();
		
		if (modelClass == "maleHuman" or modelClass == "femaleHuman") then
			local forcedAnimation = player:GetForcedAnimation();
			local angles = player:GetAngles():Forward();
			
			if ( forcedAnimation and (forcedAnimation.animation == "d1_t03_tenements_look_out_window_idle" or forcedAnimation.animation == "d1_t03_lookoutwindow") ) then
				MOUNT:MakePlayerExitStance(player);
			elseif ( !forcedAnimation or !MOUNT.stances[forcedAnimation] ) then
				if ( player:Crouching() ) then
					nexus.player.Notify(player, "You cannot do this while you are crouching!");
				else
					local traceLine = util.TraceLine( {
						start = eyePos,
						endpos = eyePos + (angles * 18),
						filter = player
					} );
					
					if (traceLine.Hit) then
						if (modelClass == "maleHuman") then
							player:SetForcedAnimation("d1_t03_tenements_look_out_window_idle", 0, nil, function()
								MOUNT:MakePlayerExitStance(player);
							end);
						else
							player:SetForcedAnimation("d1_t03_lookoutwindow", 0, nil, function()
								MOUNT:MakePlayerExitStance(player);
							end);
						end;
						
						player:SnapEyeAngles( traceLine.HitNormal:Angle() + Angle(0, 180, 0) );
						player:SetSharedVar( "sh_StancePosition", player:GetPos() );
						player:SetSharedVar( "sh_StanceAngles", player:GetAngles() );
						player:SetSharedVar( "sh_StanceIdle", true );
					else
						nexus.player.Notify(player, "You must be facing, and near a wall!");
					end;
				end;
			end;
		else
			nexus.player.Notify(player, "The model that you are using cannot perform this action!");
		end;
	else
		nexus.player.Notify(player, "You cannot do another stance or gesture yet!");
	end;
end;

nexus.command.Register(COMMAND, "AnimWindow");

COMMAND = {};
COMMAND.tip = "Put your character into a panting stance.";
COMMAND.flags = CMD_DEFAULT;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local curTime = CurTime();
	
	if (!player.nextStanceOrGesture or curTime >= player.nextStanceOrGesture) then
		player.nextStanceOrGesture = curTime + 2;
		
		local modelClass = nexus.animation.GetModelClass( player:GetModel() );
		local position = player:GetPos();
		
		if (modelClass == "maleHuman" or modelClass == "femaleHuman") then
			local forcedAnimation = player:GetForcedAnimation();
			
			if ( forcedAnimation and (forcedAnimation.animation == "d2_coast03_postbattle_idle02" or forcedAnimation.animation == "d2_coast03_postbattle_idle02_entry") ) then
				MOUNT:MakePlayerExitStance(player);
			elseif ( !forcedAnimation or !MOUNT.stances[forcedAnimation.animation] ) then
				if ( player:Crouching() ) then
					nexus.player.Notify(player, "You cannot do this while you are crouching!");
				elseif ( player:IsOnGround() or IsValid( player:GetGroundEntity() ) ) then
					player:SetSharedVar( "sh_StancePosition", player:GetPos() );
					player:SetSharedVar( "sh_StanceAngles", player:GetAngles() );
					player:SetSharedVar( "sh_StanceIdle", false );
					player:SetForcedAnimation("d2_coast03_postbattle_idle02_entry", 1.5, nil, function(player)
						player:SetForcedAnimation("d2_coast03_postbattle_idle02", 0, nil, function()
							MOUNT:MakePlayerExitStance(player);
						end);
					end);
				else
					nexus.player.Notify(player, "You must be standing on the ground!");
				end;
			end;
		else
			nexus.player.Notify(player, "The model that you are using cannot perform this action!");
		end;
	else
		nexus.player.Notify(player, "You cannot do another stance or gesture yet!");
	end;
end;

nexus.command.Register(COMMAND, "AnimPant");

COMMAND = {};
COMMAND.tip = "Make your character sit on the ground.";
COMMAND.flags = CMD_DEFAULT;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local curTime = CurTime();
	
	if (!player.nextStanceOrGesture or curTime >= player.nextStanceOrGesture) then
		player.nextStanceOrGesture = curTime + 2;
		
		local modelClass = nexus.animation.GetModelClass( player:GetModel() );
		local position = player:GetPos();
		
		if (modelClass == "maleHuman" or modelClass == "femaleHuman") then
			local forcedAnimation = player:GetForcedAnimation();
			
			if ( forcedAnimation and (forcedAnimation.animation == "sit_ground" or forcedAnimation.animation == "idle_to_sit_ground"
			or forcedAnimation.animation == "sit_ground_to_idle") ) then
				player:SetForcedAnimation(false);
				
				player:SetForcedAnimation("sit_ground_to_idle", 2, nil, function(player)
					MOUNT:MakePlayerExitStance(player);
				end);
			elseif ( !forcedAnimation or !MOUNT.stances[forcedAnimation.animation] ) then
				if ( player:Crouching() ) then
					nexus.player.Notify(player, "You cannot do this while you are crouching!");
				elseif ( player:IsOnGround() or IsValid( player:GetGroundEntity() ) ) then
					player:SetSharedVar( "sh_StancePosition", player:GetPos() );
					player:SetSharedVar( "sh_StanceAngles", player:GetAngles() );
					player:SetSharedVar( "sh_StanceIdle", true );
					player:SetForcedAnimation("idle_to_sit_ground", 2, nil, function(player)
						player:SetForcedAnimation("sit_ground", 0, nil, function()
							local forcedAnimation = player:GetForcedAnimation();
							
							if (!forcedAnimation or forcedAnimation.animation != "sit_ground_to_idle") then
								MOUNT:MakePlayerExitStance(player);
							end;
						end);
					end);
				else
					nexus.player.Notify(player, "You must be standing on the ground!");
				end;
			end;
		else
			nexus.player.Notify(player, "The model that you are using cannot perform this action!");
		end;
	else
		nexus.player.Notify(player, "You cannot do another stance or gesture yet!");
	end;
end;

nexus.command.Register(COMMAND, "AnimSit");

COMMAND = {};
COMMAND.tip = "Make your character sit back up against a wall.";
COMMAND.flags = CMD_DEFAULT;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local curTime = CurTime();
	
	if (!player.nextStanceOrGesture or curTime >= player.nextStanceOrGesture) then
		player.nextStanceOrGesture = curTime + 2;
		
		local modelClass = nexus.animation.GetModelClass( player:GetModel() );
		local position = player:GetPos() + Vector(0, 0, 16);
		local angles = player:GetAngles():Forward();
		
		if (modelClass == "maleHuman" or modelClass == "femaleHuman") then
			local forcedAnimation = player:GetForcedAnimation();
			
			if (forcedAnimation and forcedAnimation.animation == "plazaidle4") then
				MOUNT:MakePlayerExitStance(player);
			elseif ( !forcedAnimation or !MOUNT.stances[forcedAnimation.animation] ) then
				if ( player:Crouching() ) then
					nexus.player.Notify(player, "You cannot do this while you are crouching!");
				else
					local traceLine = util.TraceLine( {
						start = position,
						endpos = position + (angles * -20),
						filter = player
					} );
					
					if (traceLine.Hit) then
						player.previousPosition = player:GetPos();
						
						player:SetPos( player:GetPos() + (angles * 4) );
						player:SnapEyeAngles( traceLine.HitNormal:Angle() );
						player:SetForcedAnimation("plazaidle4", 0, nil, function()
							MOUNT:MakePlayerExitStance(player);
						end);
						
						player:SetSharedVar( "sh_StancePosition", player:GetPos() );
						player:SetSharedVar( "sh_StanceAngles", player:GetAngles() );
						player:SetSharedVar( "sh_StanceIdle", true );
					else
						nexus.player.Notify(player, "You must be facing away from, and near a wall!");
					end;
				end;
			end;
		else
			nexus.player.Notify(player, "The model that you are using cannot perform this action!");
		end;
	else
		nexus.player.Notify(player, "You cannot do another stance or gesture yet!");
	end;
end;

nexus.command.Register(COMMAND, "AnimSitWall");

COMMAND = {};
COMMAND.tip = "Put your character into an idle stance.";
COMMAND.text = "[bool ArmsCrossed]";
COMMAND.flags = CMD_DEFAULT;
COMMAND.optionalArguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local modelClass = nexus.animation.GetModelClass( player:GetModel() );
	local curTime = CurTime();
	
	if (!player.nextStanceOrGesture or curTime >= player.nextStanceOrGesture) then
		player.nextStanceOrGesture = curTime + 2;
		
		if (modelClass == "maleHuman" or modelClass == "femaleHuman") then
			local forcedAnimation = player:GetForcedAnimation();
			
			if ( forcedAnimation and string.find(forcedAnimation.animation, "lineidle") ) then
				MOUNT:MakePlayerExitStance(player);
			elseif ( !forcedAnimation or !MOUNT.stances[forcedAnimation.animation] ) then
				if ( player:Crouching() ) then
					nexus.player.Notify(player, "You cannot do this while you are crouching!");
				else
					local animation = nil;
					
					if ( NEXUS:ToBool( arguments[1] ) ) then
						if (modelClass == "maleHuman") then
							animation = "lineidle02";
						else
							animation = "lineidle01";
						end;
					else
						if (modelClass == "femaleHuman") then
							animation = "lineidle0"..math.random(1, 2);
						else
							animation = "lineidle04";
						end;
					end;
					
					if ( player:IsOnGround() or IsValid( player:GetGroundEntity() ) ) then
						player:SetSharedVar( "sh_StancePosition", player:GetPos() );
						player:SetSharedVar( "sh_StanceAngles", player:GetAngles() );
						player:SetSharedVar( "sh_StanceIdle", true );
						player:SetForcedAnimation(animation, 0, nil, function()
							MOUNT:MakePlayerExitStance(player);
						end);
					else
						nexus.player.Notify(player, "You must be standing on the ground!");
					end;
				end;
			end;
		else
			nexus.player.Notify(player, "The model that you are using cannot perform this action!");
		end;
	else
		nexus.player.Notify(player, "You cannot do another stance or gesture yet!");
	end;
end;

nexus.command.Register(COMMAND, "AnimIdle");

COMMAND = {};
COMMAND.tip = "Make your character lean back up against a wall.";
COMMAND.text = "[string ArmsBack|ArmsDown]";
COMMAND.flags = CMD_DEFAULT;
COMMAND.optionalArguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local curTime = CurTime();
	
	if (!player.nextStanceOrGesture or curTime >= player.nextStanceOrGesture) then
		player.nextStanceOrGesture = curTime + 2;
		
		local modelClass = nexus.animation.GetModelClass( player:GetModel() );
		local eyePos = player:EyePos();
		
		if (modelClass == "maleHuman" or modelClass == "femaleHuman" or modelClass == "civilProtection") then
			local forcedAnimation = player:GetForcedAnimation();
			local action = string.lower(arguments[1] or "");
			
			if ( forcedAnimation and (forcedAnimation.animation == "lean_back" or forcedAnimation.animation == "plazaidle1"
			or forcedAnimation.animation == "plazaidle2" or forcedAnimation.animation == "idle_baton") ) then
				MOUNT:MakePlayerExitStance(player);
			elseif ( !forcedAnimation or !MOUNT.stances[forcedAnimation.animation] ) then
				if ( player:Crouching() ) then
					nexus.player.Notify(player, "You cannot do this while you are crouching!");
				else
					local animation = "lean_back";
					local traceLine = util.TraceLine( {
						start = eyePos,
						endpos = eyePos + (player:GetAngles():Forward() * -20),
						filter = player
					} );
					
					if (modelClass != "civilProtection") then
						if (action == "armsback") then
							animation = "plazaidle2";
						elseif (action == "armsdown") then
							animation = "plazaidle1";
						end;
					else
						animation = "idle_baton";
					end;
					
					if (traceLine.Hit) then
						player:SetSharedVar("sh_Stance", true);
						player:SnapEyeAngles( traceLine.HitNormal:Angle() );
						player:SetForcedAnimation(animation, 0, nil, function()
							MOUNT:MakePlayerExitStance(player);
						end);
						
						player:SetSharedVar( "sh_StancePosition", player:GetPos() );
						player:SetSharedVar( "sh_StanceAngles", player:GetAngles() );
						player:SetSharedVar( "sh_StanceIdle", true );
					else
						nexus.player.Notify(player, "You must be facing away from, and near a wall!");
					end;
				end;
			end;
		else
			nexus.player.Notify(player, "The model that you are using cannot perform this action!");
		end;
	else
		nexus.player.Notify(player, "You cannot do another stance or gesture yet!");
	end;
end;

nexus.command.Register(COMMAND, "AnimLean");

COMMAND = {};
COMMAND.tip = "Make your character put their hands up against the wall.";
COMMAND.text = "[bool HandsUp]";
COMMAND.flags = CMD_DEFAULT;
COMMAND.optionalArguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local curTime = CurTime();
	
	if (!player.nextStanceOrGesture or curTime >= player.nextStanceOrGesture) then
		player.nextStanceOrGesture = curTime + 2;
		
		local modelClass = nexus.animation.GetModelClass( player:GetModel() );
		local eyePos = player:EyePos();
		
		if (modelClass == "maleHuman") then
			local forcedAnimation = player:GetForcedAnimation();
			local angles = player:GetAngles():Forward();
			
			if ( forcedAnimation and (forcedAnimation.animation == "spreadwallidle" or forcedAnimation.animation == "apcarrestidle") ) then
				MOUNT:MakePlayerExitStance(player);
			elseif ( !forcedAnimation or !MOUNT.stances[forcedAnimation] ) then
				if ( player:Crouching() ) then
					nexus.player.Notify(player, "You cannot do this while you are crouching!");
				else
					local traceLine = util.TraceLine( {
						start = eyePos,
						endpos = eyePos + (angles * 18),
						filter = player
					} );
					
					if (traceLine.Hit) then
						player.previousPosition = player:GetPos();
						
						if ( !NEXUS:ToBool( arguments[1] ) ) then
							player:SetPos( player:GetPos() + (angles * -24) );
							player:SetForcedAnimation("apcarrestidle", 0, nil, function()
								MOUNT:MakePlayerExitStance(player);
							end);
						else
							player:SetPos( player:GetPos() + (angles * 14) );
							player:SetForcedAnimation("spreadwallidle", 0, nil, function()
								MOUNT:MakePlayerExitStance(player);
							end);
						end;
						
						player:SnapEyeAngles( traceLine.HitNormal:Angle() + Angle(0, 180, 0) );
						player:SetSharedVar( "sh_StancePosition", player:GetPos() );
						player:SetSharedVar( "sh_StanceAngles", player:GetAngles() );
						player:SetSharedVar( "sh_StanceIdle", false );
					else
						nexus.player.Notify(player, "You must be facing, and near a wall!");
					end;
				end;
			end;
		else
			nexus.player.Notify(player, "The model that you are using cannot perform this action!");
		end;
	else
		nexus.player.Notify(player, "You cannot do another stance or gesture yet!");
	end;
end;

nexus.command.Register(COMMAND, "AnimATW");