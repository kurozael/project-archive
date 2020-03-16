--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PLUGIN = PLUGIN;

openAura:IncludePrefixed("sh_auto.lua");

resource.AddFile("scripts/sounds/game_sounds_vehiclepack.txt");
resource.AddFile("sound/vehicles/honk.wav");
resource.AddFile("sound/police_siren.wav");
resource.AddFile("models/tacoma2.mdl");

openAura.hint:Add("Horn", "Some vehicles have a horn, if it does you can honk it by pressing 'reload'.");
openAura.hint:Add("Vehicle", "Set the physical description of your vehicle by using the command $command_prefix$vehiclephysdesc.");

for k, v in pairs( _file.Find("../materials/models/props_vehicles/car002a_01.*") ) do
	resource.AddFile("materials/models/props_vehicles/"..v);
end;

for k, v in pairs( _file.Find("../materials/models/props/de_tides/truck001c_01.*") ) do
	resource.AddFile("materials/models/props/de_tides/"..v);
end;

for k, v in pairs( _file.Find("../materials/models/props/de_tides/trucktires.*") ) do
	resource.AddFile("materials/models/props/de_tides/"..v);
end;

for k, v in pairs( _file.Find("../materials/models/ill_hanger/vehicles/*.*") ) do
	resource.AddFile("materials/models/ill_hanger/vehicles/"..v);
end;

for k, v in pairs( _file.Find("../materials/models/copcar/*.*") ) do
	resource.AddFile("materials/models/copcar/"..v);
end;

for k, v in pairs( _file.Find("../sound/vehicles/truck/*.*") ) do
	resource.AddFile("sound/vehicles/truck/"..v);
end;

for k, v in pairs( _file.Find("../sound/vehicles/enzo/*.*") ) do
	resource.AddFile("sound/vehicles/enzo/"..v);
end;

for k, v in pairs( _file.Find("../sound/vehicles/cf_mech*.*") ) do
	resource.AddFile("sound/vehicles/"..v);
end;

for k, v in pairs( _file.Find("../sound/vehicles/digger_*.*") ) do
	resource.AddFile("sound/vehicles/"..v);
end;

for k, v in pairs( _file.Find("../models/tideslkw.*") ) do
	resource.AddFile("models/"..v);
end;

for k, v in pairs( _file.Find("../materials/corvette/*.*") ) do
	resource.AddFile("materials/corvette/"..v);
end;

for k, v in pairs( _file.Find("../materials/golf/*.*") ) do
	resource.AddFile("materials/golf/"..v);
end;

for k, v in pairs( _file.Find("../models/corvette/*.*") ) do
	resource.AddFile("models/corvette/"..v);
end;

for k, v in pairs( _file.Find("../models/golf/*.*") ) do
	resource.AddFile("models/golf/"..v);
end;

for k, v in pairs( _file.Find("../models/copcar.*") ) do
	resource.AddFile("models/"..v);
end;

for k, v in pairs( _file.Find("../models/trabbi.*") ) do
	resource.AddFile("models/"..v);
end;

for k, v in pairs( _file.Find("../scripts/vehicles/*.*") ) do
	resource.AddFile("scripts/vehicles/"..v);
end;

openAura:HookDataStream("VehiclePhysDesc", function(player, data)
	if (type(data) == "table" and player.vehiclePhysDesc and data[1] == player.vehiclePhysDesc) then
		local text = data[2];
		
		if (string.len(text) < 8) then
			openAura.player:Notify(player, "You did not specify enough text!");
			
			return;
		end;
		
		data[1].PhysDesc = openAura:ModifyPhysDesc(text);
		data[1]:SetNetworkedString("physDesc", data[1].PhysDesc);
	end;
end);

openAura:HookDataStream("ManageCar", function(player, data)
	local vehicle = player:GetVehicle();

	if ( IsValid(vehicle) ) then
		local parentVehicle = vehicle:GetParent();
		
		if ( !IsValid(parentVehicle) ) then
			if (vehicle.ItemTable) then
				parentVehicle = vehicle;
			end;
		end;
		
		if (player:InVehicle() and IsValid(parentVehicle) and parentVehicle.ItemTable) then
			if (parentVehicle:GetDriver() == player) then
				if (data == "unlock") then
					parentVehicle.IsLocked = false;
					parentVehicle:EmitSound("doors/door_latch3.wav");
					parentVehicle:Fire("unlock", "", 0);
				elseif (data == "lock") then
					parentVehicle.IsLocked = true;
					parentVehicle:EmitSound("doors/door_latch3.wav");
					parentVehicle:Fire("lock", "", 0);
				elseif (data == "horn") then
					if (parentVehicle.ItemTable.PlayHornSound) then
						parentVehicle.ItemTable:PlayHornSound(player, parentVehicle);
					elseif (parentVehicle.ItemTable.hornSound) then
						parentVehicle:EmitSound(parentVehicle.ItemTable.hornSound);
					end;
				end;
			end;
		end;
	end;
end);

-- A function to get whether a player does have a police car.
function PLUGIN:DoesPlayerHavePoliceCar(player)
	if ( player:HasItem("police_car") ) then
		return true;
	end;
	
	if (player.vehicles) then
		for k, v in pairs(player.vehicles) do
			if (IsValid(k) and v.uniqueID == "police_car") then
				return true;
			end;
		end;
	end;
end;

-- A function to take a player's police car.
function PLUGIN:PlayerTakePoliceCar(player)
	if (player.vehicles) then
		for k, v in pairs(player.vehicles) do
			if (v.uniqueID == "police_car") then
				if ( IsValid(k) ) then
					k:Remove();
				end;
				
				player.vehicles[k] = nil;
			end;
		end;
	end;
end;

-- A function to get whether a player can have a police car.
function PLUGIN:CanPlayerHavePoliceCar(player)
	local hasCar = 0;
	local amount = 0;
	
	for k, v in ipairs( _team.GetPlayers(CLASS_POLICE) ) do
		if ( v:HasInitialized() ) then
			if ( self:DoesPlayerHavePoliceCar(v) ) then
				hasCar = hasCar + 1;
			end;
			
			amount = amount + 1;
		end;
	end;
	
	if ( hasCar < (amount / 3) ) then
		return true;
	else
		return false;
	end;
end;

-- A function to get a vehicle exit for a player.
function PLUGIN:GetVehicleExit(player, vehicle)
	local available = {};
	local closest = {};
	
	if (vehicle.ItemTable and vehicle.ItemTable.customExits) then
		for k, v in ipairs(vehicle.ItemTable.customExits) do
			local position = vehicle:LocalToWorld(v);
			local entities = ents.FindInSphere(position, 1);
			local unsafe = nil;
			
			for k2, v2 in ipairs(entities) do
				if ( player != v2 and v2:IsPlayer() ) then
					unsafe = true;
					
					break;
				end;
			end;
			
			if (util.IsInWorld(position) and !unsafe) then
				available[#available + 1] = position;
			end;
		end;
	end;
	
	for k, v in ipairs(self.normalExits) do
		local attachment = vehicle:GetAttachment( vehicle:LookupAttachment(v) );
		
		if (attachment) then
			local position = attachment.Pos;
			local entities = ents.FindInSphere(position, 1);
			local unsafe = nil;
			
			for k2, v2 in ipairs(entities) do
				if ( player != v2 and v2:IsPlayer() ) then
					unsafe = true;
					
					break;
				end;
			end;
			
			if ( !unsafe and util.IsInWorld(position) ) then
				available[#available + 1] = position;
			end;
		end;
	end;
	
	for k, v in ipairs(available) do
		local distance = player:GetPos():Distance(v);
		
		if ( !closest[1] or distance < closest[1] ) then
			closest[1] = distance;
			closest[2] = v;
		end;
	end;

	if ( closest[2] ) then
		openAura.player:SetSafePosition( player, closest[2] );
	end;
end;

-- A function to make a player exit a vehicle.
function PLUGIN:MakeExitVehicle(player, vehicle)
	player:SetVelocity( Vector(0, 0, 0) );

	if ( !player:InVehicle() ) then
		local parentVehicle = vehicle:GetParent();
		
		if ( IsValid(parentVehicle) ) then
			self:GetVehicleExit(player, parentVehicle);
		else
			self:GetVehicleExit(player, vehicle);
		end;
	end;
end;

-- A function to spawn a vehicle.
function PLUGIN:SpawnVehicle(player, itemTable)
	if ( table.HasValue(player.vehicles, itemTable) ) then
		openAura.player:Notify(player, "You have already spawned a "..itemTable.name..", go and look for it!");

		return false;
	else
		local eyeTrace = player:GetEyeTraceNoCursor();

		if (player:GetPos():Distance(eyeTrace.HitPos) <= 512) then
			local trace = util.QuickTrace(eyeTrace.HitPos, eyeTrace.HitNormal * 100000);

			if (!trace.HitSky) then
				openAura.player:Notify(player, "You can only spawn a vehicle outside!");

				return false;
			end;

			local vehicleEntity, fault = self:MakeVehicle( player, itemTable, eyeTrace.HitPos + Vector(0, 0, 32), Angle(0, player:GetAngles().yaw + 180, 0) );

			if ( !IsValid(vehicleEntity) ) then
				if (fault) then
					openAura.player:Notify(player, fault);
				end;

				return false;
			end;

			if (itemTable.skin) then
				vehicleEntity:SetSkin(itemTable.skin);
			end;

			vehicleEntity.m_tblToolsAllowed = {"remover"};
			
			-- Called when a player attempts to use a tool.
			function vehicleEntity:CanTool(player, trace, tool)
				return ( mode == "remover" and player:IsAdmin() );
			end;

			openAura.player:GiveProperty(player, vehicleEntity, true);

			player.vehicles[vehicleEntity] = itemTable;

			return vehicleEntity;
		else
			openAura.player:Notify(player, "You cannot spawn a vehicle that far away!");

			return false;
		end;
	end;
end;

-- A function to make a vehicle.
function PLUGIN:MakeVehicle(player, itemTable, position, angles)
	local vehicleEntity = ents.Create(itemTable.class);

	vehicleEntity:SetModel(itemTable.model);

	if (itemTable.keyValues) then
		for k, v in pairs(itemTable.keyValues) do
			vehicleEntity:SetKeyValue(k, v);
		end		
	end;

	vehicleEntity:SetAngles(angles);
	vehicleEntity:SetPos(position);
	vehicleEntity:Spawn();

	vehicleEntity:Activate();
	vehicleEntity:SetUseType(SIMPLE_USE)
	vehicleEntity:SetNetworkedInt("index", itemTable.index);

	local physicsObject = vehicleEntity:GetPhysicsObject();

	if ( !IsValid(physicsObject) ) then
		return false, "The physics object for this vehicle is not valid!";
	end

	if ( physicsObject:IsPenetrating() ) then
		vehicleEntity:Remove();

		return false, "A vehicle cannot be spawned at this location!";
	end

	vehicleEntity.ItemTable = itemTable;
	vehicleEntity.VehicleName = itemTable.name;
	vehicleEntity.ClassOverride = itemTable.class;

	local localPosition = vehicleEntity:GetPos();
	local localAngles = vehicleEntity:GetAngles();
	local vehicleData = player:GetCharacterData(itemTable.uniqueID);

	if (itemTable.passengers) then		
		local seatName = itemTable.seatType;
		local seatData = list.Get( "Vehicles" )[seatName];

		for k, v in pairs(itemTable.passengers) do
			local seatPosition = localPosition + (localAngles:Forward() * v.position.x) + (localAngles:Right() * v.position.y) + (localAngles:Up() * v.position.z);
			local seatEntity = ents.Create("prop_vehicle_prisoner_pod");

			seatEntity:SetKeyValue("vehiclescript", "scripts/vehicles/prisoner_pod.txt");
			seatEntity:SetAngles(localAngles + v.angles);
			seatEntity:SetModel(seatData.Model);
			seatEntity:SetPos(seatPosition);
			seatEntity:Spawn();

			seatEntity:Activate();
			seatEntity:Fire("lock", "", 0);

			seatEntity:SetCollisionGroup(COLLISION_GROUP_WORLD);
			seatEntity:SetParent(vehicleEntity);
			
			if (itemTable.useLocalPositioning) then
				seatEntity:SetLocalPos(v.position);
				seatEntity:SetLocalAngles(v.angles);
			end;

			if (itemTable.hideSeats) then
				seatEntity:SetColor(255, 255, 255, 0);
			end;

			if (seatData.Members) then
				table.Merge(seatEntity, seatData.Members);
			end;

			if (seatData.KeyValues) then
				for k2, v2 in pairs(seatData.KeyValues) do
					seatEntity:SetKeyValue(k2, v2);
				end;
			end;

			seatEntity:DeleteOnRemove(vehicleEntity);
			seatEntity.ClassOverride = "prop_vehicle_prisoner_pod";
			seatEntity.VehicleTable = seatData
			seatEntity.VehicleName = "Jeep Seat";

			if (!vehicleEntity.Passengers) then
				vehicleEntity.Passengers = {};
			end;

			vehicleEntity.Passengers[k] = seatEntity;
		end;
	end;

	if (vehicleData) then
		if (vehicleData[3] and vehicleData[3] != "") then
			vehicleEntity.PhysDesc = vehicleData[3];
		end;
		
		vehicleEntity.Fuel = vehicleData[1];
	end;

	if (vehicleEntity.PhysDesc) then
		vehicleEntity:SetNetworkedString("physDesc", vehicleEntity.PhysDesc);
	end;

	return vehicleEntity;
end;