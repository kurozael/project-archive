--[[
Name: "sh_entity.lua".
Product: "kuroScript".
--]]

kuroScript.entity = {};

-- A function to check if an entity is a door.
function kuroScript.entity.IsDoor(entity)
	local class = entity:GetClass();
	local model = entity:GetModel();
	
	-- Check if a statement is true.
	if (class and model) then
		class = string.lower(class);
		model = string.lower(model);
		
		-- Check if a statement is true.
		if ( class == "func_door" or class == "func_door_rotating" or class == "prop_door_rotating"
		or ( class == "prop_dynamic" and string.find(model, "door") ) ) then
			if (model != "models/props_interiors/refrigeratordoor01a.mdl") then
				return true;
			end;
		end;
	end;
end;

-- A function to get whether an entity is decaying.
function kuroScript.entity.IsDecaying(entity)
	return entity:GetNetworkedBool("ks_Decaying");
end;

-- A function to check if an entity is in a box.
function kuroScript.entity.IsInBox(entity, minimum, maximum)
	local position = entity:GetPos();
	
	-- Check if a statement is true.
	if ( ( position.x >= math.min(minimum.x, maximum.x) and position.x <= math.max(minimum.x, maximum.x) )
	and ( position.y >= math.min(minimum.y, maximum.y) and position.y <= math.max(minimum.y, maximum.y) )
	and ( position.z >= math.min(minimum.z, maximum.z) and position.z <= math.max(minimum.z, maximum.z) ) ) then
		return true;
	else
		return false;
	end;
end;

-- A function to get a ragdoll entity's pelvis position.
function kuroScript.entity.GetPelvisPosition(entity)
	local position = entity:GetPos();
	local bone = entity:LookupBone("ValveBiped.Bip01_Pelvis");

	-- Check if a statement is true.
	if (bone) then
		local bonePosition = entity:GetBonePosition(bone);
		
		-- Check if a statement is true.
		if (bonePosition) then
			position = bonePosition;
		end;
	end;
	
	-- Return the position.
	return position;
end;

-- A function to get whether an entity can see a position.
function kuroScript.entity.CanSeePosition(entity, position, allowance, ignoreEnts)
	local trace = {};
	
	-- Set some information.
	trace.mask = CONTENTS_SOLID + CONTENTS_MOVEABLE + CONTENTS_OPAQUE + CONTENTS_DEBRIS + CONTENTS_HITBOX + CONTENTS_MONSTER;
	trace.start = entity:LocalToWorld( entity:OBBCenter() );
	trace.endpos = position;
	trace.filter = {entity};
	
	-- Check if a statement is true.
	if (ignoreEnts) then
		if (type(ignoreEnts) == "table") then
			table.Add(trace.filter, ignoreEnts);
		else
			table.Add( trace.filter, ents.GetAll() );
		end;
	end;
	
	-- Set some information.
	trace = util.TraceLine(trace);
	
	-- Check if a statement is true.
	if ( trace.Fraction >= (allowance or 0.75) ) then
		return true;
	end;
end;

-- A function to get whether an entity can see an NPC.
function kuroScript.entity.CanSeeNPC(entity, target, allowance, ignoreEnts)
	local trace = {};
	
	-- Set some information.
	trace.mask = CONTENTS_SOLID + CONTENTS_MOVEABLE + CONTENTS_OPAQUE + CONTENTS_DEBRIS + CONTENTS_HITBOX + CONTENTS_MONSTER;
	trace.start = entity:LocalToWorld( entity:OBBCenter() );
	trace.endpos = target:GetShootPos();
	trace.filter = {entity, target};
	
	-- Check if a statement is true.
	if (ignoreEnts) then
		if (type(ignoreEnts) == "table") then
			table.Add(trace.filter, ignoreEnts);
		else
			table.Add( trace.filter, ents.GetAll() );
		end;
	end;
	
	-- Set some information.
	trace = util.TraceLine(trace);
	
	-- Check if a statement is true.
	if ( trace.Fraction >= (allowance or 0.75) ) then
		return true;
	end;
end;

-- A function to get whether an entity can see a player.
function kuroScript.entity.CanSeePlayer(entity, target, allowance, ignoreEnts)
	if (target:GetEyeTraceNoCursor().Entity == entity) then
		return true;
	else
		local trace = {};
		
		-- Set some information.
		trace.mask = CONTENTS_SOLID + CONTENTS_MOVEABLE + CONTENTS_OPAQUE + CONTENTS_DEBRIS + CONTENTS_HITBOX + CONTENTS_MONSTER;
		trace.start = entity:LocalToWorld( entity:OBBCenter() );
		trace.endpos = target:GetShootPos();
		trace.filter = {entity, target};
		
		-- Check if a statement is true.
		if (ignoreEnts) then
			if (type(ignoreEnts) == "table") then
				table.Add(trace.filter, ignoreEnts);
			else
				table.Add( trace.filter, ents.GetAll() );
			end;
		end;
		
		-- Set some information.
		trace = util.TraceLine(trace);
		
		-- Check if a statement is true.
		if ( trace.Fraction >= (allowance or 0.75) ) then
			return true;
		end;
	end;
end;

-- A function to get whether an entity can see an entity.
function kuroScript.entity.CanSeeEntity(entity, target, allowance, ignoreEnts)
	local trace = {};
	
	-- Set some information.
	trace.mask = CONTENTS_SOLID + CONTENTS_MOVEABLE + CONTENTS_OPAQUE + CONTENTS_DEBRIS + CONTENTS_HITBOX + CONTENTS_MONSTER;
	trace.start = entity:LocalToWorld( entity:OBBCenter() );
	trace.endpos = target:LocalToWorld( target:OBBCenter() );
	trace.filter = {entity, target};
	
	-- Check if a statement is true.
	if (ignoreEnts) then
		if (type(ignoreEnts) == "table") then
			table.Add(trace.filter, ignoreEnts);
		else
			table.Add( trace.filter, ents.GetAll() );
		end;
	end;
	
	-- Set some information.
	trace = util.TraceLine(trace);
	
	-- Check if a statement is true.
	if ( trace.Fraction >= (allowance or 0.75) ) then
		return true;
	end;
end;

-- A function to get whether a door is unownable.
function kuroScript.entity.IsDoorUnownable(entity)
	return entity:GetNetworkedBool("ks_Unownable");
end;

-- A function to get whether a door is hidden.
function kuroScript.entity.IsDoorHidden(entity)
	return kuroScript.entity.IsDoorUnownable(entity) and kuroScript.entity.GetDoorName(entity) == "hidden";
end;

-- A function to get a door's name.
function kuroScript.entity.GetDoorName(entity)
	return entity:GetNetworkedString("ks_Name");
end;

-- A function to get a door's text.
function kuroScript.entity.GetDoorText(entity)
	return entity:GetNetworkedString("ks_Text");
end;

-- A function to get whether an entity is a player ragdoll.
function kuroScript.entity.IsPlayerRagdoll(entity)
	local player = entity:GetNetworkedEntity("ks_Player");
	
	-- Check if a statement is true.
	if ( ValidEntity(player) ) then
		if (player:GetRagdollEntity() == entity) then
			return true;
		end;
	end;
end;

-- A function to get an entity's shared variable.
function kuroScript.entity.GetSharedVar(entity, key)
	if ( ValidEntity(entity) ) then
		if (!NWTYPE_STRING) then
			return entity:GetNetworkedVar(key);
		else
			return entity[key];
		end;
	end;
end;

-- A function to get an entity's player.
function kuroScript.entity.GetPlayer(entity)
	local player = entity:GetNetworkedEntity("ks_Player");
	
	-- Check if a statement is true.
	if ( ValidEntity(player) ) then
		return player;
	elseif ( entity:IsPlayer() ) then
		return entity;
	end;
end;

-- A function to get whether an entity is interactable.
function kuroScript.entity.IsInteractable(entity)
	local class = entity:GetClass();
	
	-- Check if a statement is true.
	if ( string.find(class, "prop_") ) then
		if ( entity:HasSpawnFlags(SF_PHYSPROP_MOTIONDISABLED) or entity:HasSpawnFlags(SF_PHYSPROP_PREVENT_PICKUP) ) then
			return false;
		end;
	end;
	
	-- Check if a statement is true.
	if ( entity:IsNPC() or entity:IsPlayer() or string.find(class, "prop_dynamic") ) then
		return false;
	end;
	
	-- Check if a statement is true.
	if ( class == "func_physbox" and entity:HasSpawnFlags(SF_PHYSBOX_MOTIONDISABLED) ) then
		return false;
	end
	
	-- Check if a statement is true.
	if ( class != "func_physbox" and string.find(class, "func_") ) then
		return false;
	end;
	
	-- Check if a statement is true.
	if ( kuroScript.entity.IsDoor(entity) ) then
		return false;
	end;
	
	-- Return true to break the function.
	return true;
end;

-- A function to get whether an entity is a physics entity.
function kuroScript.entity.IsPhysicsEntity(entity)
	local class = string.lower( entity:GetClass() );
	
	-- Check if a statement is true.
	if (class == "prop_physics_multiplayer" or class == "prop_physics") then
		return true;
	end;
end;

-- A function to get whether an entity is a pod.
function kuroScript.entity.IsPodEntity(entity)
	local entityModel = string.lower( entity:GetModel() );
	
	-- Check if a statement is true.
	if ( string.find(entityModel, "prisoner") ) then
		return true;
	end;
end;

-- A function to get whether an entity is a chair.
function kuroScript.entity.IsChairEntity(entity)
	local entityModel = string.lower( entity:GetModel() );
	
	-- Check if a statement is true.
	if ( string.find(entityModel, "chair") or string.find(entityModel, "seat") ) then
		return true;
	end;
end;

-- Check if a statement is true.
if (SERVER) then
	function kuroScript.entity.OpenDoor(entity, delay, unlock, sound, origin)
		if ( kuroScript.entity.IsDoor(entity) ) then
			if (unlock) then
				entity:Fire("Unlock", "", delay);
				
				-- Set some information.
				delay = delay + 0.025;
				
				-- Check if a statement is true.
				if (sound) then
					entity:EmitSound("physics/wood/wood_box_impact_hard3.wav");
				end;
			end;
			
			-- Check if a statement is true.
			if (entity:GetClass() == "prop_dynamic") then
				entity:Fire("SetAnimation", "open", delay);
				entity:Fire("SetAnimation", "close", delay + 5);
			elseif (origin and string.lower( entity:GetClass() ) == "prop_door_rotating") then
				local target = ents.Create("info_target");
				
				-- Set some information.
				target:SetName( tostring(target) );
				target:SetPos(origin);
				target:Spawn();
				
				-- Fire an input.
				entity:Fire("OpenAwayFrom", tostring(target), delay);
				
				-- Set some information.
				timer.Simple(delay + 1, function()
					if ( ValidEntity(target) ) then
						target:Remove();
					end;
				end);
			else
				entity:Fire("Open", "", delay);
			end;
		end;
	end;
	
	-- A function to get whether a door is unsellable.
	function kuroScript.entity.IsDoorUnsellable(door)
		return door._Unsellable;
	end;
	
	-- A function to set a door's parent.
	function kuroScript.entity.SetDoorParent(door, parent)
		local k, v;
		
		-- Check if a statement is true.
		if ( kuroScript.entity.IsDoor(door) ) then
			for k, v in pairs( kuroScript.entity.GetDoorChildren(door) ) do
				if ( ValidEntity(v) ) then
					kuroScript.entity.SetDoorParent(v, false);
				end;
			end;
			
			-- Check if a statement is true.
			if ( ValidEntity(door._DoorParent) ) then
				if (door._DoorParent._DoorChildren) then
					door._DoorParent._DoorChildren[door] = nil;
				end;
			end;
			
			-- Check if a statement is true.
			if ( kuroScript.entity.IsDoor(parent) ) then
				if (parent._DoorChildren) then
					parent._DoorChildren[door] = door;
				else
					parent._DoorChildren = { [door] = door };
				end;
				
				-- Set some information.
				door._DoorParent = parent;
			else
				door._DoorParent = nil;
			end;
		end;
	end;

	-- A function to get a door's parent.
	function kuroScript.entity.GetDoorParent(door)
		if ( ValidEntity(door._DoorParent) ) then
			return door._DoorParent;
		end;
	end;

	-- A function to get a door's children.
	function kuroScript.entity.GetDoorChildren(door)
		return door._DoorChildren or {};
	end;
	
	-- A function to set a shared variable for an entity.
	function kuroScript.entity.SetSharedVar(entity, key, value)
		if ( ValidEntity(entity) ) then
			if (!NWTYPE_STRING) then
				entity:SetNetworkedVar(key, value);
			else
				entity[key] = value;
			end;
		end;
	end;
	
	-- A function to set a door as unownable.
	function kuroScript.entity.SetDoorUnownable(entity, unownable)
		if ( kuroScript.entity.IsDoor(entity) ) then
			if (unownable) then
				entity:SetNetworkedBool("ks_Unownable", true);
				
				-- Check if a statement is true.
				if ( kuroScript.entity.GetOwner(entity) ) then
					kuroScript.player.TakeDoor(kuroScript.entity.GetOwner(entity), entity, true);
				elseif ( kuroScript.entity.HasOwner(entity) ) then
					kuroScript.entity.ClearProperty(entity);
				end;
			else
				entity:SetNetworkedBool("ks_Unownable", false);
			end;
		end;
	end;
	
	-- A function to set whether a door is hidden.
	function kuroScript.entity.SetDoorHidden(entity, hidden)
		if ( kuroScript.entity.IsDoor(entity) ) then
			if (hidden) then
				kuroScript.entity.SetDoorUnownable(entity, true);
				kuroScript.entity.SetDoorName(entity, true);
			else
				kuroScript.entity.SetDoorUnownable(entity, false);
				kuroScript.entity.SetDoorName(entity, false);
			end;
		end;
	end;
	
	-- A function to set a door's text.
	function kuroScript.entity.SetDoorText(entity, text)
		if ( kuroScript.entity.IsDoor(entity) ) then
			if (text) then
				entity:SetNetworkedString("ks_Text", text);
			else
				entity:SetNetworkedString("ks_Text", "");
			end;
		end;
	end;
	
	-- A function to set a door's name.
	function kuroScript.entity.SetDoorName(entity, name)
		if ( kuroScript.entity.IsDoor(entity) ) then
			if (name) then
				entity:SetNetworkedString("ks_Name", name);
			else
				entity:SetNetworkedString("ks_Name", "");
			end;
		end;
	end;
	
	-- A function to set an entity's chair animations.
	function kuroScript.entity.SetChairAnimations(entity)
		if (!entity.VehicleTable) then
			local targetClass = "prop_vehicle_prisoner_pod";
			
			-- Check if a statement is true.
			if (entity:GetClass() == targetClass) then
				local entityModel = string.lower( entity:GetModel() );
				
				-- Check if a statement is true.
				if (entityModel == "models/props_c17/furniturechair001a.mdl"
				or entityModel == "models/props_furniture/chair1.mdl") then
					entity:SetModel("models/nova/chair_wood01.mdl");
				elseif (entityModel == "models/props_c17/chair_office01a.mdl") then
					entity:SetModel("models/nova/chair_office01.mdl");
				elseif (entityModel == "models/props_combine/breenchair.mdl") then
					entity:SetModel("models/nova/chair_office02.mdl");
				elseif (entityModel == "models/props_interiors/furniture_chair03a.mdl"
				or entityModel == "models/props_wasteland/controlroom_chair001a.mdl") then
					entity:SetModel("models/nova/chair_plastic01.mdl");
				end;
				
				-- Check if a statement is true.
				if ( kuroScript.entity.IsChairEntity(entity) ) then
					local entityModel = string.lower( entity:GetModel() );
					local vehicles = list.Get("Vehicles");
					local k2, v2;
					local k, v;
					
					-- Loop through each value in a table.
					for k, v in pairs(vehicles) do
						local keyValues = v.KeyValues;
						local members = v.Members;
						local model = v.Model;
						local class = v.Class;
						
						-- Check if a statement is true.
						if (string.lower(class) == targetClass) then
							if (string.lower(model) == entityModel) then
								for k2, v2 in pairs(keyValues) do
									entity:SetKeyValue(k2, v2);
								end;
								
								-- Set some information.
								entity.VehicleTable = v;
								entity.ClassOverride = class;
								
								-- Merge the two tables.
								table.Merge(entity, members);
								
								-- Return true to break the function.
								return true;
							end;
						end;
					end;
				end;
			end;
		end;
	end;
	
	-- A function to set an entity's start angles.
	function kuroScript.entity.SetStartAngles(entity, angles)
		entity._StartAngles = angles;
	end;
	
	-- A function to get an entity's start angles.
	function kuroScript.entity.GetStartAngles(entity)
		return entity._StartAngles;
	end;
	
	-- A function to set an entity's start position.
	function kuroScript.entity.SetStartPosition(entity, position)
		entity._StartPosition = position;
	end;
	
	-- A function to get an entity's start position.
	function kuroScript.entity.GetStartPosition(entity)
		return entity._StartPosition;
	end;

	-- A function to set whether an entity is a map entity.
	function kuroScript.entity.SetMapEntity(entity, boolean)
		if (boolean) then
			kuroScript.frame.Entities[entity] = entity;
		else
			kuroScript.frame.Entities[entity] = nil;
		end;
	end;
	
	-- A function to get whether an entity is a map entity.
	function kuroScript.entity.IsMapEntity(entity)
		if ( kuroScript.frame.Entities[entity] ) then
			return true;
		end;
	end;
	
	-- A function to make an entity flush with the ground.
	function kuroScript.entity.MakeFlushToGround(entity, position, normal)
		entity:SetPos( position + ( entity:GetPos() - entity:NearestPoint( position - (normal * 512) ) ) );
	end;
	
	-- A function to make an entity disintegrate.
	function kuroScript.entity.Disintegrate(entity, delay, velocity, callback)
		if (velocity) then
			if (entity:GetClass() == "prop_ragdoll") then
				for i = 1, entity:GetPhysicsObjectCount() do
					local physicsObject = entity:GetPhysicsObjectNum(i);
					
					-- Check if a statement is true.
					if ( ValidEntity(physicsObject) ) then
						physicsObject:AddVelocity(velocity);
					end;
				end;
			elseif ( ValidEntity( entity:GetPhysicsObject() ) ) then
				entity:GetPhysicsObject():AddVelocity(velocity);
			end;
		end;
		
		-- Decay the entity.
		kuroScript.entity.Decay(entity, delay, callback);
		
		-- Check if a statement is true.
		if (velocity) then
			timer.Simple(math.min(1, delay / 2), function()
				if ( ValidEntity(entity) ) then
					entity:SetNotSolid(true);
					
					-- Check if a statement is true.
					if (entity:GetClass() == "prop_ragdoll") then
						for i = 1, entity:GetPhysicsObjectCount() do
							local physicsObject = entity:GetPhysicsObjectNum(i);
							
							-- Check if a statement is true.
							if ( ValidEntity(physicsObject) ) then
								physicsObject:EnableMotion(false);
							end;
						end;
					elseif ( ValidEntity( entity:GetPhysicsObject() ) ) then
						entity:GetPhysicsObject():EnableMotion(false);
					end;
				end;
			end);
		else
			entity:SetNotSolid(true);
			
			-- Check if a statement is true.
			if (entity:GetClass() == "prop_ragdoll") then
				for i = 1, entity:GetPhysicsObjectCount() do
					local physicsObject = entity:GetPhysicsObjectNum(i);
					
					-- Check if a statement is true.
					if ( ValidEntity(physicsObject) ) then
						physicsObject:EnableMotion(false);
					end;
				end;
			elseif ( ValidEntity( entity:GetPhysicsObject() ) ) then
				entity:GetPhysicsObject():EnableMotion(false);
			end;
		end;
		
		-- Set some information.
		local effectData = EffectData();
			effectData:SetEntity(entity);
		util.Effect("entity_remove", effectData, true, true);
	end;
	
	-- A function to set an entity's player.
	function kuroScript.entity.SetPlayer(entity, player)
		entity:SetNetworkedEntity("ks_Player", player);
	end;
	
	-- A function to make an entity decay.
	function kuroScript.entity.Decay(entity, seconds, callback)
		local r, g, b, a = entity:GetColor();
		local subtract = math.ceil(a / seconds);
		local index = entity:EntIndex();
		local alpha = a;
		
		-- Set some information.
		kuroScript.entity.SetPlayer(entity, NULL);
		
		-- Set some information.
		entity:SetNetworkedBool("ks_Decaying", true);
		
		-- Set some information.
		kuroScript.frame:CreateTimer("Decay: "..index, 1, 0, function()
			alpha = alpha - subtract;
			
			-- Check if a statement is true.
			if ( ValidEntity(entity) ) then
				local r, g, b, a = entity:GetColor();
				local decayed = math.Clamp(alpha, 0, 255);
				
				-- Check if a statement is true.
				if (a <= 0) then
					if (callback) then callback(); end;
					
					-- Set some information.
					kuroScript.frame:DestroyTimer("Decay: "..index); entity:Remove();
				else
					entity:SetColor(r, g, b, decayed);
				end;
			else
				kuroScript.frame:DestroyTimer("Decay: "..index);
			end;
		end);
	end;
	
	-- A function to create currency.
	function kuroScript.entity.CreateCurrency(player, currency, position, angles)
		local entity = ents.Create("ks_currency");
		
		-- Check if a statement is true.
		if (type(player) == "table") then
			if (player.key and player.uniqueID) then
				kuroScript.player.GivePropertyOffline(player.key, player.uniqueID, entity, true);
			end;
		elseif ( ValidEntity(player) ) then
			kuroScript.player.GiveProperty(player, entity);
		end;
		
		-- Check if a statement is true.
		if (!angles) then
			angles = Angle(0, 0, 0);
		end;
		
		-- Set some information.
		entity:SetPos(position);
		entity:SetAngles(angles);
		
		-- Spawn the entity.
		entity:Spawn();
		
		-- Check if a statement is true.
		if ( ValidEntity(entity) ) then
			entity:SetAmount( math.Round(currency) );
			
			-- Return the entity.
			return entity;
		end;
	end;
	
	-- A function to create contraband.
	function kuroScript.entity.CreateContraband(player, class, position, angles)
		local entity = ents.Create(class);
		
		-- Check if a statement is true.
		if (!angles) then
			angles = Angle(0, 0, 0);
		end;
		
		-- Check if a statement is true.
		if (type(player) == "table") then
			if (player.key and player.uniqueID) then
				kuroScript.player.GivePropertyOffline(player.key, player.uniqueID, entity, true);
			end;
		elseif ( ValidEntity(player) ) then
			kuroScript.player.GiveProperty(player, entity, true);
		end;
		
		-- Set some information.
		entity:SetAngles(angles);
		entity:SetPos(position);
		entity:Spawn();
		
		-- Return the entity.
		return entity;
	end;
	
	-- A function to create a shipment.
	function kuroScript.entity.CreateShipment(player, item, batch, position, angles)
		local entity = ents.Create("ks_shipment");
		
		-- Check if a statement is true.
		if (!angles) then
			angles = Angle(0, 0, 0);
		end;
		
		-- Check if a statement is true.
		if (type(player) == "table") then
			if (player.key and player.uniqueID) then
				kuroScript.player.GivePropertyOffline(player.key, player.uniqueID, entity, true);
			end;
		elseif ( ValidEntity(player) ) then
			kuroScript.player.GiveProperty(player, entity);
		end;
		
		-- Set some information.
		entity:SetAngles(angles);
		entity:SetItem(item, batch);
		entity:SetPos(position);
		entity:Spawn();
		
		-- Return the new entity.
		return entity;
	end;
	
	-- A function to create an item.
	function kuroScript.entity.CreateItem(player, class, position, angles)
		local itemTable = kuroScript.item.Get(class);
		local entity = ents.Create("ks_item");
		
		-- Check if a statement is true.
		if (!angles) then
			angles = Angle(0, 0, 0);
		end;
		
		-- Check if a statement is true.
		if (type(player) == "table") then
			if (player.key and player.uniqueID) then
				kuroScript.player.GivePropertyOffline(player.key, player.uniqueID, entity, true);
			end;
		elseif ( ValidEntity(player) ) then
			kuroScript.player.GiveProperty(player, entity);
		end;
		
		-- Set some information.
		entity:SetAngles(angles);
		entity:SetItem(class);
		entity:SetPos(position);
		entity:Spawn();
		
		-- Check if a statement is true.
		if (itemTable and itemTable.OnSpawned) then
			itemTable:OnSpawned(entity);
		end;
		
		-- Return the new entity.
		return entity;
	end;
	
	-- A function to copy an entity's owner.
	function kuroScript.entity.CopyOwner(entity, target)
		local removeDelay = kuroScript.entity.QueryProperty(entity, "removeDelay");
		local networked = kuroScript.entity.QueryProperty(entity, "networked");
		local uniqueID = kuroScript.entity.QueryProperty(entity, "uniqueID");
		local key = kuroScript.entity.QueryProperty(entity, "key");
		
		-- Give the property to an offline player.
		kuroScript.player.GivePropertyOffline(key, uniqueID, target, networked, removeDelay);
	end;
	
	-- A function to set a property variable for an entity.
	function kuroScript.entity.SetPropertyVar(entity, key, value)
		if (entity._Property) then entity._Property[key] = value; end;
	end;
	
	-- A function to query an entity's property table.
	function kuroScript.entity.QueryProperty(entity, key, default)
		if (entity._Property) then
			return entity._Property[key] or default;
		else
			return default;
		end;
	end;
	
	-- A function to clear an entity as property.
	function kuroScript.entity.ClearProperty(entity)
		local owner = kuroScript.entity.GetOwner(entity);

		-- Check if a statement is true.
		if (owner) then
			kuroScript.player.TakeProperty(owner, entity);
		elseif ( kuroScript.entity.HasOwner(entity) ) then
			local uniqueID = kuroScript.entity.QueryProperty(entity, "uniqueID");
			local key = kuroScript.entity.QueryProperty(entity, "key");
			
			-- Take the property from an offline player.
			kuroScript.player.TakePropertyOffline(key, uniqueID, entity);
		end;
	end;

	-- A function to get whether an entity has an owner.
	function kuroScript.entity.HasOwner(entity)
		return kuroScript.entity.QueryProperty(entity, "owned");
	end;
	
	-- A function to get an entity's owner.
	function kuroScript.entity.GetOwner(entity)
		local owner = kuroScript.entity.QueryProperty(entity, "owner");
		
		-- Check if a statement is true.
		if ( ValidEntity(owner) ) then
			return owner;
		end;
	end;
else
	function kuroScript.entity.Decay(entity, seconds, callback)
		local r, g, b, a = entity:GetColor();
		local subtract = math.ceil(a / seconds);
		local index = entity:EntIndex();
		local alpha = a;
		
		-- Set some information.
		entity:SetNetworkedBool("ks_Decaying", true);
		
		-- Set some information.
		kuroScript.frame:CreateTimer("Decay: "..tostring( {} ), 1, 0, function()
			alpha = alpha - subtract;
			
			-- Check if a statement is true.
			if ( ValidEntity(entity) ) then
				local r, g, b, a = entity:GetColor();
				local decayed = math.Clamp(alpha, 0, 255);
				
				-- Check if a statement is true.
				if (a <= 0) then
					if (callback) then callback(); end;
					
					-- Set some information.
					kuroScript.frame:DestroyTimer("Decay: "..index); entity:Remove();
				else
					entity:SetColor(r, g, b, decayed);
				end;
			else
				kuroScript.frame:DestroyTimer("Decay: "..index);
			end;
		end);
	end;
	
	-- A function to get whether an entity has an owner.
	function kuroScript.entity.HasOwner(entity)
		return entity:GetNetworkedBool("ks_Owned");
	end;
	
	-- A function to get an entity's owner.
	function kuroScript.entity.GetOwner(entity)
		local owner = entity:GetNetworkedEntity("ks_Owner");
		
		-- Check if a statement is true.
		if ( ValidEntity(owner) ) then
			return owner;
		end;
	end;
end;