--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PLUGIN = PLUGIN;

-- Called when a player's character data should be saved.
function PLUGIN:PlayerSaveCharacterData(player, data)
	if (!player.cwVehicleList) then
		return;
	end;
	
	for k, v in pairs(player.cwVehicleList) do
		local itemUniqueID = v("uniqueID");
		
		if (IsValid(k) and data[itemUniqueID]) then
			data["Vehicles"][itemUniqueID][1] = math.Round(k.Fuel);
			
			if (k.cwPhysDesc != v.cwVehiclePhysDesc) then
				data["Vehicles"][itemUniqueID][3] = k.cwPhysDesc;
			end;
		end;
	end;
end;

function PLUGIN:PlayerRestoreCharacterData(player, data)
	data["Vehicles"] = data["Vehicles"] or {};
	
	for k, v in pairs(Clockwork.item:GetAll()) do
		local itemUniqueID = v("uniqueID");
		
		if (v("baseItem") == "vehicle_base") then
			data["Vehicles"][itemUniqueID] = data["Vehicles"][itemUniqueID] or {100, nil, ""};
		end;
	end;
end;

-- Called when a player's class has been set.
function PLUGIN:PlayerClassSet(player, newClass, oldClass, noRespawn, addDelay, noModelChange)
	if (newClass.index == CLASS_POLICE) then
		if (!self:DoesPlayerHavePoliceCar(player)) then
			if (self:CanPlayerHavePoliceCar(player)) then
				player:GiveItem("police_car", true);
				
				for k, v in ipairs(_player.GetAll()) do
					local team = v:Team();
					
					if (team == CLASS_POLICE or team == CLASS_DISPENSER or team == CLASS_RESPONSE) then
						Clockwork.player:Notify(v, player:Name().." has been given a police car to share with other cops.");
					end;
				end;
			end;
		end;
	else
		player:TakeItem("police_car");
		self:PlayerTakePoliceCar(player);
		
		for k, v in ipairs(_team.GetPlayers(CLASS_POLICE)) do
			if (v:HasInitialized() and !self:DoesPlayerHavePoliceCar(v)) then
				if (self:CanPlayerHavePoliceCar(v)) then
					v:GiveItem("police_car", true);
					
					for k2, v2 in ipairs(_player.GetAll()) do
						local team = v2:Team();
						
						if (team == CLASS_POLICE or team == CLASS_DISPENSER or team == CLASS_RESPONSE) then
							Clockwork.player:Notify(v2, v:Name().." has been given a police car to share with other cops.");
						end;
					end;
				end;
			end;
		end;
	end;
end;

-- Called when a player's shared variables should be set.
function PLUGIN:PlayerSetSharedVars(player, curTime)
	if (player.cwFuelAmt) then
		player:SetSharedVar("Fuel", math.Round(player.cwFuelAmt));
	else
		player:SetSharedVar("Fuel", 100);
	end;
end;

-- Called at an interval while a player is connected.
function PLUGIN:PlayerThink(player, curTime, infoTable)
	local isValidVehicle = false;
	
	if (player:InVehicle()) then
		local vehicle = player:GetVehicle();
		
		if (IsValid(vehicle) and vehicle.cwItemTable) then
			local uniqueID = vehicle.cwItemTable.uniqueID;
			local vehicleData = player:GetCharacterData("Vehicles")[uniqueID];

			if (vehicleData) then
				local velocity = vehicle:GetVelocity():Length();
				
				if (velocity > 0) then
					vehicle.Fuel = math.Clamp(vehicle.Fuel - (velocity / 96000), 0, 100);
				end;

				if (vehicle.Fuel == 0) then
					local physicsObject = vehicle:GetPhysicsObject();

					if (IsValid(physicsObject)) then
						physicsObject:SetVelocity(physicsObject:GetVelocity() * -1);
					end;
				end;

				player.cwFuelAmt = vehicle.Fuel;
				isValidVehicle = true;
			end;
		end;
		
		local parentVehicle = vehicle:GetParent();

		if (IsValid(parentVehicle) and parentVehicle.cwItemTable) then
			if (!IsValid(parentVehicle:GetDriver())) then
				player:ExitVehicle();
			end;
		end;
	end;
	
	if (!isValidVehicle) then
		player.cwFuelAmt = nil;
	end;
end;

-- A function to scale damage by hit group.
function PLUGIN:PlayerScaleDamageByHitGroup(player, attacker, hitGroup, damageInfo, baseDamage)
	if (player:InVehicle()) then
		local damagePosition = damageInfo:GetDamagePosition();
		local vehicle = player:GetVehicle();
		
		if (vehicle.cwItemTable) then
			if (player:GetPos():Distance(damagePosition) > 96
			and !damageInfo:IsExplosionDamage()) then
				damageInfo:SetDamage(0);
			end;

			if (vehicle.cwIsLocked) then
				vehicle.cwIsLocked = false;
				vehicle:EmitSound("doors/door_latch3.wav");
				vehicle:Fire("unlock", "", 0);
			end;
			
			if (vehicle.cwPassengers) then
				timer.Simple(FrameTime() * 0.5, function()
					if (IsValid(vehicle) and IsValid(player)) then
						for k, v in pairs(vehicle.cwPassengers) do
							if (IsValid(v)) then
								local driver = v:GetDriver();

								if (IsValid(driver) and driver != player) then
									if (driver:GetPos():Distance(damagePosition) <= 96
									or damageInfo:IsExplosionDamage()) then
										damageInfo:SetDamage(baseDamage);

										driver:TakeDamageInfo(damageInfo);
									end;
								end;
							end;
						end;
					end;
				end);
			end;
		end;
	elseif ((attacker:IsPlayer() and attacker:InVehicle())
	or attacker:IsVehicle()) then
		if (baseDamage >= 50) then
			Clockwork.player:SetRagdollState(player, RAGDOLL_KNOCKEDOUT, 20);
			
			damageInfo:ScaleDamage(0.5);
		end;
	end;
end;

-- Called when a player's character has loaded.
function PLUGIN:PlayerCharacterLoaded(player)
	player.cwVehicleList = {};
end;

-- Called when a player attempts to pickup an entity with the physics gun.
function PLUGIN:PhysgunPickup(player, entity)
	if (entity:IsVehicle() and entity.cwItemTable and !player:IsUserGroup("operator") and !player:IsAdmin()) then
		return false;
	end;
end;

-- Called when a player's saved inventory should be added to.
function PLUGIN:PlayerAddToSavedInventory(player, character, Callback)
	if (player.cwVehicleList) then
		for k, v in pairs(player.cwVehicleList) do
			if (IsValid(k)) then Callback(v); end;
		end;
	end;
end;

-- Called when a player attempts to lock an entity.
function PLUGIN:PlayerCanLockEntity(player, entity)
	if (entity:IsVehicle() and entity.cwItemTable) then
		if (entity.cwItemTable("uniqueID") == "police_car") then
			local team = player:Team();
			
			if (team == CLASS_POLICE or team == CLASS_DISPENSER or team == CLASS_RESPONSE) then
				return true;
			end;
		end;
		
		return Clockwork.entity:GetOwner(entity) == player;
	end;
end;

-- Called when a player attempts to unlock an entity.
function PLUGIN:PlayerCanUnlockEntity(player, entity)
	if (entity:IsVehicle() and entity.cwItemTable) then
		if (entity.cwItemTable("uniqueID") == "police_car") then
			local team = player:Team();
			
			if (team == CLASS_POLICE or team == CLASS_DISPENSER or team == CLASS_RESPONSE) then
				return true;
			end;
		end;
		
		return Clockwork.entity:GetOwner(entity) == player;
	end;
end;

-- Called when a player's unlock info is needed.
function PLUGIN:PlayerGetUnlockInfo(player, entity)
	if (entity:IsVehicle() and entity.cwItemTable) then
		return {
			duration = Clockwork.config:Get("unlock_time"):Get(),
			Callback = function(player, entity)
				entity.cwIsLocked = false;
				entity:Fire("unlock", "", 0);
			end
		};
	end;
end;

-- Called when a player's lock info is needed.
function PLUGIN:PlayerGetLockInfo(player, entity)
	if (entity:IsVehicle() and entity.cwItemTable) then
		return {
			duration = Clockwork.config:Get("lock_time"):Get(),
			Callback = function(player, entity)
				entity.cwIsLocked = true;
				entity:Fire("lock", "", 0);
			end
		};
	end;
end;

-- Called when a player has disconnected.
function PLUGIN:PlayerCharacterUnloaded(player)
	if (player.cwVehicleList) then
		for k, v in pairs(player.cwVehicleList) do
			if (IsValid(k)) then
				k:Remove();
			end;
		end;
	end;
end;

-- Called when a player leaves a vehicle.
function PLUGIN:PlayerLeaveVehicle(player, vehicle)
	player.cwNextEnterVehicle = CurTime() + 2;
	player:SetVelocity(Vector(0, 0, 0));

	timer.Simple(FrameTime() * 2, function()
		if (IsValid(player) and IsValid(vehicle) and !player:InVehicle()) then
			self:MakeExitVehicle(player, vehicle);
		end;
	end);
end;

-- Called when a player attempts to enter a vehicle.
function PLUGIN:CanPlayerEnterVehicle(player, vehicle, role)
	if (player.cwNextEnterVehicle and player.cwNextEnterVehicle >= CurTime()) then
		return false;
	end;

	if (vehicle.cwIsLocked) then
		return false;
	end;
end;

-- Called when a player attempts to exit a vehicle.
function PLUGIN:CanExitVehicle(vehicle, player)
	if (player.cwNextExitVehicle and player.cwNextExitVehicle >= CurTime()) then
		return false;
	end;

	local parentVehicle = vehicle:GetParent();

	if (IsValid(parentVehicle) and parentVehicle.cwItemTable) then
		return false;
	end;

	if (vehicle.cwIsLocked) then
		return false;
	end;
end;

-- Called when a player presses a key.
function PLUGIN:KeyPress(player, key)
	if (player:InVehicle()) then
		if (key == IN_USE) then
			local vehicle = player:GetVehicle();
			local parentVehicle = vehicle:GetParent();

			if (IsValid(parentVehicle) and parentVehicle.cwItemTable) then
				if (!parentVehicle.cwIsLocked) then
					player:ExitVehicle();
				end;
			end;
		end;
	end;
end;

-- Called when a player uses an entity.
function PLUGIN:PlayerUse(player, entity, testing)
	local curTime = CurTime();

	if (!entity:IsVehicle()) then return; end;

	if (player:InVehicle()) then
		if (player.cwNextExitVehicle and player.cwNextExitVehicle >= curTime) then
			return false;
		else
			local parentVehicle = player:GetVehicle():GetParent();

			if (IsValid(parentVehicle) and parentVehicle.cwItemTable) then
				return false;
			else
				return;
			end;
		end;
	end;

	if (!entity.cwIsLocked and entity.cwItemTable and player:KeyDown(IN_USE)) then
		local position = player:GetEyeTraceNoCursor().HitPos;
		local validSeat = nil;
		
		if (entity.cwPassengers and IsValid(entity:GetDriver())) then
			for k, v in pairs(entity.cwPassengers) do
				if (IsValid(v) and v:IsVehicle() and !IsValid(v:GetDriver())) then
					local distance = v:GetPos():Distance(position);
					
					if (!validSeat or distance < validSeat[1]) then
						validSeat = {distance, v};
					end;
				end;
			end;
			
			if (validSeat and IsValid(validSeat[2])) then
				player.cwNextExitVehicle = curTime + 2;

				validSeat[2]:Fire("unlock", "", 0);
					timer.Simple(FrameTime() * 0.5, function()
						if (IsValid(player) and IsValid(validSeat[2])) then
							player:EnterVehicle(validSeat[2]);
						end;
					end);
				validSeat[2]:Fire("lock", "", 1);
			end;

			return false;
		end;
	end;

	if (player:GetSharedVar("IsTied") != 0) then
		return false;
	end;
end;