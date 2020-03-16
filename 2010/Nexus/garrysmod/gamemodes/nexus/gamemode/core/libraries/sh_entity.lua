--[[
Name: "sh_entity.lua".
Product: "nexus".
--]]

nexus.entity = {};

-- A function to register an entity's shared vars.
function nexus.entity.RegisterSharedVars(entity, sharedVars)
	if (!entity.sharedVars) then
		entity.sharedVars = {};
	end;
	
	for k, v in pairs(sharedVars) do
		entity.sharedVars[ v[1] ] = v[2];
	end;
end;

-- A function to check if an entity is a door.
function nexus.entity.IsDoor(entity)
	if ( IsValid(entity) ) then
		local class = entity:GetClass();
		local model = entity:GetModel();
		
		if (class and model) then
			class = string.lower(class);
			model = string.lower(model);
			
			if (class == "func_door" or class == "func_door_rotating" or class == "prop_door_rotating"
			or ( class == "prop_dynamic" and string.find(model, "door") ) or class == "func_movelinear") then
				return true;
			end;
		end;
	end;
end;

-- A function to get whether an entity is decaying.
function nexus.entity.IsDecaying(entity)
	return entity.decaying;
end;

-- A function to check if an entity is in a box.
function nexus.entity.IsInBox(entity, minimum, maximum)
	local position = entity:GetPos();
	
	if ( entity:IsPlayer() or entity:IsNPC() ) then
		position = entity:GetShootPos();
	end;
	
	if ( ( position.x >= math.min(minimum.x, maximum.x) and position.x <= math.max(minimum.x, maximum.x) )
	and ( position.y >= math.min(minimum.y, maximum.y) and position.y <= math.max(minimum.y, maximum.y) )
	and ( position.z >= math.min(minimum.z, maximum.z) and position.z <= math.max(minimum.z, maximum.z) ) ) then
		return true;
	else
		return false;
	end;
end;

-- A function to get a ragdoll entity's pelvis position.
function nexus.entity.GetPelvisPosition(entity)
	local position = entity:GetPos();
	local bone = entity:LookupBone("ValveBiped.Bip01_Pelvis");

	if (bone) then
		local bonePosition = entity:GetBonePosition(bone);
		
		if (bonePosition) then
			position = bonePosition;
		end;
	end;
	
	return position;
end;

-- A function to get whether an entity can see a position.
function nexus.entity.CanSeePosition(entity, position, allowance, ignoreEnts)
	local trace = {};
	
	trace.mask = CONTENTS_SOLID + CONTENTS_MOVEABLE + CONTENTS_OPAQUE + CONTENTS_DEBRIS + CONTENTS_HITBOX + CONTENTS_MONSTER;
	trace.start = entity:LocalToWorld( entity:OBBCenter() );
	trace.endpos = position;
	trace.filter = {entity};
	
	if (ignoreEnts) then
		if (type(ignoreEnts) == "table") then
			table.Add(trace.filter, ignoreEnts);
		else
			table.Add( trace.filter, ents.GetAll() );
		end;
	end;
	
	trace = util.TraceLine(trace);
	
	if ( trace.Fraction >= (allowance or 0.75) ) then
		return true;
	end;
end;

-- A function to get whether an entity can see an NPC.
function nexus.entity.CanSeeNPC(entity, target, allowance, ignoreEnts)
	local trace = {};
	
	trace.mask = CONTENTS_SOLID + CONTENTS_MOVEABLE + CONTENTS_OPAQUE + CONTENTS_DEBRIS + CONTENTS_HITBOX + CONTENTS_MONSTER;
	trace.start = entity:LocalToWorld( entity:OBBCenter() );
	trace.endpos = target:GetShootPos();
	trace.filter = {entity, target};
	
	if (ignoreEnts) then
		if (type(ignoreEnts) == "table") then
			table.Add(trace.filter, ignoreEnts);
		else
			table.Add( trace.filter, ents.GetAll() );
		end;
	end;
	
	trace = util.TraceLine(trace);
	
	if ( trace.Fraction >= (allowance or 0.75) ) then
		return true;
	end;
end;

-- A function to get whether an entity can see a player.
function nexus.entity.CanSeePlayer(entity, target, allowance, ignoreEnts)
	if (target:GetEyeTraceNoCursor().Entity == entity) then
		return true;
	else
		local trace = {};
		
		trace.mask = CONTENTS_SOLID + CONTENTS_MOVEABLE + CONTENTS_OPAQUE + CONTENTS_DEBRIS + CONTENTS_HITBOX + CONTENTS_MONSTER;
		trace.start = entity:LocalToWorld( entity:OBBCenter() );
		trace.endpos = target:GetShootPos();
		trace.filter = {entity, target};
		
		if (ignoreEnts) then
			if (type(ignoreEnts) == "table") then
				table.Add(trace.filter, ignoreEnts);
			else
				table.Add( trace.filter, ents.GetAll() );
			end;
		end;
		
		trace = util.TraceLine(trace);
		
		if ( trace.Fraction >= (allowance or 0.75) ) then
			return true;
		end;
	end;
end;

-- A function to get whether an entity can see an entity.
function nexus.entity.CanSeeEntity(entity, target, allowance, ignoreEnts)
	local trace = {};
	
	trace.mask = CONTENTS_SOLID + CONTENTS_MOVEABLE + CONTENTS_OPAQUE + CONTENTS_DEBRIS + CONTENTS_HITBOX + CONTENTS_MONSTER;
	trace.start = entity:LocalToWorld( entity:OBBCenter() );
	trace.endpos = target:LocalToWorld( target:OBBCenter() );
	trace.filter = {entity, target};
	
	if (ignoreEnts) then
		if (type(ignoreEnts) == "table") then
			table.Add(trace.filter, ignoreEnts);
		else
			table.Add( trace.filter, ents.GetAll() );
		end;
	end;
	
	trace = util.TraceLine(trace);
	
	if ( trace.Fraction >= (allowance or 0.75) ) then
		return true;
	end;
end;

-- A function to get whether a door is unownable.
function nexus.entity.IsDoorUnownable(entity)
	return entity:GetNetworkedBool("sh_Unownable");
end;

-- A function to get whether a door is false.
function nexus.entity.IsDoorFalse(entity)
	return nexus.entity.IsDoorUnownable(entity) and nexus.entity.GetDoorName(entity) == "false";
end;

-- A function to get whether a door is hidden.
function nexus.entity.IsDoorHidden(entity)
	return nexus.entity.IsDoorUnownable(entity) and nexus.entity.GetDoorName(entity) == "hidden";
end;

-- A function to get a door's name.
function nexus.entity.GetDoorName(entity)
	return entity:GetNetworkedString("sh_Name");
end;

-- A function to get a door's text.
function nexus.entity.GetDoorText(entity)
	return entity:GetNetworkedString("sh_Text");
end;

-- A function to get whether an entity is a player ragdoll.
function nexus.entity.IsPlayerRagdoll(entity)
	local player = entity:GetNetworkedEntity("sh_Player");
	
	if ( IsValid(player) ) then
		if (player:GetRagdollEntity() == entity) then
			return true;
		end;
	end;
end;

-- A function to set a shared variable for an entity.
function nexus.entity.SetSharedVar(entity, key, value)
	if ( IsValid(entity) ) then
		if ( entity.sharedVars and entity.sharedVars[key] ) then
			local class = NEXUS:ConvertNetworkedClass( entity.sharedVars[key] );
			
			if (class) then
				if (value == nil) then
					value = NEXUS:GetDefaultClassValue(class);
				end;
				
				entity["SetNetworked"..class](entity, key, value);
			else
				entity:SetNetworkedVar(key, value);
			end;
		else
			entity:SetNetworkedVar(key, value);
		end;
	end;
end;

-- A function to get an entity's shared variable.
function nexus.entity.GetSharedVar(entity, key)
	if ( IsValid(entity) ) then
		if ( entity.sharedVars and entity.sharedVars[key] ) then
			local class = NEXUS:ConvertNetworkedClass( entity.sharedVars[key] );
			
			if (class) then
				return entity["GetNetworked"..class](entity, key);
			else
				return entity:GetNetworkedVar(key);
			end;
		else
			return entity:GetNetworkedVar(key);
		end;
	end;
end;

-- A function to get an entity's player.
function nexus.entity.GetPlayer(entity)
	local player = entity:GetNetworkedEntity("sh_Player");
	
	if ( IsValid(player) ) then
		return player;
	elseif ( entity:IsPlayer() ) then
		return entity;
	end;
end;

-- A function to get whether an entity is interactable.
function nexus.entity.IsInteractable(entity)
	local class = entity:GetClass();
	
	if ( string.find(class, "prop_") ) then
		if ( entity:HasSpawnFlags(SF_PHYSPROP_MOTIONDISABLED) or entity:HasSpawnFlags(SF_PHYSPROP_PREVENT_PICKUP) ) then
			return false;
		end;
	end;
	
	if ( entity:IsNPC() or entity:IsPlayer() or string.find(class, "prop_dynamic") ) then
		return false;
	end;
	
	if ( class == "func_physbox" and entity:HasSpawnFlags(SF_PHYSBOX_MOTIONDISABLED) ) then
		return false;
	end
	
	if ( class != "func_physbox" and string.find(class, "func_") ) then
		return false;
	end;
	
	if ( nexus.entity.IsDoor(entity) ) then
		return false;
	end;
	
	return true;
end;

-- A function to get whether an entity is a physics entity.
function nexus.entity.IsPhysicsEntity(entity)
	local class = string.lower( entity:GetClass() );
	
	if (class == "prop_physics_multiplayer" or class == "prop_physics") then
		return true;
	end;
end;

-- A function to get whether an entity is a pod.
function nexus.entity.IsPodEntity(entity)
	local entityModel = string.lower( entity:GetModel() );
	
	if ( string.find(entityModel, "prisoner") ) then
		return true;
	end;
end;

-- A function to get whether an entity is a chair.
function nexus.entity.IsChairEntity(entity)
	local entityModel = string.lower( entity:GetModel() );
	
	if ( string.find(entityModel, "chair") or string.find(entityModel, "seat") ) then
		return true;
	end;
end;

if (SERVER) then
	function nexus.entity.OpenDoor(entity, delay, unlock, sound, origin)
		if ( nexus.entity.IsDoor(entity) ) then
			if (unlock) then
				entity:Fire("Unlock", "", delay);
				
				delay = delay + 0.025;
				
				if (sound) then
					entity:EmitSound("physics/wood/wood_box_impact_hard3.wav");
				end;
			end;
			
			if (entity:GetClass() == "prop_dynamic") then
				entity:Fire("SetAnimation", "open", delay);
				entity:Fire("SetAnimation", "close", delay + 5);
			elseif (origin and string.lower( entity:GetClass() ) == "prop_door_rotating") then
				local target = ents.Create("info_target");
				
				target:SetName( tostring(target) );
				target:SetPos(origin);
				target:Spawn();
				
				entity:Fire("OpenAwayFrom", tostring(target), delay);
				
				timer.Simple(delay + 1, function()
					if ( IsValid(target) ) then
						target:Remove();
					end;
				end);
			else
				entity:Fire("Open", "", delay);
			end;
		end;
	end;
	
	-- A function to drop items and cash.
	function nexus.entity.DropItemsAndCash(inventory, cash, position, entity)
		if (inventory and table.Count(inventory) > 0) then
			for k, v in pairs(inventory) do
				local amount = v;
				
				if (amount > 0) then
					for i = 1, v do
						local item = nexus.entity.CreateItem(nil, k, position);
						
						if ( IsValid(item) and IsValid(entity) ) then
							nexus.entity.CopyOwner(entity, item);
						end;
					end;
				end;
			end;
		end;
			
		if (cash and cash > 0) then
			nexus.entity.CreateCash(nil, cash, position);
		end;
	end;
	
	-- A function to make an entity into a ragdoll.
	function nexus.entity.MakeIntoRagdoll(entity, force, overrideVelocity, overrideAngles)
		local velocity = entity:GetVelocity() * 1.5;
		local ragdoll = ents.Create("prop_ragdoll");
		
		if (overrideVelocity) then
			velocity = overrideVelocity;
		end;
		
		if (overrideAngles) then
			ragdoll:SetAngles(overrideAngles);
		else
			ragdoll:SetAngles( entity:GetAngles() );
		end;
		
		ragdoll:SetMaterial( entity:GetMaterial() );
		ragdoll:SetAngles( entity:GetAngles() - Angle(0, -45, 0) );
		ragdoll:SetColor( entity:GetColor() );
		ragdoll:SetModel( entity:GetModel() );
		ragdoll:SetSkin( entity:GetSkin() );
		ragdoll:SetPos( entity:GetPos() );
		ragdoll:Spawn();
		
		if ( IsValid(ragdoll) ) then
			local headIndex = ragdoll:LookupBone("ValveBiped.Bip01_Head1");
			
			for i = 1, ragdoll:GetPhysicsObjectCount() do
				local physicsObject = ragdoll:GetPhysicsObjectNum(i);
				local boneIndex = ragdoll:TranslatePhysBoneToBone(i);
				local position, angle = entity:GetBonePosition(boneIndex);
				
				if ( IsValid(physicsObject) ) then
					physicsObject:SetPos(position);
					physicsObject:SetAngle(angle);
					
					if (boneIndex == headIndex) then
						physicsObject:SetVelocity(velocity * 2);
					else
						physicsObject:SetVelocity(velocity);
					end;
					
					if (force) then
						if (boneIndex == headIndex) then
							physicsObject:ApplyForceCenter(force * 2);
						else
							physicsObject:ApplyForceCenter(force);
						end;
					end;
				end;
			end;
		end;
		
		if ( entity:IsOnFire() ) then
			ragdoll:Ignite(8, 0);
		end;
		
		return ragdoll;
	end;
	
	-- A function to get whether a door is unsellable.
	function nexus.entity.IsDoorUnsellable(door)
		return door.unsellable;
	end;
	
	-- A function to set a door's parent.
	function nexus.entity.SetDoorParent(door, parent)
		if ( nexus.entity.IsDoor(door) ) then
			for k, v in pairs( nexus.entity.GetDoorChildren(door) ) do
				if ( IsValid(v) ) then
					nexus.entity.SetDoorParent(v, false);
				end;
			end;
			
			if ( IsValid(door.doorParent) ) then
				if (door.doorParent.doorChildren) then
					door.doorParent.doorChildren[door] = nil;
				end;
			end;
			
			if ( IsValid(parent) and nexus.entity.IsDoor(parent) ) then
				if (parent.doorChildren) then
					parent.doorChildren[door] = door;
				else
					parent.doorChildren = { [door] = door };
				end;
				
				door.doorParent = parent;
			else
				door.doorParent = nil;
			end;
			
			door.sharedAccess = nil;
			door.sharedText = nil;
		end;
	end;
	
	-- A function to get whether is a door is a parent.
	function nexus.entity.IsDoorParent(door)
		return table.Count( nexus.entity.GetDoorChildren(door) ) > 0;
	end;

	-- A function to get a door's parent.
	function nexus.entity.GetDoorParent(door)
		if ( IsValid(door.doorParent) ) then
			return door.doorParent;
		end;
	end;

	-- A function to get a door's children.
	function nexus.entity.GetDoorChildren(door)
		return door.doorChildren or {};
	end;
	
	-- A function to set a door as unownable.
	function nexus.entity.SetDoorUnownable(entity, unownable)
		if ( nexus.entity.IsDoor(entity) ) then
			if (unownable) then
				entity:SetNetworkedBool("sh_Unownable", true);
				
				if ( nexus.entity.GetOwner(entity) ) then
					nexus.player.TakeDoor(nexus.entity.GetOwner(entity), entity, true);
				elseif ( nexus.entity.HasOwner(entity) ) then
					nexus.entity.ClearProperty(entity);
				end;
			else
				entity:SetNetworkedBool("sh_Unownable", false);
			end;
		end;
	end;
	
	-- A function to set whether a door is false.
	function nexus.entity.SetDoorFalse(entity, isFalse)
		if ( nexus.entity.IsDoor(entity) ) then
			if (isFalse) then
				nexus.entity.SetDoorUnownable(entity, true);
				nexus.entity.SetDoorName(entity, "false");
			else
				nexus.entity.SetDoorUnownable(entity, false);
				nexus.entity.SetDoorName(entity, "");
			end;
		end;
	end;
	
	-- A function to set whether a door is hidden.
	function nexus.entity.SetDoorHidden(entity, hidden)
		if ( nexus.entity.IsDoor(entity) ) then
			if (hidden) then
				nexus.entity.SetDoorUnownable(entity, true);
				nexus.entity.SetDoorName(entity, "hidden");
			else
				nexus.entity.SetDoorUnownable(entity, false);
				nexus.entity.SetDoorName(entity, "");
			end;
		end;
	end;
	
	-- A function to set whether a door has shared access.
	function nexus.entity.SetDoorSharedAccess(entity, sharedAccess)
		if ( nexus.entity.IsDoorParent(entity) ) then
			entity.sharedAccess = sharedAccess;
		end;
	end;
	
	-- A function to set whether a door has shared access.
	function nexus.entity.SetDoorSharedText(entity, sharedText)
		if ( nexus.entity.IsDoorParent(entity) ) then
			entity.sharedText = sharedText;
			
			if (sharedText) then
				for k, v in pairs( nexus.entity.GetDoorChildren(entity) ) do
					if ( IsValid(v) ) then
						 nexus.entity.SetDoorText( v, nexus.entity.GetDoorText(entity) );
					end;
				end;
			end;
		end;
	end;
	
	-- A function to get whether a door has shared access.
	function nexus.entity.DoorHasSharedAccess(entity)
		return entity.sharedAccess;
	end;
	
	-- A function to get whether a door has shared text.
	function nexus.entity.DoorHasSharedText(entity)
		return entity.sharedText;
	end;
	
	-- A function to set a door's text.
	function nexus.entity.SetDoorText(entity, text)
		if ( nexus.entity.IsDoor(entity) ) then
			if ( nexus.entity.IsDoorParent(entity) ) then
				if ( nexus.entity.DoorHasSharedText(entity) ) then
					for k, v in pairs( nexus.entity.GetDoorChildren(entity) ) do
						if ( IsValid(v) ) then
							 nexus.entity.SetDoorText(v, text);
						end;
					end;
				end;
			end;
			
			if (text) then
				if ( !string.find(string.gsub(string.lower(text), "%s", ""), "thisdoorcanbepurchased") ) then
					entity:SetNetworkedString("sh_Text", text);
				end;
			else
				entity:SetNetworkedString("sh_Text", "");
			end;
		end;
	end;
	
	-- A function to set a door's name.
	function nexus.entity.SetDoorName(entity, name)
		if ( nexus.entity.IsDoor(entity) ) then
			if (name) then
				entity:SetNetworkedString("sh_Name", name);
			else
				entity:SetNetworkedString("sh_Name", "");
			end;
		end;
	end;
	
	-- A function to set an entity's chair animations.
	function nexus.entity.SetChairAnimations(entity)
		if (!entity.VehicleTable) then
			local targetFaction = "prop_vehicle_prisoner_pod";
			
			if (entity:GetClass() == targetFaction) then
				local entityModel = string.lower( entity:GetModel() );
				
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
				
				if ( nexus.entity.IsChairEntity(entity) ) then
					local entityModel = string.lower( entity:GetModel() );
					local vehicles = list.Get("Vehicles");
					-- local k2, v2;
					
					for k, v in pairs(vehicles) do
						local keyValues = v.KeyValues;
						local members = v.Members;
						local model = v.Model;
						local class = v.Class;
						
						if (string.lower(class) == targetFaction) then
							if (string.lower(model) == entityModel) then
								for k2, v2 in pairs(keyValues) do
									entity:SetKeyValue(k2, v2);
								end;
								
								entity.VehicleTable = v;
								entity.ClassOverride = class;
								
								table.Merge(entity, members);
								
								return true;
							end;
						end;
					end;
				end;
			end;
		end;
	end;
	
	-- A function to set an entity's start angles.
	function nexus.entity.SetStartAngles(entity, angles)
		entity.startAngles = angles;
	end;
	
	-- A function to get an entity's start angles.
	function nexus.entity.GetStartAngles(entity)
		return entity.startAngles;
	end;
	
	-- A function to set an entity's start position.
	function nexus.entity.SetStartPosition(entity, position)
		entity.startPosition = position;
	end;
	
	-- A function to get an entity's start position.
	function nexus.entity.GetStartPosition(entity)
		return entity.startPosition;
	end;

	-- A function to set whether an entity is a map entity.
	function nexus.entity.SetMapEntity(entity, boolean)
		if (boolean) then
			NEXUS.Entities[entity] = entity;
		else
			NEXUS.Entities[entity] = nil;
		end;
	end;
	
	-- A function to get whether an entity is a map entity.
	function nexus.entity.IsMapEntity(entity)
		if ( NEXUS.Entities[entity] ) then
			return true;
		end;
	end;
	
	-- A function to make an entity flush with the ground.
	function nexus.entity.MakeFlushToGround(entity, position, normal)
		entity:SetPos( position + ( entity:GetPos() - entity:NearestPoint( position - (normal * 512) ) ) );
	end;
	
	-- A function to make an entity disintegrate.
	function nexus.entity.Disintegrate(entity, delay, velocity, Callback)
		if (velocity) then
			if (entity:GetClass() == "prop_ragdoll") then
				for i = 1, entity:GetPhysicsObjectCount() do
					local physicsObject = entity:GetPhysicsObjectNum(i);
					
					if ( IsValid(physicsObject) ) then
						physicsObject:AddVelocity(velocity);
					end;
				end;
			elseif ( IsValid( entity:GetPhysicsObject() ) ) then
				entity:GetPhysicsObject():AddVelocity(velocity);
			end;
		end;
		
		nexus.entity.Decay(entity, delay, Callback);
		
		if (velocity) then
			timer.Simple(math.min(1, delay / 2), function()
				if ( IsValid(entity) ) then
					entity:SetNotSolid(true);
					
					if (entity:GetClass() == "prop_ragdoll") then
						for i = 1, entity:GetPhysicsObjectCount() do
							local physicsObject = entity:GetPhysicsObjectNum(i);
							
							if ( IsValid(physicsObject) ) then
								physicsObject:EnableMotion(false);
							end;
						end;
					elseif ( IsValid( entity:GetPhysicsObject() ) ) then
						entity:GetPhysicsObject():EnableMotion(false);
					end;
				end;
			end);
		else
			entity:SetNotSolid(true);
			
			if (entity:GetClass() == "prop_ragdoll") then
				for i = 1, entity:GetPhysicsObjectCount() do
					local physicsObject = entity:GetPhysicsObjectNum(i);
					
					if ( IsValid(physicsObject) ) then
						physicsObject:EnableMotion(false);
					end;
				end;
			elseif ( IsValid( entity:GetPhysicsObject() ) ) then
				entity:GetPhysicsObject():EnableMotion(false);
			end;
		end;
		
		local effectData = EffectData();
			effectData:SetEntity(entity);
		util.Effect("entity_remove", effectData, true, true);
	end;
	
	-- A function to set an entity's player.
	function nexus.entity.SetPlayer(entity, player)
		entity:SetNetworkedEntity("sh_Player", player);
	end;
	
	-- A function to make an entity decay.
	function nexus.entity.Decay(entity, seconds, Callback)
		local r, g, b, a = entity:GetColor();
		local subtract = math.ceil(a / seconds);
		local index = tostring( {} );
		local alpha = a;
		
		if (entity.decaying) then
			index = entity.decaying;
		else
			entity.decaying = index;
		end;
		
		nexus.entity.SetPlayer(entity, NULL);
		
		NEXUS:CreateTimer("Decay: "..index, 1, 0, function()
			alpha = alpha - subtract;
			
			if ( IsValid(entity) ) then
				local r, g, b, a = entity:GetColor();
				local decayed = math.Clamp(math.ceil(alpha), 0, 255);
				
				if (a <= 0) then
					if (Callback) then
						Callback();
					end;
					
					entity:Remove();
					
					NEXUS:DestroyTimer("Decay: "..index);
				else
					entity:SetColor(r, g, b, decayed);
				end;
			else
				NEXUS:DestroyTimer("Decay: "..index);
			end;
		end);
	end;
	
	-- A function to create cash.
	function nexus.entity.CreateCash(player, cash, position, angles)
		if ( nexus.config.Get("cash_enabled"):Get() ) then
			local entity = ents.Create("nx_cash");
			
			if (type(player) == "table") then
				if (player.key and player.uniqueID) then
					nexus.player.GivePropertyOffline(player.key, player.uniqueID, entity, true);
				end;
			elseif ( IsValid(player) ) then
				nexus.player.GiveProperty(player, entity);
			end;
			
			if (!angles) then
				angles = Angle(0, 0, 0);
			end;
			
			entity:SetPos(position);
			entity:SetAngles(angles);
			entity:Spawn();
			
			if ( IsValid(entity) ) then
				entity:SetAmount( math.Round(cash) );
				
				return entity;
			end;
		end;
	end;
	
	-- A function to create generator.
	function nexus.entity.CreateGenerator(player, class, position, angles)
		local entity = ents.Create(class);
		
		if (!angles) then
			angles = Angle(0, 0, 0);
		end;
		
		if (type(player) == "table") then
			if (player.key and player.uniqueID) then
				nexus.player.GivePropertyOffline(player.key, player.uniqueID, entity, true);
			end;
		elseif ( IsValid(player) ) then
			nexus.player.GiveProperty(player, entity, true);
		end;
		
		entity:SetAngles(angles);
		entity:SetPos(position);
		entity:Spawn();
		
		return entity;
	end;
	
	-- A function to create a shipment.
	function nexus.entity.CreateShipment(player, item, batch, position, angles)
		local entity = ents.Create("nx_shipment");
		
		if (!angles) then
			angles = Angle(0, 0, 0);
		end;
		
		if (type(player) == "table") then
			if (player.key and player.uniqueID) then
				nexus.player.GivePropertyOffline(player.key, player.uniqueID, entity, true);
			end;
		elseif ( IsValid(player) ) then
			nexus.player.GiveProperty(player, entity);
		end;
		
		entity:SetAngles(angles);
		entity:SetItem(item, batch);
		entity:SetPos(position);
		entity:Spawn();
		
		return entity;
	end;
	
	-- A function to create an item.
	function nexus.entity.CreateItem(player, class, position, angles)
		local itemTable = nexus.item.Get(class);
		local entity = ents.Create("nx_item");
		
		if (!angles) then
			angles = Angle(0, 0, 0);
		end;
		
		if (type(player) == "table") then
			if (player.key and player.uniqueID) then
				nexus.player.GivePropertyOffline(player.key, player.uniqueID, entity, true);
			end;
		elseif ( IsValid(player) ) then
			nexus.player.GiveProperty(player, entity);
		end;
		
		entity:SetAngles(angles);
		entity:SetItem(class);
		entity:SetPos(position);
		entity:Spawn();
		
		if (itemTable and itemTable.OnEntitySpawned) then
			itemTable:OnEntitySpawned(entity);
		end;
		
		return entity;
	end;
	
	-- A function to copy an entity's owner.
	function nexus.entity.CopyOwner(entity, target)
		local removeDelay = nexus.entity.QueryProperty(entity, "removeDelay");
		local networked = nexus.entity.QueryProperty(entity, "networked");
		local uniqueID = nexus.entity.QueryProperty(entity, "uniqueID");
		local key = nexus.entity.QueryProperty(entity, "key");
		
		nexus.player.GivePropertyOffline(key, uniqueID, target, networked, removeDelay);
	end;
	
	-- A function to set a property variable for an entity.
	function nexus.entity.SetPropertyVar(entity, key, value)
		if (entity.property) then entity.property[key] = value; end;
	end;
	
	-- A function to query an entity's property table.
	function nexus.entity.QueryProperty(entity, key, default)
		if (entity.property) then
			return entity.property[key] or default;
		else
			return default;
		end;
	end;
	
	-- A function to clear an entity as property.
	function nexus.entity.ClearProperty(entity)
		local owner = nexus.entity.GetOwner(entity);

		if (owner) then
			nexus.player.TakeProperty(owner, entity);
		elseif ( nexus.entity.HasOwner(entity) ) then
			local uniqueID = nexus.entity.QueryProperty(entity, "uniqueID");
			local key = nexus.entity.QueryProperty(entity, "key");
			
			nexus.player.TakePropertyOffline(key, uniqueID, entity);
		end;
	end;

	-- A function to get whether an entity has an owner.
	function nexus.entity.HasOwner(entity)
		return nexus.entity.QueryProperty(entity, "owned");
	end;
	
	-- A function to get an entity's owner.
	function nexus.entity.GetOwner(entity)
		local owner = nexus.entity.QueryProperty(entity, "owner");
		
		if ( IsValid(owner) ) then
			return owner;
		end;
	end;
else
	function nexus.entity.Decay(entity, seconds, Callback)
		local r, g, b, a = entity:GetColor();
		local subtract = math.ceil(a / seconds);
		local index = tostring( {} );
		local alpha = a;
		
		if (entity.decaying) then
			index = entity.decaying;
		else
			entity.decaying = index;
		end;
		
		NEXUS:CreateTimer("Decay: "..index, 1, 0, function()
			alpha = alpha - subtract;
			
			if ( IsValid(entity) ) then
				local r, g, b, a = entity:GetColor();
				local decayed = math.Clamp(math.ceil(alpha), 0, 255);
				
				if (a <= 0) then
					if (Callback) then
						Callback();
					end;
					
					entity:Remove();
					
					NEXUS:DestroyTimer("Decay: "..index);
				else
					entity:SetColor(r, g, b, decayed);
				end;
			else
				NEXUS:DestroyTimer("Decay: "..index);
			end;
		end);
	end;
	
	--[[
		Description: A function to calculate a door's text position.
		Author: Nori (thanks a lot mate, if you're reading this, check out
		CakeScript G3 - it's epic!).
	]]--
	function nexus.entity.CalculateDoorTextPosition(door, reversed)
		local traceData = {};
		local obbCenter = door:OBBCenter();
		local obbMaxs = door:OBBMaxs();
		local obbMins = door:OBBMins();
		
		traceData.endpos = door:LocalToWorld(obbCenter);
		traceData.filter = ents.FindInSphere(traceData.endpos, 20);
		
		for k, v in pairs(traceData.filter) do
			if (v == door) then
				traceData.filter[k] = nil;
			end;
		end;
		
		local length = 0;
		local width = 0;
		local size = obbMins - obbMaxs;
		
		size.x = math.abs(size.x);
		size.y = math.abs(size.y);
		size.z = math.abs(size.z);
		
		if (size.z < size.x and size.z < size.y) then
			length = size.z;
			width = size.y;
			
			if (reverse) then
				traceData.start = traceData.endpos - (door:GetUp() * length);
			else
				traceData.start = traceData.endpos + (door:GetUp() * length);
			end;
		elseif (size.x < size.y) then
			length = size.x;
			width = size.y;
			
			if (reverse) then
				traceData.start = traceData.endpos - (door:GetForward() * length);
			else
				traceData.start = traceData.endpos + (door:GetForward() * length);
			end;
		elseif (size.y < size.x) then
			length = size.y;
			width = size.x;
			
			if (reverse) then
				traceData.start = traceData.endpos - (door:GetRight() * length);
			else
			
				traceData.start = traceData.endpos + (door:GetRight() * length);
			end;
		end;

		local trace = util.TraceLine(traceData);
		local angles = trace.HitNormal:Angle();
		
		if (trace.HitWorld and !reversed) then
			return nexus.entity.CalculateDoorTextPosition(door, true);
		end;
		
		angles:RotateAroundAxis(angles:Forward(), 90);
		angles:RotateAroundAxis(angles:Right(), 90);
		
		local position = trace.HitPos - ( ( (traceData.endpos - trace.HitPos):Length() * 2) + 2 ) * trace.HitNormal;
		local anglesBack = trace.HitNormal:Angle();
		local positionBack = trace.HitPos + (trace.HitNormal * 2);
		
		anglesBack:RotateAroundAxis(anglesBack:Forward(), 90);
		anglesBack:RotateAroundAxis(anglesBack:Right(), -90);
		
		return {
			positionBack = positionBack,
			anglesBack = anglesBack,
			position = position,
			hitWorld = trace.HitWorld,
			angles = angles,
			width = math.abs(width)
		};
	end;
	
	-- A function to force a menu option.
	function nexus.entity.ForceMenuOption(entity, option, arguments)
		NEXUS:StartDataStream( "EntityMenuOption", {entity, option, arguments} );
	end;
	
	-- A function to get whether an entity has an owner.
	function nexus.entity.HasOwner(entity)
		return entity:GetNetworkedBool("sh_Owned");
	end;
	
	-- A function to get an entity's owner.
	function nexus.entity.GetOwner(entity)
		local owner = entity:GetNetworkedEntity("sh_Owner");
		
		if ( IsValid(owner) ) then
			return owner;
		end;
	end;
end;