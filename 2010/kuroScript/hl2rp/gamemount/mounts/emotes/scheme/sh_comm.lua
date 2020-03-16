--[[
Name: "sh_comm.lua".
Product: "HL2 RP".
--]]

local MOUNT = MOUNT;
local COMMAND = {};

-- Set some information.
COMMAND = {};
COMMAND.tip = "Put your character into a threatening stance.";
COMMAND.text = "<crossed|none>"
COMMAND.flags = CMD_DEFAULT;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local curTime = CurTime();
	
	-- Check if a statement is true.
	if (!player._NextStanceOrGesture or curTime >= player._NextStanceOrGesture) then
		player._NextStanceOrGesture = curTime + 2;
		
		-- Set some information.
		local modelClass = kuroScript.animation.getModelClass( player:GetModel() );
		local position = player:GetPos();
		
		-- Check if a statement is true.
		if (modelClass == "civilProtection") then
			local forcedAnimation = player:GetForcedAnimation();
			local animation = "plazathreat1";
			
			-- Check if a statement is true.
			if (math.random(1, 2) == 2 or arguments[1] == "crossed") then
				animation = "plazathreat2";
			end;
			
			-- Check if a statement is true.
			if ( forcedAnimation and (forcedAnimation.animation == "plazathreat1" or forcedAnimation.animation == "plazathreat2") ) then
				MOUNT:MakePlayerExitStance(player);
			elseif ( !forcedAnimation or !MOUNT.stances[forcedAnimation.animation] ) then
				if ( player:Crouching() ) then
					kuroScript.player.Notify(player, "You cannot do this while you are crouching!");
				else
					local traceLine = util.TraceLine( {
						start = position,
						endpos = position - Vector(0, 0, 16),
						filter = player
					} );
					
					-- Check if a statement is true.
					if ( traceLine.HitWorld and player:IsOnGround() ) then
						player._StanceLocation = player:GetPos();
						
						-- Set some information.
						player:SetSharedVar("ks_Stance", true);
						player:SetForcedAnimation(animation, 0, function(player)
							player:Freeze(true);
						end, function()
							MOUNT:MakePlayerExitStance(player);
						end);
					else
						kuroScript.player.Notify(player, "You must be standing on the ground!");
					end;
				end;
			end;
		else
			kuroScript.player.Notify(player, "The model that you are using cannot perform this action!");
		end;
	else
		kuroScript.player.Notify(player, "You cannot do another stance or gesture yet!");
	end;
end;

-- Register the command.
kuroScript.command.Register(COMMAND, "threat");

-- Set some information.
COMMAND = {};
COMMAND.tip = "Make your character motion to something in a direction.";
COMMAND.text = "<left|right|behind>";
COMMAND.flags = CMD_DEFAULT;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local curTime = CurTime();
	
	-- Check if a statement is true.
	if (!player._NextStanceOrGesture or curTime >= player._NextStanceOrGesture) then
		player._NextStanceOrGesture = curTime + 2.5;
		
		-- Set some information.
		local modelClass = kuroScript.animation.getModelClass( player:GetModel() );
		
		-- Check if a statement is true.
		if (modelClass == "civilProtection") then
			local forcedAnimation = player:GetForcedAnimation();
			local animation = "luggage";
			
			-- Check if a statement is true.
			if (arguments[1] == "left") then
				animation = "motionleft";
			elseif (arguments[1] == "right") then
				animation = "motionright";
			end;
			
			-- Check if a statement is true.
			if ( forcedAnimation and MOUNT.stances[forcedAnimation.animation] ) then
				kuroScript.player.Notify(player, "You cannot do that in this state!");
			else
				player:SetForcedAnimation(animation, 2.5, function(player)
					player:Freeze(true);
				end, function(player)
					player:Freeze(false);
				end);
			end;
		else
			kuroScript.player.Notify(player, "The model that you are using cannot perform this action!");
		end;
	else
		kuroScript.player.Notify(player, "You cannot do another stance or gesture yet!");
	end;
end;

-- Register the command.
kuroScript.command.Register(COMMAND, "motion");

-- Set some information.
COMMAND = {};
COMMAND.tip = "Make your character stick his hand out to deny access.";
COMMAND.flags = CMD_DEFAULT;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local curTime = CurTime();
	
	-- Check if a statement is true.
	if (!player._NextStanceOrGesture or curTime >= player._NextStanceOrGesture) then
		player._NextStanceOrGesture = curTime + 2;
		
		-- Set some information.
		local modelClass = kuroScript.animation.getModelClass( player:GetModel() );
		
		-- Check if a statement is true.
		if (modelClass == "civilProtection") then
			local forcedAnimation = player:GetForcedAnimation();
			
			-- Check if a statement is true.
			if ( forcedAnimation and MOUNT.stances[forcedAnimation.animation] ) then
				kuroScript.player.Notify(player, "You cannot do that in this state!");
			else
				player:SetForcedAnimation("harassfront2", 1.5, function(player)
					player:Freeze(true);
				end, function(player)
					player:Freeze(false);
				end);
			end;
		else
			kuroScript.player.Notify(player, "The model that you are using cannot perform this action!");
		end;
	else
		kuroScript.player.Notify(player, "You cannot do another stance or gesture yet!");
	end;
end;

-- Register the command.
kuroScript.command.Register(COMMAND, "deny");

-- Set some information.
COMMAND = {};
COMMAND.tip = "Make your character cheer in happiness.";
COMMAND.flags = CMD_DEFAULT;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local curTime = CurTime();
	
	-- Check if a statement is true.
	if (!player._NextStanceOrGesture or curTime >= player._NextStanceOrGesture) then
		player._NextStanceOrGesture = curTime + 2.5;
		
		-- Set some information.
		local modelClass = kuroScript.animation.getModelClass( player:GetModel() );
		
		-- Check if a statement is true.
		if (modelClass == "maleHuman" or modelClass == "femaleHuman") then
			local forcedAnimation = player:GetForcedAnimation();
			
			-- Check if a statement is true.
			if ( forcedAnimation and MOUNT.stances[forcedAnimation.animation] ) then
				kuroScript.player.Notify(player, "You cannot do that in this state!");
			else
				player:SetForcedAnimation("cheer1", 2.5, function(player)
					player:Freeze(true);
				end, function(player)
					player:Freeze(false);
				end);
			end;
		else
			kuroScript.player.Notify(player, "The model that you are using cannot perform this action!");
		end;
	else
		kuroScript.player.Notify(player, "You cannot do another stance or gesture yet!");
	end;
end;

-- Register the command.
kuroScript.command.Register(COMMAND, "cheer");

-- Set some information.
COMMAND = {};
COMMAND.tip = "Make your character wave at another character.";
COMMAND.flags = CMD_DEFAULT;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local curTime = CurTime();
	
	-- Check if a statement is true.
	if (!player._NextStanceOrGesture or curTime >= player._NextStanceOrGesture) then
		player._NextStanceOrGesture = curTime + 2.5;
		
		-- Set some information.
		local modelClass = kuroScript.animation.getModelClass( player:GetModel() );
		
		-- Check if a statement is true.
		if (modelClass == "maleHuman" or modelClass == "femaleHuman") then
			local forcedAnimation = player:GetForcedAnimation();
			
			-- Check if a statement is true.
			if ( forcedAnimation and MOUNT.stances[forcedAnimation.animation] ) then
				kuroScript.player.Notify(player, "You cannot do that in this state!");
			else
				player:SetForcedAnimation("wave", 2.5, function(player)
					player:Freeze(true);
				end, function(player)
					player:Freeze(false);
				end);
			end;
		else
			kuroScript.player.Notify(player, "The model that you are using cannot perform this action!");
		end;
	else
		kuroScript.player.Notify(player, "You cannot do another stance or gesture yet!");
	end;
end;

-- Register the command.
kuroScript.command.Register(COMMAND, "wave");

-- Set some information.
COMMAND = {};
COMMAND.tip = "Make your character pant up against a wall.";
COMMAND.flags = CMD_DEFAULT;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local curTime = CurTime();
	
	-- Check if a statement is true.
	if (!player._NextStanceOrGesture or curTime >= player._NextStanceOrGesture) then
		player._NextStanceOrGesture = curTime + 2;
		
		-- Set some information.
		local modelClass = kuroScript.animation.getModelClass( player:GetModel() );
		local eyePos = player:EyePos();
		
		-- Check if a statement is true.
		if (modelClass == "maleHuman" or modelClass == "femaleHuman") then
			local forcedAnimation = player:GetForcedAnimation();
			local angles = player:GetAngles():Forward();
			
			-- Check if a statement is true.
			if ( forcedAnimation and (forcedAnimation.animation == "d2_coast03_postbattle_idle01" or forcedAnimation.animation == "d2_coast03_postbattle_idle01_entry") ) then
				MOUNT:MakePlayerExitStance(player);
			elseif ( !forcedAnimation or !MOUNT.stances[forcedAnimation] ) then
				if ( player:Crouching() ) then
					kuroScript.player.Notify(player, "You cannot do this while you are crouching!");
				else
					local traceLine = util.TraceLine( {
						start = eyePos,
						endpos = eyePos + (angles * 18),
						filter = player
					} );
					
					-- Check if a statement is true.
					if (traceLine.HitWorld) then
						player._StanceLocation = player:GetPos();
						
						-- Set some information.
						player:SetForcedAnimation("d2_coast03_postbattle_idle01_entry", 1.5, function(player)
							player:Freeze(true);
						end, function(player)
							player:SetForcedAnimation("d2_coast03_postbattle_idle01", 0, function(player)
								player:Freeze(true);
							end, function()
								MOUNT:MakePlayerExitStance(player);
							end);
						end);
						
						-- Set some information.
						player:SnapEyeAngles( traceLine.HitNormal:Angle() + Angle(0, 180, 0) );
						player:SetSharedVar("ks_Stance", true);
					else
						kuroScript.player.Notify(player, "You must be facing, and near a wall!");
					end;
				end;
			end;
		else
			kuroScript.player.Notify(player, "The model that you are using cannot perform this action!");
		end;
	else
		kuroScript.player.Notify(player, "You cannot do another stance or gesture yet!");
	end;
end;

-- Register the command.
kuroScript.command.Register(COMMAND, "pantwall");

-- Set some information.
COMMAND = {};
COMMAND.tip = "Make your character look out of a window.";
COMMAND.flags = CMD_DEFAULT;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local curTime = CurTime();
	
	-- Check if a statement is true.
	if (!player._NextStanceOrGesture or curTime >= player._NextStanceOrGesture) then
		player._NextStanceOrGesture = curTime + 2;
		
		-- Set some information.
		local modelClass = kuroScript.animation.getModelClass( player:GetModel() );
		local eyePos = player:EyePos();
		
		-- Check if a statement is true.
		if (modelClass == "maleHuman" or modelClass == "femaleHuman") then
			local forcedAnimation = player:GetForcedAnimation();
			local angles = player:GetAngles():Forward();
			
			-- Check if a statement is true.
			if ( forcedAnimation and (forcedAnimation.animation == "d1_t03_tenements_look_out_window_idle" or forcedAnimation.animation == "d1_t03_lookoutwindow") ) then
				MOUNT:MakePlayerExitStance(player);
			elseif ( !forcedAnimation or !MOUNT.stances[forcedAnimation] ) then
				if ( player:Crouching() ) then
					kuroScript.player.Notify(player, "You cannot do this while you are crouching!");
				else
					local traceLine = util.TraceLine( {
						start = eyePos,
						endpos = eyePos + (angles * 18),
						filter = player
					} );
					
					-- Check if a statement is true.
					if (traceLine.HitWorld) then
						player._StanceLocation = player:GetPos();
						
						-- Check if a statement is true.
						if (modelClass == "maleHuman") then
							player:SetForcedAnimation("d1_t03_tenements_look_out_window_idle", 0, function(player)
								player:Freeze(true);
							end, function()
								MOUNT:MakePlayerExitStance(player);
							end);
						else
							player:SetForcedAnimation("d1_t03_lookoutwindow", 0, function(player)
								player:Freeze(true);
							end, function()
								MOUNT:MakePlayerExitStance(player);
							end);
						end;
						
						-- Set some information.
						player:SnapEyeAngles( traceLine.HitNormal:Angle() + Angle(0, 180, 0) );
						player:SetSharedVar("ks_Stance", true);
					else
						kuroScript.player.Notify(player, "You must be facing, and near a wall!");
					end;
				end;
			end;
		else
			kuroScript.player.Notify(player, "The model that you are using cannot perform this action!");
		end;
	else
		kuroScript.player.Notify(player, "You cannot do another stance or gesture yet!");
	end;
end;

-- Register the command.
kuroScript.command.Register(COMMAND, "window");

-- Set some information.
COMMAND = {};
COMMAND.tip = "Put your character into a panting stance.";
COMMAND.flags = CMD_DEFAULT;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local curTime = CurTime();
	
	-- Check if a statement is true.
	if (!player._NextStanceOrGesture or curTime >= player._NextStanceOrGesture) then
		player._NextStanceOrGesture = curTime + 2;
		
		-- Set some information.
		local modelClass = kuroScript.animation.getModelClass( player:GetModel() );
		local position = player:GetPos();
		
		-- Check if a statement is true.
		if (modelClass == "maleHuman" or modelClass == "femaleHuman") then
			local forcedAnimation = player:GetForcedAnimation();
			
			-- Check if a statement is true.
			if ( forcedAnimation and (forcedAnimation.animation == "d2_coast03_postbattle_idle02" or forcedAnimation.animation == "d2_coast03_postbattle_idle02_entry") ) then
				MOUNT:MakePlayerExitStance(player);
			elseif ( !forcedAnimation or !MOUNT.stances[forcedAnimation.animation] ) then
				if ( player:Crouching() ) then
					kuroScript.player.Notify(player, "You cannot do this while you are crouching!");
				else
					local traceLine = util.TraceLine( {
						start = position,
						endpos = position - Vector(0, 0, 16),
						filter = player
					} );
					
					-- Check if a statement is true.
					if ( traceLine.HitWorld and player:IsOnGround() ) then
						player._StanceLocation = player:GetPos();
						
						-- Set some information.
						player:SetSharedVar("ks_Stance", true);
						player:SetForcedAnimation("d2_coast03_postbattle_idle02_entry", 1.5, function(player)
							player:Freeze(true);
						end, function(player)
							player:SetForcedAnimation("d2_coast03_postbattle_idle02", 0, function(player)
								player:Freeze(true);
							end, function()
								MOUNT:MakePlayerExitStance(player);
							end);
						end);
					else
						kuroScript.player.Notify(player, "You must be standing on the ground!");
					end;
				end;
			end;
		else
			kuroScript.player.Notify(player, "The model that you are using cannot perform this action!");
		end;
	else
		kuroScript.player.Notify(player, "You cannot do another stance or gesture yet!");
	end;
end;

-- Register the command.
kuroScript.command.Register(COMMAND, "pant");

-- Set some information.
COMMAND = {};
COMMAND.tip = "Make your character sit on the ground.";
COMMAND.flags = CMD_DEFAULT;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local curTime = CurTime();
	
	-- Check if a statement is true.
	if (!player._NextStanceOrGesture or curTime >= player._NextStanceOrGesture) then
		player._NextStanceOrGesture = curTime + 2;
		
		-- Set some information.
		local modelClass = kuroScript.animation.getModelClass( player:GetModel() );
		local position = player:GetPos();
		
		-- Check if a statement is true.
		if (modelClass == "maleHuman" or modelClass == "femaleHuman") then
			local forcedAnimation = player:GetForcedAnimation();
			
			-- Check if a statement is true.
			if ( forcedAnimation and (forcedAnimation.animation == "sit_ground" or forcedAnimation.animation == "idle_to_sit_ground"
			or forcedAnimation.animation == "sit_ground_to_idle") ) then
				player:SetForcedAnimation(false);
				
				-- Set some information.
				player:SetForcedAnimation("sit_ground_to_idle", 2, function(player)
					player:Freeze(true);
				end, function(player)
					MOUNT:MakePlayerExitStance(player);
				end);
			elseif ( !forcedAnimation or !MOUNT.stances[forcedAnimation.animation] ) then
				if ( player:Crouching() ) then
					kuroScript.player.Notify(player, "You cannot do this while you are crouching!");
				else
					local traceLine = util.TraceLine( {
						start = position,
						endpos = position - Vector(0, 0, 16),
						filter = player
					} );
					
					-- Check if a statement is true.
					if ( traceLine.HitWorld and player:IsOnGround() ) then
						player._StanceLocation = player:GetPos();
						
						-- Set some information.
						player:SetSharedVar("ks_Stance", true);
						player:SetForcedAnimation("idle_to_sit_ground", 2, function(player)
							player:Freeze(true);
						end, function(player)
							player:SetForcedAnimation("sit_ground", 0, function(player)
								player:Freeze(true);
							end, function()
								local forcedAnimation = player:GetForcedAnimation();
								
								-- Check if a statement is true.
								if (!forcedAnimation or forcedAnimation.animation != "sit_ground_to_idle") then
									MOUNT:MakePlayerExitStance(player);
								end;
							end);
						end);
					else
						kuroScript.player.Notify(player, "You must be standing on the ground!");
					end;
				end;
			end;
		else
			kuroScript.player.Notify(player, "The model that you are using cannot perform this action!");
		end;
	else
		kuroScript.player.Notify(player, "You cannot do another stance or gesture yet!");
	end;
end;

-- Register the command.
kuroScript.command.Register(COMMAND, "sit");

-- Set some information.
COMMAND = {};
COMMAND.tip = "Make your character sit back up against a wall.";
COMMAND.flags = CMD_DEFAULT;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local curTime = CurTime();
	
	-- Check if a statement is true.
	if (!player._NextStanceOrGesture or curTime >= player._NextStanceOrGesture) then
		player._NextStanceOrGesture = curTime + 2;
		
		-- Set some information.
		local modelClass = kuroScript.animation.getModelClass( player:GetModel() );
		local angles = player:GetAngles():Forward();
		local eyePos = player:EyePos();
		local k, v;
		
		-- Check if a statement is true.
		if (modelClass == "maleHuman" or modelClass == "femaleHuman") then
			local forcedAnimation = player:GetForcedAnimation();
			
			-- Check if a statement is true.
			if (forcedAnimation and forcedAnimation.animation == "plazaidle4") then
				MOUNT:MakePlayerExitStance(player);
			elseif ( !forcedAnimation or !MOUNT.stances[forcedAnimation.animation] ) then
				if ( player:Crouching() ) then
					kuroScript.player.Notify(player, "You cannot do this while you are crouching!");
				else
					local traceLine = util.TraceLine( {
						start = eyePos,
						endpos = eyePos + (angles * -20),
						filter = player
					} );
					
					-- Check if a statement is true.
					if (traceLine.HitWorld) then
						player._StancePosition = player:GetPos();
						
						-- Set some information.
						player:SetPos( player:GetPos() + (angles * 4) );
						player:SetSharedVar("ks_Stance", true);
						player:SnapEyeAngles( traceLine.HitNormal:Angle() );
						player:SetForcedAnimation("plazaidle4", 0, function(player)
							player:Freeze(true);
						end, function() MOUNT:MakePlayerExitStance(player); end);
						
						-- Set some information.
						player._StanceLocation = player:GetPos();
					else
						kuroScript.player.Notify(player, "You must be facing away from, and near a wall!");
					end;
				end;
			end;
		else
			kuroScript.player.Notify(player, "The model that you are using cannot perform this action!");
		end;
	else
		kuroScript.player.Notify(player, "You cannot do another stance or gesture yet!");
	end;
end;

-- Register the command.
kuroScript.command.Register(COMMAND, "sitwall");

-- Set some information.
COMMAND = {};
COMMAND.tip = "Put your character into an idle stance.";
COMMAND.text = "<crossed|none>";
COMMAND.flags = CMD_DEFAULT;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local curTime = CurTime();
	
	-- Check if a statement is true.
	if (!player._NextStanceOrGesture or curTime >= player._NextStanceOrGesture) then
		player._NextStanceOrGesture = curTime + 2;
		
		-- Set some information.
		local modelClass = kuroScript.animation.getModelClass( player:GetModel() );
		local position = player:GetPos();
		
		-- Check if a statement is true.
		if (modelClass == "maleHuman" or modelClass == "femaleHuman") then
			local forcedAnimation = player:GetForcedAnimation();
			
			-- Check if a statement is true.
			if ( forcedAnimation and (forcedAnimation.animation == "lineidle04" or forcedAnimation.animation == "lineidle02") ) then
				MOUNT:MakePlayerExitStance(player);
			elseif ( !forcedAnimation or !MOUNT.stances[forcedAnimation.animation] ) then
				if ( player:Crouching() ) then
					kuroScript.player.Notify(player, "You cannot do this while you are crouching!");
				else
					local animation = math.random(1, 2);
					local traceLine = util.TraceLine( {
						start = position,
						endpos = position - Vector(0, 0, 16),
						filter = player
					} );
					
					-- Check if a statement is true.
					if (animation == 2 or arguments[1] == "crossed") then
						if (modelClass == "maleHuman") then
							animation = "lineidle02";
						else
							animation = "lineidle01";
						end;
					elseif (animation == 1) then
						if (modelClass == "femaleHuman") then
							animation = "lineidle0"..math.random(1, 2);
						else
							animation = "lineidle04";
						end;
					end;
					
					-- Check if a statement is true.
					if ( traceLine.HitWorld and player:IsOnGround() ) then
						player._StanceLocation = player:GetPos();
						
						-- Set some information.
						player:SetSharedVar("ks_Stance", true);
						player:SetForcedAnimation(animation, 0, function(player)
							player:Freeze(true);
						end, function()
							MOUNT:MakePlayerExitStance(player);
						end);
					else
						kuroScript.player.Notify(player, "You must be standing on the ground!");
					end;
				end;
			end;
		else
			kuroScript.player.Notify(player, "The model that you are using cannot perform this action!");
		end;
	else
		kuroScript.player.Notify(player, "You cannot do another stance or gesture yet!");
	end;
end;

-- Register the command.
kuroScript.command.Register(COMMAND, "idle");

-- Set some information.
COMMAND = {};
COMMAND.tip = "Make your character lean back up against a wall.";
COMMAND.text = "<1|2|3|none>";
COMMAND.flags = CMD_DEFAULT;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local curTime = CurTime();
	
	-- Check if a statement is true.
	if (!player._NextStanceOrGesture or curTime >= player._NextStanceOrGesture) then
		player._NextStanceOrGesture = curTime + 2;
		
		-- Set some information.
		local modelClass = kuroScript.animation.getModelClass( player:GetModel() );
		local eyePos = player:EyePos();
		
		-- Check if a statement is true.
		if (modelClass == "maleHuman" or modelClass == "femaleHuman" or modelClass == "civilProtection") then
			local forcedAnimation = player:GetForcedAnimation();
			
			-- Check if a statement is true.
			if ( forcedAnimation and (forcedAnimation.animation == "lean_back" or forcedAnimation.animation == "plazaidle1"
			or forcedAnimation.animation == "plazaidle2" or forcedAnimation.animation == "idle_baton") ) then
				MOUNT:MakePlayerExitStance(player);
			elseif ( !forcedAnimation or !MOUNT.stances[forcedAnimation.animation] ) then
				if ( player:Crouching() ) then
					kuroScript.player.Notify(player, "You cannot do this while you are crouching!");
				else
					local animation = math.random(1, 3);
					local traceLine = util.TraceLine( {
						start = eyePos,
						endpos = eyePos + (player:GetAngles():Forward() * -20),
						filter = player
					} );
					
					-- Check if a statement is true.
					if (modelClass != "civilProtection") then
						if (animation == 3 or arguments[1] == "3") then
							animation = "lean_back";
						elseif (animation == 2 or arguments[1] == "2") then
							animation = "plazaidle2";
						elseif (animation == 1 or arguments[1] == "1") then
							animation = "plazaidle1";
						end;
					else
						animation = "idle_baton";
					end;
					
					-- Check if a statement is true.
					if (traceLine.HitWorld) then
						player._StanceLocation = player:GetPos();
						
						-- Set some information.
						player:SetSharedVar("ks_Stance", true);
						player:SnapEyeAngles( traceLine.HitNormal:Angle() );
						player:SetForcedAnimation(animation, 0, function(player)
							player:Freeze(true);
						end, function() MOUNT:MakePlayerExitStance(player); end);
					else
						kuroScript.player.Notify(player, "You must be facing away from, and near a wall!");
					end;
				end;
			end;
		else
			kuroScript.player.Notify(player, "The model that you are using cannot perform this action!");
		end;
	else
		kuroScript.player.Notify(player, "You cannot do another stance or gesture yet!");
	end;
end;

-- Register the command.
kuroScript.command.Register(COMMAND, "lean");

-- Set some information.
COMMAND = {};
COMMAND.tip = "Make your character put their hands up against the wall.";
COMMAND.text = "<handsup|none>";
COMMAND.flags = CMD_DEFAULT;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local curTime = CurTime();
	
	-- Check if a statement is true.
	if (!player._NextStanceOrGesture or curTime >= player._NextStanceOrGesture) then
		player._NextStanceOrGesture = curTime + 2;
		
		-- Set some information.
		local modelClass = kuroScript.animation.getModelClass( player:GetModel() );
		local eyePos = player:EyePos();
		
		-- Check if a statement is true.
		if (modelClass == "maleHuman") then
			local forcedAnimation = player:GetForcedAnimation();
			local angles = player:GetAngles():Forward();
			
			-- Check if a statement is true.
			if ( forcedAnimation and (forcedAnimation.animation == "spreadwallidle" or forcedAnimation.animation == "apcarrestidle") ) then
				MOUNT:MakePlayerExitStance(player);
			elseif ( !forcedAnimation or !MOUNT.stances[forcedAnimation] ) then
				if ( player:Crouching() ) then
					kuroScript.player.Notify(player, "You cannot do this while you are crouching!");
				else
					local traceLine = util.TraceLine( {
						start = eyePos,
						endpos = eyePos + (angles * 18),
						filter = player
					} );
					
					-- Check if a statement is true.
					if (traceLine.HitWorld) then
						player._StancePosition = player:GetPos();
						
						-- Check if a statement is true.
						if (math.random(1, 2) == 2 and arguments[1] != "handsup") then
							player:SetPos( player:GetPos() + (angles * -24) );
							player:SetForcedAnimation("apcarrestidle", 0, function(player)
								player:Freeze(true);
							end, function() MOUNT:MakePlayerExitStance(player); end);
						else
							player:SetPos( player:GetPos() + (angles * 14) );
							player:SetForcedAnimation("spreadwallidle", 0, function(player)
								player:Freeze(true);
							end, function() MOUNT:MakePlayerExitStance(player); end);
						end;
						
						-- Set some information.
						player:SnapEyeAngles( traceLine.HitNormal:Angle() + Angle(0, 180, 0) );
						player:SetSharedVar("ks_Stance", true);
						
						-- Set some information.
						player._StanceLocation = player:GetPos();
					else
						kuroScript.player.Notify(player, "You must be facing, and near a wall!");
					end;
				end;
			end;
		else
			kuroScript.player.Notify(player, "The model that you are using cannot perform this action!");
		end;
	else
		kuroScript.player.Notify(player, "You cannot do another stance or gesture yet!");
	end;
end;

-- Register the command.
kuroScript.command.Register(COMMAND, "atw");