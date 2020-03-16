--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PLUGIN = PLUGIN;

-- Called when a player's character data should be saved.
function PLUGIN:PlayerSaveCharacterData(player, data)
	if (player.vehicles) then
		for k, v in pairs(player.vehicles) do
			if ( IsValid(k) ) then
				if ( data[v.uniqueID] ) then
					data[v.uniqueID][1] = math.Round(k.Fuel);
					
					if (k.PhysDesc != v.vehiclePhysDesc) then
						data[v.uniqueID][3] = k.PhysDesc;
					end;
				end;
			end;
		end;
	end;
end;

function PLUGIN:PlayerRestoreCharacterData(player, data)
	for k, v in pairs( openAura.item:GetAll() ) do
		if (v.base == "vehicle_base") then
			data[v.uniqueID] = data[v.uniqueID] or {100, nil, ""};
		end;
	end;
end;

-- Called when a player's class has been set.
function PLUGIN:PlayerClassSet(player, newClass, oldClass, noRespawn, addDelay, noModelChange)
	if (newClass.index == CLASS_POLICE) then
		if ( !self:DoesPlayerHavePoliceCar(player) ) then
			if ( self:CanPlayerHavePoliceCar(player) ) then
				player:UpdateInventory("police_car", 1, true);
				
				for k, v in ipairs( _player.GetAll() ) do
					local team = v:Team();
					
					if (team == CLASS_POLICE or team == CLASS_DISPENSER or team == CLASS_RESPONSE) then
						openAura.player:Notify(v, player:Name().." has been given a police car to share with other cops.");
					end;
				end;
			end;
		end;
	else
		player:UpdateInventory("police_car", -1, true);
		
		self:PlayerTakePoliceCar(player);
		
		for k, v in ipairs( _team.GetPlayers(CLASS_POLICE) ) do
			if ( v:HasInitialized() and !self:DoesPlayerHavePoliceCar(v) ) then
				if ( self:CanPlayerHavePoliceCar(v) ) then
					v:UpdateInventory("police_car", 1, true);
					
					for k2, v2 in ipairs( _player.GetAll() ) do
						local team = v2:Team();
						
						if (team == CLASS_POLICE or team == CLASS_DISPENSER or team == CLASS_RESPONSE) then
							openAura.player:Notify(v2, v:Name().." has been given a police car to share with other cops.");
						end;
					end;
				end;
			end;
		end;
	end;
end;

-- Called when a player's shared variables should be set.
function PLUGIN:PlayerSetSharedVars(player, curTime)
	if (player.fuel) then
		player:SetSharedVar( "fuel", math.Round(player.fuel) );
	else
		player:SetSharedVar("fuel", 100);
	end;
end;

-- Called at an interval while a player is connected.
function PLUGIN:PlayerThink(player, curTime, infoTable)
	local isValidVehicle = false;
	
	if ( player:InVehicle() ) then
		local vehicle = player:GetVehicle();
		
		if (IsValid(vehicle) and vehicle.ItemTable) then
			local uniqueID = vehicle.ItemTable.uniqueID;
			local vehicleData = player:GetCharacterData(uniqueID);

			if (vehicleData) then
				local velocity = vehicle:GetVelocity():Length();
				
				if (velocity > 0) then
					vehicle.Fuel = math.Clamp(vehicle.Fuel - (velocity / 48000), 0, 100);
				end;

				if (vehicle.Fuel == 0) then
					local physicsObject = vehicle:GetPhysicsObject();

					if ( IsValid(physicsObject) ) then
						physicsObject:SetVelocity(physicsObject:GetVelocity() * -1);
					end;
				end;

				player.fuel = vehicle.Fuel;
				isValidVehicle = true;
			end;
		end;
		
		local parentVehicle = vehicle:GetParent();

		if (IsValid(parentVehicle) and parentVehicle.ItemTable) then
			if ( !IsValid( parentVehicle:GetDriver() ) ) then
				player:ExitVehicle();
			end;
		end;
	end;
	
	if (!isValidVehicle) then
		player.fuel = nil;
	end;
end;

-- A function to scale damage by hit group.
function PLUGIN:PlayerScaleDamageByHitGroup(player, attacker, hitGroup, damageInfo, baseDamage)
	if ( player:InVehicle() ) then
		local damagePosition = damageInfo:GetDamagePosition();
		local vehicle = player:GetVehicle();
		
		if (vehicle.ItemTable) then
			if ( player:GetPos():Distance(damagePosition) > 96
			and !damageInfo:IsExplosionDamage() ) then
				damageInfo:SetDamage(0);
			end;

			if (vehicle.IsLocked) then
				vehicle.IsLocked = false;
				vehicle:EmitSound("doors/door_latch3.wav");
				vehicle:Fire("unlock", "", 0);
			end;
			
			if (vehicle.Passengers) then
				timer.Simple(FrameTime() * 0.5, function()
					if ( IsValid(vehicle) and IsValid(player) ) then
						for k, v in pairs(vehicle.Passengers) do
							if ( IsValid(v) ) then
								local driver = v:GetDriver();

								if (IsValid(driver) and driver != player) then
									if ( driver:GetPos():Distance(damagePosition) <= 96
									or damageInfo:IsExplosionDamage() ) then
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
	elseif ( ( attacker:IsPlayer() and attacker:InVehicle() )
	or attacker:IsVehicle() ) then
		if (baseDamage >= 50) then
			openAura.player:SetRagdollState(player, RAGDOLL_KNOCKEDOUT, 20);
			
			damageInfo:ScaleDamage(0.5);
		end;
	end;
end;

-- Called when a player's character has loaded.
function PLUGIN:PlayerCharacterLoaded(player)
	player.vehicles = {};
end;

-- Called when a player attempts to pickup an entity with the physics gun.
function PLUGIN:PhysgunPickup(player, entity)
	if ( entity:IsVehicle() and entity.ItemTable and !player:IsUserGroup("operator") and !player:IsAdmin() ) then
		return false;
	end;
end;

-- Called when a player's inventory string is needed.
function PLUGIN:PlayerGetInventoryString(player, character, inventory)
	if (player.vehicles) then
		for k, v in pairs(player.vehicles) do
			if ( IsValid(k) ) then
				if ( inventory[v.uniqueID] ) then
					inventory[v.uniqueID] = inventory[v.uniqueID] + 1;
				else
					inventory[v.uniqueID] = 1;
				end;
			end;
		end;
	end;
end;

-- Called when a player attempts to lock an entity.
function PLUGIN:PlayerCanLockEntity(player, entity)
	if (entity:IsVehicle() and entity.ItemTable) then
		if (entity.ItemTable.uniqueID == "police_car") then
			local team = player:Team();
			
			if (team == CLASS_POLICE or team == CLASS_DISPENSER or team == CLASS_RESPONSE) then
				return true;
			end;
		end;
		
		return openAura.entity:GetOwner(entity) == player;
	end;
end;

-- Called when a player attempts to unlock an entity.
function PLUGIN:PlayerCanUnlockEntity(player, entity)
	if (entity:IsVehicle() and entity.ItemTable) then
		if (entity.ItemTable.uniqueID == "police_car") then
			local team = player:Team();
			
			if (team == CLASS_POLICE or team == CLASS_DISPENSER or team == CLASS_RESPONSE) then
				return true;
			end;
		end;
		
		return openAura.entity:GetOwner(entity) == player;
	end;
end;

-- Called when a player's unlock info is needed.
function PLUGIN:PlayerGetUnlockInfo(player, entity)
	if (entity:IsVehicle() and entity.ItemTable) then
		return {
			duration = openAura.config:Get("unlock_time"):Get(),
			Callback = function(player, entity)
				entity.IsLocked = false;
				entity:Fire("unlock", "", 0);
			end
		};
	end;
end;

-- Called when a player's lock info is needed.
function PLUGIN:PlayerGetLockInfo(player, entity)
	if (entity:IsVehicle() and entity.ItemTable) then
		return {
			duration = openAura.config:Get("lock_time"):Get(),
			Callback = function(player, entity)
				entity.IsLocked = true;
				entity:Fire("lock", "", 0);
			end
		};
	end;
end;

-- Called when a player has disconnected.
function PLUGIN:PlayerCharacterUnloaded(player)
	if (player.vehicles) then
		for k, v in pairs(player.vehicles) do
			if ( IsValid(k) ) then
				k:Remove();
			end;
		end;
	end;
end;

-- Called when a player leaves a vehicle.
function PLUGIN:PlayerLeaveVehicle(player, vehicle)
	player.nextEnterVehicle = CurTime() + 2;
	player:SetVelocity( Vector(0, 0, 0) );

	timer.Simple(FrameTime() * 2, function()
		if ( IsValid(player) and IsValid(vehicle) and !player:InVehicle() ) then
			self:MakeExitVehicle(player, vehicle);
		end;
	end);
end;

-- Called when a player attempts to enter a vehicle.
function PLUGIN:CanPlayerEnterVehicle(player, vehicle, role)
	if ( player.nextEnterVehicle and player.nextEnterVehicle >= CurTime() ) then
		return false;
	end;

	if (vehicle.IsLocked) then
		return false;
	end;
end;

-- Called when a player attempts to exit a vehicle.
function PLUGIN:CanExitVehicle(vehicle, player)
	if ( player.nextExitVehicle and player.nextExitVehicle >= CurTime() ) then
		return false;
	end;

	local parentVehicle = vehicle:GetParent();

	if (IsValid(parentVehicle) and parentVehicle.ItemTable) then
		return false;
	end;

	if (vehicle.IsLocked) then
		return false;
	end;
end;

-- Called when a player presses a key.
function PLUGIN:KeyPress(player, key)
	if ( player:InVehicle() ) then
		if (key == IN_USE) then
			local vehicle = player:GetVehicle();
			local parentVehicle = vehicle:GetParent();

			if (IsValid(parentVehicle) and parentVehicle.ItemTable) then
				if (!parentVehicle.IsLocked) then
					player:ExitVehicle();
				end;
			end;
		end;
	end;
end;

-- Called when a player uses an entity.
function PLUGIN:PlayerUse(player, entity, testing)
	local curTime = CurTime();

	if ( !entity:IsVehicle() ) then
		return;
	end;

	if ( player:InVehicle() ) then
		if (player.nextExitVehicle and player.nextExitVehicle >= curTime) then
			return false;
		else
			local parentVehicle = player:GetVehicle():GetParent();

			if (IsValid(parentVehicle) and parentVehicle.ItemTable) then
				return false;
			else
				return;
			end;
		end;
	end;

	if ( !entity.IsLocked and entity.ItemTable and player:KeyDown(IN_USE) ) then
		local position = player:GetEyeTraceNoCursor().HitPos;
		local validSeat = nil;
		
		if ( entity.Passengers and IsValid( entity:GetDriver() ) ) then
			for k, v in pairs(entity.Passengers) do
				if ( IsValid(v) and v:IsVehicle() and !IsValid( v:GetDriver() ) ) then
					local distance = v:GetPos():Distance(position);
					
					if ( !validSeat or distance < validSeat[1] ) then
						validSeat = {distance, v};
					end;
				end;
			end;
			
			if ( validSeat and IsValid( validSeat[2] ) ) then
				player.nextExitVehicle = curTime + 2;

				validSeat[2]:Fire("unlock", "", 0);
					timer.Simple(FrameTime() * 0.5, function()
						if ( IsValid(player) and IsValid( validSeat[2] ) ) then
							player:EnterVehicle( validSeat[2] );
						end;
					end);
				validSeat[2]:Fire("lock", "", 1);
			end;

			return false;
		end;
	end;

	if (player:GetSharedVar("tied") != 0) then
		return false;
	end;
end;